-- Neovim Qt Assistant Plugin - Final Main Module
-- Qt项目辅助插件主模块（最终版）

local M = {}

-- 内联配置管理，避免循环依赖
M._config = nil

-- 初始化插件
function M.setup(user_config)
	-- 默认配置
	local default_config = {
		project_root = vim.fn.getcwd(),
		directories = {
			source = "src",
			include = "include",
			ui = "ui",
			resource = "resources",
			scripts = "scripts",
			tests = "tests",
			docs = "docs",
		},
		naming_convention = "snake_case",
		auto_update_cmake = true,
		generate_comments = true,
		template_path = vim.fn.stdpath("config") .. "/qt-templates",
		qt_project = {
			version = "auto", -- "auto", "Qt5", "Qt6"
			qt5_path = "", -- Windows Qt5 installation path
			qt6_path = "", -- Windows Qt6 installation path
			auto_detect = true,
			build_type = "Debug",
			build_dir = "build",
			parallel_build = true,
			build_jobs = vim.loop.os_uname().sysname == "Windows_NT" and os.getenv("NUMBER_OF_PROCESSORS") or vim.fn.system("nproc"):gsub("%s+", ""),
			cmake_minimum_version = "3.5", -- Qt5 compatible
			cxx_standard = "14", -- Qt5 compatible, will be updated based on detected version
		},
		global_search = {
			enabled = true,
			max_depth = 3,
			include_system_paths = true,
			custom_search_paths = {},
			exclude_patterns = {
				"node_modules",
				".git",
				".vscode",
				"build",
				"target",
				"dist",
				"out",
				"__pycache__",
				".cache",
				"tmp",
				"temp",
			},
		},
		designer = {
			designer_path = "designer",
			creator_path = "qtcreator",
			default_editor = "designer",
			custom_editor = { command = "", args = { "--file", "{file}" } },
			auto_sync = true,
			enable_preview = true,
		},
		debug = {
			enabled = false,
			log_level = "INFO",
			log_file = vim.fn.stdpath("data") .. "/qt-assistant.log",
		},
		-- 代码格式化配置
		auto_format = {
			enabled = true,  -- 默认启用自动格式化
			formatter = "clang_format",  -- "clang_format" 或 "astyle"
			on_save = true,  -- 保存时自动格式化
		},
		enable_default_keymaps = true,
	}

	M._config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- 更新外部config模块的配置（如果存在）
	local ok, config_module = pcall(require, "qt-assistant.config")
	if ok then
		config_module.setup(user_config)
	end

	-- 设置快捷键（如果用户配置了）
	if M._config.enable_default_keymaps then
		M.setup_keymaps()
	end
	
	-- 设置自动格式化（如果启用）
	if M._config.auto_format and M._config.auto_format.enabled then
		local formatter = require("qt-assistant.formatter")
		formatter.setup_auto_format()
	end

	-- vim.notify("Qt Assistant Plugin loaded successfully!", vim.log.levels.INFO)
end

-- 获取配置
function M.get_config()
	return M._config or {}
end

