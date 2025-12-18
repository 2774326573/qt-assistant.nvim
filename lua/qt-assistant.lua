-- Neovim Qt Assistant Plugin - Core Module
-- Qt项目辅助插件主模块

local M = {}

-- Configuration
M._config = nil

-- Initialize plugin
function M.setup(user_config)
	-- Use the dedicated config module for centralized configuration
	local config = require('qt-assistant.config')
	M._config = config.setup(user_config or {})

	-- Setup keymaps if enabled
	if M._config.enable_default_keymaps then
		M.setup_keymaps()
	end
	
	-- Initialize debug integration (lazy)
	vim.schedule(function()
		local debug_ok, debug = pcall(require, 'qt-assistant.debug')
		if debug_ok then
			debug.init()
		end
	end)
	
end

-- Get configuration
function M.get_config()
	if not M._config then
		local config = require('qt-assistant.config')
		M._config = config.get()
	end
	return M._config
end

-- Setup optimized keymaps for quick development
function M.setup_keymaps()
	local map = vim.keymap.set
	local config = require('qt-assistant.config').get()
	local preset = (config.keymaps and config.keymaps.preset) or 'minimal'
	preset = tostring(preset):lower()

	-- Core Qt commands (essential workflow)
	map("n", "<leader>qa", function() M.show_main_interface() end, { desc = "Qt Assistant" })
	map("n", "<leader>qh", function() M.show_help() end, { desc = "Qt Help" })
	
	-- Project management (quick access)
	map("n", "<leader>qp", function() M.new_project_interactive() end, { desc = "New Qt Project (Interactive)" })
	if preset == 'full' then
		map("n", "<leader>qP", function() M.new_project_quick() end, { desc = "New Qt Project (Quick C++17)" })
	end
	map("n", "<leader>qo", function() M.open_project_interactive() end, { desc = "Open Qt Project" })
	
	-- UI Designer (rapid UI development)
	map("n", "<leader>qd", function() M.open_designer() end, { desc = "Qt Designer" })
	map("n", "<leader>qu", function() M.create_new_ui_interactive() end, { desc = "New UI File" })
	map("n", "<leader>qe", function() 
		local current_file = vim.fn.expand('%:p')
		if current_file:match("%.ui$") then
			M.open_designer(current_file)
		else
			local designer = require("qt-assistant.designer")
			designer.select_ui_file_to_open()
		end
	end, { desc = "Edit Current/Select UI" })
	
	-- Class creation (smart class generation)
	map("n", "<leader>qc", function() M.create_class_interactive() end, { desc = "Create Qt Class" })
	map("n", "<leader>qf", function() M.create_class_from_current_ui() end, { desc = "Create Class from Current UI" })
	
	-- Build system (fast build & run)
	map("n", "<leader>qb", function() M.build_project() end, { desc = "Build Project" })
	map("n", "<leader>qr", function() M.run_project() end, { desc = "Run Project" })
	if preset == 'full' then
		-- Quick build+run is convenient but <leader>qq is commonly mapped to quit; avoid conflicts.
		map("n", "<leader>qA", function() M.quick_build_and_run() end, { desc = "Quick Build & Run" })
	end
	
	-- C++ Standard specific builds (Windows)
	if preset == 'full' then
		map("n", "<leader>qb1", function() M.build_with_std("11") end, { desc = "Build with C++11" })
		map("n", "<leader>qb4", function() M.build_with_std("14") end, { desc = "Build with C++14" })
		map("n", "<leader>qb7", function() M.build_with_std("17") end, { desc = "Build with C++17" })
		map("n", "<leader>qb20", function() M.build_with_std("20") end, { desc = "Build with C++20" })
	end
	
	-- Debug system (integrated debugging) - conditional loading
	map("n", "<leader>qdb", function() M.debug_application() end, { desc = "Debug Qt App" })
	map("n", "<leader>qda", function() M.attach_to_process() end, { desc = "Attach to Qt Process" })
	
	-- Configuration and Standards
	if preset == 'full' then
		map("n", "<leader>qsc", function() M.show_current_config() end, { desc = "Show Current Config" })
		map("n", "<leader>qss", function() M.select_cxx_standard() end, { desc = "Select C++ Standard" })
		map("n", "<leader>qsr", function() M.reconfigure_project() end, { desc = "Reconfigure Project" })
	end
	
	-- File-specific keymaps (context-aware)
	local function setup_ui_file_keymaps()
		local bufnr = vim.api.nvim_get_current_buf()
		local filename = vim.api.nvim_buf_get_name(bufnr)
		
		if filename:match("%.ui$") then
			-- UI file specific keymaps
			map("n", "<leader>gd", function() M.open_designer(filename) end, { buffer = bufnr, desc = "Open in Designer" })
			map("n", "<leader>gc", function() M.create_class_from_ui_file(filename) end, { buffer = bufnr, desc = "Generate Class" })
		elseif filename:match("%.h$") or filename:match("%.cpp$") then
			-- C++ file specific keymaps
			map("n", "<leader>gu", function() M.find_and_open_ui() end, { buffer = bufnr, desc = "Find & Open UI" })
		end
	end
	
	-- Auto setup file-specific keymaps
	vim.api.nvim_create_autocmd({"BufEnter", "FileType"}, {
		pattern = {"*.ui", "*.h", "*.cpp"},
		callback = setup_ui_file_keymaps
	})
