FROM debian:bullseye as downloader-python 
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "running on $BUILDPLATFORM, building for $TARGETPLATFORM" 

ARG PYTORCH_VERSION
RUN echo "Building PyTorch version ${PYTORCH_VERSION}"

WORKDIR /workspace

RUN apt-get update && apt-get install -y git

RUN git clone --recursive --branch ${PYTORCH_VERSION} https://github.com/pytorch/pytorch.git

FROM python:3.13-bullseye as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake 

FROM builder as pytorch-builder
COPY --from=downloader-python /workspace/pytorch /workspace/pytorch

# install cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN /bin/bash -c "source $HOME/.cargo/env && cd /workspace/pytorch && pip3 install -r requirements.txt"

# fixes error c10::Scalar::Scalar(long long int)' cannot be overloaded with 'c10::Scalar::Scalar(int64_t)'
RUN cd /workspace/pytorch/c10/core && grep -rl --include='*.h' '#if defined(__linux__) && !defined(__ANDROID__)' . | xargs sed -i '/#if defined(__linux__) && !defined(__ANDROID__)/,/#endif/ s/^/\/\//'

# Configure and build LibTorch
RUN mkdir -p /workspace/pytorch/build && cd /workspace/pytorch/build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_PYTHON=OFF \
    -DBUILD_CUSTOM_PROTOBUF=ON \
    -DUSE_CUDA=OFF \
    -DUSE_NCCL=OFF \
    -DUSE_NNPACK=OFF \
    -DUSE_PYTORCH_QNNPACK=OFF \
    -DUSE_QNNPACK=OFF \
    -DUSE_XNNPACK=OFF \
    -DUSE_MKLDNN=OFF \
    -DUSE_DISTRIBUTED=OFF \
    -DBUILD_TEST=OFF 

RUN cd /workspace/pytorch/build && cmake --build . -j1

RUN cd /workspace/pytorch/build && cmake --install . --prefix /workspace/pytorch/install --config Release

ARG PYTORCH_VERSION
RUN cd /workspace/pytorch/install && tar -czf /workspace/pytorch-${PYTORCH_VERSION}.tar.gz .
