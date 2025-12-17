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

# vcpkg toolchain (optional, fallback): OFF by default.
# Note: toolchain must be set before the first project() call.
option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_vcpkg_toolchain}")
        set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
    endif()
endif()

# 防止在Windows上CMake混合MinGW和MSVC工具链
if(WIN32)
    # 当检测到MSVC时确保使用正确的编译器
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR MSVC)
        # 强制使用MSVC工具链设置
        set(CMAKE_SYSTEM_NAME Windows)

        # 移除可能导致库冲突的任何MinGW路径
        if(CMAKE_PREFIX_PATH)
            string(REPLACE "C:/mingw64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "C:/msys64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "/mingw64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
            string(REPLACE "/msys64" "" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
        endif()

        # 强制选择MSVC运行时库以避免与MinGW冲突
        if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        endif()

        # 从链接器中清除任何潜在的MinGW库路径
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:mingw32")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:libmingw32.a")
    endif()
endif()

# 定义项目名称、版本和使用的语言
project({{PROJECT_NAME}} VERSION 1.0 LANGUAGES CXX)

# 为 clangd 导出编译数据库
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 标准安装目录变量（bin/lib/include等）
include(GNUInstallDirs)

# C++标准配置
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD {{CXX_STANDARD}})  # 模板默认值
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 根据Qt版本要求验证C++标准
if(CMAKE_CXX_STANDARD LESS 11)
    message(FATAL_ERROR "Qt至少需要C++11。请将CMAKE_CXX_STANDARD设置为11或更高。")
endif()

# Qt版本特定的C++标准要求
if(CMAKE_CXX_STANDARD LESS 17)
    message(STATUS "使用C++${CMAKE_CXX_STANDARD} - Qt6需要C++17，如果两者都可用，将优先使用Qt5")
    set(PREFER_QT5 TRUE)
else()
    set(PREFER_QT5 FALSE)
endif()

# MSVC不同C++标准的特定设置
if(MSVC)
    # 检查MSVC版本并应用适当的标志
    if(MSVC_VERSION GREATER_EQUAL 1910)  # VS2017 (15.0) 及更高版本
        # VS2017+ 支持现代C++标准
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 17)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17 /Zc:__cplusplus")
        elseif(CMAKE_CXX_STANDARD EQUAL 14)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++11")
        endif()

        if(MSVC_VERSION GREATER_EQUAL 1914)  # VS2017 15.7+
            # /permissive- 从VS2017 15.7+ 开始可用
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
        endif()
    elseif(MSVC_VERSION GREATER_EQUAL 1800)  # VS2013
        # VS2013+ 有部分C++11/14支持
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 14)
            message(WARNING "MSVC ${MSVC_VERSION} 的C++14支持有限。建议升级到VS2017+。")
        endif()
    else()
        # 非常旧的MSVC版本
        message(WARNING "MSVC版本 ${MSVC_VERSION} 对现代C++的支持有限。建议升级。")
    endif()

    # 额外的MSVC优化和警告标志
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /EHsc")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /DNDEBUG")
elseif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # GCC/Clang不同标准的特定标志
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

# Qt设置 - 在查找Qt之前启用
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# 根据C++标准要求查找Qt
if(PREFER_QT5 OR CMAKE_CXX_STANDARD LESS 17)
    # 对于较旧的C++标准优先尝试Qt5
    find_package(Qt5 5.9 COMPONENTS Core Widgets QUIET)
    if(Qt5_FOUND)
        message(STATUS "使用Qt5: ${Qt5_VERSION} 和 C++${CMAKE_CXX_STANDARD}")
        set(QT_VERSION_MAJOR 5)
        # 确保Qt5的最低C++标准
        if(CMAKE_CXX_STANDARD LESS 11)
            set(CMAKE_CXX_STANDARD 11)
            message(STATUS "为Qt5兼容性升级C++标准为11")
        endif()
    else()
        # 如果找不到Qt5，回退到Qt6
        find_package(Qt6 COMPONENTS Core Widgets QUIET)
        if(Qt6_FOUND)
            message(STATUS "未找到Qt5，使用Qt6: ${Qt6_VERSION}")
            set(QT_VERSION_MAJOR 6)
            # Qt6最低需要C++17
            if(CMAKE_CXX_STANDARD LESS 17)
                set(CMAKE_CXX_STANDARD 17)
                message(STATUS "为Qt6兼容性升级C++标准为17")
            endif()
        else()
            message(FATAL_ERROR "未找到Qt5或Qt6。请安装Qt开发库。")
        endif()
    endif()
else()
    # 对于C++17+优先尝试Qt6
    find_package(Qt6 COMPONENTS Core Widgets QUIET)
    if(Qt6_FOUND)
        message(STATUS "使用Qt6: ${Qt6_VERSION} 和 C++${CMAKE_CXX_STANDARD}")
        set(QT_VERSION_MAJOR 6)
    else()
        # 回退到Qt5
        find_package(Qt5 5.9 COMPONENTS Core Widgets QUIET)
        if(Qt5_FOUND)
            message(STATUS "未找到Qt6，使用Qt5: ${Qt5_VERSION}")
            set(QT_VERSION_MAJOR 5)
            message(WARNING "使用C++${CMAKE_CXX_STANDARD}和Qt5。建议使用Qt6以获得完整的C++17+支持。")
        else()
            message(FATAL_ERROR "未找到Qt6或Qt5。请安装Qt开发库。")
        endif()
    endif()
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)