end

-- Quick build and run (NF5 optimization)
function M.quick_build_and_run()
	vim.notify("🚀 Quick Build & Run...", vim.log.levels.INFO)
	
	local build_manager = require("qt-assistant.build_manager")
	
	-- Build first, then run on success
	vim.schedule(function()
		local original_notify = vim.notify
		local build_success = false
		
		-- Override notify to catch build completion
		vim.notify = function(msg, level)
			original_notify(msg, level)
			if msg:match("Build completed successfully") then
				build_success = true
				vim.schedule(function()
					vim.notify("⚡ Auto-running project...", vim.log.levels.INFO)
					build_manager.run_project()
				end)
			end
		end
		
		-- Start build
		build_manager.build_project()
		
		-- Restore original notify after 10 seconds
		vim.defer_fn(function()
			vim.notify = original_notify
		end, 10000)
	end)
end

-- Create class from current UI file
function M.create_class_from_current_ui()
	local current_file = vim.fn.expand('%:p')
	
	if not current_file:match("%.ui$") then
		vim.notify("❌ Current file is not a UI file", vim.log.levels.ERROR)
		return
	end
	
	-- Extract class name from UI file
	local designer = require("qt-assistant.designer")
	local ui_info = designer.analyze_ui_file(current_file)
	
	if ui_info.class_name and ui_info.class_name ~= "" then
		local class_type = M.determine_class_type_from_ui(ui_info)
		M.create_class_from_ui(vim.fn.fnamemodify(current_file, ":t"), ui_info.class_name)
	else
		vim.notify("❌ Could not determine class name from UI file", vim.log.levels.ERROR)
	end
end

-- Find and open corresponding UI file
function M.find_and_open_ui()
	local current_file = vim.fn.expand('%:p')
	local base_name = vim.fn.fnamemodify(current_file, ":t:r")
	
	local designer = require("qt-assistant.designer")
	local ui_files = designer.find_ui_files()
	
	-- Look for matching UI file
	for _, ui_info in ipairs(ui_files) do
		if ui_info.name == base_name or ui_info.class_name == base_name then
			M.open_designer(ui_info.path)
			return
		end
	end
	
	vim.notify("❌ No corresponding UI file found for: " .. base_name, vim.log.levels.WARN)
end

-- ==================== Core Functions ====================

-- Show main interface
function M.show_main_interface()
	local ui = require("qt-assistant.ui")
	ui.show_main_interface()
end

-- Project Management
function M.new_project_interactive()
	vim.ui.input({ prompt = 'Project name: ' }, function(name)
		if name and name ~= "" then
			local labels = {
				'Qt Widgets App',
				'Qt Quick App',
				'Console App',
				'Static Library',
				'Shared Library',
				'Plugin Module'
			}
			local types = {
				'widget_app',
				'quick_app',
				'console_app',
				'static_lib',
				'shared_lib',
				'plugin'
			}

			vim.ui.select(labels, {
				prompt = 'Select project type:'
			}, function(choice, idx)
				if not choice or not idx then
					return
				end
				local project_manager = require('qt-assistant.project_manager')
				project_manager.new_project_interactive_preset(name, types[idx])
			end)
		end
	end)
