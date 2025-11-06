-- Qt Assistant Plugin - Build management module
-- 构建管理模块

local M = {}

-- Get configuration
local function get_config()
    return require('qt-assistant.config').get()
end

-- Detect build system
function M.detect_build_system()
    local project_root = get_config().project_root
    
    if vim.fn.filereadable(project_root .. "/CMakeLists.txt") == 1 then
        return "cmake"
    elseif vim.fn.glob(project_root .. "/*.pro") ~= "" then
        return "qmake"
    end
    
    return nil
end

function M.build_project(build_type, opts)
    build_type = build_type or "Debug"
    opts = opts or {}
    
    vim.schedule(function()
        local build_system = M.detect_build_system()
        if not build_system then
            vim.notify("❌ No build system detected (CMakeLists.txt or *.pro)", vim.log.levels.ERROR)
            return
        end
        
        local project_root = get_config().project_root
        local build_dir = project_root .. "/build"
        
        -- Ensure build directory exists
        local file_manager = require('qt-assistant.file_manager')
        local success, error_msg = file_manager.ensure_directory_exists(build_dir)
        if not success then
            vim.notify("❌ Failed to create build directory: " .. error_msg, vim.log.levels.ERROR)
            return
        end
        
        vim.notify("🔨 Building Qt project (" .. build_system .. ")...", vim.log.levels.INFO)
        
        if build_system == "cmake" then
            M.build_with_cmake_async(project_root, build_dir, build_type)
        elseif build_system == "qmake" then
            M.build_with_qmake_async(project_root, build_dir)
        end
    end)
    
    return true
end

-- Build with CMake (async)
function M.build_with_cmake_async(project_root, build_dir, build_type)
    local system = require('qt-assistant.system')
    local cmake_path = system.find_executable("cmake")
    
    if not cmake_path then
        vim.notify("❌ CMake not found. Please install CMake.", vim.log.levels.ERROR)
        return
    end
    
    -- Configure step
    local configure_cmd = {
        cmake_path, 
        "-B", build_dir, 
        "-S", project_root,
        "-DCMAKE_BUILD_TYPE=" .. build_type,
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    }
    
    vim.notify("⚙️  Configuring with CMake...", vim.log.levels.INFO)
    
    vim.fn.jobstart(configure_cmd, {
        cwd = project_root,
        on_stderr = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line and line ~= "" and not line:match("^$") then
                        vim.schedule(function()
                            vim.notify("CMake: " .. line, vim.log.levels.WARN)
                        end)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("✅ CMake configure completed", vim.log.levels.INFO)
                    M.start_cmake_build(cmake_path, build_dir)
                else
                    vim.notify("❌ CMake configure failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end
            end)
        end
    })
end

-- Start CMake build step
function M.start_cmake_build(cmake_path, build_dir)
    local build_cmd = {cmake_path, "--build", build_dir, "--parallel"}
    
    vim.notify("🔨 Building project...", vim.log.levels.INFO)
    
    vim.fn.jobstart(build_cmd, {
        on_stderr = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line and line ~= "" and not line:match("^$") then
                        vim.schedule(function()
                            vim.notify("Build: " .. line, vim.log.levels.WARN)
                        end)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("🎉 Build completed successfully!", vim.log.levels.INFO)
                else
                    vim.notify("❌ Build failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end
            end)
        end
    })
end

-- Build with qmake (async)
function M.build_with_qmake_async(project_root, build_dir)
    local system = require('qt-assistant.system')
    local qmake_path = system.find_qt_tool("qmake")
    
    if not qmake_path then
        vim.notify("❌ qmake not found. Please install Qt development tools.", vim.log.levels.ERROR)
        return
    end
    
    -- Find .pro file
    local pro_files = vim.fn.glob(project_root .. "/*.pro", false, true)
    if #pro_files == 0 then
        vim.notify("❌ No .pro file found", vim.log.levels.ERROR)
        return
    end
    
    local pro_file = pro_files[1]
    
    vim.notify("⚙️  Configuring with qmake...", vim.log.levels.INFO)
    
    -- Generate Makefile
    local qmake_cmd = {qmake_path, pro_file, "-o", build_dir .. "/Makefile"}
    
    vim.fn.jobstart(qmake_cmd, {
        cwd = build_dir,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("✅ qmake completed", vim.log.levels.INFO)
                    M.start_make_build(build_dir)
                else
                    vim.notify("❌ qmake failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end
            end)
        end
    })
end

-- Start make build
function M.start_make_build(build_dir)
    vim.notify("🔨 Building with make...", vim.log.levels.INFO)
    
    local make_cmd = {"make", "-j4"}  -- Parallel build
    
    vim.fn.jobstart(make_cmd, {
        cwd = build_dir,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("🎉 Build completed successfully!", vim.log.levels.INFO)
                else
                    vim.notify("❌ Build failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end
            end)
        end
    })
end

-- Run project (async)
function M.run_project()
    vim.schedule(function()
        local project_root = get_config().project_root
        local build_dir = project_root .. "/build"
        
        -- Find executable
        local project_name = vim.fn.fnamemodify(project_root, ":t")
        local system = require('qt-assistant.system')
        local exe_name = project_name
        if system.get_os() == 'windows' then
            exe_name = exe_name .. ".exe"
        end
        
        local possible_paths = {
            build_dir .. "/" .. exe_name,
            build_dir .. "/Debug/" .. exe_name,
            build_dir .. "/Release/" .. exe_name
        }
        
        local exe_path = nil
        for _, path in ipairs(possible_paths) do
            if vim.fn.executable(path) == 1 then
                exe_path = path
                break
            end
        end
        
        if not exe_path then
            vim.notify("❌ Executable not found. Please build the project first.", vim.log.levels.ERROR)
            return
        end
        
        vim.notify("▶️  Running: " .. exe_name, vim.log.levels.INFO)
        
        -- Run in split terminal
        vim.cmd("split")
        vim.cmd("terminal " .. vim.fn.shellescape(exe_path))
    end)
end

return M
