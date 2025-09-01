-- Qt Assistant Plugin - Template management module
-- 模板管理模块

local M = {}

-- Template configurations
local template_configs = {
    main_window = {
        has_header = true,
        has_source = true,
        has_ui = true,
        base_class = "QMainWindow"
    },
    dialog = {
        has_header = true,
        has_source = true,
        has_ui = true,
        base_class = "QDialog"
    },
    widget = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QWidget"
    },
    model = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QAbstractItemModel"
    }
}

-- Built-in templates
local builtin_templates = {}

-- Initialize templates
function M.init()
    M.load_builtin_templates()
end

-- Load built-in templates
function M.load_builtin_templates()
    -- Main Window Header Template
    builtin_templates.main_window_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QMainWindow>
{{#HAS_UI_FILE}}

QT_BEGIN_NAMESPACE
class Ui_{{UI_CLASS_NAME}};
QT_END_NAMESPACE
{{/HAS_UI_FILE}}

class {{CLASS_NAME}} : public QMainWindow
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QWidget *parent = nullptr);
    ~{{CLASS_NAME}}();

private slots:
    void onActionTriggered();

private:
    void setupUI();
{{#HAS_UI_FILE}}
    Ui_{{UI_CLASS_NAME}} *ui;
{{/HAS_UI_FILE}}
};

#endif // {{HEADER_GUARD}}
]]

    -- Main Window Source Template
    builtin_templates.main_window_source = [[
#include "{{FILE_NAME}}.h"
{{#HAS_UI_FILE}}
#include "{{UI_HEADER}}"
{{/HAS_UI_FILE}}

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QMainWindow(parent)
{{#HAS_UI_FILE}}
    , ui(new Ui_{{UI_CLASS_NAME}})
{{/HAS_UI_FILE}}
{
    setupUI();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
{{#HAS_UI_FILE}}
    delete ui;
{{/HAS_UI_FILE}}
}

void {{CLASS_NAME}}::setupUI()
{
{{#HAS_UI_FILE}}
    ui->setupUi(this);
{{/HAS_UI_FILE}}
{{^HAS_UI_FILE}}
    // TODO: Setup UI manually
{{/HAS_UI_FILE}}
}

void {{CLASS_NAME}}::onActionTriggered()
{
    // TODO: Handle action
}
]]

    -- Dialog templates
    builtin_templates.dialog_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QDialog>
{{#HAS_UI_FILE}}

QT_BEGIN_NAMESPACE
class Ui_{{UI_CLASS_NAME}};
QT_END_NAMESPACE
{{/HAS_UI_FILE}}

class {{CLASS_NAME}} : public QDialog
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QWidget *parent = nullptr);
    ~{{CLASS_NAME}}();

private slots:
    void accept() override;
    void reject() override;

private:
    void setupUI();
{{#HAS_UI_FILE}}
    Ui_{{UI_CLASS_NAME}} *ui;
{{/HAS_UI_FILE}}
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.dialog_source = [[
#include "{{FILE_NAME}}.h"
{{#HAS_UI_FILE}}
#include "{{UI_HEADER}}"
{{/HAS_UI_FILE}}

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QDialog(parent)
{{#HAS_UI_FILE}}
    , ui(new Ui_{{UI_CLASS_NAME}})
{{/HAS_UI_FILE}}
{
    setupUI();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
{{#HAS_UI_FILE}}
    delete ui;
{{/HAS_UI_FILE}}
}

void {{CLASS_NAME}}::setupUI()
{
{{#HAS_UI_FILE}}
    ui->setupUi(this);
{{/HAS_UI_FILE}}
{{^HAS_UI_FILE}}
    // TODO: Setup UI manually
{{/HAS_UI_FILE}}
}

void {{CLASS_NAME}}::accept()
{
    // TODO: Validate and accept
    QDialog::accept();
}

void {{CLASS_NAME}}::reject()
{
    // TODO: Handle rejection
    QDialog::reject();
}
]]

    -- Widget templates
    builtin_templates.widget_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QWidget>

class {{CLASS_NAME}} : public QWidget
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QWidget *parent = nullptr);
    ~{{CLASS_NAME}}();

private:
    void setupUI();
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.widget_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QWidget(parent)
{
    setupUI();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
}

void {{CLASS_NAME}}::setupUI()
{
    // TODO: Setup UI
}
]]

    -- Model template
    builtin_templates.model_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QAbstractItemModel>

class {{CLASS_NAME}} : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);

    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
    // TODO: Add your data members
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.model_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QAbstractItemModel(parent)
{
}

QModelIndex {{CLASS_NAME}}::index(int row, int column, const QModelIndex &parent) const
{
    // TODO: Implement
    Q_UNUSED(row)
    Q_UNUSED(column)
    Q_UNUSED(parent)
    return QModelIndex();
}

QModelIndex {{CLASS_NAME}}::parent(const QModelIndex &child) const
{
    // TODO: Implement
    Q_UNUSED(child)
    return QModelIndex();
}

int {{CLASS_NAME}}::rowCount(const QModelIndex &parent) const
{
    // TODO: Implement
    Q_UNUSED(parent)
    return 0;
}

int {{CLASS_NAME}}::columnCount(const QModelIndex &parent) const
{
    // TODO: Implement
    Q_UNUSED(parent)
    return 0;
}

QVariant {{CLASS_NAME}}::data(const QModelIndex &index, int role) const
{
    // TODO: Implement
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}
]]

    -- UI templates
    builtin_templates.main_window_ui = [[
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>{{CLASS_NAME}}</class>
 <widget class="QMainWindow" name="{{CLASS_NAME}}">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>{{CLASS_NAME}}</string>
  </property>
  <widget class="QWidget" name="centralwidget"/>
  <widget class="QMenuBar" name="menubar"/>
  <widget class="QStatusBar" name="statusbar"/>
 </widget>
 <resources/>
 <connections/>
</ui>
]]

    builtin_templates.dialog_ui = [[
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>{{CLASS_NAME}}</class>
 <widget class="QDialog" name="{{CLASS_NAME}}">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>400</width>
    <height>300</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>{{CLASS_NAME}}</string>
  </property>
 </widget>
 <resources/>
 <connections/>
</ui>
]]

    -- Project templates
    builtin_templates.main_widget_app = [[
#include <QApplication>
#include "{{FILE_NAME}}.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    {{CLASS_NAME}} window;
    window.show();
    
    return app.exec();
}
]]

    builtin_templates.main_console_app = [[
#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    qDebug() << "Hello Qt Console Application!";
    
    return app.exec();
}
]]

    builtin_templates.cmake_widget_app = [[
cmake_minimum_required(VERSION 3.16)
project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

# C++ Standard (Qt5 requires C++11+, Qt6 requires C++17+)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt settings - enable before finding Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt (prioritize Qt6, fallback to Qt5.15+)
find_package(Qt6 COMPONENTS Core Widgets QUIET)
if(Qt6_FOUND)
    message(STATUS "Using Qt6: ${Qt6_VERSION}")
    set(QT_VERSION_MAJOR 6)
else()
    find_package(Qt5 5.15 COMPONENTS Core Widgets QUIET)
    if(Qt5_FOUND)
        message(STATUS "Using Qt5: ${Qt5_VERSION}")
        set(QT_VERSION_MAJOR 5)
        # Qt5 requires C++11 minimum
        set(CMAKE_CXX_STANDARD 11)
    else()
        message(FATAL_ERROR "Qt5 (5.15+) or Qt6 is required")
    endif()
endif()

# Source files
set(SOURCES
    src/main.cpp
    src/mainwindow.cpp
)

set(HEADERS
    include/mainwindow.h
)

set(UI_FILES
    ui/mainwindow.ui
)

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} ${UI_FILES})

# Link Qt libraries (version-aware)
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME} 
        Qt6::Core 
        Qt6::Widgets
    )
    
    # Qt6 specific settings
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        MACOSX_BUNDLE TRUE
    )
else()
    target_link_libraries(${PROJECT_NAME} 
        Qt5::Core 
        Qt5::Widgets
    )
    
    # Qt5 specific settings
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        MACOSX_BUNDLE TRUE
    )
endif()

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE 
    include
    ${CMAKE_CURRENT_BINARY_DIR}  # For generated UI headers
)

# Compiler-specific settings
if(MSVC)
    # Windows-specific settings for both Qt5/Qt6
    target_compile_definitions(${PROJECT_NAME} PRIVATE 
        _CRT_SECURE_NO_WARNINGS
        NOMINMAX
    )
endif()
]]

    builtin_templates.cmake_console_app = [[
cmake_minimum_required(VERSION 3.16)
project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

# C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt (prioritize Qt6, fallback to Qt5.15+)
find_package(Qt6 COMPONENTS Core QUIET)
if(Qt6_FOUND)
    message(STATUS "Using Qt6: ${Qt6_VERSION}")
    set(QT_VERSION_MAJOR 6)
else()
    find_package(Qt5 5.15 COMPONENTS Core QUIET)
    if(Qt5_FOUND)
        message(STATUS "Using Qt5: ${Qt5_VERSION}")
        set(QT_VERSION_MAJOR 5)
        set(CMAKE_CXX_STANDARD 11)
    else()
        message(FATAL_ERROR "Qt5 (5.15+) or Qt6 is required")
    endif()
endif()

# Source files
set(SOURCES
    src/main.cpp
)

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Link Qt libraries
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME} Qt6::Core)
else()
    target_link_libraries(${PROJECT_NAME} Qt5::Core)
endif()
]]
end

-- Get template configuration
function M.get_template_config(class_type)
    return template_configs[class_type]
end

-- Render template with conditional blocks
function M.render_template(template_name, variables)
    local template = builtin_templates[template_name]
    if not template then
        return nil, "Template not found: " .. template_name
    end

    local rendered = template
    variables = variables or {}
    
    -- Process conditional blocks {{#VAR}}...{{/VAR}}
    rendered = rendered:gsub("{{#([^}]+)}}(.-){{/[^}]+}}", function(var_name, content)
        if variables[var_name] then
            return content
        else
            return ""
        end
    end)
    
    -- Process negative conditional blocks {{^VAR}}...{{/VAR}}
    rendered = rendered:gsub("{{%^([^}]+)}}(.-){{/[^}]+}}", function(var_name, content)
        if not variables[var_name] then
            return content
        else
            return ""
        end
    end)
    
    -- Process regular variable substitutions
    for key, value in pairs(variables) do
        local pattern = "{{" .. key .. "}}"
        rendered = rendered:gsub(pattern, tostring(value))
    end

    return rendered
end

-- Render template string with variables (simple version)
function M.render_template_string(template_string, variables)
    if not template_string or not variables then
        return template_string
    end
    
    local rendered = template_string
    
    -- Process regular variable substitutions
    for key, value in pairs(variables) do
        local pattern = "{{" .. key .. "}}"
        rendered = rendered:gsub(pattern, tostring(value))
    end
    
    return rendered
end

-- Windows Scripts Templates
function M.get_windows_build_script()
    return builtin_templates.windows_build_script or [[
@echo off
setlocal enabledelayedexpansion

echo ================================
echo Qt Project Build Script (Windows)
echo ================================

:: Configuration
set PROJECT_NAME={{PROJECT_NAME}}
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Debug

set BUILD_DIR=build
set SOURCE_DIR=%~dp0

echo Project: %PROJECT_NAME%
echo Build Type: %BUILD_TYPE%
echo Source Directory: %SOURCE_DIR%
echo Build Directory: %BUILD_DIR%
echo.

:: Check if CMake is available
cmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] CMake not found. Please install CMake and add it to PATH.
    pause
    exit /b 1
)

:: Create build directory
if not exist %BUILD_DIR% (
    echo [INFO] Creating build directory...
    mkdir %BUILD_DIR%
)

:: Configure project
echo [INFO] Configuring CMake project...
cd %BUILD_DIR%
cmake .. -DCMAKE_BUILD_TYPE=%BUILD_TYPE%
if %errorlevel% neq 0 (
    echo [ERROR] CMake configuration failed!
    pause
    exit /b 1
)

:: Build project
echo [INFO] Building project...
cmake --build . --config %BUILD_TYPE%
if %errorlevel% neq 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Build completed successfully!
echo Executable location: %BUILD_DIR%\%BUILD_TYPE%\%PROJECT_NAME%.exe

pause
]]
end

function M.get_windows_run_script()
    return builtin_templates.windows_run_script or [[
@echo off
setlocal enabledelayedexpansion

echo ==============================
echo Qt Project Run Script (Windows)
echo ==============================

:: Configuration
set PROJECT_NAME={{PROJECT_NAME}}
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Debug

set BUILD_DIR=build
set EXE_PATH=%BUILD_DIR%\%BUILD_TYPE%\%PROJECT_NAME%.exe

echo Project: %PROJECT_NAME%
echo Build Type: %BUILD_TYPE%
echo Executable Path: %EXE_PATH%
echo.

:: Check if executable exists
if not exist "%EXE_PATH%" (
    echo [ERROR] Executable not found: %EXE_PATH%
    echo [INFO] Please build the project first using build.bat
    pause
    exit /b 1
)

:: Run the application
echo [INFO] Starting %PROJECT_NAME%...
echo.
"%EXE_PATH%"

echo.
echo [INFO] Application terminated.
pause
]]
end

function M.get_windows_clean_script()
    return builtin_templates.windows_clean_script or [[
@echo off
setlocal enabledelayedexpansion

echo ===============================
echo Qt Project Clean Script (Windows)
echo ===============================

set BUILD_DIR=build

echo Cleaning build directory: %BUILD_DIR%
echo.

if exist %BUILD_DIR% (
    echo [INFO] Removing build directory...
    rmdir /s /q %BUILD_DIR%
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to remove build directory!
        pause
        exit /b 1
    )
    echo [SUCCESS] Build directory cleaned.
) else (
    echo [INFO] Build directory does not exist, nothing to clean.
)

echo.
pause
]]
end

function M.get_windows_setup_script()
    return builtin_templates.windows_setup_script or [[
@echo off
setlocal enabledelayedexpansion

echo ====================================
echo Qt Development Environment Setup (Windows)
echo ====================================

echo This script will help you set up your Qt development environment.
echo.

:: Check CMake
echo [INFO] Checking CMake...
cmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] CMake not found in PATH
    echo Please download and install CMake from: https://cmake.org/download/
    echo Make sure to add CMake to your system PATH
) else (
    for /f "tokens=3" %%i in ('cmake --version 2^>nul ^| findstr /r "cmake version"') do (
        echo [OK] CMake found: %%i
    )
)
echo.

:: Check Qt
echo [INFO] Checking Qt installation...
qmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Qt/qmake not found in PATH
    echo Please install Qt from: https://www.qt.io/download
    echo Make sure Qt bin directory is in your system PATH
) else (
    for /f "tokens=4" %%i in ('qmake --version 2^>nul ^| findstr /r "Qt version"') do (
        echo [OK] Qt found: %%i
    )
)
echo.

