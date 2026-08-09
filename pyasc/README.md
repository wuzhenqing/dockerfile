# PyASC Developer Images

Dockerfiles for PyASC (Python for Ascend) development environments. This directory holds two complementary image styles: distribution-based developer images that build Python and LLVM from source and install CANN from `.run` packages, and a ModelArts-oriented stack on a published CANN 9.0.0 base.

## Distribution developer images

| File | Base image |
|------|------------|
| [`Dockerfile.ubuntu22.04`](Dockerfile.ubuntu22.04) | `ubuntu:22.04` |
| [`Dockerfile.openeuler22.03`](Dockerfile.openeuler22.03) | `openeuler/openeuler:22.03` |

Both images install a host C/C++ toolchain, build CPython 3.11.15 from source under `/usr/local/python3.11.15`, compile LLVM/MLIR 19.1.7 with Python bindings enabled into `/opt/LLVM-19.1.7` (`LLVM_INSTALL_PREFIX`), and install Ascend CANN toolkit plus a matching ops package. Login shells source `/usr/local/Ascend/cann/set_env.sh` through `~/.bashrc`.

Build on a host whose CPU architecture matches the CANN `.run` packages you download (aarch64 or x86_64). Compiling LLVM from source needs ample CPU, memory, and disk; expect a long first build.

### CANN package URLs

These Dockerfiles do not hard-code CANN versions. You must pass two build arguments with direct download URLs:

`CANN_TOOLKIT_URL` — Ascend CANN toolkit installer (`.run`)  
`CANN_OPS_URL` — Ascend CANN ops installer for your target device (`.run`)

Browse the public mirror to pick packages:

https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/

Typical channels include `master/` (weekly snapshots) and `legacy/`. Open a snapshot directory, then choose toolkit and ops installers that match your architecture and device. Filenames look like:

```text
Ascend-cann-toolkit_<version>_linux-<arch>.run
Ascend-cann-910b-ops_<version>_linux-<arch>.run
```

Use the full HTTPS URL of each file as the corresponding build argument. Keep toolkit and ops from the same snapshot so versions align. Package names may contain `~`; leave that character as-is in the URL.

Example paths from a `master` weekly snapshot (replace with the files you select):

```text
https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-toolkit_<version>_linux-aarch64.run
https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-910b-ops_<version>_linux-aarch64.run
```

### Build

From the repository root:

```bash
docker build \
  -f pyasc/Dockerfile.ubuntu22.04 \
  --build-arg CANN_TOOLKIT_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-toolkit_<version>_linux-<arch>.run' \
  --build-arg CANN_OPS_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-910b-ops_<version>_linux-<arch>.run' \
  -t pyasc-dev:ubuntu22.04 \
  .
```

Swap in `pyasc/Dockerfile.openeuler22.03` and tag `pyasc-dev:openeuler22.03` for the openEuler variant. Both `CANN_TOOLKIT_URL` and `CANN_OPS_URL` are required; the build fails if either argument is omitted or unreachable.

### Run

Mount a PyASC checkout and start an interactive shell:

```bash
docker run --rm -it \
  --name pyasc-dev \
  -v "$(pwd):/workspace/pyasc" \
  -w /workspace/pyasc \
  pyasc-dev:ubuntu22.04 \
  bash
```

Attach Ascend devices and driver mounts required by your host when you run NPU workloads. Interactive bash sessions load the CANN environment through `~/.bashrc`. For non-interactive commands, source `/usr/local/Ascend/cann/set_env.sh` yourself if you need CANN tools on `PATH`.

### Notes

Python is installed under `/usr/local/python3.11.15` and placed first on `PATH`, so `python` / `python3` resolve to 3.11. The LLVM/MLIR build enables `MLIR_ENABLE_BINDINGS_PYTHON` against that interpreter. The images also create the `HwHiAiUser` account expected by the CANN installers; development commands in these Dockerfiles run as `root`.

## ModelArts stack image

[`9.0.0-910b-ubuntu22.04-py3.11.Dockerfile`](9.0.0-910b-ubuntu22.04-py3.11.Dockerfile) starts from `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:9.0.0-910b-ubuntu22.04-py3.11`, configures `ma-user` for ModelArts, and layers Miniconda, a from-source LLVM under `/home/ma-user/LLVM`, plus PyTorch / torch-npu and related wheels. It does not take `CANN_*_URL` build arguments.

```bash
docker build -f pyasc/9.0.0-910b-ubuntu22.04-py3.11.Dockerfile -t pyasc:9.0.0 .
```

## Related

Additional project context is in [docs/projects.md](../docs/projects.md#pyasc). For a CANN-free LLVM base with the same Python and LLVM layout, see [llvm/README.md](../llvm/README.md).
