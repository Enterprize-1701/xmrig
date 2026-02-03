#!/usr/bin/env bash
set -euo pipefail

# Проверка, что мы в корне проекта
if [[ ! -f "CMakeLists.txt" ]]; then
  echo "Ошибка: CMakeLists.txt не найден. Запустите скрипт из корня проекта."
  exit 1
fi

# Создаём/очищаем build каталог
rm -rf build
mkdir build
cd build

# Конфигурация и сборка
cmake ..
make -j"$(nproc)"

echo "Готово. Бинарник: ./xmrig (в каталоге build)"
