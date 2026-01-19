# Nvidia toolchain
## Using R36.4(Jetpack 6.1) with Jetson orin AGX for Example
- https://developer.nvidia.com/embedded/jetson-linux-archive

## Choose your Jetpack version
- https://developer.nvidia.com/embedded/jetson-linux-r3640

## Download the toolchain
- Bootlin Toolchain gcc 11.3 
https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2

- Bootlin Toolchain Sources, 2020.08-1
https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/toolchain/toolchain-source_toolchains.bootlin.com-2022.08.1.tar.bz2

## Extracting the Toolchain
```
mkdir $HOME/l4t-gcc
cd $HOME/l4t-gcc
tar xf <toolchain_archive>
```

## Setting the CROSS_COMPILE Environment Variable
```
export CROSS_COMPILE=<toolchain-path>/bin/aarch64-buildroot-linux-gnu-
Ex:
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
```

# Nvidia source code
- 
- Driver Package (BSP)
https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2
---

## Prerequisites
```
sudo apt install git-core
sudo apt install build-essential bc
```

## To Sync the Kernel Sources with Git
```
cd <install-path>/Linux_for_Tegra/source
./source_sync.sh -k -t <release-tag>

Ex:
cd Linux_for_Tegra/source/
./source_sync.sh -k -t jetson_36.4
```

# Building the Jetson Linux Kernel
## if not building the real-time kernel, don't ./generic_rt_build.sh "enable"
- realtime kernel please: ./generic_rt_build.sh "enable"

```
cd Linux_for_Tegra/source/
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
make -C kernel
```

# Modify the defconfig
- kernel-jammy-src/arch/arm64/configs/defconfig

## you can modify the defconfig as above path or using below command to add kernel config
```
./kernel/kernel-jammy-src/scripts/config --file "./kernel/kernel-jammy-src/arch/arm64/configs/defconfig" --enable CONFIG_WIREGUARD
```
# Push related module to device of Jetson orin AGX
```
sudo mkdir /lib/modules/5.15.148-tegra/kernel/drivers/net/wireguard/
sudo cp wireguard.ko /lib/modules/5.15.148-tegra/kernel/drivers/net/wireguard/
sudo cp libchacha20poly1305.ko /lib/modules/5.15.148-tegra/kernel/lib/crypto/
sudo cp poly1305-neon.ko /lib/modules/5.15.148-tegra/kernel/arch/arm64/crypto/
sudo depmod -a
sudo modprobe wireguard
lsmod | grep wire
sudo cp wireguard.conf /etc/modules-load.d/
reboot
```
# Reference
- https://developer.nvidia.com/embedded/jetpack-archive
- https://docs.nvidia.com/jetson/archives/r36.4/DeveloperGuide/SD/Kernel/KernelCustomization.html
- https://www.wireguard.com/compilation/
- https://docs.kinesis.network/blog/enable-wireguard-on-nvidia-jetson
