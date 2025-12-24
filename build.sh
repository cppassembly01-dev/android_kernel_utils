#!/bin/bash

export PATH=~/oneplus/prebuilts/clang-r536225/bin:~/oneplus/prebuilts/arm-gnu-toolchain-15.2.rel1-x86_64-aarch64-none-linux-gnu/bin:$PATH
export ARCH=arm64
export SUBARCH=arm64
export LLVM=1
export CROSS_COMPILE=aarch64-none-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
export KBUILD_BUILD_USER=akronnos
export KBUILD_BUILD_HOST=archlinux
rm -rf out
make O=out lemonades_defconfig
make O=out -j3 CLANG_TRIPLE=aarch64-linux-gnu-
