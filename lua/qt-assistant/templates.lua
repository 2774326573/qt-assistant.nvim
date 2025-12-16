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
    },
    delegate = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QStyledItemDelegate"
    },
    thread = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QThread"
    },
    utility = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QObject"
    },
    singleton = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QObject"
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

    -- Delegate template
    builtin_templates.delegate_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QStyledItemDelegate>

class {{CLASS_NAME}} : public QStyledItemDelegate
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);

    QWidget *createEditor(QWidget *parent, const QStyleOptionViewItem &option, const QModelIndex &index) const override;
    void setEditorData(QWidget *editor, const QModelIndex &index) const override;
    void setModelData(QWidget *editor, QAbstractItemModel *model, const QModelIndex &index) const override;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option, const QModelIndex &index) const override;
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.delegate_source = [[
#include "{{FILE_NAME}}.h"
#include <QLineEdit>

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QStyledItemDelegate(parent)
{
}

QWidget *{{CLASS_NAME}}::createEditor(QWidget *parent, const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    Q_UNUSED(option)
    Q_UNUSED(index)
    // TODO: customize editor
    return new QLineEdit(parent);
}

void {{CLASS_NAME}}::setEditorData(QWidget *editor, const QModelIndex &index) const
{
    // TODO: set editor data from model
    QStyledItemDelegate::setEditorData(editor, index);
}

void {{CLASS_NAME}}::setModelData(QWidget *editor, QAbstractItemModel *model, const QModelIndex &index) const
{
    // TODO: write editor data back to model
    QStyledItemDelegate::setModelData(editor, model, index);
}

void {{CLASS_NAME}}::updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    Q_UNUSED(index)
    editor->setGeometry(option.rect);
}
]]

    -- Thread template
    builtin_templates.thread_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QThread>

class {{CLASS_NAME}} : public QThread
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
    ~{{CLASS_NAME}}() override = default;

protected:
    void run() override;
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.thread_source = [[
#include "{{FILE_NAME}}.h"
#include <QDebug>

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QThread(parent)
{
}

void {{CLASS_NAME}}::run()
{
    // TODO: implement thread workload
    qDebug() << "{{CLASS_NAME}} thread running";
}
]]

    -- Utility template (QObject based)
    builtin_templates.utility_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QObject>

class {{CLASS_NAME}} : public QObject
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.utility_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QObject(parent)
{
    // TODO: add initialization
}
]]

    -- Singleton template (non-QObject)
    builtin_templates.singleton_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

class {{CLASS_NAME}}
{
public:
    static {{CLASS_NAME}} &instance();

    {{CLASS_NAME}}(const {{CLASS_NAME}} &) = delete;
    {{CLASS_NAME}} &operator=(const {{CLASS_NAME}} &) = delete;

private:
    {{CLASS_NAME}}();
    ~{{CLASS_NAME}}() = default;
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.singleton_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}} &{{CLASS_NAME}}::instance()
{
    static {{CLASS_NAME}} instance;
    return instance;
}

