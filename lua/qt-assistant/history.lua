-- Qt Assistant Plugin - Project history utilities

local M = {}

local MAX_RECENT = 10

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end
  local absolute = vim.fn.fnamemodify(path, ":p")
  -- strip trailing separators for consistent comparisons
  absolute = absolute:gsub("[/\\]+$", "")
  return absolute
end

local function history_file_path()
  local data_dir = vim.fn.stdpath("data")
  local system = require("qt-assistant.system")
  return system.join_path(data_dir, "qt-assistant", "recent-projects.json")
end

local function ensure_history_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

local function load_history()
  local file_path = history_file_path()
  if vim.fn.filereadable(file_path) == 0 then
    return {}
  end

  local content = table.concat(vim.fn.readfile(file_path), "\n")
  if content == "" then
    return {}
  end

  local ok, decoded = pcall(vim.fn.json_decode, content)
  if not ok or type(decoded) ~= "table" then
    return {}
  end

  return decoded
end

local function save_history(history)
  local file_path = history_file_path()
  ensure_history_dir(file_path)
  local ok, encoded = pcall(vim.fn.json_encode, history)
  if not ok then
    return
  end
  vim.fn.writefile({ encoded }, file_path)
end

function M.get_recent_projects()
  local history = load_history()
  local cleaned = {}
  local seen = {}

  for _, entry in ipairs(history) do
    if type(entry) == "string" and entry ~= "" then
      local normalized = normalize_path(entry)
      if normalized and vim.fn.isdirectory(normalized) == 1 then
        local key = normalized:lower()
        if not seen[key] then
          table.insert(cleaned, normalized)
          seen[key] = true
        end
      end
    end
  end

  if #cleaned ~= #history then
    save_history(cleaned)
  end

  return cleaned
end

function M.record_project(path)
  local normalized = normalize_path(path)
  if not normalized then
    return
  end

  local history = M.get_recent_projects()
  local filtered = { normalized }

  for _, entry in ipairs(history) do
    if entry:lower() ~= normalized:lower() then
      table.insert(filtered, entry)
    end
    if #filtered >= MAX_RECENT then
      break
    end
  end

  save_history(filtered)
end

return M
