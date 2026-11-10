-- Qt Assistant Plugin - Build management module
-- 构建管理模块

local M = {}

-- Remember last requested build type for subsequent install/package steps
M._last_build_type = nil

-- Get configuration
local function get_config()
    return require('qt-assistant.config').get()
end

local function project_has_build_file(project_root, kind)
    if kind == "cmake" then
        return vim.fn.filereadable(project_root .. "/CMakeLists.txt") == 1
    elseif kind == "qmake" then
        return vim.fn.glob(project_root .. "/*.pro") ~= ""
    elseif kind == "xmake" then
        return vim.fn.filereadable(project_root .. "/xmake.lua") == 1
    end
    return false
end

-- Detect build system.
-- Auto order preserves existing projects: CMake, then qmake, then xmake.
-- config.build_system = "cmake"|"qmake"|"xmake" forces that system when its file exists.
function M.detect_build_system(project_root)
    project_root = project_root or get_config().project_root

    local prefer = get_config().build_system
    if prefer and prefer ~= "" and prefer ~= "auto" and project_has_build_file(project_root, prefer) then
        return prefer
    end

    if project_has_build_file(project_root, "cmake") then
        return "cmake"
    elseif project_has_build_file(project_root, "qmake") then
        return "qmake"
    elseif project_has_build_file(project_root, "xmake") then
        return "xmake"
    end

    return nil
end

function M.xmake_mode(build_type)
    local s = tostring(build_type or "Debug"):lower()
    if s == "relwithdebinfo" or s == "releasedbg" then
        return "releasedbg"
    elseif s == "minsizerel" then
        return "minsizerel"
    elseif s:find("release", 1, true) and not s:find("debug", 1, true) then
        return "release"
    end
    return "debug"
end

function M.xmake_build_argv(xmake_path, project_root, build_type)
    return { xmake_path, "-P", project_root, "-m", M.xmake_mode(build_type), "-y" }
end

function M.xmake_clean_argv(xmake_path, project_root)
    return { xmake_path, "-P", project_root, "clean", "-y" }
end

function M.xmake_install_argv(xmake_path, project_root, prefix)
    local cmd = { xmake_path, "-P", project_root, "install", "-y" }
    if prefix and prefix ~= "" then
        table.insert(cmd, "-o")
        table.insert(cmd, prefix)
    end
    return cmd
end

function M.xmake_run_argv(xmake_path, project_root, build_type)
    return { xmake_path, "-P", project_root, "-m", M.xmake_mode(build_type), "run", "-y" }
end

function M.cmake_clean_argv(cmake_path, build_dir)
    return { cmake_path, "--build", build_dir, "--target", "clean" }
end

function M.build_project(build_type, opts)
    build_type = build_type or "Debug"
    opts = opts or {}

    M._last_build_type = build_type
    
    vim.schedule(function()
        local build_system = M.detect_build_system()
        if not build_system then
            vim.notify("❌ No build system detected (CMakeLists.txt, *.pro, or xmake.lua)", vim.log.levels.ERROR)
            if opts.on_failure then
                opts.on_failure(-1)
            end
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
            M.build_with_cmake_async(project_root, build_dir, build_type, opts)
        elseif build_system == "qmake" then
            M.build_with_qmake_async(project_root, build_dir, opts)
        elseif build_system == "xmake" then
            M.build_with_xmake_async(project_root, build_type, opts)
        end
    end)
    
    return true
end

local function ensure_dir(path)
    local file_manager = require('qt-assistant.file_manager')
    local ok, err = file_manager.ensure_directory_exists(path)
    return ok, err
end

local function get_export_root(project_root)
    local cfg = get_config()
    local dir = (cfg.export and cfg.export.dir) or 'export'
    local project_name = vim.fn.fnamemodify(project_root, ":t")
    return project_root .. "/" .. dir .. "/" .. project_name
end

