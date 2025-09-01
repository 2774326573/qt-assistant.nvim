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
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    MainWindow window;
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

-- Initialize on module load
M.load_builtin_templates()

return M