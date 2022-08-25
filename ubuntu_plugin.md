# rsync
### sudo apt install rsync

### rsync -avzh --progress pi@192.168.1.12:/mypath/myfile.gz /mybackup/

    rsync 基本用法
    rsync 的基本語法結構如下：
    rsync 參數 來源檔案 目的檔案
    以下是最常見的幾個參數：
        -v：verbose 模式，輸出比較詳細的訊息。
        -r：遞迴（recursive）備份所有子目錄下的目錄與檔案。
        -a：封裝備份模式，相當於 -rlptgoD，遞迴備份所有子目錄下的目錄與檔案，保留連結檔、檔案的擁有者、群組、權限以及時間戳記。
        -z：啟用壓縮。
        -h：將數字以比較容易閱讀的格式輸出。