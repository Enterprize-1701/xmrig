#!/usr/bin/env bash
set -euo pipefail

# Make sure we are in the project root (CMakeLists.txt must exist)
if [[ ! -f "CMakeLists.txt" ]]; then
  echo "Error: CMakeLists.txt not found. Run this script from the project root."
  exit 1
fi

# Recreate clean build directory
rm -rf build
mkdir build
cd build

# Configure and build
cmake ..
make -j"$(nproc)"

echo "Done. Binary located in: ./build/xmrig"
