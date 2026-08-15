# AGENTS.md

Guidance for AI coding agents working in this repository. It assumes no prior knowledge of the project.

## Project overview

This is **not an application codebase** — it is a curated collection of Dockerfiles for building development and runtime container images around [Huawei Ascend CANN](https://www.hiascend.com/document) and related toolchains. There is no compiled code, no package manifest (`pyproject.toml`, `package.json`, etc.), and no application test suite. The "build artifacts" are Docker images; the only configuration files are `mkdocs.yml` (documentation site), `.gitignore`, and GitHub Actions workflows under `.github/`.

### Technology stack

- **Dockerfiles** — the entire deliverable. Built with Docker or Podman (20.10+).
- **Base images**: published Ascend CANN tags (e.g. `ascendai/cann:...`, `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:...`, `quay.io/ascend/verl:...`), plus plain `ubuntu:22.04/24.04` and `openeuler/openeuler:22.03/24.03` for from-source builds.
- **In-image toolchains**: CANN toolkit/ops `.run` installers, from-source LLVM/Clang/MLIR 19.1.7 and CPython 3.11.15, Miniconda/Miniforge, PyTorch + torch-npu, MindSpore.
- **Documentation**: MkDocs Material (`mkdocs.yml`), sources in `docs/`, deployed to GitHub Pages (site URL `https://docker.infrae.top/`).
- **CI/CD**: GitHub Actions only (`.github/workflows/`).

### Runtime architecture

Images target Ascend NPU hosts. At runtime, NPU-backed containers need the host's Ascend devices and driver mounted:

```bash
docker run -it --rm \
  --device=/dev/davinci0 --device=/dev/davinci_manager \
  --device=/dev/devmm_svm --device=/dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  <image> /bin/bash
```

Two image variants exist across the repo (see `docs/naming-conventions.md`):

- **base / no suffix** — runs as `root`, workdir `/root`, for local development and testing.
- **`-modelarts`** — runs as `ma-user` (UID 1000, GID 100), workdir `/home/ma-user`, for Huawei Cloud ModelArts. These may accept SSH public keys via environment variables; check each Dockerfile's entrypoint.

## Repository layout

Each project has its own directory; versions/variants are distinguished by **filename**, not subdirectory (except `cann/master/`):

| Directory | Contents |
|-----------|----------|
| `cann/` | Versioned CANN runtime/toolkit images (`8.1` through `9.1.0-master`, 910b/910c/A3 devices, Ubuntu/openEuler). `cann/entrypoint.sh` is the shared container startup script. `cann/master/<os>/Dockerfile` are rolling master-channel builds. |
| `llvm/` | From-source LLVM 19.1.7 + Clang + MLIR (+ Python bindings) on 4 distros, no CANN. Files named `Dockerfile.<distro>`. |
| `pyasc/` | PyASC developer image: `Dockerfile` layers CANN onto an LLVM 19.1.7 base (`LLVM_IMAGE`, plus required `CANN_TOOLKIT_URL`/`CANN_OPS_URL`), and a ModelArts stack on CANN 9.0.0. |
| `mindspore/` | MindSpore 2.7 + CANN 8.2 ModelArts image. |
| `asnumpy/` | NumPy-style Ascend NPU dev image (Miniforge, `py311`/`py312` conda envs, PyTorch 2.9.0 + torch-npu). |
| `verl/` | Thin customization over the published `quay.io/ascend/verl` vLLM/veRL stack. |
| `docs/` | MkDocs sources: `index.md` (mirrors README), `projects.md` (per-image notes), `naming-conventions.md`, `contributing.md`. |

Per-directory READMEs with build/run details: `llvm/README.md`, `pyasc/README.md`, `cann/master/README.md`.

## Build and test commands

There is no test suite. Verification = lint + build.

```bash
# Lint all Dockerfiles (required before submitting changes)
find . -name "Dockerfile*" -exec hadolint {} +

# Syntax-check a single Dockerfile
docker build -f path/to/Dockerfile --check .

# Build (run from repo root; build context is usually `.`, but `llvm/` uses `llvm`)
docker build -f cann/8.3.RC1-base.Dockerfile -t cann:8.3-base .
docker build -f llvm/Dockerfile.ubuntu22.04 -t llvm:19.1.7-ubuntu22.04 llvm
docker build -f pyasc/Dockerfile \
  --build-arg CANN_TOOLKIT_URL='...' --build-arg CANN_OPS_URL='...' \
  -t pyasc-dev:ubuntu24.04 .

# Preview the docs site locally
pip install mkdocs-material && mkdocs serve
```

Notes:

- Most Dockerfiles are aarch64-oriented (Ascend 910b); some base variants hard-fail on other architectures at build time.
- LLVM builds are CPU/memory-intensive; use a native builder for the target arch.
- `cann/8.3.RC1-base.Dockerfile` expects a prebuilt `clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz` in the build context (such archives are gitignored — never commit them).
- CANN `.run` URLs come from the public mirror `https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/`; keep toolkit and ops from the same snapshot.

## Code style guidelines

Dockerfile conventions (from `docs/contributing.md` and existing files):

- **Uppercase instructions** (`FROM`, `RUN`, `COPY`, ...); comment each major step.
- **Combine related `RUN` steps** to reduce layers; place slow-changing steps early for cache reuse; clean package caches in the same `RUN` layer.
- **Pin explicit versions** for base images and pip packages; avoid `latest`.
- **No hardcoded secrets**; ModelArts images must run as `ma-user`, not root.
- **Naming**: `{version-tag}-{platform-tag}.Dockerfile` where the platform tag is `base` or `modelarts` (framework images embed dependency versions, e.g. `2.7-cann8.2-modelarts.Dockerfile`). Never repeat the project name in the filename. Full rules and anti-patterns: `docs/naming-conventions.md`.
- Keep `base` and `modelarts` variants of the same image in sync (same packages, toolchain, env vars — only user/home/pip-config differences).
- Existing images commonly set China-region mirrors (HuaweiCloud apt/pip), timezone `Asia/Shanghai`, and locale `en_US.UTF-8` — follow that pattern in new images.
- **Always update docs** (`README.md`, `docs/projects.md`, directory READMEs) when adding or changing a Dockerfile.

Git conventions: branch prefixes `feat/ fix/ docs/ refactor/ test/`; commit prefixes `feat: fix: docs: style: refactor: test: chore:`. PRs go through GitHub review against `main`.

## CI/CD and deployment

- **`.github/workflows/cann-master-weekly.yml`** — every Tuesday (and on dispatch) builds `cann/master/` for 4 OS variants × amd64/arm64, resolving the latest CANN master snapshot URLs from the mirror at build time, and pushes rolling tags (`cann:master-910b-<os>[-<arch>]`) plus multi-arch manifests to a registry configured via repo variables `IMAGE_REGISTRY`/`IMAGE_NAMESPACE` and secrets `REGISTRY_USERNAME`/`REGISTRY_PASSWORD`.
- **`.github/workflows/pyasc-weekly.yml`** — every Tuesday (and on dispatch) builds `pyasc/Dockerfile` for Ubuntu 24.04 and openEuler 24.03 on amd64 and arm64. It pulls published LLVM 19.1.7 bases from the same registry, resolves the latest CANN master snapshot URLs, and publishes four per-arch tags (`pyasc:master-910b-llvm19.1.7-<os>-<arch>`) plus two multi-arch tags (`pyasc:master-910b-llvm19.1.7-<os>`).
- **`.github/workflows/pages.yml`** — on every push to `main`, builds the MkDocs site and deploys to GitHub Pages.
- No other automated builds/tests exist; all other images are built manually on demand.

## Security considerations

- Never commit secrets, CANN installer archives, wheels, or tarballs — `.gitignore` already excludes `*.tar.*`, `*.whl`, `Miniconda*.sh`, `clang+llvm-*.tar.xz`, etc.
- Do not bake SSH private keys or credentials into images; in-container SSH is configured at runtime from supplied public keys via `entrypoint.sh`.
- Registry credentials live only in GitHub Actions secrets.
- Runtime device/driver mounts grant the container direct NPU access — treat these images as privileged development environments, not sandboxed workloads.

## Key documentation

- `README.md` — quick start, build commands, variant table.
- `docs/naming-conventions.md` — authoritative Dockerfile naming rules.
- `docs/projects.md` — per-project background and how to choose an image.
- `docs/contributing.md` — style guide, pre-commit checks, PR process.
- `llvm/README.md`, `pyasc/README.md`, `cann/master/README.md` — detailed per-image build/run instructions.