# 源文件列表
set(SOURCES
    src/main.cpp
    src/mainwindow.cpp
)

# 头文件列表
set(HEADERS
    include/mainwindow.h
)

# UI文件列表
set(UI_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/ui/mainwindow.ui
)

# 创建可执行文件
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} ${UI_FILES})

# Debug构建附加d后缀，方便区分与发布版本
set_target_properties(${PROJECT_NAME} PROPERTIES
    DEBUG_POSTFIX "d"
)

# 设置AUTOUIC搜索路径，让AutoUic能找到UI文件
set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOUIC_SEARCH_PATHS "${CMAKE_CURRENT_SOURCE_DIR}/ui"
)

# 链接Qt库（版本感知）
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME}
        Qt6::Core
        Qt6::Widgets
    )

    # Qt6特定设置
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        MACOSX_BUNDLE TRUE
    )
else()
    target_link_libraries(${PROJECT_NAME}
        Qt5::Core
        Qt5::Widgets
        ${CMAKE_CURRENT_LIST_DIR}/thridLibrary/ElaWidgetTools/lib/ElaWidgetTools.lib
    )

    # Qt5特定设置
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        MACOSX_BUNDLE TRUE
    )
endif()


# 包含目录
target_include_directories(${PROJECT_NAME} PRIVATE
    include
    ${CMAKE_CURRENT_LIST_DIR}/include
    ${CMAKE_CURRENT_LIST_DIR}/thridLibrary/ElaWidgetTools/include
    ${CMAKE_CURRENT_LIST_DIR}/TestLibrary/TestDll/include  # TestDll头文件（用于了解接口）
    ${CMAKE_CURRENT_LIST_DIR}/TestLibrary/TestPlugin/include  # TestPlugin头文件（用于了解接口）
    ${CMAKE_CURRENT_BINARY_DIR}  # 用于生成的UI头文件
)

# Optional: core library for tests/demos (created by Qt Assistant when tests enabled)
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/src/calculator.cpp")
    add_library(${PROJECT_NAME}_core STATIC
        src/calculator.cpp
        include/calculator.h
    )
    target_include_directories(${PROJECT_NAME}_core PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
    target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_core)
endif()

# Optional: runnable demo program
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/examples/demo.cpp")
    add_executable(${PROJECT_NAME}_demo examples/demo.cpp)
    set_target_properties(${PROJECT_NAME}_demo PROPERTIES DEBUG_POSTFIX "d")
    if(TARGET ${PROJECT_NAME}_core)
        target_link_libraries(${PROJECT_NAME}_demo PRIVATE ${PROJECT_NAME}_core)
    endif()
    target_include_directories(${PROJECT_NAME}_demo PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()

# 编译器特定设置
if(MSVC)
    # Windows特定设置（适用于Qt5/Qt6）
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        _CRT_SECURE_NO_WARNINGS
        NOMINMAX
    )
    # 设置源文件编码为UTF-8
    target_compile_options(${PROJECT_NAME} PRIVATE /utf-8 /wd4399)
else()
    # 非MSVC时保持UTF-8输入/执行字符集
    target_compile_options(${PROJECT_NAME} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
endif()

# 安装规则
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    BUNDLE  DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 打包配置（默认ZIP）
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)
]]

    builtin_templates.cmake_console_app = [[
cmake_minimum_required(VERSION 3.16)

# vcpkg toolchain (optional, fallback): OFF by default.
# Note: toolchain must be set before the first project() call.
option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_vcpkg_toolchain}")
        set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
    endif()
endif()

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

# Optional: core library for tests/demos (created by Qt Assistant when tests enabled)
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/src/calculator.cpp")
    add_library(${PROJECT_NAME}_core STATIC
        src/calculator.cpp
        include/calculator.h
    )
    target_include_directories(${PROJECT_NAME}_core PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES})

set_target_properties(${PROJECT_NAME} PROPERTIES
    DEBUG_POSTFIX "d"
)

# Link Qt libraries
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME} Qt6::Core)
else()
    target_link_libraries(${PROJECT_NAME} Qt5::Core)
endif()

if(TARGET ${PROJECT_NAME}_core)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_core)
endif()

# Optional: runnable demo program
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/examples/demo.cpp")
    add_executable(${PROJECT_NAME}_demo examples/demo.cpp)
    set_target_properties(${PROJECT_NAME}_demo PROPERTIES DEBUG_POSTFIX "d")
    if(TARGET ${PROJECT_NAME}_core)
        target_link_libraries(${PROJECT_NAME}_demo PRIVATE ${PROJECT_NAME}_core)
    endif()
    target_include_directories(${PROJECT_NAME}_demo PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()

# 字符集设置，避免中文路径/源码乱码
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /utf-8 /wd4399)
    target_compile_definitions(${PROJECT_NAME} PRIVATE UNICODE _UNICODE)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
