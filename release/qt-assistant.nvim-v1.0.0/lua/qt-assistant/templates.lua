-- Qt Assistant Plugin - 模板管理模块
-- Template management module

local M = {}

-- 模板配置
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

-- 内置模板
local builtin_templates = {}

-- 初始化模板系统
function M.init(template_path)
    M.template_path = template_path
    M.load_builtin_templates()
end

-- 加载内置模板
function M.load_builtin_templates()
    -- Main Window 头文件模板
    builtin_templates.main_window_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QMainWindow>

QT_BEGIN_NAMESPACE
class QAction;
class QMenu;
class QMenuBar;
class QStatusBar;
class QToolBar;
{{#INCLUDE_UI}}
QT_FORWARD_DECLARE_CLASS(Ui::{{CLASS_NAME}})
{{/INCLUDE_UI}}
QT_END_NAMESPACE

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
    void setupMenus();
    void setupToolBars();
    void setupStatusBar();
    void connectSignals();

{{#INCLUDE_UI}}
    Ui::{{CLASS_NAME}} *ui;
{{/INCLUDE_UI}}
};

#endif // {{HEADER_GUARD}}
]]

    -- Main Window 源文件模板
    builtin_templates.main_window_source = [[
#include "{{FILE_NAME}}.h"
{{#INCLUDE_UI}}
#include "ui_{{FILE_NAME}}.h"
{{/INCLUDE_UI}}

#include <QAction>
#include <QApplication>
#include <QMenuBar>
#include <QStatusBar>
#include <QToolBar>

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QMainWindow(parent)
{{#INCLUDE_UI}}
    , ui(new Ui::{{CLASS_NAME}})
{{/INCLUDE_UI}}
{
{{#INCLUDE_UI}}
    ui->setupUi(this);
{{/INCLUDE_UI}}
    setupUI();
    setupMenus();
    setupToolBars();
    setupStatusBar();
    connectSignals();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
{{#INCLUDE_UI}}
    delete ui;
{{/INCLUDE_UI}}
}

void {{CLASS_NAME}}::onActionTriggered()
{
    // TODO: Implement action handler
}

void {{CLASS_NAME}}::setupUI()
{
    setWindowTitle("{{CLASS_NAME}}");
    resize(800, 600);
}

void {{CLASS_NAME}}::setupMenus()
{
    // TODO: Setup menus
}

void {{CLASS_NAME}}::setupToolBars()
{
    // TODO: Setup toolbars
}

void {{CLASS_NAME}}::setupStatusBar()
{
    statusBar()->showMessage("Ready");
}

void {{CLASS_NAME}}::connectSignals()
{
    // TODO: Connect signals and slots
}
]]

    -- Dialog 头文件模板
    builtin_templates.dialog_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QDialog>

QT_BEGIN_NAMESPACE
{{#INCLUDE_UI}}
QT_FORWARD_DECLARE_CLASS(Ui::{{CLASS_NAME}})
{{/INCLUDE_UI}}
QT_END_NAMESPACE

class {{CLASS_NAME}} : public QDialog
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QWidget *parent = nullptr);
    ~{{CLASS_NAME}}();

public slots:
    void accept() override;
    void reject() override;

private slots:
    void onOkClicked();
    void onCancelClicked();

private:
    void setupUI();
    void connectSignals();

{{#INCLUDE_UI}}
    Ui::{{CLASS_NAME}} *ui;
{{/INCLUDE_UI}}
};

#endif // {{HEADER_GUARD}}
]]

    -- Dialog 源文件模板
    builtin_templates.dialog_source = [[
#include "{{FILE_NAME}}.h"
{{#INCLUDE_UI}}
#include "ui_{{FILE_NAME}}.h"
{{/INCLUDE_UI}}

#include <QPushButton>

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QDialog(parent)
{{#INCLUDE_UI}}
    , ui(new Ui::{{CLASS_NAME}})
{{/INCLUDE_UI}}
{
{{#INCLUDE_UI}}
    ui->setupUi(this);
{{/INCLUDE_UI}}
    setupUI();
    connectSignals();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
{{#INCLUDE_UI}}
    delete ui;
{{/INCLUDE_UI}}
}

void {{CLASS_NAME}}::accept()
{
    // TODO: Validate input and save data
    QDialog::accept();
}

void {{CLASS_NAME}}::reject()
{
    // TODO: Handle rejection
    QDialog::reject();
}

void {{CLASS_NAME}}::onOkClicked()
{
    accept();
}

void {{CLASS_NAME}}::onCancelClicked()
{
    reject();
}

void {{CLASS_NAME}}::setupUI()
{
    setWindowTitle("{{CLASS_NAME}}");
    setModal(true);
}

void {{CLASS_NAME}}::connectSignals()
{
    // TODO: Connect signals and slots
}
]]

    -- Widget 头文件模板
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

signals:
    void valueChanged(int value);

protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;

private:
    void setupUI();
    void updateDisplay();

    // Private members
    int m_value;
};

#endif // {{HEADER_GUARD}}
]]

    -- Widget 源文件模板
    builtin_templates.widget_source = [[
#include "{{FILE_NAME}}.h"

#include <QPainter>
#include <QMouseEvent>
#include <QResizeEvent>

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QWidget(parent)
    , m_value(0)
{
    setupUI();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
}

void {{CLASS_NAME}}::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event)
    
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    
    // TODO: Implement custom painting
    painter.fillRect(rect(), Qt::lightGray);
}

void {{CLASS_NAME}}::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        // TODO: Handle mouse press
    }
    
    QWidget::mousePressEvent(event);
}

void {{CLASS_NAME}}::mouseMoveEvent(QMouseEvent *event)
{
    // TODO: Handle mouse move
    QWidget::mouseMoveEvent(event);
}

void {{CLASS_NAME}}::resizeEvent(QResizeEvent *event)
{
    // TODO: Handle resize
    QWidget::resizeEvent(event);
    updateDisplay();
}

void {{CLASS_NAME}}::setupUI()
{
    setMinimumSize(100, 100);
    setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
}

void {{CLASS_NAME}}::updateDisplay()
{
    update();
}
]]

    -- 添加更多模板...
    M.add_model_templates()
    M.add_ui_templates()
    M.add_project_templates()
end

-- 添加数据模型模板
function M.add_model_templates()
    builtin_templates.model_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>

class {{CLASS_NAME}} : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit {{CLASS_NAME}}(QObject *parent = nullptr);
    ~{{CLASS_NAME}}();

    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    // Editable model
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

public slots:
    void refresh();

private:
    void setupData();

    // Private data members
    QList<QVariantList> m_data;
    QStringList m_headers;
};

#endif // {{HEADER_GUARD}}
]]

    builtin_templates.model_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QObject *parent)
    : QAbstractItemModel(parent)
{
    setupData();
}

{{CLASS_NAME}}::~{{CLASS_NAME}}()
{
}

QModelIndex {{CLASS_NAME}}::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();

    // TODO: Implement for tree models
    return createIndex(row, column, nullptr);
}

QModelIndex {{CLASS_NAME}}::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)
    // TODO: Implement for tree models
    return QModelIndex();
}

int {{CLASS_NAME}}::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data.size();
}

int {{CLASS_NAME}}::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_headers.size();
}

QVariant {{CLASS_NAME}}::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (role == Qt::DisplayRole || role == Qt::EditRole) {
        if (index.row() < m_data.size() && index.column() < m_data[index.row()].size()) {
            return m_data[index.row()][index.column()];
        }
    }