{{CLASS_NAME}}::{{CLASS_NAME}}()
{
    // TODO: initialize singleton state
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

    builtin_templates.main_quick_app = [[
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Load the main QML file
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    // Handle QML loading errors
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
]]

    builtin_templates.main_qml = [[
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("{{PROJECT_NAME}}")

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4CAF50" }
            GradientStop { position: 1.0; color: "#2E7D32" }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Welcome to {{PROJECT_NAME}}")
                font.pointSize: 24
                font.bold: true
                color: "white"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Click me!")
                onClicked: {
                    messageText.text = qsTr("Hello from Qt Quick!")
                }
            }

            Text {
                id: messageText
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Qt Quick Application")
                font.pointSize: 16
                color: "white"
            }
        }
    }
}
]]

    builtin_templates.qml_qrc = [[
<RCC>
    <qresource prefix="/">
        <file>qml/main.qml</file>
    </qresource>
</RCC>
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

# Default export output directories
set(EXPORT_ROOT "${CMAKE_SOURCE_DIR}/export/${PROJECT_NAME}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${EXPORT_ROOT}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")

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

    builtin_templates.cmake_quick_app = [[
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

# Validate C++ standard for Qt Quick
if(CMAKE_CXX_STANDARD LESS 17)
    message(STATUS "Qt Quick applications work better with C++17+. Current: C++${CMAKE_CXX_STANDARD}")
    if(CMAKE_CXX_STANDARD LESS 11)
        message(FATAL_ERROR "Qt requires at least C++11. Please set CMAKE_CXX_STANDARD to 11 or higher.")
    endif()
endif()

# MSVC specific settings for different C++ standards
if(MSVC)
    if(MSVC_VERSION GREATER_EQUAL 1910)  # VS2017 (15.0) and later
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 17)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17 /Zc:__cplusplus")
        elseif(CMAKE_CXX_STANDARD EQUAL 14)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++11")
        endif()

        if(MSVC_VERSION GREATER_EQUAL 1914)  # VS2017 15.7+
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
        endif()
    endif()

    # Additional MSVC optimizations and warnings
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /EHsc")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /DNDEBUG")
endif()

# Qt settings - enable before finding Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt - prefer Qt6 for Quick applications
find_package(Qt6 COMPONENTS Core Quick Qml QUIET)
if(Qt6_FOUND)
    message(STATUS "Using Qt6: ${Qt6_VERSION} for Qt Quick application")
    set(QT_VERSION_MAJOR 6)
    # Ensure minimum C++ standard for Qt6
    if(CMAKE_CXX_STANDARD LESS 17)
        set(CMAKE_CXX_STANDARD 17)
        message(STATUS "Upgraded to C++17 for Qt6 compatibility")
    endif()
else()
    # Fallback to Qt5
    find_package(Qt5 5.12 COMPONENTS Core Quick Qml QUIET)
    if(Qt5_FOUND)
        message(STATUS "Using Qt5: ${Qt5_VERSION} for Qt Quick application")
        set(QT_VERSION_MAJOR 5)
        # Ensure minimum C++ standard for Qt5
        if(CMAKE_CXX_STANDARD LESS 11)
            set(CMAKE_CXX_STANDARD 11)
        endif()
    else()
        message(FATAL_ERROR "Qt5 (5.12+) or Qt6 with Quick/Qml components is required")
    endif()
endif()

# Source files
set(SOURCES
    src/main.cpp
)

# QML files and resources
set(QML_SOURCES
    qml/main.qml
)

# Create executable
if(QT_VERSION_MAJOR EQUAL 6)
    qt_add_executable(${PROJECT_NAME} ${SOURCES})
    qt_add_qml_module(${PROJECT_NAME}
        URI ${PROJECT_NAME}
        VERSION 1.0
        QML_FILES ${QML_SOURCES}
    )
else()
    # For Qt5, use traditional resource compilation
    qt5_add_resources(QML_RESOURCES qml.qrc)
    add_executable(${PROJECT_NAME} ${SOURCES} ${QML_RESOURCES})
endif()

# Link Qt libraries
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME}
        Qt6::Core
        Qt6::Quick
        Qt6::Qml
    )
else()
    target_link_libraries(${PROJECT_NAME}
        Qt5::Core
        Qt5::Quick
        Qt5::Qml
    )
endif()

# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Platform-specific settings
if(WIN32)
    # Windows-specific settings
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()
]]

    -- Multi-module project templates
    builtin_templates.cmake_multi_project = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

include(GNUInstallDirs)

# Default export output directories
set(EXPORT_ROOT "${CMAKE_SOURCE_DIR}/export/${PROJECT_NAME}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${EXPORT_ROOT}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")

# C++ Standard Configuration
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Global Qt settings
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt
find_package(Qt6 COMPONENTS Core Widgets QUIET)
if(Qt6_FOUND)
    message(STATUS "Using Qt6: ${Qt6_VERSION}")
    set(QT_VERSION_MAJOR 6)
