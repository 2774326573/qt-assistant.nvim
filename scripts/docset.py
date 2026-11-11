#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""docset.py -- Qt docset (Dash/Zeal format) query & render engine for qt-assistant.nvim

Subcommands:
  search <dsidx_path> <term> [limit]     -> JSON array [{"name","type","path"}]
  render <docset_root> <relpath>         -> plain text (HTML converted)

Stdlib only (sqlite3 + html.parser). Exit code 0 on success.
"""

import json
import os
import re
import sqlite3
import sys
from html.parser import HTMLParser
from html import unescape

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


def search(dsidx, term, limit=50):
    term = term.strip()
    con = sqlite3.connect(dsidx)
    cur = con.cursor()
    esc = term.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
    rows = []
    seen = set()

    def add(sql, params):
        for name, typ, path in cur.execute(sql, params):
            key = (name, path)
            if key not in seen:
                seen.add(key)
                rows.append({"name": name, "type": typ, "path": path})

    add("SELECT name, type, path FROM searchIndex WHERE name = ? COLLATE NOCASE LIMIT ?",
        (term, limit))
    add("SELECT name, type, path FROM searchIndex WHERE name LIKE ? ESCAPE '\\' COLLATE NOCASE LIMIT ?",
        (term + "%", limit))
    add("SELECT name, type, path FROM searchIndex WHERE name LIKE ? ESCAPE '\\' COLLATE NOCASE LIMIT ?",
        ("%" + esc + "%", limit))
    con.close()
    out, n = [], 0
    for r in rows:
        out.append(r)
        n += 1
        if n >= limit:
            break
    print(json.dumps(out, ensure_ascii=False))


# ---------------- HTML -> text ----------------

SKIP_CLASSES = re.compile(
    r"qds-page-header|b-header|b-topbar|b-sidebar__sidebar|c-sidebar"
    r"|c-mobile-close|hamburger|theme-switch|lang-icon|c-navigation"
    r"|l-footer|breadcrumb|feedback|prevnext|pagination|c-copy-notice",
    re.IGNORECASE)


class QtDocExtractor(HTMLParser):
    """Extract readable markdown from a Qt documentation HTML page."""

    BLOCK = {"p", "div", "section", "article", "li", "tr", "h1", "h2", "h3",
             "h4", "h5", "h6", "br", "table", "ul", "ol", "dl", "dt", "dd",
             "pre", "blockquote", "figcaption", "hr"}
    HEADINGS = {"h1": "# ", "h2": "## ", "h3": "### ", "h4": "#### ",
                "h5": "##### ", "h6": "###### "}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []
        self.skip_tag = None
        self.skip_depth = 0
        self.pre = 0
        self.in_heading = None
        # table state
        self.in_table = 0
        self.row_cells = []
        self.cell = []
        self.cell_active = False
        self.header_cells = None   # captured first row if it used th
        self.header_done = False

    def _flush_row(self):
        if not self.row_cells:
            return
        if self.header_cells is None:
            # first row of the table: emit as header + GFM separator
            self.header_cells = list(self.row_cells)
            ncol = len(self.header_cells) or 1
            self.parts.append("\n| " + " | ".join(
                c.replace("|", "\\|") for c in self.header_cells) + " |")
            self.parts.append("\n|" + "|".join([" --- "] * ncol) + "|")
            self.header_done = True
        else:
            self._emit_row(self.row_cells)
        self.row_cells = []

    def _emit_row(self, cells):
        ncol = len(self.header_cells or cells) or 1
        cells = list(cells) + [""] * (ncol - len(cells))
        self.parts.append("\n| " + " | ".join(c.replace("|", "\\|") for c in cells[:ncol]) + " |")

    def _emit_table_end(self):
        if self.header_cells is None and self.row_cells:
            # table with no complete row flush (rare): emit what we have without separator
            self._emit_row(self.row_cells)
        self.header_cells = None
        self.header_done = False

    def handle_starttag(self, tag, attrs):
        if self.skip_tag:
            # track nested same-tag elements so we only stop at the matching end
            if tag == self.skip_tag:
                self.skip_depth += 1
            return
        if tag in ("script", "style", "svg", "iframe", "head"):
            self.skip_tag = tag
            self.skip_depth = 1
            return
        attrs_d = dict(attrs or {})
        cls = attrs_d.get("class", "") or ""
        if cls and SKIP_CLASSES.search(cls):
            self.skip_tag = tag
            self.skip_depth = 1
            return
        if tag == "table":
            self.in_table += 1
            self.header_cells = None
            self.header_done = False
            return
        if self.in_table:
            if tag == "tr":
                self._flush_row()
                return
            if tag in ("td", "th"):
                self.cell_active = True
                self.cell = []
                return
        if tag == "pre":
            self.pre += 1
            self.parts.append("\n```\n")
        elif tag in self.HEADINGS:
            self.in_heading = tag
            self.parts.append("\n" + self.HEADINGS[tag])
        elif tag == "li":
            self.parts.append("\n- ")
        elif tag in self.BLOCK:
            self.parts.append("\n")

    def handle_endtag(self, tag):
        if self.skip_tag:
            if tag == self.skip_tag:
                self.skip_depth -= 1
                if self.skip_depth <= 0:
                    self.skip_tag = None
                    self.skip_depth = 0
            return
        if self.in_table:
            if tag in ("td", "th") and self.cell_active:
                self.cell_active = False
                self.row_cells.append(re.sub(r"\s+", " ", "".join(self.cell)).strip())
                self.cell = []
                return
            if tag == "tr":
                self._flush_row()
                return
            if tag == "table":
                self.in_table = max(0, self.in_table - 1)
                self._flush_row()
                self._emit_table_end()
                self.parts.append("\n")
                return
        if tag == "pre":
            self.pre = max(0, self.pre - 1)
            self.parts.append("\n```\n")
        elif tag in self.HEADINGS and self.in_heading == tag:
            self.in_heading = None
            self.parts.append("\n")
        elif tag in self.BLOCK:
            self.parts.append("\n")

    def handle_data(self, data):
        if self.skip_tag:
            return
        if self.cell_active:
            self.cell.append(data)
        elif self.pre:
            self.parts.append(data)
        elif data.strip():
            self.parts.append(re.sub(r"\s+", " ", data))

    def text(self):
        raw = "".join(self.parts)
        raw = raw.replace("\r", "")
        # drop the leading "On this page" TOC block
        raw = re.sub(r"\A\s*On this page\n\n", "", raw, count=1)
        # collapse 3+ blank lines
        raw = re.sub(r"\n[ \t]*\n[ \t\n]*\n+", "\n\n", raw)
        # trim trailing spaces
        raw = "\n".join(line.rstrip() for line in raw.split("\n"))
        return raw.strip() + "\n"


def render(docset_root, relpath):
    base = os.path.join(docset_root, "Contents", "Resources", "Documents")
    full = os.path.normpath(os.path.join(base, relpath))
    if not os.path.isfile(full):
        print("PAGE NOT FOUND: %s" % relpath, file=sys.stderr)
        sys.exit(2)
    with open(full, "r", encoding="utf-8", errors="replace") as f:
        html = f.read()
    ex = QtDocExtractor()
    ex.feed(html)
    ex.close()
    print(ex.text())


def main():
    if len(sys.argv) < 3:
        print("usage: docset.py search <dsidx> <term> [limit] | "
              "docset.py render <docset_root> <relpath>", file=sys.stderr)
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "search":
        limit = int(sys.argv[4]) if len(sys.argv) > 4 else 50
        search(sys.argv[2], sys.argv[3], limit)
    elif cmd == "render":
        render(sys.argv[2], sys.argv[3])
    else:
        print("unknown command: %s" % cmd, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
