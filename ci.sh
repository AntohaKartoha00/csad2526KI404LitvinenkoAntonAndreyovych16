#!/bin/bash
# CI скрипт для локального білду C++ проекту з CMake
set -e # Зупинятися при помилці
echo "Початок CI: конфігурація та білд проекту..."
# Видаляємо старий каталог build
if [ -d "build" ]; then
    echo "Видалення старого каталогу 'build'..."
    rm -rf build
fi
# Створюємо новий каталог build
mkdir build
echo "Каталог 'build' створено."
# Переходимо в каталог build
cd build
# Конфігурація проекту
echo "Конфігурація з cmake .."
if cmake ..; then
    echo "Конфігурація успішна."
else
    echo "Конфігурація невдала!"
    exit 1
fi
# Збірка проекту
echo "Збірка з cmake --build ."
if cmake --build .; then
    echo "Білд успішний."
else
    echo "Білд невдалий!"
    exit 1
fi
# Запуск тестів
echo "Запуск тестів з ctest."
if ctest; then
    echo "Тести пройдено успішно."
else
    echo "Тести не пройдено!"
    exit 1
fi
echo "CI завершено успішно!"