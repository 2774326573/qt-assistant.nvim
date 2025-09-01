-- Neovim Qt Assistant Plugin - Core Module
-- Qt项目辅助插件主模块

local M = {}

-- Configuration
M._config = nil

-- Initialize plugin
function M.setup(user_config)
	local default_config = {
		project_root = vim.fn.getcwd(),
		directories = {
			source = "src",
			include = "include",
			ui = "ui",
			resource = "resources"
		},
		auto_update_cmake = true,
		qt_tools = {
			designer_path = "designer",
			uic_path = "uic",
			qmake_path = "qmake",
			cmake_path = "cmake"
		},
		enable_default_keymaps = true
	}

	M._config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Setup keymaps if enabled
	if M._config.enable_default_keymaps then
		M.setup_keymaps()
	end
	
	-- Initialize debug integration
	local debug = require('qt-assistant.debug')
	debug.init()
	
	-- Initialize LSP integration
	local lsp = require('qt-assistant.lsp')
	lsp.init()
end

-- Get configuration
function M.get_config()
	return M._config or {}
end

-- Setup optimized keymaps for quick development
function M.setup_keymaps()
	local map = vim.keymap.set

	-- Core Qt commands (essential workflow)
	map("n", "<leader>qa", function() M.show_main_interface() end, { desc = "Qt Assistant" })
	map("n", "<leader>qh", function() M.show_help() end, { desc = "Qt Help" })
	
	-- Project management (quick access)
	map("n", "<leader>qp", function() M.new_project_interactive() end, { desc = "New Qt Project" })
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
	map("n", "<leader>qq", function() M.quick_build_and_run() end, { desc = "Quick Build & Run" })
	
	-- Debug system (integrated debugging)
	map("n", "<leader>qdb", function() M.debug_application() end, { desc = "Debug Qt App" })
	map("n", "<leader>qda", function() M.attach_to_process() end, { desc = "Attach to Qt Process" })
	
	-- LSP system (clangd integration)
	map("n", "<leader>qls", function() M.setup_qt_lsp() end, { desc = "Setup Qt LSP" })
	map("n", "<leader>qlg", function() M.generate_compile_commands() end, { desc = "Generate Compile Commands" })
	map("n", "<leader>qlt", function() M.show_lsp_status() end, { desc = "LSP Status" })
	
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
			vim.ui.select({'Qt Widgets App', 'Qt Quick App', 'Console App'}, {
				prompt = 'Select project type:'
			}, function(choice, idx)
				if choice then
					local types = {'widget_app', 'quick_app', 'console_app'}
					M.new_project(name, types[idx])
				end
			end)
		end
	end)
end

function M.open_project_interactive()
	vim.ui.input({ 
		prompt = 'Project path: ',
		default = vim.fn.getcwd(),
		completion = 'dir'
	}, function(path)
		if path and path ~= "" then
			M.open_project(path)
		end
	end)
end

function M.new_project(name, template_type)
	local project_manager = require("qt-assistant.project_manager")
	project_manager.new_project(name, template_type)
end

function M.open_project(path)
	local project_manager = require("qt-assistant.project_manager")
	project_manager.open_project(path)
end

-- UI Designer Integration
function M.create_new_ui_interactive()
	vim.ui.input({ prompt = 'UI filename: ' }, function(filename)
		if filename and filename ~= "" then
			M.create_new_ui(filename)
		end
	end)
end

function M.create_new_ui(filename)
	local designer = require("qt-assistant.designer")
	designer.create_new_ui(filename)
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
			vim.ui.select({'Main Window', 'Dialog', 'Widget', 'Model'}, {
				prompt = 'Select class type:'
			}, function(choice, idx)
				if choice then
					local types = {'main_window', 'dialog', 'widget', 'model'}
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

-- Debug Management
function M.debug_application()
	local debug = require("qt-assistant.debug")
	debug.debug_application()
end

function M.attach_to_process()
	local debug = require("qt-assistant.debug")
	debug.attach_to_process()
end

function M.show_debug_status()
	local debug = require("qt-assistant.debug")
	debug.show_debug_status()
end

-- LSP Management
function M.setup_qt_lsp()
	local lsp = require("qt-assistant.lsp")
	lsp.setup_complete_qt_lsp()
end

function M.generate_compile_commands()
	local lsp = require("qt-assistant.lsp")
	lsp.generate_compile_commands()
end

function M.show_lsp_status()
	local lsp = require("qt-assistant.lsp")
	lsp.show_lsp_status()
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
	local help_text = {
		"=== Qt Assistant - Essential Commands ===",
		"",
		"Project Management:",
		"  :QtNewProject <name> <type>  - Create new Qt project",
		"  :QtOpenProject [path]        - Open Qt project",
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
		"",
		"Debug System (requires nvim-dap):",
		"  :QtDebugSetup                - Setup debugging environment",
		"  :QtDebug                     - Debug Qt application",
		"  :QtDebugAttach               - Attach to running Qt process", 
		"  :QtDebugStatus               - Show debug configuration",
		"",
		"LSP System (requires clangd):",
		"  :QtLspSetup                  - Setup clangd for Qt development",
		"  :QtLspGenerate               - Generate compile_commands.json",
		"  :QtLspStatus                 - Show clangd LSP status",
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
		"  <leader>qq  - Quick build & run",
		"  <leader>qdb - Debug application (nvim-dap)",
		"  <leader>qda - Attach to Qt process",
		"  <leader>qls - Setup Qt LSP (clangd)",
		"  <leader>qlg - Generate compile commands",
		"  <leader>qlt - LSP status",
		"",
		"Context-aware keymaps (in UI/C++ files):",
		"  <leader>gd  - Open current UI in Designer",
		"  <leader>gc  - Generate class from current UI",
		"  <leader>gu  - Find & open corresponding UI",
		"",
		"Project Types: widget_app, quick_app, console_app",
		"Class Types: main_window, dialog, widget, model"
	}
	
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

return M