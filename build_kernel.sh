#!/bin/bash

git clone https://github.com/raystef66/InfiniR_kernel_alioth --recursive
cd InfiniR_kernel_alioth
rm -rf KernelSU-Next
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
cp $HOME/alioth_ath9k_htc/nfs.patch .
git apply nfs.patch
git clone https://gitlab.com/simonpunk/susfs4ksu -b kernel-4.19
cd susfs4ksu
cp ./kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch ../KernelSU-Next
cd ../KernelSU-Next
patch -p1 < 10_enable_susfs_for_ksu.patch
