#!/bin/bash
# =============================================================================
# Jetson AGX Orin BSP 一鍵編譯腳本
# 版本: R36.5.0 (JetPack 6.2.2)
# build.sh version: v0.3
# =============================================================================

# -----------------------------------------------------------------------------
# 全域設定（依實際環境修改）
# -----------------------------------------------------------------------------
TOOLCHAIN_PATH="$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1"
L4T_PATH="$(cd "$(dirname "$0")" && pwd)/Linux_for_Tegra"
SOURCE_PATH="${L4T_PATH}/source"
ROOTFS_PATH="${L4T_PATH}/rootfs"
RELEASE_TAG="jetson_36.5"
BUILD_JOBS=$(nproc)

# -----------------------------------------------------------------------------
# 顏色輸出（必須放在最前面，因為所有函數都會用到）
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

die() { log_error "$*"; exit 1; }

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------
usage()
{
    echo ""
    echo "USAGE: $0 [-R] [-S] [-K] [-M] [-D] [-B] [-T] [-I] [-F] [-r FLAVOR] [-u USER] [-p PASSWORD] [-m NUM] [-j JOBS] [-a]"
    echo ""
    echo "No ARGS means show this help message"
    echo ""
    echo "WHERE: -R = build RootFS (若已建置則跳過；單獨 -R 強制重建)"
    echo "       -S = sync kernel source (若已 sync 則跳過；單獨 -S 強制重新 sync)"
    echo "       -K = build kernel"
    echo "       -M = build & install out-of-tree modules + update initramfs"
    echo "       -D = build DTBs"
    echo "       -B = update bootloader files to bootloader directory (使用 flash.sh --no-flash)"
    echo "       -T = flash bootloader DTB to device (使用 --no-systemimg -k A_cpu-bootloader)"
    echo "            Note: 需先執行 -D 編譯 DTB，及 -B 更新 bootloader 目錄"
    echo "       -I = make MFI massflash package (產生線刷包)"
    echo "       -F = flash device (使用 nvsdkmanager_flash.sh)"
    echo "       -r = rootfs flavor: 'desktop' or 'minimal' (default: desktop)"
    echo "       -u = default username for rootfs (default: nvidia)"
    echo "       -p = default password for rootfs (default: nvidia)"
    echo "       -m = number of devices for MFI massflash (default: 5)"
    echo "       -j = build jobs (default: nproc = ${BUILD_JOBS})"
    echo "       -a = build all: RootFS + Sync + Kernel + Modules + DTBs (不含 flash, bootloader, MFI)"
    echo ""
    echo "EXAMPLE:"
    echo "  $0 -a               # 全部編譯（不 flash）"
    echo "  $0 -K -M -D         # 只重新編譯 Kernel + Modules + DTBs"
    echo "  $0 -R -r minimal    # 只建立 Minimal RootFS"
    echo "  $0 -B               # 只更新 Bootloader 目錄檔案"
    echo "  $0 -T               # 只燒錄 Bootloader DTB 到裝置"
    echo "  $0 -D -B -T         # 編譯 DTB → 更新 Bootloader 目錄 → 燒錄到裝置"
    echo "  $0 -I -m 10         # 製作 MFI 線刷包（10 台裝置）"
    echo "  $0 -F               # 只執行燒錄"
    echo ""
    exit 1
}

# -----------------------------------------------------------------------------
# 初始化旗標
# -----------------------------------------------------------------------------
BUILD_ROOTFS=false
SYNC_SOURCE=false
BUILD_KERNEL=false
BUILD_MODULES=false
BUILD_DTBS=false
UPDATE_BOOTLOADER=false
FLASH_BOOTLOADER_DTB=false
MAKE_MFI=false
FLASH_DEVICE=false
ROOTFS_FLAVOR="desktop"
DEFAULT_USER="nvidia"
DEFAULT_PASS="nvidia"
FORCE_ROOTFS=false   # 單獨 -R 時設為 true，強制重建即使已存在
FORCE_SYNC=false     # 單獨 -S 時設為 true，強制重新 sync
MFI_MASSFLASH_NUM=5  # MFI 同時燒錄裝置數量，預設 5

