# Projects

Background and configuration notes for each image family in this repository. For build commands and layout overview, start with the [home page](../index.md). Naming rules live in [Naming Conventions](../naming-conventions.md).

<div class="grid cards" markdown>

-   :material-docker: **asnumpy**

    NumPy-like API development image for Ascend NPU.

    [:octicons-arrow-right-24: Read more](asnumpy.md)

-   :material-layers-triple: **cann**

    Multi-version CANN base and ModelArts images.

    [:octicons-arrow-right-24: Read more](cann.md)

-   :material-hammer-wrench: **llvm**

    LLVM 19.1.7, Clang, MLIR, and MLIR Python bindings from source.

    [:octicons-arrow-right-24: Read more](llvm.md)

-   :material-brain: **mindspore**

    MindSpore training and development images on Ascend CANN.

    [:octicons-arrow-right-24: Read more](mindspore.md)

-   :material-language-python: **pyasc**

    Python-for-Ascend toolchain and published rolling images.

    [:octicons-arrow-right-24: Read more](pyasc.md)

-   :material-rocket-launch: **verl**

    veRL / vLLM stack tailored for Ascend / ModelArts.

    [:octicons-arrow-right-24: Read more](verl.md)

</div>

## Choosing an image

For quick algorithm prototyping on Ascend, start with **asnumpy**. For MindSpore training, use the **mindspore** Dockerfile. For PyTorch on Ascend via a CANN base, pick a matching **cann** ModelArts or versioned tag (for example 8.3 RC1 alpha003 or a newer 9.x line). Compiler, MLIR, or PyASC host work belongs in **llvm** or the **pyasc** distribution developer images, depending on whether you need CANN installed in the same container. veRL / vLLM training stacks should use **verl**.

Local root-oriented images typically omit a ModelArts suffix or use `*-base`; ModelArts deployments should use `*-modelarts` (or an equivalent `ma-user` setup) so UID/GID and home paths match the platform. Prefer the newest stable CANN line that your software supports; keep older Dockerfiles only when you must reproduce a pinned environment.

## FAQ

**Which CANN version should I use?** Prefer a current stable or project-required pin (many recent Dockerfiles target 8.5.x or 9.0.x). Reach for older tags such as 8.1 / 8.2 only when dependency compatibility demands it.

**What is the difference between base and ModelArts images?** Toolchains are intended to match; the important differences are the default user (`root` vs `ma-user`), home directory layout, and where user-level tools such as pip write configuration. See [Image variants](../index.md#image-variants) on the home page.

**Can I add `ma-user` to a base image myself?** Yes, but it is usually simpler and less error-prone to build the corresponding ModelArts Dockerfile.

**How do I shrink image size?** Multi-stage builds, dropping unused packages, deleting build trees and package caches in the same `RUN` layer, and a tight `.dockerignore` are the usual levers. From-source LLVM and full scientific stacks will remain large by nature.