local function run_qt_deploy_if_available(target_path, build_type)
    local system = require('qt-assistant.system')
    local cfg = get_config()
    if not (cfg.export and cfg.export.deploy_qt) then
        return true
    end

    local os_type = system.get_os()

    if os_type == 'windows' then
        local function normalize_glob_path(p)
            return tostring(p or ''):gsub('\\', '/')
        end

        local function safe_isdir(p)
            return p and p ~= '' and vim.fn.isdirectory(p) == 1
        end

        local function is_debug_build(bt)
            local s = tostring(bt or ''):lower()
            return s == 'debug' or s:find('debug', 1, true) ~= nil
        end

        local function fallback_copy_adjacent_dlls(export_exe_path, bt)
            local file_manager = require('qt-assistant.file_manager')
            local project_root = get_config().project_root
            local build_root = project_root .. '/build'

            local export_bin = vim.fn.fnamemodify(export_exe_path, ':h')
            if not export_bin or export_bin == '' then
                return false, 'invalid export bin dir'
            end

            local config_name = is_debug_build(bt) and 'Debug' or 'Release'
            -- Common CMake layouts (VS multi-config, Ninja multi-config, custom)
            local candidates = {
                build_root .. '/bin/' .. config_name,
                build_root .. '/bin',
                build_root .. '/' .. config_name .. '/bin',
                build_root .. '/' .. config_name,
                -- Some users configure runtime output under build/bin/<cfg>/<arch>/...
                build_root .. '/bin/' .. config_name .. '/x64',
                build_root .. '/bin/' .. config_name .. '/Win32',
            }

            local copied = 0
            local searched = 0
            local seen_src = {}

            for _, dir in ipairs(candidates) do
                if safe_isdir(dir) then
                    searched = searched + 1
                    local dlls = vim.fn.glob(normalize_glob_path(dir) .. '/*.dll', false, true)
                    if type(dlls) == 'table' and #dlls > 0 then
                        for _, src in ipairs(dlls) do
                            local src_key = normalize_glob_path(src):lower()
                            if not seen_src[src_key] then
                                seen_src[src_key] = true
                                local name = vim.fn.fnamemodify(src, ':t')
                                local dst = export_bin .. '/' .. name
                                if not file_manager.file_exists(dst) then
                                    local ok = file_manager.copy_file(src, dst)
                                    if ok then
                                        copied = copied + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if copied > 0 then
                vim.notify('🧩 Fallback: copied ' .. tostring(copied) .. ' DLL(s) into export/bin', vim.log.levels.WARN)
                return true
            end

            if searched == 0 then
                return false, 'no candidate build bin directories found'
            end
            return false, 'no DLLs found in build bin directories'
        end

        local windeployqt = system.find_qt_tool('windeployqt')
        if not windeployqt then
            vim.notify("⚠️  windeployqt not found; skip Qt DLL deployment", vim.log.levels.WARN)
            return false
        end

        local function normalize_slash(p)
            return tostring(p or ''):gsub('\\', '/')
        end

        local function normalize_os_path(p)
            if not p or p == '' then
                return p
            end
            return system.normalize_path(p)
        end

        local function derive_vcpkg_bins_from_tool(tool_path)
            local norm = normalize_slash(tool_path)
            -- vcpkg Qt layout: <VCPKG_ROOT>/installed/<triplet>/tools/<port>/bin/windeployqt.exe
            local installed_triplet = norm:match('^(.*)/tools/')
            if not installed_triplet then
                return nil
            end
            if not installed_triplet:match('/installed/[^/]+$') then
                return nil
            end
            return normalize_os_path(installed_triplet .. '/bin'), normalize_os_path(installed_triplet .. '/debug/bin')
        end

        local function prepend_path(existing, paths)
            local sep = ';'
            local parts = {}
            local seen = {}
            for _, p in ipairs(paths or {}) do
                if p and p ~= '' then
                    local key = normalize_slash(p):lower()
                    if not seen[key] then
                        seen[key] = true
                        table.insert(parts, p)
                    end
                end
            end
            if existing and existing ~= '' then
                table.insert(parts, existing)
            end
            return table.concat(parts, sep)
        end

        local debug_build = is_debug_build(build_type or M._last_build_type)
        local extra_paths = {}
        local windeployqt_dir = normalize_os_path(vim.fn.fnamemodify(windeployqt, ':h'))
        if windeployqt_dir and windeployqt_dir ~= '' then
            table.insert(extra_paths, windeployqt_dir)
        end

        local vcpkg_release_bin, vcpkg_debug_bin = derive_vcpkg_bins_from_tool(windeployqt)
        if vcpkg_release_bin and vcpkg_debug_bin then
            -- Ensure windeployqt can load Qt DLLs and can discover the right Qt runtime.
            -- Prefer debug/bin for Debug builds, but keep both as fallback.
            if debug_build then
                table.insert(extra_paths, vcpkg_debug_bin)
                table.insert(extra_paths, vcpkg_release_bin)
            else
                table.insert(extra_paths, vcpkg_release_bin)
                table.insert(extra_paths, vcpkg_debug_bin)
            end
            vim.notify('ℹ️  Detected vcpkg Qt; extending PATH for windeployqt', vim.log.levels.INFO)
        end

        local args = { windeployqt, '--no-translations' }
        if debug_build then
            table.insert(args, '--debug')
        else
            table.insert(args, '--release')
        end
        if cfg.export.deploy_compiler_runtime then
            table.insert(args, '--compiler-runtime')
        end
        table.insert(args, target_path)

        local target_dir = vim.fn.fnamemodify(target_path, ':h')
        vim.notify("📦 Deploying Qt runtime via: " .. tostring(windeployqt), vim.log.levels.INFO)
        vim.notify("📦 Target: " .. vim.fn.fnamemodify(target_path, ':t'), vim.log.levels.INFO)
        local job_env = nil
        if #extra_paths > 0 then
            -- On Windows, some runtimes/tools rely on SYSTEMROOT/TEMP/etc.
            -- `environ()` gives us a full env snapshot; then we override PATH.
            job_env = vim.fn.environ()

            -- Windows env keys are case-insensitive, but Neovim's env table can
            -- preserve casing (commonly "Path"). Set both to be safe.
            local base_path = vim.env.PATH or vim.env.Path or job_env.PATH or job_env.Path or ''
            local new_path = prepend_path(base_path, extra_paths)
            job_env.PATH = new_path
            job_env.Path = new_path
        end

        vim.fn.jobstart(args, {
            cwd = target_dir,
            env = job_env,
            on_stdout = function(_, data)
                if data and #data > 0 then
                    for _, line in ipairs(data) do
                        if line and line ~= '' and not line:match('^%s*$') then
                            vim.schedule(function()
                                -- windeployqt reports most useful info on stdout
                                vim.notify("windeployqt: " .. line, vim.log.levels.INFO)
                            end)
                        end
                    end
                end
            end,
            on_stderr = function(_, data)
                if data and #data > 0 then
                    for _, line in ipairs(data) do
                        if line and line ~= '' and not line:match('^%s*$') then
                            vim.schedule(function()
                                vim.notify("windeployqt: " .. line, vim.log.levels.WARN)
                            end)
                        end
                    end
                end
            end,
            on_exit = function(_, code)
                vim.schedule(function()
                    if code == 0 then
                        vim.notify("✅ windeployqt completed", vim.log.levels.INFO)
                    else
                        vim.notify("❌ windeployqt failed (exit code: " .. tostring(code) .. ")", vim.log.levels.ERROR)
                        local ok_fallback, why = fallback_copy_adjacent_dlls(target_path, build_type or M._last_build_type)
                        if not ok_fallback and why and why ~= '' then
                            vim.notify('⚠️  Fallback DLL copy skipped: ' .. tostring(why), vim.log.levels.WARN)
                        end
                    end
                end)
            end,
        })
        return true
    end

    if os_type == 'macos' then
        local macdeployqt = system.find_qt_tool('macdeployqt')
        if not macdeployqt then
            vim.notify("⚠️  macdeployqt not found; skip macOS Qt deployment", vim.log.levels.WARN)
            return false
        end

        -- macdeployqt expects an .app bundle. If a plain executable is provided, warn and skip.
        if not tostring(target_path):match('%.app$') then
            vim.notify("⚠️  macdeployqt expects a .app bundle; skip: " .. vim.fn.fnamemodify(target_path, ':t'), vim.log.levels.WARN)
            return false
        end

        local args = { macdeployqt, target_path }
        vim.notify("📦 Deploying Qt runtime: " .. vim.fn.fnamemodify(target_path, ':t'), vim.log.levels.INFO)
        vim.fn.jobstart(args, {
            on_stderr = function(_, data)
                if data and #data > 0 then
                    for _, line in ipairs(data) do
                        if line and line ~= '' and not line:match('^%s*$') then
                            vim.schedule(function()
                                vim.notify("macdeployqt: " .. line, vim.log.levels.WARN)
                            end)
                        end
                    end
                end
            end,
        })
        return true
    end

    -- Linux: linuxdeployqt is not part of Qt; run it only if available.
    if os_type == 'linux' then
        local linuxdeployqt = system.find_executable('linuxdeployqt')
        if not linuxdeployqt then
            -- Best-effort: rely on system Qt runtime / package manager.
            return false
        end

        local args = { linuxdeployqt, target_path, '-no-translations' }
        vim.notify("📦 Deploying Qt runtime: " .. vim.fn.fnamemodify(target_path, ':t'), vim.log.levels.INFO)
        vim.fn.jobstart(args, {
            on_stderr = function(_, data)
                if data and #data > 0 then
                    for _, line in ipairs(data) do
                        if line and line ~= '' and not line:match('^%s*$') then
                            vim.schedule(function()
                                vim.notify("linuxdeployqt: " .. line, vim.log.levels.WARN)
                            end)
                        end
                    end
                end
            end,
        })
        return true
    end

    return false
