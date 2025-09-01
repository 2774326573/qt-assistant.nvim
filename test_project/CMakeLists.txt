cmake_minimum_required(VERSION 3.16)
project(TestQtApp VERSION 1.0 LANGUAGES CXX)

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