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

# Prevent CMake from mixing MinGW and MSVC toolchains on Windows
if(WIN32)
    # Ensure we use the correct compiler when MSVC is detected
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR MSVC)
        # Force MSVC toolchain settings
        set(CMAKE_SYSTEM_NAME Windows)
        
        # Remove any potential MinGW paths that could cause library conflicts
        if(CMAKE_PREFIX_PATH)
            string(REPLACE "C:/mingw64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "C:/msys64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "/mingw64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "/msys64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
        endif()
        
        # Force MSVC runtime library selection to avoid MinGW conflicts
        if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        endif()
        
        # Clear any potential MinGW library paths from linker
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:mingw32")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:libmingw32.a")
    endif()
endif()

project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

# C++ Standard Configuration
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})  # Default from template
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Validate C++ standard based on Qt version requirements
if(CMAKE_CXX_STANDARD LESS 11)
    message(FATAL_ERROR "Qt requires at least C++11. Please set CMAKE_CXX_STANDARD to 11 or higher.")
endif()

# Qt version specific C++ standard requirements
if(CMAKE_CXX_STANDARD LESS 17)
    message(STATUS "Using C++${CMAKE_CXX_STANDARD} - Qt6 requires C++17, will prefer Qt5 if both available")
    set(PREFER_QT5 TRUE)
else()
    set(PREFER_QT5 FALSE)
endif()

# MSVC specific settings for different C++ standards
if(MSVC)
    # Check MSVC version and apply appropriate flags
    if(MSVC_VERSION GREATER_EQUAL 1910)  # VS2017 (15.0) and later
        # VS2017+ supports modern C++ standards
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 17)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17 /Zc:__cplusplus")
        elseif(CMAKE_CXX_STANDARD EQUAL 14)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++11")
        endif()
        
        if(MSVC_VERSION GREATER_EQUAL 1914)  # VS2017 15.7+
            # /permissive- available from VS2017 15.7+
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
        endif()
    elseif(MSVC_VERSION GREATER_EQUAL 1800)  # VS2013
        # VS2013+ has partial C++11/14 support
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 14)
            message(WARNING "MSVC ${MSVC_VERSION} has limited C++14 support. Consider upgrading to VS2017+.")
        endif()
    else()
        # Very old MSVC versions
        message(WARNING "MSVC version ${MSVC_VERSION} has limited modern C++ support. Consider upgrading.")
    endif()
    
    # Additional MSVC optimizations and warnings
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /EHsc")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /DNDEBUG")
elseif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # GCC/Clang specific flags for different standards
    if(CMAKE_CXX_STANDARD GREATER_EQUAL 20)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")
    elseif(CMAKE_CXX_STANDARD GREATER_EQUAL 17)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    elseif(CMAKE_CXX_STANDARD EQUAL 14)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    endif()
endif()

# Qt settings - enable before finding Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt based on C++ standard requirements
if(PREFER_QT5 OR CMAKE_CXX_STANDARD LESS 17)
    # Try Qt5 first for older C++ standards
    find_package(Qt5 5.9 COMPONENTS Core Widgets QUIET)
    if(Qt5_FOUND)
        message(STATUS "Using Qt5: ${Qt5_VERSION} with C++${CMAKE_CXX_STANDARD}")
        set(QT_VERSION_MAJOR 5)
        # Ensure minimum C++ standard for Qt5
        if(CMAKE_CXX_STANDARD LESS 11)
            set(CMAKE_CXX_STANDARD 11)
            message(STATUS "Upgraded C++ standard to 11 for Qt5 compatibility")
        endif()
    else()
        # Fallback to Qt6 if Qt5 not found
        find_package(Qt6 COMPONENTS Core Widgets QUIET)
        if(Qt6_FOUND)
            message(STATUS "Qt5 not found, using Qt6: ${Qt6_VERSION}")
            set(QT_VERSION_MAJOR 6)
            # Qt6 requires C++17 minimum
            if(CMAKE_CXX_STANDARD LESS 17)
                set(CMAKE_CXX_STANDARD 17)
                message(STATUS "Upgraded C++ standard to 17 for Qt6 compatibility")
            endif()
        else()
            message(FATAL_ERROR "Neither Qt5 nor Qt6 found. Please install Qt development libraries.")
        endif()
    endif()
