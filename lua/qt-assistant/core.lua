-- Qt Assistant Plugin - 核心功能模块
-- Core functionality module

local M = {}
local file_manager = require('qt-assistant.file_manager')
local templates = require('qt-assistant.templates')
local cmake = require('qt-assistant.cmake')
-- local keymaps = require('qt-assistant.keymaps') -- 已移除独立的keymaps模块

-- 验证类名格式
function M.validate_class_name(class_name)
    -- 检查是否为空或包含非法字符
    if not class_name or class_name:match('%W') then
        return false
    end
    
    -- 检查是否以数字开头
    if class_name:match('^%d') then
        return false
    end
    
    return true
end

-- 创建Qt类的主函数
function M.create_qt_class(class_name, class_type, options)
    options = options or {}
    
    -- 检测Qt版本
    local qt_version_module = require('qt-assistant.qt_version')
    local project_path = file_manager.get_project_root()
    local qt_version = qt_version_module.get_recommended_qt_version(project_path)
    
    -- 获取模板配置
    local template_config = templates.get_template_config(class_type)
    if not template_config then
        return false, "Unknown class type: " .. class_type
    end
    
    -- 确定目标目录
    local target_dirs = file_manager.determine_target_directories(class_type)
    
    -- 生成文件内容（传递Qt版本信息）
    local files = M.generate_class_files(class_name, class_type, template_config, options, qt_version)
    
    -- 创建文件
    local success, error_msg = file_manager.create_files(files, target_dirs)
    if not success then
        return false, error_msg
    end
    
    -- 更新CMakeLists.txt（如果启用）
    local ok, config_module = pcall(require, 'qt-assistant.config')
    local auto_update = ok and config_module.get().auto_update_cmake
    if auto_update then
        cmake.add_source_files(files)
    end
    
    return true
end

-- 生成类文件内容
function M.generate_class_files(class_name, class_type, template_config, options, qt_version)
    local files = {}
    qt_version = qt_version or 6
    
    -- 模板变量
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
    
    -- 生成头文件
    if template_config.has_header then
        local header_content = templates.render_template(class_type .. '_header', template_vars)
        files.header = {
            name = template_vars.FILE_NAME .. '.h',
            content = header_content,
            type = 'header'
        }
    end
    
    -- 生成源文件
    if template_config.has_source then
        local source_content = templates.render_template(class_type .. '_source', template_vars)
        files.source = {
            name = template_vars.FILE_NAME .. '.cpp',
            content = source_content,
            type = 'source'
        }
    end
    
    -- 生成UI文件
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

-- 生成头文件保护宏
function M.generate_header_guard(class_name)
    local filename = file_manager.class_name_to_filename(class_name)
    return string.upper(filename) .. "_H"
end

-- 创建Qt UI文件
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

-- 获取支持的类类型列表
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

-- 获取类类型的描述信息
function M.get_class_type_info(class_type)
    local class_info = {
        main_window = {
            name = "Main Window",
            description = "继承自QMainWindow的主窗口类",
            base_class = "QMainWindow",
            files = {"header", "source", "ui"}
        },
        dialog = {
            name = "Dialog",
            description = "继承自QDialog的对话框类",
            base_class = "QDialog", 
            files = {"header", "source", "ui"}
        },
        widget = {
            name = "Widget",
            description = "继承自QWidget的自定义控件类",
            base_class = "QWidget",
            files = {"header", "source"}
        },
        model = {
            name = "Data Model",
            description = "继承自QAbstractItemModel的数据模型类",
            base_class = "QAbstractItemModel",
            files = {"header", "source"}
        },
        delegate = {
            name = "Item Delegate", 
            description = "继承自QStyledItemDelegate的代理类",
            base_class = "QStyledItemDelegate",
            files = {"header", "source"}
        },
        thread = {
            name = "Thread",
            description = "继承自QThread的线程类",
            base_class = "QThread",
            files = {"header", "source"}
        },
        utility = {
            name = "Utility Class",
            description = "普通工具类，包含静态方法",
            base_class = "QObject",
            files = {"header", "source"}
        },
        singleton = {
            name = "Singleton",
            description = "单例模式类",
            base_class = "QObject",
            files = {"header", "source"}
        }
    }
    
    return class_info[class_type]
end

-- 键盘映射功能已移至主模块 qt-assistant.lua
-- 不再需要独立的 keymaps 模块

return M