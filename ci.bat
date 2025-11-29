@echo off
setlocal enabledelayedexpansion

echo Початок CI: конфігурація та білд проекту...

REM Створюємо каталог build, якщо його немає
if not exist build (
    mkdir build
    echo Каталог 'build' створено.
) else (
    echo Каталог 'build' вже існує.
)

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
ctest
if %errorlevel% neq 0 (
    echo Тести не пройдено!
    echo FAILED
    exit /b 1
)
echo Тести пройдено успішно.

echo CI завершено успішно!
echo SUCCESS