else()
    # Try Qt6 first for C++17+
    find_package(Qt6 COMPONENTS Core Widgets QUIET)
    if(Qt6_FOUND)
        message(STATUS "Using Qt6: ${Qt6_VERSION} with C++${CMAKE_CXX_STANDARD}")
        set(QT_VERSION_MAJOR 6)
    else()
        # Fallback to Qt5
        find_package(Qt5 5.9 COMPONENTS Core Widgets QUIET)
        if(Qt5_FOUND)
            message(STATUS "Qt6 not found, using Qt5: ${Qt5_VERSION}")
            set(QT_VERSION_MAJOR 5)
            message(WARNING "Using Qt5 with C++${CMAKE_CXX_STANDARD}. Consider Qt6 for full C++17+ support.")
        else()
            message(FATAL_ERROR "Neither Qt6 nor Qt5 found. Please install Qt development libraries.")
        endif()
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

# Prevent CMake from mixing MinGW and MSVC toolchains on Windows  
if(WIN32)
    # Ensure we use the correct compiler when MSVC is detected
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR MSVC)
        # Force MSVC toolchain settings
        set(CMAKE_SYSTEM_NAME Windows)
        
        # Remove any potential MinGW paths that could cause library conflicts
        if(CMAKE_PREFIX_PATH)
            string(REPLACE "C:/mingw64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "C:/msys64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "/mingw64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "/msys64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
        endif()
        
        # Force MSVC runtime library selection to avoid MinGW conflicts
        if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        endif()
        
        # Clear any potential MinGW library paths from linker  
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:mingw32")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:libmingw32.a")
    endif()
endif()

project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

# C++ Standard Configuration
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})  # Default from template
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Validate C++ standard based on Qt version requirements
if(CMAKE_CXX_STANDARD LESS 11)
    message(FATAL_ERROR "Qt requires at least C++11. Please set CMAKE_CXX_STANDARD to 11 or higher.")
endif()

# Qt version specific C++ standard requirements
if(CMAKE_CXX_STANDARD LESS 17)
    message(STATUS "Using C++${CMAKE_CXX_STANDARD} - Qt6 requires C++17, will prefer Qt5 if both available")
    set(PREFER_QT5 TRUE)
else()
    set(PREFER_QT5 FALSE)
endif()

# MSVC specific settings for different C++ standards
if(MSVC)
    # Check MSVC version and apply appropriate flags
    if(MSVC_VERSION GREATER_EQUAL 1910)  # VS2017 (15.0) and later
        # VS2017+ supports modern C++ standards
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 17)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17 /Zc:__cplusplus")
        elseif(CMAKE_CXX_STANDARD EQUAL 14)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++11")
        endif()
        
        if(MSVC_VERSION GREATER_EQUAL 1914)  # VS2017 15.7+
            # /permissive- available from VS2017 15.7+
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
        endif()
    elseif(MSVC_VERSION GREATER_EQUAL 1800)  # VS2013
        # VS2013+ has partial C++11/14 support
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 14)
            message(WARNING "MSVC ${MSVC_VERSION} has limited C++14 support. Consider upgrading to VS2017+.")
        endif()
    else()
        # Very old MSVC versions
        message(WARNING "MSVC version ${MSVC_VERSION} has limited modern C++ support. Consider upgrading.")
    endif()
    
    # Additional MSVC optimizations and warnings
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /EHsc")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /DNDEBUG")
elseif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # GCC/Clang specific flags for different standards
    if(CMAKE_CXX_STANDARD GREATER_EQUAL 20)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")
    elseif(CMAKE_CXX_STANDARD GREATER_EQUAL 17)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    elseif(CMAKE_CXX_STANDARD EQUAL 14)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    endif()
endif()

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
set CXX_STANDARD=%2
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Debug
if "%CXX_STANDARD%"=="" set CXX_STANDARD=17