endif()


# Install rules
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Packaging (default: ZIP)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)
]]

    builtin_templates.cmake_quick_app = [[
cmake_minimum_required(VERSION 3.16)

# vcpkg toolchain (optional, fallback): OFF by default.
# Note: toolchain must be set before the first project() call.
option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_vcpkg_toolchain}")
        set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
    endif()
endif()

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

# Optional: core library for tests/demos (created by Qt Assistant when tests enabled)
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/src/calculator.cpp")
    add_library(${PROJECT_NAME}_core STATIC
        src/calculator.cpp
        include/calculator.h
    )
    target_include_directories(${PROJECT_NAME}_core PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()

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

if(TARGET ${PROJECT_NAME}_core)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_core)
endif()

# Optional: runnable demo program
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/examples/demo.cpp")
    add_executable(${PROJECT_NAME}_demo examples/demo.cpp)
    set_target_properties(${PROJECT_NAME}_demo PROPERTIES DEBUG_POSTFIX "d")
    if(TARGET ${PROJECT_NAME}_core)
        target_link_libraries(${PROJECT_NAME}_demo PRIVATE ${PROJECT_NAME}_core)
    endif()
    target_include_directories(${PROJECT_NAME}_demo PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()

# 字符集设置，避免中文路径/源码乱码
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /utf-8 /wd4399)
    target_compile_definitions(${PROJECT_NAME} PRIVATE UNICODE _UNICODE)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
endif()


# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    DEBUG_POSTFIX "d"
)

# Platform-specific settings
if(WIN32)
    # Windows-specific settings
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()

# Install rules
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Packaging (default: ZIP)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)
]]

    -- Multi-module project templates
    builtin_templates.cmake_multi_project = [[
cmake_minimum_required(VERSION 3.16)

# vcpkg toolchain (optional, fallback): OFF by default.
# Note: toolchain must be set before the first project() call.
option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_vcpkg_toolchain}")
        set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
    endif()
endif()

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

# Packaging (default: ZIP). Add install rules in submodules as needed.
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)

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

# vcpkg toolchain (optional, fallback): OFF by default.
# Note: toolchain must be set before the first project() call.
option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_vcpkg_toolchain}")
        set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
    endif()
endif()

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
    src/{{PROJECT_NAME}}/{{PROJECT_NAME}}.cpp
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
    DEBUG_POSTFIX "d"
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

