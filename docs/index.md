# Ascend Container Images

Dockerfiles for building development and runtime images around [Huawei Ascend CANN](https://www.hiascend.com/document) and related toolchains.

This repository collects versioned, reviewable Dockerfiles for Ascend-based workflows: CANN runtimes, framework stacks (MindSpore, PyASC, veRL), NumPy-style NPU APIs, and a from-source LLVM / Clang / MLIR development base.

<div class="grid cards" markdown>

-   :material-docker: **asnumpy**

    NumPy-like API development image for Ascend NPU.

    [:octicons-arrow-right-24: Read more](projects.md#asnumpy)

-   :material-layers-triple: **cann**

    Multi-version CANN base and ModelArts images.

    [:octicons-arrow-right-24: Read more](projects.md#cann)

-   :material-hammer-wrench: **llvm**

    LLVM 19.1.7, Clang, MLIR, and MLIR Python bindings from source.

    [:octicons-arrow-right-24: Read more](projects.md#llvm)

-   :material-brain: **mindspore**

    MindSpore training and development images on Ascend CANN.

    [:octicons-arrow-right-24: Read more](projects.md#mindspore)

-   :material-language-python: **pyasc**

    Python-for-Ascend toolchain and development environment.

    [:octicons-arrow-right-24: Read more](projects.md#pyasc)

-   :material-rocket-launch: **verl**

    veRL / vLLM stack tailored for Ascend / ModelArts.

    [:octicons-arrow-right-24: Read more](projects.md#verl)

</div>

## Quick start

Run from the repository root. The build context depends on the Dockerfile (some use `.`, others use a project subdirectory).

```bash
# asnumpy
docker build -f asnumpy/Dockerfile -t asnumpy:dev .

# CANN (example)
docker build -f cann/8.3.RC1-base.Dockerfile -t cann:8.3-base .

# LLVM 19.1.7 (Ubuntu / openEuler)
docker build -f llvm/Dockerfile.ubuntu24.04 -t llvm:19.1.7-ubuntu24.04 llvm

# MindSpore
docker build -f mindspore/2.7-cann8.2-modelarts.Dockerfile -t mindspore:2.7 .

# PyASC distribution developer image
docker build -f pyasc/Dockerfile.ubuntu24.04 \
  --build-arg CANN_TOOLKIT_URL='...' \
  --build-arg CANN_OPS_URL='...' \
  -t pyasc-dev:ubuntu24.04 .
```

LLVM builds are especially heavy; prefer a native builder for the target architecture. See the [Projects](projects.md) section for detailed build options and environment variables.

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

Naming rules are documented in [Naming Conventions](naming-conventions.md).

## Documentation

- [Projects](projects.md) — per-project background and configuration notes
- [Naming conventions](naming-conventions.md) — how Dockerfiles are named and organized
- [Contributing](contributing.md) — how to propose changes

## Requirements

- Docker or Podman (20.10+ recommended)
- Linux host (Ubuntu 22.04 is a common baseline)
- Ascend hardware and drivers for runtime use of NPU-backed images
- Network access to pull base images and, for some Dockerfiles, upstream source archives

## License

This project is licensed under the [MIT License](https://github.com/wuzhenqing/dockerfile/blob/main/LICENSE).

## Contributing

Issues and pull requests are welcome. Please read the [Contributing Guide](contributing.md) before submitting changes.

## Related links

- [CANN documentation](https://www.hiascend.com/document)
- [MindSpore documentation](https://www.mindspore.cn/docs)
- [LLVM 19.1.7 release](https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.7)
