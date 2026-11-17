-- Qt Assistant Plugin - UI Designer integration module
-- UI设计师集成模块

local M = {}
local file_manager = require('qt-assistant.core.file_manager')

-- Get plugin configuration
local function get_config()
    return require('qt-assistant.core.config').get()
end

-- Cache UI file metadata so command completion never starts a deep sync scan.
local async_scan = require('qt-assistant.core.async_scan')
local uv = vim.uv or vim.loop
local ui_cache, shallow_cache, active_ui_scans = {}, {}, {}

local function ui_project_root(path)
    return vim.fs.normalize(path or get_config().project_root)
end

--- Asynchronous deep lookup; ignores generated and dependency directories.
--- @param project_path? string
--- @param callback fun(ui_files: table[], stats: table)
--- @param opts? {refresh?: boolean}
function M.find_ui_files_async(project_path, callback, opts)
    opts = opts or {}
    local root = ui_project_root(project_path)
    assert(type(callback) == 'function', 'find_ui_files_async requires callback')
    if active_ui_scans[root] then active_ui_scans[root].cancel() end

    local cached = ui_cache[root]
    if cached and not opts.refresh and os.time() - cached.timestamp < 120 then
        local cancelled = false
        vim.schedule(function()
            if not cancelled then
                callback(vim.deepcopy(cached.files), {
                    reason = 'cached', directories = 0, entries = 0,
                    truncated = cached.truncated,
                })
            end
        end)
        return function() cancelled = true end
    end

    local cancelled, child_cancel = false, nil
    local function cancel()
        cancelled = true
        if child_cancel then child_cancel() end
    end
    active_ui_scans[root] = { cancel = cancel }
    child_cancel = async_scan.walk({
        root = root,
        depth = 6,
        max_dirs = 1200,
        max_entries = 25000,
        limit = 200,
        match = function(name, dir)
            if name:match('%.ui$') then return dir .. '/' .. name end
        end,
    }, function(paths, stats)
        if cancelled then return end
        local files, index = {}, 1
        local function parse_batch()
            if cancelled then return end
            for _ = 1, 8 do
                if index > #paths then break end
                local path = paths[index]
                local info = M.analyze_ui_file(path)
                info.path = path
                info.relative_path = file_manager.get_relative_path(path, root)
                table.insert(files, info)
                index = index + 1
            end
            if index <= #paths then
                vim.schedule(parse_batch)
                return
            end
            ui_cache[root] = {
                files = files, timestamp = os.time(),
                truncated = stats.truncated,
            }
            shallow_cache[root] = nil
            if active_ui_scans[root] and active_ui_scans[root].cancel == cancel then
                active_ui_scans[root] = nil
            end
            callback(files, stats)
        end
        vim.schedule(parse_batch)
    end)
    return cancel
end

-- Compatibility synchronous API for immediate completion results. Only checks
-- standard UI directories (no recursion); deep discovery runs in the background.
function M.find_ui_files(project_path)
    local root = ui_project_root(project_path)
    local cache = ui_cache[root]
    if cache and os.time() - cache.timestamp < 120 then
        return vim.deepcopy(cache.files)
    end
    local quick = shallow_cache[root]
    if quick and os.time() - quick.timestamp < 10 then
        return vim.deepcopy(quick.files)
    end

    local files, seen = {}, {}
    local checked = 0
    for _, dir in ipairs({ root .. '/ui', root .. '/forms', root }) do
        if checked >= 300 or #files >= 100 then break end
        local handle = uv.fs_scandir(dir)
        if handle then
            while checked < 300 and #files < 100 do
                local name, kind = uv.fs_scandir_next(handle)
                if not name then break end
                checked = checked + 1
                if kind == 'file' and name:match('%.ui$') then
                    local full_path = dir .. '/' .. name
                    if not seen[full_path] then
                        seen[full_path] = true
                        local info = M.analyze_ui_file(full_path)
                        info.path = full_path
                        info.relative_path = file_manager.get_relative_path(full_path, root)
                        table.insert(files, info)
                    end
                end
            end
        end
    end
    shallow_cache[root] = { timestamp = os.time(), files = files }
    if not active_ui_scans[root] then
        M.find_ui_files_async(root, function() end)
    end
    return files
end

-- Analyze UI file
function M.analyze_ui_file(ui_file_path)
    local ui_info = {
        name = vim.fn.fnamemodify(ui_file_path, ":t:r"),
        class_name = "",
        widgets = {}
    }
    
    local content = file_manager.read_file(ui_file_path)
    if not content then
        return ui_info
    end
    
    -- Parse class name
    local class_match = content:match('<class>([^<]+)</class>')
    if class_match then
        ui_info.class_name = class_match
    end
    
    -- Parse widgets
    for widget_class, widget_name in content:gmatch('<widget class="([^"]+)" name="([^"]+)"') do
        table.insert(ui_info.widgets, {
            class = widget_class,
            name = widget_name
        })
    end
    
    return ui_info
