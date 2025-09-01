@echo off
echo ========================================
echo Qt C++ Standard Examples
echo ========================================
echo.

echo This script demonstrates how to create Qt projects with different C++ standards
echo.

echo Examples:
echo.

echo 1. Create Qt project with C++11 (Qt5 compatible):
echo    :QtNewProject MyApp widget_app 11
echo.

echo 2. Create Qt project with C++14 (Qt5 compatible):
echo    :QtNewProject MyApp widget_app 14
echo.

echo 3. Create Qt project with C++17 (Qt5/Qt6 compatible, recommended):
echo    :QtNewProject MyApp widget_app 17
echo.

echo 4. Create Qt project with C++20 (Modern features, Qt6 preferred):
echo    :QtNewProject MyApp widget_app 20
echo.

echo 5. Create Qt project with C++23 (Latest standard):
echo    :QtNewProject MyApp widget_app 23
echo.

echo 6. Interactive mode (select C++ standard):
echo    :QtNewProject
echo.

echo ========================================
echo C++ Standard Compatibility Matrix
echo ========================================
echo.

echo C++11:
echo - Qt5: Full support (minimum required)
echo - Qt6: Supported but C++17 features unavailable
echo - MSVC: VS2013+ (limited), VS2015+ (good)
echo - GCC: 4.8+ (partial), 5.0+ (good)
echo.

echo C++14:
echo - Qt5: Full support
echo - Qt6: Supported but C++17 features unavailable
echo - MSVC: VS2015+ (partial), VS2017+ (good)
echo - GCC: 5.0+ (good)
echo.

echo C++17:
echo - Qt5: Full support (recommended)
echo - Qt6: Required minimum
echo - MSVC: VS2017+ (good support)
echo - GCC: 7.0+ (good)
echo.

echo C++20:
echo - Qt5: Limited support (depends on compiler)
echo - Qt6: Good support with modern compilers
echo - MSVC: VS2019+ (partial), VS2022+ (good)
echo - GCC: 10.0+ (partial), 11.0+ (good)
echo.

echo C++23:
echo - Qt5: Very limited support
echo - Qt6: Experimental support
echo - MSVC: VS2022 17.5+ (partial)
echo - GCC: 13.0+ (experimental)
echo.

echo ========================================
echo Building with specific C++ standard:
echo ========================================
echo.

echo Using build script with C++ standard:
echo    build.bat Debug 17     - Build Debug with C++17
echo    build.bat Release 20   - Build Release with C++20
echo.

echo Manual CMake with C++ standard:
echo    cmake -DCMAKE_CXX_STANDARD=14 ..
echo    cmake -DCMAKE_CXX_STANDARD=17 ..
echo    cmake -DCMAKE_CXX_STANDARD=20 ..
echo.

pause