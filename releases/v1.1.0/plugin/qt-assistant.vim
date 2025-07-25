" Qt Assistant Plugin - Vim script entry point
" Neovim Qt项目辅助插件入口

if exists('g:loaded_qt_assistant')
    finish
endif

let g:loaded_qt_assistant = 1

" 设置默认配置
if !exists('g:qt_assistant_config')
    let g:qt_assistant_config = {}
endif

" 延迟加载Lua模块
function! s:LoadQtAssistant()
    lua require('qt-assistant')
endfunction

" 注册命令
command! -nargs=+ -complete=customlist,s:CompleteClassTypes QtCreateClass call s:LoadQtAssistant() | lua require('qt-assistant').create_class(<f-args>)
command! -nargs=+ QtCreateUI call s:LoadQtAssistant() | lua require('qt-assistant').create_ui(<f-args>)
command! -nargs=1 QtCreateModel call s:LoadQtAssistant() | lua require('qt-assistant').create_model(<f-args>)
command! QtAssistant call s:LoadQtAssistant() | lua require('qt-assistant.ui').show_class_creator()
command! -nargs=1 -complete=customlist,s:CompleteScriptNames QtScript call s:LoadQtAssistant() | lua require('qt-assistant.scripts').run_script(<f-args>)
command! QtScriptManager call s:LoadQtAssistant() | lua require('qt-assistant.ui').show_script_manager()
command! QtInitScripts call s:LoadQtAssistant() | lua require('qt-assistant.scripts').init_scripts_directory()
command! QtHelp call s:LoadQtAssistant() | lua require('qt-assistant.ui').show_help()

" 项目管理命令
command! -nargs=? -complete=dir QtOpenProject call s:LoadQtAssistant() | lua require('qt-assistant.project_manager').open_project(<f-args>)
command! -nargs=+ -complete=customlist,s:CompleteProjectTemplates QtNewProject call s:LoadQtAssistant() | lua require('qt-assistant.project_manager').new_project(<f-args>)
command! QtListTemplates call s:LoadQtAssistant() | lua require('qt-assistant.project_manager').list_templates()
command! QtProjectManager call s:LoadQtAssistant() | lua require('qt-assistant.ui').show_project_manager()

" 构建管理命令
command! -nargs=? -complete=customlist,s:CompleteBuildTypes QtBuildProject call s:LoadQtAssistant() | lua require('qt-assistant.build_manager').build_project(<f-args>)
command! QtRunProject call s:LoadQtAssistant() | lua require('qt-assistant.build_manager').run_project()
command! QtCleanProject call s:LoadQtAssistant() | lua require('qt-assistant.build_manager').clean_project()
command! QtBuildStatus call s:LoadQtAssistant() | lua require('qt-assistant.ui').show_build_manager()

" UI设计师命令
command! -nargs=? -complete=file QtOpenDesigner call s:LoadQtAssistant() | lua require('qt-assistant.designer').open_designer(<f-args>)
command! QtOpenDesignerCurrent call s:LoadQtAssistant() | lua require('qt-assistant.designer').open_designer_current()
command! -nargs=? -complete=file QtPreviewUI call s:LoadQtAssistant() | lua require('qt-assistant.designer').preview_ui(<f-args>)
command! -nargs=? -complete=file QtSyncUI call s:LoadQtAssistant() | lua require('qt-assistant.designer').sync_ui(<f-args>)
command! QtDesignerManager call s:LoadQtAssistant() | lua require('qt-assistant.ui').show_designer_manager()

" 命令补全函数
function! s:CompleteClassTypes(ArgLead, CmdLine, CursorPos)
    return ['main_window', 'dialog', 'widget', 'model', 'delegate', 'thread', 'utility', 'singleton']
endfunction

function! s:CompleteScriptNames(ArgLead, CmdLine, CursorPos)
    return ['build', 'clean', 'run', 'debug', 'test']
endfunction

function! s:CompleteProjectTemplates(ArgLead, CmdLine, CursorPos)
    return ['widget_app', 'quick_app', 'console_app', 'library']
endfunction

function! s:CompleteBuildTypes(ArgLead, CmdLine, CursorPos)
    return ['Debug', 'Release', 'RelWithDebInfo', 'MinSizeRel']
endfunction