else()
    find_package(Qt5 5.15 COMPONENTS Core Widgets QUIET)
    if(Qt5_FOUND)
        message(STATUS "Using Qt5: ${Qt5_VERSION}")
        set(QT_VERSION_MAJOR 5)
    else()
        message(FATAL_ERROR "Qt5 or Qt6 is required")
    endif()
endif()

# Global settings
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Add subdirectories (modules will be added here)
# add_subdirectory(core)
# add_subdirectory(ui)
# add_subdirectory(plugins)
# add_subdirectory(app)

# Example structure for multi-module project:
#
# {{PROJECT_NAME}}/
# ├── CMakeLists.txt           # This file
# ├── core/                    # Core library module
# │   ├── CMakeLists.txt
# │   ├── src/
# │   └── include/
# ├── ui/                      # UI library module
# │   ├── CMakeLists.txt
# │   ├── src/
# │   └── include/
# ├── plugins/                 # Plugin modules
# │   ├── CMakeLists.txt
# │   └── plugin1/
# └── app/                     # Main application
#     ├── CMakeLists.txt
#     ├── src/
#     └── main.cpp

message(STATUS "Multi-module project structure created")
message(STATUS "Use :QtAddModule <name> <type> to add new modules")
]]

    builtin_templates.cmake_shared_lib = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

# C++ Standard Configuration
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Default export output directories (shared library: bin/lib split)
set(EXPORT_ROOT "${CMAKE_SOURCE_DIR}/export/${PROJECT_NAME}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${EXPORT_ROOT}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")

# Qt settings
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt components for this library
find_package(Qt6 COMPONENTS Core QUIET)
if(Qt6_FOUND)
    set(QT_VERSION_MAJOR 6)
else()
    find_package(Qt5 5.15 COMPONENTS Core QUIET)
    if(Qt5_FOUND)
        set(QT_VERSION_MAJOR 5)
    else()
        message(FATAL_ERROR "Qt5 or Qt6 is required")
    endif()
endif()

# Source files
set(SOURCES
    src/{{PROJECT_NAME}}.cpp
    # Add more source files here
)

set(HEADERS
    include/{{PROJECT_NAME}}/{{PROJECT_NAME}}.h
    # Add more header files here
)

# Group files for IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/include PREFIX "Header Files" FILES ${HEADERS})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/src PREFIX "Source Files" FILES ${SOURCES})

# Create shared library
add_library({{PROJECT_NAME}} SHARED ${SOURCES} ${HEADERS})

# Set library properties
set_target_properties({{PROJECT_NAME}} PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER "${HEADERS}"
)

# Include directories
target_include_directories({{PROJECT_NAME}}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        src
)

# Link Qt libraries
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries({{PROJECT_NAME}} PUBLIC Qt6::Core)
else()
    target_link_libraries({{PROJECT_NAME}} PUBLIC Qt5::Core)
endif()

# Export symbols for Windows
if(WIN32)
    target_compile_definitions({{PROJECT_NAME}} PRIVATE {{PROJECT_NAME}}_EXPORTS)
endif()

# Installation rules
install(TARGETS {{PROJECT_NAME}}
    EXPORT {{PROJECT_NAME}}Targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/{{PROJECT_NAME}}
)

install(EXPORT {{PROJECT_NAME}}Targets
    FILE {{PROJECT_NAME}}Targets.cmake
    NAMESPACE {{PROJECT_NAME}}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/{{PROJECT_NAME}}
)
]]

    builtin_templates.cmake_static_lib = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

include(GNUInstallDirs)

# C++ Standard Configuration
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Default export output directories (static library: lib only)
set(EXPORT_ROOT "${CMAKE_SOURCE_DIR}/export/${PROJECT_NAME}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${EXPORT_ROOT}/lib")

# Qt settings
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt components for this library
find_package(Qt6 COMPONENTS Core QUIET)
if(Qt6_FOUND)
    set(QT_VERSION_MAJOR 6)
