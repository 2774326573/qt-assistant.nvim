-- Qt Assistant Plugin - Core functionality module
-- Core functionality module

local M = {}
local file_manager = require('qt-assistant.file_manager')
local templates = require('qt-assistant.templates')
local cmake = require('qt-assistant.cmake')
-- local keymaps = require('qt-assistant.keymaps') -- Removed independent keymaps module

-- Validate class name format
function M.validate_class_name(class_name)
    -- Check if empty or contains illegal characters
    if not class_name or class_name:match('%W') then
        return false
    end
    
    -- Check if starts with number
    if class_name:match('^%d') then
        return false
    end
    
    return true
end

-- Main function to create Qt class
function M.create_qt_class(class_name, class_type, options)
    options = options or {}
    
    -- Detect Qt version
    local qt_version_module = require('qt-assistant.qt_version')
    local project_path = file_manager.get_project_root()
    local qt_version = qt_version_module.get_recommended_qt_version(project_path)
    
    -- Get template configuration
    local template_config = templates.get_template_config(class_type)
    if not template_config then
        return false, "Unknown class type: " .. class_type
    end
    
    -- Determine target directory
    local target_dirs = file_manager.determine_target_directories(class_type)
    
    -- Generate file content (pass Qt version info)
    local files = M.generate_class_files(class_name, class_type, template_config, options, qt_version)
    
    -- Create files
    local success, error_msg = file_manager.create_files(files, target_dirs)
    if not success then
        return false, error_msg
    end
    
    -- Update CMakeLists.txt (if enabled)
    local ok, config_module = pcall(require, 'qt-assistant.config')
    local auto_update = ok and config_module.get().auto_update_cmake
    if auto_update then
        cmake.add_source_files(files)
    end
    
    return true
end

-- Generate class file content
function M.generate_class_files(class_name, class_type, template_config, options, qt_version)
    local files = {}
    qt_version = qt_version or 6
    
    -- Template variables
    local template_vars = {
        CLASS_NAME = class_name,
        CLASS_NAME_UPPER = string.upper(class_name),
        CLASS_NAME_LOWER = string.lower(class_name),
        FILE_NAME = file_manager.class_name_to_filename(class_name),
        HEADER_GUARD = M.generate_header_guard(class_name),
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y'),
        QT_VERSION = qt_version,
        INCLUDE_UI = template_config.has_ui and options.generate_ui ~= false
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
    
    -- Generate UI file
    if template_config.has_ui and template_vars.INCLUDE_UI then
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

-- Create Qt UI file
function M.create_qt_ui(ui_name, ui_type)
    local template_vars = {
        UI_NAME = ui_name,
        FILE_NAME = file_manager.class_name_to_filename(ui_name),
        DATE = os.date('%Y-%m-%d')
    }
    
    local ui_content = templates.render_template('ui_' .. ui_type, template_vars)
    
    local files = {
        ui = {
            name = template_vars.FILE_NAME .. '.ui',
            content = ui_content,
            type = 'ui'
        }
    }
    
    local target_dirs = file_manager.determine_target_directories('ui')
    return file_manager.create_files(files, target_dirs)
end

-- Get supported class types list
function M.get_supported_class_types()
    return {
        'main_window',
        'dialog', 
        'widget',
        'model',
        'delegate',
        'thread',
        'utility',
        'singleton'
    }
end

-- Get class type description info
function M.get_class_type_info(class_type)
    local class_info = {
        main_window = {
            name = "Main Window",
            description = "Main window class inheriting from QMainWindow",
            base_class = "QMainWindow",
            files = {"header", "source", "ui"}
        },
        dialog = {
            name = "Dialog",
            description = "Dialog class inheriting from QDialog",
            base_class = "QDialog", 
            files = {"header", "source", "ui"}
        },
        widget = {
            name = "Widget",
            description = "Custom widget class inheriting from QWidget",
            base_class = "QWidget",
            files = {"header", "source"}
        },
        model = {
            name = "Data Model",
            description = "Data model class inheriting from QAbstractItemModel",
            base_class = "QAbstractItemModel",
            files = {"header", "source"}
        },
        delegate = {
            name = "Item Delegate", 
            description = "Delegate class inheriting from QStyledItemDelegate",
            base_class = "QStyledItemDelegate",
            files = {"header", "source"}
        },
        thread = {
            name = "Thread",
            description = "Thread class inheriting from QThread",
            base_class = "QThread",
            files = {"header", "source"}
        },
        utility = {
            name = "Utility Class",
            description = "Utility class with static methods",
            base_class = "QObject",
            files = {"header", "source"}
        },
        singleton = {
            name = "Singleton",
            description = "Singleton pattern class",
            base_class = "QObject",
            files = {"header", "source"}
        }
    }
    
    return class_info[class_type]
end

-- Keyboard mapping functionality moved to main module qt-assistant.lua
-- No longer need independent keymaps module

return M