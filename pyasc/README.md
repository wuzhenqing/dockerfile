# PyASC Developer Images

Dockerfiles for PyASC (Python for Ascend) development environments. This directory holds two complementary image styles: a single distribution developer image that layers CANN onto a published LLVM base from SWR, and a ModelArts-oriented stack on a published CANN 9.0.0 base.

## Distribution developer image

[`Dockerfile`](Dockerfile) starts from an LLVM 19.1.7 image (CPython 3.11.15, Clang, MLIR, and MLIR Python bindings) and installs the Ascend CANN toolkit plus a matching ops package. Login shells source `/usr/local/Ascend/cann/set_env.sh` through `~/.bashrc`. `PATH`, `LLVM_INSTALL_PREFIX`, and `PYTHONPATH` are inherited from the LLVM base so the custom Python and MLIR bindings stay importable.

Pull the LLVM base from SWR. The images are multi-arch (`linux/amd64` and `linux/arm64`); Docker selects the matching architecture. Log in first if the repository is private:

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

### Weekly images

[`pyasc-weekly.yml`](../.github/workflows/pyasc-weekly.yml) rebuilds the distribution image every Tuesday against the latest CANN master snapshot. It pulls the SWR LLVM bases above, builds `amd64` and `arm64` natively, and publishes four rolling per-arch tags plus two multi-arch tags:

```text
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04-amd64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04-arm64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03-amd64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03-arm64
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-ubuntu24.04
swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/pyasc:master-910b-llvm19.1.7-openeuler24.03
```

The workflow can also be started with **Actions → pyasc-weekly → Run workflow**.

### Run

Mount a PyASC checkout and start an interactive shell:

```bash
docker run --rm -it \
  --name pyasc-dev \
  -v "$(pwd):/workspace/pyasc" \
  -w /workspace/pyasc \
  pyasc-dev:ubuntu24.04 \
  bash
```

Attach Ascend devices and driver mounts required by your host when you run NPU workloads. Interactive bash sessions load the CANN environment through `~/.bashrc`. For non-interactive commands, source `/usr/local/Ascend/cann/set_env.sh` yourself if you need CANN tools on `PATH`.

### Notes

Python is installed under `/usr/local/python3.11.15` and placed first on `PATH`, so `python` / `python3` resolve to 3.11. The images also create the `HwHiAiUser` account expected by the CANN installers; development commands in this Dockerfile run as `root`.

## ModelArts stack image

[`9.0.0-910b-ubuntu22.04-py3.11.Dockerfile`](9.0.0-910b-ubuntu22.04-py3.11.Dockerfile) starts from `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:9.0.0-910b-ubuntu22.04-py3.11`, configures `ma-user` for ModelArts, and layers Miniconda, a from-source LLVM under `/home/ma-user/LLVM`, plus PyTorch / torch-npu and related wheels. It does not take `LLVM_IMAGE` or `CANN_*_URL` build arguments.

```bash
docker build -f pyasc/9.0.0-910b-ubuntu22.04-py3.11.Dockerfile -t pyasc:9.0.0 .
```

## Related

Additional project context is in [docs/projects.md](../docs/projects.md#pyasc). For the CANN-free LLVM base used by the distribution image, see [llvm/README.md](../llvm/README.md).
