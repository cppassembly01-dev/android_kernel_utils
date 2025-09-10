#!/bin/bash

### Setup build environment ###
sudo apt update
sudo apt upgrade
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig bc libssl-dev

# Toolchain location
toolchains=~

### Clang toolchain ###
clang=clang-r547379
cd $toolchains
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz
mkdir $clang
tar -xvf $clang.tar.gz -C $clang
CLANG=$tolchains/$clang

### GCC toolchain ###
gcc=14.3.rel1
wget https://developer.arm.com/-/media/Files/downloads/gnu/$gcc/binrel/arm-gnu-toolchain-$gcc-x86_64-aarch64-none-linux-gnu.tar.xz
mkdir arm-gnu-toolchain-$gcc-x86_64-aarch64-none-linux-gnu
tar -xvf arm-gnu-toolchain-$gcc-x86_64-aarch64-none-linux-gnu.tar.xz -C \
arm-gnu-toolchain-$gcc-x86_64-aarch64-none-linux-gnu
GCC=$toolchains/arm-gnu-toolchain-$gcc-x86_64-aarch64-none-linux-gnu

### Download the kernel source ###
kernel_source=https://github.com/raystef66/InfiniR_kernel_alioth
kernel_root=~/InfiniR_kernel_alioth
git clone $kernel_source

### Apply patches to the kernel ###
git clone https://github.com/cppassembly01-dev/alioth_ath9k_htc
for patch in fix-nfs-backport.patch monitor_mode_enable.patch fix-config.gz.patch
do
        cp ~/alioth_ath9k_htc/patches/$patch $kernel_root
        cd $kernel_root
        patch -p1 < $patch
done
git clone https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder
cp ~/alioth_ath9k_htc/patches/add-wifi-injection-4.14.patch kali-nethunter-kernel-builder/patches/4.19
cd kali-nethunter-kernel-builder
./build.sh
cd ..

### KernelSU-Next and SUSFS setup ###
rmdir KernelSU-Next
git clone https://github.com/KernelSU-Next/KernelSU-Next -b v1.0.9
cp ~/alioth_ath9k_htc/SUSFS/setup.sh $kernel_root
cp ~/alioth_ath9k_htc/SUSFS/susfs-1.5.9-a13-5.15.patch $kernel_root
bash - setup.sh

### Perform the build ###
cp ~/alioth_ath9k_htc/configs/nethunter.config $kernel_root/arch/arm64/configs/vendor
cp ~/alioth_ath9k_htc/configs/linux.config $kernel_root/arch/arm64/configs/vendor
CLANG=$toolchains/$clang/bin
GCC=$toolchains/arm-gnu-toolchain-$gcc-x86_64-aarch64-none-linux-gnu/bin
PATH=$CLANG:$GCC:$PATH
export LINKER=ld.lld
make O=out ARCH=arm64 SUBARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-none-linux-gnu- alioth_defconfig vendor/nethunter.config vendor/linux.config
make O=out ARCH=arm64 SUBARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-none-linux-gnu-
