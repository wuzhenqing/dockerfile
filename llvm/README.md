# LLVM 19.1.7 development images

This directory provides Ubuntu 22.04 and openEuler 22.03 development images built from the official LLVM 19.1.7 source archive.

Both images install LLVM, Clang, MLIR, and the MLIR Python bindings under `/opt/llvm`. CMake, Ninja, Git, and the system C/C++ toolchain are included for downstream development.

CPython 3.11.13 is built from source into `/usr/local/python3.11.13` using the versioned prefix, shared-library RPATH, `altinstall`, and command links used by the paired Ubuntu 22.04 and openEuler 22.03 CANN images. This preserves CPython 3.11 ABI compatibility with CANN while keeping the distribution Python environment unchanged.

The available Dockerfiles are `Dockerfile.ubuntu22.04` and `Dockerfile.openeuler22.03`.

## Design

These images are long-lived development bases: build once, then reuse for many months without rebuilding. The two Dockerfiles are maintained side by side on purpose; each tracks one fixed OS baseline and is not expected to change often after review.

Versions and base images are written literally in the Dockerfiles. There are no build `ARG`s for version bumping, and the images do not add extra checksum steps for downloaded archives—integrity relies on the upstream release channels and the build host network environment.

Multi-stage builds keep download artifacts out of the final image. Python and LLVM source tarballs, unpacked trees, and build directories exist only in intermediate stages and are removed before the install prefixes are copied forward. The final image keeps `/opt/llvm`, the versioned CPython prefix, and the system packages needed for C/C++ and MLIR development.

Python `make` and LLVM `ninja` both use `-j"$(nproc)"` so the build saturates every CPU the builder reports.

## Build

Run the following commands from the repository root. The build context is the `llvm/` directory because the Dockerfiles do not `COPY` from the context.

```bash
docker build \
  -f llvm/Dockerfile.ubuntu22.04 \
  -t llvm:19.1.7-ubuntu22.04 \
  llvm

docker build \
  -f llvm/Dockerfile.openeuler22.03 \
  -t llvm:19.1.7-openeuler22.03 \
  llvm
```

The AArch64 LLVM backend is enabled for code generation. This does not set the container architecture. Native builders are recommended because compiling LLVM through emulation is slow.

## Verify

Each Dockerfile verifies LLVM, Clang, MLIR, CPython, and the Python bindings during the image build. The resulting image can also be checked manually:

```bash
docker run --rm llvm:19.1.7-ubuntu22.04 llvm-config --version
docker run --rm llvm:19.1.7-ubuntu22.04 clang --version
docker run --rm llvm:19.1.7-ubuntu22.04 mlir-opt --version
docker run --rm llvm:19.1.7-ubuntu22.04 python --version
docker run --rm llvm:19.1.7-ubuntu22.04 \
  python -c 'from mlir import ir; print(ir.Context())'
```

The images export `CC`, `CXX`, `PATH`, `LD_LIBRARY_PATH`, `CMAKE_PREFIX_PATH`, `LLVM_DIR`, `MLIR_DIR`, `Clang_DIR`, and `PYTHONPATH`. Downstream CMake projects can use `find_package(LLVM CONFIG)` and `find_package(MLIR CONFIG)` without additional paths.

## References

- [LLVM 19.1.7 release](https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.7)
- [LLVM build documentation](https://llvm.org/docs/GettingStarted.html)
- [CANN Ubuntu 22.04 Python build](https://github.com/Ascend/cann-container-image/blob/main/cann/8.3.rc1.alpha001-910b-ubuntu22.04-py3.11/Dockerfile)
- [CANN openEuler 22.03 Python build](https://github.com/Ascend/cann-container-image/blob/main/cann/8.3.rc1.alpha001-310p-openeuler22.03-py3.11/Dockerfile)
- [openEuler container images](https://www.openeuler.org/en/wiki/install/image/)