# Optional: runnable demo program
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/examples/demo.cpp")
    add_executable({{PROJECT_NAME}}_demo examples/demo.cpp)
    set_target_properties({{PROJECT_NAME}}_demo PROPERTIES DEBUG_POSTFIX "d")
    target_link_libraries({{PROJECT_NAME}}_demo PRIVATE {{PROJECT_NAME}})
    target_include_directories({{PROJECT_NAME}}_demo PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()

# 字符集设置，避免中文路径/源码乱码
if(MSVC)
    target_compile_options({{PROJECT_NAME}} PRIVATE /utf-8 /wd4399)
    target_compile_definitions({{PROJECT_NAME}} PRIVATE UNICODE _UNICODE)
else()
    target_compile_options({{PROJECT_NAME}} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
endif()



# Export symbols for Windows
if(WIN32)
    target_compile_definitions({{PROJECT_NAME}} PRIVATE {{PROJECT_NAME_UPPER}}_EXPORTS)
endif()

# 字符集设置，避免中文路径/源码乱码
if(MSVC)
    target_compile_options({{PROJECT_NAME}} PRIVATE /utf-8 /wd4399)
    target_compile_definitions({{PROJECT_NAME}} PRIVATE UNICODE _UNICODE)
else()
    target_compile_options({{PROJECT_NAME}} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
endif()

# 字符集设置，避免中文路径/源码乱码
if(MSVC)
    target_compile_options({{PROJECT_NAME}} PRIVATE /utf-8 /wd4399)
    target_compile_definitions({{PROJECT_NAME}} PRIVATE UNICODE _UNICODE)
else()
    target_compile_options({{PROJECT_NAME}} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
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

# Packaging (default: ZIP)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)
]]

    builtin_templates.cmake_static_lib = [[
cmake_minimum_required(VERSION 3.16)

# vcpkg toolchain (optional, fallback): OFF by default.
# Note: toolchain must be set before the first project() call.
option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_vcpkg_toolchain}")
        set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
    endif()
endif()

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
    src/{{PROJECT_NAME}}/{{PROJECT_NAME}}.cpp
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

set_target_properties({{PROJECT_NAME}} PROPERTIES
    DEBUG_POSTFIX "d"
)

# Mark as static for export macro handling
target_compile_definitions({{PROJECT_NAME}} PUBLIC {{PROJECT_NAME_UPPER}}_STATIC)

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

# Optional: runnable demo program
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/examples/demo.cpp")
    add_executable({{PROJECT_NAME}}_demo examples/demo.cpp)
    set_target_properties({{PROJECT_NAME}}_demo PROPERTIES DEBUG_POSTFIX "d")
    target_link_libraries({{PROJECT_NAME}}_demo PRIVATE {{PROJECT_NAME}})
    target_include_directories({{PROJECT_NAME}}_demo PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
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

# Packaging (default: ZIP)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)
]]

    builtin_templates.cmake_plugin = [[
cmake_minimum_required(VERSION 3.16)

    # vcpkg toolchain (optional, fallback): OFF by default.
    # Note: toolchain must be set before the first project() call.
    option(QT_ASSISTANT_USE_VCPKG "Use vcpkg toolchain (fallback option)" OFF)
    if(QT_ASSISTANT_USE_VCPKG AND NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
        set(_vcpkg_toolchain "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
        if(EXISTS "${_vcpkg_toolchain}")
            set(CMAKE_TOOLCHAIN_FILE "${_vcpkg_toolchain}" CACHE STRING "vcpkg toolchain file")
            message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
        else()
            message(WARNING "QT_ASSISTANT_USE_VCPKG is ON but vcpkg toolchain not found under VCPKG_ROOT")
        endif()
    endif()

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
    src/{{PROJECT_NAME}}/{{PROJECT_NAME}}.cpp
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

# Create plugin (SHARED keeps it loadable as a plugin and also linkable for demos/tests)
add_library({{PROJECT_NAME}} SHARED ${SOURCES} ${HEADERS})

set_target_properties({{PROJECT_NAME}} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
    PREFIX ""  # Remove 'lib' prefix on Unix
    DEBUG_POSTFIX "d"
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

# Optional: runnable demo program
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/examples/demo.cpp")
    add_executable({{PROJECT_NAME}}_demo examples/demo.cpp)
    set_target_properties({{PROJECT_NAME}}_demo PROPERTIES DEBUG_POSTFIX "d")
    target_link_libraries({{PROJECT_NAME}}_demo PRIVATE {{PROJECT_NAME}})
    target_include_directories({{PROJECT_NAME}}_demo PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include
    )
endif()


# Export symbols for Windows
if(WIN32)
    target_compile_definitions({{PROJECT_NAME}} PRIVATE {{PROJECT_NAME_UPPER}}_EXPORTS)
endif()

# Installation rules
install(TARGETS {{PROJECT_NAME}}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/plugins
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Packaging (default: ZIP)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "ZIP")
include(CPack)
]]

    -- Tests (Qt Test) templates
    builtin_templates.cmake_tests_app = [[
# Tests for {{PROJECT_NAME}} (Qt Test) - app template

set(CMAKE_AUTOMOC ON)

# Prefer using the same Qt major as the main project if available
if(NOT DEFINED QT_VERSION_MAJOR)
    find_package(Qt6 COMPONENTS Core Test QUIET)
    if(Qt6_FOUND)
        set(QT_VERSION_MAJOR 6)
    else()
        find_package(Qt5 5.15 COMPONENTS Core Test REQUIRED)
        set(QT_VERSION_MAJOR 5)
    endif()
endif()

if(QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS Core Test REQUIRED)
else()
    find_package(Qt5 5.15 COMPONENTS Core Test REQUIRED)
endif()

add_executable({{PROJECT_NAME}}_tests
    test_basic.cpp
)

target_include_directories({{PROJECT_NAME}}_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

if(TARGET {{PROJECT_NAME}}_core)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE {{PROJECT_NAME}}_core)
endif()

if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE Qt6::Core Qt6::Test)
else()
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE Qt5::Core Qt5::Test)
endif()

add_test(NAME {{PROJECT_NAME}}_tests COMMAND {{PROJECT_NAME}}_tests)
]]

    builtin_templates.cmake_tests_lib = [[
# Tests for {{PROJECT_NAME}} (Qt Test) - library/plugin template

set(CMAKE_AUTOMOC ON)

# Prefer using the same Qt major as the main project if available
if(NOT DEFINED QT_VERSION_MAJOR)
    find_package(Qt6 COMPONENTS Core Test QUIET)
    if(Qt6_FOUND)
        set(QT_VERSION_MAJOR 6)
    else()
        find_package(Qt5 5.15 COMPONENTS Core Test REQUIRED)
        set(QT_VERSION_MAJOR 5)
    endif()
endif()

if(QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS Core Test REQUIRED)
else()
    find_package(Qt5 5.15 COMPONENTS Core Test REQUIRED)
endif()

add_executable({{PROJECT_NAME}}_tests
    test_basic.cpp
)

target_include_directories({{PROJECT_NAME}}_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

if(TARGET {{PROJECT_NAME}})
    # Link only if it's a library-type target
    get_target_property(_qa_target_type {{PROJECT_NAME}} TYPE)
    if(_qa_target_type AND NOT _qa_target_type STREQUAL "EXECUTABLE")
        target_link_libraries({{PROJECT_NAME}}_tests PRIVATE {{PROJECT_NAME}})
    endif()
endif()

if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE Qt6::Core Qt6::Test)
else()
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE Qt5::Core Qt5::Test)
endif()

add_test(NAME {{PROJECT_NAME}}_tests COMMAND {{PROJECT_NAME}}_tests)
]]

    builtin_templates.qt_test_app = [[
#include <QtTest/QtTest>
#include "calculator.h"

class CalculatorTest : public QObject {
    Q_OBJECT

private slots:
    void add_works() {
        QCOMPARE(Calculator::add(1, 2), 3);
        QCOMPARE(Calculator::add(-1, 1), 0);
    }

    void sub_works() {
        QCOMPARE(Calculator::sub(10, 3), 7);
    }
};

QTEST_MAIN(CalculatorTest)
#include "test_basic.moc"
]]

    builtin_templates.qt_test_lib = [[
#include <QtTest/QtTest>
#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"

class LibrarySmokeTest : public QObject {
    Q_OBJECT

private slots:
    void add_works() {
        {{CLASS_NAME}} api;
        QCOMPARE(api.add(1, 2), 3);
    }
};

QTEST_MAIN(LibrarySmokeTest)
#include "test_basic.moc"
]]

    builtin_templates.cmake_gtest_tests_app = [[
# Tests for {{PROJECT_NAME}} (GoogleTest)

# vcpkg typically provides a CMake config package for GTest
find_package(GTest CONFIG QUIET)
if(NOT GTest_FOUND)
    find_package(GTest REQUIRED)
endif()

add_executable({{PROJECT_NAME}}_tests
    test_basic.cpp
)

target_include_directories({{PROJECT_NAME}}_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

if(TARGET {{PROJECT_NAME}}_core)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE {{PROJECT_NAME}}_core)
endif()

if(TARGET GTest::gtest_main)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE GTest::gtest GTest::gtest_main)
elseif(TARGET GTest::Main)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE GTest::GTest GTest::Main)
else()
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE GTest::GTest)
endif()

add_test(NAME {{PROJECT_NAME}}_tests COMMAND {{PROJECT_NAME}}_tests)
]]

    builtin_templates.cmake_gtest_tests_lib = [[
# Tests for {{PROJECT_NAME}} (GoogleTest)

# vcpkg typically provides a CMake config package for GTest
find_package(GTest CONFIG QUIET)
if(NOT GTest_FOUND)
    find_package(GTest REQUIRED)
endif()

add_executable({{PROJECT_NAME}}_tests
    test_basic.cpp
)

target_include_directories({{PROJECT_NAME}}_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

if(TARGET {{PROJECT_NAME}})
    get_target_property(_qa_target_type {{PROJECT_NAME}} TYPE)
    if(_qa_target_type AND NOT _qa_target_type STREQUAL "EXECUTABLE")
        target_link_libraries({{PROJECT_NAME}}_tests PRIVATE {{PROJECT_NAME}})
    endif()
endif()

if(TARGET GTest::gtest_main)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE GTest::gtest GTest::gtest_main)
elseif(TARGET GTest::Main)
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE GTest::GTest GTest::Main)
else()
    target_link_libraries({{PROJECT_NAME}}_tests PRIVATE GTest::GTest)
endif()

add_test(NAME {{PROJECT_NAME}}_tests COMMAND {{PROJECT_NAME}}_tests)
]]

    builtin_templates.gtest_test_app = [[
#include <gtest/gtest.h>

#include "calculator.h"

TEST(CalculatorTest, Add) {
    EXPECT_EQ(Calculator::add(1, 2), 3);
}

TEST(CalculatorTest, Sub) {
    EXPECT_EQ(Calculator::sub(10, 3), 7);
}
]]

    builtin_templates.gtest_test_lib = [[
#include <gtest/gtest.h>

#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"

TEST(LibrarySmokeTest, Add) {
    {{CLASS_NAME}} api;
    EXPECT_EQ(api.add(1, 2), 3);
}
]]

    -- App helper (calculator) templates
    builtin_templates.calculator_header = [[
#pragma once

class Calculator {
public:
    static int add(int a, int b) noexcept;
    static int sub(int a, int b) noexcept;
};
]]

    builtin_templates.calculator_source = [[
#include "calculator.h"

int Calculator::add(int a, int b) noexcept
{
    return a + b;
}

int Calculator::sub(int a, int b) noexcept
{
    return a - b;
}
]]

    -- Runnable demo templates
    builtin_templates.demo_app = [[
#include <iostream>

#include "calculator.h"

int main()
{
    const int a = 12;
    const int b = 30;
    std::cout << "Calculator demo: " << a << " + " << b << " = " << Calculator::add(a, b) << "\n";
    std::cout << "Calculator demo: " << a << " - " << b << " = " << Calculator::sub(a, b) << "\n";
    return 0;
}
]]

    builtin_templates.demo_lib = [[
#include <QCoreApplication>
#include <QDebug>

#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    {{CLASS_NAME}} api;
    qDebug() << "Library demo: 12 + 30 =" << api.add(12, 30);
    qDebug() << "Library demo: echo =" << api.echo(QStringLiteral("Hello from {{PROJECT_NAME}}"));

    return 0;
}
]]

    -- Library / Plugin source templates
    builtin_templates.library_export_header = [[
#ifndef {{PROJECT_NAME_UPPER}}_EXPORT_H
#define {{PROJECT_NAME_UPPER}}_EXPORT_H

#include <QtGlobal>

#if defined({{PROJECT_NAME_UPPER}}_STATIC)
#  define {{PROJECT_NAME_UPPER}}_EXPORT
#elif defined(Q_OS_WIN)
#  if defined({{PROJECT_NAME_UPPER}}_EXPORTS)
#    define {{PROJECT_NAME_UPPER}}_EXPORT __declspec(dllexport)
#  else
#    define {{PROJECT_NAME_UPPER}}_EXPORT __declspec(dllimport)
#  endif
#else
#  define {{PROJECT_NAME_UPPER}}_EXPORT __attribute__((visibility("default")))
#endif

#endif // {{PROJECT_NAME_UPPER}}_EXPORT_H
]]

    builtin_templates.library_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QObject>