set BUILD_DIR=build
set SOURCE_DIR=%~dp0

echo Project: %PROJECT_NAME%
echo Build Type: %BUILD_TYPE%
echo C++ Standard: C++%CXX_STANDARD%
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

:: Try to detect and use Visual Studio generator for better MSVC support
echo [INFO] Detecting Visual Studio version...

:: Clean any potential MinGW paths from environment to avoid conflicts
set PATH_CLEAN=%PATH%
set PATH_CLEAN=%PATH_CLEAN:C:\mingw64\bin;=%
set PATH_CLEAN=%PATH_CLEAN:C:\msys64\usr\bin;=%
set PATH_CLEAN=%PATH_CLEAN:C:\msys64\mingw64\bin;=%
set PATH=%PATH_CLEAN%

:: Force MSVC compiler environment
set CMAKE_C_COMPILER=cl
set CMAKE_CXX_COMPILER=cl

:: Try VS2022 first
cmake .. -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_CXX_STANDARD=%CXX_STANDARD% -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -G "Visual Studio 17 2022" -A x64 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using Visual Studio 2022 with C++%CXX_STANDARD%
    goto :build_project
)

:: Try VS2019
echo [INFO] VS2022 not found, trying VS2019...
cmake .. -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_CXX_STANDARD=%CXX_STANDARD% -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -G "Visual Studio 16 2019" -A x64 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using Visual Studio 2019 with C++%CXX_STANDARD%
    goto :build_project
)

:: Try VS2017
echo [INFO] VS2019 not found, trying VS2017...
cmake .. -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_CXX_STANDARD=%CXX_STANDARD% -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -G "Visual Studio 15 2017" -A x64 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using Visual Studio 2017 with C++%CXX_STANDARD%
    goto :build_project
)

:: Fallback to default generator with explicit MSVC compiler
echo [WARNING] No specific Visual Studio version detected, using default generator with MSVC...
cmake .. -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_CXX_STANDARD=%CXX_STANDARD% -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl
if %errorlevel% neq 0 (
    echo [ERROR] CMake configuration failed!
    echo.
    echo Possible solutions:
    echo 1. Install Visual Studio 2017, 2019, or 2022 with C++ support
    echo 2. Install Visual Studio Build Tools
    echo 3. Run from Visual Studio Developer Command Prompt
    echo 4. Check if Qt is properly installed and in PATH
    echo 5. Verify CMake is installed and in PATH
    pause
    exit /b 1
)

:build_project

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

:: Try to detect C++ standard from CMakeCache.txt
set DETECTED_CXX_STD=Unknown
if exist "../CMakeCache.txt" (
    for /f "tokens=2 delims==" %%i in ('findstr "CMAKE_CXX_STANDARD:STRING" "../CMakeCache.txt" 2^>nul') do (
        set DETECTED_CXX_STD=%%i
    )
)
if not "%DETECTED_CXX_STD%"=="Unknown" (
    echo C++ Standard: C++%DETECTED_CXX_STD%
    echo.
)

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
echo [INFO] Checking Visual Studio installations...

:: Check for cl.exe in PATH
where cl >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('cl 2^>^&1 ^| findstr /r "Microsoft.*C/C++"') do (
        echo [OK] Visual Studio compiler found: %%i
    )
    goto :vs_found
)

:: Check common VS installation paths
set VS_FOUND=0

:: VS2022
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC" (
    echo [OK] Visual Studio 2022 Community detected
    set VS_FOUND=1
)
if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC" (
    echo [OK] Visual Studio 2022 Professional detected  
    set VS_FOUND=1
)

:: VS2019
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC" (
    echo [OK] Visual Studio 2019 Community detected
    set VS_FOUND=1
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Tools\MSVC" (
    echo [OK] Visual Studio 2019 Professional detected
    set VS_FOUND=1
)

:: VS2017
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC" (
    echo [OK] Visual Studio 2017 Community detected
    set VS_FOUND=1
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Tools\MSVC" (
    echo [OK] Visual Studio 2017 Professional detected
    set VS_FOUND=1
)

