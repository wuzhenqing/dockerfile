# LLVM Development Images

Container images that provide a ready-to-use LLVM 19.1.7 development environment on Ubuntu 22.04/24.04 and openEuler 22.03/24.03.

Each image builds **LLVM**, **Clang**, **MLIR**, and the **MLIR Python bindings** from source, and ships with CMake, Ninja, Git, and a system C/C++ toolchain. A versioned CPython 3.11.15 is also built from source so projects that need a consistent Python ABI can rely on a predictable interpreter without replacing the distribution Python.

## What's included

| Component | Location / notes |
|-----------|------------------|
| LLVM / Clang / MLIR | `/opt/LLVM-19.1.7` (`LLVM_INSTALL_PREFIX`) |
| CPython 3.11.15 | `/usr/local/python3.11.15` (shared library + RPATH, `altinstall`) |
| Build tools | CMake, Ninja, Git, pkg-config |
| Host toolchain | Distribution Clang, LLD, and C/C++ libraries (used to compile LLVM) |

### LLVM build options

The source build is configured as a Release install with:

- Projects: `mlir`, `clang`
- Target: `Native`
- Compilers / linker: system `clang` / `clang++` with LLD
- Features: RTTI, assertions, utils, MLIR Python bindings

Versions and download URLs are pinned in the Dockerfiles. Python is fetched from HuaweiCloud; LLVM sources are fetched from a Huawei OBS mirror.

## Dockerfiles

| File | Base image |
|------|------------|
| [`Dockerfile.ubuntu22.04`](Dockerfile.ubuntu22.04) | `ubuntu:22.04` |
| [`Dockerfile.openeuler22.03`](Dockerfile.openeuler22.03) | `openeuler/openeuler:22.03` |
| [`Dockerfile.ubuntu24.04`](Dockerfile.ubuntu24.04) | `ubuntu:24.04` |
| [`Dockerfile.openeuler24.03`](Dockerfile.openeuler24.03) | `openeuler/openeuler:24.03` |

All four files follow the same layout: a single stage with three `RUN` steps (install dependencies → build Python → build LLVM). Temporary source archives and build trees are removed after each compile step.

## Build

From the repository root, use the `llvm/` directory as the build context:

```bash
docker build -f llvm/Dockerfile.ubuntu22.04 -t llvm:19.1.7-ubuntu22.04 llvm
docker build -f llvm/Dockerfile.openeuler22.03 -t llvm:19.1.7-openeuler22.03 llvm
docker build -f llvm/Dockerfile.ubuntu24.04 -t llvm:19.1.7-ubuntu24.04 llvm
docker build -f llvm/Dockerfile.openeuler24.03 -t llvm:19.1.7-openeuler24.03 llvm
```

Building LLVM is CPU- and memory-intensive. Prefer a native builder for the target architecture; compiling under emulation is significantly slower.

## Usage

```bash
docker run --rm -it llvm:19.1.7-ubuntu22.04
```

The image starts an interactive shell (`/bin/bash`) with the custom Python on `PATH`.

### Environment variables

| Variable | Value |
|----------|-------|
| `PATH` | Prepends `/usr/local/python3.11.15/bin` and `/opt/LLVM-19.1.7/bin` on Ubuntu; prepends only `/usr/local/python3.11.15/bin` on openEuler |
| `LLVM_INSTALL_PREFIX` | `/opt/LLVM-19.1.7` |
| `PYTHONPATH` | `/opt/LLVM-19.1.7/python_packages/mlir_core` |

LLVM tools and CMake config packages live under `$LLVM_INSTALL_PREFIX`. On openEuler they are **not** added to `PATH` by default, so add them explicitly when needed. For typical downstream use:

```bash
export PATH="$LLVM_INSTALL_PREFIX/bin:$PATH"
export CMAKE_PREFIX_PATH="$LLVM_INSTALL_PREFIX${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
export PYTHONPATH="$LLVM_INSTALL_PREFIX/python_packages/mlir_core${PYTHONPATH:+:$PYTHONPATH}"
```

You can then use `llvm-config`, `clang`, `mlir-opt`, and `find_package(LLVM CONFIG)` / `find_package(MLIR CONFIG)` as usual.

### Quick checks

After building or pulling an image, verify LLVM, MLIR, and the Python bindings
with the following commands:

```bash
docker run --rm llvm:19.1.7-ubuntu22.04 \
  bash -lc 'export PATH="$LLVM_INSTALL_PREFIX/bin:$PATH"; llvm-config --version'

docker run --rm llvm:19.1.7-ubuntu22.04 \
  bash -lc 'python --version'

docker run --rm llvm:19.1.7-ubuntu22.04 \
  bash -lc 'export PYTHONPATH="$LLVM_INSTALL_PREFIX/python_packages/mlir_core"; python -c "from mlir import ir; print(ir.Context())"'
```

### Toolchain notes

- The Ubuntu Dockerfiles prepend `/opt/LLVM-19.1.7/bin` to `PATH`; the openEuler
  Dockerfiles do not, so openEuler users must add `$LLVM_INSTALL_PREFIX/bin`
  manually when they need `llvm-config`, `clang`, or `mlir-opt` on `PATH`.
- Every build uses the distribution `clang` / `clang++` and `lld` explicitly, so
  the newer GCC in Ubuntu 24.04 does not silently become the LLVM bootstrap
  compiler.
- Ubuntu 22.04 and 24.04 both use the unversioned `libncurses-dev` package.
- openEuler 24.03 uses the `openeuler/openeuler:24.03` image tag and adds
  `libxcrypt-devel`. openEuler 22.03 and 24.03 both use the native
  `xz-devel` / `ncurses-devel` package names.
- All Dockerfiles set the global PyPI index to the HuaweiCloud mirror with
  `python -m pip config set global.index-url` before installing MLIR Python
  binding dependencies, so builds do not stall when the default PyPI route is
  slow or unavailable in China.

## Design notes

- **Pinned, not parameterized.** Base images and component versions are written literally in each Dockerfile. There are no build `ARG`s for bumping releases.
- **Single-stage builds.** Dependencies, Python, and LLVM remain in one image layer sequence so the result is a self-contained development base rather than a minimal runtime.
- **Parallel compiles.** Python `make` and LLVM `ninja` both use `-j"$(nproc)"`.

## References

- [LLVM 19.1.7 release](https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.7)
- [Getting Started with the LLVM System](https://llvm.org/docs/GettingStarted.html)
- [CANN Ubuntu 22.04 Python build](https://github.com/Ascend/cann-container-image/blob/main/cann/8.3.rc1.alpha001-910b-ubuntu22.04-py3.11/Dockerfile)
- [CANN openEuler 22.03 Python build](https://github.com/Ascend/cann-container-image/blob/main/cann/8.3.rc1.alpha001-310p-openeuler22.03-py3.11/Dockerfile)