end

local function export_after_cmake_build(project_root, build_dir, build_type)
    local cfg = get_config()
    if not (cfg.export and cfg.export.enabled) then
        return
    end

    local system = require('qt-assistant.system')
    local cmake_path = system.find_executable('cmake')
    if not cmake_path then
        vim.notify('❌ CMake not found. Cannot export build artifacts.', vim.log.levels.ERROR)
        return
    end

    local export_root = get_export_root(project_root)
    local ok, err = ensure_dir(export_root)
    if not ok then
        vim.notify('❌ Failed to create export directory: ' .. tostring(err), vim.log.levels.ERROR)
        return
    end

    local cmd = { cmake_path, '--install', build_dir }
    table.insert(cmd, '--prefix')
    table.insert(cmd, export_root)
    table.insert(cmd, '--config')
    table.insert(cmd, build_type or 'Release')

    vim.notify('📤 Exporting to: ' .. export_root, vim.log.levels.INFO)
    vim.fn.jobstart(cmd, {
        cwd = project_root,
        on_stderr = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line and line ~= '' and not line:match('^%s*$') then
                        vim.schedule(function()
                            vim.notify('Export: ' .. line, vim.log.levels.WARN)
                        end)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code ~= 0 then
                    vim.notify('❌ Export failed (exit code: ' .. exit_code .. ')', vim.log.levels.ERROR)
                    return
                end

                vim.notify('✅ Export completed', vim.log.levels.INFO)

                -- Deploy Qt DLLs on Windows
                local file_manager = require('qt-assistant.file_manager')
                local project_name = vim.fn.fnamemodify(project_root, ":t")
                local bin_dir = export_root .. '/bin'
                local exe_suffix = (system.get_os() == 'windows') and '.exe' or ''

                -- Many templates set DEBUG_POSTFIX to "d". When building Debug with multi-config
                -- generators, the exported binaries are typically <name>d.exe. Best-effort: probe
                -- both without/with the postfix.
                local function resolve_executable(base_name)
                    local candidates = {
                        bin_dir .. '/' .. base_name .. exe_suffix,
                        bin_dir .. '/' .. base_name .. 'd' .. exe_suffix,
                    }
                    for _, p in ipairs(candidates) do
                        if file_manager.file_exists(p) then
                            return p
                        end
                    end
                    return nil
                end

                -- Prefer deploying bundles on macOS when they exist.
                local main_target = resolve_executable(project_name)
                if system.get_os() == 'macos' then
                    local main_app = bin_dir .. '/' .. project_name .. '.app'
                    if vim.fn.isdirectory(main_app) == 1 then
                        main_target = main_app
                    end
                end
                if main_target and (file_manager.file_exists(main_target) or vim.fn.isdirectory(main_target) == 1) then
                    run_qt_deploy_if_available(main_target, build_type)
                end

                if cfg.export.include_tests then
                    local tests_target = resolve_executable(project_name .. '_tests')
                    if tests_target then
                        run_qt_deploy_if_available(tests_target, build_type)
                    end
                end

                if cfg.export.include_demo then
                    local demo_target = resolve_executable(project_name .. '_demo')
                    if demo_target then
                        run_qt_deploy_if_available(demo_target, build_type)
                    end
                end
            end)
        end
    })