:: Check Visual Studio Build Tools
echo [INFO] Checking Visual Studio Build Tools...
where cl >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Visual Studio compiler (cl.exe) not found in PATH
    echo Please ensure Visual Studio Build Tools are installed and
    echo you're running this from a Developer Command Prompt, or
    echo add Visual Studio tools to your PATH
) else (
    for /f "tokens=*" %%i in ('cl 2^>^&1 ^| findstr /r "Microsoft.*C/C++"') do (
        echo [OK] Visual Studio compiler found
    )
)
echo.

:: Check Git
echo [INFO] Checking Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Git not found in PATH
    echo Please install Git from: https://git-scm.com/download/win
) else (
    for /f "tokens=3" %%i in ('git --version 2^>nul') do (
        echo [OK] Git found: %%i
    )
)
echo.

:: Environment Summary
echo ====================================
echo Environment Setup Summary:
echo ====================================
echo.
echo Required tools for Qt development:
echo - CMake: Build system generator
echo - Qt: Qt framework and tools
echo - Visual Studio: C++ compiler and build tools
echo - Git: Version control
echo.
echo If any tools are missing, please install them and add to PATH.
echo Then run this script again to verify the setup.
echo.

pause
]]
end

function M.get_windows_dev_script()
    return builtin_templates.windows_dev_script or [[
@echo off
setlocal enabledelayedexpansion

echo ==========================
echo Qt Project Developer Menu
echo ==========================

:menu
echo.
echo Please select an option:
echo.
echo 1. Build Project (Debug)
echo 2. Build Project (Release)
echo 3. Run Project (Debug)
echo 4. Run Project (Release)
echo 5. Clean Build Directory
echo 6. Open Qt Designer
echo 7. Open Project in Qt Creator
echo 8. Setup Development Environment
echo 9. Exit
echo.
set /p choice="Enter your choice (1-9): "

if "%choice%"=="1" goto build_debug
if "%choice%"=="2" goto build_release
if "%choice%"=="3" goto run_debug
if "%choice%"=="4" goto run_release
if "%choice%"=="5" goto clean
if "%choice%"=="6" goto designer
if "%choice%"=="7" goto qtcreator
if "%choice%"=="8" goto setup
if "%choice%"=="9" goto exit
echo Invalid choice, please try again.
goto menu

:build_debug
echo [INFO] Building project in Debug mode...
call build.bat Debug
goto menu

:build_release
echo [INFO] Building project in Release mode...
call build.bat Release
goto menu

:run_debug
echo [INFO] Running project (Debug)...
call run.bat Debug
goto menu

:run_release
echo [INFO] Running project (Release)...
call run.bat Release
goto menu

:clean
echo [INFO] Cleaning project...
call clean.bat
goto menu

:designer
echo [INFO] Opening Qt Designer...
where designer >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Qt Designer not found in PATH
    pause
    goto menu
)
designer ui\*.ui >nul 2>&1 &
goto menu

:qtcreator
echo [INFO] Opening Qt Creator...
where qtcreator >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Qt Creator not found in PATH
    pause
    goto menu
)
qtcreator CMakeLists.txt >nul 2>&1 &
goto menu

:setup
echo [INFO] Running environment setup...
call setup.bat
goto menu

:exit
echo Goodbye!
exit /b 0
]]
end

-- Initialize on module load
M.load_builtin_templates()

return M