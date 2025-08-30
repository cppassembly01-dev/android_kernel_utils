#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz
mkdir clang-r547379
tar -xvf clang-r547379.tar.gz -C clang-r547379

CLANG=/workspaces/alioth_ath9k_htc/clang-r547379/bin
GCC=/workspaces/alioth_ath9k_htc/arm-gnu-toolchain-14.3.rel1-x86_64-aarch64-none-linux-gnu/bin
PATH=$CLANG:$GCC::$PATH

make O=out ARCH=arm64 SUBARCH=arm64 CC=clang LD=ld.lld LLVM_IAS=0 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-none-linux-gnu- -j4
