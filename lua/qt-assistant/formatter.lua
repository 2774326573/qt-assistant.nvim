-- Qt Assistant Plugin - 代码格式化模块
-- Code formatting module

local M = {}
local system = require("qt-assistant.system")

-- 获取插件配置
local function get_config()
	return require("qt-assistant").get_config()
end

-- 格式化工具配置
local formatters = {
	clang_format = {
		name = "clang-format",
		command = "clang-format",
		args = { "-i" }, -- -i 表示就地格式化
		args_stdout = {}, -- 输出到标准输出（用于BufWritePre）
		file_types = { "cpp", "c", "h", "hpp", "cc", "cxx" },
		check_command = function()
			return system.command_exists("clang-format")
		end,
	},
	astyle = {
		name = "Artistic Style",
		command = "astyle",
		args = { "--style=google", "--indent=spaces=4", "--max-code-length=120" },
		file_types = { "cpp", "c", "h", "hpp", "cc", "cxx" },
		check_command = function()
			return system.command_exists("astyle")
		end,
	},
}

-- 检测可用的格式化工具
function M.detect_available_formatters()
	local available = {}

	for name, formatter in pairs(formatters) do
		if formatter.check_command() then
			table.insert(available, {
				name = name,
				formatter = formatter,
			})
		end
	end

	return available
end

-- 获取文件类型
local function get_file_type(file_path)
	local extension = file_path:match("%.([^%.]+)$")
	if not extension then
		return nil
	end

	return extension:lower()
end

-- 检查文件是否支持格式化
function M.is_formattable_file(file_path)
	local file_type = get_file_type(file_path)
	if not file_type then
		return false
	end

	for _, formatter in pairs(formatters) do
		for _, supported_type in ipairs(formatter.file_types) do
			if file_type == supported_type then
				return true
			end
		end
	end

	return false
end

-- 格式化单个文件
function M.format_file(file_path, formatter_name)
	if not M.is_formattable_file(file_path) then
		vim.notify("File type not supported for formatting: " .. file_path, vim.log.levels.WARN)
		return false
	end

	local available_formatters = M.detect_available_formatters()
	if #available_formatters == 0 then
		vim.notify("No formatters available. Please install clang-format or astyle.", vim.log.levels.ERROR)
		return false
	end

	-- 选择格式化工具
	local selected_formatter = nil
	if formatter_name then
		for _, fmt in ipairs(available_formatters) do
			if fmt.name == formatter_name then
				selected_formatter = fmt.formatter
				break
			end
		end
	else
		-- 默认使用第一个可用的格式化工具
		selected_formatter = available_formatters[1].formatter
	end

	if not selected_formatter then
		vim.notify("Formatter not found: " .. (formatter_name or "default"), vim.log.levels.ERROR)
		return false
	end

	-- 构建格式化命令
	local cmd = { selected_formatter.command }
	for _, arg in ipairs(selected_formatter.args) do
		table.insert(cmd, arg)
	end
	table.insert(cmd, file_path)

	vim.notify(
		"Formatting " .. vim.fn.fnamemodify(file_path, ":t") .. " with " .. selected_formatter.name .. "...",
		vim.log.levels.INFO
	)

	-- 执行格式化命令
	local success = false
	local job_id = vim.fn.jobstart(cmd, {
		on_exit = function(_, exit_code)
			success = (exit_code == 0)
			if success then
				vim.notify("File formatted successfully!", vim.log.levels.INFO)
				-- 重新加载文件以显示格式化结果
				vim.cmd("checktime")
			else
				vim.notify("Formatting failed!", vim.log.levels.ERROR)
			end
		end,
		on_stderr = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						vim.notify("Formatter error: " .. line, vim.log.levels.ERROR)
					end
				end
			end
		end,
	})

	if job_id <= 0 then
		vim.notify("Failed to start formatter", vim.log.levels.ERROR)
		return false
	end

	-- 等待命令完成
	vim.fn.jobwait({ job_id })

	return success
end

-- 格式化当前文件
function M.format_current_file(formatter_name)
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		vim.notify("No file is currently open", vim.log.levels.WARN)
		return false
	end

	return M.format_file(current_file, formatter_name)
end

-- 格式化目录中的所有支持文件
function M.format_directory(directory_path, formatter_name)
	if not system.directory_exists(directory_path) then
		vim.notify("Directory does not exist: " .. directory_path, vim.log.levels.ERROR)
		return false
	end

	local formatted_count = 0
	local function format_recursive(dir)
		local handle = vim.loop.fs_scandir(dir)
		if not handle then
			return
		end

		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			local full_path = system.join_path(dir, name)

			if type == "file" and M.is_formattable_file(full_path) then
				if M.format_file(full_path, formatter_name) then
					formatted_count = formatted_count + 1
				end
			elseif type == "directory" and name ~= "." and name ~= ".." and not name:match("^%.") then
				-- 递归格式化子目录，但跳过隐藏目录
				format_recursive(full_path)
			end
		end
	end

	format_recursive(directory_path)

	vim.notify(string.format("Formatted %d files in %s", formatted_count, directory_path), vim.log.levels.INFO)
	return formatted_count > 0
