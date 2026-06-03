# Jetson AGX Orin BSP 編譯紀錄

> 基於 **JetPack 6.2.2 / L4T r36.5.0**，已實測編譯更新成功。

---

## 官方資源

| 項目 | 連結 |
|------|------|
| 官方文件首頁 | https://docs.nvidia.com/jetson/index.html |
| Jetson Linux Archive | https://developer.nvidia.com/embedded/jetson-linux-archive |
| r36.5.0 版本頁面 | https://developer.nvidia.com/embedded/jetson-linux-r365 |
| r36.5 Developer Guide | https://docs.nvidia.com/jetson/archives/r36.5/DeveloperGuide/index.html |

### 下載項目

| 項目 | URL |
|------|-----|
| Driver Package (BSP) | https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v5.0/release/Jetson_Linux_r36.5.0_aarch64.tbz2 |
| Sample Root Filesystem | https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v5.0/release/Tegra_Linux_Sample-Root-Filesystem_r36.5.0_aarch64.tbz2 |
| BSP Sources | https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v5.0/sources/public_sources.tbz2 |
| Bootlin Toolchain gcc 11.3 | https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2 |
| Bootlin Toolchain Sources | https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.3/toolchain/toolchain-source_toolchains.bootlin.com-2022.08.1.tar.bz2 |

---

## 前置準備

### 安裝必要套件

```bash
sudo apt install git-core build-essential bc
```

### 解壓 Toolchain

```bash
mkdir $HOME/l4t-gcc
cd $HOME/l4t-gcc
tar xf <toolchain_archive>
```

### 設定交叉編譯環境變數

```bash
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
```

---

## Step 1：建立 Root File System

### 1-1：產生 RootFS

```bash
cd Linux_for_Tegra/tools/samplefs

# Desktop 版本
sudo ./nv_build_samplefs.sh --abi aarch64 --distro ubuntu --flavor desktop --version jammy

# Minimal 版本
sudo ./nv_build_samplefs.sh --abi aarch64 --distro ubuntu --flavor minimal --version jammy
```

### 1-2：解壓至 rootfs 目錄

```bash
sudo tar -jxpf sample_fs.tbz2 -C ../../rootfs/
```

### 1-3：套用 NVIDIA 驅動

```bash
cd ../../
sudo ./apply_binaries.sh
```

### 1-4：建立預設使用者

```bash
sudo ./tools/l4t_create_default_user.sh -u nvidia -p nvidia
```

---

## Step 2：同步 Kernel 原始碼

```bash
cd Linux_for_Tegra/source/
./source_sync.sh -t jetson_36.5
```

---

## Step 3：編譯 Kernel

```bash
cd Linux_for_Tegra/source/
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
make -C kernel
```

> 如需修改 kernel config，可直接編輯 `kernel/kernel-jammy-src/arch/arm64/configs/defconfig`，或使用指令：
> ```bash
> ./kernel/kernel-jammy-src/scripts/config \
>   --file "./kernel/kernel-jammy-src/arch/arm64/configs/defconfig" \
>   --enable CONFIG_WIREGUARD
> ```
> 如需 Real-time Kernel，請先執行 `./generic_rt_build.sh "enable"`。

---

## Step 4：安裝 Kernel 及 In-tree Modules

```bash
export INSTALL_MOD_PATH=/Linux_for_Tegra/rootfs/
sudo -E make install -C kernel
cp kernel/kernel-jammy-src/arch/arm64/boot/Image ../kernel/Image
```

---

## Step 5：編譯並安裝 NVIDIA Out-of-Tree Modules

```bash
# 編譯
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
make modules

# 安裝（需先確認 rootfs 已完成 apply_binaries.sh）
export INSTALL_MOD_PATH=/Linux_for_Tegra/rootfs/
sudo -E make modules_install

# 更新 initramfs
cd ..
sudo ./tools/l4t_update_initrd.sh
```

> 若編譯 Real-time Kernel，需額外設定：
> ```bash
> export IGNORE_PREEMPT_RT_PRESENCE=1
> ```

---

## Step 6：編譯 DTB

```bash
cd Linux_for_Tegra/source/
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
make dtbs
cp kernel-devicetree/generic-dts/dtbs/* ../kernel/dtb/
```

---

## Step 7：燒錄裝置（Jetson AGX Orin，NVMe）

建議使用 `nvsdkmanager_flash.sh`，可自動偵測裝置 SKU：

```bash
sudo ./nvsdkmanager_flash.sh --storage nvme0n1p1
```

或使用 initrd flash 方式：

```bash
sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
  --external-device nvme0n1p1 \
  -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
  --network usb0 \
  jetson-agx-orin-devkit \
  external
```

或使用 flash.sh 方式：

```bash
sudo ./flash.sh jetson-agx-orin-devkit nvme0n1p1
```

---

## Docker 編譯環境

使用 Docker 容器可提供一致且隔離的編譯環境，避免 Host 系統套件污染。

### 目錄結構

```
project/
├── Dockerfile
├── docker-compose.yml
├── workspace/          # 放置 Linux_for_Tegra/
└── toolchain/          # 解壓 Bootlin Toolchain 至此
```

> **注意**：`toolchain/` 目錄對應容器內的 `~/l4t-gcc/aarch64--glibc--stable-2022.08-1`，
> 請確認 Toolchain 解壓後的子目錄名稱與此一致。

### Dockerfile

