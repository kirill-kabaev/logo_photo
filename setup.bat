@echo off
setlocal

echo === Setting up Python virtual environment ===

rem 1) Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Install Python 3.8+ and add to PATH:
    echo         https://www.python.org/downloads/windows/
    pause
    exit /b 1
)

for /f "delims=" %%V in ('python -c "import sys;print(sys.version.split()[0])"') do set PYVER=%%V
echo [OK] Python found: %PYVER%

rem 2) Create venv
if not exist .venv (
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment (.venv)
        pause
        exit /b 1
    ) else (
        echo [OK] Virtual environment created (.venv)
    )
) else (
    echo [OK] Virtual environment already exists (.venv)
)

rem 3) Activate venv
call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
) else (
    echo [OK] Virtual environment activated
)

rem 4) Upgrade pip
python -m pip install --upgrade pip >nul
if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip
    pause
    exit /b 1
) else (
    for /f "delims=" %%V in ('python -m pip --version') do set PIPVER=%%V
    echo [OK] %PIPVER%
)

rem 5) Install Pillow (PIL)
python -m pip install pillow >nul
if errorlevel 1 (
    echo [ERROR] Failed to install Pillow
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%V in ('python -m pip show pillow ^| findstr /I "Version"') do set PILVER=%%V
    echo [OK] Pillow installed: %PILVER%
)

rem 6) Check tkinter
python -c "import tkinter" >nul 2>&1
if errorlevel 1 (
    echo [WARN] tkinter not available. GUI may not run.
    echo [HINT] On Windows: reinstall Python with "tcl/tk" option
    echo [HINT] On Linux: sudo apt install python3-tk
) else (
    echo [OK] tkinter available
)

echo.
echo === Setup complete ===
echo Run: run.bat
pause