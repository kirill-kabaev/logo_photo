@echo off
setlocal
echo === Running Add Logo program ===

REM Если есть виртуальное окружение — активируем
if exist ".venv\Scripts\activate.bat" (
    call ".venv\Scripts\activate.bat"
)

REM Запуск GUI
python add_logo.py --gui

echo.
echo (If you see "No module named 'PIL'", install Pillow manually:  pip install pillow)
pause