# -----------------------------------------------------------------------------
# 解析參數
# -----------------------------------------------------------------------------
[ $# -eq 0 ] && usage

while getopts "RSKMDBTIFr:u:p:m:j:a" arg; do
    case $arg in
        R) BUILD_ROOTFS=true; FORCE_ROOTFS=true ;;
        S) SYNC_SOURCE=true;  FORCE_SYNC=true  ;;
        K) BUILD_KERNEL=true   ;;
        M) BUILD_MODULES=true  ;;
        D) BUILD_DTBS=true     ;;
        B) UPDATE_BOOTLOADER=true ;;
        T) FLASH_BOOTLOADER_DTB=true ;;
        I) MAKE_MFI=true ;;
        F) FLASH_DEVICE=true   ;;
        r) ROOTFS_FLAVOR=$OPTARG ;;
        u) DEFAULT_USER=$OPTARG  ;;
        p) DEFAULT_PASS=$OPTARG  ;;
        m) MFI_MASSFLASH_NUM=$OPTARG ;;
        j) BUILD_JOBS=$OPTARG    ;;
        a)
            BUILD_ROOTFS=true
            SYNC_SOURCE=true
            BUILD_KERNEL=true
            BUILD_MODULES=true
            BUILD_DTBS=true
            ;;
        ?) usage ;;
    esac
done

# -----------------------------------------------------------------------------
# 環境檢查
# CROSS_COMPILE 解析優先順序：
#   1. 環境變數 CROSS_COMPILE 已設定（e.g. docker-compose 直接注入）
#   2. TOOLCHAIN_PATH 目錄存在（e.g. docker-compose 1 掛載 toolchain 目錄）
#   3. PATH 上找得到 aarch64-buildroot-linux-gnu-gcc（系統安裝）
#   4. PATH 上找得到 aarch64-linux-gnu-gcc（Ubuntu 套件 gcc-aarch64-linux-gnu）
#   都找不到 → die
# -----------------------------------------------------------------------------
check_env() {
    log_info "檢查編譯環境..."

    [ -d "${L4T_PATH}" ] || die "Linux_for_Tegra 不存在: ${L4T_PATH}"

    if [ -n "${CROSS_COMPILE:-}" ]; then
        # 情況 1：外部已注入（docker-compose 2 的做法），直接沿用
        log_info "使用環境變數 CROSS_COMPILE"

    elif [ -d "${TOOLCHAIN_PATH}" ]; then
        # 情況 2：toolchain 目錄掛載存在（docker-compose 1 的做法）
        export CROSS_COMPILE="${TOOLCHAIN_PATH}/bin/aarch64-buildroot-linux-gnu-"
        log_info "使用 TOOLCHAIN_PATH: ${TOOLCHAIN_PATH}"

    elif command -v aarch64-buildroot-linux-gnu-gcc >/dev/null 2>&1; then
        # 情況 3：PATH 上有 bootlin toolchain
        local _bin
        _bin="$(dirname "$(command -v aarch64-buildroot-linux-gnu-gcc)")"
        export CROSS_COMPILE="${_bin}/aarch64-buildroot-linux-gnu-"
        log_info "從 PATH 找到 bootlin toolchain: ${_bin}"

    elif command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
        # 情況 4：PATH 上有 Ubuntu 套件 gcc-aarch64-linux-gnu
        local _bin
        _bin="$(dirname "$(command -v aarch64-linux-gnu-gcc)")"
        export CROSS_COMPILE="${_bin}/aarch64-linux-gnu-"
        log_info "從 PATH 找到 aarch64-linux-gnu toolchain: ${_bin}"

    else
        die "找不到 aarch64 cross toolchain。\n請確認：\n  (1) docker-compose 已設定 CROSS_COMPILE 環境變數，或\n  (2) toolchain 目錄已掛載至 ${TOOLCHAIN_PATH}，或\n  (3) 已安裝 gcc-aarch64-linux-gnu 套件"
    fi

    # 驗證 CROSS_COMPILE 可執行
    local _cc="${CROSS_COMPILE}gcc"
    [ -x "${_cc}" ] || die "CROSS_COMPILE 指向的 gcc 不可執行: ${_cc}"

    export KERNEL_HEADERS="${SOURCE_PATH}/kernel/kernel-jammy-src"
    export INSTALL_MOD_PATH="${ROOTFS_PATH}"

    log_ok "CROSS_COMPILE    = ${CROSS_COMPILE}"
    log_ok "KERNEL_HEADERS   = ${KERNEL_HEADERS}"
    log_ok "INSTALL_MOD_PATH = ${INSTALL_MOD_PATH}"
}