#include <QString>
#include "{{PROJECT_NAME}}_export.h"

class {{PROJECT_NAME_UPPER}}_EXPORT {{CLASS_NAME}} : public QObject
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
    virtual ~{{CLASS_NAME}}();

    int add(int a, int b) const;
    QString echo(const QString& text) const;

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

int {{CLASS_NAME}}::add(int a, int b) const
{
    return a + b;
}

QString {{CLASS_NAME}}::echo(const QString& text) const
{
    return text;
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
#include <QString>
#include "{{PROJECT_NAME}}_export.h"

class {{PROJECT_NAME_UPPER}}_EXPORT {{CLASS_NAME}} : public QObject
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "{{PLUGIN_IID}}")

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
    ~{{CLASS_NAME}}() override;

    int add(int a, int b) const;
    QString echo(const QString& text) const;

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

int {{CLASS_NAME}}::add(int a, int b) const
{
    return a + b;
}

QString {{CLASS_NAME}}::echo(const QString& text) const
{
    return text;
}

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
请选择适合当前操作系统的生成器，并为不同生成器使用不同的构建目录。

### Windows（MSVC / MinGW(GCC) / Clang / Ninja）
```pwsh
# 0) 提示：MSVC/clang-cl 通常需要先进入“开发者命令提示符(Developer Command Prompt)”
# 或手动执行 vcvars64.bat，确保 cl.exe/link.exe 在 PATH。

# 1) MSVC（IDE/调试友好；生成器名可替换为 VS2019/VS2022）
cmake -S . -B build-msvc -G "Visual Studio 15 2017" -A x64 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-msvc --config Debug

# 2) MinGW（GCC）
# 适用于安装了“Qt + MinGW”或 MSYS2/MinGW-w64 的环境；确保 gcc/g++/mingw32-make 在 PATH
cmake -S . -B build-mingw -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-mingw

# 3) Clang（两种常见方式）
# 3.1 clang-cl（走 MSVC ABI，适合 Windows 平台；通常也需要 vcvars 环境）
cmake -S . -B build-clangcl -G "Ninja" -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-clangcl

# 3.2 clang++（GNU 风格；配合 MinGW/LLVM 工具链时可用）
cmake -S . -B build-clang -G "Ninja" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-clang

# 4) Ninja（轻量、适合 clangd；编译器随当前环境/CC/CXX 或 CMAKE_*_COMPILER 决定）
cmake -S . -B build-ninja -G "Ninja" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-ninja
```