end

-- Install project (CMake and xmake)
function M.install_project(prefix)
    vim.schedule(function()
        local build_system = M.detect_build_system()
        local project_root = get_config().project_root
        local system = require('qt-assistant.system')

        if build_system == "xmake" then
            local xmake_path = system.find_executable("xmake")
            if not xmake_path then
                vim.notify("❌ xmake not found. Install it from https://xmake.io", vim.log.levels.ERROR)
                return
            end
            local cmd = M.xmake_install_argv(xmake_path, project_root, prefix)
            vim.notify("📦 Installing project with xmake...", vim.log.levels.INFO)
            vim.fn.jobstart(cmd, {
                cwd = project_root,
                on_exit = function(_, exit_code)
                    vim.schedule(function()
                        if exit_code == 0 then
                            vim.notify("✅ Install completed", vim.log.levels.INFO)
                        else
                            vim.notify("❌ Install failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                        end
                    end)
                end
            })
            return
        end

        if build_system ~= "cmake" then
            vim.notify("❌ Install is supported for CMake and xmake projects", vim.log.levels.ERROR)
            return
        end

        local build_dir = project_root .. "/build"
        if vim.fn.isdirectory(build_dir) ~= 1 then
            vim.notify("❌ Build directory not found. Please run :QtBuild first.", vim.log.levels.ERROR)
            return
        end

        local cmake_path = system.find_executable("cmake")
        if not cmake_path then
            vim.notify("❌ CMake not found. Please install CMake.", vim.log.levels.ERROR)
            return
        end

        local cmd = { cmake_path, "--install", build_dir }
        local build_type = M._last_build_type or "Release"
        table.insert(cmd, "--config")
        table.insert(cmd, build_type)

        if prefix and prefix ~= "" then
            table.insert(cmd, "--prefix")
            table.insert(cmd, prefix)
        end

        vim.notify("📦 Installing project...", vim.log.levels.INFO)

        vim.fn.jobstart(cmd, {
            cwd = project_root,
            on_stderr = function(_, data)
                if data and #data > 0 then
                    for _, line in ipairs(data) do
                        if line and line ~= "" and not line:match("^%s*$") then
                            vim.schedule(function()
                                vim.notify("Install: " .. line, vim.log.levels.WARN)
                            end)
                        end
                    end
                end
            end,
            on_exit = function(_, exit_code)
                vim.schedule(function()
                    if exit_code == 0 then
                        vim.notify("✅ Install completed", vim.log.levels.INFO)
                    else
                        vim.notify("❌ Install failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    end
                end)
            end
        })
    end)
end

-- Package project (CMake + CPack only)
function M.package_project()
    vim.schedule(function()
        local build_system = M.detect_build_system()
        local project_root = get_config().project_root
        local build_dir = project_root .. "/build"
        if vim.fn.isdirectory(build_dir) ~= 1 then
            vim.notify("❌ Build directory not found. Please run :QtBuild first.", vim.log.levels.ERROR)
            return
        end

        if build_system == "cmake" then
            local system = require('qt-assistant.system')
            local cmake_path = system.find_executable("cmake")
            if not cmake_path then
                vim.notify("❌ CMake not found. Please install CMake.", vim.log.levels.ERROR)
                return
            end

            local build_type = M._last_build_type or "Release"
            local cmd = { cmake_path, "--build", build_dir, "--target", "package" }
            table.insert(cmd, "--config")
            table.insert(cmd, build_type)

            vim.notify("📦 Packaging project (CPack)...", vim.log.levels.INFO)

            vim.fn.jobstart(cmd, {
                cwd = project_root,
                on_stderr = function(_, data)
                    if data and #data > 0 then
                        for _, line in ipairs(data) do
                            if line and line ~= "" and not line:match("^%s*$") then
                                vim.schedule(function()
                                    vim.notify("Package: " .. line, vim.log.levels.WARN)
                                end)
                            end
                        end
                    end
                end,
                on_exit = function(_, exit_code)
                    vim.schedule(function()
                        if exit_code == 0 then
                            vim.notify("✅ Package completed", vim.log.levels.INFO)
                        else
                            vim.notify("❌ Package failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                        end
                    end)
                end
            })

            return
        end

        if build_system == "qmake" then
            local system = require('qt-assistant.system')
            local project_name = vim.fn.fnamemodify(project_root, ":t")
            local zip_path = build_dir .. "/" .. project_name .. ".zip"

            local function escape_ps_single_quotes(s)
                return tostring(s):gsub("'", "''")
            end

            if system.get_os() == 'windows' then
                local pwsh = system.find_executable('pwsh') or system.find_executable('powershell')
                if not pwsh then
                    vim.notify("❌ PowerShell not found (pwsh/powershell). Cannot create ZIP.", vim.log.levels.ERROR)
                    return
                end

                local build_dir_escaped = escape_ps_single_quotes(build_dir)
                local zip_path_escaped = escape_ps_single_quotes(zip_path)
                local ps_cmd = "Compress-Archive -Path (Join-Path '" .. build_dir_escaped .. "' '*') -DestinationPath '" .. zip_path_escaped .. "' -Force"
                local cmd = { pwsh, "-NoProfile", "-NonInteractive", "-Command", ps_cmd }

                vim.notify("📦 Packaging project (ZIP)...", vim.log.levels.INFO)
                vim.fn.jobstart(cmd, {
                    cwd = project_root,
                    on_stderr = function(_, data)
                        if data and #data > 0 then
                            for _, line in ipairs(data) do
                                if line and line ~= "" and not line:match("^%s*$") then
                                    vim.schedule(function()
                                        vim.notify("Package: " .. line, vim.log.levels.WARN)
                                    end)
                                end
                            end
                        end
                    end,
                    on_exit = function(_, exit_code)
                        vim.schedule(function()
                            if exit_code == 0 then
                                vim.notify("✅ ZIP created: " .. zip_path, vim.log.levels.INFO)
                            else
                                vim.notify("❌ ZIP failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                            end
                        end)
                    end
                })

                return
            end

            local zip_exe = system.find_executable('zip')
            if not zip_exe then
                vim.notify("❌ 'zip' not found. Please install zip to package qmake builds.", vim.log.levels.ERROR)
                return
            end

            local cmd = { zip_exe, "-r", zip_path, "." }
            vim.notify("📦 Packaging project (ZIP)...", vim.log.levels.INFO)
            vim.fn.jobstart(cmd, {
                cwd = build_dir,
                on_stderr = function(_, data)
                    if data and #data > 0 then
                        for _, line in ipairs(data) do
                            if line and line ~= "" and not line:match("^%s*$") then
                                vim.schedule(function()
                                    vim.notify("Package: " .. line, vim.log.levels.WARN)
                                end)
                            end
                        end
                    end
                end,
                on_exit = function(_, exit_code)
                    vim.schedule(function()
                        if exit_code == 0 then
                            vim.notify("✅ ZIP created: " .. zip_path, vim.log.levels.INFO)
                        else
                            vim.notify("❌ ZIP failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                        end
                    end)
                end
            })

            return
        end

        if build_system == "xmake" then
            vim.notify("QtPackage does not invent an xmake pack spec. Add pack rules to xmake.lua, or package CMake projects with CPack.", vim.log.levels.WARN)
            return
        end

        vim.notify("❌ No build system detected (CMakeLists.txt, *.pro, or xmake.lua)", vim.log.levels.ERROR)
    end)
end

-- Build with CMake (async)
function M.build_with_cmake_async(project_root, build_dir, build_type, opts)
    local system = require('qt-assistant.system')
    local cmake_path = system.find_executable("cmake")
    
    if not cmake_path then
        vim.notify("❌ CMake not found. Please install CMake.", vim.log.levels.ERROR)
        if opts and opts.on_failure then
            opts.on_failure(-1)
        end
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
    
    -- Add vcpkg toolchain file if enabled
    local config = get_config()
    if config.vcpkg and config.vcpkg.enabled then
        local vcpkg_toolchain = require('qt-assistant.config').get_vcpkg_toolchain_file()
        if vcpkg_toolchain then
            table.insert(configure_cmd, "-DCMAKE_TOOLCHAIN_FILE=" .. vcpkg_toolchain)
            vim.notify("🔧 Using vcpkg toolchain: " .. vcpkg_toolchain, vim.log.levels.INFO)
        else
            vim.notify("⚠️  vcpkg enabled but toolchain file not found", vim.log.levels.WARN)
        end
    end
    
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
                    M.start_cmake_build(cmake_path, project_root, build_dir, build_type, opts)
                else
                    vim.notify("❌ CMake configure failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    if opts and opts.on_failure then
                        opts.on_failure(exit_code)
                    end
                end
            end)
        end
    })
end

-- Start CMake build step
function M.start_cmake_build(cmake_path, project_root, build_dir, build_type, opts)
    local build_cmd = { cmake_path, "--build", build_dir }

    -- For multi-config generators (Visual Studio, Xcode, Ninja Multi-Config), passing --config is required.
    -- It's harmless/ignored for most single-config generators.
    if build_type and tostring(build_type) ~= "" then
        table.insert(build_cmd, "--config")
        table.insert(build_cmd, build_type)
    end

    table.insert(build_cmd, "--parallel")
    
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
                    export_after_cmake_build(project_root, build_dir, build_type)
                    if opts and opts.on_success then
                        opts.on_success()
                    end
                else
                    vim.notify("❌ Build failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    if opts and opts.on_failure then
                        opts.on_failure(exit_code)
                    end
                end
            end)
        end
    })
end

-- Build with qmake (async)
function M.build_with_qmake_async(project_root, build_dir, opts)
    local system = require('qt-assistant.system')
    local qmake_path = system.find_qt_tool("qmake")
    
    if not qmake_path then
        vim.notify("❌ qmake not found. Please install Qt development tools.", vim.log.levels.ERROR)
        if opts and opts.on_failure then
            opts.on_failure(-1)
        end
        return
    end
    
    -- Find .pro file
    local pro_files = vim.fn.glob(project_root .. "/*.pro", false, true)
    if #pro_files == 0 then
        vim.notify("❌ No .pro file found", vim.log.levels.ERROR)
        if opts and opts.on_failure then
            opts.on_failure(-1)
        end
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
                    M.start_make_build(project_root, build_dir, opts)
                else
                    vim.notify("❌ qmake failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    if opts and opts.on_failure then
                        opts.on_failure(exit_code)
                    end
                end
            end)
        end
    })
