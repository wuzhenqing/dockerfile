# cann

CANN (Compute Architecture for Neural Networks) is Huawei Ascend’s runtime and toolkit layer. The `cann/` directory holds versioned Dockerfiles that layer developer tooling on top of published CANN base images, covering both local `root` images and ModelArts `ma-user` variants.

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

## Master channel

--8<-- "cann/master/README.md:3:"