else()
    find_package(Qt5 5.15 COMPONENTS Core QUIET)
    if(Qt5_FOUND)
        set(QT_VERSION_MAJOR 5)
    else()
        message(FATAL_ERROR "Qt5 or Qt6 is required")
    endif()
endif()

# Source files
set(SOURCES
    src/{{PROJECT_NAME}}.cpp
    # Add more source files here
)

set(HEADERS
    include/{{PROJECT_NAME}}/{{PROJECT_NAME}}.h
    # Add more header files here
)

# Group files for IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/include PREFIX "Header Files" FILES ${HEADERS})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/src PREFIX "Source Files" FILES ${SOURCES})

# Create static library
add_library({{PROJECT_NAME}} STATIC ${SOURCES} ${HEADERS})

# Include directories
target_include_directories({{PROJECT_NAME}}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        src
)

# Link Qt libraries
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries({{PROJECT_NAME}} PUBLIC Qt6::Core)
else()
    target_link_libraries({{PROJECT_NAME}} PUBLIC Qt5::Core)
endif()

# Installation rules
install(TARGETS {{PROJECT_NAME}}
    EXPORT {{PROJECT_NAME}}Targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/{{PROJECT_NAME}}
)

install(EXPORT {{PROJECT_NAME}}Targets
    FILE {{PROJECT_NAME}}Targets.cmake
    NAMESPACE {{PROJECT_NAME}}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/{{PROJECT_NAME}}
)
]]

    builtin_templates.cmake_plugin = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

include(GNUInstallDirs)

# C++ Standard Configuration
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Qt settings
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Find Qt components for plugin
find_package(Qt6 COMPONENTS Core QUIET)
if(Qt6_FOUND)
    set(QT_VERSION_MAJOR 6)
else()
    find_package(Qt5 5.15 COMPONENTS Core QUIET)
    if(Qt5_FOUND)
        set(QT_VERSION_MAJOR 5)
    else()
        message(FATAL_ERROR "Qt5 or Qt6 is required")
    endif()
endif()

# Source files
set(SOURCES
    src/{{PROJECT_NAME}}.cpp
    # Add more source files here
)

set(HEADERS
    include/{{PROJECT_NAME}}/{{PROJECT_NAME}}.h
    # Add more header files here
)

# Group files for IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/include PREFIX "Header Files" FILES ${HEADERS})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/src PREFIX "Source Files" FILES ${SOURCES})

# Create plugin
add_library({{PROJECT_NAME}} MODULE ${SOURCES} ${HEADERS})

set_target_properties({{PROJECT_NAME}} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
    PREFIX ""  # Remove 'lib' prefix on Unix
)

# Include directories
target_include_directories({{PROJECT_NAME}}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
        src
)

# Link Qt libraries
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries({{PROJECT_NAME}} Qt6::Core)
else()
    target_link_libraries({{PROJECT_NAME}} Qt5::Core)
endif()

# Installation rules
install(TARGETS {{PROJECT_NAME}}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/plugins
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
]]

    -- Library / Plugin source templates
    builtin_templates.library_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QObject>

class {{CLASS_NAME}} : public QObject
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
    virtual ~{{CLASS_NAME}}();

public slots:
    void doSomething();

signals:
    void somethingDone();

private:
    // TODO: Add private members
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.library_source = [[
#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QObject(parent)
{
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
}

void {{CLASS_NAME}}::doSomething()
{
    // TODO: Implement functionality
    emit somethingDone();
}
]]

    builtin_templates.plugin_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QObject>

class {{CLASS_NAME}} : public QObject
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "{{PLUGIN_IID}}")

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
    ~{{CLASS_NAME}}() override;

signals:
    void activated();