    return QVariant();
}

QVariant {{CLASS_NAME}}::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
        if (section < m_headers.size()) {
            return m_headers[section];
        }
    }

    return QVariant();
}

bool {{CLASS_NAME}}::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid() && role == Qt::EditRole) {
        if (index.row() < m_data.size() && index.column() < m_data[index.row()].size()) {
            m_data[index.row()][index.column()] = value;
            emit dataChanged(index, index, {role});
            return true;
        }
    }

    return false;
}

Qt::ItemFlags {{CLASS_NAME}}::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

void {{CLASS_NAME}}::refresh()
{
    beginResetModel();
    setupData();
    endResetModel();
}

void {{CLASS_NAME}}::setupData()
{
    // TODO: Initialize model data
    m_headers << "Column 1" << "Column 2" << "Column 3";
}
]]
end

-- 添加UI模板
function M.add_ui_templates()
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
  <widget class="QMenuBar" name="menubar">
   <property name="geometry">
    <rect>
     <x>0</x>
     <y>0</y>
     <width>800</width>
     <height>22</height>
    </rect>
   </property>
  </widget>
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
  <layout class="QVBoxLayout" name="verticalLayout">
   <item>
    <widget class="QDialogButtonBox" name="buttonBox">
     <property name="orientation">
      <enum>Qt::Horizontal</enum>
     </property>
     <property name="standardButtons">
      <set>QDialogButtonBox::Cancel|QDialogButtonBox::Ok</set>
     </property>
    </widget>
   </item>
  </layout>
 </widget>
 <resources/>
 <connections>
  <connection>
   <sender>buttonBox</sender>
   <signal>accepted()</signal>
   <receiver>{{CLASS_NAME}}</receiver>
   <slot>accept()</slot>
   <hints>
    <hint type="sourcelabel">
     <x>248</x>
     <y>254</y>
    </hint>
    <hint type="destinationlabel">
     <x>157</x>
     <y>274</y>
    </hint>
   </hints>
  </connection>
  <connection>
   <sender>buttonBox</sender>
   <signal>rejected()</signal>
   <receiver>{{CLASS_NAME}}</receiver>
   <slot>reject()</slot>
   <hints>
    <hint type="sourcelabel">
     <x>316</x>
     <y>260</y>
    </hint>
    <hint type="destinationlabel">
     <x>286</x>
     <y>274</y>
    </hint>
   </hints>
  </connection>
 </connections>
