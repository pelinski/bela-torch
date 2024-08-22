# bela-torch
This repository contains a Dockerfile that builds pytorch for armv7. Instead of cross-compiling with a CMake toolchain, we use the official pytorch build system to build pytorch for armv7. This is done by using the `multiarch/qemu-user-static` docker image to emulate an armv7 environment.

## Building pytorch for armv7

You will need to have Docker installed and running. You can install it following the instructions on the [Docker website](https://docs.docker.com/get-docker/).

Before we get started we need to ensure that we can emulate ARM32. We do this by install `qemu` and configuring it:

```bash
# Install QEMU
sudo apt install binfmt-support qemu qemu-user-static

# Configure QEMU to enable execution of different multi-architecture containers by QEMU and binfmt_misc
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

After our prerequisites are done, we can compile pytorch by starting up the docker build process (be aware that it might take 2-3h to compile):

```bash
docker buildx build --build-arg V_PYTORCH=main --platform=linux/arm/v7 --progress=plain --output type=local,dest=./pytorch-install .
```

## Credits
This repo builds on top of https://github.com/rodrigodzf/bela-torch and https://github.com/XavierGeerinck/Jetson-Linux-PyTorch