end

function M.open_project_interactive()
	local function prompt_for_path(default_path)
		vim.ui.input({
			prompt = 'Project path: ',
			default = default_path or vim.fn.getcwd(),
			completion = 'dir'
		}, function(path)
			if path and path ~= "" then
				M.open_project(path)
			end
		end)
	end

	local history = require("qt-assistant.history")
	local project_manager = require("qt-assistant.project_manager")

	local recent = history.get_recent_projects()
	local discovered = project_manager.discover_projects({ limit = 20 })

	local items = {}
	local seen = {}

	local function normalize_path(path)
		if not path or path == "" then
			return nil
		end
		local absolute = vim.fn.fnamemodify(path, ":p")
		absolute = absolute:gsub("[/\\]+$", "")
		return absolute
	end

	local function add_item(path, source_label)
		local normalized = normalize_path(path)
		if not normalized then
			return
		end
		local key = normalized:lower()
		if seen[key] then
			return
		end
		local label = normalized
		if source_label then
			label = string.format("%s (%s)", normalized, source_label)
		end
		table.insert(items, { label = label, path = normalized })
		seen[key] = true
	end

	for _, path in ipairs(recent) do
		add_item(path)
	end

	for _, path in ipairs(discovered) do
		add_item(path, "auto")
	end

	if #items == 0 then
		prompt_for_path()
		return
	end

	table.insert(items, { label = "[Browse for another project...]", path = nil })

	vim.ui.select(items, {
		prompt = 'Open Qt project:',
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end
		if choice.path then
			M.open_project(choice.path)
		else
			prompt_for_path()
		end
	end)
end

function M.new_project(name, template_type, root_dir)
	local project_manager = require("qt-assistant.project_manager")
	project_manager.new_project(name, template_type, nil, root_dir)
end

function M.open_project(path)
	local project_manager = require("qt-assistant.project_manager")
	return project_manager.open_project(path)
end

-- UI Designer Integration
function M.create_new_ui_interactive()
	vim.ui.input({ prompt = 'UI filename: ' }, function(filename)
		if not filename or filename == "" then
			return
		end

		local default_dir = vim.fs.normalize(require('qt-assistant.config').get().project_root .. "/ui")
		vim.ui.input({
			prompt = 'Target directory for UI file:',
			default = default_dir,
			completion = 'dir'
		}, function(dir_choice)
			if dir_choice == nil then
				return
			end
			local target_dir = dir_choice ~= '' and vim.fs.normalize(dir_choice) or default_dir
			M.create_new_ui(filename, target_dir)
		end)
	end)
end

function M.create_new_ui(filename, target_dir)
	local designer = require("qt-assistant.designer")
	designer.create_new_ui(filename, target_dir)
end

function M.edit_ui_file(filename)
	local designer = require("qt-assistant.designer")
	designer.edit_ui_file(filename)
end

function M.open_designer(ui_file)
	local designer = require("qt-assistant.designer")
	designer.open_designer(ui_file)
end

function M.get_ui_files_for_completion()
	local designer = require("qt-assistant.designer")
	return designer.get_ui_files_for_completion()
end

-- Class Creation
function M.create_class_interactive()
	vim.ui.input({ prompt = 'Class name: ' }, function(class_name)
		if class_name and class_name ~= "" then
			local labels = {
				'Main Window',
				'Dialog',
				'Widget',
				'Data Model',
				'Item Delegate',
				'Thread',
				'Utility',
				'Singleton'
			}
			local types = {
				'main_window',
				'dialog',
				'widget',
				'model',
				'delegate',
				'thread',
				'utility',
				'singleton'
			}

			vim.ui.select(labels, {
				prompt = 'Select class type:'
			}, function(choice, idx)
				if choice then
					M.create_class(class_name, types[idx])
				end
			end)
		end
	end)
end

function M.create_class(class_name, class_type, options)
	if not class_name or class_name == "" then
		vim.notify("Error: Class name is required", vim.log.levels.ERROR)
		return
	end

	local core = require("qt-assistant.core")
	local success, error_msg = core.create_qt_class(class_name, class_type, options or {})

	if success then
		vim.notify(string.format("Successfully created %s class: %s", class_type, class_name), vim.log.levels.INFO)
	else
		vim.notify(string.format("Error creating class: %s", error_msg), vim.log.levels.ERROR)
	end
end

function M.create_class_from_ui(ui_file, class_name)
	local core = require("qt-assistant.core")
	local designer = require("qt-assistant.designer")
	
	-- Find UI file
	local project_root = M._config.project_root
	local system = require('qt-assistant.system')
	
	local ui_file_path = nil
	if ui_file:match("^/") then
		ui_file_path = ui_file
	else
		local possible_paths = {
			system.join_path(project_root, "ui", ui_file),
			system.join_path(project_root, ui_file),
			system.join_path(vim.fn.getcwd(), ui_file)
		}
		
		for _, path in ipairs(possible_paths) do
			if vim.fn.filereadable(path) == 1 then
				ui_file_path = path
				break
			end
		end
	end
	
	if not ui_file_path then
		vim.notify("UI file not found: " .. ui_file, vim.log.levels.ERROR)
		return false
	end
	
	-- Analyze UI file
	local ui_info = designer.analyze_ui_file(ui_file_path)
	if not ui_info.class_name or ui_info.class_name == "" then
		vim.notify("Could not determine class name from UI file", vim.log.levels.ERROR)
		return false
	end
	
	-- Use UI class name if no class name provided
	if not class_name or class_name == "" then
		class_name = ui_info.class_name
	end
	
	-- Determine class type from UI
	local class_type = M.determine_class_type_from_ui(ui_info)
	
	-- Compile UI file with uic
	M.compile_ui_file(ui_file_path)
	
	-- Create class with UI integration
	local success, error_msg = core.create_qt_class(class_name, class_type, {
		ui_file = ui_file_path,
		ui_class_name = ui_info.class_name,
		include_ui = true
	})
	
	if success then
		vim.notify(string.format("Successfully created %s class from UI file: %s", class_type, class_name), vim.log.levels.INFO)
		
		-- Update CMakeLists.txt if enabled
		if M._config.auto_update_cmake then
			local cmake = require("qt-assistant.cmake")
			cmake.add_ui_file(ui_file_path)
		end
	else
		vim.notify(string.format("Error creating class from UI: %s", error_msg), vim.log.levels.ERROR)
	end
	
	return success
end

-- Build Management
function M.build_project()
	local build_manager = require("qt-assistant.build_manager")
	build_manager.build_project()
end

function M.run_project()
	local build_manager = require("qt-assistant.build_manager")
	build_manager.run_project()
end

function M.install_project(prefix)
	local build_manager = require("qt-assistant.build_manager")
	build_manager.install_project(prefix)
end

function M.package_project()
	local build_manager = require("qt-assistant.build_manager")
	build_manager.package_project()
end

-- Debug Management
function M.debug_application()
	local debug_ok, debug = pcall(require, "qt-assistant.debug")
	if debug_ok then
		debug.debug_application()
	else
		vim.notify("❌ Debug module not available", vim.log.levels.ERROR)
	end
end

function M.attach_to_process()
	local debug_ok, debug = pcall(require, "qt-assistant.debug")
	if debug_ok then
		debug.attach_to_process()
	else
		vim.notify("❌ Debug module not available", vim.log.levels.ERROR)
	end
end

function M.show_debug_status()
	local debug_ok, debug = pcall(require, "qt-assistant.debug")
	if debug_ok then
		debug.show_debug_status()
	else
		vim.notify("❌ Debug module not available", vim.log.levels.ERROR)
	end
end

-- ==================== Helper Functions ====================

-- Determine class type from UI file
function M.determine_class_type_from_ui(ui_info)
	if not ui_info.widgets or #ui_info.widgets == 0 then
		return "widget"
	end
	
	for _, widget in ipairs(ui_info.widgets) do
		if widget.class == "QMainWindow" then
			return "main_window"
		elseif widget.class == "QDialog" then
			return "dialog"
		elseif widget.class == "QWidget" then
			return "widget"
		end
	end
	
	return "widget"
end

-- Compile UI file with uic (enhanced error handling)
function M.compile_ui_file(ui_file_path)
	local system = require('qt-assistant.system')
	local file_manager = require('qt-assistant.file_manager')
	
	-- Validate input
	if not ui_file_path or ui_file_path == "" then
		vim.notify("❌ UI file path is required", vim.log.levels.ERROR)
		return false
	end
	
	if not file_manager.file_exists(ui_file_path) then
		vim.notify("❌ UI file not found: " .. ui_file_path, vim.log.levels.ERROR)
		return false
	end
	
	-- Find uic tool with helpful error message
	local uic_path = system.find_qt_tool("uic")
	if not uic_path then
		local os_type = system.get_os()
		local install_hint = ""
		
		if os_type == 'linux' then
			install_hint = "\n💡 Try: sudo apt install qt6-dev-tools or qttools5-dev-tools"
		elseif os_type == 'macos' then
			install_hint = "\n💡 Try: brew install qt@6 or qt@5"
		else
			install_hint = "\n💡 Ensure Qt development tools are installed and in PATH"
		end
		
		vim.notify("❌ uic tool not found." .. install_hint, vim.log.levels.ERROR)
		return false
	end
	
	-- Determine output path
	local project_root = M._config.project_root
	local ui_filename = vim.fn.fnamemodify(ui_file_path, ":t:r")
	local output_file = system.join_path(project_root, "include", "ui_" .. ui_filename .. ".h")
	
	-- Ensure include directory exists
	local include_dir = vim.fn.fnamemodify(output_file, ":h")
	local success, error_msg = file_manager.ensure_directory_exists(include_dir)
	if not success then
		vim.notify("❌ Failed to create include directory: " .. error_msg, vim.log.levels.ERROR)
		return false
	end
	
	-- Validate write permissions
	local test_file = include_dir .. "/.write_test"
	local test_success = file_manager.write_file(test_file, "test")
	if test_success then
		os.remove(test_file)
	else
		vim.notify("❌ No write permission to include directory: " .. include_dir, vim.log.levels.ERROR)
		return false
	end
	
	-- Run uic command with detailed error handling
	local cmd = {uic_path, "-o", output_file, ui_file_path}
	
	vim.notify("🔧 Compiling UI file with uic...", vim.log.levels.INFO)
	
	local error_output = {}
	
	local job_id = vim.fn.jobstart(cmd, {
		on_stdout = function(_, data)
			if data and #data > 0 then
				for _, line in ipairs(data) do
					if line and line ~= "" then
						vim.schedule(function()
							print("uic: " .. line)
						end)
					end
				end
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				for _, line in ipairs(data) do
					if line and line ~= "" then
						table.insert(error_output, line)
						vim.schedule(function()
							vim.notify("uic Error: " .. line, vim.log.levels.ERROR)
						end)
					end
				end
			end
		end,
		on_exit = function(_, exit_code)
			vim.schedule(function()
				if exit_code == 0 then
					-- Verify output file was created
					if file_manager.file_exists(output_file) then
						vim.notify("✅ Successfully compiled UI file to: " .. vim.fn.fnamemodify(output_file, ":t"), vim.log.levels.INFO)
					else
						vim.notify("❌ uic completed but output file not found", vim.log.levels.ERROR)
					end
				else
					local error_summary = #error_output > 0 and table.concat(error_output, " | ") or "Unknown error"
					vim.notify("❌ uic compilation failed (exit code: " .. exit_code .. ")\n💡 " .. error_summary, vim.log.levels.ERROR)
				end
			end)
		end
	})
	
	if job_id <= 0 then
		vim.notify("❌ Failed to start uic command. Check tool permissions.", vim.log.levels.ERROR)
		return false
	end
	
	return true
end

-- Show help
function M.show_help()
	local config = require('qt-assistant.config').get()
	local preset = (config.keymaps and config.keymaps.preset) or 'minimal'
	preset = tostring(preset):lower()

	local help_text = {
		"=== Qt Assistant - Essential Commands ===",
		"",
		"Project Management:",
		"  :QtNewProject <name> <type>  - Create new Qt project",
		"  :QtOpenProject [path]        - Open Qt project",
		"",
		"Multi-Module Projects:",
		"  :QtAddModule <name> <type>   - Add module to project",
		"  :QtAddModule                 - Interactive module creation",
		"",
		"UI Designer (PRD Core Features):",
		"  :QtNewUi <filename>          - Create new UI file",
		"  :QtEditUi [filename]         - Edit existing UI file",
		"  :QtDesigner [file]           - Open Qt Designer",
		"",
		"Class Generation:",
		"  :QtCreateClass <name> <type> - Create Qt class",
		"  :QtCreateClass <name> <type> <ui> - Create class from UI file",
		"",
		"Build System:",
		"  :QtBuild                     - Build project",
		"  :QtRun                       - Run project",
		"  :QtInstall [prefix]           - Install (CMake only)",
		"  :QtPackage                    - Package ZIP (CMake: CPack, qmake: zip build dir)",
		"",
		"CMake Management:",
		"  :QtCMakePresets              - Generate CMakePresets.json",
		"  :QtBuildPreset [preset]      - Build with CMake preset",
		"  :QtCMakeFormat               - Format CMakeLists.txt",
		"  :QtCMakeBackup               - Backup CMakeLists.txt",
		"",
		"Debug System (requires nvim-dap):",
		"  :QtDebugSetup                - Setup debugging environment",
		"  :QtDebug                     - Debug Qt application",
		"  :QtDebugAttach               - Attach to running Qt process", 
		"  :QtDebugStatus               - Show debug configuration",
		"",
		"Essential Keymaps (optimized for quick development):",
		"  <leader>qa  - Qt Assistant main interface",
		"  <leader>qh  - Show this help",
		"  <leader>qp  - New project (interactive)",
		"  <leader>qo  - Open project (interactive)",
		"  <leader>qu  - New UI file (interactive)",
		"  <leader>qe  - Edit current/select UI file",
		"  <leader>qd  - Open Qt Designer",
		"  <leader>qc  - Create class (interactive)",
		"  <leader>qf  - Create class from current UI",
		"  <leader>qb  - Build project",
		"  <leader>qr  - Run project",
		"  <leader>qdb - Debug application (nvim-dap)",
		"  <leader>qda - Attach to Qt process",
		"",
		"Context-aware keymaps (in UI/C++ files):",
		"  <leader>gd  - Open current UI in Designer",
		"  <leader>gc  - Generate class from current UI",
		"  <leader>gu  - Find & open corresponding UI",
		"",
		"Project Types: widget_app, quick_app, console_app, static_lib, shared_lib, plugin",
		"Class Types: main_window, dialog, widget, model, delegate, thread, utility, singleton"
	}

	if preset == 'full' then
		table.insert(help_text, 1, "(Keymaps preset: full)")
		-- Mention optional/legacy keymaps at the end
		table.insert(help_text, "")
		table.insert(help_text, "Extra keymaps (full preset):")
		table.insert(help_text, "  <leader>qP  - New project (quick widget_app + C++17)")
		table.insert(help_text, "  <leader>qA  - Quick build & run")
		table.insert(help_text, "  <leader>qb1/qb4/qb7/qb20 - Build with specific C++ standard (Windows)")
		table.insert(help_text, "  <leader>qsc/qss/qsr - Config & reconfigure helpers")
	else
		table.insert(help_text, 1, "(Keymaps preset: minimal)")
	end
	
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_text)
	
	local width = 60
	local height = math.min(#help_text + 2, 25)
	
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
		title = " Qt Assistant Help ",
		title_pos = "center"
	}
	
	local win = vim.api.nvim_open_win(buf, true, win_config)
	
	vim.api.nvim_win_set_option(win, "number", false)
	vim.api.nvim_win_set_option(win, "relativenumber", false)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	
	-- Close with q or Esc
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
end