public slots:
    void activate();
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.plugin_source = [[
#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QObject(parent)
{
}

{{CLASS_NAME}}::~{{CLASS_NAME}}() = default;

void {{CLASS_NAME}}::activate()
{
    // TODO: Implement plugin behavior
    emit activated();
}
]]

        -- Documentation template (combined guide)
        builtin_templates.doc_project_guide = [[
    # 项目使用说明

    ## 概览
    - 名称：{{PROJECT_NAME}}
    - 类型：Qt 项目
    - 主要源码：`src/`，头文件：`include/`
    - 依赖：Qt5/Qt6（优先检测 Qt6）

    ## 构建指引（跨平台）
    - 请选择适合当前操作系统的生成器，并为不同生成器使用不同的构建目录。

    ### Windows（MSVC / Ninja）
    ```pwsh
    # MSVC（IDE/调试友好，示例使用 VS 2017，可改为 2019/2022 对应生成器名）
    cmake -S . -B build-msvc -G "Visual Studio 15 2017" -A x64 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build-msvc --config Debug

    # Ninja（轻量、适合 clangd）
    cmake -S . -B build-ninja -G "Ninja" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    ninja -C build-ninja
    ```

    ### Linux / macOS（Ninja / Unix Makefiles）
    ```bash
    # Ninja（推荐搭配 clangd）
    cmake -S . -B build-ninja -G "Ninja" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    ninja -C build-ninja

    # 或 Unix Makefiles
    cmake -S . -B build-make -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    cmake --build build-make
    ```

    > 重要：同一构建目录只能使用同一种生成器。切换生成器请改用新的目录（如 build-msvc、build-ninja、build-make）。

    ## clangd / 编译数据库
    - 若根目录缺少 `compile_commands.json`，请把构建目录中的文件复制/链接到根目录，或在 clangd 参数中指定 `--compile-commands-dir=<build-dir>`。
    - 修改 CMakeLists 或新增源码后，重新运行上面的 cmake 以刷新编译数据库。

    ## 目录速览
    - 源码：`src/`
    - 头文件：`include/`
    - 构建输出示例：`build-msvc/`、`build-ninja/`、`build-make/`
    - 文档：`doc/`

    ## 常见问题
    - 生成器冲突：同一 build 目录只能用同一生成器，切换时请清空或改用新目录。
    - 未找到 Qt：检查 Qt5/Qt6 安装，必要时设置 `Qt5_DIR`/`Qt6_DIR`。
    - clangd 无法解析：确保根目录存在 `compile_commands.json`，或显式传入 `--compile-commands-dir`。
    ]]

    builtin_templates.multi_project_readme = [[
# {{PROJECT_NAME}}

Multi-module Qt project with the following structure:

## Project Structure

```
{{PROJECT_NAME}}/
├── CMakeLists.txt           # Root CMake configuration
├── README.md                # This file
├── core/                    # Core library module
│   ├── CMakeLists.txt
│   ├── src/
│   └── include/
├── ui/                      # UI library module
│   ├── CMakeLists.txt
│   ├── src/
│   └── include/
├── plugins/                 # Plugin modules
│   ├── CMakeLists.txt
│   └── plugin1/
├── app/                     # Main application
│   ├── CMakeLists.txt
│   ├── src/
│   └── main.cpp
└── build/                   # Build output
    ├── bin/                 # Executables
    ├── lib/                 # Libraries
    └── plugins/             # Plugins
```

## Adding New Modules

Use Qt Assistant commands to add new modules:

```vim
:QtAddModule core shared_lib         " Add a shared library module
:QtAddModule utils static_lib        " Add a static library module
:QtAddModule myplugin plugin         " Add a plugin module
:QtAddModule myapp widget_app        " Add an application module
```

## Building

```bash
# Generate build configuration
cmake -B build -S .

# Build all modules
cmake --build build

# Or use Qt Assistant presets
:QtCMakePresets
:QtBuildPreset debug
```

## Module Dependencies

Edit the root CMakeLists.txt to define module dependencies:

```cmake
# Add modules in dependency order
add_subdirectory(core)      # Base library
add_subdirectory(ui)        # UI library (depends on core)
add_subdirectory(plugins)   # Plugins (depend on core)
add_subdirectory(app)       # Application (depends on all)
```
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

-- Initialize on module load
M.load_builtin_templates()

return M
