@echo off
setlocal EnableExtensions
set LOGFILE=setup.log

echo === Setup: Add Logo project ===
echo (log write in %LOGFILE%)
echo.

rem ---- Утилиты для логов/пауз ----
set PAUSE_ON_FAIL=1

rem Функция печати и логирования
echo. > "%LOGFILE%"

call :log "Step 1/7: Check Python"
python -c "import sys;print(sys.version)" 1>>"%LOGFILE%" 2>&1
if errorlevel 1 (
  call :fail "Python not found. Install Python 3.8+ and add to PATH: https://www.python.org/downloads/windows/"
  goto END
) else (
  for /f "delims=" %%V in ('python -c "import sys;print(sys.version.split()[0])"') do set PYVER=%%V
  call :ok "Python found: %PYVER%"
)

call :log "Step 2/7: Create virtual environment (.venv)"
if exist ".venv\Scripts\activate.bat" (
  call :ok "Virtual environment already exists"
) else (
  python -m venv ".venv" 1>>"%LOGFILE%" 2>&1
  if errorlevel 1 (
    rem пробуем через py-лаунчер
    py -3 -m venv ".venv" 1>>"%LOGFILE%" 2>&1
  )
  if not exist ".venv\Scripts\activate.bat" (
    call :fail "Failed to create virtual environment. See %LOGFILE% for details."
    goto END
  ) else (
    call :ok "Virtual environment created"
  )
)

call :log "Step 3/7: Activate virtual environment"
call ".venv\Scripts\activate.bat"
if errorlevel 1 (
  call :fail "Failed to activate virtual environment"
  goto END
) else (
  call :ok "Virtual environment activated"
)

call :log "Step 4/7: Upgrade pip"
python -m pip install --upgrade pip 1>>"%LOGFILE%" 2>&1
if errorlevel 1 (
  call :fail "Failed to upgrade pip. See %LOGFILE%."
  goto END
) else (
  for /f "delims=" %%V in ('python -m pip --version') do set PIPVER=%%V
  call :ok "%PIPVER%"
)

call :log "Step 5/7: Install Pillow (PIL)"
python -m pip install pillow 1>>"%LOGFILE%" 2>&1
if errorlevel 1 (
  call :fail "Failed to install Pillow. See %LOGFILE%."
  goto END
) else (
  for /f "tokens=2" %%V in ('python -m pip show pillow ^| findstr /I "Version"') do set PILVER=%%V
  call :ok "Pillow %PILVER%"
)

call :log "Step 6/7: Check tkinter"
python -c "import tkinter" 1>>"%LOGFILE%" 2>&1
if errorlevel 1 (
  call :warn "tkinter not available. GUI may not run."
  echo   Windows: reinstall Python with Tcl/Tk >>"%LOGFILE%"
  echo   Linux:   sudo apt install python3-tk   >>"%LOGFILE%"
) else (
  call :ok "tkinter available"
)

call :log "Step 7/7: Final check (import modules)"
python -c "import argparse, pathlib; import PIL, tkinter" 1>>"%LOGFILE%" 2>&1
if errorlevel 1 (
  call :fail "Final import check failed. See %LOGFILE%."
  goto END
) else (
  call :ok "All required modules import successfully"
)

echo.
echo Setup completed successfully. You can run: run.bat
if defined PAUSE_ON_FAIL pause
exit /b 0

:ok
echo [SUCCESS] %~1
goto :eof

:fail
echo [FAIL]    %~1
echo.
type "%LOGFILE%"
if defined PAUSE_ON_FAIL pause
exit /b 1

:warn
echo [WARN]    %~1
goto :eof

:log
echo -- %~1
echo -- %~1>>"%LOGFILE%"
goto :eof

:END
if defined PAUSE_ON_FAIL pause

exit /b
