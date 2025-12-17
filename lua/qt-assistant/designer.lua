-- Qt Assistant Plugin - UI Designer integration module
-- UI设计师集成模块

local M = {}
local file_manager = require('qt-assistant.file_manager')

-- Get plugin configuration
local function get_config()
    return require('qt-assistant.config').get()
end

-- Find UI files in project
function M.find_ui_files(project_path)
    project_path = project_path or get_config().project_root
    local ui_files = {}
    
    local function scan_directory(dir)
        local handle = vim.loop.fs_scandir(dir)
        if not handle then return end
        
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            
            local full_path = dir .. "/" .. name
            
            if type == "file" and name:match("%.ui$") then
                local ui_info = M.analyze_ui_file(full_path)
                ui_info.path = full_path
                ui_info.relative_path = file_manager.get_relative_path(full_path, project_path)
                table.insert(ui_files, ui_info)
            elseif type == "directory" and not name:match("^%.") and name ~= "build" then
                scan_directory(full_path)
            end
        end
    end
    
    scan_directory(project_path)
    return ui_files
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
    local system = require('qt-assistant.system')
    
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
    local system = require('qt-assistant.system')

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
    
    vim.notify("Created UI file: " .. filename, vim.log.levels.INFO)
    
    -- Open in Qt Designer
    M.open_designer(ui_file_path)
    
    return true
end

-- Edit existing UI file
function M.edit_ui_file(filename)
    local project_root = get_config().project_root
    local system = require('qt-assistant.system')
    
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

-- Select UI file to open
function M.select_ui_file_to_open()
    local ui_files = M.find_ui_files()
    
    if #ui_files == 0 then
        vim.notify("No UI files found in project", vim.log.levels.WARN)
        return
    end
    
    local file_options = {}
    for _, ui_info in ipairs(ui_files) do
        table.insert(file_options, ui_info.relative_path)
    end
    
    vim.ui.select(file_options, {
        prompt = 'Select UI file to open:'
    }, function(choice, idx)
        if choice and idx then
            M.open_designer(ui_files[idx].path)
        end
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

return M