# =============================================================================
# Jetson AGX Orin BSP 編譯環境 - R36.5.0 (JetPack 6.2.2)
# Base Image: Ubuntu 22.04 (Jammy Jellyfish)
# 最終修正：配合工具鏈實際目錄結構調整掛載與環境變數
# =============================================================================

FROM ubuntu:22.04

# 避免互動式提示並設定 locale
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# =============================================================================
# 1. 安裝基礎套件與編譯依賴
# =============================================================================
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

# =============================================================================
# 2. 建立使用者
# =============================================================================
ARG USER_ID=1001
ARG GROUP_ID=1001
ARG USERNAME=jetson-dev

RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -u ${USER_ID} -g ${USERNAME} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# =============================================================================
# 3. 切換至使用者並設定環境
# =============================================================================
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# =============================================================================
# 4. 設定 .bashrc 環境變數 (關鍵：使用正確的 toolchain 子目錄名稱)
# =============================================================================
# 注意：這裡的 TOOLCHAIN_SUBDIR 必須與 docker-compose.yml 掛載的目錄名稱一致
RUN echo "# === Jetson BSP Environment (Auto-generated) ===" >> /home/${USERNAME}/.bashrc && \
    echo 'export TOOLCHAIN_SUBDIR="aarch64--glibc--stable-2022.08-1"' >> /home/${USERNAME}/.bashrc && \
    echo 'export L4T_GCC_PATH="$HOME/l4t-gcc"' >> /home/${USERNAME}/.bashrc && \
    echo 'export CROSS_COMPILE="$L4T_GCC_PATH/${TOOLCHAIN_SUBDIR}/bin/aarch64-buildroot-linux-gnu-"' >> /home/${USERNAME}/.bashrc && \
    echo 'export PATH="$L4T_GCC_PATH/${TOOLCHAIN_SUBDIR}/bin:$PATH"' >> /home/${USERNAME}/.bashrc && \
    echo 'echo "✓ Jetson BSP 環境已載入"' >> /home/${USERNAME}/.bashrc && \
    echo 'echo "  CROSS_COMPILE=$CROSS_COMPILE"' >> /home/${USERNAME}/.bashrc && \
    echo 'echo "  Compiler: $(${CROSS_COMPILE}gcc --version | head -n1)"' >> /home/${USERNAME}/.bashrc

# 建立必要目錄
RUN mkdir -p /home/${USERNAME}/l4t-gcc /home/${USERNAME}/workspace

WORKDIR /home/${USERNAME}/workspace

# =============================================================================
# 5. 預設指令：使用登入 shell 確保 .bashrc 載入
# =============================================================================
CMD ["/bin/bash", "-l"]