end

-- Open Qt Designer (with comprehensive error handling)
function M.open_designer(ui_file)
    local system = require('qt-assistant.core.system')
    
    -- Detailed Qt Designer detection with helpful error messages
    local designer_path = system.find_qt_tool(get_config().qt_tools.designer_path)
    if not designer_path then
        local os_type = system.get_os()
        local install_hint = ""
        
        if os_type == 'linux' then
            install_hint = "\n💡 Try: sudo apt install qttools5-dev-tools (Ubuntu/Debian) or sudo pacman -S qt6-tools (Arch)"
        elseif os_type == 'macos' then
            install_hint = "\n💡 Try: brew install qt@6 or download from https://qt.io"
        else
            install_hint = "\n💡 Download Qt from https://qt.io and ensure it's in PATH"
        end
        
        vim.notify("❌ Qt Designer not found." .. install_hint, vim.log.levels.ERROR)
        return false
    end
    
    -- Validate UI file if specified
    if ui_file then
        if not file_manager.file_exists(ui_file) then
            vim.notify("❌ UI file not found: " .. ui_file, vim.log.levels.ERROR)
            return false
        end
        
        -- Check file is readable
        if vim.fn.filereadable(ui_file) ~= 1 then
            vim.notify("❌ UI file not readable: " .. ui_file, vim.log.levels.ERROR)
            return false
        end
        
        -- Validate UI file format
        local content = file_manager.read_file(ui_file)
        if not content or not content:match('<?xml') or not content:match('<ui') then
            vim.notify("❌ Invalid UI file format: " .. ui_file, vim.log.levels.ERROR)
            return false
        end
    end
    
    -- Build command
    local cmd = {designer_path}
    if ui_file then
        table.insert(cmd, ui_file)
        vim.notify("🎨 Opening Qt Designer with: " .. vim.fn.fnamemodify(ui_file, ":t"), vim.log.levels.INFO)
    else
        vim.notify("🎨 Opening Qt Designer", vim.log.levels.INFO)
    end
    
    -- Start Designer with error handling
    local job_id = vim.fn.jobstart(cmd, {
        detach = true,
        on_stderr = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        vim.schedule(function()
                            vim.notify("Designer Error: " .. line, vim.log.levels.WARN)
                        end)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code ~= 0 then
                    vim.notify("⚠️  Qt Designer exited with code: " .. exit_code, vim.log.levels.WARN)
                end
            end)
        end
    })
    
    if job_id <= 0 then
        vim.notify("❌ Failed to start Qt Designer. Check tool installation and permissions.", vim.log.levels.ERROR)
        return false
    end
    
    return true
end

-- Create new UI file
function M.create_new_ui(filename, target_dir)
    if not filename:match("%.ui$") then
        filename = filename .. ".ui"
    end
    
    local project_root = get_config().project_root
    local system = require('qt-assistant.core.system')

    local ui_dir = target_dir and target_dir ~= ''
        and vim.fs.normalize(target_dir)
        or (project_root .. "/ui")

    -- Ensure ui directory exists
    if not file_manager.directory_exists(ui_dir) then
        local success, error_msg = file_manager.ensure_directory_exists(ui_dir)
        if not success then
            vim.notify("Failed to create UI directory: " .. error_msg, vim.log.levels.ERROR)
            return false
        end
    end

    local ui_file_path = system.join_path(ui_dir, filename)
    
    -- Check if file already exists
    if file_manager.file_exists(ui_file_path) then
        vim.notify("UI file already exists: " .. filename, vim.log.levels.WARN)
        vim.ui.select({'Open existing file', 'Cancel'}, {
            prompt = 'File already exists. What would you like to do?'
        }, function(choice)
            if choice == 'Open existing file' then
                M.open_designer(ui_file_path)
            end
        end)
        return false
    end
    
    -- Generate basic UI template
    local class_name = vim.fn.fnamemodify(filename, ":t:r")
    local ui_content = M.generate_basic_ui_template(class_name)
    
    -- Write file
    local success = file_manager.write_file(ui_file_path, ui_content)
    if not success then
        vim.notify("Failed to create UI file: " .. filename, vim.log.levels.ERROR)
        return false
    end
    
    ui_cache[ui_project_root(project_root)] = nil
    shallow_cache[ui_project_root(project_root)] = nil
    vim.notify("Created UI file: " .. filename, vim.log.levels.INFO)
    
    -- Open in Qt Designer
    M.open_designer(ui_file_path)
    
    return true