-- 设置快捷键映射
function M.setup_keymaps()
	-- 条件检查已经在调用处处理了，这里直接设置
	local map = vim.keymap.set

	-- 基础操作
		map("n", "<leader>qC", function()
			M.show_main_interface()
		end, { desc = "Qt Assistant" })
		map("n", "<leader>qh", "<cmd>help qt-assistant<cr>", { desc = "Qt Help" })

		-- 项目管理 (Project Management)
		-- 核心操作
		map("n", "<leader>qpo", function()
			M.smart_project_selector()
		end, { desc = "Smart Open Project (Auto)" })
		map("n", "<leader>qpm", function()
			M.show_project_manager()
		end, { desc = "Project Manager" })

		-- 项目选择/切换
		map("n", "<leader>qpc", function()
			M.smart_project_selector_with_choice()
		end, { desc = "Choose Project (Manual)" })
		map("n", "<leader>qpw", function()
			M.quick_project_switcher()
		end, { desc = "Quick Project Switcher" })
		map("n", "<leader>qpr", function()
			M.show_recent_projects()
		end, { desc = "Recent Projects" })

		-- 项目搜索
		map("n", "<leader>qps", function()
			M.search_qt_projects()
		end, { desc = "Search Qt Projects (Local)" })
		map("n", "<leader>qpg", function()
			M.global_search_projects()
		end, { desc = "Global Search All Drives" })

		-- 构建管理
		map("n", "<leader>qb", function()
			M.build_project()
		end, { desc = "Build Project" })
		map("n", "<leader>qr", function()
			M.run_project()
		end, { desc = "Run Project" })
		map("n", "<leader>qcl", function()
			M.clean_project()
		end, { desc = "Clean Project" })
		map("n", "<leader>qbs", function()
			M.show_build_status()
		end, { desc = "Build Status" })

		-- UI设计师
		map("n", "<leader>qud", function()
			M.open_designer()
		end, { desc = "Open Designer" })
		map("n", "<leader>quc", function()
			M.open_designer_current()
		end, { desc = "Designer Current" })
		map("n", "<leader>qum", function()
			M.show_designer_manager()
		end, { desc = "Designer Manager" })

		-- 脚本管理
		map("n", "<leader>qsb", function()
			M.run_script("build")
		end, { desc = "Script Build" })
		map("n", "<leader>qsr", function()
			M.run_script("run")
		end, { desc = "Script Run" })
		map("n", "<leader>qsd", function()
			M.run_script("debug")
		end, { desc = "Script Debug" })
		map("n", "<leader>qsc", function()
			M.run_script("clean")
		end, { desc = "Script Clean" })
		map("n", "<leader>qst", function()
			M.run_script("test")
		end, { desc = "Script Test" })
		map("n", "<leader>qsp", function()
			M.run_script("deploy")
		end, { desc = "Script Deploy" })
		map("n", "<leader>qsg", function()
			M.show_script_generator()
		end, { desc = "Script Generator" })
		map("n", "<leader>qsa", function()
			M.quick_generate_all_scripts()
		end, { desc = "Generate All Scripts" })

		-- 代码格式化
		map("n", "<leader>qff", function()
			M.format_current_file()
		end, { desc = "Format Current File" })
		map("n", "<leader>qfp", function()
			M.format_project()
		end, { desc = "Format Project" })
		map("n", "<leader>qfs", function()
			M.show_formatter_status()
		end, { desc = "Formatter Status" })
		map("n", "<leader>qfc", function()
			M.create_clang_format_config()
		end, { desc = "Create .clang-format" })

		-- 系统信息
		map("n", "<leader>qis", function()
			M.show_system_info()
		end, { desc = "System Info" })

		-- Qt版本管理
		map("n", "<leader>qvi", function()
			M.show_qt_version_info()
		end, { desc = "Qt Version Info" })
	map("n", "<leader>qvd", function()
		M.detect_qt_version()
	end, { desc = "Detect Qt Version" })
	
	-- ==================== 新的四键组合系统 ====================
	-- 检测 leader 键类型
	local leader = vim.g.mapleader or "\\"
	local leader_prefix = leader == " " and "<Space>" or "<leader>"
	
	-- 任务管理 (qt)
	map("n", leader_prefix .. "qt", function()
		vim.notify("Qt Tasks:\nb - Build Project\nr - Run Project\nc - Clean Project\nd - Debug Project\nt - Run Tests\np - Deploy Project", 
			vim.log.levels.INFO, {title = "Qt Assistant - Tasks"})
	end, { desc = "Qt: Tasks menu" })
	
	map("n", leader_prefix .. "qtb", function() M.build_project() end, { desc = "Qt: Build project" })
	map("n", leader_prefix .. "qtr", function() M.run_project() end, { desc = "Qt: Run project" })
	map("n", leader_prefix .. "qtc", function() M.clean_project() end, { desc = "Qt: Clean project" })
	map("n", leader_prefix .. "qtd", function() M.run_script("debug") end, { desc = "Qt: Debug project" })
	map("n", leader_prefix .. "qtt", function() M.run_script("test") end, { desc = "Qt: Run tests" })
	map("n", leader_prefix .. "qtp", function() M.run_script("deploy") end, { desc = "Qt: Deploy project" })
	
	-- 环境设置 (qe)
	map("n", leader_prefix .. "qe", function()
		vim.notify("Qt Environment:\nm - Setup MSVC\nl - Setup Clangd\nk - Check MSVC\nf - Fix .pro File\nc - Fix Compilation Environment", 
			vim.log.levels.INFO, {title = "Qt Assistant - Environment"})
	end, { desc = "Qt: Environment menu" })
	
	map("n", leader_prefix .. "qem", function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('setup_msvc') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/setup_msvc' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, { desc = "Qt: Setup MSVC" })
	
	map("n", leader_prefix .. "qel", function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('setup_clangd') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/setup_clangd' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, { desc = "Qt: Setup Clangd" })
	
	map("n", leader_prefix .. "qek", function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('check_msvc') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/check_msvc' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, { desc = "Qt: Check MSVC" })
	
	map("n", leader_prefix .. "qef", function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('fix_pro') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/fix_pro' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, { desc = "Qt: Fix .pro file" })
	
	map("n", leader_prefix .. "qec", function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('fix_compile') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/fix_compile' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, { desc = "Qt: Fix compilation environment" })
	
	-- 脚本管理 (qs)
	map("n", leader_prefix .. "qs", function()
		vim.notify("Qt Scripts:\ng - Generate Scripts\ne - Edit Scripts\ns - Show Status", 
			vim.log.levels.INFO, {title = "Qt Assistant - Scripts"})
	end, { desc = "Qt: Scripts menu" })
	
	map("n", leader_prefix .. "qsg", function() M.quick_generate_all_scripts() end, { desc = "Qt: Generate scripts" })
	map("n", leader_prefix .. "qse", function() M.show_script_selector() end, { desc = "Qt: Edit scripts" })
	map("n", leader_prefix .. "qss", function() M.show_script_status() end, { desc = "Qt: Show status" })
	
	-- UI设计师 (qd)
	map("n", leader_prefix .. "qd", function()
		vim.notify("Qt Designer:\nu - Open Qt Designer", 
			vim.log.levels.INFO, {title = "Qt Assistant - Designer"})
	end, { desc = "Qt: Designer menu" })
	
	map("n", leader_prefix .. "qdu", function() M.open_designer_current() end, { desc = "Qt: Qt Designer" })
	
	-- 项目管理 (qp)
	map("n", leader_prefix .. "qp", function()
		vim.notify("Qt Project:\ni - Init Project\no - Select Project\nc - Configuration", 
			vim.log.levels.INFO, {title = "Qt Assistant - Project"})
	end, { desc = "Qt: Project menu" })
	
	map("n", leader_prefix .. "qpi", function() M.new_project() end, { desc = "Qt: Init project" })
	map("n", leader_prefix .. "qpo", function() M.smart_project_selector() end, { desc = "Qt: Select project" })
	map("n", leader_prefix .. "qpc", function() M.configure_build_environment() end, { desc = "Qt: Configure build environment" })
	
	-- 添加对应的用户命令
	vim.api.nvim_create_user_command('QtBuild', function() M.build_project() end, {desc = "Build Qt project"})
	vim.api.nvim_create_user_command('QtRun', function() M.run_project() end, {desc = "Run Qt project"})
	vim.api.nvim_create_user_command('QtClean', function() M.clean_project() end, {desc = "Clean Qt project"})
	vim.api.nvim_create_user_command('QtSetupMsvc', function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('setup_msvc') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/setup_msvc' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, {desc = "Setup MSVC environment"})
	vim.api.nvim_create_user_command('QtSetupClangd', function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('setup_clangd') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/setup_clangd' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, {desc = "Setup Clangd LSP"})
	vim.api.nvim_create_user_command('QtFixPro', function()
		local scripts = require('qt-assistant.scripts')
		if scripts.generate_single_script('fix_pro') then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and '.bat' or '.sh'
			local script_path = scripts_dir .. '/fix_pro' .. script_ext
			vim.cmd('terminal ' .. vim.fn.shellescape(script_path))
		end
	end, {desc = "Fix .pro file MSVC paths"})
	vim.api.nvim_create_user_command('QtScripts', function() M.quick_generate_all_scripts() end, {desc = "Generate all scripts"})
	vim.api.nvim_create_user_command('QtConfig', function() M.configure_build_environment() end, {desc = "Configure build environment"})
	
	-- 提示信息 (已禁用)
	-- if leader == " " then
	--	vim.notify("Qt Assistant: 已设置空格键快捷键 (Space+qt, Space+qe, etc.)", vim.log.levels.INFO)
	-- else
	--	vim.notify("Qt Assistant: 已设置快捷键 (" .. leader .. "qt, " .. leader .. "qe, etc.)", vim.log.levels.INFO)
	-- end
end

-- 脚本选择器
function M.show_script_selector()
	local scripts = require('qt-assistant.scripts')
	local script_list = scripts.list_scripts()
	
	if #script_list == 0 then
		vim.notify("No scripts found. Run :QtScripts to generate them.", vim.log.levels.WARN)
		return
	end
	
	vim.ui.select(script_list, {
		prompt = "Select script to edit:",
		format_item = function(item) return item end,
	}, function(choice)
		if choice then
			local scripts_dir = scripts.get_scripts_directory()
			local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
			local script_ext = is_windows and ".bat" or ".sh"
			local script_path = scripts_dir .. "/" .. choice .. script_ext
			vim.cmd("edit " .. vim.fn.fnameescape(script_path))
		end
	end)
end

-- 显示脚本状态
function M.show_script_status()
	local scripts = require('qt-assistant.scripts')
	scripts.show_script_status()
end

-- ==================== 接口函数 ====================
-- 以下函数使用延迟加载避免循环依赖

-- 创建Qt类的主函数
function M.create_class(class_name, class_type, options)
	if not class_name or class_name == "" then
		vim.notify("Error: Class name is required", vim.log.levels.ERROR)
		return
	end

	-- 延迟加载需要的模块
	local core = require("qt-assistant.core")
	local templates = require("qt-assistant.templates")

	-- 初始化模板
	templates.init(M._config.template_path)

	-- 验证类名
	if not core.validate_class_name(class_name) then
		vim.notify("Error: Invalid class name format", vim.log.levels.ERROR)
		return
	end

	-- 创建类
	local success, error_msg = core.create_qt_class(class_name, class_type, options)

	if success then
		vim.notify(string.format("Successfully created %s class: %s", class_type, class_name), vim.log.levels.INFO)
	else
		vim.notify(string.format("Error creating class: %s", error_msg), vim.log.levels.ERROR)
	end
end

-- 创建UI类
function M.create_ui_class(ui_name, ui_type)
	M.create_class(ui_name, ui_type, { include_ui = true })
end

-- 创建数据模型
function M.create_model_class(model_name)
	M.create_class(model_name, "model", {})
end

-- 获取项目信息
function M.get_project_info()
	return {
		root = M._config.project_root,
		directories = M._config.directories,
		cmake_file = M._config.project_root .. "/CMakeLists.txt",
	}
end

-- 显示主界面
function M.show_main_interface()
	local ui = require("qt-assistant.ui")
	ui.show_class_creator()
end

-- 交互式类创建函数
function M.create_class_interactive(class_type)
	-- 提示用户输入类名
	local class_name = vim.fn.input("Enter class name: ")
	if class_name and class_name ~= "" then
		M.create_class(class_name, class_type, {})
	else
		vim.notify("Class creation cancelled", vim.log.levels.WARN)
	end
end

-- 快速类创建（显示类型选择器）
function M.quick_create_class()
	local class_types = {
		{ key = "1", name = "Main Window", type = "main_window" },
		{ key = "2", name = "Dialog", type = "dialog" },
		{ key = "3", name = "Widget", type = "widget" },
		{ key = "4", name = "Model", type = "model" },
		{ key = "5", name = "Delegate", type = "delegate" },
		{ key = "6", name = "Thread", type = "thread" },
		{ key = "7", name = "Utility", type = "utility" },
		{ key = "8", name = "Singleton", type = "singleton" },
	}

	local choices = {}
	for _, item in ipairs(class_types) do
		table.insert(choices, string.format("%s. %s", item.key, item.name))
	end

	local choice = vim.fn.inputlist(vim.list_extend({ "Select class type:" }, choices))

	if choice >= 1 and choice <= #class_types then
		local selected_type = class_types[choice].type
		M.create_class_interactive(selected_type)
	else
		vim.notify("Class creation cancelled", vim.log.levels.WARN)
	end
end

-- 项目管理
function M.open_project(path)
	local project_manager = require("qt-assistant.project_manager")
	project_manager.open_project(path)
end

function M.new_project(name, type)
	local project_manager = require("qt-assistant.project_manager")
	project_manager.new_project(name, type)
end

function M.show_project_manager()
	local ui = require("qt-assistant.ui")
	ui.show_project_manager()
end

-- 智能搜索Qt项目
function M.search_qt_projects()
	local project_manager = require("qt-assistant.project_manager")
	project_manager.search_and_select_project()
end

-- 显示最近项目
function M.show_recent_projects()
	local project_manager = require("qt-assistant.project_manager")
	project_manager.show_recent_projects()
end

-- 智能项目选择器（整合所有功能）- 自动打开
function M.smart_project_selector()
	local project_manager = require("qt-assistant.project_manager")
	project_manager.show_smart_project_selector()
end

-- 智能项目选择器（带选择界面）- 手动选择
function M.smart_project_selector_with_choice()
	local project_manager = require("qt-assistant.project_manager")
	project_manager.show_smart_project_selector_with_choice()
end

-- 快速项目切换器
function M.quick_project_switcher()
	local project_manager = require("qt-assistant.project_manager")
	project_manager.show_quick_project_switcher()
end

-- 全局搜索Qt项目
function M.global_search_projects()
	local project_manager = require("qt-assistant.project_manager")
	project_manager.start_global_search()
end

-- 构建管理
function M.build_project(build_type)
	local build_manager = require("qt-assistant.build_manager")
	build_manager.build_project(build_type)
end

function M.run_project()
	local build_manager = require("qt-assistant.build_manager")
	build_manager.run_project()
end

function M.clean_project()
	local build_manager = require("qt-assistant.build_manager")
	build_manager.clean_project()
end

function M.show_build_status()
	local build_manager = require("qt-assistant.build_manager")
	build_manager.show_build_status()
end

-- 脚本管理
function M.init_scripts()
	local scripts = require("qt-assistant.scripts")
	scripts.init_scripts_directory()
end

function M.run_script(script_name)
	local scripts = require("qt-assistant.scripts")
	scripts.run_script(script_name, { in_terminal = true })
end

-- 快速生成脚本
function M.generate_scripts()
	local scripts = require("qt-assistant.scripts")
	return scripts.quick_generate_scripts()
end

-- 生成单个脚本
function M.generate_single_script(script_type)
	local scripts = require("qt-assistant.scripts")
	return scripts.generate_single_script(script_type)
end

-- 交互式脚本生成器
function M.show_script_generator()
	local scripts = require("qt-assistant.scripts")
	return scripts.interactive_script_generator()
end

-- 快速生成所有脚本（基于当前项目模板）
function M.quick_generate_all_scripts()
	local scripts = require("qt-assistant.scripts")
	return scripts.quick_generate_scripts()
end

-- 检测项目构建系统
function M.detect_build_system()
	local scripts = require("qt-assistant.scripts")
	local build_system = scripts.detect_build_system()
	vim.notify("Detected build system: " .. build_system, vim.log.levels.INFO)
	return build_system
end

-- 编辑脚本
function M.edit_script(script_name)
	local scripts = require("qt-assistant.scripts")
	return scripts.edit_script(script_name)
end

-- 列出脚本
function M.list_scripts()
	local scripts = require("qt-assistant.scripts")
	return scripts.get_available_scripts()
end

-- UI设计师
function M.open_designer(ui_file)
	local designer = require("qt-assistant.designer")
	designer.open_designer(ui_file)
end

function M.open_designer_current()
	local designer = require("qt-assistant.designer")
	designer.open_designer_current()
end

function M.preview_ui(ui_file)
	local designer = require("qt-assistant.designer")
	designer.preview_ui(ui_file)
end

function M.sync_ui(ui_file)
	local designer = require("qt-assistant.designer")
	designer.sync_ui(ui_file)
end

function M.show_designer_manager()
	local ui = require("qt-assistant.ui")
	ui.show_designer_manager()
end

-- 系统信息
function M.show_system_info()
	local system = require("qt-assistant.system")
	system.show_system_info()
end

-- Qt版本管理
function M.show_qt_version_info()
	local qt_version = require("qt-assistant.qt_version")
	qt_version.show_qt_version_info(M._config.project_root)
end

function M.detect_qt_version()
	local qt_version = require("qt-assistant.qt_version")
	local detected_version = qt_version.get_recommended_qt_version(M._config.project_root)
	vim.notify("Detected Qt version: Qt" .. detected_version, vim.log.levels.INFO)
	return detected_version
end

function M.setup_qt_environment(version, path)
	local qt_version = require("qt-assistant.qt_version")
	return qt_version.setup_qt_environment(version, path)
end

-- 代码格式化功能
function M.format_current_file(formatter_name)
	local formatter = require("qt-assistant.formatter")
	formatter.format_current_file(formatter_name)
end

function M.format_project(formatter_name)
	local formatter = require("qt-assistant.formatter")
	formatter.format_project(formatter_name)
end

function M.show_formatter_status()
	local formatter = require("qt-assistant.formatter")
	formatter.show_formatter_status()
end

function M.create_clang_format_config()
	local formatter = require("qt-assistant.formatter")
	formatter.create_clang_format_config()
end

-- 快捷键帮助
function M.show_keymaps()
	local config = M.get_config()
	local keymaps_enabled = config.enable_default_keymaps

	local keymaps = {
		"=== Qt Assistant Keymaps ===",
		"",
		"Basic Commands:",
		"  :QtAssistant         - Open main interface",
		"  :QtQuickClass        - Quick class creator (interactive)",
		"  :QtCreateClass       - Create Qt class (with args)",
		"  :QtCreateMainWindow  - Create main window (interactive)",
		"  :QtCreateDialog      - Create dialog (interactive)",
		"  :QtCreateWidget      - Create widget (interactive)",
		"  :QtCreateModelClass  - Create model (interactive)",
		"",
		"Project Management:",
		"  :QtSmartSelector     - Auto open Qt project (smart & fast)",
		"  :QtChooseProject     - Choose from all Qt projects",
		"  :QtQuickSwitcher     - Quick project switcher (recent projects)",
		"  :QtGlobalSearch      - Global search all drives (comprehensive)",
		"  :QtSearchProjects    - Search for Qt projects",
		"  :QtRecentProjects    - Show recent projects",
		"  :QtOpenProject       - Open project",
		"  :QtNewProject        - Create new project",
		"  :QtProjectManager    - Project manager interface",
		"",
		"Build System:",
		"  :QtBuildProject      - Build project",
		"  :QtRunProject        - Run project",
		"  :QtCleanProject      - Clean project",
		"  :QtBuildStatus       - Show build status",
		"",
		"UI Designer:",
		"  :QtOpenDesigner      - Open Qt Designer",
		"  :QtOpenDesignerCurrent - Open Designer for current file",
		"  :QtPreviewUI         - Preview UI file",
		"  :QtSyncUI            - Sync UI file with source",
		"  :QtDesignerManager   - Designer manager interface",
		"",
		"Scripts:",
		"  :QtInitScripts       - Initialize project scripts",
		"  :QtScript <name>     - Run project script (build/run/debug/clean/test/deploy)",
		"  :QtScriptGenerator   - Interactive script generator",
		"  :QtGenerateAllScripts - Generate all scripts quickly",
		"  :QtDetectBuildSystem - Detect project build system",
		"",
		"Code Formatting:",
		"  :QtFormatFile        - Format current file",
		"  :QtFormatProject     - Format entire project",
		"  :QtFormatterStatus   - Show formatter status",
		"  :QtCreateClangFormat - Create .clang-format config",
		"",
		"System:",
		"  :QtSystemInfo        - Show system information",
		"  :QtVersionInfo       - Show Qt version information",
		"  :QtDetectVersion     - Detect Qt version",
		"  :QtKeymaps          - Show this help",
		"",
	}

	if keymaps_enabled then
		vim.list_extend(keymaps, {
			"Default Keymaps (ENABLED):",
			"",
			"Basic:",
			"  <leader>qc          - Qt Assistant",
			"  <leader>qh          - Qt Help",
			"",
			"Quick Class Creation:",
			"  <leader>qcc         - Quick Class Creator (choose type)",
			"  <leader>qcw         - Create Main Window",
			"  <leader>qcd         - Create Dialog",
			"  <leader>qcv         - Create Widget",
			"  <leader>qcm         - Create Model",
			"",
			"Project Core:",
			"  <leader>qpo         - Smart Open Project (⭐ Auto)",
			"  <leader>qpm         - Project Manager",
			"",
			"Project Switch:",
			"  <leader>qpc         - Choose Project (Manual)",
			"  <leader>qpw         - Quick Project Switcher (⚡ Fast)",
			"  <leader>qpr         - Recent Projects",
			"",
			"Project Search:",
			"  <leader>qps         - Search Qt Projects (Local)",
			"  <leader>qpg         - Global Search All Drives (🌍 Complete)",
			"",
			"Build System:",
			"  <leader>qb          - Build Project",
			"  <leader>qr          - Run Project",
			"  <leader>qcl         - Clean Project",
			"  <leader>qbs         - Build Status",
			"",
			"UI Designer:",
			"  <leader>qud         - Open Designer",
			"  <leader>quc         - Designer Current",
			"  <leader>qum         - Designer Manager",
			"",
			"Scripts:",
			"  <leader>qsb         - Script Build",
			"  <leader>qsr         - Script Run",
			"  <leader>qsd         - Script Debug",
			"  <leader>qsc         - Script Clean",
			"  <leader>qst         - Script Test",
			"  <leader>qsp         - Script Deploy",
			"  <leader>qsg         - Script Generator",
			"  <leader>qsa         - Generate All Scripts",
			"",
			"Code Formatting:",
			"  <leader>qff         - Format Current File",
			"  <leader>qfp         - Format Project",
			"  <leader>qfs         - Formatter Status",
			"  <leader>qfc         - Create .clang-format",
			"",
			"System & Qt Version:",
			"  <leader>qis         - System Info",
			"  <leader>qvi         - Qt Version Info",
			"  <leader>qvd         - Detect Qt Version",
		})
	else
		vim.list_extend(keymaps, {
			"Default Keymaps (DISABLED):",
			"  To enable, add to your config:",
			"  require('qt-assistant').setup({",
			"    enable_default_keymaps = true",
			"  })",
		})
	end

	-- 创建帮助窗口
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, keymaps)

	local width = 50
	local height = math.min(#keymaps + 2, 25)

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	vim.api.nvim_win_set_option(win, "number", false)
	vim.api.nvim_win_set_option(win, "relativenumber", false)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- 按q关闭
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", {
		noremap = true,
		silent = true,
	})
end

-- 配置构建环境
function M.configure_build_environment()
	local config = require('qt-assistant.config')
	local current_config = config.get()
	local build_env = current_config.build_environment or {}
	
	-- 创建交互式配置界面
	local choices = {
		"=== Qt Assistant Build Environment Configuration ===",
		"",
		"Current Settings:",
		"  VS2017 Path: " .. (build_env.vs2017_path ~= "" and build_env.vs2017_path or "(auto-detect)"),
		"  VS2019 Path: " .. (build_env.vs2019_path ~= "" and build_env.vs2019_path or "(auto-detect)"),
		"  VS2022 Path: " .. (build_env.vs2022_path ~= "" and build_env.vs2022_path or "(auto-detect)"),
		"  Prefer VS Version: " .. (build_env.prefer_vs_version or "2017"),
		"  MinGW Path: " .. (build_env.mingw_path ~= "" and build_env.mingw_path or "(auto-detect)"),
		"",
		"Configuration Options:",
		"",
		"1. Set VS2017 Path",
		"2. Set VS2019 Path", 
		"3. Set VS2022 Path",
		"4. Set Preferred VS Version",
		"5. Set MinGW Path",
		"6. Reset to Auto-detect",
		"7. Show Current Configuration",
		"0. Exit Configuration"
	}
	
	local choice = vim.fn.inputlist(choices)
	
	if choice == 1 then
		local path = vim.fn.input("Enter VS2017 installation path (e.g., C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Community): ")
		if path and path ~= "" then
			current_config.build_environment.vs2017_path = path
			config.setup(current_config)
			vim.notify("VS2017 path set to: " .. path, vim.log.levels.INFO)
			vim.notify("Run :QtScripts to regenerate scripts with new settings", vim.log.levels.INFO)
		end
		
	elseif choice == 2 then
		local path = vim.fn.input("Enter VS2019 installation path (e.g., C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community): ")
		if path and path ~= "" then
			current_config.build_environment.vs2019_path = path
			config.setup(current_config)
			vim.notify("VS2019 path set to: " .. path, vim.log.levels.INFO)
			vim.notify("Run :QtScripts to regenerate scripts with new settings", vim.log.levels.INFO)
		end
		
	elseif choice == 3 then
		local path = vim.fn.input("Enter VS2022 installation path (e.g., C:\\Program Files\\Microsoft Visual Studio\\2022\\Community): ")
		if path and path ~= "" then
			current_config.build_environment.vs2022_path = path
			config.setup(current_config)
			vim.notify("VS2022 path set to: " .. path, vim.log.levels.INFO)
			vim.notify("Run :QtScripts to regenerate scripts with new settings", vim.log.levels.INFO)
		end
		
	elseif choice == 4 then
		local vs_choices = {"1. Visual Studio 2017", "2. Visual Studio 2019", "3. Visual Studio 2022"}
		local vs_choice = vim.fn.inputlist(vim.list_extend({"Select preferred Visual Studio version:", ""}, vs_choices))
		local vs_versions = {"2017", "2019", "2022"}
		if vs_choice >= 1 and vs_choice <= 3 then
			current_config.build_environment.prefer_vs_version = vs_versions[vs_choice]
			config.setup(current_config)
			vim.notify("Preferred VS version set to: " .. vs_versions[vs_choice], vim.log.levels.INFO)
			vim.notify("Run :QtScripts to regenerate scripts with new settings", vim.log.levels.INFO)
		end
		
	elseif choice == 5 then
		local path = vim.fn.input("Enter MinGW installation path (e.g., C:\\mingw64): ")
		if path and path ~= "" then
			current_config.build_environment.mingw_path = path
			config.setup(current_config)
			vim.notify("MinGW path set to: " .. path, vim.log.levels.INFO)
		end
		
	elseif choice == 6 then
		current_config.build_environment = {
			vs2017_path = "",
			vs2019_path = "", 
			vs2022_path = "",
			prefer_vs_version = "2017",
			mingw_path = "",
			qt_version = "auto"
		}
		config.setup(current_config)
		vim.notify("Build environment reset to auto-detect", vim.log.levels.INFO)
		vim.notify("Run :QtScripts to regenerate scripts with new settings", vim.log.levels.INFO)
		
	elseif choice == 7 then
		M.show_build_environment_info()
		
	elseif choice == 0 then
		vim.notify("Configuration cancelled", vim.log.levels.WARN)
	else
		vim.notify("Invalid choice", vim.log.levels.WARN)
	end
end

-- 显示构建环境信息
function M.show_build_environment_info()
	local config = require('qt-assistant.config').get()
	local build_env = config.build_environment or {}
	
	local info = {
		"=== Current Build Environment Configuration ===",
		"",
		"Visual Studio Paths:",
		"  VS2017: " .. (build_env.vs2017_path ~= "" and build_env.vs2017_path or "(auto-detect)"),
		"  VS2019: " .. (build_env.vs2019_path ~= "" and build_env.vs2019_path or "(auto-detect)"),
		"  VS2022: " .. (build_env.vs2022_path ~= "" and build_env.vs2022_path or "(auto-detect)"),
		"",
		"Preferences:",
		"  Preferred VS Version: " .. (build_env.prefer_vs_version or "2017"),
		"  MinGW Path: " .. (build_env.mingw_path ~= "" and build_env.mingw_path or "(auto-detect)"),
		"  Qt Version Detection: " .. (build_env.qt_version or "auto"),
		"",
		"Usage:",
		"  - Use 'leader + q + p + c' to modify these settings",
		"  - Run ':QtScripts' after changing paths to regenerate scripts",
		"  - Scripts will use custom paths if provided, otherwise auto-detect"
	}
	
	vim.notify(table.concat(info, "\n"), vim.log.levels.INFO, {title = "Qt Assistant - Build Environment"})
end

return M

