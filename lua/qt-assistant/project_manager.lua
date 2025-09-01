-- Qt Assistant Plugin - Project management module
-- 项目管理模块

local M = {}
local file_manager = require('qt-assistant.file_manager')

-- Project templates
local project_templates = {
    widget_app = {
        name = "Qt Widgets Application",
        description = "Standard Qt Widgets desktop application",
        files = {"main.cpp", "mainwindow.h", "mainwindow.cpp", "mainwindow.ui", "CMakeLists.txt"}
    },
    quick_app = {
        name = "Qt Quick Application", 
        description = "Qt Quick/QML application",
        files = {"main.cpp", "main.qml", "qml.qrc", "CMakeLists.txt"}
    },
    console_app = {
        name = "Qt Console Application",
        description = "Command-line Qt application", 
        files = {"main.cpp", "CMakeLists.txt"}
    }
}

-- Detect project type
function M.detect_project_type(project_path)
    project_path = project_path or vim.fn.getcwd()
    
    local project_files = {
        {file = "CMakeLists.txt", type = "cmake", priority = 1},
        {file = "*.pro", type = "qmake", priority = 2}
    }
    
    for _, config in ipairs(project_files) do
        if config.file:match("%*") then
            -- Glob pattern
            local pattern = config.file:gsub("%*", ".*")
            local handle = vim.loop.fs_scandir(project_path)
            if handle then
                while true do
                    local name, type = vim.loop.fs_scandir_next(handle)
                    if not name then break end
                    if name:match(pattern) then
                        return config.type
                    end
                end
            end
        else
            -- Exact file match
            if file_manager.file_exists(project_path .. "/" .. config.file) then
                return config.type
            end
        end
    end
    
    return nil
end

-- Open project
function M.open_project(project_path)
    project_path = project_path or vim.fn.getcwd()
    
    if not vim.fn.isdirectory(project_path) then
        vim.notify("Directory does not exist: " .. project_path, vim.log.levels.ERROR)
        return false
    end
    
    -- Change to project directory
    vim.cmd("cd " .. vim.fn.fnameescape(project_path))
    
    -- Detect project type
    local project_type = M.detect_project_type(project_path)
    
    if not project_type then
        vim.notify("No Qt project detected in: " .. project_path, vim.log.levels.WARN)
        return false
    end
    
    vim.notify(string.format("Opened Qt project (%s): %s", project_type, project_path), vim.log.levels.INFO)
    
    -- Update configuration
    local config = require('qt-assistant.config')
    config.set_value('project_root', project_path)
    
    return true
end

-- Create new project
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
    
    -- Create project directory
    local project_path = vim.fn.getcwd() .. "/" .. project_name
    local success, error_msg = file_manager.ensure_directory_exists(project_path)
    if not success then
        vim.notify("Failed to create project directory: " .. error_msg, vim.log.levels.ERROR)
        return false
    end
    
    -- Create project structure
    M.create_project_structure(project_path, template_type)
    
    -- Generate project files
    M.create_project_files(project_path, template_type, project_name)
    
    -- Create Windows scripts if on Windows or requested
    M.create_windows_scripts(project_path, project_name)
    
    vim.notify(string.format("Project '%s' created successfully", project_name), vim.log.levels.INFO)
    
    -- Ask if user wants to open the project
    vim.ui.select({'Yes', 'No'}, {
        prompt = 'Open the new project?'
    }, function(choice)
        if choice == 'Yes' then
            M.open_project(project_path)
        end
    end)
    
    return true
end

-- Create project directory structure
function M.create_project_structure(project_path, template_type)
    local directories = {"src", "include"}
    
    if template_type == "widget_app" then
        table.insert(directories, "ui")
        table.insert(directories, "resources")
    elseif template_type == "quick_app" then
        table.insert(directories, "qml")
        table.insert(directories, "resources")
    end
    
    for _, dir in ipairs(directories) do
        local dir_path = project_path .. "/" .. dir
        file_manager.ensure_directory_exists(dir_path)
    end
end

-- Create project files
function M.create_project_files(project_path, template_type, project_name)
    local templates = require('qt-assistant.templates')
    templates.init()
    
    local template_vars = {
        PROJECT_NAME = project_name,
        CLASS_NAME = M.project_name_to_class_name(project_name),
        FILE_NAME = "mainwindow",
        HEADER_GUARD = "MAINWINDOW_H",
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y')
    }
    
    -- Create files based on template
    local template = project_templates[template_type]
    for _, file_name in ipairs(template.files) do
        local file_content = M.generate_template_file(file_name, template_type, template_vars)
        if file_content then
            local target_dir = M.get_target_directory(file_name, template_type)
            local file_path = project_path
            if target_dir ~= "" then
                file_path = file_path .. "/" .. target_dir
            end
            file_path = file_path .. "/" .. file_name
            
            file_manager.write_file(file_path, file_content)
        end
    end