end

-- Edit existing UI file
function M.edit_ui_file(filename)
    local project_root = get_config().project_root
    local system = require('qt-assistant.core.system')
    
    if not filename:match("%.ui$") then
        filename = filename .. ".ui"
    end
    
    -- Search for UI file
    local possible_paths = {
        system.join_path(project_root, "ui", filename),
        system.join_path(project_root, filename),
        system.join_path(vim.fn.getcwd(), filename)
    }
    
    local ui_file_path = nil
    for _, path in ipairs(possible_paths) do
        if file_manager.file_exists(path) then
            ui_file_path = path
            break
        end
    end
    
    if not ui_file_path then
        vim.notify("UI file not found: " .. filename, vim.log.levels.ERROR)
        return false
    end
    
    M.open_designer(ui_file_path)
    return true
end

-- Select UI file to open without a blocking full-tree walk.
function M.select_ui_file_to_open()
    M.find_ui_files_async(nil, function(ui_files, stats)
        if #ui_files == 0 then
            vim.notify('No UI files found in project', vim.log.levels.WARN)
            return
        end
        if stats.truncated then
            vim.notify('UI file search reached its limit; showing partial results.',
                vim.log.levels.INFO)
        end
        local options = {}
        for _, ui_info in ipairs(ui_files) do
            table.insert(options, ui_info.relative_path)
        end
        vim.ui.select(options, {
            prompt = 'Select UI file to open:',
        }, function(choice, index)
            if choice and index then M.open_designer(ui_files[index].path) end
        end)
    end)
end

-- Generate basic UI template
function M.generate_basic_ui_template(class_name)
    return string.format([[<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>%s</class>
 <widget class="QMainWindow" name="%s">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>%s</string>
  </property>
  <widget class="QWidget" name="centralwidget"/>
  <widget class="QMenuBar" name="menubar"/>
  <widget class="QStatusBar" name="statusbar"/>
 </widget>
 <resources/>
 <connections/>
</ui>]], class_name, class_name, class_name)
end

-- Get UI files for command completion
function M.get_ui_files_for_completion()
    local ui_files = M.find_ui_files()
    local filenames = {}
    
    for _, ui_info in ipairs(ui_files) do
        local filename = vim.fn.fnamemodify(ui_info.path, ":t")
        table.insert(filenames, filename)
        -- Also add basename without extension
        local basename = vim.fn.fnamemodify(ui_info.path, ":t:r")
        table.insert(filenames, basename)
    end
    
    return filenames
end

function M.get_editor_status()
    local system = require('qt-assistant.core.system')
    local function entry(tool, label)
        local path = system.find_qt_tool(tool)
        return {
            name = label,
            available = path ~= nil,
            path = path,
        }
    end
    return {
        designer = entry('designer', 'Qt Designer'),
        qtcreator = entry('qtcreator', 'Qt Creator'),
        uic = entry('uic', 'uic'),
    }
end

function M.open_designer_current()
    local current = vim.fn.expand('%:p')
    if current and current ~= '' and current:match('%.ui$') then
        return M.open_designer(current)
    end
    vim.notify('Current buffer is not a .ui file. Select a UI file instead.', vim.log.levels.INFO)
    M.select_ui_file_to_open()
    return false
end

function M.preview_ui(ui_file)
    ui_file = ui_file or vim.fn.expand('%:p')
    if not ui_file or ui_file == '' or not tostring(ui_file):match('%.ui$') or vim.fn.filereadable(ui_file) ~= 1 then
        vim.notify('Not a readable UI file: ' .. tostring(ui_file), vim.log.levels.WARN)
        return false
    end

    local info = M.analyze_ui_file(ui_file)
    local lines = {
        'UI preview: ' .. (info.name or ui_file),
        'Class: ' .. ((info.class_name and info.class_name ~= '') and info.class_name or '(unknown)'),
        'Widgets:',
    }
    for _, widget in ipairs(info.widgets or {}) do
        table.insert(lines, string.format('  %s (%s)', widget.name, widget.class))
    end
    if not info.widgets or #info.widgets == 0 then
        table.insert(lines, '  (none parsed)')
    end
    require('qt-assistant.ui').show_info_window(lines)
    return true
end

function M.sync_ui(ui_file)
    ui_file = ui_file or vim.fn.expand('%:p')
    if not ui_file or not tostring(ui_file):match('%.ui$') then
        vim.notify('Current file is not a .ui file', vim.log.levels.ERROR)
        return false
    end
    return require('qt-assistant').compile_ui_file(ui_file)
end

return M