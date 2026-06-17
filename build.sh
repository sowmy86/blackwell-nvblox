#!/bin/bash

# blackwell-nvblox Build Automation Script
# Purpose: Automates cloning, patching, and building nvblox and nvblox_torch for Blackwell (sm_120).

set -e # Exit on error

# --- Configuration ---
INSTALL_PREFIX=${1:-$HOME/nvblox_install}
CUDAARCHS=${2:-120}
BASE_DIR=$(pwd)
PATCH_DIR=$BASE_DIR/patches

echo "--------------------------------------------------"
echo "Starting blackwell-nvblox Automated Build"
echo "Install Prefix: $INSTALL_PREFIX"
echo "Target Architecture: sm_$CUDAARCHS"
echo "--------------------------------------------------"

# --- Environment Setup ---
export CMAKE_PREFIX_PATH=$INSTALL_PREFIX:$CMAKE_PREFIX_PATH
export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib:$LD_LIBRARY_PATH

mkdir -p "$INSTALL_PREFIX"

# --- Build nvblox ---
echo "Building nvblox..."
if [ ! -d "nvblox" ]; then
    git clone https://github.com/nvidia-isaac/nvblox.git
fi
cd nvblox
git checkout main # Or a specific tag if preferred

echo "Applying patches to nvblox..."
git apply "$PATCH_DIR/0001-fix-thrust-2.7-regex.patch"
git apply "$PATCH_DIR/0002-disable-nvtx-clash.patch"
git apply "$PATCH_DIR/0003-stdgpu-adl-ambiguity.patch"
git apply "$PATCH_DIR/0004-gcc13-missing-array-includes.patch"

mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES="$CUDAARCHS" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DNVBLOX_BUILD_EXAMPLES=OFF \
    -DNVBLOX_BUILD_TESTS=OFF
make -j$(nproc) install
cd "$BASE_DIR"

# --- Build nvblox_torch ---
echo "Building nvblox_torch..."
if [ ! -d "nvblox_torch" ]; then
    git clone https://github.com/NVlabs/nvblox_torch.git
fi
cd nvblox_torch
git checkout main

echo "Applying patches to nvblox_torch..."
git apply "$PATCH_DIR/0005-nvblox-torch-cmake-linking.patch"

# Install using pip (assumes python environment is active)
pip install .

echo "--------------------------------------------------"
echo "Build and Installation Complete!"
echo "Please add the following to your .bashrc or run them in your terminal:"
echo "export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH"
echo "--------------------------------------------------"
