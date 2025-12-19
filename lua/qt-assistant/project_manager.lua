-- Qt Assistant Plugin - Project management module
-- 项目管理模块

local M = {}
local file_manager = require('qt-assistant.file_manager')
local history = require('qt-assistant.history')
local system = require('qt-assistant.system')

-- Project templates
local project_templates = {
    widget_app = {
        name = "Qt Widgets Application",
        description = "Standard Qt Widgets desktop application",
        files = {"main.cpp", "mainwindow.h", "mainwindow.cpp", "mainwindow.ui", "CMakeLists.txt", "ProjectGuide.md", "ThirdParty.md"},
        type = "executable"
    },
    quick_app = {
        name = "Qt Quick Application",
        description = "Qt Quick/QML application",
        files = {"main.cpp", "main.qml", "qml.qrc", "CMakeLists.txt", "ProjectGuide.md", "ThirdParty.md"},
        type = "executable"
    },
    console_app = {
        name = "Qt Console Application",
        description = "Command-line Qt application",
        files = {"main.cpp", "CMakeLists.txt", "ProjectGuide.md", "ThirdParty.md"},
        type = "executable"
    },
    -- Multi-module project templates
    multi_project = {
        name = "Multi-Module Qt Project",
        description = "Qt project with multiple modules (app + libraries)",
        files = {"CMakeLists.txt", "README.md", "ProjectGuide.md"},
        type = "workspace"
    },
    shared_lib = {
        name = "Qt Shared Library",
        description = "Qt shared library module",
        files = {"CMakeLists.txt", "ProjectGuide.md", "SharedLibraryGuide.md"},
        type = "library"
    },
    static_lib = {
        name = "Qt Static Library",
        description = "Qt static library module",
        files = {"CMakeLists.txt", "ProjectGuide.md"},
        type = "library"
    },
    plugin = {
        name = "Qt Plugin Module",
        description = "Qt plugin module",
        files = {"CMakeLists.txt", "ProjectGuide.md", "SharedLibraryGuide.md"},
        type = "plugin"
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

-- Discover Qt project directories by scanning for key project files
---@param opts? { paths?: string[], limit?: number }
---@return string[]
function M.discover_projects(opts)
    opts = opts or {}
    local limit = opts.limit or 20
    local results = {}
    local seen = {}
    local path_seen = {}

    local function normalize_path(path)
        if not path or path == "" then
            return nil
        end
        local absolute = vim.fn.fnamemodify(path, ":p")
        absolute = vim.fs.normalize(absolute)
        absolute = absolute:gsub("[/\\]+$", "")
        return absolute
    end

    local search_paths = {}
    if opts.paths and #opts.paths > 0 then
        for _, p in ipairs(opts.paths) do
            local normalized = normalize_path(p)
            if normalized then
                local key = normalized:lower()
                if not path_seen[key] then
                    table.insert(search_paths, normalized)
                    path_seen[key] = true
                end
            end
        end
    else
        local config = require('qt-assistant.config').get()
        if config and config.project_root then
            local normalized = normalize_path(config.project_root)
            if normalized then
                local key = normalized:lower()
                if not path_seen[key] then
                    table.insert(search_paths, normalized)
                    path_seen[key] = true
                end
            end
        end
        local cwd = normalize_path(vim.fn.getcwd())
        if cwd then
            local key = cwd:lower()
            if not path_seen[key] then
                table.insert(search_paths, cwd)
                path_seen[key] = true
            end
        end
    end

    local function add_result(dir)
        local normalized = normalize_path(dir)
        if not normalized then
            return
        end
        if vim.fn.isdirectory(normalized) ~= 1 then
            return
        end
        local key = normalized:lower()
        if not seen[key] then
            table.insert(results, normalized)
            seen[key] = true
        end
    end

    for _, root in ipairs(search_paths) do
        if vim.fn.isdirectory(root) == 1 then
            local remaining = limit - #results
            if remaining <= 0 then
                break
            end
            local matches = vim.fs.find(function(name)
                return name == "CMakeLists.txt" or name:match("%.pro$")
            end, {
                path = root,
                limit = remaining * 4,
                type = "file",
            }) or {}

            for _, file_path in ipairs(matches) do
                local dir = vim.fs.dirname(file_path)
                add_result(dir)
                if #results >= limit then
                    break
                end
            end
        end
    end

    return results
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

    history.record_project(project_path)

    return true
end

-- Create new project with optional C++ standard
-- opts:
--   enable_tests: boolean (default false)
function M.new_project(project_name, template_type, cxx_standard, root_dir, opts)
    opts = opts or {}
    if opts.enable_tests == nil then
        -- Default ON: new projects include runnable tests & demo code
        opts.enable_tests = true
    end
    if not project_name or project_name == "" then
        vim.notify("Project name is required", vim.log.levels.ERROR)
        return false
    end
    
    local template = project_templates[template_type]
    if not template then
        vim.notify("Unknown template type: " .. template_type, vim.log.levels.ERROR)
        return false
    end
    
    -- Default C++ standard if not specified
    cxx_standard = cxx_standard or "17"

    -- If no root directory provided, ask the user once and recurse with the choice
    if not root_dir then
        local base_dir = vim.fs.normalize(vim.fn.getcwd())
        vim.ui.input({
            prompt = "Project location (directory): ",
            default = base_dir,
            completion = 'dir'
        }, function(dir_input)
            if dir_input == nil then
                return
            end
            local target_root = dir_input ~= '' and vim.fs.normalize(dir_input) or base_dir
            M.new_project(project_name, template_type, cxx_standard, target_root, opts)
        end)
        return true
    end

    -- Root directory to place the new project (default: cwd)
    local base_dir = vim.fs.normalize(root_dir)
    
    -- Validate C++ standard
    if not M.validate_cxx_standard(cxx_standard) then
        vim.notify("Invalid C++ standard: " .. cxx_standard .. ". Supported: 11, 14, 17, 20", vim.log.levels.ERROR)
        return false
    end
    
    -- Create project directory
    local project_path = base_dir .. "/" .. project_name
    local success, error_msg = file_manager.ensure_directory_exists(project_path)
    if not success then
        vim.notify("Failed to create project directory: " .. error_msg, vim.log.levels.ERROR)
        return false
    end
    
    -- Create project structure
    M.create_project_structure(project_path, template_type, opts)
    
    -- Generate project files with C++ standard
    M.create_project_files(project_path, template_type, project_name, cxx_standard, opts)
    
    vim.notify(string.format("Project '%s' created successfully", project_name), vim.log.levels.INFO)
    
    -- Ask if user wants to open the project (skip in headless mode)
    local has_ui = true
    pcall(function()
        has_ui = #vim.api.nvim_list_uis() > 0
    end)

    if has_ui then
        vim.ui.select({'Yes', 'No'}, {
            prompt = 'Open the new project?'
        }, function(choice)
            if choice == 'Yes' then
                M.open_project(project_path)
            end
        end)
    end
    
    return true
end

-- Create project directory structure
function M.create_project_structure(project_path, template_type, opts)
    opts = opts or {}
    local project_dirname = vim.fn.fnamemodify(project_path, ":t")
    local directories = {"src", "include", "doc"}

    if template_type == "widget_app" then
        table.insert(directories, "ui")
        table.insert(directories, "resources")
    elseif template_type == "quick_app" then
        table.insert(directories, "qml")
        table.insert(directories, "resources")
    elseif template_type == "shared_lib" or template_type == "static_lib" or template_type == "plugin" then
        directories = {"src/" .. project_dirname, "include/" .. project_dirname, "doc"}
    end

    for _, dir in ipairs(directories) do
        local dir_path = project_path .. "/" .. dir
        file_manager.ensure_directory_exists(dir_path)
    end

    if opts.enable_tests then
        file_manager.ensure_directory_exists(project_path .. "/tests")
        file_manager.ensure_directory_exists(project_path .. "/examples")
    end

    -- Default export directory: export/<project_name>
    local export_dir = project_path .. "/export/" .. project_dirname
    file_manager.ensure_directory_exists(export_dir)
end

-- Create project files
function M.create_project_files(project_path, template_type, project_name, cxx_standard, opts)
    local templates = require('qt-assistant.templates')
    templates.init()

    opts = opts or {}
    
    cxx_standard = cxx_standard or "17"  -- Default to C++17
    
    local template_vars = {
        PROJECT_NAME = project_name,
        PROJECT_NAME_UPPER = string.upper(project_name),
        CLASS_NAME = M.project_name_to_class_name(project_name),
        FILE_NAME = "mainwindow",
        HEADER_GUARD = "MAINWINDOW_H",
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y'),
        CXX_STANDARD = cxx_standard
    }

    -- Used by doc templates to selectively show sections.
    template_vars.IS_APP = (template_type == "widget_app" or template_type == "console_app" or template_type == "quick_app")

    -- widget_app: wire MainWindow class to the generated .ui file.
    -- CMake template already lists ui/mainwindow.ui and enables AUTOUIC.
    if template_type == 'widget_app' then
        template_vars.HAS_UI_FILE = true
        template_vars.UI_HEADER = 'ui_' .. template_vars.FILE_NAME .. '.h'
        -- The <class> tag inside mainwindow.ui uses {{CLASS_NAME}}, so uic generates Ui_{{CLASS_NAME}}.
        template_vars.UI_CLASS_NAME = template_vars.CLASS_NAME
    end
    
    -- Create files based on template
    local template = project_templates[template_type]
    for _, file_name in ipairs(template.files) do
        local file_content = M.generate_template_file(file_name, template_type, template_vars)
        if file_content then
            if file_name == "CMakeLists.txt" and opts.enable_tests then
                file_content = file_content .. "\n\n# Testing (optional)\ninclude(CTest)\nenable_testing()\nadd_subdirectory(tests)\n"
            end

            local target_dir = M.get_target_directory(file_name, template_type)
            local file_path = project_path
            if target_dir ~= "" then
                file_path = file_path .. "/" .. target_dir
            end
            file_path = file_path .. "/" .. file_name
            
            file_manager.write_file(file_path, file_content)
        end
    end

    if opts.enable_tests then
        local framework = tostring(opts.test_framework or "qt"):lower()
        local tests_dir = project_path .. "/tests"
        file_manager.ensure_directory_exists(tests_dir)

        local is_app = template_type == "widget_app" or template_type == "console_app" or template_type == "quick_app"

        -- Tests
        local tests_cmake_template
        local test_cpp_template
        if framework == "gtest" then
            tests_cmake_template = is_app and "cmake_gtest_tests_app" or "cmake_gtest_tests_lib"
            test_cpp_template = is_app and "gtest_test_app" or "gtest_test_lib"
        else
            tests_cmake_template = is_app and "cmake_tests_app" or "cmake_tests_lib"
            test_cpp_template = is_app and "qt_test_app" or "qt_test_lib"
        end

        local tests_cmake = templates.render_template(tests_cmake_template, template_vars)
        file_manager.write_file(tests_dir .. "/CMakeLists.txt", tests_cmake)

        local test_cpp = templates.render_template(test_cpp_template, template_vars)
        file_manager.write_file(tests_dir .. "/test_basic.cpp", test_cpp)

        -- Runnable demo (callable test program)
        local examples_dir = project_path .. "/examples"
        file_manager.ensure_directory_exists(examples_dir)
        local demo_template = is_app and "demo_app" or "demo_lib"
        local demo_cpp = templates.render_template(demo_template, template_vars)
        file_manager.write_file(examples_dir .. "/demo.cpp", demo_cpp)

        -- App core (calculator) to be called by tests/demo
        if is_app then
            local calc_h = templates.render_template("calculator_header", template_vars)
            local calc_cpp = templates.render_template("calculator_source", template_vars)
            file_manager.write_file(project_path .. "/include/calculator.h", calc_h)
            file_manager.write_file(project_path .. "/src/calculator.cpp", calc_cpp)
        end
    end

    if template_type == "shared_lib" or template_type == "static_lib" or template_type == "plugin" then
        local include_dir = project_path .. "/include/" .. project_name
        local source_dir = project_path .. "/src/" .. project_name

        file_manager.ensure_directory_exists(include_dir)
        file_manager.ensure_directory_exists(source_dir)

        local header_content = M.generate_library_header(project_name, template_type, template_vars)
        file_manager.write_file(include_dir .. "/" .. project_name .. ".h", header_content)

        -- Export macro header for shared/static/plugin targets
        local export_content = templates.render_template("library_export_header", template_vars)
        file_manager.write_file(include_dir .. "/" .. project_name .. "_export.h", export_content)

        local source_content = M.generate_library_source(project_name, template_type, template_vars)
        file_manager.write_file(source_dir .. "/" .. project_name .. ".cpp", source_content)
    end
end

-- Get target directory for file type
function M.get_target_directory(file_name, template_type)
    if file_name:match("%.h$") then
        return "include"
    elseif file_name:match("%.cpp$") then
        return "src"  -- All cpp files go to src, including main.cpp
    elseif file_name:match("%.md$") then
        return "doc"
    elseif file_name:match("%.ui$") then
        return "ui"
    elseif file_name:match("%.qml$") then
        return template_type == "quick_app" and "qml" or "resources"
    elseif file_name:match("%.qrc$") then
        return ""  -- Root directory for resource files
    else
        return ""  -- Root directory
    end
end

-- Generate template file content
function M.generate_template_file(file_name, template_type, vars)
    local templates = require('qt-assistant.templates')
    
    local template_map = {
        ["main.cpp"] = template_type == "widget_app" and "main_widget_app" or
                      (template_type == "quick_app" and "main_quick_app" or "main_console_app"),
        ["mainwindow.h"] = "main_window_header",
        ["mainwindow.cpp"] = "main_window_source",
        ["mainwindow.ui"] = "main_window_ui",
        ["main.qml"] = "main_qml",
        ["qml.qrc"] = "qml_qrc",
        ["CMakeLists.txt"] = "cmake_" .. template_type,
        ["README.md"] = template_type == "multi_project" and "multi_project_readme" or nil,
        ["ProjectGuide.md"] = "doc_project_guide",
        ["ThirdParty.md"] = "doc_third_party_guide",
        ["SharedLibraryGuide.md"] = "doc_shared_library_guide"
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

-- Validate C++ standard
function M.validate_cxx_standard(standard)
    local valid_standards = {"11", "14", "17", "20", "23"}
    for _, valid in ipairs(valid_standards) do
        if tostring(standard) == valid then
            return true
        end
    end
    return false
end

-- Get recommended C++ standard for Qt version
function M.get_recommended_cxx_standard(qt_version)
    if qt_version == "6" then
        return "17"  -- Qt6 requires C++17 minimum
    elseif qt_version == "5" then
        return "11"  -- Qt5 works with C++11 minimum
    else
        return "17"  -- Default to C++17
    end
end

-- Interactive project creation with C++ standard selection
function M.new_project_interactive()
    local project_name = vim.fn.input("Project name: ")
    if project_name == "" then
        vim.notify("Project name cannot be empty", vim.log.levels.ERROR)
        return
    end

    -- Choose base directory to place the project
    local base_dir = vim.fs.normalize(vim.fn.getcwd())
    vim.ui.input({
        prompt = "Project location (directory): ",
        default = base_dir,
        completion = 'dir'
    }, function(dir_input)
        if dir_input == nil then
            return
        end

        local target_root = dir_input ~= '' and vim.fs.normalize(dir_input) or base_dir

        -- Template selection
        local template_options = {"widget_app", "console_app", "quick_app", "static_lib", "shared_lib", "plugin"}
        local template_choice = vim.fn.inputlist({
            "Select project template:",
            "1. Widget Application (QMainWindow)",
            "2. Console Application", 
            "3. Quick Application (QML)",
            "4. Static Library",
            "5. Shared Library",
            "6. Plugin Module"
        })
        
        if template_choice < 1 or template_choice > #template_options then
            vim.notify("Invalid template selection", vim.log.levels.ERROR)
            return
        end
        
        local template_type = template_options[template_choice]

        -- Test framework selection (right after template selection)
        vim.ui.select({ 'No tests', 'Qt Test', 'GoogleTest (gtest)' }, {
            prompt = 'Select test framework:'
        }, function(choice)
            local enable_tests = choice ~= 'No tests'
            local test_framework = nil
            if choice == 'Qt Test' then
                test_framework = 'qt'
            elseif choice == 'GoogleTest (gtest)' then
                test_framework = 'gtest'
            end

            -- C++ standard selection (use vim.ui.select for better UI compatibility)
            local cxx_options = {
                { label = 'C++11 (Qt5 compatible)', value = '11' },
                { label = 'C++14 (Qt5 compatible)', value = '14' },
                { label = 'C++17 (Qt5/Qt6 compatible, recommended)', value = '17' },
                { label = 'C++20 (Modern C++, Qt6 preferred)', value = '20' },
                { label = 'C++23 (Latest standard)', value = '23' },
            }

            vim.ui.select(cxx_options, {
                prompt = 'Select C++ standard:',
                format_item = function(item)
                    return item.label
                end
            }, function(item)
                local cxx_standard = (item and item.value) or '17'

                vim.notify(string.format(
                    "Creating %s project '%s' in %s with C++%s%s",
                    template_type,
                    project_name,
                    target_root,
                    cxx_standard,
                    enable_tests and (" + " .. (test_framework == 'gtest' and 'gtest' or 'QtTest')) or ""
                ), vim.log.levels.INFO)

                return M.new_project(project_name, template_type, cxx_standard, target_root, { enable_tests = enable_tests, test_framework = test_framework })
            end)
        end)
    end)
end

-- Semi-interactive: user provides project_name and template_type, we still prompt
-- for location, test framework, and C++ standard.
function M.new_project_interactive_preset(project_name, template_type)
    if not project_name or project_name == "" then
        vim.notify("Project name is required", vim.log.levels.ERROR)
        return
    end

    if not template_type or template_type == "" then
        vim.notify("Project template is required", vim.log.levels.ERROR)
        return
    end

    -- Choose base directory to place the project
    local base_dir = vim.fs.normalize(vim.fn.getcwd())
    vim.ui.input({
        prompt = "Project location (directory): ",
        default = base_dir,
        completion = 'dir'
    }, function(dir_input)
        if dir_input == nil then
            return
        end

        local target_root = dir_input ~= '' and vim.fs.normalize(dir_input) or base_dir

        vim.ui.select({ 'No tests', 'Qt Test', 'GoogleTest (gtest)' }, {
            prompt = 'Select test framework:'
        }, function(choice)
            local enable_tests = choice ~= 'No tests'
            local test_framework = nil
            if choice == 'Qt Test' then
                test_framework = 'qt'
            elseif choice == 'GoogleTest (gtest)' then
                test_framework = 'gtest'
            end

            -- C++ standard selection (use vim.ui.select for better UI compatibility)
            local cxx_options = {
                { label = 'C++11 (Qt5 compatible)', value = '11' },
                { label = 'C++14 (Qt5 compatible)', value = '14' },
                { label = 'C++17 (Qt5/Qt6 compatible, recommended)', value = '17' },
                { label = 'C++20 (Modern C++, Qt6 preferred)', value = '20' },
                { label = 'C++23 (Latest standard)', value = '23' },
            }

            vim.ui.select(cxx_options, {
                prompt = 'Select C++ standard:',
                format_item = function(item)
                    return item.label
                end
            }, function(item)
                local cxx_standard = (item and item.value) or '17'

                vim.notify(string.format(
                    "Creating %s project '%s' in %s with C++%s%s",
                    template_type,
                    project_name,
                    target_root,
                    cxx_standard,
                    enable_tests and (" + " .. (test_framework == 'gtest' and 'gtest' or 'QtTest')) or ""
                ), vim.log.levels.INFO)

                return M.new_project(project_name, template_type, cxx_standard, target_root, { enable_tests = enable_tests, test_framework = test_framework })
            end)
        end)
    end)
end

-- Add module to existing multi-module project
function M.add_module(module_name, module_type, parent_dir, opts)
    opts = opts or {}
    if not module_name or module_name == "" then
        vim.notify("Module name is required", vim.log.levels.ERROR)
        return false
    end

    local template = project_templates[module_type]
    if not template then
        vim.notify("Unknown module type: " .. module_type, vim.log.levels.ERROR)
        return false
    end

    parent_dir = parent_dir or vim.fn.getcwd()

    -- Check if this is a multi-module project
    local root_cmake = parent_dir .. "/CMakeLists.txt"
    if not file_manager.file_exists(root_cmake) then
        vim.notify("No CMakeLists.txt found in parent directory. Is this a multi-module project?", vim.log.levels.ERROR)
        return false
    end

    -- Create module directory
    local module_path = parent_dir .. "/" .. module_name
    local success, error_msg = file_manager.ensure_directory_exists(module_path)
    if not success then
        vim.notify("Failed to create module directory: " .. error_msg, vim.log.levels.ERROR)
        return false
    end

    -- Create module structure based on type
    M.create_module_structure(module_path, module_type, opts)

    -- Generate module files
    M.create_module_files(module_path, module_type, module_name, opts)

    -- Update root CMakeLists.txt to include new module
    M.add_module_to_root_cmake(parent_dir, module_name)

    vim.notify(string.format("Module '%s' (%s) created successfully", module_name, module_type), vim.log.levels.INFO)
    return true
end

-- Create module directory structure
function M.create_module_structure(module_path, module_type, opts)
    opts = opts or {}
    local directories = {"doc"}

    if module_type == "shared_lib" or module_type == "static_lib" or module_type == "plugin" then
        directories = {
            "doc",
            "src/" .. vim.fn.fnamemodify(module_path, ":t"),
            "include/" .. vim.fn.fnamemodify(module_path, ":t")
        }
    elseif module_type == "widget_app" or module_type == "quick_app" then
        directories = {"doc", "src", "include", "ui"}
        if module_type == "quick_app" then
            table.insert(directories, "qml")
        end
    elseif module_type == "console_app" then
        directories = {"doc", "src", "include"}
    end

    for _, dir in ipairs(directories) do
        local dir_path = module_path .. "/" .. dir
        file_manager.ensure_directory_exists(dir_path)
    end

    if opts.enable_tests then
        file_manager.ensure_directory_exists(module_path .. "/tests")
        file_manager.ensure_directory_exists(module_path .. "/examples")
    end
end

-- Create module files
function M.create_module_files(module_path, module_type, module_name, opts)
    local templates = require('qt-assistant.templates')
    templates.init()

    opts = opts or {}

    local is_shared_lib = module_type == "shared_lib"
    local is_static_lib = module_type == "static_lib"
    local is_plugin = module_type == "plugin"
    local is_widget_app = module_type == "widget_app"
    local is_quick_app = module_type == "quick_app"
    local is_console_app = module_type == "console_app"
    local is_app = is_widget_app or is_quick_app or is_console_app

    local template_vars = {
        PROJECT_NAME = module_name,
        PROJECT_NAME_UPPER = string.upper(module_name),
        CLASS_NAME = M.project_name_to_class_name(module_name),
        FILE_NAME = module_name:lower(),
        HEADER_GUARD = string.upper(module_name) .. "_H",
        DATE = os.date('%Y-%m-%d'),
        YEAR = os.date('%Y'),
        CXX_STANDARD = "17",  -- Default for modules
        MODULE_TYPE = module_type,

        -- Flags for docs/templates
        IS_SHARED_LIB = is_shared_lib,
        IS_STATIC_LIB = is_static_lib,
        IS_PLUGIN = is_plugin,
        IS_WIDGET_APP = is_widget_app,
        IS_QUICK_APP = is_quick_app,
        IS_CONSOLE_APP = is_console_app,
        IS_APP = is_app,
        IS_LIBRARY = (is_shared_lib or is_static_lib),
    }

    -- Create CMakeLists.txt for the module
    local cmake_template_name = "cmake_" .. module_type
    local cmake_content = templates.render_template(cmake_template_name, template_vars)
    if cmake_content then
        if opts.enable_tests then
            cmake_content = cmake_content .. "\n\n# Testing (optional)\ninclude(CTest)\nenable_testing()\nadd_subdirectory(tests)\n"
        end
        file_manager.write_file(module_path .. "/CMakeLists.txt", cmake_content)
    end

    if opts.enable_tests then
        local framework = tostring(opts.test_framework or "qt"):lower()
        local tests_dir = module_path .. "/tests"
        file_manager.ensure_directory_exists(tests_dir)

        local tests_cmake_template
        local test_cpp_template
        if framework == "gtest" then
            tests_cmake_template = is_app and "cmake_gtest_tests_app" or "cmake_gtest_tests_lib"
            test_cpp_template = is_app and "gtest_test_app" or "gtest_test_lib"
        else
            tests_cmake_template = is_app and "cmake_tests_app" or "cmake_tests_lib"
            test_cpp_template = is_app and "qt_test_app" or "qt_test_lib"
        end

        local tests_cmake = templates.render_template(tests_cmake_template, template_vars)
        file_manager.write_file(tests_dir .. "/CMakeLists.txt", tests_cmake)

        local test_cpp = templates.render_template(test_cpp_template, template_vars)
        file_manager.write_file(tests_dir .. "/test_basic.cpp", test_cpp)

        local examples_dir = module_path .. "/examples"
        file_manager.ensure_directory_exists(examples_dir)
        local demo_template = is_app and "demo_app" or "demo_lib"
        local demo_cpp = templates.render_template(demo_template, template_vars)
        file_manager.write_file(examples_dir .. "/demo.cpp", demo_cpp)

        if is_app then
            local calc_h = templates.render_template("calculator_header", template_vars)
            local calc_cpp = templates.render_template("calculator_source", template_vars)
            file_manager.write_file(module_path .. "/include/calculator.h", calc_h)
            file_manager.write_file(module_path .. "/src/calculator.cpp", calc_cpp)
        end
    end

    -- Create source and header files for libraries and plugins
    if module_type == "shared_lib" or module_type == "static_lib" or module_type == "plugin" then
        local header_content = M.generate_library_header(module_name, module_type, template_vars)
        local header_path = module_path .. "/include/" .. module_name .. "/" .. module_name .. ".h"
        file_manager.write_file(header_path, header_content)

        -- Export macro header
        local export_content = templates.render_template("library_export_header", template_vars)
        local export_path = module_path .. "/include/" .. module_name .. "/" .. module_name .. "_export.h"
        file_manager.write_file(export_path, export_content)

        local source_content = M.generate_library_source(module_name, module_type, template_vars)
        local source_path = module_path .. "/src/" .. module_name .. "/" .. module_name .. ".cpp"
        file_manager.write_file(source_path, source_content)
    end

    -- Documentation for modules
    local module_doc_dir = module_path .. "/doc"
    file_manager.ensure_directory_exists(module_doc_dir)

    local module_guide = templates.render_template("doc_module_guide", template_vars)
    if module_guide then
        file_manager.write_file(module_doc_dir .. "/ModuleGuide.md", module_guide)
    end

    -- Reuse project guides where appropriate
    if module_type == "widget_app" or module_type == "quick_app" or module_type == "console_app" then
        local guide = templates.render_template("doc_project_guide", template_vars)
        if guide then
            file_manager.write_file(module_doc_dir .. "/ProjectGuide.md", guide)
        end
    end

    if module_type == "shared_lib" or module_type == "static_lib" or module_type == "plugin" then
        local lib_guide = templates.render_template("doc_shared_library_guide", template_vars)
        if lib_guide then
            file_manager.write_file(module_doc_dir .. "/SharedLibraryGuide.md", lib_guide)
        end
    end
end

-- Generate library header template
function M.generate_library_header(module_name, module_type, template_vars)
    local templates = require('qt-assistant.templates')
    local vars = vim.tbl_extend("force", template_vars or {}, {
        HEADER_GUARD = (template_vars and template_vars.HEADER_GUARD) or (string.upper(module_name) .. "_H"),
        PLUGIN_IID = "org.example." .. module_name,
        PROJECT_NAME_UPPER = string.upper(module_name)
    })

    if module_type == "plugin" then
        return templates.render_template("plugin_header", vars)
    end

    return templates.render_template("library_header", vars)
end

-- Generate library source template
function M.generate_library_source(module_name, module_type, template_vars)
    local templates = require('qt-assistant.templates')
    local vars = vim.tbl_extend("force", template_vars or {}, {
        PLUGIN_IID = "org.example." .. module_name
    })

    if module_type == "plugin" then
        return templates.render_template("plugin_source", vars)
    end

    return templates.render_template("library_source", vars)
end

-- Add module to root CMakeLists.txt
function M.add_module_to_root_cmake(parent_dir, module_name)
    local root_cmake_path = parent_dir .. "/CMakeLists.txt"
    local content = file_manager.read_file(root_cmake_path)

    if not content then
        vim.notify("Failed to read root CMakeLists.txt", vim.log.levels.ERROR)
        return false
    end

    -- Check if module is already added
    local subdirectory_line = "add_subdirectory(" .. module_name .. ")"
    if content:find(subdirectory_line, 1, true) then
        vim.notify("Module " .. module_name .. " already exists in root CMakeLists.txt", vim.log.levels.INFO)
        return true
    end

    -- Find a good place to insert the add_subdirectory call
    local insertion_point = content:find("# Add subdirectories %(modules will be added here%)")
    if insertion_point then
        -- Replace the comment with the actual subdirectory call
        local before = content:sub(1, insertion_point - 1)
        local after = content:sub(content:find("\n", insertion_point))
        local new_content = before .. "# Add subdirectories (modules will be added here)\nadd_subdirectory(" .. module_name .. ")" .. after
        file_manager.write_file(root_cmake_path, new_content)
    else
        -- Append at the end
        local new_content = content .. "\n# Add " .. module_name .. " module\nadd_subdirectory(" .. module_name .. ")\n"
        file_manager.write_file(root_cmake_path, new_content)
    end

    return true
end

-- List available module types
function M.get_available_module_types()
    local module_types = {}
    for key, template in pairs(project_templates) do
        if template.type ~= "workspace" then  -- Exclude workspace type
            table.insert(module_types, key)
        end
    end
    return module_types
end

-- Interactive module addition
function M.add_module_interactive()
    local module_name = vim.fn.input("Module name: ")
    if module_name == "" then
        vim.notify("Module name cannot be empty", vim.log.levels.ERROR)
        return
    end

    local module_types = M.get_available_module_types()
    local type_descriptions = {}
    for i, type_key in ipairs(module_types) do
        local template = project_templates[type_key]
        table.insert(type_descriptions, i .. ". " .. template.name .. " (" .. template.description .. ")")
    end

    local choice = vim.fn.inputlist(vim.tbl_flatten({
        "Select module type:",
        type_descriptions
    }))

    if choice < 1 or choice > #module_types then
        vim.notify("Invalid selection", vim.log.levels.ERROR)
        return
    end

    local module_type = module_types[choice]

    vim.ui.select({ 'No tests', 'Qt Test', 'GoogleTest (gtest)' }, {
        prompt = 'Select test framework:'
    }, function(test_choice)
        local enable_tests = test_choice ~= 'No tests'
        local test_framework = nil
        if test_choice == 'Qt Test' then
            test_framework = 'qt'
        elseif test_choice == 'GoogleTest (gtest)' then
            test_framework = 'gtest'
        end

        return M.add_module(module_name, module_type, nil, { enable_tests = enable_tests, test_framework = test_framework })
    end)
end

return M
