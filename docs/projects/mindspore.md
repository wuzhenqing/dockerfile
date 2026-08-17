# mindspore

MindSpore training and development image for Ascend. `mindspore/2.7-cann8.2-modelarts.Dockerfile` builds on the AscendHub CANN 8.2 RC1 alpha003 Ubuntu 22.04 Python 3.11 base, configures `ma-user` for ModelArts, widens permissions under `/usr/local/Ascend`, and installs MindSpore 2.7.0 together with a scientific Python stack (NumPy, SciPy, SymPy, and related native build dependencies such as Eigen and Boost).

Ascend environment scripts are expected to be sourced at runtime (`setenv.bash` from the ascend-toolkit). Use this image for MindSpore model work on Ascend rather than for general LLVM or NumPy-only prototyping.

```bash
docker build -f mindspore/2.7-cann8.2-modelarts.Dockerfile -t mindspore:2.7 .
```