end

-- Get target directory for file type
function M.get_target_directory(file_name, template_type)
    if file_name:match("%.h$") then
        return "include"
    elseif file_name:match("%.cpp$") then
        return "src"  -- All cpp files go to src, including main.cpp
    elseif file_name:match("%.ui$") then
        return "ui"
    elseif file_name:match("%.qml$") or file_name:match("%.qrc$") then
        return template_type == "quick_app" and "qml" or "resources"
    else
        return ""  -- Root directory
    end
end

-- Generate template file content
function M.generate_template_file(file_name, template_type, vars)
    local templates = require('qt-assistant.templates')
    
    local template_map = {
        ["main.cpp"] = template_type == "widget_app" and "main_widget_app" or "main_console_app",
        ["mainwindow.h"] = "main_window_header",
        ["mainwindow.cpp"] = "main_window_source", 
        ["mainwindow.ui"] = "main_window_ui",
        ["CMakeLists.txt"] = "cmake_" .. template_type
    }
    
    local template_name = template_map[file_name]
    if template_name then
        return templates.render_template(template_name, vars)
    end
    
    return nil
end

-- Convert project name to class name
function M.project_name_to_class_name(project_name)
    local class_name = project_name:gsub("[-_](%w)", function(c)
        return string.upper(c)
    end)
    return string.upper(class_name:sub(1, 1)) .. class_name:sub(2)
end

-- Check if directory is Qt project
function M.is_qt_project(project_path)
    project_path = project_path or vim.fn.getcwd()
    return M.detect_project_type(project_path) ~= nil
end

-- Create Windows development scripts
function M.create_windows_scripts(project_path, project_name)
    local templates = require('qt-assistant.templates')
    
    -- Variables for template rendering
    local vars = {
        PROJECT_NAME = project_name,
        UPPER_PROJECT_NAME = string.upper(project_name)
    }
    
    -- Scripts to create
    local scripts = {
        {
            filename = "build.bat",
            template_func = templates.get_windows_build_script
        },
        {
            filename = "run.bat", 
            template_func = templates.get_windows_run_script
        },
        {
            filename = "clean.bat",
            template_func = templates.get_windows_clean_script
        },
        {
            filename = "setup.bat",
            template_func = templates.get_windows_setup_script
        },
        {
            filename = "dev.bat",
            template_func = templates.get_windows_dev_script
        }
    }
    
    vim.notify("Creating Windows development scripts...", vim.log.levels.INFO)
    
    for _, script in ipairs(scripts) do
        local script_path = project_path .. "/" .. script.filename
        local script_content = script.template_func()
        
        -- Render template with variables
        script_content = templates.render_template_string(script_content, vars)
        
        local success, error_msg = file_manager.write_file(script_path, script_content)
        if success then
            vim.notify(string.format("✓ Created %s", script.filename), vim.log.levels.INFO)
        else
            vim.notify(string.format("✗ Failed to create %s: %s", script.filename, error_msg), vim.log.levels.ERROR)
        end
    end
    
    -- Create additional useful scripts
    M.create_additional_windows_scripts(project_path, vars)
end

-- Create additional Windows scripts
function M.create_additional_windows_scripts(project_path, vars)
    local templates = require('qt-assistant.templates')
    
    -- Create VS Code launch configuration for Windows
    local vscode_config = [[
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Qt Debug",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/Debug/{{PROJECT_NAME}}.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "externalTerminal",
            "preLaunchTask": "Build Debug"
        },
        {
            "name": "Qt Release",
            "type": "cppvsdbg", 
            "request": "launch",
            "program": "${workspaceFolder}/build/Release/{{PROJECT_NAME}}.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "externalTerminal",
            "preLaunchTask": "Build Release"
        }
    ]
}
]]
    
    -- Create VS Code tasks configuration
    local vscode_tasks = [[
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Debug",
            "type": "shell",
            "command": "${workspaceFolder}/build.bat",
            "args": ["Debug"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Build Release",
            "type": "shell",
            "command": "${workspaceFolder}/build.bat",
            "args": ["Release"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Clean",
            "type": "shell",
            "command": "${workspaceFolder}/clean.bat",
            "group": "build"
        }
    ]
}
]]
    
    -- Create .vscode directory and files
    local vscode_dir = project_path .. "/.vscode"
    file_manager.ensure_directory_exists(vscode_dir)
    
    -- Render and write VS Code configurations
    local launch_content = templates.render_template_string(vscode_config, vars)
    local tasks_content = templates.render_template_string(vscode_tasks, vars)
    
    file_manager.write_file(vscode_dir .. "/launch.json", launch_content)
    file_manager.write_file(vscode_dir .. "/tasks.json", tasks_content)
    
    vim.notify("✓ Created VS Code configurations", vim.log.levels.INFO)
end

return M