-- Windows Qt5 配置示例
-- Example configuration for Qt5 on Windows

return {
    -- 基本配置
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
    
    -- Qt项目配置
    qt_project = {
        version = "Qt5", -- 强制使用Qt5
        qt5_path = "C:\\Qt\\5.15.2", -- Qt5安装路径
        qt6_path = "", -- 如果同时安装了Qt6
        auto_detect = true,
        build_type = "Debug",
        build_dir = "build",
        parallel_build = true,
        build_jobs = 4, -- 或者使用 os.getenv("NUMBER_OF_PROCESSORS")
        cmake_minimum_version = "3.5",
        cxx_standard = "14",
    },
    
    -- Windows特殊配置
    global_search = {
        enabled = true,
        max_depth = 3,
        include_system_paths = true,
        custom_search_paths = {
            "C:\\Projects",
            "D:\\Dev",
        },
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
    
    -- Designer配置
    designer = {
        designer_path = "designer.exe", -- 会自动从Qt路径中查找
        creator_path = "qtcreator.exe",
        default_editor = "designer",
        custom_editor = { command = "", args = { "--file", "{file}" } },
        auto_sync = true,
        enable_preview = true,
    },
    
    -- 调试配置
    debug = {
        enabled = true,
        log_level = "INFO",
        log_file = vim.fn.stdpath("data") .. "\\qt-assistant.log",
    },
    
    -- 启用默认快捷键
    enable_default_keymaps = true,
    
    -- 其他配置
    naming_convention = "snake_case",
    auto_update_cmake = true,
    generate_comments = true,
    template_path = vim.fn.stdpath("config") .. "\\qt-templates",
}