end

-- Start make build
function M.start_make_build(project_root, build_dir, opts)
    local system = require('qt-assistant.system')
    local make_tool = system.find_executable('mingw32-make')
        or system.find_executable('nmake')
        or system.find_executable('make')

    if not make_tool then
        vim.notify("❌ No make tool found (mingw32-make/nmake/make)", vim.log.levels.ERROR)
        if opts and opts.on_failure then
            opts.on_failure(-1)
        end
        return
    end

    local make_cmd
    if make_tool:lower():find('nmake') then
        -- nmake does not support -j, keep invocation simple
        make_cmd = {make_tool}
    else
        make_cmd = {make_tool, "-j4"}
    end

    vim.notify("🔨 Building with " .. vim.fn.fnamemodify(make_tool, ':t') .. "...", vim.log.levels.INFO)
    
    vim.fn.jobstart(make_cmd, {
        cwd = build_dir,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("🎉 Build completed successfully!", vim.log.levels.INFO)

                    -- Best-effort export for qmake builds: copy main exe to export/bin and deploy Qt runtime on Windows.
                    local cfg = get_config()
                    if cfg.export and cfg.export.enabled then
                        local export_root = get_export_root(project_root)
                        ensure_dir(export_root .. '/bin')
                        local project_name = vim.fn.fnamemodify(project_root, ":t")
                        local exe_suffix = (system.get_os() == 'windows') and '.exe' or ''
                        local src_exe = build_dir .. '/' .. project_name .. exe_suffix
                        local dst_exe = export_root .. '/bin/' .. project_name .. exe_suffix

                        local file_manager = require('qt-assistant.file_manager')
                        if file_manager.file_exists(src_exe) then
                            file_manager.copy_file(src_exe, dst_exe)
                            vim.notify('📤 Exported executable to: ' .. dst_exe, vim.log.levels.INFO)
                            run_qt_deploy_if_available(dst_exe)
                        else
                            vim.notify('⚠️  qmake build succeeded but executable not found for export: ' .. src_exe, vim.log.levels.WARN)
                        end
                    end
                    if opts and opts.on_success then
                        opts.on_success()
                    end
                else
                    vim.notify("❌ Build failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    if opts and opts.on_failure then
                        opts.on_failure(exit_code)
                    end
                end
            end)
        end
    })