### Linux / macOS（GCC / Clang + Ninja / Makefiles）
```bash
# GCC（默认；若系统默认不是 GCC，可显式指定）
cmake -S . -B build-gcc -G Ninja -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-gcc

# Clang（推荐搭配 clangd）
cmake -S . -B build-clang -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-clang

# 或 Unix Makefiles
cmake -S . -B build-make -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-make
```

> 重要：同一构建目录只能使用同一种生成器。切换生成器请改用新的目录（如 build-msvc、build-ninja、build-make）。

### 可选：使用 CMakePresets（推荐）
你可以在项目根目录创建 `CMakePresets.json`，把“生成器/编译器/构建目录”固化下来：

- 用 Qt Assistant：`:QtCMakePresets`，然后 `:QtBuildPreset debug`
- 或手动命令：`cmake --preset=debug`，再 `cmake --build --preset=debug`

> 说明：默认 presets 使用 Ninja。若你要用 MSVC/MinGW/Clang，请在 presets 的 `generator`/`cacheVariables` 中调整。

### （若使用 vcpkg 安装依赖）
当你用 vcpkg 安装 Qt/依赖时，构建成功的关键是：**编译器/生成器 与 vcpkg triplet 必须匹配**。

1) 确保已设置 vcpkg 工具链（两种方式二选一）：
- Qt Assistant 插件配置里启用 `vcpkg.enabled = true`（会自动追加 `-DCMAKE_TOOLCHAIN_FILE=.../vcpkg.cmake`）
- 或手动 CMake：`-DCMAKE_TOOLCHAIN_FILE=<VCPKG_ROOT>/scripts/buildsystems/vcpkg.cmake`

2) 显式指定 triplet（推荐；避免默认 triplet 与当前工具链不一致）：
- 环境变量：`VCPKG_DEFAULT_TRIPLET=x64-windows`（示例）
- 或 CMake 参数：`-DVCPKG_TARGET_TRIPLET=x64-windows`

