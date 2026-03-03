# PowerShell Script: Setup OpenCV and Verify Build Configuration
# Purpose: Complete automation for project setup and diagnostics
# Usage: .\setup_build_environment.ps1

param(
    [string]$OpenCVPath = "",
    [switch]$Diagnostic = $false,
    [switch]$Force = $false
)

# Colors for output
$colors = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
}

function Write-Status {
    param($Message, $Type = "Info")
    $color = $colors[$Type]
    Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] " -NoNewline
    Write-Host $Message -ForegroundColor $color
}

# ==================== SETUP PHASE ====================

if ($Diagnostic -eq $false) {
    Write-Host ""
    Write-Host "??????????????????????????????????????????????????????????????"
    Write-Host "?       OPENCV BUILD ENVIRONMENT SETUP & CONFIGURATION       ?"
    Write-Host "??????????????????????????????????????????????????????????????"
    Write-Host ""
    
    # Get OpenCV path if not provided
    if ([string]::IsNullOrEmpty($OpenCVPath)) {
        Write-Host "OpenCV Installation Path Selection:" -ForegroundColor Cyan
        Write-Host "=================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Common paths:"
        Write-Host "  • C:\opencv"
        Write-Host "  • C:\Users\<YourName>\opencv"
        Write-Host "  • C:\opencv-build"
        Write-Host ""
        $OpenCVPath = Read-Host "Enter your OpenCV installation path"
    }
    
    # Validate OpenCV path
    Write-Status "Validating OpenCV path: $OpenCVPath" Info
    
    if (-not (Test-Path $OpenCVPath)) {
        Write-Status "ERROR: Path does not exist: $OpenCVPath" Error
        Write-Host ""
        Write-Host "Please check the path and try again."
        exit 1
    }
    
    # Check for required OpenCV subdirectories
    $requiredDirs = @(
        "build\include",
        "build\x64\vc16\lib"
    )
    
    $allDirsExist = $true
    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $OpenCVPath $dir
        if (Test-Path $fullPath) {
            Write-Status "? Found: $dir" Success
        } else {
            Write-Status "? Missing: $dir" Error
            $allDirsExist = $false
        }
    }
    
    if (-not $allDirsExist) {
        Write-Host ""
        Write-Host "Some OpenCV directories are missing. Possible reasons:"
        Write-Host "  1. OpenCV not properly built/installed"
        Write-Host "  2. Wrong path specified"
        Write-Host "  3. Using different OpenCV structure"
        Write-Host ""
        Write-Host "Please verify your OpenCV installation and try again."
        exit 1
    }
    
    # Set environment variable
    Write-Host ""
    Write-Status "Setting OPENCV_DIR environment variable..." Info
    
    [Environment]::SetEnvironmentVariable("OPENCV_DIR", $OpenCVPath, "User")
    
    # Verify it was set
    if ($env:OPENCV_DIR -eq $OpenCVPath) {
        Write-Status "? Environment variable set successfully" Success
        Write-Status "  OPENCV_DIR = $OpenCVPath" Success
    } else {
        # Reload environment for current session
        $env:OPENCV_DIR = $OpenCVPath
        Write-Status "? Environment variable set (requires full restart for persistence)" Warning
    }
    
    # Check for required files
    Write-Host ""
    Write-Status "Checking project files..." Info
    
    $missingFiles = @()
    
    if (-not (Test-Path "OpenCV.props")) {
        Write-Status "? Missing: OpenCV.props" Error
        $missingFiles += "OpenCV.props"
    } else {
        Write-Status "? Found: OpenCV.props" Success
    }
    
    if (-not (Test-Path "ConsoleApplication3.vcxproj")) {
        Write-Status "? Missing: ConsoleApplication3.vcxproj" Error
        $missingFiles += "ConsoleApplication3.vcxproj"
    } else {
        Write-Status "? Found: ConsoleApplication3.vcxproj" Success
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "Missing required files. Please ensure you're in the project root directory."
        exit 1
    }
    
    # Check if OpenCV.props is imported
    Write-Host ""
    $vcxprojContent = Get-Content "ConsoleApplication3.vcxproj" -Raw
    if ($vcxprojContent -match "OpenCV\.props") {
        Write-Status "? OpenCV.props is imported in .vcxproj" Success
    } else {
        Write-Status "? OpenCV.props might not be imported" Warning
        Write-Host ""
        Write-Host "Add this line to ConsoleApplication3.vcxproj after:"
        Write-Host '  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />'
        Write-Host ""
        Write-Host "Add:"
        Write-Host '  <Import Project="OpenCV.props" />'
    }
    
    # Summary
    Write-Host ""
    Write-Host "??????????????????????????????????????????????????????????????"
    Write-Host "?                     SETUP COMPLETE                          ?"
    Write-Host "??????????????????????????????????????????????????????????????"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "  1. ? Close Visual Studio"
    Write-Host "  2. ? Restart your computer (to apply environment changes)"
    Write-Host "  3. ? Open Visual Studio again"
    Write-Host "  4. ? Set Configuration: Release"
    Write-Host "  5. ? Set Platform: x64"
    Write-Host "  6. ? Build ? Rebuild Solution"
    Write-Host "  7. ? Run and test FPS"
    Write-Host ""
    Write-Host "Run this for diagnostics:"
    Write-Host "  .\setup_build_environment.ps1 -Diagnostic"
    Write-Host ""
}

