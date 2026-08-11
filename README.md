# Ascend Container Images

Dockerfiles for building development and runtime images around [Huawei Ascend CANN](https://www.hiascend.com/document) and related toolchains.

This repository collects versioned, reviewable Dockerfiles for Ascend-based workflows: CANN runtimes, framework stacks (MindSpore, PyASC, veRL), NumPy-style NPU APIs, and a from-source LLVM / Clang / MLIR development base.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Repository layout

```text
.
├── asnumpy/       # NumPy-like API development image for Ascend NPU
├── cann/          # CANN runtime images across versions and platforms
├── llvm/          # LLVM / Clang / MLIR built from source
├── mindspore/     # MindSpore training / development images
├── pyasc/         # PyASC (Python for Ascend) development images
├── verl/          # veRL + Ascend / vLLM stack images
├── docs/          # Naming conventions and project notes
└── README.md
```

## Projects

| Project | Description | Docs |
|---------|-------------|------|
| **asnumpy** | Development image for NumPy-like Ascend NPU APIs | [projects.md](docs/projects.md#asnumpy) |
| **cann** | Multi-version CANN base and ModelArts images | [projects.md](docs/projects.md#cann) |
| **llvm** | LLVM 19.1.7, Clang, MLIR, and MLIR Python bindings from source | [llvm/README.md](llvm/README.md) |
| **mindspore** | MindSpore on Ascend CANN | [projects.md](docs/projects.md#mindspore) |
| **pyasc** | Python-for-Ascend toolchain and development environment | [pyasc/README.md](pyasc/README.md), [projects.md](docs/projects.md#pyasc) |
| **verl** | veRL image tailored for Ascend / ModelArts | — |

## Quick start

### Build

Run from the repository root. Build context depends on the Dockerfile (some use `.`, others use a project subdirectory).

```bash
# asnumpy
docker build -f asnumpy/Dockerfile -t asnumpy:dev .

# CANN (example)
docker build -f cann/8.3.RC1-base.Dockerfile -t cann:8.3-base .

# LLVM 19.1.7 (Ubuntu 22.04 / openEuler 22.03)
docker build -f llvm/Dockerfile.ubuntu22.04 -t llvm:19.1.7-ubuntu22.04 llvm
docker build -f llvm/Dockerfile.openeuler22.03 -t llvm:19.1.7-openeuler22.03 llvm
docker build -f llvm/Dockerfile.ubuntu24.04 -t llvm:19.1.7-ubuntu24.04 llvm
docker build -f llvm/Dockerfile.openeuler24.03 -t llvm:19.1.7-openeuler24.03 llvm

# MindSpore
docker build -f mindspore/2.7-cann8.2-modelarts.Dockerfile -t mindspore:2.7 .

# PyASC (upstream-style developer images; CANN .run URLs required)
docker build -f pyasc/Dockerfile.ubuntu22.04 \
  --build-arg CANN_TOOLKIT_URL='...' \
  --build-arg CANN_OPS_URL='...' \
  -t pyasc-dev:ubuntu22.04 .
docker build -f pyasc/Dockerfile.openeuler22.03 \
  --build-arg CANN_TOOLKIT_URL='...' \
  --build-arg CANN_OPS_URL='...' \
  -t pyasc-dev:openeuler22.03 .

# PyASC ModelArts stack (CANN 9.0.0 base)
docker build -f pyasc/9.0.0-910b-ubuntu22.04-py3.11.Dockerfile -t pyasc:9.0.0 .

# veRL
docker build -f verl/Dockerfile -t verl:dev .
```

LLVM builds are especially heavy; prefer a native builder for the target architecture. See [llvm/README.md](llvm/README.md) for install paths and environment variables.

### Run (Ascend host)

Local development images typically need Ascend devices and the host driver mounted:

```bash
docker run -it --rm \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  asnumpy:dev \
  /bin/bash
```

ModelArts-oriented images usually run as `ma-user` and may accept host SSH public keys via environment variables. Check the individual Dockerfile for entrypoints and user setup.

## Image variants

Many CANN and framework Dockerfiles follow a two-variant convention:

| Suffix | Typical user | Intended use |
|--------|--------------|--------------|
| `*-base` / no ModelArts suffix | `root` | Local development and testing |
| `*-modelarts` | `ma-user` (UID 1000) | Huawei Cloud ModelArts |

Naming rules are documented in [docs/naming-conventions.md](docs/naming-conventions.md).

## Documentation

- [Naming conventions](docs/naming-conventions.md) — how Dockerfiles are named and organized
- [Project notes](docs/projects.md) — per-project background and configuration notes
- [LLVM images](llvm/README.md) — build options, paths, and usage for the LLVM base
- [Contributing](CONTRIBUTING.md) — how to propose changes

## Requirements

- Docker or Podman (20.10+ recommended)
- Linux host (Ubuntu 22.04 is a common baseline)
- Ascend hardware and drivers for runtime use of NPU-backed images
- Network access to pull base images and, for some Dockerfiles, upstream source archives

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Issues and pull requests are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.

## Related links

- [CANN documentation](https://www.hiascend.com/document)
- [MindSpore documentation](https://www.mindspore.cn/docs)
- [LLVM 19.1.7 release](https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.7)
