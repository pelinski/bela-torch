#!/bin/bash
source PYTORCH_VERSION.env
mkdir pytorch-install
tar -xvf pytorch-install.tar -C pytorch-install && mv pytorch-install/workspace/pytorch-${PYTORCH_VERSION}.tar.gz ./
rm -rf pytorch-install