:: VS Build Tools
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC" (
    echo [OK] VS2019 Build Tools detected
    set VS_FOUND=1
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC" (
    echo [OK] VS2017 Build Tools detected
    set VS_FOUND=1
)

if %VS_FOUND% equ 0 (
    echo [WARNING] No Visual Studio installation detected
    echo Please install Visual Studio 2017 or later with C++ support
    echo Or run this from Visual Studio Developer Command Prompt
) else (
    echo [INFO] To use VS tools, run from Developer Command Prompt
    echo Or manually call: "C:\Program Files\Microsoft Visual Studio\YYYY\Edition\VC\Auxiliary\Build\vcvars64.bat"
)

:vs_found
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
echo 9. Setup Visual Studio Environment
echo A. Advanced Build Options
echo 0. Exit
echo.
set /p choice="Enter your choice (0-9, A): "

if "%choice%"=="1" goto build_debug
if "%choice%"=="2" goto build_release
if "%choice%"=="3" goto run_debug
if "%choice%"=="4" goto run_release
if "%choice%"=="5" goto clean
if "%choice%"=="6" goto designer
if "%choice%"=="7" goto qtcreator
if "%choice%"=="8" goto setup
if "%choice%"=="9" goto setup_vs
if /I "%choice%"=="A" goto advanced_build
if "%choice%"=="0" goto exit
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

:setup_vs
echo [INFO] Setting up Visual Studio environment...
echo.
echo Available Visual Studio versions:
echo 1. Visual Studio 2017
echo 2. Visual Studio 2019  
echo 3. Visual Studio 2022
echo 4. Auto-detect
echo.
set /p vs_choice="Select Visual Studio version (1-4): "

if "%vs_choice%"=="1" goto setup_vs2017
if "%vs_choice%"=="2" goto setup_vs2019
if "%vs_choice%"=="3" goto setup_vs2022
if "%vs_choice%"=="4" goto setup_vs_auto
echo Invalid choice.
pause
goto menu

:setup_vs2017
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2017 Community environment loaded
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2017 Professional environment loaded
) else (
    echo VS2017 not found
)
pause
goto menu

:setup_vs2019
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2019 Community environment loaded
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2019 Professional environment loaded
) else (
    echo VS2019 not found
)
pause
goto menu

:setup_vs2022
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2022 Community environment loaded
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2022 Professional environment loaded
) else (
    echo VS2022 not found
)
pause
goto menu

:setup_vs_auto
echo [INFO] Auto-detecting Visual Studio...
:: Try to find and setup any available VS version
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2022 Community environment loaded
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2019 Community environment loaded
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo VS2017 Community environment loaded
) else (
    echo No Visual Studio found
)
pause
goto menu

:advanced_build
echo [INFO] Advanced Build Options
echo.
echo Current project C++ standard detection:
if exist "CMakeCache.txt" (
    for /f "tokens=2 delims==" %%i in ('findstr "CMAKE_CXX_STANDARD:STRING" "CMakeCache.txt" 2^>nul') do (
        echo Current C++ Standard: C++%%i
    )
) else (
    echo No build cache found - project not configured yet
)
echo.
echo Available options:
echo 1. Build with specific C++ standard
echo 2. Show current build configuration
echo 3. Regenerate build files with new C++ standard
echo 4. Back to main menu
echo.
set /p adv_choice="Enter your choice (1-4): "

if "%adv_choice%"=="1" goto build_with_std
if "%adv_choice%"=="2" goto show_config
if "%adv_choice%"=="3" goto regen_config
if "%adv_choice%"=="4" goto menu
echo Invalid choice.
pause
goto advanced_build

:build_with_std
echo.
echo Select C++ standard:
echo 1. C++11
echo 2. C++14  
echo 3. C++17 (recommended)
echo 4. C++20
echo 5. C++23
echo.
set /p std_choice="Enter choice (1-5): "

