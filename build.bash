#!/usr/bin/env bash
set -euo pipefail

# Install build dependencies (Debian/Ubuntu)
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y \
    build-essential \
    cmake \
    libhwloc-dev \
    libuv1-dev \
    libssl-dev
else
  echo "Unsupported package manager. Install deps manually: cmake, build tools, libhwloc-dev, libuv-dev, libssl-dev."
  exit 1
fi

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
