-- Qt Assistant Plugin - Core functionality module
-- 核心功能模块

local M = {}
local file_manager = require('qt-assistant.file_manager')
local templates = require('qt-assistant.templates')
local cmake = require('qt-assistant.cmake')

-- Validate class name format
function M.validate_class_name(class_name)
    if not class_name or class_name:match('%W') then
        return false
    end
    
    if class_name:match('^%d') then
        return false
    end
    
    return true
end

-- Main function to create Qt class
function M.create_qt_class(class_name, class_type, options)
    options = options or {}
    
    -- Get template configuration
    local template_config = templates.get_template_config(class_type)
    if not template_config then
        return false, "Unknown class type: " .. class_type
    end
    
    local system = require('qt-assistant.system')
    local target_dirs = file_manager.determine_target_directories(class_type, options)
    
    -- Generate file content
    local files = M.generate_class_files(class_name, class_type, template_config, options)
    
    for file_type, file_info in pairs(files) do
        local target_dir = target_dirs[file_type]
        if target_dir then
            file_info.full_path = system.join_path(target_dir, file_info.name)
        end
    end

    -- Create files
    local success, error_msg = file_manager.create_files(files, target_dirs)
    if not success then
        return false, error_msg
    end
    
    -- Update CMakeLists.txt if enabled
    local config = require('qt-assistant.config').get()
    if config.auto_update_cmake then
        cmake.add_source_files(files)
    end
    
    return true
end

-- Generate class file content
function M.generate_class_files(class_name, class_type, template_config, options)
    local files = {}
    
    -- Template variables
    local template_vars = {
        CLASS_NAME = class_name,
        CLASS_NAME_UPPER = string.upper(class_name),
        CLASS_NAME_LOWER = string.lower(class_name),
        FILE_NAME = file_manager.class_name_to_filename(class_name),
        HEADER_GUARD = M.generate_header_guard(class_name),
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y'),
        UI_CLASS_NAME = options.ui_class_name or class_name,
        UI_HEADER = options.ui_class_name and ("ui_" .. file_manager.class_name_to_filename(options.ui_class_name) .. ".h") or ("ui_" .. file_manager.class_name_to_filename(class_name) .. ".h"),
        HAS_UI_FILE = options.ui_file ~= nil,
        INCLUDE_UI = options.include_ui or false
    }
    
    -- Generate header file
    if template_config.has_header then
        local header_content = templates.render_template(class_type .. '_header', template_vars)
        files.header = {
            name = template_vars.FILE_NAME .. '.h',
            content = header_content,
            type = 'header'
        }
    end
    
    -- Generate source file
    if template_config.has_source then
        local source_content = templates.render_template(class_type .. '_source', template_vars)
        files.source = {
            name = template_vars.FILE_NAME .. '.cpp',
            content = source_content,
            type = 'source'
        }
    end
    
    -- Generate UI file (if not from existing UI)
    if template_config.has_ui and not options.ui_file then
        local ui_content = templates.render_template(class_type .. '_ui', template_vars)
        files.ui = {
            name = template_vars.FILE_NAME .. '.ui',
            content = ui_content,
            type = 'ui'
        }
    end
    
    return files
end

-- Generate header file guard macro
function M.generate_header_guard(class_name)
    local filename = file_manager.class_name_to_filename(class_name)
    return string.upper(filename) .. "_H"
end

-- Get supported class types
function M.get_supported_class_types()
    return {'main_window', 'dialog', 'widget', 'model', 'delegate', 'thread', 'utility', 'singleton'}
end

return M