set CXX_STD=17
if "%std_choice%"=="1" set CXX_STD=11
if "%std_choice%"=="2" set CXX_STD=14
if "%std_choice%"=="3" set CXX_STD=17
if "%std_choice%"=="4" set CXX_STD=20
if "%std_choice%"=="5" set CXX_STD=23

echo.
echo Select build type:
echo 1. Debug
echo 2. Release
set /p build_choice="Enter choice (1-2): "

set BUILD_TYPE=Debug
if "%build_choice%"=="2" set BUILD_TYPE=Release

echo [INFO] Building with C++%CXX_STD% (%BUILD_TYPE%)...
call build.bat %BUILD_TYPE% %CXX_STD%
pause
goto advanced_build

:show_config
echo.
echo [INFO] Current Build Configuration:
if exist "CMakeCache.txt" (
    echo Found CMakeCache.txt:
    findstr "CMAKE_CXX_STANDARD\|CMAKE_BUILD_TYPE\|Qt.*_VERSION" "CMakeCache.txt" 2>nul
) else (
    echo No CMakeCache.txt found - project not configured
)
echo.
pause
goto advanced_build

:regen_config
echo.
echo [INFO] Regenerating build configuration...
if exist build (
    echo Cleaning existing build directory...
    rmdir /s /q build
)
mkdir build
cd build

echo.
echo Select C++ standard for regeneration:
echo 1. C++11    4. C++20
echo 2. C++14    5. C++23
echo 3. C++17 (recommended)
set /p regen_std="Enter choice (1-5): "

set REGEN_CXX=17
if "%regen_std%"=="1" set REGEN_CXX=11
if "%regen_std%"=="2" set REGEN_CXX=14
if "%regen_std%"=="3" set REGEN_CXX=17
if "%regen_std%"=="4" set REGEN_CXX=20
if "%regen_std%"=="5" set REGEN_CXX=23

echo [INFO] Configuring with C++%REGEN_CXX%...
cmake .. -DCMAKE_CXX_STANDARD=%REGEN_CXX%

if %errorlevel% equ 0 (
    echo [SUCCESS] Configuration completed with C++%REGEN_CXX%
) else (
    echo [ERROR] Configuration failed
)

cd ..
pause
goto advanced_build

:exit
echo Goodbye!
exit /b 0
]]
end

function M.get_windows_fix_script()
    return builtin_templates.windows_fix_script or [[
@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Qt Project MSVC C++17 Fix Script
echo ========================================
echo.
echo This script fixes the MSVC C++17 compilation error.
echo.

:: Check if CMakeLists.txt exists
if not exist "CMakeLists.txt" (
    echo [ERROR] CMakeLists.txt not found!
    pause
    exit /b 1
)

:: Backup and clean build
if exist build (
    echo [INFO] Cleaning build directory...
    rmdir /s /q build
)

echo [INFO] Creating fresh build directory...
mkdir build
cd build

echo [INFO] Configuring with proper MSVC settings...

:: Try different Visual Studio versions in order
echo [INFO] Detecting Visual Studio version...

:: Try VS2022
cmake .. -G "Visual Studio 17 2022" -A x64 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using Visual Studio 2022
    goto :fix_complete
)

:: Try VS2019
cmake .. -G "Visual Studio 16 2019" -A x64 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using Visual Studio 2019
    goto :fix_complete
)

:: Try VS2017
cmake .. -G "Visual Studio 15 2017" -A x64 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using Visual Studio 2017
    goto :fix_complete
)

:: Fallback to default with explicit flags
cmake .. -DCMAKE_CXX_FLAGS="/std:c++17 /Zc:__cplusplus" 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Using default generator with MSVC C++17 flags
    goto :fix_complete
)

echo [ERROR] Configuration failed with all methods!
echo.
echo Please check:
echo 1. Visual Studio 2017 or later is installed
echo 2. CMake is installed and in PATH
echo 3. You're running from correct command prompt
pause
exit /b 1

:fix_complete

echo.
echo [SUCCESS] Project fixed! Now you can build with:
echo cmake --build . --config Debug
echo.
pause
]]
end

-- Initialize on module load
M.load_builtin_templates()

return M