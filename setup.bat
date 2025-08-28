@echo off
setlocal

echo === Setup: Add Logo project ===

rem Step 1/6: Check Python
python -c "import sys;print(sys.version)" >nul 2>&1
if errorlevel 1 (
  echo [FAIL]   Step 1/6: Python not found. Install Python 3.8+ and add to PATH:
  echo          https://www.python.org/downloads/windows/
  goto :end_fail
) else (
  for /f "delims=" %%V in ('python -c "import sys;print(sys.version.split()[0])"') do set PYVER=%%V
  echo [SUCCESS] Step 1/6: Python found: %PYVER%
)

rem Step 2/6: Create virtual environment
if exist ".venv\Scripts\activate.bat" (
  echo [SUCCESS] Step 2/6: Virtual environment already exists (.venv)
) else (
  python -m venv .venv >nul 2>&1
  if errorlevel 1 (
    echo [FAIL]   Step 2/6: Failed to create virtual environment (.venv)
    goto :end_fail
  ) else (
    echo [SUCCESS] Step 2/6: Virtual environment created (.venv)
  )
)

rem Step 3/6: Activate virtual environment
call ".venv\Scripts\activate.bat"
if errorlevel 1 (
  echo [FAIL]   Step 3/6: Failed to activate virtual environment
  goto :end_fail
) else (
  echo [SUCCESS] Step 3/6: Virtual environment activated
)

rem Step 4/6: Upgrade pip
python -m pip install --upgrade pip >nul 2>&1
if errorlevel 1 (
  echo [FAIL]   Step 4/6: Failed to upgrade pip
  goto :end_fail
) else (
  for /f "delims=" %%V in ('python -m pip --version') do set PIPVER=%%V
  echo [SUCCESS] Step 4/6: %PIPVER%
)

rem Step 5/6: Install Pillow (PIL)
python -m pip install pillow >nul 2>&1
if errorlevel 1 (
  echo [FAIL]   Step 5/6: Failed to install Pillow
  goto :end_fail
) else (
  for /f "tokens=2" %%V in ('python -m pip show pillow ^| findstr /I "Version"') do set PILVER=%%V
  echo [SUCCESS] Step 5/6: Pillow %PILVER%
)

rem Step 6/6: Check tkinter availability
python -c "import tkinter" >nul 2>&1
if errorlevel 1 (
  echo [FAIL]   Step 6/6: tkinter not available. GUI may not run.
  echo          Windows: reinstall Python with Tcl/Tk.  Linux: sudo apt install python3-tk
) else (
  echo [SUCCESS] Step 6/6: tkinter available
)

echo.
echo Setup completed. You can run: run.bat
exit /b 0

:end_fail
echo.
echo Setup failed. See messages above.
exit /b 1