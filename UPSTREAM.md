# Upstream Submission Guide for blackwell-nvblox

To ensure long-term maintenance of these fixes, we should aim to merge them into the official NVIDIA repositories. This guide outlines the recommended strategy for each patch.

## Upstream Target: `nvidia-isaac/nvblox`

### 1. Patch: `0004-gcc13-missing-array-includes.patch` (High Priority)
*   **Description:** GCC 13 no longer transitively includes `<array>`. This patch adds explicit `#include <array>` where needed.
*   **Submission Strategy:** This is a standard fix for modern compiler compatibility. Create a PR titled "Fix: Add missing <array> includes for GCC 13 compatibility".
*   **Justification:** Essential for compilation on Ubuntu 24.04.

### 2. Patch: `0001-fix-thrust-2.7-regex.patch` (Medium Priority)
*   **Description:** Fixes a regex in `Findthrust.cmake` that fails to parse Thrust 2.7.0 version strings.
*   **Submission Strategy:** This likely affects `stdgpu` or the internal Thrust search logic. Create a PR titled "Fix: Correct Thrust version parsing in Findthrust.cmake".
*   **Justification:** Prevents build failures when using CUDA 12.8.

### 3. Patch: `0003-stdgpu-adl-ambiguity.patch` (Medium Priority)
*   **Description:** Fixes ADL ambiguities between `std::` and `cuda::std::`.
*   **Submission Strategy:** Submit to `nvblox` (if it contains `stdgpu` source) or the relevant dependency. PR title: "Fix: Resolve ADL ambiguities in stdgpu memory headers".
*   **Justification:** Required for modern CUDA standard library compatibility.

### 4. Patch: `0002-disable-nvtx-clash.patch` (Medium Priority)
*   **Description:** Defines `CCCL_DISABLE_NVTX` to prevent symbol clashes between NVTX v1 and v3.
*   **Submission Strategy:** Create a PR titled "Fix: Resolve NVTX symbol conflicts by disabling CCCL NVTX".
*   **Justification:** Prevents duplicate symbol errors in modern CUDA environments.

### 5. Blackwell Architecture Enablement
*   **Description:** Update `CMakeLists.txt` to include `120` in `CMAKE_CUDA_ARCHITECTURES`.
*   **Submission Strategy:** PR title: "Feat: Add support for Blackwell architecture (sm_120)".
*   **Justification:** Enables official support for NVIDIA's latest GPU architecture.

---

## Upstream Target: `NVlabs/nvblox_torch`

### 1. Patch: `0005-nvblox-torch-cmake-linking.patch` (High Priority)
*   **Description:** Fixes CMake target namespacing and `glog` directory location.
*   **Submission Strategy:** Create a PR titled "Fix: Correct nvblox target namespacing and glog linking".
*   **Justification:** Fixes build failure when installing Python bindings against a modern `nvblox` installation.

## Submission Checklist
1.  [ ] Create a fork of the upstream repository.
2.  [ ] Apply the specific patch to a new branch.
3.  [ ] Ensure the code follows the upstream style guide.
4.  [ ] Verify the build on a clean environment.
5.  [ ] Submit the PR with a clear description and reference to this repository.