end

local function run_in_terminal(argv)
    local rendered = table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
    vim.cmd("split")
    vim.cmd("terminal " .. rendered)
end

-- Run project (async)
function M.run_project()
    vim.schedule(function()
        local project_root = get_config().project_root
        local system = require('qt-assistant.system')
        local build_system = M.detect_build_system()
        local exe_path = M.find_project_executable(M._last_build_type)

        if exe_path then
            vim.notify("▶️  Running: " .. vim.fn.fnamemodify(exe_path, ":t"), vim.log.levels.INFO)
            run_in_terminal({ exe_path })
            return
        end

        if build_system == "xmake" then
            local xmake_path = system.find_executable("xmake")
            if not xmake_path then
                vim.notify("❌ xmake not found. Install it from https://xmake.io", vim.log.levels.ERROR)
                return
            end
            vim.notify("▶️  Running via xmake", vim.log.levels.INFO)
            run_in_terminal(M.xmake_run_argv(xmake_path, project_root, M._last_build_type))
            return
        end

        vim.notify("❌ Executable not found. Please build the project first.", vim.log.levels.ERROR)
    end)
end

function M.xmake_target_names(project_root)
    project_root = project_root or get_config().project_root
    local path = project_root .. "/xmake.lua"
    if vim.fn.filereadable(path) ~= 1 then
        return {}
    end
    local content = table.concat(vim.fn.readfile(path), "\n")
    local names = {}
    local seen = {}
    local function add(name)
        if name and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end
    for name in content:gmatch('target%s*%(%s*"([^"]+)"') do
        add(name)
    end
    for name in content:gmatch("target%s*%(%s*'([^']+)'") do
        add(name)
    end
    return names
