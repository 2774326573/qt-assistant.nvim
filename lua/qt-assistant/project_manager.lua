-- Qt Assistant Plugin - 项目管理模块
-- Project management module

local M = {}
local file_manager = require('qt-assistant.file_manager')

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 项目类型检测
local project_types = {
    cmake = {
        files = {"CMakeLists.txt"},
        priority = 1,
        name = "CMake Project"
    },
    qmake = {
        files = {"*.pro"},
        priority = 2,
        name = "qmake Project"
    },
    qbs = {
        files = {"*.qbs"},
        priority = 3,
        name = "Qbs Project"
    },
    meson = {
        files = {"meson.build"},
        priority = 4,
        name = "Meson Project"
    }
}

-- 项目模板
local project_templates = {
    widget_app = {
        name = "Qt Widgets Application",
        description = "Standard Qt Widgets desktop application",
        files = {
            "main.cpp",
            "mainwindow.h",
            "mainwindow.cpp", 
            "mainwindow.ui",
            "CMakeLists.txt"
        }
    },
    quick_app = {
        name = "Qt Quick Application",
        description = "Qt Quick/QML application",
        files = {
            "main.cpp",
            "main.qml",
            "qml.qrc",
            "CMakeLists.txt"
        }
    },
    console_app = {
        name = "Qt Console Application",
        description = "Command-line Qt application",
        files = {
            "main.cpp",
            "CMakeLists.txt"
        }
    },
    library = {
        name = "Qt Library",
        description = "Qt shared/static library",
        files = {
            "library.h",
            "library.cpp",
            "library_global.h",
            "CMakeLists.txt"
        }
    }
}

-- 检测项目类型
function M.detect_project_type(project_path)
    project_path = project_path or vim.fn.getcwd()
    
    local detected_types = {}
    
    for type_name, type_config in pairs(project_types) do
        for _, file_pattern in ipairs(type_config.files) do
            if file_pattern:match("%*") then
                -- 使用glob模式匹配
                local pattern = file_pattern:gsub("%*", ".*")
                local handle = vim.loop.fs_scandir(project_path)
                if handle then
                    while true do
                        local name, type = vim.loop.fs_scandir_next(handle)
                        if not name then break end
                        
                        if name:match(pattern) then
                            table.insert(detected_types, {
                                type = type_name,
                                priority = type_config.priority,
                                name = type_config.name,
                                file = name
                            })
                            break
                        end
                    end
                end
            else
                -- 精确文件匹配
                local file_path = project_path .. "/" .. file_pattern
                if file_manager.file_exists(file_path) then
                    table.insert(detected_types, {
                        type = type_name,
                        priority = type_config.priority,
                        name = type_config.name,
                        file = file_pattern
                    })
                end
            end
        end
    end
    
    -- 按优先级排序
    table.sort(detected_types, function(a, b)
        return a.priority < b.priority
    end)
    
    return detected_types
end

-- 打开项目
function M.open_project(project_path)
    project_path = project_path or vim.fn.getcwd()
    
    -- 检查路径是否存在
    local stat = vim.loop.fs_stat(project_path)
    if not stat or stat.type ~= "directory" then
        vim.notify("Project path does not exist: " .. project_path, vim.log.levels.ERROR)
        return false
    end
    
    -- 切换到项目目录
    vim.cmd("cd " .. vim.fn.fnameescape(project_path))
    
    -- 检测项目类型
    local detected_types = M.detect_project_type(project_path)
    
    if #detected_types == 0 then
        vim.notify("No Qt project detected in: " .. project_path, vim.log.levels.WARN)
        return false
    end
    
    local primary_type = detected_types[1]
    vim.notify(string.format("Opened %s: %s", primary_type.name, project_path), vim.log.levels.INFO)
    
    -- 更新配置
    local config_manager = require('qt-assistant.config')
    config_manager.set_value('project_root', project_path)
    
    -- 分析项目结构
    M.analyze_project_structure(project_path, primary_type.type)
    
    -- 显示项目信息
    M.show_project_info(project_path, detected_types)
    
    return true
end

-- 分析项目结构
function M.analyze_project_structure(project_path, project_type)
    local structure = {
        source_dirs = {},
        include_dirs = {},
        ui_dirs = {},
        resource_dirs = {},
        build_files = {}
    }
    
    -- 递归扫描目录
    local function scan_directory(dir, max_depth, current_depth)
        current_depth = current_depth or 0
        if current_depth >= (max_depth or 3) then
            return
        end
        
        local handle = vim.loop.fs_scandir(dir)
        if not handle then return end
        
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            
            local full_path = dir .. "/" .. name
            
            if type == "directory" and not name:match("^%.") then
                -- 识别常见目录类型
                if name:match("^src") or name:match("source") then
                    table.insert(structure.source_dirs, full_path)
                elseif name:match("include") or name:match("headers") then
                    table.insert(structure.include_dirs, full_path)
                elseif name:match("ui") or name:match("forms") then
                    table.insert(structure.ui_dirs, full_path)
                elseif name:match("resources") or name:match("assets") then
                    table.insert(structure.resource_dirs, full_path)
                end
                
                -- 递归扫描子目录
                scan_directory(full_path, max_depth, current_depth + 1)
                
            elseif type == "file" then
                -- 识别构建文件
                if name:match("CMakeLists%.txt") or name:match("%.pro$") or 
                   name:match("%.qbs$") or name:match("meson%.build") then
                    table.insert(structure.build_files, full_path)
                end
            end
        end
    end
    
    scan_directory(project_path, 3)
    
    -- 保存项目结构信息
    M.current_project = {
        path = project_path,
        type = project_type,
        structure = structure
    }
    
    return structure
end

-- 显示项目信息
function M.show_project_info(project_path, detected_types)
    local info_lines = {}
    
    table.insert(info_lines, "=== Qt Project Information ===")
    table.insert(info_lines, "Path: " .. project_path)
    table.insert(info_lines, "")
    
    table.insert(info_lines, "Detected Project Types:")
    for i, type_info in ipairs(detected_types) do
        local marker = i == 1 and "[PRIMARY] " or "[DETECTED] "
        table.insert(info_lines, string.format("  %s%s (%s)", marker, type_info.name, type_info.file))
    end
    
    if M.current_project and M.current_project.structure then
        local structure = M.current_project.structure
        
        table.insert(info_lines, "")
        table.insert(info_lines, "Project Structure:")
        
        if #structure.source_dirs > 0 then
            table.insert(info_lines, "  Source directories:")
            for _, dir in ipairs(structure.source_dirs) do
                table.insert(info_lines, "    " .. file_manager.get_relative_path(dir, project_path))
            end
        end
        
        if #structure.include_dirs > 0 then
            table.insert(info_lines, "  Include directories:")
            for _, dir in ipairs(structure.include_dirs) do
                table.insert(info_lines, "    " .. file_manager.get_relative_path(dir, project_path))
            end
        end
        
        if #structure.ui_dirs > 0 then
            table.insert(info_lines, "  UI directories:")
            for _, dir in ipairs(structure.ui_dirs) do
                table.insert(info_lines, "    " .. file_manager.get_relative_path(dir, project_path))
            end
        end
        
        if #structure.build_files > 0 then
            table.insert(info_lines, "  Build files:")
            for _, file in ipairs(structure.build_files) do
                table.insert(info_lines, "    " .. file_manager.get_relative_path(file, project_path))
            end
        end
    end
    
    -- 在浮动窗口中显示信息
    M.show_info_window(info_lines)