</ui>
]]
end

-- 添加项目模板
function M.add_project_templates()
    -- Widget应用主程序模板
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

    -- Quick应用主程序模板
    builtin_templates.main_quick_app = [[
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    
    return app.exec();
}
]]

    -- 控制台应用主程序模板
    builtin_templates.main_console_app = [[
#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    qDebug() << "{{PROJECT_NAME}} started";
    
    // TODO: Add your application logic here
    
    return app.exec();
}
]]

    -- CMake模板 - Widget应用
    builtin_templates.cmake_widget_app = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

qt6_standard_project_setup()

set(SOURCES
    main.cpp
    {{FILE_NAME}}.cpp
)

set(HEADERS
    {{FILE_NAME}}.h
)

set(UI_FILES
    {{FILE_NAME}}.ui
)

qt6_add_executable({{PROJECT_NAME}}
    ${SOURCES}
    ${HEADERS}
)

qt6_add_resources({{PROJECT_NAME}} "resources"
    PREFIX "/"
    FILES
        # Add resource files here
)

qt6_wrap_ui(UI_HEADERS ${UI_FILES})

target_sources({{PROJECT_NAME}} PRIVATE ${UI_HEADERS})
target_link_libraries({{PROJECT_NAME}} Qt6::Core Qt6::Widgets)

# Installation
install(TARGETS {{PROJECT_NAME}}
    BUNDLE DESTINATION .
    RUNTIME DESTINATION bin
)
]]

    -- CMake模板 - Quick应用
    builtin_templates.cmake_quick_app = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)

qt6_standard_project_setup()

set(SOURCES
    main.cpp
)

qt6_add_executable({{PROJECT_NAME}}
    ${SOURCES}
)

qt6_add_qml_module({{PROJECT_NAME}}
    URI {{PROJECT_NAME}}
    VERSION 1.0
    QML_FILES
        main.qml
)

target_link_libraries({{PROJECT_NAME}} Qt6::Core Qt6::Quick)

# Installation
install(TARGETS {{PROJECT_NAME}}
    BUNDLE DESTINATION .
    RUNTIME DESTINATION bin
)
]]

    -- CMake模板 - 控制台应用
    builtin_templates.cmake_console_app = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core)

qt6_standard_project_setup()

set(SOURCES
    main.cpp
)

qt6_add_executable({{PROJECT_NAME}}
    ${SOURCES}
)

target_link_libraries({{PROJECT_NAME}} Qt6::Core)

