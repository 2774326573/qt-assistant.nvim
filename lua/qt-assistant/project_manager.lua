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
    
    -- 创建项目目录
    local project_path = vim.fn.getcwd() .. "/" .. project_name
    local success, error_msg = file_manager.ensure_directory_exists(project_path)
    if not success then
        vim.notify("Failed to create project directory: " .. error_msg, vim.log.levels.ERROR)  
        return false
    end
    
    -- 生成项目文件
    local template_vars = {
        PROJECT_NAME = project_name,
        PROJECT_NAME_UPPER = string.upper(project_name),
        PROJECT_NAME_LOWER = string.lower(project_name),
        CLASS_NAME = M.project_name_to_class_name(project_name),
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y')
    }
    
    for _, file_name in ipairs(template.files) do
        local file_content = M.generate_template_file(file_name, template_type, template_vars)
        if file_content then
            local file_path = project_path .. "/" .. file_name
            local write_success = file_manager.write_file(file_path, file_content)
            if write_success then
                vim.notify("Created: " .. file_name, vim.log.levels.INFO)
            else
                vim.notify("Failed to create: " .. file_name, vim.log.levels.ERROR)
            end
        end
    end
    
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

-- 智能搜索Qt项目
function M.search_qt_projects(search_paths, max_depth)
    search_paths = search_paths or {vim.fn.getcwd(), vim.fn.expand('~')}
    max_depth = max_depth or 3
    
    local found_projects = {}
    
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
            
            if type == "directory" and not name:match("^%.") and 
               name ~= "build" and name ~= "node_modules" and 
               name ~= ".git" and name ~= ".vscode" then
                
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