```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安裝編譯依賴
RUN apt-get update && \
    apt-get install -y fakeroot libncurses-dev gcc-aarch64-linux-gnu \
                    g++-aarch64-linux-gnu make gcc flex bison python3 \
                    dialog wget sudo bzip2 gdisk build-essential bc git \
                    ssh time file software-properties-common abootimg \
                    binfmt-support binutils cpio cpp device-tree-compiler \
                    dosfstools lbzip2 libxml2-utils nfs-kernel-server openssl \
                    python3-yaml qemu-user-static sshpass udev uuid-runtime \
                    whois rsync zstd lz4 libssl-dev libelf-dev iproute2 \
                    iputils-ping netcat-openbsd parted usbutils xmlstarlet \
                    xxd zlib1g python-is-python3 curl whiptail kmod \
    && rm -rf /var/lib/apt/lists/*

# 建立使用者（UID/GID 由 build args 傳入，與 Host 對齊避免權限問題）
ARG USER_ID=1001
ARG GROUP_ID=1001
ARG USERNAME=jetson-dev

RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -u ${USER_ID} -g ${USERNAME} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# 設定 .bashrc 環境變數（自動載入 CROSS_COMPILE）
RUN echo 'export TOOLCHAIN_SUBDIR="aarch64--glibc--stable-2022.08-1"' >> ~/.bashrc && \
    echo 'export L4T_GCC_PATH="$HOME/l4t-gcc"' >> ~/.bashrc && \
    echo 'export CROSS_COMPILE="$L4T_GCC_PATH/${TOOLCHAIN_SUBDIR}/bin/aarch64-buildroot-linux-gnu-"' >> ~/.bashrc && \
    echo 'export PATH="$L4T_GCC_PATH/${TOOLCHAIN_SUBDIR}/bin:$PATH"' >> ~/.bashrc

RUN mkdir -p ~/l4t-gcc ~/workspace

WORKDIR /home/${USERNAME}/workspace
CMD ["/bin/bash", "-l"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  jetson-bsp-builder:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        USER_ID: ${USER_ID:-1001}
        GROUP_ID: ${GROUP_ID:-1001}

    container_name: jetson-bsp-r36-5-builder

    privileged: true
    network_mode: host

    # 以 Host UID:GID 執行，掛載目錄的新生成檔案直接屬於 Host 帳號
    user: "${USER_ID:-1001}:${GROUP_ID:-1001}"

    environment:
      - USER=jetson-dev
      - HOME=/home/jetson-dev
      - INSTALL_MOD_PATH=/home/jetson-dev/workspace/Linux_for_Tegra/rootfs
      - KERNEL_HEADERS=/home/jetson-dev/workspace/Linux_for_Tegra/source/kernel/kernel-jammy-src

    devices:
      - "/dev/bus/usb:/dev/bus/usb"

    volumes:
      - ./workspace:/home/jetson-dev/workspace:rw
      - ./toolchain:/home/jetson-dev/l4t-gcc/aarch64--glibc--stable-2022.08-1:rw
      - /tmp:/tmp:rw,rshared
      - /run/udev/control:/run/udev/control:ro
      - /dev/bus/usb:/dev/bus/usb
      - /dev:/dev

    stdin_open: true
    tty: true
    command: /bin/bash -l
```

### 使用方式

**啟動前，取得 Host 的 UID/GID：**

```bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
```

**建立並進入容器：**

```bash
docker compose up -d
docker compose exec jetson-bsp-builder bash
```

或直接啟動（前景執行）：

```bash
USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose run --rm jetson-bsp-builder
```

**容器內的路徑對應：**

| Host 路徑 | 容器路徑 |
|-----------|----------|
| `./workspace/` | `/home/jetson-dev/workspace/` |
| `./toolchain/` | `/home/jetson-dev/l4t-gcc/aarch64--glibc--stable-2022.08-1/` |

---

## 注意事項與問題紀錄

### DTS 路徑

Jetson AGX Orin 64G 的 Board DTS **不在** kernel 原始碼樹中，而是在 out-of-tree 的路徑：

```
# 正確路徑
Linux_for_Tegra/source/hardware/nvidia/t23x/nv-public/nv-platform/
    tegra234-p3737-0000+p3701-0005-nv.dts

# 注意：以下路徑的 DTS 不是目標板子的正確檔案
Linux_for_Tegra/source/kernel/kernel-jammy-src/arch/arm64/boot/dts/nvidia/
    tegra234-p3737-0000+p3701-0000.dts
```

`make dtbs` 完成後，需手動將 DTB 複製到正確位置：

```bash
# 來源
source/kernel-devicetree/generic-dts/dtbs/tegra234-p3737-0000+p3701-0005-nv.dtb

# 目標
Linux_for_Tegra/kernel/dtb/tegra234-p3737-0000+p3701-0005-nv.dtb
```

### 驗證 DTB

```bash
# 查看 model 資訊
dtc -I dtb -O dts source/kernel-devicetree/generic-dts/dtbs/tegra234-p3737-0000+p3701-0005-nv.dtb | grep -i "model"
dtc -I dtb -O dts kernel/dtb/tegra234-p3737-0000+p3701-0005-nv.dtb | grep -i "model"
dtc -I dtb -O dts rootfs/boot/kernel_tegra234-p3737-0000+p3701-0005-nv.dtb | grep -i "model"

# 比對各路徑的 DTB 是否一致
cmp source/kernel-devicetree/generic-dts/dtbs/tegra234-p3737-0000+p3701-0005-nv.dtb \
    kernel/dtb/tegra234-p3737-0000+p3701-0005-nv.dtb

cmp source/kernel-devicetree/generic-dts/dtbs/tegra234-p3737-0000+p3701-0005-nv.dtb \
    rootfs/boot/tegra234-p3737-0000+p3701-0005-nv.dtb

cmp source/kernel-devicetree/generic-dts/dtbs/tegra234-p3737-0000+p3701-0005-nv.dtb \
    tools/kernel_flash/images/external/kernel_tegra234-p3737-0000+p3701-0005-nv.dtb
```