常见 triplet 示例：
- Windows + MSVC：`x64-windows` / `x64-windows-static`
- Windows + MinGW：`x64-mingw-dynamic` / `x64-mingw-static`
- Windows + clang-cl：`x64-windows-clang`（以及对应 static 变体）

示例（Windows + Ninja + MSVC triplet）：
```pwsh
cmake -S . -B build -G Ninja -DVCPKG_TARGET_TRIPLET=x64-windows -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

> 注意：不要用 `x64-windows` 的 Qt 去配 MinGW 构建，也不要反过来混用；切换工具链请换新的构建目录。

### （若使用 qmake 工程）
如果你的工程是 `*.pro`（qmake），构建通常是：

- 生成：`qmake -o build/Makefile <your>.pro`
- 编译：MinGW 用 `mingw32-make`；MSVC 用 `nmake`；Linux/macOS 用 `make`

## 运行主程序
- 生成：`cmake --build <build-dir> --target {{PROJECT_NAME}}`（VS 需加 `--config Debug/Release`）
- 运行：可执行文件位置取决于生成器；常见为 `<build-dir>/bin/`。

## 运行示例程序（如存在）
- 构建：`cmake --build <build-dir> --target {{PROJECT_NAME}}_demo`（VS 需加 `--config Debug/Release`）
- 说明：示例源码位于 `examples/demo.cpp`。

## 运行测试（如存在）
- 构建：`cmake --build <build-dir> --target {{PROJECT_NAME}}_tests`（VS 需加 `--config Debug/Release`）
- 执行：`ctest --test-dir <build-dir> --output-on-failure`（VS 加 `-C Debug/Release`）

## clangd / 编译数据库
- 若根目录缺少 `compile_commands.json`，请把构建目录中的文件复制/链接到根目录，或在 clangd 参数中指定 `--compile-commands-dir=<build-dir>`。
- 修改 CMakeLists 或新增源码后，重新运行生成步骤以刷新编译数据库。

## 安装与打包
- 安装（示例）：`cmake --install <build-dir> --prefix "${PWD}/install"`
- 打包（ZIP，依赖 CPack）：进入构建目录后运行 `cpack -G ZIP -C Release`

## 目录速览
- 源码：`src/`
- 头文件：`include/`
- 示例程序：`examples/`（若存在，目标一般为 `{{PROJECT_NAME}}_demo`）
- 单元测试：`tests/`（若存在，目标一般为 `{{PROJECT_NAME}}_tests`）
- 文档：`doc/`

## 常见问题
- 生成器冲突：同一 build 目录只能用同一生成器，切换时请清空或改用新目录。
- 未找到 Qt：检查 Qt5/Qt6 安装，必要时设置 `Qt5_DIR`/`Qt6_DIR`。
- clangd 无法解析：确保根目录存在 `compile_commands.json`，或显式传入 `--compile-commands-dir`。
]]

    builtin_templates.doc_shared_library_guide = [[
# {{PROJECT_NAME}} Shared Library Guide

本项目生成动态库（含插件模式），下面说明导出宏、构建与使用要点。

## 导出宏与静态守护
- 头文件：`include/{{PROJECT_NAME}}/{{PROJECT_NAME}}_export.h`
- 宏：`{{PROJECT_NAME_UPPER}}_EXPORT` 用于导出/导入符号。
- 静态构建：在 `CMakeLists.txt` 会定义 `{{PROJECT_NAME_UPPER}}_STATIC`，可在需要时自行添加，避免导入导出宏导致的符号冲突。

## 构建示例
### Windows（MSVC / MinGW / Clang / Ninja）
```pwsh
cmake -S . -B build-msvc -G "Visual Studio 15 2017" -A x64 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-msvc --config Debug

cmake -S . -B build-mingw -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-mingw

cmake -S . -B build-clangcl -G "Ninja" -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-clangcl

cmake -S . -B build-ninja -G "Ninja" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ninja -C build-ninja
```

### Linux / macOS（GCC / Clang + Ninja / Makefiles）
```bash
cmake -S . -B build-gcc -G Ninja -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-gcc

cmake -S . -B build-clang -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-clang

