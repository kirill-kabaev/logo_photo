@echo off
echo === Running Add Logo program ===

REM Активируем виртуальное окружение
call .venv\Scripts\activate.bat

REM Запускаем программу в GUI
python add_logo.py --gui

pause