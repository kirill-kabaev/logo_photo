@echo off
setlocal enabledelayedexpansion

:: Поддержка ANSI Escape
for /F "delims=" %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

echo === Setting up Python virtual environment ===

:: Проверка Python
python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Python not found. Install Python 3.8+ and add to PATH.%RESET%
    pause
    exit /b 1
) else (
    for /f "tokens=2 delims= " %%v in ('python --version') do set pyver=%%v
    echo %GREEN%✅ Python found: %pyver%%RESET%
)

:: Создание виртуального окружения
if not exist .venv (
    python -m venv .venv
    if errorlevel 1 (
        echo %RED%❌ Failed to create virtual environment%RESET%
        pause
        exit /b 1
    ) else (
        echo %GREEN%✅ Virtual environment created%RESET%
    )
) else (
    echo %GREEN%✅ Virtual environment already exists%RESET%
)

:: Активация окружения
call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo %RED%❌ Failed to activate virtual environment%RESET%
    pause
    exit /b 1
) else (
    echo %GREEN%✅ Virtual environment activated%RESET%
)

:: Установка зависимостей
pip install --upgrade pip >nul
pip install pillow >nul
if errorlevel 1 (
    echo %RED%❌ Failed to install Pillow%RESET%
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%v in ('pip show pillow ^| findstr Version') do set pillowver=%%v
    echo %GREEN%✅ Pillow installed: %pillowver%%RESET%
)

:: Проверка tkinter
python - <<END
try:
    import tkinter
    print("OK")
except ImportError:
    exit(1)
END

if errorlevel 1 (
    echo %RED%❌ tkinter not available (install via python installer)%RESET%
) else (
    echo %GREEN%✅ tkinter available%RESET%
)

echo.
echo === Setup complete! ===
echo Use run_windows.bat to start the program.
pause