@echo off
setlocal enabledelayedexpansion
echo Початок CI: конфігурація та білд проекту...
REM Видаляємо старий каталог build
if exist build (
    rmdir /s /q build
    echo Старий каталог 'build' видалено.
)
REM Створюємо новий каталог build
mkdir build
echo Каталог 'build' створено.
REM Переходимо в каталог build
cd build
REM Конфігурація проекту
echo Конфігурація з cmake ..
cmake ..
if %errorlevel% neq 0 (
    echo Конфігурація невдала!
    echo FAILED
    exit /b 1
)
echo Конфігурація успішна.
REM Збірка проекту
echo Збірка з cmake --build .
cmake --build .
if %errorlevel% neq 0 (
    echo Білд невдалий!
    echo FAILED
    exit /b 1
)
echo Білд успішний.
REM Запуск тестів
echo Запуск тестів з ctest.
ctest -C Debug
if %errorlevel% neq 0 (
    echo Тести не пройдено!
    echo FAILED
    exit /b 1
)
echo Тести пройдено успішно.
echo CI завершено успішно!
echo SUCCESS