end

function M.find_project_executable(build_type)
    local root = get_config().project_root
    local system = require('qt-assistant.system')
    local names = { vim.fn.fnamemodify(root, ":t") }
    for _, target in ipairs(M.xmake_target_names(root)) do
        table.insert(names, target)
    end

    local exe_suffix = system.get_os() == "windows" and ".exe" or ""
    local build_dir = root .. "/build"
    local mode = M.xmake_mode(build_type or M._last_build_type)
    local os_dir = ({ windows = "windows", macos = "macosx", linux = "linux" })[system.get_os()] or "linux"
    local archs = { "x86_64", "arm64", "i386", "aarch64", "x64" }
    local modes = { mode, "debug", "release", "releasedbg" }

    local function exists(path)
        return vim.fn.filereadable(path) == 1 or vim.fn.executable(path) == 1
    end

    local seen = {}
    for _, name in ipairs(names) do
        if not seen[name] then
            seen[name] = true
            local exe = name .. exe_suffix
            local candidates = {
                build_dir .. "/" .. exe,
                build_dir .. "/Debug/" .. exe,
                build_dir .. "/Release/" .. exe,
                build_dir .. "/RelWithDebInfo/" .. exe,
                build_dir .. "/bin/" .. exe,
                build_dir .. "/bin/Debug/" .. exe,
                build_dir .. "/bin/Release/" .. exe,
            }
            for _, arch in ipairs(archs) do
                for _, m in ipairs(modes) do
                    table.insert(candidates, string.format("%s/%s/%s/%s/%s", build_dir, os_dir, arch, m, exe))
                end
            end
            for _, path in ipairs(candidates) do
                if exists(path) then
                    return path
                end
            end
            local matches = vim.fn.glob(build_dir .. "/**/" .. exe, false, true)
            if type(matches) == "table" then
                for _, path in ipairs(matches) do
                    if exists(path) then
                        return path
                    end
                end
            end
        end
    end
    return nil
