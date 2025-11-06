-- Example configuration for Qt Assistant Plugin
-- Copy this to your init.lua or put it in a separate file

-- Basic setup
require('qt-assistant').setup({
    -- Project settings
    project_root = vim.fn.getcwd(),
    
    -- Directory structure  
    directories = {
        source = "src",
        include = "include", 
        ui = "ui",
        resource = "resources"
    },
    
    -- Auto update CMakeLists.txt when adding files
    auto_update_cmake = true,
    auto_rebuild_on_cmake_change = false,
    
    -- Qt tools paths (will auto-detect if not specified)
    qt_tools = {
        designer_path = "designer",
        uic_path = "uic",
        qmake_path = "qmake", 
        cmake_path = "cmake",
        creator_path = "qtcreator"
    },
    
    -- Enable default keymaps
    enable_default_keymaps = true
})

-- Default keymaps are automatically enabled. Manual setup:
-- require('qt-assistant').setup_keymaps()

--[[ 
Key mappings overview (with enable_default_keymaps = true):

Core Qt Assistant:
<leader>qa  - Open Qt Assistant interface
<leader>qh  - Show Qt Help

Project Management:
<leader>qp  - New Qt Project (Interactive with C++ standard selection)
<leader>qP  - New Qt Project (Quick C++17 widget app)
<leader>qo  - Open Qt Project

UI Designer:
<leader>qd  - Open Qt Designer
<leader>qu  - Create new UI file
<leader>qe  - Edit current/select UI file

Class Creation:
<leader>qc  - Create Qt Class (Interactive)
<leader>qf  - Create Class from current UI file

Build System:
<leader>qb   - Build Project (default)
<leader>qb1  - Build with C++11
<leader>qb4  - Build with C++14
<leader>qb7  - Build with C++17
<leader>qb20 - Build with C++20
<leader>qr   - Run Project
<leader>qA   - Quick Build & Run

Configuration & Standards:
<leader>qsc - Show Current Config (C++ standard, Qt version, etc.)
<leader>qss - Select C++ Standard
<leader>qsr - Reconfigure Project

LSP Integration:
<leader>qls - Setup Qt LSP
<leader>qlg - Generate Compile Commands
<leader>qlt - LSP Status

Debug System:
<leader>qdb - Debug Qt Application
<leader>qda - Attach to Qt Process
--]]
