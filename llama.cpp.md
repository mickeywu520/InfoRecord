# 確認CUDA安裝是否完全
```
nvcc -V
```
## 如果出現錯誤 nvcc: command not found, 需新增環境變數
```
sudo gedit ~/.bashrc
```
## 在結尾(拉到最下面), 新增下方程式碼
```
export LD_LIBRARY_PATH=/usr/local/cuda/lib export PATH=$PATH:/usr/local/cuda/bin
export PATH=$PATH:/usr/local/cuda/bin
```
## 重新source變數
```
source ~/.bashrc
```
## clone llama.cpp專案
```
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
```
## 編譯專案 with Jetson裝置或有Nvidia顯卡機器
```
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release
```


### 參考文獻
#### https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
#### https://medium.com/@EricChou711/nvidia-jetson-orin-nano-%E6%89%8B%E6%8A%8A%E6%89%8B%E5%AE%8C%E6%95%B4%E5%AE%89%E8%A3%9D%E6%95%99%E5%AD%B8-pytorch-tensorflow-opencv-cuda%E7%89%88%E6%9C%AC-683271bfaa42