end

function M.build_with_xmake_async(project_root, build_type, opts)
    opts = opts or {}
    local system = require('qt-assistant.system')
    local xmake_path = system.find_executable("xmake")
    if not xmake_path then
        vim.notify("❌ xmake not found. Install it from https://xmake.io", vim.log.levels.ERROR)
        if opts.on_failure then
            opts.on_failure(-1)
        end
        return
    end

    local cmd = M.xmake_build_argv(xmake_path, project_root, build_type)
    vim.notify("⚙️  Building with xmake (" .. M.xmake_mode(build_type) .. ")...", vim.log.levels.INFO)
    vim.fn.jobstart(cmd, {
        cwd = project_root,
        on_stderr = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line and line ~= "" and not line:match("^%s*$") then
                        vim.schedule(function()
                            vim.notify("xmake: " .. line, vim.log.levels.WARN)
                        end)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("🎉 Build completed successfully!", vim.log.levels.INFO)
                    if opts.on_success then
                        opts.on_success()
                    end
                else
                    vim.notify("❌ xmake build failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    if opts.on_failure then
                        opts.on_failure(exit_code)
                    end
                end
            end)
        end
    })
end

function M.clean_project()
    vim.schedule(function()
        local system = require('qt-assistant.system')
        local build_system = M.detect_build_system()
        local project_root = get_config().project_root
        local build_dir = project_root .. "/build"
        if not build_system then
            vim.notify("❌ No build system detected (CMakeLists.txt, *.pro, or xmake.lua)", vim.log.levels.ERROR)
            return
        end

        local cmd, cwd
        if build_system == "cmake" then
            local cmake_path = system.find_executable("cmake")
            if not cmake_path then
                vim.notify("❌ CMake not found. Please install CMake.", vim.log.levels.ERROR)
                return
            end
            if vim.fn.isdirectory(build_dir) ~= 1 then
                vim.notify("Nothing to clean (no build directory).", vim.log.levels.INFO)
                return
            end
            cmd = M.cmake_clean_argv(cmake_path, build_dir)
            cwd = project_root
        elseif build_system == "qmake" then
            local make_tool = system.find_executable("mingw32-make")
                or system.find_executable("nmake")
                or system.find_executable("make")
            if not make_tool then
                vim.notify("❌ No make tool found to clean the qmake build.", vim.log.levels.ERROR)
                return
            end
            if vim.fn.filereadable(build_dir .. "/Makefile") ~= 1
                and vim.fn.filereadable(build_dir .. "/Makefile.Release") ~= 1
                and vim.fn.filereadable(build_dir .. "/Makefile.Debug") ~= 1 then
                vim.notify("Nothing to clean (no qmake Makefile).", vim.log.levels.INFO)
                return
            end
            cmd = { make_tool, "clean" }
            cwd = build_dir
        else
            local xmake_path = system.find_executable("xmake")
            if not xmake_path then
                vim.notify("❌ xmake not found. Install it from https://xmake.io", vim.log.levels.ERROR)
                return
            end
            cmd = M.xmake_clean_argv(xmake_path, project_root)
            cwd = project_root
        end

        vim.notify("🧹 Cleaning project (" .. build_system .. ")...", vim.log.levels.INFO)
        vim.fn.jobstart(cmd, {
            cwd = cwd,
            on_exit = function(_, exit_code)
                vim.schedule(function()
                    if exit_code == 0 then
                        vim.notify("✅ Clean completed", vim.log.levels.INFO)
                    else
                        vim.notify("❌ Clean failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    end
                end)
            end
        })
    end)
end

function M.show_build_status()
    local project_root = get_config().project_root
    local build_system = M.detect_build_system() or "none"
    local exe = M.find_project_executable()
    local lines = {
        "Qt build status",
        "Project: " .. project_root,
        "Build system: " .. build_system,
        "Last build type: " .. tostring(M._last_build_type or "n/a"),
        "Build directory: " .. project_root .. "/build",
        "Executable: " .. (exe or "not found"),
    }
    require("qt-assistant.ui").show_info_window(lines)
    return lines
end

return M