end

-- 格式化项目中的所有源文件
function M.format_project(formatter_name)
	local config = get_config()
	local project_root = vim.fn.getcwd() -- 使用当前工作目录

	local source_dirs = {
		project_root .. "/" .. (config.directories.source or "src"),
		project_root .. "/" .. (config.directories.include or "include"),
	}

	local total_formatted = 0
	for _, source_dir in ipairs(source_dirs) do
		if system.directory_exists(source_dir) then
			local count = M.format_directory(source_dir, formatter_name)
			if count then
				total_formatted = total_formatted + count
			end
		end
	end

	-- 也格式化项目根目录下的源文件
	local root_count = M.format_directory(project_root, formatter_name)
	if root_count then
		total_formatted = total_formatted + root_count
	end

	if total_formatted == 0 then
		vim.notify("No files were formatted", vim.log.levels.WARN)
	else
		vim.notify(
			string.format("Project formatting complete! Formatted %d files", total_formatted),
			vim.log.levels.INFO
		)
	end

	return total_formatted > 0
end

-- 创建.clang-format配置文件
function M.create_clang_format_config()
	local project_root = vim.fn.getcwd()
	local config_file = project_root .. "/.clang-format"

	if vim.fn.filereadable(config_file) == 1 then
		local overwrite = vim.fn.confirm(".clang-format already exists. Overwrite?", "&Yes\n&No", 2)
		if overwrite ~= 1 then
			return false
		end
	end

	local clang_format_config = [[# Qt C++ Code Style Configuration
BasedOnStyle: Google
IndentWidth: 4
TabWidth: 4
UseTab: Never
ColumnLimit: 120
AccessModifierOffset: -2
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
AlignConsecutiveDeclarations: false
AlignOperands: true
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: false
AllowShortBlocksOnASingleLine: false
AllowShortCaseLabelsOnASingleLine: false
AllowShortFunctionsOnASingleLine: Empty
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: true
BinPackArguments: false
BinPackParameters: false
BreakBeforeBinaryOperators: NonAssignment
BreakBeforeBraces: Attach
BreakBeforeInheritanceComma: false
BreakBeforeTernaryOperators: true
BreakConstructorInitializersBeforeComma: false
BreakAfterJavaFieldAnnotations: false
BreakStringLiterals: true
Cpp11BracedListStyle: true
DerivePointerAlignment: false
DisableFormat: false
ExperimentalAutoDetectBinPacking: false
FixNamespaceComments: true
IncludeBlocks: Preserve
IndentCaseLabels: true
IndentPPDirectives: None
IndentWrappedFunctionNames: false
KeepEmptyLinesAtTheStartOfBlocks: false
MacroBlockBegin: ''
MacroBlockEnd: ''
MaxEmptyLinesToKeep: 1
NamespaceIndentation: None
PenaltyBreakAssignment: 2
PenaltyBreakBeforeFirstCallParameter: 19
PenaltyBreakComment: 300
PenaltyBreakFirstLessLess: 120
PenaltyBreakString: 1000
PenaltyExcessCharacter: 1000000
PenaltyReturnTypeOnItsOwnLine: 60
PointerAlignment: Left
ReflowComments: true
SortIncludes: true
SortUsingDeclarations: true
SpaceAfterCStyleCast: false
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeParens: ControlStatements
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 2
SpacesInAngles: false
SpacesInContainerLiterals: true
SpacesInCStyleCastParentheses: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
Standard: Cpp11
]]

	local file = io.open(config_file, "w")
	if file then
		file:write(clang_format_config)
		file:close()
		vim.notify("Created .clang-format configuration file", vim.log.levels.INFO)
		return true
	else
		vim.notify("Failed to create .clang-format file", vim.log.levels.ERROR)
		return false
	end
end