end

-- 创建新项目
function M.new_project(project_name, template_type)
    if not project_name or project_name == "" then
        vim.notify("Project name is required", vim.log.levels.ERROR)
        return false
    end
    
    local template = project_templates[template_type]
    if not template then
        vim.notify("Unknown template type: " .. template_type, vim.log.levels.ERROR)
        return false
    end
    
    -- 创建项目根目录
    local project_path = vim.fn.getcwd() .. "/" .. project_name
    local success, error_msg = file_manager.ensure_directory_exists(project_path)
    if not success then
        vim.notify("Failed to create project directory: " .. error_msg, vim.log.levels.ERROR)  
        return false
    end
    
    -- 创建项目目录结构
    vim.notify("Creating project directory structure...", vim.log.levels.INFO)
    M.create_project_directories(project_path, template_type)
    
    -- 生成项目文件
    local template_vars = {
        PROJECT_NAME = project_name,
        PROJECT_NAME_UPPER = string.upper(project_name),
        PROJECT_NAME_LOWER = string.lower(project_name),
        CLASS_NAME = M.project_name_to_class_name(project_name),
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y')
    }
    
    -- 创建项目文件到合适的目录中
    M.create_project_files(project_path, template_type, template_vars)
    
    vim.notify(string.format("Project '%s' created successfully using %s template", 
                           project_name, template.name), vim.log.levels.INFO)
    
    -- 询问是否打开项目
    vim.ui.select({'Yes', 'No'}, {
        prompt = 'Open the new project?'
    }, function(choice)
        if choice == 'Yes' then
            M.open_project(project_path)
        end
    end)
    
    return true
end

-- 创建项目目录结构
function M.create_project_directories(project_path, template_type)
    local directories = {}
    
    -- 根据项目类型创建不同的目录结构
    if template_type == "widget_app" or template_type == "quick_app" then
        directories = {
            "src",
            "include",
            "ui",
            "resources",
            "build",
            "docs",
            "tests"
        }
    elseif template_type == "console_app" then
        directories = {
            "src",
            "include", 
            "build",
            "docs",
            "tests"
        }
    elseif template_type == "library" then
        directories = {
            "src",
            "include",
            "build",
            "examples",
            "docs",
            "tests"
        }
    end
    
    -- 创建目录
    for _, dir in ipairs(directories) do
        local dir_path = project_path .. "/" .. dir
        local success, error_msg = file_manager.ensure_directory_exists(dir_path)
        if success then
            vim.notify("Created directory: " .. dir, vim.log.levels.INFO)
        else
            vim.notify("Failed to create directory " .. dir .. ": " .. error_msg, vim.log.levels.WARN)
        end
    end
    
    -- 创建QML特定目录（对于Quick应用）
    if template_type == "quick_app" then
        local qml_dirs = {"qml", "qml/components", "qml/pages"}
        for _, dir in ipairs(qml_dirs) do
            local dir_path = project_path .. "/" .. dir
            file_manager.ensure_directory_exists(dir_path)
            vim.notify("Created QML directory: " .. dir, vim.log.levels.INFO)
        end
    end
end

-- 创建项目文件
function M.create_project_files(project_path, template_type, template_vars)
    local template = project_templates[template_type]
    
    -- 定义文件到目录的映射
    local file_mappings = {
        ["main.cpp"] = "src",
        ["mainwindow.h"] = "include",
        ["mainwindow.cpp"] = "src",
        ["mainwindow.ui"] = "ui",
        ["library.h"] = "include",
        ["library_global.h"] = "include", 
        ["library.cpp"] = "src",
        ["main.qml"] = "qml",
        ["qml.qrc"] = "resources",
        ["CMakeLists.txt"] = "",  -- 根目录
    }
    
    for _, file_name in ipairs(template.files) do
        local file_content = M.generate_template_file(file_name, template_type, template_vars)
        if file_content then
            -- 确定文件应该放在哪个目录
            local target_dir = file_mappings[file_name] or ""
            local file_path = project_path
            if target_dir ~= "" then
                file_path = file_path .. "/" .. target_dir
            end
            file_path = file_path .. "/" .. file_name
            
            local write_success = file_manager.write_file(file_path, file_content)
            if write_success then
                local relative_path = target_dir ~= "" and (target_dir .. "/" .. file_name) or file_name
                vim.notify("Created: " .. relative_path, vim.log.levels.INFO)
            else
                vim.notify("Failed to create: " .. file_name, vim.log.levels.ERROR)
            end
        end
    end
    
    -- 创建额外的项目文件
    M.create_additional_project_files(project_path, template_type, template_vars)
end

-- 创建额外的项目文件
function M.create_additional_project_files(project_path, template_type, template_vars)
    -- 创建README.md
    local readme_content = string.format([[# %s

## 项目描述
%s项目，使用Qt框架开发。

## 构建方法
```bash
mkdir build
cd build
cmake ..
make
```

## 运行
```bash
./build/%s
```

## 项目结构
- `src/` - 源代码文件
- `include/` - 头文件
- `ui/` - UI文件 (仅GUI应用)
- `resources/` - 资源文件
- `build/` - 构建输出目录
- `docs/` - 文档文件
- `tests/` - 测试文件

## 依赖
- Qt 6.x
- CMake 3.16+

## 作者
Generated by Qt Assistant Plugin on %s
]], template_vars.PROJECT_NAME, project_templates[template_type].description, 
    template_vars.PROJECT_NAME_LOWER, template_vars.DATE)
    
    file_manager.write_file(project_path .. "/README.md", readme_content)
    vim.notify("Created: README.md", vim.log.levels.INFO)
    
    -- 创建.gitignore
    local gitignore_content = [[# Build directories
build/
build-*/

# Qt generated files
*.pro.user*
*.autosave
ui_*.h
moc_*.cpp
moc_*.h
qrc_*.cpp

# Object files
*.o
*.obj

# Shared objects
*.so
*.dll
*.dylib

# Executables
*.exe

# IDE files
.vscode/
.idea/
*.user

# OS generated files
.DS_Store
Thumbs.db

# CMake
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
]]
    
    file_manager.write_file(project_path .. "/.gitignore", gitignore_content)
    vim.notify("Created: .gitignore", vim.log.levels.INFO)
    
    -- 为Quick应用创建额外的QML文件
    if template_type == "quick_app" then
        M.create_qml_project_files(project_path, template_vars)
    end
end

-- 创建QML项目的额外文件
function M.create_qml_project_files(project_path, template_vars)
    -- 创建基础QML组件
    local button_component = [[import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: customButton
    
    property alias buttonText: buttonText.text
    property alias buttonColor: background.color
    
    background: Rectangle {
        id: background
        color: "#4CAF50"
        radius: 8
        border.color: customButton.hovered ? "#45a049" : "transparent"
        border.width: 2
    }
    
    contentItem: Text {
        id: buttonText
        text: "Custom Button"
        color: "white"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
]]
    
    file_manager.write_file(project_path .. "/qml/components/CustomButton.qml", button_component)
    vim.notify("Created: qml/components/CustomButton.qml", vim.log.levels.INFO)
    
    -- 创建主页面
    local main_page = string.format([[import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("%s")
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            id: welcomeText
            text: "Welcome to %s"
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }
        
        CustomButton {
            buttonText: "Click Me!"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                welcomeText.text = "Button Clicked!"
            }
        }
    }
}
]], template_vars.PROJECT_NAME, template_vars.PROJECT_NAME)
    
    file_manager.write_file(project_path .. "/qml/pages/MainPage.qml", main_page)
    vim.notify("Created: qml/pages/MainPage.qml", vim.log.levels.INFO)