-- Quick project creation with C++17 default
function M.new_project_quick()
	vim.notify(
		"Quick project mode: creates a widget_app with C++17 defaults (no prompts). Use <leader>qp or :QtNewProject for interactive test/C++ selection.",
		vim.log.levels.INFO
	)
	local project_name = vim.fn.input("Project name: ")
	if project_name == "" then
		vim.notify("Project name cannot be empty", vim.log.levels.ERROR)
		return
	end

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
		local project_manager = require('qt-assistant.project_manager')
		project_manager.new_project(project_name, "widget_app", "17", target_root)
	end)
end

-- Build with specific C++ standard
function M.build_with_std(cxx_standard)
	if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
		-- Windows: use batch script with C++ standard
		local cmd = string.format('build.bat Debug %s', cxx_standard)
		vim.notify(string.format("Building with C++%s...", cxx_standard), vim.log.levels.INFO)
		vim.fn.system(cmd)
	else
		-- Unix: use cmake directly
		local build_manager = require('qt-assistant.build_manager')
		build_manager.build_project()
		vim.notify(string.format("Building with C++%s...", cxx_standard), vim.log.levels.INFO)
	end
end

-- Show current project configuration
function M.show_current_config()
	local lines = {
		"=== Qt Project Configuration ===",
		"",
	}
	
	-- Try to read CMakeCache.txt
	local cache_file = "build/CMakeCache.txt"
	if vim.fn.filereadable(cache_file) == 1 then
		local cache_content = vim.fn.readfile(cache_file)
		local cxx_standard = "Not found"
		local qt_version = "Not found"
		local build_type = "Not found"
		
		for _, line in ipairs(cache_content) do
			if line:match("CMAKE_CXX_STANDARD:STRING=") then
				cxx_standard = "C++" .. line:gsub(".*=", "")
			elseif line:match("CMAKE_BUILD_TYPE:STRING=") then
				build_type = line:gsub(".*=", "")
			elseif line:match("Qt.*_VERSION:STRING=") then
				qt_version = line:gsub(".*=", "")
			end
		end
		
		table.insert(lines, "C++ Standard: " .. cxx_standard)
		table.insert(lines, "Qt Version: " .. qt_version)
		table.insert(lines, "Build Type: " .. build_type)
	else
		table.insert(lines, "No build configuration found")
		table.insert(lines, "Run build command to configure project")
	end
	
	table.insert(lines, "")
	table.insert(lines, "Project Root: " .. vim.fn.getcwd())
	
	local height = #lines + 2
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = 'minimal',
		border = 'rounded',
		title = " Qt Configuration "
	})
	
	-- Close on any key
	vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', {buffer = buf})
	vim.keymap.set('n', 'q', '<cmd>close<cr>', {buffer = buf})
