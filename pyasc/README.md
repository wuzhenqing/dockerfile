# PyASC Developer Images

Dockerfiles for PyASC (Python for Ascend) development environments. This directory holds two complementary image styles: a single distribution developer image that layers CANN onto a published LLVM base from SWR, and a ModelArts-oriented stack on a published CANN 9.0.0 base.

## Distribution developer image

[`Dockerfile`](https://github.com/wuzhenqing/dockerfile/blob/main/pyasc/Dockerfile) starts from an LLVM 19.1.7 image (CPython 3.11.15, Clang, MLIR, and MLIR Python bindings) and installs the Ascend CANN toolkit plus a matching ops package. Login shells source `/usr/local/Ascend/cann/set_env.sh` through `~/.bashrc`. `PATH`, `LLVM_INSTALL_PREFIX`, and `PYTHONPATH` are inherited from the LLVM base so the custom Python and MLIR bindings stay importable.

### Published images

Rolling `master` tags are published to two Huawei Cloud SWR regions. Prefer the registry closest to you. Log in first if the repository is private.

| Region | Registry | Role | Recommended tags |
|--------|----------|------|------------------|
| Hong Kong | `swr.ap-southeast-1.myhuaweicloud.com` | Weekly CI location | `wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04`, `wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03` (plus per-arch `-amd64` / `-arm64` tags) |
| Guiyang1 | `swr.cn-southwest-2.myhuaweicloud.com` | China-region copy | `wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04`, `wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03` |

```bash
# Guiyang1
docker login swr.cn-southwest-2.myhuaweicloud.com
docker pull swr.cn-southwest-2.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04
docker pull swr.cn-southwest-2.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03

# Hong Kong
docker login swr.ap-southeast-1.myhuaweicloud.com
docker pull swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04
docker pull swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03
```

Hong Kong also publishes explicit per-arch tags:

```text
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04-amd64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04-arm64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03-amd64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03-arm64
```

Mount a PyASC checkout and the host Ascend devices when you run NPU workloads:

```bash
docker run --rm -it \
  --name pyasc-dev \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  -v "$(pwd):/workspace/pyasc" \
  -w /workspace/pyasc \
  swr.cn-southwest-2.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04 \
  bash
```

Interactive bash sessions load the CANN environment through `~/.bashrc`. For non-interactive commands, source `/usr/local/Ascend/cann/set_env.sh` yourself if you need CANN tools on `PATH`. Swap the registry host for the Hong Kong tag if that region is closer.

### LLVM base images

To build your own image instead, pull an LLVM base from Hong Kong SWR. Those images are multi-arch (`linux/amd64` and `linux/arm64`); Docker selects the matching architecture:

```bash
docker login swr.ap-southeast-1.myhuaweicloud.com
docker pull swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-ubuntu24.04
docker pull swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-openeuler24.03
```

Select the base with `LLVM_IMAGE`. The default is the Ubuntu 24.04 SWR tag; pass the openEuler tag (or another published LLVM tag) when you need a different distro:

| `LLVM_IMAGE` | Distro |
|--------------|--------|
| `swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-ubuntu24.04` | Ubuntu 24.04 (default) |
| `swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-openeuler24.03` | openEuler 24.03 |
| `swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-ubuntu22.04` | Ubuntu 22.04 |
| `swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-openeuler22.03` | openEuler 22.03 |

Build on a host whose CPU architecture matches the CANN `.run` packages you download (`aarch64` or `x86_64`). CANN installers are architecture-specific, so build each platform separately.

### CANN package URLs

The Dockerfile does not hard-code CANN versions. You must pass two build arguments with direct download URLs:

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

From the repository root. Ubuntu 24.04 uses the default SWR `LLVM_IMAGE`:

```bash
docker build \
  -f pyasc/Dockerfile \
  --build-arg CANN_TOOLKIT_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-toolkit_<version>_linux-<arch>.run' \
  --build-arg CANN_OPS_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-910b-ops_<version>_linux-<arch>.run' \
  -t pyasc-dev:ubuntu24.04 \
  .
```

openEuler 24.03 points `LLVM_IMAGE` at the matching SWR tag:

```bash
docker build \
  -f pyasc/Dockerfile \
  --build-arg LLVM_IMAGE='swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-openeuler24.03' \
  --build-arg CANN_TOOLKIT_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-toolkit_<version>_linux-<arch>.run' \
  --build-arg CANN_OPS_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-910b-ops_<version>_linux-<arch>.run' \
  -t pyasc-dev:openeuler24.03 \
  .
```

`CANN_TOOLKIT_URL` and `CANN_OPS_URL` are required; the build fails if either argument is omitted or unreachable. `LLVM_IMAGE` must be a published LLVM 19.1.7 tag with the Python and LLVM layout from `llvm/`.

### Weekly CI builds

[`pyasc-weekly.yml`](https://github.com/wuzhenqing/dockerfile/blob/main/.github/workflows/pyasc-weekly.yml) rebuilds the distribution image every Tuesday against the latest CANN master snapshot. It pulls the SWR LLVM bases above, builds `amd64` and `arm64` natively, and publishes rolling tags to Hong Kong SWR. The same multi-arch tag names are also available on Guiyang1. See [Published images](#published-images) for the full URLs and pull commands.

The workflow can also be started with **Actions → pyasc-weekly → Run workflow**.

### Run a locally built image

If you built the image yourself, replace the published tag with the local name:

```bash
docker run --rm -it \
  --name pyasc-dev \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  -v "$(pwd):/workspace/pyasc" \
  -w /workspace/pyasc \
  pyasc-dev:ubuntu24.04 \
  bash
```

### Notes

Python is installed under `/usr/local/python3.11.15` and placed first on `PATH`, so `python` / `python3` resolve to 3.11. The images also create the `HwHiAiUser` account expected by the CANN installers; development commands in this Dockerfile run as `root`.

## ModelArts stack image

[`9.0.0-910b-ubuntu22.04-py3.11.Dockerfile`](https://github.com/wuzhenqing/dockerfile/blob/main/pyasc/9.0.0-910b-ubuntu22.04-py3.11.Dockerfile) starts from `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:9.0.0-910b-ubuntu22.04-py3.11`, configures `ma-user` for ModelArts, and layers Miniconda, a from-source LLVM under `/home/ma-user/LLVM`, plus PyTorch / torch-npu and related wheels. It does not take `LLVM_IMAGE` or `CANN_*_URL` build arguments.

```bash
docker build -f pyasc/9.0.0-910b-ubuntu22.04-py3.11.Dockerfile -t pyasc:9.0.0 .
```

## Related

For the CANN-free LLVM base used by the distribution image, see [LLVM images](https://docker.infrae.top/projects/llvm/).