end

-- 项目名转类名
function M.project_name_to_class_name(project_name)
    -- 转换为驼峰命名
    local class_name = project_name:gsub("[-_](%w)", function(c)
        return string.upper(c)
    end)
    
    -- 首字母大写
    return string.upper(class_name:sub(1, 1)) .. class_name:sub(2)
end

-- 生成模板文件
function M.generate_template_file(file_name, template_type, vars)
    local templates = require('qt-assistant.templates')
    
    -- 根据文件扩展名确定模板类型
    local template_name = nil
    
    if file_name == "main.cpp" then
        if template_type == "widget_app" then
            template_name = "main_widget_app"
        elseif template_type == "quick_app" then
            template_name = "main_quick_app"
        elseif template_type == "console_app" then
            template_name = "main_console_app"
        end
    elseif file_name == "CMakeLists.txt" then
        template_name = "cmake_" .. template_type
    elseif file_name:match("%.h$") then
        if file_name:match("mainwindow") then
            template_name = "main_window_header"
        elseif file_name:match("library") then
            template_name = "library_header"
        end
    elseif file_name:match("%.cpp$") then
        if file_name:match("mainwindow") then
            template_name = "main_window_source"
        elseif file_name:match("library") then
            template_name = "library_source"
        end
    elseif file_name:match("%.ui$") then
        template_name = "main_window_ui"
    elseif file_name:match("%.qml$") then
        template_name = "main_qml"
    elseif file_name:match("%.qrc$") then
        template_name = "qml_resources"
    end
    
    if template_name then
        return templates.render_template(template_name, vars)
    end
    
    return nil
end

-- 列出项目模板
function M.list_templates()
    local template_lines = {}
    
    table.insert(template_lines, "=== Available Qt Project Templates ===")
    table.insert(template_lines, "")
    
    for template_key, template_info in pairs(project_templates) do
        table.insert(template_lines, string.format("• %s (%s)", template_info.name, template_key))
        table.insert(template_lines, "  " .. template_info.description)
        table.insert(template_lines, "  Files: " .. table.concat(template_info.files, ", "))
        table.insert(template_lines, "")
    end
    
    table.insert(template_lines, "Usage: :QtNewProject <name> <template_type>")
    table.insert(template_lines, "Example: :QtNewProject MyApp widget_app")
    
    M.show_info_window(template_lines)
end

