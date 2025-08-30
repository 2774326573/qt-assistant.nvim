-- Qt Assistant Plugin - Template management module (simplified)
-- Template management module (simplified)

local M = {}

-- Template configuration
local template_configs = {
	main_window = {
		has_header = true,
		has_source = true,
		has_ui = true,
		base_class = "QMainWindow",
	},
	dialog = {
		has_header = true,
		has_source = true,
		has_ui = true,
		base_class = "QDialog",
	},
	widget = {
		has_header = true,
		has_source = true,
		has_ui = false,
		base_class = "QWidget",
	},
	model = {
		has_header = true,
		has_source = true,
		has_ui = false,
		base_class = "QAbstractItemModel",
	},
	delegate = {
		has_header = true,
		has_source = true,
		has_ui = false,
		base_class = "QStyledItemDelegate",
	},
	thread = {
		has_header = true,
		has_source = true,
		has_ui = false,
		base_class = "QThread",
	},
	utility = {
		has_header = true,
		has_source = true,
		has_ui = false,
		base_class = "QObject",
	},
	singleton = {
		has_header = true,
		has_source = true,
		has_ui = false,
		base_class = "QObject",
	},
}

-- Builtin templates
local builtin_templates = {}

-- Initialize template system
function M.init(template_path)
	M.template_path = template_path
	M.load_builtin_templates()
end

-- Load builtin templates | ch: 加载内置模板
function M.load_builtin_templates()
	-- Simplified main window header template | ch: 最小化主窗口头文件模板
	builtin_templates.main_window_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QMainWindow>

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
};

#endif // {{HEADER_GUARD}}
]]

	-- Simplified main window source template | ch: 最小化主窗口源代码模板
	builtin_templates.main_window_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QMainWindow(parent)
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

void {{CLASS_NAME}}::onActionTriggered()
{
    // TODO: Handle action
}
]]

	-- Simplified dialog header template | ch: 最小化对话框头文件模板
	builtin_templates.dialog_header = [[
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}

#include <QDialog>

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
};

#endif // {{HEADER_GUARD}}
]]

	-- Simplified dialog source template | ch: 最小化对话框源代码模板
	builtin_templates.dialog_source = [[
#include "{{FILE_NAME}}.h"

{{CLASS_NAME}}::{{CLASS_NAME}}(QWidget *parent)
    : QDialog(parent)
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

	-- Widget template | ch: 小部件模板
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

protected:
    void paintEvent(QPaintEvent *event) override;

private:
    void setupUI();
};

#endif // {{HEADER_GUARD}}
]]

	builtin_templates.widget_source = [[
#include "{{FILE_NAME}}.h"
#include <QPainter>

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

void {{CLASS_NAME}}::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event)
    QPainter painter(this);
    // TODO: Custom painting
}
]]

	-- Add basic UI templates | ch: 添加基本UI模板
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
 </widget>
 <resources/>
 <connections/>
</ui>
]]
end

-- Get template configuration | ch: 获取模板配置
function M.get_template_config(class_type)
	return template_configs[class_type]
end

-- Render template | ch: 渲染模板
function M.render_template(template_name, variables)
	local template = builtin_templates[template_name]
	if not template then
		return nil, "Template not found: " .. template_name
	end

	local rendered = template
	for key, value in pairs(variables or {}) do
		local pattern = "{{" .. key .. "}}"
		rendered = rendered:gsub(pattern, tostring(value))
	end

	return rendered
end

-- Get all available templates | ch: 获取所有可用模板
function M.get_available_templates()
	local templates = {}
	for name, _ in pairs(builtin_templates) do
		table.insert(templates, name)
	end
	return templates
end

-- Check if template exists |ch: 检查模板是否存在
function M.template_exists(template_name)
	return builtin_templates[template_name] ~= nil
end

-- Initialize on module load | ch: 模块加载时初始化
M.load_builtin_templates()

return M

