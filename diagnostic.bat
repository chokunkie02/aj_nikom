@echo off
REM ==============================================================================
REM YOLO Performance Diagnostic Tool
REM Purpose: Check build configuration and diagnose performance issues
REM ==============================================================================

echo ====================================================================
echo           YOLO PERFORMANCE DIAGNOSTIC TOOL
echo ====================================================================
echo.

REM Check OPENCV_DIR environment variable
echo [CHECK 1] OpenCV Environment Variable
echo ==========================================
if defined OPENCV_DIR (
    echo ? OPENCV_DIR is set: %OPENCV_DIR%
    if exist "%OPENCV_DIR%\build\include" (
        echo ? OpenCV include directory found
    ) else (
        echo ? ERROR: include directory not found in OPENCV_DIR
    )
    if exist "%OPENCV_DIR%\build\x64\vc16\lib" (
        echo ? OpenCV x64 library directory found
    ) else (
        echo ? WARNING: x64 library directory not found
    )
) else (
    echo ? ERROR: OPENCV_DIR not set
    echo   Solution: Run setup_opencv.bat
)
echo.

REM Check build output directories and file sizes
echo [CHECK 2] Build Output Size
echo ==========================================

if exist "x64\Release" (
    for /f %%A in ('dir /b "x64\Release\*.exe" 2^>nul') do (
        for /f %%B in ('wmic datafile where name^="x64\Release\%%A" get filesize^') do (
            if "%%B" neq "filesize" (
                set /a SIZE_MB=%%B/1048576
                echo Release build size: !SIZE_MB! MB
                if !SIZE_MB! gtr 40 (
                    echo ? WARNING: Release binary too large (>40MB indicates Debug symbols)
                ) else (
                    echo ? Release binary size OK (^<20MB expected)
                )
            )
        )
    )
) else (
    echo ? Release build directory not found (need to build first)
)

if exist "x64\Debug" (
    for /f %%A in ('dir /b "x64\Debug\*.exe" 2^>nul') do (
        for /f %%B in ('wmic datafile where name^="x64\Debug\%%A" get filesize^') do (
            if "%%B" neq "filesize" (
                set /a SIZE_MB=%%B/1048576
                echo Debug build size: !SIZE_MB! MB
                echo ? Debug builds are expected to be larger
            )
        )
    )
)
echo.

REM Check Visual Studio project file
echo [CHECK 3] Project Configuration
echo ==========================================

findstr /C:"Release" "ConsoleApplication3.vcxproj" >nul
if !errorlevel! equ 0 (
    echo ? Release configuration found in .vcxproj
) else (
    echo ? ERROR: Release configuration not found
)

findstr /C:"Optimization" "ConsoleApplication3.vcxproj" >nul
if !errorlevel! equ 0 (
    echo ? Optimization settings found in .vcxproj
) else (
    echo ? WARNING: Optimization settings not explicit in .vcxproj
)

findstr /C:"OpenCV.props" "ConsoleApplication3.vcxproj" >nul
if !errorlevel! equ 0 (
    echo ? OpenCV.props imported in .vcxproj
) else (
    echo ? ERROR: OpenCV.props not imported
    echo   Add this line after ^<Import Project="^$(VCTargetsPath)\Microsoft.Cpp.props" /^>:
    echo     ^<Import Project="OpenCV.props" /^>
)
echo.

REM Check for common optimization flags in props
echo [CHECK 4] OpenCV.props Content
echo ==========================================

if exist "OpenCV.props" (
    echo ? OpenCV.props file exists
    
    findstr /C:"MaxSpeed" "OpenCV.props" >nul
    if !errorlevel! equ 0 (
        echo ? MaxSpeed optimization enabled (/O2)
    ) else (
        echo ? MaxSpeed optimization not found
    )
    
    findstr /C:"EnableIntrinsicFunctions" "OpenCV.props" >nul
    if !errorlevel! equ 0 (
        echo ? Intrinsic functions enabled (/Oi)
    ) else (
        echo ? Intrinsic functions not enabled
    )
    
    findstr /C:"OmitFramePointers" "OpenCV.props" >nul
    if !errorlevel! equ 0 (
        echo ? Frame pointer omission enabled (/Oy)
    ) else (
        echo ? Frame pointer omission not enabled
    )
    
    findstr /C:"OptimizeReferences" "OpenCV.props" >nul
    if !errorlevel! equ 0 (
        echo ? Linker optimization enabled (/OPT:REF)
    ) else (
        echo ? Linker optimization not enabled
    )
) else (
    echo ? ERROR: OpenCV.props file not found
    echo   Solution: Copy OpenCV.props from repository root
)
echo.

REM Performance expectations
echo [CHECK 5] Performance Expectations
echo ==========================================
echo.
echo Expected FPS (Release|x64 build):
echo   With optimization:  45-60 FPS ?
echo   Without optimiz.:   15-25 FPS ?
echo.
echo If your FPS is in the "Without optimization" range:
echo   1. Verify Release configuration (not Debug)
echo   2. Check OpenCV.props exists and is imported
echo   3. Rebuild solution (Clean + Rebuild)
echo.

echo ====================================================================
echo                    DIAGNOSTIC COMPLETE
echo ====================================================================
echo.
echo Summary:
echo - Check all [CHECK X] sections above for ? or ? marks
echo - If you see ? ERROR, follow the suggested solution
echo - If you see ? WARNING, it may affect performance
echo.
pause