-- 显示信息窗口
function M.show_info_window(lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    local width = 80
    local height = math.min(#lines + 2, 25)
    
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded'
    }
    
    local win = vim.api.nvim_open_win(buf, true, win_config)
    
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
end

-- 获取当前项目信息
function M.get_current_project()
    return M.current_project
end

-- 检查是否为Qt项目
function M.is_qt_project(project_path)
    project_path = project_path or vim.fn.getcwd()
    local detected_types = M.detect_project_type(project_path)
    return #detected_types > 0
end

-- 获取系统所有可用的搜索路径（包括不同驱动器）
function M.get_global_search_paths()
    local config = require('qt-assistant').get_config()
    local global_config = config.global_search or {}
    
    local paths = {}
    
    -- 添加用户自定义路径
    if global_config.custom_search_paths then
        for _, custom_path in ipairs(global_config.custom_search_paths) do
            if vim.fn.isdirectory(custom_path) == 1 then
                table.insert(paths, custom_path)
            end
        end
    end
    
    -- 如果禁用系统路径，只返回自定义路径
    if not global_config.include_system_paths then
        return paths
    end
    
    -- 检测操作系统
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
    
    if is_windows then
        -- Windows: 检查所有驱动器盘符
        for drive_letter = string.byte('A'), string.byte('Z') do
            local drive = string.char(drive_letter) .. ":\\"
            if vim.fn.isdirectory(drive) == 1 then
                table.insert(paths, drive)
                -- 添加常见的开发目录
                local common_dirs = {
                    drive .. "Projects",
                    drive .. "Development", 
                    drive .. "Code",
                    drive .. "Qt",
                    drive .. "workspace",
                    drive .. "src",
                    drive .. "Users\\" .. vim.fn.expand('$USERNAME') .. "\\Documents",
                    drive .. "Users\\" .. vim.fn.expand('$USERNAME') .. "\\Desktop"
                }
                for _, dir in ipairs(common_dirs) do
                    if vim.fn.isdirectory(dir) == 1 then
                        table.insert(paths, dir)
                    end
                end
            end
        end
    else
        -- Linux/macOS: 检查常见的挂载点和目录
        local unix_paths = {
            "/",
            "/home",
            "/opt",
            "/usr/local",
            "/var",
            "/mnt",
            "/media",
            vim.fn.expand('~'),
            vim.fn.expand('~/Documents'),
            vim.fn.expand('~/Projects'),
            vim.fn.expand('~/Development'),
            vim.fn.expand('~/Code'),
            vim.fn.expand('~/Desktop'),
            vim.fn.expand('~/workspace'),
            vim.fn.expand('~/src')
        }
        
        for _, path in ipairs(unix_paths) do
            if vim.fn.isdirectory(path) == 1 then
                table.insert(paths, path)
            end
        end
        
        -- 检查挂载的其他设备
        local mounts = {"/mnt", "/media"}
        for _, mount_base in ipairs(mounts) do
            if vim.fn.isdirectory(mount_base) == 1 then
                local handle = vim.loop.fs_scandir(mount_base)
                if handle then
                    while true do
                        local name, type = vim.loop.fs_scandir_next(handle)
                        if not name then break end
                        
                        if type == "directory" then
                            local mount_path = mount_base .. "/" .. name
                            table.insert(paths, mount_path)
                        end
                    end
                end
            end
        end
    end
    
    -- 去重并排序
    local unique_paths = {}
    local seen = {}
    
    for _, path in ipairs(paths) do
        local normalized = vim.fn.fnamemodify(path, ':p')
        if not seen[normalized] then
            seen[normalized] = true
            table.insert(unique_paths, normalized)
        end
    end
    
    table.sort(unique_paths)
    return unique_paths
end

-- 智能搜索Qt项目
function M.search_qt_projects(search_paths, max_depth)
    search_paths = search_paths or {vim.fn.getcwd(), vim.fn.expand('~')}
    max_depth = max_depth or 3
    
    -- 获取配置中的排除模式
    local config = require('qt-assistant').get_config()
    local global_config = config.global_search or {}
    local exclude_patterns = global_config.exclude_patterns or {
        "node_modules", ".git", ".vscode", "build", "target", 
        "dist", "out", "__pycache__", ".cache", "tmp", "temp"
    }
    
    local found_projects = {}
    
    -- 检查是否应该排除目录
    local function should_exclude(name)
        if name:match("^%.") then
            return true
        end
        
        for _, pattern in ipairs(exclude_patterns) do
            if name == pattern or name:match(pattern) then
                return true
            end
        end
        
        return false
    end
    
    -- 搜索函数
    local function search_directory(dir, current_depth)
        if current_depth > max_depth then
            return
        end
        
        -- 检查当前目录是否是Qt项目
        local detected_types = M.detect_project_type(dir)
        if #detected_types > 0 then
            table.insert(found_projects, {
                path = dir,
                name = vim.fn.fnamemodify(dir, ':t'),
                types = detected_types,
                primary_type = detected_types[1]
            })
        end
        
        -- 递归搜索子目录
        local handle = vim.loop.fs_scandir(dir)
        if not handle then
            return
        end
        
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            
            if type == "directory" and not should_exclude(name) then
                local sub_path = dir .. "/" .. name
                search_directory(sub_path, current_depth + 1)
            end
        end
    end
    
    -- 在指定路径中搜索
    for _, search_path in ipairs(search_paths) do
        if vim.fn.isdirectory(search_path) == 1 then
            search_directory(search_path, 0)
        end
    end
    
    -- 按项目名称排序
    table.sort(found_projects, function(a, b)
        return a.name < b.name
    end)
    
    return found_projects
end

-- 全局搜索Qt项目（跨驱动器）
function M.global_search_qt_projects(progress_callback)
    progress_callback = progress_callback or function() end
    
    local found_projects = {}
    local search_paths = M.get_global_search_paths()
    
    progress_callback("🌍 Starting global search across all drives...")
    vim.notify("🔍 Global search started. This may take a while...", vim.log.levels.INFO)
    
    local total_paths = #search_paths
    local processed = 0
    
    -- 异步搜索函数
    local function search_path_async(path_index)
        if path_index > total_paths then
            progress_callback("✅ Global search completed!")
            -- 搜索完成后显示结果
            vim.defer_fn(function()
                M.show_global_search_results(found_projects)
            end, 100)
            return
        end
        
        local search_path = search_paths[path_index]
        processed = processed + 1
        
        progress_callback(string.format("🔍 Searching (%d/%d): %s", 
            processed, total_paths, vim.fn.fnamemodify(search_path, ':~')))
        
        -- 使用配置的深度设置
        local config = require('qt-assistant').get_config()
        local global_config = config.global_search or {}
        local max_depth = global_config.max_depth or 3
        
        -- 根目录使用更小的深度以提高性能
        if search_path:match("^[A-Z]:\\$") or search_path == "/" then
            max_depth = math.min(max_depth, 2)
        end
        
        local projects = M.search_qt_projects({search_path}, max_depth)
        
        -- 将找到的项目添加到结果中
        for _, project in ipairs(projects) do
            -- 检查是否已存在（去重）
            local exists = false
            for _, existing in ipairs(found_projects) do
                if existing.path == project.path then
                    exists = true
                    break
                end
            end
            
            if not exists then
                -- 添加搜索来源信息
                project.search_source = search_path
                project.global_search = true
                table.insert(found_projects, project)
            end
        end
        
        -- 继续搜索下一个路径
        vim.defer_fn(function()
            search_path_async(path_index + 1)
        end, 10)  -- 很短的延迟，保持响应性
    end
    
    -- 开始异步搜索
    search_path_async(1)
end

-- 显示全局搜索结果
function M.show_global_search_results(projects)
    if #projects == 0 then
        vim.notify("🔍 No Qt projects found in global search", vim.log.levels.WARN)
        return
    end
    
    -- 按驱动器/路径分组
    local groups = {}
    for _, project in ipairs(projects) do
        local source = project.search_source or "Unknown"
        local group_key = source
        
        if not groups[group_key] then
            groups[group_key] = {
                title = group_key,
                projects = {}
            }
        end
        
        table.insert(groups[group_key].projects, project)
    end
    
    -- 创建显示项目
    local items = {}
    local project_map = {}
    
    table.insert(items, "")
    table.insert(items, string.format("🌍 Global Qt Project Search Results (%d projects found)", #projects))
    table.insert(items, string.rep("═", 70))
    table.insert(items, "")
    
    -- 按组显示项目
    local sorted_groups = {}
    for _, group in pairs(groups) do
        table.insert(sorted_groups, group)
    end
    table.sort(sorted_groups, function(a, b) return a.title < b.title end)
    
    for _, group in ipairs(sorted_groups) do
        table.insert(items, "📁 " .. vim.fn.fnamemodify(group.title, ':~'))
        table.insert(items, string.rep("─", 50))
        
        -- 排序组内项目
        table.sort(group.projects, function(a, b) return a.name < b.name end)
        
        for _, project in ipairs(group.projects) do
            local display = string.format("   • %s (%s) - %s", 
                project.name, 
                project.primary_type.name,
                vim.fn.fnamemodify(project.path, ':~'))
            
            table.insert(items, display)
            project_map[#items] = project
        end
        
        table.insert(items, "")
    end
    
    table.insert(items, string.rep("─", 70))
    table.insert(items, "Press Enter to open project, 'q' to quit")
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)
    
    local width = math.min(80, vim.o.columns - 4)
    local height = math.min(#items + 2, vim.o.lines - 4)
    
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded',
        title = ' Global Search Results ',
        title_pos = 'center'
    }
    
    local win = vim.api.nvim_open_win(buf, true, win_config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    -- 设置高亮
    vim.api.nvim_buf_add_highlight(buf, -1, 'Title', 1, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', 2, 0, -1)
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
    -- 设置键盘映射
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        callback = function()
            local line_num = vim.api.nvim_win_get_cursor(win)[1]
            local project = project_map[line_num]
            if project then
                close_window()
                vim.notify(string.format("Opening global project: %s", project.name), vim.log.levels.INFO)
                M.open_project(project.path)
            end
        end,
        noremap = true,
        silent = true
    })
    
    -- 自动定位到第一个项目
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
            for line = 1, #items do
                if project_map[line] then
                    vim.api.nvim_win_set_cursor(win, {line, 0})
                    break
                end
            end
        end
    end, 50)
end

-- 显示项目搜索结果
function M.show_project_search_results(projects)
    if #projects == 0 then
        vim.notify("No Qt projects found in search paths", vim.log.levels.WARN)
        return
    end
    
    -- 如果只找到一个项目，直接打开
    if #projects == 1 then
        local project = projects[1]
        vim.notify(string.format("Found and opening: %s (%s)", 
            project.name, project.primary_type.name), vim.log.levels.INFO)
        M.open_project(project.path)
        return
    end
    
    -- 多个项目时显示选择界面
    local items = {}
    for i, project in ipairs(projects) do
        table.insert(items, string.format("%s (%s) - %s", 
            project.name, project.primary_type.name, project.path))
    end
    
    vim.ui.select(items, {
        prompt = string.format('Found %d Qt projects, select one to open:', #projects),
        format_item = function(item)
            return item
        end
    }, function(choice, idx)
        if choice and idx then
            M.open_project(projects[idx].path)
        end
    end)
end

-- 搜索并选择Qt项目
function M.search_and_select_project(options)
    options = options or {}
    local max_depth = options.max_depth or 2
    local include_current = options.include_current ~= false
    
    vim.notify("Searching for Qt projects...", vim.log.levels.INFO)
    
    -- 异步搜索以避免阻塞UI
    vim.defer_fn(function()
        local search_paths = {}
        
        -- 如果当前目录就是Qt项目，优先检查
        if include_current then
            local current_dir = vim.fn.getcwd()
            if M.is_qt_project(current_dir) then
                vim.notify(string.format("Current directory is a Qt project: %s", 
                    vim.fn.fnamemodify(current_dir, ':t')), vim.log.levels.INFO)
                M.open_project(current_dir)
                return
            end
            table.insert(search_paths, current_dir)
        end
        
        -- 添加其他搜索路径
        local additional_paths = {
            vim.fn.expand('~'),
            vim.fn.expand('~/Projects'),
            vim.fn.expand('~/Development'),
            vim.fn.expand('~/code'),
            vim.fn.expand('~/workspace'),
            vim.fn.expand('~/Documents'),
            '/home/' .. vim.fn.expand('$USER') .. '/QtProjects'
        }
        
        for _, path in ipairs(additional_paths) do
            if vim.fn.isdirectory(path) == 1 then
                table.insert(search_paths, path)
            end
        end
        
        local projects = M.search_qt_projects(search_paths, max_depth)
        
        -- 过滤掉当前目录（如果已经检查过）
        if include_current then
            local current_dir = vim.fn.getcwd()
            projects = vim.tbl_filter(function(project)
                return project.path ~= current_dir
            end, projects)
        end
        
        M.show_project_search_results(projects)
    end, 100)
end

-- 启动全局搜索（带进度显示）
function M.start_global_search()
    -- 检查全局搜索是否启用
    local config = require('qt-assistant').get_config()
    local global_config = config.global_search or {}
    
    if not global_config.enabled then
        vim.notify("Global search is disabled. Enable it in your configuration.", vim.log.levels.WARN)
        return
    end
    
    -- 创建进度显示窗口
    local progress_buf = vim.api.nvim_create_buf(false, true)
    local progress_items = {
        "",
        "🌍 Global Qt Project Search",
        string.rep("═", 40),
        "",
        "🔍 Initializing global search...",
        "",
        "This will search all available drives and directories.",
        "Press 'q' to cancel search.",
        ""
    }
    
    vim.api.nvim_buf_set_lines(progress_buf, 0, -1, false, progress_items)
    
    local progress_win_config = {
        relative = 'editor',
        width = 50,
        height = 12,
        col = math.floor((vim.o.columns - 50) / 2),
        row = math.floor((vim.o.lines - 12) / 2),
        style = 'minimal',
        border = 'rounded',
        title = ' Searching... ',
        title_pos = 'center'
    }
    
    local progress_win = vim.api.nvim_open_win(progress_buf, true, progress_win_config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(progress_win, 'number', false)
    vim.api.nvim_win_set_option(progress_win, 'relativenumber', false)
    vim.api.nvim_buf_set_option(progress_buf, 'modifiable', false)
    
    -- 设置高亮
    vim.api.nvim_buf_add_highlight(progress_buf, -1, 'Title', 1, 0, -1)
    vim.api.nvim_buf_add_highlight(progress_buf, -1, 'Comment', 2, 0, -1)
    
    local search_cancelled = false
    
    local function close_progress_window()
        if vim.api.nvim_win_is_valid(progress_win) then
            vim.api.nvim_win_close(progress_win, true)
        end
    end
    
    local function update_progress(message)
        if search_cancelled or not vim.api.nvim_win_is_valid(progress_win) then
            return
        end
        
        local new_items = {}
        for i = 1, 4 do
            table.insert(new_items, progress_items[i])
        end
        table.insert(new_items, message)
        for i = 6, #progress_items do
            table.insert(new_items, progress_items[i])
        end
        
        vim.api.nvim_buf_set_option(progress_buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(progress_buf, 0, -1, false, new_items)
        vim.api.nvim_buf_set_option(progress_buf, 'modifiable', false)
        
        -- 强制刷新显示
        vim.cmd('redraw')
    end
    
    -- 取消搜索的键盘映射
    vim.api.nvim_buf_set_keymap(progress_buf, 'n', 'q', '', {
        callback = function()
            search_cancelled = true
            close_progress_window()
            vim.notify("Global search cancelled", vim.log.levels.INFO)
        end,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(progress_buf, 'n', '<Esc>', '', {
        callback = function()
            search_cancelled = true
            close_progress_window()
            vim.notify("Global search cancelled", vim.log.levels.INFO)
        end,
        noremap = true,
        silent = true
    })
    
    -- 重写progress_callback以关闭进度窗口
    local original_progress_callback = function(message)
        if search_cancelled then
            return
        end
        
        if message:match("completed") then
            close_progress_window()
        else
            update_progress(message)
        end
    end
    
    -- 延迟启动搜索，让进度窗口先显示
    vim.defer_fn(function()
        if not search_cancelled then
            M.global_search_qt_projects(original_progress_callback)
        end
    end, 100)
end

-- 快速搜索（只搜索当前目录和父目录）
function M.quick_search_project()
    local current_dir = vim.fn.getcwd()
    
    -- 检查当前目录
    if M.is_qt_project(current_dir) then
        vim.notify("Opening current Qt project", vim.log.levels.INFO)
        M.open_project(current_dir)
        return
    end
    
    -- 检查父目录
    local parent_dir = vim.fn.fnamemodify(current_dir, ':h')
    if parent_dir ~= current_dir and M.is_qt_project(parent_dir) then
        vim.notify("Opening parent Qt project", vim.log.levels.INFO)
        M.open_project(parent_dir)
        return
    end
    
    -- 如果当前和父目录都不是Qt项目，进行完整搜索
    vim.notify("No Qt project in current/parent directory, searching...", vim.log.levels.INFO)
    M.search_and_select_project({max_depth = 1, include_current = false})
end

-- 最近项目管理
local recent_projects_file = vim.fn.stdpath('data') .. '/qt-assistant-recent-projects.json'

-- 保存最近项目
function M.save_recent_project(project_path, project_info)
    local recent_projects = M.load_recent_projects()
    
    -- 移除已存在的项目（避免重复）
    recent_projects = vim.tbl_filter(function(proj)
        return proj.path ~= project_path
    end, recent_projects)
    
    -- 添加到列表开头
    table.insert(recent_projects, 1, {
        path = project_path,
        name = vim.fn.fnamemodify(project_path, ':t'),
        type = project_info and project_info.type or 'unknown',
        last_opened = os.time()
    })
    
    -- 只保留最近10个项目
    if #recent_projects > 10 then
        recent_projects = vim.list_slice(recent_projects, 1, 10)
    end
    
    -- 保存到文件
    local file = io.open(recent_projects_file, 'w')
    if file then
        file:write(vim.json.encode(recent_projects))
        file:close()
    end
end

-- 加载最近项目
function M.load_recent_projects()
    local file = io.open(recent_projects_file, 'r')
    if not file then
        return {}
    end
    
    local content = file:read('*all')
    file:close()
    
    local ok, recent_projects = pcall(vim.json.decode, content)
    if not ok or type(recent_projects) ~= 'table' then
        return {}
    end
    
    -- 过滤掉不存在的项目
    return vim.tbl_filter(function(proj)
        return vim.fn.isdirectory(proj.path) == 1
    end, recent_projects)
end

-- 显示最近项目
function M.show_recent_projects()
    local recent_projects = M.load_recent_projects()
    
    if #recent_projects == 0 then
        vim.notify("No recent Qt projects found", vim.log.levels.INFO)
        return
    end
    
    -- 如果只有一个最近项目，直接打开
    if #recent_projects == 1 then
        local project = recent_projects[1]
        vim.notify(string.format("Opening recent project: %s", project.name), vim.log.levels.INFO)
        M.open_project(project.path)
        return
    end
    
    -- 多个项目时显示选择界面
    local items = {}
    for i, project in ipairs(recent_projects) do
        local time_str = os.date('%Y-%m-%d %H:%M', project.last_opened)
        table.insert(items, string.format("%s (%s) - %s [%s]", 
            project.name, project.type, project.path, time_str))
    end
    
    vim.ui.select(items, {
        prompt = 'Select recent Qt project:',
        format_item = function(item)
            return item
        end
    }, function(choice, idx)
        if choice and idx then
            M.open_project(recent_projects[idx].path)
        end
    end)
end

-- 重写open_project函数以保存最近项目
local original_open_project = M.open_project
function M.open_project(project_path)
    local success = original_open_project(project_path)
    
    if success and M.current_project then
        -- 保存到最近项目列表
        M.save_recent_project(project_path, {
            type = M.current_project.type
        })
    end
    
    return success
end

-- 🚀 优化版智能项目选择器
function M.show_smart_project_selector()
    local current_dir = vim.fn.getcwd()
    
    -- 显示搜索进度动画
    local progress_handle = M._show_search_progress()
    
    -- 1. 立即检查当前目录（最快）
    if M.is_qt_project(current_dir) then
        M._hide_search_progress(progress_handle)
        vim.notify(string.format("✅ Opening current Qt project: %s", vim.fn.fnamemodify(current_dir, ':t')), vim.log.levels.INFO)
        M.open_project(current_dir)
        return
    end
    
    -- 2. 异步执行智能搜索策略
    vim.defer_fn(function()
        M._execute_smart_search_strategy(current_dir, progress_handle)
    end, 50)
end

-- 执行智能搜索策略
function M._execute_smart_search_strategy(current_dir, progress_handle)
    -- 阶段1: 检查最近项目（缓存，很快）
    local recent_projects = M.load_recent_projects()
    local valid_recent = {}
    
    for _, project in ipairs(recent_projects) do
        if vim.fn.isdirectory(project.path) == 1 and project.path ~= current_dir then
            table.insert(valid_recent, project)
        end
    end
    
    if #valid_recent > 0 then
        M._hide_search_progress(progress_handle)
        local latest = valid_recent[1]
        local time_ago = M._format_time_ago(latest.last_opened)
        vim.notify(string.format("🕒 Opening recent project: %s (%s ago)", latest.name, time_ago), vim.log.levels.INFO)
        M.open_project(latest.path)
        return
    end
    
    -- 阶段2: 智能近邻搜索（中等速度）
    vim.defer_fn(function()
        M._smart_proximity_search(current_dir, progress_handle)
    end, 100)
end

-- 智能近邻搜索
function M._smart_proximity_search(current_dir, progress_handle)
    local proximity_paths = M._get_proximity_search_paths(current_dir)
    local found_projects = {}
    
    for _, path_info in ipairs(proximity_paths) do
        if vim.fn.isdirectory(path_info.path) == 1 then
            local projects = M.search_qt_projects({path_info.path}, path_info.depth)
            for _, project in ipairs(projects) do
                if project.path ~= current_dir then
                    project._proximity_score = path_info.priority
                    table.insert(found_projects, project)
                end
            end
            
            -- 如果在高优先级路径找到项目，立即返回
            if #found_projects > 0 and path_info.priority >= 90 then
                break
            end
        end
    end
    
    if #found_projects > 0 then
        M._hide_search_progress(progress_handle)
        -- 按优先级排序
        table.sort(found_projects, function(a, b)
            return (a._proximity_score or 0) > (b._proximity_score or 0)
        end)
        
        local best_project = found_projects[1]
        vim.notify(string.format("📁 Found nearby project: %s (%s)", 
            best_project.name, best_project.primary_type.name), vim.log.levels.INFO)
        M.open_project(best_project.path)
        return
    end
    
    -- 阶段3: 深度搜索（较慢，异步执行）
    vim.defer_fn(function()
        M._deep_search_with_intelligence(current_dir, progress_handle)
    end, 200)
end

-- 获取近邻搜索路径（按优先级排序）
function M._get_proximity_search_paths(current_dir)
    local paths = {}
    
    -- 父目录（最高优先级）
    local parent_dir = vim.fn.fnamemodify(current_dir, ':h')
    if parent_dir ~= current_dir then
        table.insert(paths, {path = parent_dir, depth = 1, priority = 100})
    end
    
    -- 当前目录的子目录
    table.insert(paths, {path = current_dir, depth = 2, priority = 95})
    
    -- 兄弟目录
    local grandparent = vim.fn.fnamemodify(current_dir, ':h:h')
    if grandparent ~= parent_dir then
        table.insert(paths, {path = grandparent, depth = 2, priority = 90})
    end
    
    -- 用户桌面和下载（常用位置）
    table.insert(paths, {path = vim.fn.expand('~/Desktop'), depth = 1, priority = 80})
    table.insert(paths, {path = vim.fn.expand('~/Downloads'), depth = 1, priority = 75})
    
    -- 开发相关目录
    local dev_dirs = {
        {vim.fn.expand('~/Projects'), 85},
        {vim.fn.expand('~/Development'), 85}, 
        {vim.fn.expand('~/code'), 80},
        {vim.fn.expand('~/src'), 80},
        {vim.fn.expand('~/workspace'), 75},
    }
    
    for _, dir_info in ipairs(dev_dirs) do
        table.insert(paths, {path = dir_info[1], depth = 2, priority = dir_info[2]})
    end
    
    return paths
end

-- 深度智能搜索
function M._deep_search_with_intelligence(current_dir, progress_handle)
    local extended_paths = {
        vim.fn.expand('~'),
        vim.fn.expand('~/Documents'),
        vim.fn.expand('~/work'),
        '/opt',
        '/usr/local/src'
    }
    
    local all_projects = {}
    
    for _, path in ipairs(extended_paths) do
        if vim.fn.isdirectory(path) == 1 then
            local projects = M.search_qt_projects({path}, 3)
            for _, project in ipairs(projects) do
                if project.path ~= current_dir then
                    -- 计算智能评分
                    project._intelligence_score = M._calculate_project_intelligence(project, current_dir)
                    table.insert(all_projects, project)
                end
            end
        end
    end
    
    M._hide_search_progress(progress_handle)
    
    if #all_projects > 0 then
        -- 按智能评分排序
        table.sort(all_projects, function(a, b)
            return a._intelligence_score > b._intelligence_score
        end)
        
        local best_project = all_projects[1]
        vim.notify(string.format("🔍 Discovered Qt project: %s (score: %.1f)", 
            best_project.name, best_project._intelligence_score), vim.log.levels.INFO)
        M.open_project(best_project.path)
    else
        M._show_no_projects_dialog(current_dir)
    end
end

-- 计算项目智能评分
function M._calculate_project_intelligence(project, current_dir)
    local score = 0
    
    -- 基础项目类型评分
    local type_scores = {
        ["CMake Project"] = 10,
        ["qmake Project"] = 8,
        ["Qbs Project"] = 6,
        ["Meson Project"] = 7
    }
    score = score + (type_scores[project.primary_type.name] or 5)
    
    -- 路径相似度评分
    score = score + M._calculate_path_similarity(project.path, current_dir) * 15
    
    -- 项目名称相关性评分
    score = score + M._calculate_name_relevance(project.name, current_dir) * 20
    
    -- 最近活跃度评分
    score = score + M._calculate_activity_score(project.path) * 10
    
    -- 项目大小评分（更大的项目可能更重要）
    score = score + M._calculate_size_score(project.path) * 5
    
    return score
end

-- 路径相似度计算
function M._calculate_path_similarity(path1, path2)
    local parts1 = vim.split(path1, '/')
    local parts2 = vim.split(path2, '/')
    local common = 0
    local total = math.max(#parts1, #parts2)
    
    for i = 1, math.min(#parts1, #parts2) do
        if parts1[i] == parts2[i] then
            common = common + 1
        end
    end
    
    return total > 0 and common / total or 0
end

-- 名称相关性计算
function M._calculate_name_relevance(project_name, current_dir)
    local current_name = vim.fn.fnamemodify(current_dir, ':t'):lower()
    local proj_name_lower = project_name:lower()
    
    -- 完全匹配
    if proj_name_lower == current_name then return 1.0 end
    
    -- 包含关系
    if proj_name_lower:find(current_name) or current_name:find(proj_name_lower) then
        return 0.7
    end
    
    -- 相似词汇
    local similar_words = {'app', 'project', 'demo', 'test', 'example'}
    for _, word in ipairs(similar_words) do
        if proj_name_lower:find(word) and current_name:find(word) then
            return 0.4
        end
    end
    
    return 0
end

-- 活跃度评分
function M._calculate_activity_score(project_path)
    local stat = vim.loop.fs_stat(project_path)
    if not stat then return 0 end
    
    local days_ago = (os.time() - stat.mtime.sec) / (24 * 3600)
    
    if days_ago < 1 then return 1.0
    elseif days_ago < 7 then return 0.8
    elseif days_ago < 30 then return 0.5
    elseif days_ago < 90 then return 0.3
    else return 0.1 end
end

-- 项目大小评分
function M._calculate_size_score(project_path)
    local handle = vim.loop.fs_scandir(project_path)
    if not handle then return 0 end
    
    local file_count = 0
    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        if type == "file" and name:match("%.(cpp|h|ui|pro|cmake)$") then
            file_count = file_count + 1
        end
        if file_count > 50 then break end -- 避免过度计算
    end
    
    return math.min(file_count / 50, 1.0)
end

-- 显示搜索进度
function M._show_search_progress()
    local handle = {
        timer = vim.loop.new_timer(),
        dots = 0
    }
    
    handle.timer:start(0, 400, vim.schedule_wrap(function()
        handle.dots = (handle.dots + 1) % 4
        local animation = string.rep('.', handle.dots) .. string.rep(' ', 3 - handle.dots)
        vim.notify(string.format("🔍 Searching for Qt projects%s", animation), vim.log.levels.INFO, {
            replace = true
        })
    end))
    
    return handle
end

-- 隐藏搜索进度
function M._hide_search_progress(handle)
    if handle and handle.timer and not handle.timer:is_closing() then
        handle.timer:stop()
        handle.timer:close()
    end
end

-- 格式化时间差
function M._format_time_ago(timestamp)
    local diff = os.time() - timestamp
    if diff < 60 then return "just now"
    elseif diff < 3600 then return string.format("%dm", math.floor(diff / 60))
    elseif diff < 86400 then return string.format("%dh", math.floor(diff / 3600))
    elseif diff < 604800 then return string.format("%dd", math.floor(diff / 86400))
    else return string.format("%dw", math.floor(diff / 604800)) end
end

-- 无项目找到对话框
function M._show_no_projects_dialog(current_dir)
    local options = {
        "📁 Browse for project directory",
        "➕ Create new Qt project here", 
        "🔍 Search in specific directory",
        "📋 Show all recent projects",
        "❌ Cancel"
    }
    
    vim.ui.select(options, {
        prompt = '❌ No Qt projects found. What would you like to do?',
        format_item = function(item) return item end
    }, function(choice, idx)
        if not choice then return end
        
        if idx == 1 then
            vim.ui.input({
                prompt = 'Project path: ',
                default = current_dir,
                completion = 'dir'
            }, function(path)
                if path and path ~= "" then 
                    M.open_project(path) 
                end
            end)
        elseif idx == 2 then
            M._quick_project_creator(current_dir)
        elseif idx == 3 then
            vim.ui.input({
                prompt = 'Search in directory: ',
                default = vim.fn.expand('~'),
                completion = 'dir'
            }, function(path)
                if path and path ~= "" then
                    local projects = M.search_qt_projects({path}, 4)
                    if #projects > 0 then
                        M.show_project_search_results(projects)
                    else
                        vim.notify("No Qt projects found in: " .. path, vim.log.levels.WARN)
                    end
                end
            end)
        elseif idx == 4 then
            M.show_smart_project_selector_with_choice()
        end
    end)
end

-- 快速項目創建器
function M._quick_project_creator(current_dir)
    local templates = {"widget_app", "quick_app", "console_app", "library"}
    local template_names = {
        "Qt Widgets Application", 
        "Qt Quick Application",
        "Qt Console Application",
        "Qt Library"
    }
    
    vim.ui.select(template_names, {
        prompt = 'Select project template:'
    }, function(choice, idx)
        if not choice then return end
        
        local default_name = vim.fn.fnamemodify(current_dir, ':t')
        vim.ui.input({
            prompt = 'Project name: ',
            default = default_name
        }, function(name)
            if name and name ~= "" then
                M.new_project(name, templates[idx])
            end
        end)
    end)
end

-- 智能项目选择器（带选择界面）- 当用户需要手动选择时使用
function M.show_smart_project_selector_with_choice()
    local all_projects = {}
    local sections = {}
    
    -- 1. 检查当前目录是否是Qt项目
    local current_dir = vim.fn.getcwd()
    if M.is_qt_project(current_dir) then
        table.insert(sections, {
            title = "📂 Current Directory",
            projects = {{
                path = current_dir,
                name = vim.fn.fnamemodify(current_dir, ':t'),
                display = string.format("📂 %s (Current Directory)", vim.fn.fnamemodify(current_dir, ':t')),
                priority = 1
            }}
        })
    end
    
    -- 2. 加载最近项目
    local recent_projects = M.load_recent_projects()
    if #recent_projects > 0 then
        local recent_items = {}
        for i, project in ipairs(recent_projects) do
            if project.path ~= current_dir then -- 避免重复显示当前目录
                local time_str = os.date('%m-%d %H:%M', project.last_opened)
                table.insert(recent_items, {
                    path = project.path,
                    name = project.name,
                    display = string.format("🕒 %s (%s) [%s]", project.name, project.type, time_str),
                    priority = 2
                })
            end
        end
        if #recent_items > 0 then
            table.insert(sections, {
                title = "🕒 Recent Projects",
                projects = recent_items
            })
        end
    end
    
    -- 3. 搜索附近的Qt项目
    vim.notify("Searching for Qt projects...", vim.log.levels.INFO)
    
    -- 异步搜索
    vim.defer_fn(function()
        local search_paths = {
            vim.fn.expand('~'),
            vim.fn.expand('~/Projects'),
            vim.fn.expand('~/Development'), 
            vim.fn.expand('~/code'),
            vim.fn.expand('~/workspace'),
            vim.fn.expand('~/Documents')
        }
        
        local found_projects = M.search_qt_projects(search_paths, 2)
        
        -- 过滤掉已显示的项目
        local existing_paths = {}
        for _, section in ipairs(sections) do
            for _, proj in ipairs(section.projects) do
                existing_paths[proj.path] = true
            end
        end
        
        local new_projects = {}
        for _, project in ipairs(found_projects) do
            if not existing_paths[project.path] then
                table.insert(new_projects, {
                    path = project.path,
                    name = project.name,
                    display = string.format("🔍 %s (%s)", project.name, project.primary_type.name),
                    priority = 3
                })
            end
        end
        
        if #new_projects > 0 then
            table.insert(sections, {
                title = "🔍 Found Projects",
                projects = new_projects
            })
        end
        
        -- 4. 添加手动选择选项
        table.insert(sections, {
            title = "📁 Manual Selection",
            projects = {{
                path = "MANUAL_SELECT",
                name = "Browse...",
                display = "📁 Browse for project directory...",
                priority = 4
            }}
        })
        
        -- 显示统一选择界面
        M.display_unified_project_selector(sections)
    end, 100)
end

-- 快速项目切换界面
function M.show_quick_project_switcher()
    local recent_projects = M.load_recent_projects()
    
    if #recent_projects == 0 then
        vim.notify("No recent projects found. Use smart selector to open projects first.", vim.log.levels.WARN)
        M.show_smart_project_selector()
        return
    end
    
    -- 准备快速切换列表
    local items = {}
    local project_map = {}
    
    -- 当前项目信息
    local current_dir = vim.fn.getcwd()
    local current_project_idx = nil
    
    -- 查找当前项目
    for i, project in ipairs(recent_projects) do
        if vim.fn.fnamemodify(project.path, ':p') == vim.fn.fnamemodify(current_dir, ':p') then
            current_project_idx = i
            break
        end
    end
    
    -- 添加标题
    table.insert(items, "")
    if current_project_idx then
        table.insert(items, "🔄 Quick Project Switcher (Current: " .. recent_projects[current_project_idx].name .. ")")
    else
        table.insert(items, "🔄 Quick Project Switcher")
    end
    table.insert(items, string.rep("═", 60))
    table.insert(items, "")
    
    -- 添加最近项目
    for i, project in ipairs(recent_projects) do
        local is_current = (i == current_project_idx)
        local time_str = os.date('%m-%d %H:%M', project.last_opened)
        local prefix = is_current and "👉" or "  "
        local status = is_current and " (Current)" or ""
        
        local display = string.format("%s %d. %s (%s)%s - %s [%s]", 
            prefix, i, project.name, project.type, status, 
            vim.fn.fnamemodify(project.path, ':~'), time_str)
        
        table.insert(items, display)
        project_map[#items] = project
    end
    
    table.insert(items, "")
    table.insert(items, string.rep("─", 60))
    table.insert(items, "  s. Smart Selector (Find new projects)")
    table.insert(items, "  Enter number (1-" .. #recent_projects .. ") to switch, 's' for smart selector, 'q' to quit")
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)
    
    local width = math.min(80, vim.o.columns - 4)
    local height = math.min(#items + 2, vim.o.lines - 4)
    
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded',
        title = ' Quick Switcher ',
        title_pos = 'center'
    }
    
    local win = vim.api.nvim_open_win(buf, true, win_config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    -- 设置高亮
    vim.api.nvim_buf_add_highlight(buf, -1, 'Title', 1, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', 2, 0, -1)
    
    -- 高亮当前项目
    if current_project_idx then
        local current_line = 4 + current_project_idx - 1
        vim.api.nvim_buf_add_highlight(buf, -1, 'DiffAdd', current_line, 0, -1)
    end
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
    -- 设置键盘映射
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    -- 智能选择器
    vim.api.nvim_buf_set_keymap(buf, 'n', 's', '', {
        callback = function()
            close_window()
            M.show_smart_project_selector()
        end,
        noremap = true,
        silent = true
    })
    
    -- 数字快捷键切换项目
    for i = 1, math.min(#recent_projects, 9) do
        vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
            callback = function()
                close_window()
                local project = recent_projects[i]
                if project.path ~= current_dir then
                    vim.notify(string.format("Switching to: %s", project.name), vim.log.levels.INFO)
                    M.open_project(project.path)
                else
                    vim.notify("Already in this project", vim.log.levels.INFO)
                end
            end,
            noremap = true,
            silent = true
        })
    end
    
    -- Enter键选择当前行
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        callback = function()
            local line_num = vim.api.nvim_win_get_cursor(win)[1]
            local project = project_map[line_num]
            if project then
                close_window()
                if project.path ~= current_dir then
                    vim.notify(string.format("Switching to: %s", project.name), vim.log.levels.INFO)
                    M.open_project(project.path)
                else
                    vim.notify("Already in this project", vim.log.levels.INFO)
                end
            end
        end,
        noremap = true,
        silent = true
    })
    
    -- 快速键盘导航 - j/k上下移动, Tab在项目间快速跳转
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Tab>', '', {
        callback = function()
            local current_line = vim.api.nvim_win_get_cursor(win)[1]
            local next_project_line = nil
            
            -- 找到下一个项目行
            for line = current_line + 1, #items do
                if project_map[line] then
                    next_project_line = line
                    break
                end
            end
            
            -- 如果没找到，从头开始找
            if not next_project_line then
                for line = 1, current_line - 1 do
                    if project_map[line] then
                        next_project_line = line
                        break
                    end
                end
            end
            
            if next_project_line then
                vim.api.nvim_win_set_cursor(win, {next_project_line, 0})
            end
        end,
        noremap = true,
        silent = true
    })
    
    -- Shift+Tab 向上跳转项目
    vim.api.nvim_buf_set_keymap(buf, 'n', '<S-Tab>', '', {
        callback = function()
            local current_line = vim.api.nvim_win_get_cursor(win)[1]
            local prev_project_line = nil
            
            -- 从当前行向上找
            for line = current_line - 1, 1, -1 do
                if project_map[line] then
                    prev_project_line = line
                    break
                end
            end
            
            -- 如果没找到，从尾部开始找
            if not prev_project_line then
                for line = #items, current_line + 1, -1 do
                    if project_map[line] then
                        prev_project_line = line
                        break
                    end
                end
            end
            
            if prev_project_line then
                vim.api.nvim_win_set_cursor(win, {prev_project_line, 0})
            end
        end,
        noremap = true,
        silent = true
    })
    
    -- 自动定位到第一个项目
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
            for line = 1, #items do
                if project_map[line] then
                    vim.api.nvim_win_set_cursor(win, {line, 0})
                    break
                end
            end
        end
    end, 50)
end

-- 显示统一的项目选择界面
function M.display_unified_project_selector(sections)
    local items = {}
    local project_map = {}
    
    -- 构建选择列表
    for _, section in ipairs(sections) do
        if #section.projects > 0 then
            table.insert(items, "")
            table.insert(items, section.title .. ":")
            table.insert(items, string.rep("─", 50))
            
            for _, project in ipairs(section.projects) do
                table.insert(items, project.display)
                project_map[#items] = project
            end
        end
    end
    
    if #items == 0 then
        vim.notify("No Qt projects found", vim.log.levels.WARN)
        return
    end
    
    -- 检查是否只有一个真正的项目选项（排除分隔线和标题）
    local real_projects = {}
    for _, project in pairs(project_map) do
        if project.path ~= "MANUAL_SELECT" then
            table.insert(real_projects, project)
        end
    end
    
    -- 如果只有一个项目，直接打开
    if #real_projects == 1 then
        local project = real_projects[1]
        vim.notify(string.format("Opening: %s", project.name), vim.log.levels.INFO)
        M.open_project(project.path)
        return
    end
    
    -- 显示选择界面
    vim.ui.select(items, {
        prompt = 'Select Qt project to open:',
        format_item = function(item)
            return item
        end
    }, function(choice, idx)
        if not choice or not idx then
            return
        end
        
        local selected_project = project_map[idx]
        if not selected_project then
            return
        end
        
        if selected_project.path == "MANUAL_SELECT" then
            -- 手动选择目录
            vim.ui.input({
                prompt = 'Project path: ',
                default = vim.fn.getcwd(),
                completion = 'dir'
            }, function(path)
                if path then
                    M.open_project(path)
                end
            end)
        else
            -- 打开选中的项目
            M.open_project(selected_project.path)
        end
    end)
end

return M