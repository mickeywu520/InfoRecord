# 使用 Ubuntu 16.04 以確保與 Android 7.1.2 BSP 編譯環境的相容性
FROM ubuntu:16.04

# 設定環境變數：避免在 apt-get 安裝過程中出現互動式選擇視窗（防止自動化建置中斷）
ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------
# 1. 安裝 Android 7.1.2 編譯所需的基礎相依套件與工具
# ---------------------------------------------------------------------
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    git-core gnupg flex bison gperf build-essential \
    zip curl zlib1g-dev gcc-multilib g++-multilib \
    libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev \
    libx11-dev lib32z-dev ccache libgl1-mesa-dev \
    libxml2-utils xsltproc unzip openjdk-8-jdk \
    python-markdown gettext genisoimage wget sudo bc lzop

# 將系統預設的 Java 版本切換至 OpenJDK 8（Android 7.1 強制要求）
RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

# 解除 OpenJDK 8 對 TLSv1 與 TLSv1.1 的禁用限制，修復 Jack Server SSL 錯誤
RUN sed -i 's/TLSv1, TLSv1.1,//g' /etc/java-8-openjdk/security/java.security

# ---------------------------------------------------------------------
# 2. 安裝原始碼管理工具 Repo (修正原 Dockerfile 的下載與權限設定)
# ---------------------------------------------------------------------
RUN curl googleapis.com > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

# ---------------------------------------------------------------------
# 3. 權限修復核心：動態同步宿主機與容器內的用戶 UID/GID
# ---------------------------------------------------------------------
# 定義建置參數，預設值設為 1001 (對應您宿主機 mickey 的 UID/GID)。
# 可在執行 docker build 時透過 --build-arg 動態帶入目前的用戶 ID。
ARG USER_ID=1001
ARG GROUP_ID=1001

# 建立與宿主機相同 GID 的群組，並建立相同 UID 的用戶 `android`
# 同時將該用戶加入 sudoer 列表中，允許免密碼執行 sudo（方便在容器內臨時安裝套件）
RUN groupadd -g ${GROUP_ID} android && \
    useradd -m -u ${USER_ID} -g android -s /bin/bash android && \
    echo "android ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---------------------------------------------------------------------
# 4. 工作環境配置
# ---------------------------------------------------------------------
# 切換至新建立的用戶，避免使用 root 帳號編譯導致輸出的檔案權限錯亂
USER android

# 強制宣告 USER 環境變數，防止 Android Jack 編譯器報錯 (unbound variable)
ENV USER=android

# 設定容器啟動時的預設工作目錄（即您掛載 Android 原始碼的位置）
WORKDIR /home/rk3288-env/build

# 預設啟動命令：開啟 Bash 終端機
CMD ["/bin/bash"]

