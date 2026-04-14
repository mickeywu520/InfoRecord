# 蓝牙HID——将android设备变成蓝牙键盘（BluetoothHidDevice）
- https://blog.csdn.net/CJohn1994/article/details/125108065
---
# IPV6 static IP settings.
- https://guiderworld.blogspot.com/2012/02/linuxipv6.html
---
# check desktop system(linux)
loginctl show-session 2 -p Type 
---
# Turn off ubuntu 22.04 auto suspend by command
---
## Disable autosuspend when on AC power
```
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
```
---
## Disable autosuspend when on battery power
```
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
```
---
# Using below cmmand to disable menu
- https://www.tecmint.com/disable-suspend-and-hibernation-in-linux/
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```
---
# [Ubuntu 22.04] IPV6 SLAAC with NetworkManager
## Go to ethernet settings and changed the connection method to link-local only
```
/etc/NetworkManager/system-connections
```
---
# [ipv6]
```
addr-gen-mode=eui64
dhcp-timeout=60
ip6-privacy=0
method=link-local
```
---
```
Port forwarding - socat
sudo apt-get install socat
sudo socat TCP4-LISTEN:XXX,fork,reuseaddr TCP4:192.168.1.102:80
```
---
# [LVDS]
```
----------------------------------------------------------------------
Signal      Item        Symbol                 Min      Typ      Max    Unit
----------------------------------------------------------------------
Vertical   | Period     | Tv                   | 1032   1066    1150    Th
Section    | Active     | Tdisp(v)             | 1024   1024    1024    Th 
           | Blanking   | Tbp(v)+Tfp(v)+PWvs   | 8      42      126     Th
----------------------------------------------------------------------
Horizontal | Period     | Th                   | 780    844    2048     Tclk
Section    | Active     | Tdisp(h)             | 640    640    640      Tclk
           | Blanking   | Tbp(h)+Tfp(h)+PWhs   | 140    204    1408     Tclk
----------------------------------------------------------------------
Clock      | Period     | Tclk                 | 14.81  18.52  25       ns  
           | Frequency  | Freq                 | 40     54     67.5     MHz
