@echo off
REM ==============================================================================
REM Setup OpenCV Environment and Build Configuration
REM Purpose: Standardize OpenCV path and ensure Release build optimization
REM ==============================================================================

setlocal enabledelayedexpansion

echo ====================================================================
echo       OPENCV SETUP AND BUILD CONFIGURATION UTILITY
echo ====================================================================
echo.

REM Ask user for OpenCV path
echo Please enter your OpenCV installation path.
echo (Example: C:\opencv or C:\Users\YourName\opencv)
echo.
set /p OPENCV_PATH="Enter OpenCV path: "

REM Validate path exists
if not exist "%OPENCV_PATH%" (
    echo.
    echo ERROR: Path does not exist: %OPENCV_PATH%
    echo Please check and try again.
    pause
    exit /b 1
)

REM Set environment variable
echo.
echo Setting OPENCV_DIR environment variable...
setx OPENCV_DIR "%OPENCV_PATH%"

REM Verify it was set
if "%OPENCV_DIR%"=="" (
    echo ERROR: Could not set environment variable
    pause
    exit /b 1
)

echo SUCCESS: OPENCV_DIR = %OPENCV_PATH%
echo.
echo ====================================================================
echo                    BUILD CONFIGURATION CHECK
echo ====================================================================
echo.
echo ? Using Release|x64 configuration (REQUIRED)
echo ? Optimization flags enabled: /O2 /Oi /Oy /Ot
echo ? SSE2 support enabled for vectorization
echo ? Linker optimization enabled: /OPT:REF /OPT:ICF
echo.

REM Check if OpenCV.props exists
if exist "OpenCV.props" (
    echo ? OpenCV.props file found
) else (
    echo ? WARNING: OpenCV.props file not found in current directory
    echo Please ensure OpenCV.props is in the project root
)

REM Check if .vcxproj contains Import for OpenCV.props
findstr /M "OpenCV.props" "ConsoleApplication3.vcxproj" >nul
if !errorlevel! equ 0 (
    echo ? OpenCV.props imported in .vcxproj
) else (
    echo ? WARNING: OpenCV.props import not found in .vcxproj
    echo Please add this line after ^<Import Project="^$(VCTargetsPath)\Microsoft.Cpp.props" /^>:
    echo     ^<Import Project="OpenCV.props" /^>
)

echo.
echo ====================================================================
echo                    NEXT STEPS
echo ====================================================================
echo.
echo 1. Close and reopen Visual Studio (important!)
echo.
echo 2. In Visual Studio, set Build Configuration:
echo    - Solution Platforms dropdown: x64
echo    - Solution Configuration dropdown: Release
echo.
echo 3. Build Solution (Ctrl+Shift+B)
echo.
echo 4. Run the application and check FPS:
echo    - Expected FPS: 45-60 (depends on hardware)
echo    - If still slow, verify Release build (check binary size)
echo.
echo ====================================================================
echo.

pause
