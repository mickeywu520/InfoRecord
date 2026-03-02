#!/bin/bash

set -e

echo "=============================="
echo " USB Read / Write Speed Test"
echo "=============================="
echo

# -------- 1. 安裝 fio --------
if ! command -v fio >/dev/null 2>&1; then
    echo "[INFO] fio not found, installing..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y fio
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y fio
    else
        echo "[ERROR] Unsupported package manager"
        exit 1
    fi
else
    echo "[OK] fio already installed"
fi

echo

# -------- 2. 偵測 USB 掛載點 --------
USB_MOUNT=$(lsblk -o RM,MOUNTPOINT -nr | awk '$1=="1" && $2!="" {print $2; exit}')

if [ -z "$USB_MOUNT" ]; then
    echo "[ERROR] No mounted USB device detected"
    exit 1
fi

echo "[OK] Detected USB mount point:"
echo "     $USB_MOUNT"
echo
echo "⚠️  Write test will create temporary test files (~256MB total)"
echo

# -------- 3. 等待使用者 --------
read -n 1 -s -r -p "Press any key to start test..."
echo
echo

# -------- 4. Write Test --------
echo "[TEST] Write speed testing..."

WRITE_MB=$(fio \
 --ioengine=libaio \
 --direct=1 \
 --bs=1M \
 --size=128M \
 --directory="$USB_MOUNT" \
 --group_reporting \
 --name=job1 --rw=write \
 --name=job2 --rw=write \
 2>/dev/null | \
grep -i 'bw=' | head -n 1 | sed -n 's/.*bw=\([0-9]*\)KB\/s.*/\1/p' | \
awk '{printf "%.2f", $1/1024}')

# -------- 5. Read Test --------
echo "[TEST] Read speed testing..."

READ_MB=$(fio \
 --ioengine=libaio \
 --direct=1 \
 --bs=1M \
 --size=128M \
 --directory="$USB_MOUNT" \
 --group_reporting \
 --name=job1 --rw=read \
 --name=job2 --rw=read \
 2>/dev/null | \
grep -i 'bw=' | head -n 1 | sed -n 's/.*bw=\([0-9]*\)KB\/s.*/\1/p' | \
awk '{printf "%.2f", $1/1024}')

# -------- 6. 顯示結果 --------
echo
echo "=============================="
echo " Test Result (MB/s)"
echo "=============================="
echo " Write Speed : $WRITE_MB MB/s"
echo " Read  Speed : $READ_MB MB/s"
echo "=============================="
echo

