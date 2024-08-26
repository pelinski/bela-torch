# Use an Ubuntu base image
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

FROM debian:bullseye as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3 \
    python3-pip 

FROM builder as pytorch-builder
COPY --from=downloader-python /workspace/pytorch /workspace/pytorch

RUN cd /workspace/pytorch && pip3 install -r requirements.txt

# Configure and build LibTorch
RUN mkdir -p /workspace/pytorch/build && cd /workspace/pytorch/build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_PYTHON=OFF \
    -DUSE_CUDA=OFF \
    -DUSE_NCCL=OFF \
    -DUSE_NNPACK=OFF \
    -DUSE_PYTORCH_QNNPACK=OFF \
    -DUSE_QNNPACK=OFF \
    -DUSE_XNNPACK=OFF \
    -DUSE_MKLDNN=OFF \
    -DUSE_DISTRIBUTED=OFF \
    -DBUILD_TEST=OFF 

RUN cd /workspace/pytorch/build && cmake --build . -j4

RUN cd /workspace/pytorch/build && cmake --install . --prefix /workspace/pytorch/install --config Release

ARG PYTORCH_VERSION
RUN cd /workspace/pytorch/install && tar -czf /workspace/pytorch-${PYTORCH_VERSION}.tar.gz .


# Set the entrypoint to bash so users can inspect the environment
# ENTRYPOINT ["/bin/bash"]