cmake -S . -B build-make -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-make
```

> 生成器不可混用同一 build 目录，切换生成器请改用新目录。

## 使用动态库
- 头文件：`include/`
- 库文件：构建后位于对应 build 目录（例如 `build-ninja/`）。
- CMake 使用：
```cmake
find_package({{PROJECT_NAME}} CONFIG REQUIRED)
target_link_libraries(MyApp PRIVATE {{PROJECT_NAME}})
```
- 运行时：确保可执行文件能找到动态库（Windows 需把 dll 放到运行目录或设置 PATH；Linux/macOS 确保 rpath/LD_LIBRARY_PATH）。

## 安装与打包
- 安装（示例）：`cmake --install build-ninja --prefix "${PWD}/install"`，头文件、库、插件按 `GNUInstallDirs` 安装到标准目录。
- 打包（ZIP，使用 CPack）：在构建目录执行 `cpack -G ZIP -C Release`，生成的压缩包包含安装产物。

## 插件（如适用）
- 插件目标与导出宏一致，只是通过插件 IID 暴露。
- 部署时将插件放入 Qt 插件搜索路径或自行加载插件目录。

## 调试提示
- 若发现符号未导出，检查类/函数是否标注 `{{PROJECT_NAME_UPPER}}_EXPORT`。
- 若静态链接报错，确认 `{{PROJECT_NAME_UPPER}}_STATIC` 是否按需定义。

## 示例程序与测试（若启用）
- 示例程序：`examples/demo.cpp`（目标通常为 `{{PROJECT_NAME}}_demo`）
- 测试：`tests/test_basic.cpp`（目标通常为 `{{PROJECT_NAME}}_tests`，通过 `ctest` 运行）

### 构建示例程序
```bash
cmake --build <build-dir> --target {{PROJECT_NAME}}_demo
```

### 运行测试
```bash
ctest --test-dir <build-dir> --output-on-failure
```
]]

    -- Module guide (for multi-module projects)
    builtin_templates.doc_module_guide = [[
# {{PROJECT_NAME}} Module Guide

## 概览
- 模块名称：{{PROJECT_NAME}}
- 模块类型：{{MODULE_TYPE}}
- 目录：源码 `src/`，头文件 `include/`，文档 `doc/`

## 构建方式（推荐：在根项目构建）
在 multi-module 根目录创建构建目录并生成后，模块会通过 `add_subdirectory({{PROJECT_NAME}})` 自动参与构建。

## 在根工程中添加模块（可直接复制）
将下列片段加入根工程的 `CMakeLists.txt`（通常放在其它 `add_subdirectory(...)` 附近，按依赖顺序排列）：

```cmake
add_subdirectory({{PROJECT_NAME}})
```

> 若根工程已由 Qt Assistant 自动插入 `add_subdirectory({{PROJECT_NAME}})`，无需重复添加。

### 仅构建此模块
```bash
cmake --build <root-build-dir> --target {{PROJECT_NAME}}
```

## 在其它目标中使用本模块（可直接复制）
下面示例演示：在另一个目标（例如 `app`）里链接本模块，并确保包含路径正确。

```cmake
# 假设你的可执行/库目标名为 MyAppTarget
target_link_libraries(MyAppTarget PRIVATE {{PROJECT_NAME}})
```

通常无需手动 `target_include_directories(MyAppTarget ...)`，因为本模块模板会把 `include/` 作为 `PUBLIC` 导出（可通过查看本模块 `CMakeLists.txt` 的 `target_include_directories` 验证）。

{{#IS_LIBRARY}}
### 库模块（shared/static）使用示例

```cmake
# 1) 根工程包含该模块
add_subdirectory({{PROJECT_NAME}})

# 2) 在应用/其它库中链接
target_link_libraries(MyAppTarget PRIVATE {{PROJECT_NAME}})
```

头文件包含方式（示例）：

```cpp
#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"
```
{{/IS_LIBRARY}}

{{#IS_PLUGIN}}
### 插件模块使用示例

本模板的插件目标是 `{{PROJECT_NAME}}`（使用 `SHARED` 生成，既可被 Qt 插件机制加载，也能用于 demo/tests 直接链接）。

```cmake
add_subdirectory({{PROJECT_NAME}})
target_link_libraries(MyAppTarget PRIVATE {{PROJECT_NAME}})
```

头文件包含方式（示例）：

```cpp
#include "{{PROJECT_NAME}}/{{PROJECT_NAME}}.h"
```

如果你希望“纯插件（不参与链接）”的形式，也可以把模块 `CMakeLists.txt` 的 `add_library(... SHARED ...)` 改回 `MODULE`；此时 demo/tests 将不能再直接链接该插件目标（但仍可通过运行时加载验证）。
{{/IS_PLUGIN}}

{{#IS_APP}}
### 应用模块（widget/quick/console）使用示例

应用模块通常是可执行文件目标。根工程引用：

```cmake
add_subdirectory({{PROJECT_NAME}})
```

如果应用要链接其它模块（例如 `mylib`），在应用模块的 `CMakeLists.txt` 中追加：

```cmake
target_link_libraries({{PROJECT_NAME}} PRIVATE mylib)
```

若出现找不到头文件：
- 优先确认被链接模块是否导出了 `include/`（`PUBLIC` include dirs）。
- 或在应用目标上临时添加（不推荐长期依赖）：

```cmake
target_include_directories({{PROJECT_NAME}} PRIVATE ${CMAKE_SOURCE_DIR}/mylib/include)
```
{{/IS_APP}}

## 目标（Targets）
- 主目标：`{{PROJECT_NAME}}`
- 可选示例：`{{PROJECT_NAME}}_demo`（如生成 `examples/demo.cpp`）
- 可选测试：`{{PROJECT_NAME}}_tests`（如生成 `tests/` 并开启 CTest）

## 依赖与包含
- 本模块头文件默认从 `include/` 导出；使用时在上层目标 `target_link_libraries(...)` 并添加 include 路径即可。

## 常见问题
- 若根项目未包含该模块：检查根 `CMakeLists.txt` 是否已有 `add_subdirectory({{PROJECT_NAME}})`。
- Windows 多配置生成器：使用 `--config Debug/Release` 指定配置。
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