-- 显示格式化工具状态
function M.show_formatter_status()
	local available_formatters = M.detect_available_formatters()

	local status_lines = {}
	table.insert(status_lines, "=== Code Formatter Status ===")
	table.insert(status_lines, "")

	if #available_formatters == 0 then
		table.insert(status_lines, "❌ No formatters available")
		table.insert(status_lines, "")
		table.insert(status_lines, "Install one of the following:")
		table.insert(status_lines, "  • clang-format (recommended)")
		table.insert(status_lines, "  • astyle")
		table.insert(status_lines, "")
		table.insert(status_lines, "Installation commands:")
		local sys = system.detect_os()
		if sys.is_windows then
			table.insert(status_lines, "  Windows: winget install LLVM.LLVM")
		elseif sys.is_macos then
			table.insert(status_lines, "  macOS: brew install clang-format")
		else
			table.insert(status_lines, "  Ubuntu: sudo apt install clang-format")
			table.insert(status_lines, "  CentOS: sudo dnf install clang-tools-extra")
		end
	else
		table.insert(status_lines, "✅ Available formatters:")
		for _, fmt in ipairs(available_formatters) do
			table.insert(status_lines, "  • " .. fmt.formatter.name)
		end
		table.insert(status_lines, "")
		table.insert(status_lines, "Commands:")
		table.insert(status_lines, "  f - Format current file")
		table.insert(status_lines, "  p - Format entire project")
		table.insert(status_lines, "  c - Create .clang-format config")
	end

	table.insert(status_lines, "  q - Close")

	-- 显示状态窗口
	M.show_formatter_window(status_lines, available_formatters)
end

-- 显示格式化工具窗口
function M.show_formatter_window(lines, available_formatters)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = 60
	local height = math.min(#lines + 2, 20)

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

	local function close_window()
		vim.api.nvim_win_close(win, true)
	end

	-- 设置键盘映射
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		callback = close_window,
		noremap = true,
		silent = true,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
		callback = close_window,
		noremap = true,
		silent = true,
	})

	if #available_formatters > 0 then
		vim.api.nvim_buf_set_keymap(buf, "n", "f", "", {
			callback = function()
				close_window()
				M.format_current_file()
			end,
			noremap = true,
			silent = true,
		})

		vim.api.nvim_buf_set_keymap(buf, "n", "p", "", {
			callback = function()
				close_window()
				M.format_project()
			end,
			noremap = true,
			silent = true,
		})

		vim.api.nvim_buf_set_keymap(buf, "n", "c", "", {
			callback = function()
				close_window()
				M.create_clang_format_config()
			end,
			noremap = true,
			silent = true,
		})
	end
end

-- 设置自动格式化
-- 在保存前格式化缓冲区内容（不修改磁盘文件）
function M.format_buffer_content()
	local config = get_config()
	if not (config.auto_format and config.auto_format.enabled) then
		return
	end

	local file_path = vim.fn.expand("%:p")
	if not M.is_formattable_file(file_path) then
		return
	end

	local available_formatters = M.detect_available_formatters()
	if #available_formatters == 0 then
		return
	end

	-- 选择格式化工具
	local selected_formatter = nil
	if config.auto_format.formatter then
		for _, fmt in ipairs(available_formatters) do
			if fmt.name == config.auto_format.formatter then
				selected_formatter = fmt.formatter
				break
			end
		end
	else
		selected_formatter = available_formatters[1].formatter
	end

	if not selected_formatter then
		return
	end

	-- 获取缓冲区内容
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local content = table.concat(lines, "\n")

	-- 构建格式化命令（输出到stdout）
	local cmd = { selected_formatter.command }
	for _, arg in ipairs(selected_formatter.args_stdout or {}) do
		table.insert(cmd, arg)
	end

	-- 使用同步方式执行格式化
	local result = vim.fn.system(cmd, content)
	local exit_code = vim.v.shell_error

	if exit_code == 0 and result and result ~= "" then
		-- 分割结果为行
		local formatted_lines = vim.split(result, "\n")
		-- 移除最后的空行（如果存在）
		if #formatted_lines > 0 and formatted_lines[#formatted_lines] == "" then
			table.remove(formatted_lines, #formatted_lines)
		end

		-- 检查是否有实际变化
		local current_content = table.concat(lines, "\n")
		local formatted_content = table.concat(formatted_lines, "\n")

		if current_content ~= formatted_content then
			-- 更新缓冲区内容
			vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_lines)
		end
	end
end

function M.setup_auto_format()
	-- 检查是否有可用的格式化工具
	local available_formatters = M.detect_available_formatters()
	if #available_formatters == 0 then
		vim.notify(
			"No code formatters available. Install clang-format or astyle for auto-formatting.",
			vim.log.levels.WARN
		)
		return
	end

	-- 创建自动命令组
	vim.api.nvim_create_augroup("QtAssistantAutoFormat", { clear = true })

	-- 在保存时自动格式化C++文件
	vim.api.nvim_create_autocmd({ "BufWritePre" }, {
		group = "QtAssistantAutoFormat",
		pattern = { "*.cpp", "*.h", "*.hpp", "*.cc", "*.cxx", "*.c" },
		callback = function()
			M.format_buffer_content()
		end,
	})
end

return M