" 设置快捷键（可选）
if get(g:, 'qt_assistant_setup_keymaps', 1)
    " === 基础功能快捷键 ===
    " 类创建和主界面
    nnoremap <leader>qc :QtAssistant<CR>
    nnoremap <leader>qh :QtHelp<CR>
    
    " === 项目管理快捷键 ===
    " 项目操作
    nnoremap <leader>qpo :QtOpenProject<CR>
    nnoremap <leader>qpn :QtNewProject 
    nnoremap <leader>qpt :QtListTemplates<CR>
    nnoremap <leader>qpm :QtProjectManager<CR>
    
    " === 构建管理快捷键 ===
    " 构建和运行
    nnoremap <leader>qb :QtBuildProject<CR>
    nnoremap <leader>qr :QtRunProject<CR>
    nnoremap <leader>qcl :QtCleanProject<CR>
    nnoremap <leader>qbs :QtBuildStatus<CR>
    
    " === 脚本管理快捷键 ===
    " 脚本执行
    nnoremap <leader>qsb :QtScript build<CR>
    nnoremap <leader>qsr :QtScript run<CR>
    nnoremap <leader>qsd :QtScript debug<CR>
    nnoremap <leader>qsc :QtScript clean<CR>
    nnoremap <leader>qst :QtScript test<CR>
    nnoremap <leader>qsm :QtScriptManager<CR>
    
    " === UI设计师快捷键 ===
    " UI设计和管理
    nnoremap <leader>qud :QtOpenDesigner<CR>
    nnoremap <leader>quc :QtOpenDesignerCurrent<CR>
    nnoremap <leader>qup :QtPreviewUI<CR>
    nnoremap <leader>qus :QtSyncUI<CR>
    nnoremap <leader>qum :QtDesignerManager<CR>
    
    " === 快速类创建快捷键 ===
    " 常用类类型快捷创建
    nnoremap <leader>qcw :QtCreateClass 
    nnoremap <leader>qcd :QtCreateClass 
    nnoremap <leader>qcv :QtCreateClass 
    nnoremap <leader>qcm :QtCreateModel 
    
    " === 一键操作快捷键 ===
    " 常用组合操作
    nnoremap <leader>qbr :QtBuildProject<CR>:QtRunProject<CR>
    nnoremap <leader>qcb :QtCleanProject<CR>:QtBuildProject<CR>
endif

" 创建快捷键帮助命令
command! QtKeymaps call s:ShowKeymaps()

function! s:ShowKeymaps()
    let keymap_help = [
        \ "Qt Assistant - Keyboard Shortcuts",
        \ "=" . repeat("=", 40),
        \ "",
        \ "Basic Operations:",
        \ "  <leader>qc  - Open Qt Assistant",
        \ "  <leader>qh  - Show help",
        \ "",
        \ "Project Management:",
        \ "  <leader>qpo - Open project",
        \ "  <leader>qpn - New project (need to complete command)",
        \ "  <leader>qpt - List templates", 
        \ "  <leader>qpm - Project manager",
        \ "",
        \ "Build Management:",
        \ "  <leader>qb  - Build project",
        \ "  <leader>qr  - Run project", 
        \ "  <leader>qcl - Clean project",
        \ "  <leader>qbs - Build status",
        \ "",
        \ "Script Management:",
        \ "  <leader>qsb - Script build",
        \ "  <leader>qsr - Script run",
        \ "  <leader>qsd - Script debug",
        \ "  <leader>qsc - Script clean",
        \ "  <leader>qst - Script test",
        \ "  <leader>qsm - Script manager",
        \ "",
        \ "UI Designer:",
        \ "  <leader>qud - Open Designer",
        \ "  <leader>quc - Open Designer (current file)",
        \ "  <leader>qup - Preview UI",
        \ "  <leader>qus - Sync UI",
        \ "  <leader>qum - Designer manager",
        \ "",
        \ "Quick Class Creation:",
        \ "  <leader>qcw - Create widget (need to complete)",
        \ "  <leader>qcd - Create dialog (need to complete)",
        \ "  <leader>qcv - Create view (need to complete)",
        \ "  <leader>qcm - Create model (need to complete)",
        \ "",
        \ "Combo Operations:",
        \ "  <leader>qbr - Build and run",
        \ "  <leader>qcb - Clean and build",
        \ "",
        \ "Note: Replace <leader> with your actual leader key (usually \\)",
        \ "Press 'q' or <Esc> to close this help"
    \ ]
    
    " 创建帮助缓冲区
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:false, keymap_help)
    
    " 创建浮动窗口
    let width = 60
    let height = min([len(keymap_help) + 2, 30])
    let col = ((&columns - width) / 2)
    let row = ((&lines - height) / 2)
    
    let opts = {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'col': col,
        \ 'row': row,
        \ 'style': 'minimal',
        \ 'border': 'rounded'
    \ }
    
    let win = nvim_open_win(buf, v:true, opts)
    
    " 设置窗口选项
    call nvim_win_set_option(win, 'number', v:false)
    call nvim_win_set_option(win, 'relativenumber', v:false)
    call nvim_buf_set_option(buf, 'modifiable', v:false)
    
    " 设置关闭快捷键
    call nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {'noremap': v:true, 'silent': v:true})
    call nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', {'noremap': v:true, 'silent': v:true})
endfunction