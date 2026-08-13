# CANN Master Base Images

Rolling base images built from the `master` (bleeding-edge) channel of the Huawei Ascend CANN toolkit, for Ubuntu 22.04/24.04 and openEuler 22.03/24.03. Each Dockerfile is a single stage: it installs a C/C++ toolchain, builds CPython 3.11.15 from source under `/usr/local/python3.11.15`, then installs the CANN toolkit and ops packages supplied as build arguments.

`CANN_TOOLKIT_URL` and `CANN_OPS_URL` are required and must point at matching `.run` installers from the same snapshot on the [Ascend CANN run-package mirror](https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/), typically under `master/`. Build the Ubuntu variant with:

```bash
docker build \
  -f cann/master/ubuntu22.04/Dockerfile \
  --build-arg CANN_TOOLKIT_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-toolkit_<version>_linux-<arch>.run' \
  --build-arg CANN_OPS_URL='https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/<snapshot>/Ascend-cann-910b-ops_<version>_linux-<arch>.run' \
  -t cann:master-ubuntu22.04 \
  .
```

Use the matching directory for the other variants:

- `cann/master/ubuntu22.04/Dockerfile`
- `cann/master/ubuntu24.04/Dockerfile`
- `cann/master/openeuler22.03/Dockerfile`
- `cann/master/openeuler24.03/Dockerfile`

The images run as root. A `HwHiAiUser` account is still created because the CANN installers expect it, not because the container runs as a different user. Interactive shells load the CANN environment automatically by sourcing `/usr/local/Ascend/cann/set_env.sh` from `~/.bashrc`; source it yourself for non-interactive commands.

[`cann-master-weekly.yml`](../../.github/workflows/cann-master-weekly.yml) rebuilds all four variants every Tuesday against the latest CANN master snapshot and publishes rolling multi-arch tags such as `cann:master-910b-ubuntu24.04`.
