# Qt Assistant 新功能说明

## 新增功能

### 1. 文档模板生成

Qt Assistant 现在支持自动生成多种类型的项目文档：

- **项目文档** (`project_doc`) - 完整的项目说明文档
- **API文档** (`api_doc`) - API参考文档
- **模块文档** (`module_doc`) - 模块说明文档
- **第三方库文档** (`third_party_lib_doc`) - 第三方库集成指南

#### 使用命令

```vim
" 生成项目文档
:QtGenerateDoc project_doc

" 生成API文档
:QtGenerateDoc api_doc

" 生成模块文档
:QtGenerateDoc module_doc

" 生成第三方库集成文档
:QtGenerateDoc third_party_lib_doc
```

### 2. 相对目录第三方库导入

支持在项目的相对目录中管理和导入第三方库，无需全局安装。

#### 配置示例

```lua
require('qt-assistant').setup({
    third_party = {
        enabled = true,
        root_dir = "third_party",
        libraries = {
            boost = {
                path = "third_party/boost",
                include_dir = "include",
                lib_dir = "lib",
                version = "1.80.0"
            },
            opencv = {
                path = "third_party/opencv",
                include_dir = "include",
                lib_dir = "lib",
                use_find_package = true,
                components = {"core", "imgproc"}
            }
        },
        auto_cmake = true
    }
})
```

#### 使用命令

```vim
" 交互式添加第三方库
:QtAddThirdParty

" 生成第三方库CMake配置文件
:QtCreateThirdPartyCMake

" 生成第三方库集成文档
:QtThirdPartyDoc
```

## 快速开始

### 1. 启用新功能

在你的 Neovim 配置中：

```lua
require('qt-assistant').setup({
    -- 启用第三方库管理
    third_party = {
        enabled = true,
        root_dir = "third_party",
        libraries = {},
        auto_cmake = true
    },
    
    -- 启用文档生成
    documentation = {
        enabled = true,
        output_dir = "docs",
        default_template = "project_doc"
    }
})
```

### 2. 项目结构

```
MyQtProject/
├── CMakeLists.txt
├── src/
├── include/
├── docs/                   # 生成的文档
│   ├── PROJECT.md
│   ├── API.md
│   └── THIRD_PARTY.md
├── cmake/
│   └── ThirdParty.cmake    # 第三方库配置
└── third_party/            # 第三方库
    ├── boost/
    ├── opencv/
    └── spdlog/
```

### 3. 添加第三方库

#### 方法1：使用命令（推荐）

```vim
:QtAddThirdParty
```

然后按提示输入库信息。

#### 方法2：在配置中定义

```lua
third_party = {
    libraries = {
        boost = {
            path = "third_party/boost",
            include_dir = "include",
            lib_dir = "lib"
        }
    }
}
```

#### 方法3：生成CMake配置文件

```vim
:QtCreateThirdPartyCMake
```

这会生成 `cmake/ThirdParty.cmake` 文件，然后在主 CMakeLists.txt 中包含它：

```cmake
include(cmake/ThirdParty.cmake)

target_link_libraries(your_app PRIVATE
    boost_filesystem
    opencv_core
)
```

### 4. 生成文档

```vim
" 生成项目文档
:QtGenerateDoc

" 生成第三方库集成文档
:QtThirdPartyDoc
```

## 配置选项

### third_party 配置

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| enabled | boolean | false | 启用第三方库管理 |
| root_dir | string | "third_party" | 第三方库根目录 |
| libraries | table | {} | 库配置表 |
| auto_cmake | boolean | true | 自动生成CMake配置 |

### 库配置选项

| 选项 | 类型 | 必需 | 说明 |
|------|------|------|------|
| path | string | 是 | 库路径（相对或绝对） |
| include_dir | string | 否 | 包含目录 |
| lib_dir | string | 否 | 库文件目录 |
| version | string | 否 | 库版本 |
| use_find_package | boolean | 否 | 使用find_package |
| required | boolean | 否 | 是否必需 |
| components | table | 否 | 组件列表 |

### documentation 配置

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| enabled | boolean | true | 启用文档生成 |
| output_dir | string | "docs" | 文档输出目录 |
| default_template | string | "project_doc" | 默认模板类型 |
| auto_generate_api | boolean | false | 自动生成API文档 |

## 支持的集成方式

1. **相对路径引用** - 将第三方库放在项目目录下
2. **vcpkg** - 使用vcpkg包管理器
3. **Git Submodule** - 使用git子模块
4. **FetchContent** - CMake自动下载

详见生成的第三方库集成文档（`:QtThirdPartyDoc`）。

## 命令参考

### 文档命令

- `:QtGenerateDoc [type] [output]` - 生成文档
- `:QtThirdPartyDoc` - 生成第三方库文档

### 第三方库命令

- `:QtAddThirdParty` - 添加第三方库
- `:QtCreateThirdPartyCMake` - 创建CMake配置文件

## 示例

### 完整配置示例

```lua
require('qt-assistant').setup({
    project_root = vim.fn.getcwd(),
    
    -- 第三方库配置
    third_party = {
        enabled = true,
        root_dir = "third_party",
        libraries = {
            boost = {
                path = "third_party/boost_1_80_0",
                include_dir = "include",
                lib_dir = "lib",
                version = "1.80.0",
                use_find_package = true,
                components = {"filesystem", "system"}
            },
            opencv = {
                path = "third_party/opencv",
                include_dir = "include",
                lib_dir = "lib",
                use_find_package = true,
                required = true,
                components = {"core", "imgproc", "highgui"}
            },
            spdlog = {
                path = "third_party/spdlog",
                include_dir = "include",
                lib_dir = "lib"
            }
        },
        auto_cmake = true
    },
    
    -- 文档配置
    documentation = {
        enabled = true,
        output_dir = "docs",
        default_template = "project_doc"
    },
    
    -- 其他配置
    directories = {
        source = "src",
        include = "include",
        ui = "ui",
        resource = "resources"
    },
    
    auto_update_cmake = true,
    enable_default_keymaps = true
})
```

### 工作流程示例

```vim
" 1. 创建新项目
:QtNewProject MyApp widget_app 17

" 2. 添加第三方库
:QtAddThirdParty
" 输入库信息...

" 3. 生成CMake配置
:QtCreateThirdPartyCMake

" 4. 生成文档
:QtGenerateDoc project_doc
:QtThirdPartyDoc

" 5. 构建项目
:QtBuild
```

## 更多信息

详细使用指南请参考：
- [第三方库集成使用指南](docs/THIRD_PARTY_USAGE.md)
- [主README](README.md)

## 贡献

欢迎提交问题和改进建议！