# Installation
install(TARGETS {{PROJECT_NAME}}
    BUNDLE DESTINATION .
    RUNTIME DESTINATION bin
)
]]

    -- CMake模板 - 库
    builtin_templates.cmake_library = [[
cmake_minimum_required(VERSION 3.16)

project({{PROJECT_NAME}} VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core)

qt6_standard_project_setup()

set(SOURCES
    {{FILE_NAME}}.cpp
)

set(HEADERS
    {{FILE_NAME}}.h
    {{FILE_NAME}}_global.h
)

qt6_add_library({{PROJECT_NAME}} SHARED
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries({{PROJECT_NAME}} Qt6::Core)

# Export symbols
target_compile_definitions({{PROJECT_NAME}} PRIVATE {{PROJECT_NAME_UPPER}}_LIBRARY)

# Installation
install(TARGETS {{PROJECT_NAME}}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES ${HEADERS}
    DESTINATION include/{{PROJECT_NAME}}
)
]]

    -- 主QML文件模板
    builtin_templates.main_qml = [[
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    
    width: 640
    height: 480
    visible: true
    title: "{{PROJECT_NAME}}"
    
    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&New...")
                onTriggered: console.log("New triggered")
            }
            MenuItem {
                text: qsTr("&Open...")
                onTriggered: console.log("Open triggered")
            }
            MenuItem {
                text: qsTr("&Save")
                onTriggered: console.log("Save triggered")
            }
            MenuSeparator { }
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: qsTr("&Help")
            MenuItem {
                text: qsTr("&About")
                onTriggered: console.log("About triggered")
            }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        
        Text {
            anchors.centerIn: parent
            text: "Welcome to {{PROJECT_NAME}}"
            font.pointSize: 24
        }
    }
}
]]

    -- QML资源文件模板
    builtin_templates.qml_resources = [[
<RCC>
    <qresource prefix="/">
        <file>main.qml</file>
    </qresource>
</RCC>
]]

    -- 库头文件模板
    builtin_templates.library_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include "{{FILE_NAME}}_global.h"

class {{CLASS_NAME_UPPER}}_EXPORT {{CLASS_NAME}}
{
public:
    {{CLASS_NAME}}();
    
    // Static utility functions
    static QString version();
    static void initialize();
    static void cleanup();
    
private:
    // Private implementation
};

#endif // {{HEADER_GUARD}}
]]

    -- 库源文件模板
    builtin_templates.library_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}()
{
    // Constructor implementation
}

QString {{CLASS_NAME}}::version()
{
    return QStringLiteral("1.0.0");
}

void {{CLASS_NAME}}::initialize()
{
    // Initialization code
}

void {{CLASS_NAME}}::cleanup()
{
    // Cleanup code
}
]]

    -- 库全局头文件模板
    builtin_templates.library_global_header = [[
#ifndef {{PROJECT_NAME_UPPER}}_GLOBAL_H
#define {{PROJECT_NAME_UPPER}}_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined({{PROJECT_NAME_UPPER}}_LIBRARY)
#  define {{CLASS_NAME_UPPER}}_EXPORT Q_DECL_EXPORT
#else
#  define {{CLASS_NAME_UPPER}}_EXPORT Q_DECL_IMPORT
#endif

#endif // {{PROJECT_NAME_UPPER}}_GLOBAL_H
]]
end

-- 获取模板配置
function M.get_template_config(class_type)
    return template_configs[class_type]
end

-- 渲染模板
function M.render_template(template_name, vars)
    local template = builtin_templates[template_name]
    if not template then
        return nil, "Template not found: " .. template_name
    end
    
    local result = template
    
    -- 简单的变量替换
    for key, value in pairs(vars) do
        result = result:gsub("{{" .. key .. "}}", tostring(value))
    end
    
    -- 处理条件语句
    result = M.process_conditionals(result, vars)
    
    return result
end

-- 处理条件语句
function M.process_conditionals(template, vars)
    -- 处理 {{#VAR}} ... {{/VAR}} 条件块
    return template:gsub("{{#(%w+)}}(.-){{/%1}}", function(var, content)
        if vars[var] then
            return content
        else
            return ""
        end
    end)
end

-- 列出可用模板
function M.list_templates()
    local templates = {}
    for name, _ in pairs(builtin_templates) do
        table.insert(templates, name)
    end
    return templates
end

return M