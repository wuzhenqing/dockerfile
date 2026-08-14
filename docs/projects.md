# Project notes

Background and configuration notes for each image family in this repository. For build commands and layout overview, start with the [home page](index.md). Naming rules live in [naming-conventions.md](naming-conventions.md).

## asnumpy

Development image for NumPy-style Ascend NPU workflows. The Dockerfile starts from `ascendai/cann:9.0.0-beta.2-910b-ubuntu22.04-py3.11`, creates a ModelArts-compatible `ma-user` account, and installs a full host toolchain (Clang/LLVM, CMake, Ninja, GDB, ripgrep, tmux, and related utilities).

Inside the image, Miniforge/Mamba provides two conda environments (`py311` and `py312`). Each environment ships NumPy, pytest, PyTorch 2.9.0, and matching `torch-npu` / torchvision / torchaudio wheels so algorithm work can move between NumPy-style code and PyTorch without rebuilding the container.

```bash
docker build -f asnumpy/Dockerfile -t asnumpy:dev .
```

Prefer this image when you want a relatively light Ascend development shell for prototyping and tests, rather than a from-source LLVM or framework training stack.

## cann

CANN (Compute Architecture for Neural Networks) is Huawei Ascend’s runtime and toolkit layer. The `cann/` directory holds versioned Dockerfiles that layer developer tooling on top of published CANN base images, covering both local `root` images and ModelArts `ma-user` variants. Rolling builds from the CANN `master` channel are documented separately in [cann/master/README.md](https://github.com/wuzhenqing/dockerfile/blob/main/cann/master/README.md).

Representative files:

| Dockerfile | Role |
|------------|------|
| `8.3.RC1-base.Dockerfile` | Local development base with a prebuilt LLVM 19.1.7 toolchain under `/opt/llvm`, monitoring/debug utilities, SSH, and `entrypoint.sh` |
| `8.3.RC1.alpha003-modelarts.Dockerfile` | ModelArts image with PyTorch 2.x and `torch-npu` |
| `8.2.RC1.alpha003-modelarts.Dockerfile` | ModelArts image with a scientific Python stack on CANN 8.2 |
| `8.2.RC1.alpha002-modelarts.Dockerfile` | Older ModelArts line with Miniconda (Python 3.10) |
| `8.1.RC1.beta1-modelarts.Dockerfile` | Legacy ModelArts line retained for compatibility |

Newer lines (`8.5.x`, `9.0.0`, `9.0.0-beta.2`, `9.1.0-master`, and device- or distro-specific variants such as 910b / 910c / A3 and Ubuntu / openEuler) follow the same pattern: pin a CANN base tag in the filename, then add packages and user setup needed for that target. Browse `cann/` for the full set.

The 8.3 RC1 base image is still a useful reference for a “batteries included” local toolchain. It expects a prebuilt archive at build time (`clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz` in the build context), installs it to `/opt/llvm`, and exports `LLVM_INSTALL_PREFIX`, `CC`, and `CXX` accordingly. Python packages commonly pinned in that line include NumPy, SciPy, pybind11, pytest, and related build helpers. `entrypoint.sh` sources Ascend environment scripts and can configure in-container SSH when keys are supplied.

```bash
docker build -f cann/8.3.RC1-base.Dockerfile -t cann:8.3-base .
```

Older tags are kept mainly for reproducing historical environments and dependency pins.

## llvm

From-source LLVM 19.1.7 images (Clang, MLIR, and MLIR Python bindings) on Ubuntu 22.04 and openEuler 22.03, including a matching CPython 3.11.15 build. These images do not install CANN; they are intentional bases for compiler and binding work.

Full build options, install paths, and usage notes are in [llvm/README.md](https://github.com/wuzhenqing/dockerfile/blob/main/llvm/README.md).

## mindspore

MindSpore training and development image for Ascend. `mindspore/2.7-cann8.2-modelarts.Dockerfile` builds on the AscendHub CANN 8.2 RC1 alpha003 Ubuntu 22.04 Python 3.11 base, configures `ma-user` for ModelArts, widens permissions under `/usr/local/Ascend`, and installs MindSpore 2.7.0 together with a scientific Python stack (NumPy, SciPy, SymPy, and related native build dependencies such as Eigen and Boost).

Ascend environment scripts are expected to be sourced at runtime (`setenv.bash` from the ascend-toolkit). Use this image for MindSpore model work on Ascend rather than for general LLVM or NumPy-only prototyping.

```bash
docker build -f mindspore/2.7-cann8.2-modelarts.Dockerfile -t mindspore:2.7 .
```

## pyasc

PyASC (Python for Ascend) images live under `pyasc/`. There are two complementary styles.

**Distribution developer image** (`Dockerfile`) starts from a published LLVM 19.1.7 SWR image (CPython 3.11.15, Clang, MLIR) selected with `LLVM_IMAGE`, then installs toolkit and ops packages supplied through the required build arguments `CANN_TOOLKIT_URL` and `CANN_OPS_URL`. Interactive shells source the installed CANN environment via `~/.bashrc`. These images are meant for self-contained local environments where you choose the CANN snapshot yourself. The default `LLVM_IMAGE` is the Ubuntu 24.04 SWR tag in `ap-southeast-1`; override it for openEuler 24.03 (or a 22.x LLVM tag if you have published one). [`pyasc-weekly.yml`](https://github.com/wuzhenqing/dockerfile/blob/main/.github/workflows/pyasc-weekly.yml) rebuilds Ubuntu 24.04 and openEuler 24.03 every Tuesday and publishes multi-arch tags `pyasc:master-910b-llvm19.1.7-<os>`.

**ModelArts stack image** (`9.0.0-910b-ubuntu22.04-py3.11.Dockerfile`) starts from the published CANN 9.0.0 AscendHub tag, runs as `ma-user`, and layers Miniconda, a from-source LLVM under `/home/ma-user/LLVM`, and PyTorch / torch-npu wheels for cloud-oriented development.

Build and run details, including how to obtain matching CANN `.run` URLs, are in [pyasc/README.md](https://github.com/wuzhenqing/dockerfile/blob/main/pyasc/README.md).

```bash
docker build \
  -f pyasc/Dockerfile \
  --build-arg CANN_TOOLKIT_URL='https://.../Ascend-cann-toolkit_....run' \
  --build-arg CANN_OPS_URL='https://.../Ascend-cann-910b-ops_....run' \
  -t pyasc-dev:ubuntu24.04 .

docker build -f pyasc/9.0.0-910b-ubuntu22.04-py3.11.Dockerfile -t pyasc:9.0.0 .
```

## verl

Thin customization on top of a published Ascend veRL / vLLM stack image (`quay.io/ascend/verl` with CANN 9.0.0 and torch-npu). Use `verl/Dockerfile` when you need that training stack with repository-local adjustments rather than assembling the full dependency tree from scratch.

```bash
docker build -f verl/Dockerfile -t verl:dev .
```

## Choosing an image

For quick algorithm prototyping on Ascend, start with **asnumpy**. For MindSpore training, use the **mindspore** Dockerfile. For PyTorch on Ascend via a CANN base, pick a matching **cann** ModelArts or versioned tag (for example 8.3 RC1 alpha003 or a newer 9.x line). Compiler, MLIR, or PyASC host work belongs in **llvm** or the **pyasc** distribution developer images, depending on whether you need CANN installed in the same container. veRL / vLLM training stacks should use **verl**.

Local root-oriented images typically omit a ModelArts suffix or use `*-base`; ModelArts deployments should use `*-modelarts` (or an equivalent `ma-user` setup) so UID/GID and home paths match the platform. Prefer the newest stable CANN line that your software supports; keep older Dockerfiles only when you must reproduce a pinned environment.

## FAQ

**Which CANN version should I use?** Prefer a current stable or project-required pin (many recent Dockerfiles target 8.5.x or 9.0.x). Reach for older tags such as 8.1 / 8.2 only when dependency compatibility demands it.

**What is the difference between base and ModelArts images?** Toolchains are intended to match; the important differences are the default user (`root` vs `ma-user`), home directory layout, and where user-level tools such as pip write configuration. See [Image variants](index.md#image-variants) on the home page.

**Can I add `ma-user` to a base image myself?** Yes, but it is usually simpler and less error-prone to build the corresponding ModelArts Dockerfile.

**How do I shrink image size?** Multi-stage builds, dropping unused packages, deleting build trees and package caches in the same `RUN` layer, and a tight `.dockerignore` are the usual levers. From-source LLVM and full scientific stacks will remain large by nature.
