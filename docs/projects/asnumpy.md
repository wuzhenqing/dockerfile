# asnumpy

Development image for NumPy-style Ascend NPU workflows. The Dockerfile starts from `ascendai/cann:9.0.0-beta.2-910b-ubuntu22.04-py3.11`, creates a ModelArts-compatible `ma-user` account, and installs a full host toolchain (Clang/LLVM, CMake, Ninja, GDB, ripgrep, tmux, and related utilities).

Inside the image, Miniforge/Mamba provides two conda environments (`py311` and `py312`). Each environment ships NumPy, pytest, PyTorch 2.9.0, and matching `torch-npu` / torchvision / torchaudio wheels so algorithm work can move between NumPy-style code and PyTorch without rebuilding the container.

```bash
docker build -f asnumpy/Dockerfile -t asnumpy:dev .
```

Prefer this image when you want a relatively light Ascend development shell for prototyping and tests, rather than a from-source LLVM or framework training stack.
