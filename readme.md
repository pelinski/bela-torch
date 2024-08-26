# bela-torch
This repository contains a Dockerfile that builds pytorch for armv7. Instead of cross-compiling with a CMake toolchain, we use the official pytorch build system to build pytorch for armv7. This is done by using the `multiarch/qemu-user-static` docker image to emulate an armv7 environment.

Note: I tried adding CI with Github Actions, but since the build takes over 6h, it gets killed even when using Docker cache, so the docker build has to be run locally.

## Building pytorch for armv7

You will need to have Docker installed and running. You can install it following the instructions on the [Docker website](https://docs.docker.com/get-docker/).

Before we get started we need to ensure that we can emulate ARM32. We do this by install `qemu` and configuring it:

```bash
# Install QEMU
sudo apt install binfmt-support qemu qemu-user-static

# Configure QEMU to enable execution of different multi-architecture containers by QEMU and binfmt_misc
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

After our prerequisites are done, we can compile pytorch by starting up the docker build process. Be aware that it might take ~5h to compile. You can set the `PYTORCH_VERSION` build argument to the version of pytorch you want to build. The default is `main`.

```bash
docker buildx build --build-arg PYTORCH_VERSION=main --platform=linux/arm/v7 --progress=plain --output type=tar,dest=pytorch-install.tar .
```

This generates a `pytorch-install.tar` file that contains all the filesystem from the docker image. The packaged installation is in `workspace/pytorch//pytorch-${PYTORCH_VERSION}.tar.gz`. To extract the compiled pytorch, run the following commands:

```bash
source PYTORCH_VERSION.env
mkdir pytorch-install && tar -xvf pytorch-install.tar -C pytorch-install
mv pytorch-install/workspace/pytorch-${PYTORCH_VERSION}.tar.gz ./
rm -rf pytorch-install
```

or alternatively, `./extract-pytorch-install.sh` will do the same.


## Credits
This repo builds on top of https://github.com/rodrigodzf/bela-torch and https://github.com/XavierGeerinck/Jetson-Linux-PyTorch
