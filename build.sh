#!/bin/bash

### Setup build environment ###
sudo apt update
sudo apt upgrade -y
sudo apt-get install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig bc libssl-dev flex

### Environment variables ###
workdir=~

HOST_ARCH=`arch`

if [ $HOST_ARCH == x86_64 ]; then
clang=clang-r547379
CLANG=$workdir/$clang/bin; fi

if [ $HOST_ARCH == aarch64 ]; then
CLANG=$workdir; fi

gcc=14.3.rel1
GCC=$workdir/arm-gnu-toolchain-$gcc-$HOST_ARCH-aarch64-none-linux-gnu/bin

kernel_source=https://github.com/cppassembly01-dev/Droidlinux_kernel_alioth
kernel_root=~/Droidlinux_kernel_alioth

PATH=$CLANG:$GCC:$PATH
export LINKER=ld.lld
export KBUILD_BUILD_USER=akronnos
export KBUILD_BUILD_HOST=nethunter

### Clang toolchain ###
if [ $HOST_ARCH == x86_64 ]; then
cd $workdir
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android16-release/clang-r547379.tar.gz
mkdir $clang
tar -xvf $clang.tar.gz -C $clang
rm $clang.tar.gz
fi

### GCC toolchain ###
wget https://developer.arm.com/-/media/Files/downloads/gnu/$gcc/binrel/arm-gnu-toolchain-$gcc-$HOST_ARCH-aarch64-none-linux-gnu.tar.xz
mkdir arm-gnu-toolchain-$gcc-$HOST_ARCH-aarch64-none-linux-gnu
tar -xvf arm-gnu-toolchain-$gcc-$HOST_ARCH-aarch64-none-linux-gnu.tar.xz -C \
arm-gnu-toolchain-$gcc-$HOST_ARCH-aarch64-none-linux-gnu
rm arm-gnu-toolchain-$gcc-$HOST_ARCH-aarch64-none-linux-gnu.tar.xz

### Download the kernel source ###
#git clone $kernel_source

### Apply patches to the kernel ###
# for patch in fix-nfs-backport.patch monitor_mode_enable.patch fix-config.gz.patch
#do
#        cp ~/alioth_ath9k_htc/patches/$patch $kernel_root
#        cd $kernel_root
#        patch -p1 < $patch
# done
# git clone https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder
# cp ~/alioth_ath9k_htc/patches/add-wifi-injection-4.14.patch kali-nethunter-kernel-builder/patches/4.19
# cd kali-nethunter-kernel-builder
# ./build.sh
# cd ..

### KernelSU-Next and SUSFS setup ###
cd $kernel_root
if [ -d "KernelSU-Next" ]; then
rmdir KernelSU-Next
fi
curl -LSs https://raw.githubusercontent.com/cppassembly01-dev/alioth_ath9k_htc/refs/heads/main/SUSFS/setup.sh | bash -

### Perform the build ###
# cp ~/alioth_ath9k_htc/configs/nethunter.config $kernel_root/arch/arm64/configs/vendor
# cp ~/alioth_ath9k_htc/configs/linux.config $kernel_root/arch/arm64/configs/vendor

make O=out ARCH=arm64 SUBARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-none-linux-gnu- alioth_defconfig vendor/nethunter.config vendor/linux.config
make O=out ARCH=arm64 SUBARCH=arm64 LLVM=1 LLVM_IAS=1 CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-none-linux-gnu- -j$(nproc --all)
