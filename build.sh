#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig
wget https://dl.google.com/android/repository/android-ndk-r28c-linux.zip
unzip android-ndk-r28c-linux.zip
CLANG=/workspaces/alioth_ath9k_htc/clang-r536225/bin
GCC=/workspaces/alioth_ath9k_htc/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9/bin
GCC32=/workspaces/alioth_ath9k_htc/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9/bin
PATH=$CLANG:$GCC:$GCC32:$PATH
make O=out ARCH=arm64 SUBARCH=arm64 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CROSS_COMPILE_ARM32=arm-linux-androideabi- -j4 alioth_defconfig
