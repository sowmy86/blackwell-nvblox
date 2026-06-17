# Blackwell-nvblox: sm_120 Support for CUDA 12.8

This repository provides the build procedures, patches, and integration logic required to build and run **NVIDIA nvblox** and **nvblox_torch** from source on the latest **NVIDIA Blackwell architecture (RTX 50-series / sm_120)** using **CUDA 12.8** and **GCC 13**.

As pre-built binaries for this specific architecture and CUDA combination are currently unavailable, this repository bridges the gap for robotics researchers and engineers who require high-performance, real-time GPU-accelerated mapping and collision checking.

## 🚀 Key Features

*   **First-of-kind Blackwell Build:** Enables successful compilation of `nvblox` and `nvblox_torch` targeting the `sm_120` architecture.
*   **CUDA 12.8 & GCC 13 Compatibility:** Resolves conflicts between modern compilers, Thrust 2.7.0, and legacy NVTX headers.
*   **Automated Tooling:** Includes a one-click build script and a Docker environment for reproducible builds.
*   **cuRobo Integration Ready:** Fully supports cuRobo's `WorldBloxCollision` (BLOX mode) for dynamic, real-time robotic collision avoidance.

---

## 🛠 Included Patches

The `patches/` directory contains fixes for the following build issues encountered on this stack:

1.  **`0001-fix-thrust-2.7-regex.patch`**: Fixes the `Findthrust.cmake` (via stdgpu) regular expression to correctly parse Thrust 2.7.0's version strings.
2.  **`0002-disable-nvtx-clash.patch`**: Adds `CCCL_DISABLE_NVTX` to resolve linking conflicts between legacy `nvToolsExt.h` and modern `nvtx3`.
3.  **`0003-stdgpu-adl-ambiguity.patch`**: Qualifies `stdgpu` memory headers to fix ADL ambiguities with `cuda::std::`.
4.  **`0004-gcc13-missing-array-includes.patch`**: Adds `#include <array>` to several nvblox headers required due to GCC 13 dropping transitive includes.
5.  **`0005-nvblox-torch-cmake-linking.patch`**: Corrects `nvblox_torch` CMake logic to properly link namespaced `nvblox` targets.

---

## 📦 Installation & Build Guide

### 1. Automated Build (Recommended)
We provide a script to handle cloning, patching, and building automatically.

```bash
# Set your target installation directory
export INSTALL_PREFIX=$HOME/nvblox_install
chmod +x build.sh
./build.sh $INSTALL_PREFIX
```

### 2. Docker Build
For a fully isolated and reproducible environment:

```bash
docker build -t blackwell-nvblox .
```

### 3. Manual Build
If you prefer to build manually, follow the steps below:

#### Build Environment Setup
```bash
export INSTALL_PREFIX=/path/to/your/local/pkgs
export CUDAARCHS=120
export CMAKE_PREFIX_PATH=${INSTALL_PREFIX}
export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig
export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:$LD_LIBRARY_PATH
```

#### Building nvblox
```bash
git clone https://github.com/nvidia-isaac/nvblox.git
cd nvblox
# Apply patches from this repo
git apply ../patches/0001-*.patch
git apply ../patches/0002-*.patch
git apply ../patches/0003-*.patch
git apply ../patches/0004-*.patch

mkdir build && cd build
cmake .. -DCMAKE_CUDA_ARCHITECTURES=120 -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
make -j$(nproc) install
```

#### Building nvblox_torch
```bash
git clone https://github.com/NVlabs/nvblox_torch.git
cd nvblox_torch
git apply ../patches/0005-*.patch
pip install .
```

---

## 🤖 cuRobo Integration Usage

Once built, you can utilize the `CollisionCheckerType.BLOX` in cuRobo for dynamic collision checking.

**Important Runtime Requirement:**
`export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:$LD_LIBRARY_PATH`

```python
from curobo.geom.types import WorldConfig, BloxMap
from curobo.geom.sdf.world import WorldCollisionConfig, CollisionCheckerType
from curobo.geom.sdf.utils import create_collision_checker

# Initialize a live nvblox layer
blox_world = WorldConfig(
    blox=[BloxMap(name="dynamic_layer", voxel_size=0.01, integrator_type="occupancy")]
)

# Create the Blackwell-accelerated checker
checker = create_collision_checker(WorldCollisionConfig(
    world_model=blox_world,
    checker_type=CollisionCheckerType.BLOX
))
```

---

## 👥 Authors

*   **Main Author:** **sowmy86** | [sowmysuresh86@gmail.com](mailto:sowmysuresh86@gmail.com)
*   **Co-Author:** **yesMohanHere** | [mohanasriram.e@gmail.com](mailto:mohanasriram.e@gmail.com)

---

## 📜 License

This repository provides build instructions and patches. The core libraries (`nvblox`, `nvblox_torch`, `stdgpu`) remain under their respective original licenses.