end

-- Select C++ standard interactively
function M.select_cxx_standard()
	local standards = {"11", "14", "17", "20", "23"}
	local choices = {
		"Select C++ Standard:",
		"1. C++11 (Qt5 compatible)",
		"2. C++14 (Qt5 compatible)", 
		"3. C++17 (Qt5/Qt6 compatible, recommended)",
		"4. C++20 (Modern C++, Qt6 preferred)",
		"5. C++23 (Latest standard)"
	}
	
	local choice = vim.fn.inputlist(choices)
	if choice >= 1 and choice <= 5 then
		local std = standards[choice]
		vim.notify(string.format("Selected C++%s - Use build commands to apply", std), vim.log.levels.INFO)
		return std
	end
	return nil
end

-- Reconfigure project with new settings
function M.reconfigure_project()
	local choice = vim.fn.inputlist({
		"Reconfigure project:",
		"1. Reconfigure with current settings",
		"2. Reconfigure with new C++ standard", 
		"3. Clean and reconfigure"
	})
	
	if choice == 1 then
		-- Simple reconfigure
		local cmd = "cd build && cmake .."
		vim.fn.system(cmd)
		vim.notify("Project reconfigured", vim.log.levels.INFO)
	elseif choice == 2 then
		-- Reconfigure with new C++ standard
		local std = M.select_cxx_standard()
		if std then
			local cmd = string.format("cd build && cmake .. -DCMAKE_CXX_STANDARD=%s", std)
			vim.fn.system(cmd)
			vim.notify(string.format("Project reconfigured with C++%s", std), vim.log.levels.INFO)
		end
	elseif choice == 3 then
		-- Clean and reconfigure
		if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
			vim.fn.system('clean.bat')
		else
			vim.fn.system('rm -rf build && mkdir build')
		end
		vim.notify("Project cleaned and will be reconfigured on next build", vim.log.levels.INFO)
	end
end

return M