# ==================== DIAGNOSTIC PHASE ====================

if ($Diagnostic -or $Force) {
    Write-Host ""
    Write-Host "??????????????????????????????????????????????????????????????"
    Write-Host "?             BUILD ENVIRONMENT DIAGNOSTICS                  ?"
    Write-Host "??????????????????????????????????????????????????????????????"
    Write-Host ""
    
    # Check 1: OPENCV_DIR
    Write-Host "CHECK 1: Environment Variables" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    
    if ([string]::IsNullOrEmpty($env:OPENCV_DIR)) {
        Write-Status "? OPENCV_DIR is not set" Error
        Write-Host "  Solution: Run setup_build_environment.ps1 first"
    } else {
        Write-Status "? OPENCV_DIR = $env:OPENCV_DIR" Success
        
        if (Test-Path "$env:OPENCV_DIR\build\include") {
            Write-Status "  ? Include directory exists" Success
        } else {
            Write-Status "  ? Include directory not found" Error
        }
    }
    
    # Check 2: Build Output
    Write-Host ""
    Write-Host "CHECK 2: Build Output Size" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    
    $releaseExe = Get-ChildItem "x64\Release\*.exe" -ErrorAction SilentlyContinue
    if ($releaseExe) {
        $size = $releaseExe.Length / 1MB
        Write-Status "Release build: $([Math]::Round($size, 2)) MB" Info
        
        if ($size -gt 40) {
            Write-Status "? WARNING: Release binary too large!" Warning
            Write-Host "  This suggests Debug configuration or debug symbols."
            Write-Host "  Verify: Configuration = Release, Platform = x64"
        } elseif ($size -lt 5) {
            Write-Status "? WARNING: Release binary very small" Warning
            Write-Host "  This might indicate incomplete build."
        } else {
            Write-Status "? Release binary size is normal" Success
        }
    } else {
        Write-Status "? Release build not found" Warning
        Write-Host "  Build the project first: Build ? Rebuild Solution"
    }
    
    $debugExe = Get-ChildItem "x64\Debug\*.exe" -ErrorAction SilentlyContinue
    if ($debugExe) {
        $size = $debugExe.Length / 1MB
        Write-Status "Debug build: $([Math]::Round($size, 2)) MB" Info
        Write-Host "  (Debug builds are expected to be larger)"
    }
    
    # Check 3: Project Configuration
    Write-Host ""
    Write-Host "CHECK 3: Project Configuration" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    if (Test-Path "ConsoleApplication3.vcxproj") {
        $vcxprojContent = Get-Content "ConsoleApplication3.vcxproj" -Raw
        
        if ($vcxprojContent -match '<ConfigurationType>Application') {
            Write-Status "? Project type is Application" Success
        }
        
        if ($vcxprojContent -match 'Release') {
            Write-Status "? Release configuration found" Success
        } else {
            Write-Status "? Release configuration not found" Error
        }
    }
    
    # Check 4: OpenCV.props
    Write-Host ""
    Write-Host "CHECK 4: OpenCV.props File" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    
    if (Test-Path "OpenCV.props") {
        Write-Status "? OpenCV.props exists" Success
        
        $propsContent = Get-Content "OpenCV.props" -Raw
        
        $checks = @{
            "MaxSpeed optimization" = "MaxSpeed"
            "Intrinsic functions" = "EnableIntrinsicFunctions"
            "Frame pointer omission" = "OmitFramePointers"
            "Linker optimization" = "OptimizeReferences"
            "SSE2 support" = "StreamingSIMDExtensions"
        }
        
        foreach ($check in $checks.GetEnumerator()) {
            if ($propsContent -match $check.Value) {
                Write-Status "? $($check.Key)" Success
            } else {
                Write-Status "? $($check.Key) not found" Error
            }
        }
    } else {
        Write-Status "? OpenCV.props not found" Error
        Write-Host "  This file should be in the project root"
    }
    
    # Check 5: Performance Expectations
    Write-Host ""
    Write-Host "CHECK 5: Performance Summary" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Expected FPS (Release|x64 build):" -ForegroundColor Green
    Write-Host "  ? With optimization:  45-60 FPS"
    Write-Host "  ? Without optimiz.:   15-25 FPS"
    Write-Host ""
    Write-Host "If you're getting low FPS:" -ForegroundColor Yellow
    Write-Host "  1. Verify Release configuration (not Debug)"
    Write-Host "  2. Check binary size (<20 MB for Release)"
    Write-Host "  3. Rebuild solution (Clean + Rebuild)"
    Write-Host "  4. Close other programs"
    
    Write-Host ""
    Write-Host "????????????????????????????????????????????????????????????"
    Write-Host "Diagnostic complete. All checks above should show ?"
    Write-Host "????????????????????????????????????????????????????????????"
    Write-Host ""
}

Write-Host ""
pause