----------------------------------------------------------------------
Frame rate | Frame rate | F                    | 50     60     75       Hz
----------------------------------------------------------------------
```
## 上圖中，Vertical section blanking=42, Horizontal section blanking=204,在填充6個參數時只需要滿足關係：vbp+vfp+vs=42,hbp+hfp+hs=204,各值自行分配(通常hbp 和vbp取較大值),例如
```
hback-porch = <150>;
hfront-porch = <50>;
vback-porch = <30>;
vfront-porch = <11>;
hsync-len = <4>;
vsync-len = <1>;
```
---
## [Control gpio in uboot (NXP example)]
```
gpio status -a #List所有GPIO
gpio toggle GPIO5_20 #更換GPIO方向
gpio set GPIO5_20 1 #設定GPIO輸出為high
gpio clear GPIO5_20 #設定GPIO輸出為low
```
## [gpio command in uboot]
```
https://docs.u-boot.org/en/latest/usage/cmd/gpio.html
```
## if no gpio command in uboot, please enable below flag
```
CONFIG_CMD_GPIO=y
```
---
# Test POST by MINGW64
```
curl -X 'POST' 'http://localhost:3090/api/hello2?name=aaaaaaaaaaaaa' -H 'accept: text/plain; charset=utf-8' -d ''
```
---
# OSCP备忘单示例 Example Cheat Sheet
```
https://www.ddosi.org/oscp-cheat-sheet-2/
```
---
# Wake Your Linux PC From Suspend With a USB Mouse or Keyboard
- 1. find out your USB "device ID"
  Ex: $ lsusb
  show: Bus 001 Device 006: ID 0000:3825 USB OPTICAL MOUSE
- 2. find out the device node
  grep "device ID" /sys/bus/usb/devices/*/idProduct
  Ex: $ grep 3825 /sys/bus/usb/devices/*/idProduct
  Show: /sys/bus/devices/1-1/idProduct:3825
- 3. find out the wakeup value
  Ex: $ cat /sys/bus/devices/1-1/power/wakeup
  Show: disabled
- 4. Set wakeup to Enable
  Ex: sudo echo enabled > /sys/bus/usb/devices/1-1/power/wakeup
## Refer
https://www.makeuseof.com/wake-your-linux-pc-from-suspend-using-usb-devices/
---
# [經驗] RK3399 Android支援wifi/4G與乙太網路共存的解決過程與方法
```
https://bbs.elecfans.com/jishu_2280127_1_1.html
```
---
# Jenkins-Android原始碼編譯【架構設計】（適用鴻蒙/自動化/多產品/持續迭代）
```
https://blog.csdn.net/dengtonglong/article/details/136512728
```
---
# Anydesk cannot unlock security(ubuntu 22.04) 
```
sudo vi /etc/gdm3/custom.conf
```
- [daemon] Uncomment the line below to force the login screen to use Xorg
```
WaylandEnable=false
```
---
# RK356x & RK3399 Android 12 GMS
```
https://blog.csdn.net/qq_46524402/article/details/132018105
```
---
# 2016
```
T9NBK-Q6DM2-RJHDQ-RKFVJ-VH7B2
```
---
# 356x SDK
```
FTP address: ftp://ftp.rock-chips.com	
Connection type: Ftp
Port number: 998
FTP account: arborbu5
FTP password: c867e9cd
```
---
# Virtual box 7.0 cannot open terminal
 - changed the line of /etc/default/locale file to LANG=en_US.UTF-8 and rebooted.
 - If you dont have privilleges to change it, you can Alt+F2 and write gedit admin:/etc/default/locale
---
# ESXi Download
https://support.broadcom.com/group/ecx/downloads
---
# Google Drive
帳號: HQPS@arbor.com.tw
密碼: ArborFAE999
---
# fdisk
After fdisk new partition, don't forget to resise2fs the new partition to marge the /dev/root
Ex: resize2fs /dev/mmcblk0p2
---
# [x86 ubuntu 22.04 install rtx3070]
```
sudo apt update
sudo apt install ubuntu-drivers-common
sudo ubuntu-drivers devices
Ex:
$ sudo ubuntu-drivers devices
== /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
modalias : pci:v000010DEd00002484sv0000107Dsd00002791bc03sc00i00
vendor   : NVIDIA Corporation
model    : GA104 [GeForce RTX 3070]
driver   : nvidia-driver-535-server-open - distro non-free
driver   : nvidia-driver-470-server - distro non-free
driver   : nvidia-driver-545 - distro non-free
driver   : nvidia-driver-535 - distro non-free
driver   : nvidia-driver-535-server - distro non-free
driver   : nvidia-driver-535-open - distro non-free
driver   : nvidia-driver-550-open - distro non-free recommended
driver   : nvidia-driver-550 - distro non-free
driver   : nvidia-driver-545-open - distro non-free
driver   : nvidia-driver-470 - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
sudo apt install nvidia-driver-550-open
sudo reboot
sudo nvidia-smi
```
- Ex:
```
$ nvidia-smi
Thu Feb 13 10:54:15 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.120                Driver Version: 550.120        CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3070        Off |   00000000:01:00.0  On |                  N/A |
| 31%   27C    P8             13W /  220W |     173MiB /   8192MiB |      6%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A      1233      G   /usr/lib/xorg/Xorg                             82MiB |
|    0   N/A  N/A      1566      G   /usr/bin/gnome-shell                           75MiB |
+-----------------------------------------------------------------------------------------+
```
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-6

nano ~/.bashrc
# paste the following lines at the end of the file.
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64\
                         ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

. ~/.bashrc
nvcc -V
```
## refer:
```
https://www.cherryservers.com/blog/install-cuda-ubuntu
```
---
# Markdown translator
- Free-Markdown-Translator
```
https://github.com/CrazyMayfly/Free-Markdown-Translator
```
---
# C# 軟體Licence應用實例
```
https://blog.csdn.net/fengershishe/article/details/132653311
```
---
# Speech VLM
```
https://wiki.seeedstudio.com/cn/speech_vlm/
https://github.com/ZhuYaoHui1998/speech_vlm
```
---
# Postfix 
## Install postfix
```
sudo apt install postfix
```
## Restart postfix
```
sudo systemctl restart postfix
```
## Config file
```
/etc/postfix/main.cf
```
## Example
```
# See /usr/share/postfix/main.cf.dist for a commented, more complete version


# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
myorigin = /etc/mailname

smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# See http://www.postfix.org/COMPATIBILITY_README.html -- default to 3.6 on
# fresh installs.
compatibility_level = 3.6



# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level=may

smtp_tls_CApath=/etc/ssl/certs
smtp_tls_security_level=may
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache


smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = rfq.mail.alert
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = $myhostname, localhost.localdomain, localhost
relayhost = [mail.arbor.com.tw]:25
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 192.168.0.0/24 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4
```
---
# Windows 11 25H2 建立本機帳號
在「請我們將您連線到網路」畫面時，按 Shift + F10 組合鍵，開啟命令提示字元視窗。輸入 
```
start ms-cxh:localonly
```
---
# 測試延遲
- In windows powershell
```
(myvenv) PS C:\Users\mickey\Desktop\python\rtsp> curl.exe -o NUL -s -w "DNS:%{time_namelookup}s Connect:%{time_connect}s TTFB:%{time_starttransfer}s Total:%{time_total}s`n" `
>> https://mickeywu520-inventory-fastapi.hf.space/
DNS:0.018018s Connect:0.223967s TTFB:1.143879s Total:1.143961s
(myvenv) PS C:\Users\mickey\Desktop\python\rtsp>
```
- 測試網頁
1. Oracle OCI(VPS)
```
https://cloudpingtest.com/oracle
```
2. GCP(VPS)
```
https://www.gcping.com/
```
3. Vultr(VPS)
```
https://sgp-ping.vultr.com/
```
4. AWS(VPS)
```
https://aws-latency-test.com/
```
5. Azure(VPS)
```
https://www.azurespeed.com/Azure/Latency
```
---
# llama.cpp

- if encounter the error: No CMAKE_CXX_COMPILER could be found.
Check the gcc & g++ version, and both must be the same version.
```
gcc --version
g++ --version
```
- adjust the g++ version
```
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
sudo update-alternatives --config g++
```
- fixed error "update-alternatives: error: alternative g++ can't be master: it is a slave of gcc"
```
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-12
```
- build llama.cpp
```
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build
cmake --build build --config Release -j 8
```
- Download the gguf model via unsloth on huggingface
Ex:
```
https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF
```
- launch llama.cpp with CPU only
```
./build/bin/llama-server \
  --model ../models/gemma-4-E4B-it-Q4_K_M.gguf \
  --alias gemma-4-E4B \
  --ctx-size 8192 \
  --threads 20 \
  --batch-size 512 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --host 0.0.0.0 \
  --port 8080 \
  --mlock \
  --jinja