# -----------------------------------------------------------------------------
# 檢查 RootFS 是否已建置
# 判斷依據：rootfs/bin/bash 存在（基本系統已解壓）
#           且 rootfs/etc/nv_tegra_release 存在（apply_binaries 已執行）
#           且 rootfs/etc/passwd 包含自訂使用者（預設使用者已建立）
# -----------------------------------------------------------------------------
is_rootfs_built() {
    local ROOTFS_MARKER_BASE="${ROOTFS_PATH}/bin/bash"
    local ROOTFS_MARKER_NV="${ROOTFS_PATH}/etc/nv_tegra_release"
    local ROOTFS_MARKER_USER="${ROOTFS_PATH}/etc/passwd"

    if [ ! -f "${ROOTFS_MARKER_BASE}" ]; then
        log_warn "RootFS 尚未解壓（找不到 rootfs/bin/bash）"
        return 1
    fi

    if [ ! -f "${ROOTFS_MARKER_NV}" ]; then
        log_warn "apply_binaries 尚未執行（找不到 rootfs/etc/nv_tegra_release）"
        return 1
    fi

    if ! grep -q "^${DEFAULT_USER}:" "${ROOTFS_MARKER_USER}" 2>/dev/null; then
        log_warn "預設使用者 '${DEFAULT_USER}' 尚未建立（rootfs/etc/passwd 無此帳號）"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# 檢查 Kernel Source 是否已 sync
# 判斷依據：kernel-jammy-src/Makefile 存在（主 Makefile 代表 git clone 完成）
#           且 .git/HEAD 指向正確 tag
# -----------------------------------------------------------------------------
is_source_synced() {
    local KERNEL_SRC="${SOURCE_PATH}/kernel/kernel-jammy-src"
    local KERNEL_MK="${KERNEL_SRC}/Makefile"

    if [ ! -f "${KERNEL_MK}" ]; then
        log_warn "Kernel source 尚未 sync（找不到 ${KERNEL_MK}）"
        return 1
    fi

    # 確認 git tag 是否符合（kernel-jammy-src 是子目錄 repo）
    local CURRENT_TAG
    CURRENT_TAG=$(git -C "${KERNEL_SRC}" describe --tags --exact-match 2>/dev/null || echo "unknown")
    if [ "${CURRENT_TAG}" = "unknown" ]; then
        log_warn "Kernel source 無法確認 tag，視為已 sync，若有問題請手動執行 -S"
        return 0
    fi

    # RELEASE_TAG 為 "jetson_36.5"，kernel repo tag 格式相同
    if echo "${CURRENT_TAG}" | grep -q "${RELEASE_TAG}"; then
        return 0
    else
        log_warn "Kernel source tag 為 '${CURRENT_TAG}'，與目標 '${RELEASE_TAG}' 不符"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Step 1: Build RootFS
# -----------------------------------------------------------------------------
build_rootfs() {
    log_info "========== Step 1: 建立 Root File System (flavor: ${ROOTFS_FLAVOR}) =========="

    # 使用 -a 時自動跳過；單獨 -R 時強制重建
    if [ "${FORCE_ROOTFS}" != "true" ] && is_rootfs_built; then
        log_ok "RootFS 已建置完成（使用者: ${DEFAULT_USER}），跳過此步驟"
        log_warn "若需強制重建，請單獨執行 ./build.sh -R"
        return 0
    fi

    local SAMPLEFS_DIR="${L4T_PATH}/tools/samplefs"
    [ -d "${SAMPLEFS_DIR}" ] || die "找不到 samplefs 目錄: ${SAMPLEFS_DIR}"

    cd "${SAMPLEFS_DIR}" || die "無法進入 ${SAMPLEFS_DIR}"

    log_info "1-1: 產生 RootFS..."
    sudo ./nv_build_samplefs.sh \
        --abi aarch64 \
        --distro ubuntu \
        --flavor "${ROOTFS_FLAVOR}" \
        --version jammy || die "nv_build_samplefs.sh 失敗"

    log_info "1-2: 解壓 sample_fs.tbz2 至 rootfs/..."
    sudo tar -jxpf sample_fs.tbz2 -C ../../rootfs/ || die "解壓 rootfs 失敗"

    log_info "1-3: 套用 NVIDIA 驅動 (apply_binaries.sh)..."
    cd "${L4T_PATH}" || die "無法進入 ${L4T_PATH}"
    sudo ./apply_binaries.sh || die "apply_binaries.sh 失敗"

    log_info "1-4: 建立預設使用者 (${DEFAULT_USER})..."
    sudo ./tools/l4t_create_default_user.sh \
        -u "${DEFAULT_USER}" \
        -p "${DEFAULT_PASS}" || die "l4t_create_default_user.sh 失敗"

    log_ok "RootFS 建立完成"
}

# -----------------------------------------------------------------------------
# Step 2: Sync Kernel Source
# -----------------------------------------------------------------------------
sync_source() {
    log_info "========== Step 2: 同步 Kernel 原始碼 (tag: ${RELEASE_TAG}) =========="

    # 使用 -a 時自動跳過；單獨 -S 時強制重新 sync
    if [ "${FORCE_SYNC}" != "true" ] && is_source_synced; then
        log_ok "Kernel source 已同步（tag: ${RELEASE_TAG}），跳過此步驟"
        log_warn "若需強制重新 sync，請單獨執行 ./build.sh -S"
        return 0
    fi

    [ -d "${SOURCE_PATH}" ] || die "找不到 source 目錄: ${SOURCE_PATH}"
    cd "${SOURCE_PATH}" || die "無法進入 ${SOURCE_PATH}"

    ./source_sync.sh -t "${RELEASE_TAG}" || die "source_sync.sh 失敗"

    log_ok "Kernel 原始碼同步完成"
}

# -----------------------------------------------------------------------------
# Step 3: Build Kernel
# -----------------------------------------------------------------------------
build_kernel() {
    log_info "========== Step 3: 編譯 Kernel =========="

    [ -d "${SOURCE_PATH}" ] || die "找不到 source 目錄: ${SOURCE_PATH}"
    cd "${SOURCE_PATH}" || die "無法進入 ${SOURCE_PATH}"

    make -C kernel -j"${BUILD_JOBS}" || die "Kernel 編譯失敗"

    log_info "安裝 Kernel 及 In-tree Modules..."
    sudo -E make install -C kernel || die "Kernel install 失敗"

    log_info "複製 Image 至 ${L4T_PATH}/kernel/Image..."
    cp kernel/kernel-jammy-src/arch/arm64/boot/Image \
        "${L4T_PATH}/kernel/Image" || die "複製 Image 失敗"

    log_ok "Kernel 編譯安裝完成"
}

# -----------------------------------------------------------------------------
# Step 4: Build & Install Out-of-Tree Modules
# -----------------------------------------------------------------------------
build_modules() {
    log_info "========== Step 4: 編譯並安裝 NVIDIA Out-of-Tree Modules =========="

    [ -d "${SOURCE_PATH}" ] || die "找不到 source 目錄: ${SOURCE_PATH}"
    cd "${SOURCE_PATH}" || die "無法進入 ${SOURCE_PATH}"

    log_info "編譯 OOT modules..."
    make modules -j"${BUILD_JOBS}" || die "modules 編譯失敗"

    log_info "安裝 OOT modules 至 ${ROOTFS_PATH}..."
    sudo -E make modules_install || die "modules_install 失敗"

    log_info "更新 initramfs..."
    cd "${L4T_PATH}" || die "無法進入 ${L4T_PATH}"
    sudo ./tools/l4t_update_initrd.sh || die "l4t_update_initrd.sh 失敗"

    log_ok "Out-of-Tree Modules 安裝完成"
}

# -----------------------------------------------------------------------------
# Step 5: Build DTBs
# -----------------------------------------------------------------------------
build_dtbs() {
    log_info "========== Step 5: 編譯 DTBs =========="

    [ -d "${SOURCE_PATH}" ] || die "找不到 source 目錄: ${SOURCE_PATH}"
    cd "${SOURCE_PATH}" || die "無法進入 ${SOURCE_PATH}"

    make dtbs -j"${BUILD_JOBS}" || die "DTB 編譯失敗"

    log_info "複製 DTBs 至 ${L4T_PATH}/kernel/dtb/..."
    cp kernel-devicetree/generic-dts/dtbs/* \
        "${L4T_PATH}/kernel/dtb/" || die "複製 DTBs 失敗"

    log_ok "DTBs 編譯完成"
    log_warn "提醒：請確認 tegra234-p3737-0000+p3701-0005-nv.dtb 已正確複製至 kernel/dtb/"
}

# -----------------------------------------------------------------------------
# Step 6: Update Bootloader (更新 Bootloader 目錄檔案)
# -----------------------------------------------------------------------------
update_bootloader() {
    log_info "========== Step 6: 更新 Bootloader 目錄檔案 =========="

    cd "${L4T_PATH}" || die "無法進入 ${L4T_PATH}"

    log_info "執行 flash.sh --no-flash 更新 Bootloader 目錄..."
    sudo ./flash.sh --no-flash jetson-agx-orin-devkit external || die "Bootloader 更新失敗"

    log_ok "Bootloader 目錄檔案更新完成"
}

# -----------------------------------------------------------------------------
# Step 7: Flash Bootloader DTB (燒錄 Bootloader DTB 到裝置)
# -----------------------------------------------------------------------------
flash_bootloader_dtb() {
    log_info "========== Step 7: 燒錄 Bootloader DTB 到裝置 =========="

    cd "${L4T_PATH}" || die "無法進入 ${L4T_PATH}"

    # 檢查 L4TConfiguration.dtbo 是否存在
    local DTBO_PATH="${L4T_PATH}/bootloader/L4TConfiguration.dtbo"
    if [ ! -f "${DTBO_PATH}" ]; then
        log_error "找不到 ${DTBO_PATH}"
        log_info "請先執行以下步驟："
        log_info "  1. ./build.sh -D    # 編譯 DTB"
        log_info "  2. ./build.sh -B    # 更新 Bootloader 目錄"
        die "缺少 L4TConfiguration.dtbo，無法燒錄 Bootloader DTB"
    fi

    log_info "找到 L4TConfiguration.dtbo: ${DTBO_PATH}"
    
    # 顯示 dtbo 資訊（可選）
    if command -v dtc >/dev/null 2>&1; then
        log_info "DTBO 資訊："
        dtc -I dtb -O dts "${DTBO_PATH}" 2>/dev/null | grep -A 5 "gNVIDIATokenSpaceGuid" || true
    fi

    log_info "執行 flash.sh --no-systemimg -k A_cpu-bootloader 燒錄 Bootloader DTB..."
    sudo ./flash.sh --no-systemimg -k A_cpu-bootloader jetson-agx-orin-devkit internal || die "Bootloader DTB 燒錄失敗"

    log_ok "Bootloader DTB 燒錄完成"
    log_warn "注意：如果 boot 順序有問題，請檢查 L4TConfiguration.dtbo 中的 gNVIDIATokenSpaceGuid 設定"
    log_warn "      - data = 'boot.img' : 從 eMMC 開機"
    log_warn "      - data = 'external' : 從外部儲存裝置開機"
}

# -----------------------------------------------------------------------------
# Step 8: Make MFI Massflash Package
# -----------------------------------------------------------------------------
make_mfi() {
    log_info "========== Step 8: 製作 MFI 線刷包 (Massflash Package) =========="
    log_info "目標裝置數量: ${MFI_MASSFLASH_NUM}"

    cd "${L4T_PATH}" || die "無法進入 ${L4T_PATH}"

    log_info "產生 MFI 線刷包 (此過程可能需要數分鐘)..."
    sudo ./tools/kernel_flash/l4t_initrd_flash.sh --no-flash \
        --network usb0 --massflash "${MFI_MASSFLASH_NUM}" \
        -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
        --external-device nvme0n1p1 \
        -c ./tools/kernel_flash/flash_l4t_t234_nvme.xml \
        --append \
        jetson-agx-orin-devkit external || die "MFI 線刷包製作失敗"

    # 檢查 MFI 檔案是否成功產生
    local MFI_FILE="${L4T_PATH}/mfi_jetson-agx-orin-devkit.tar.gz"
    if [ -f "${MFI_FILE}" ]; then
        log_ok "MFI 線刷包已成功產生: ${MFI_FILE}"
        local MFI_SIZE
        MFI_SIZE=$(du -h "${MFI_FILE}" | cut -f1)
        log_info "檔案大小: ${MFI_SIZE}"
        log_info ""
        log_info "後續燒錄步驟："
        log_info "  1. cd ${L4T_PATH}"
        log_info "  2. sudo tar -xvf mfi_jetson-agx-orin-devkit.tar.gz"
        log_info "  3. cd mfi_jetson-agx-orin-devkit/"
        log_info "  4. sudo ./tools/kernel_flash/l4t_initrd_flash.sh --flash-only --network usb0 --massflash ${MFI_MASSFLASH_NUM}"
        log_info ""
        log_warn "注意：將裝置置於 Recovery 模式後再執行燒錄"
    else
        die "MFI 線刷包產生失敗，找不到 ${MFI_FILE}"
    fi

    log_ok "MFI 線刷包製作完成"
}

# -----------------------------------------------------------------------------
# 偵測是否在 Docker 容器內執行
# 判斷依據（三擇一即成立）：
#   1. /.dockerenv 存在（Docker 標準標記檔）
#   2. /proc/1/cgroup 內含 "docker" 字串
#   3. 環境變數 container=docker（部分 compose 設定會注入）
# -----------------------------------------------------------------------------
is_in_docker() {
    [ -f /.dockerenv ] && return 0
    grep -qsi "docker" /proc/1/cgroup 2>/dev/null && return 0
    [ "${container:-}" = "docker" ] && return 0
    return 1
}

# -----------------------------------------------------------------------------
# Step 9: Flash Device
# -----------------------------------------------------------------------------
flash_device() {
    log_info "========== Step 9: 燒錄裝置 =========="

    cd "${L4T_PATH}" || die "無法進入 ${L4T_PATH}"

    if is_in_docker; then
        log_warn "偵測到 Docker 環境"
        log_warn "nvsdkmanager_flash.sh 依賴 NFS，在容器內會因 rpcbind 衝突而失敗"
        log_info "改用 l4t_initrd_flash.sh（純 USB 傳輸，會完全抹除並重灌 NVMe）..."
        
        sudo ./tools/kernel_flash/l4t_initrd_flash.sh \
            --external-device nvme0n1p1 \
            -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
            -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" \
            --showlogs \
            jetson-agx-orin-devkit internal || die "Docker 環境下燒錄失敗"
    else
        log_info 'Host 環境，使用 l4t_initrd_flash.sh 燒錄 (NVMe)...'
        sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
            --flash-only \
            -c tools/kernel_flash/flash_l4t_t234_nvme.xml \
            -p "-c bootloader/generic/cfg/flash_t234_qspi.xml --no-systemimg" \
            --network usb0 \
            --showlogs \
            jetson-agx-orin-devkit external
    fi

    log_ok "燒錄完成"
}

# -----------------------------------------------------------------------------
# 主流程
# -----------------------------------------------------------------------------
START_TIME=$(date +%s)

check_env

# 依照順序執行各步驟
$BUILD_ROOTFS  && build_rootfs
$SYNC_SOURCE   && sync_source
$BUILD_KERNEL  && build_kernel
$BUILD_MODULES && build_modules
$BUILD_DTBS    && build_dtbs
$UPDATE_BOOTLOADER && update_bootloader
$FLASH_BOOTLOADER_DTB && flash_bootloader_dtb
$MAKE_MFI      && make_mfi
$FLASH_DEVICE  && flash_device

END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))
MINUTES=$(( ELAPSED / 60 ))
SECONDS=$(( ELAPSED % 60 ))

echo ""
log_ok "======================================"
log_ok " 全部完成！耗時: ${MINUTES}m ${SECONDS}s"
log_ok "======================================"