```
- update server settings
```
# 1. 設定 CPU 為效能模式（重開機後失效，建議寫入 /etc/rc.local 或 systemd service）
sudo cpupower frequency-set -g performance

# 2. 關閉透明大頁面的非同步回收（可減少記憶體碎片與延遲）
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# 3. 確認記憶體通道是否插滿（關鍵！）
sudo dmidecode -t memory | grep -E "Size|Configured Clock Speed|Locator" | head -20
```
- update llama.cpp & build
```
# 1. 拉取最新版（包含 NUMA、KV量化、CPU 推論優化）
git pull origin master

# 2. 徹底清除舊編譯檔（關鍵！）
rm -rf build

# 3. 重新設定編譯（啟用 AVX2/FMA 與 Flash Attention 支援）
cmake -B build \
  -DLLAMA_AVX2=ON \
  -DLLAMA_F16C=ON \
  -DLLAMA_FMA=ON \
  -DLLAMA_AVX=ON \
  -DLLAMA_FLASH_ATTN=ON \
  -DCMAKE_BUILD_TYPE=Release

# 3.1 Added CUDA and RPC on Jetson orin series
cmake -B build \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES=87 \
  -DLLAMA_FLASH_ATTN=ON \
  -DGGML_CUDA_F16=ON \
  -DGGML_RPC=ON \
  -DCMAKE_BUILD_TYPE=Release
```
# 4. 編譯
```
cmake --build build -j$(nproc) --config Release
```
- update llama-server launch command
```
./build/bin/llama-server \
  --model ../models/gemma-4-E4B-it-Q4_K_M.gguf \
  --alias gemma-4-E4B \
  --ctx-size 8192 \
  --threads 20 \
  --batch-size 512 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --numa isolate \
  --host 0.0.0.0 \
  --port 8080 \
  --mlock \
  --jinja

Or

MALLOC_ARENA_MAX=1 numactl --cpunodebind=0 --membind=0 ./build/bin/llama-server \
  --model ../models/gemma-4-E4B-it-Q4_K_M.gguf \
  --alias gemma-4-E4B \
  --ctx-size 8192 \
  --threads 20 \
  --batch-size 512 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --numa isolate \
  --host 0.0.0.0 \
  --port 8080 \
  --mlock \
  --jinja

Or with CUDA

 ./build/bin/llama-server \
  --model ../models/gemma-4-E4B-it-Q4_K_M.gguf \
  --alias gemma-4-E4B \
  --ctx-size 32768 \
  --batch-size 256 \
  --n-gpu-layers 999 \
  --parallel 1 \
  --cache-type-k q4_0 \
  --cache-type-v q4_0 \
  --host 0.0.0.0 \
  --port 8080 \
  --jinja \
  --verbose
```
- 紀錄
```
--cpunodebind=0 / 僅允許程序在 Node 0 (Socket 0) 的 20 個邏輯核心上排程
--membind=0 / 強制所有 malloc/mmap 僅從 Node 0 的記憶體分配
--threads 20 / 必須匹配 Node 0 的邏輯核心數。若設 40，多出的 20 執行緒會因節點限制產生排程衝突與 Context Switch 罰款
--numa isolate + 雙節點記憶體 / 6.5 ~ 8.5 t/s / 跨節點存取拖累頻寬
numactl --membind=0 + --threads 20 / 9.5 ~ 12.5 t/s / ✅ 推薦，記憶體頻寬集中，無 QPI 延遲
--numa distribute + --threads 40 / 8.0 ~ 10.0 t/s / 適合模型 > 單節點 RAM 容量時
```
- Error Msg:
```
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
update-alternatives: error: alternative g++ can't be master: it is a slave of gcc
```
- Error Msg:
```
cmake -B build
-- The CXX compiler identification is unknown
CMake Error at CMakeLists.txt:2 (project):
  No CMAKE_CXX_COMPILER could be found.

  Tell CMake where to find the compiler by setting either the environment
  variable "CXX" or the CMake cache entry CMAKE_CXX_COMPILER to the full path
  to the compiler, or to the compiler name if it is in the PATH.


-- Configuring incomplete, errors occurred!
```
---

