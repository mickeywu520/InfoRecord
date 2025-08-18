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
## 開啟 RPC 支援
```
cmake -B build -DGGML_CUDA=ON -DLLAMA_RPC=ON
cmake --build build --config Release
```
## 編譯完成, 運行llama-cli
```
cd build/bin
./llama-cli -m "your download gguf model" -ngl 25
```
## ngl 最高層數訊息: load_tensors: offloaded 25/25 layers to GPU

## llama-server
```
./llama-server -m "model.gguf" -ngl 25 --host 0.0.0.0
```
## RPC server, 需要編譯支援RPC的執行檔
```
mkdir build-rpc-cuda
cd build-rpc-cuda
cmake .. -DGGML_CUDA=ON -DGGML_RPC=ON
cmake --build . --config Release
```
## 啟動 RPC server
```
./rpc-server -p 50052
```
## 如果執行 rpc-server 遇到下方錯誤
## ./rpc-server ./rpc-server: error while loading shared libraries: libggml.so: cannot open shared object file: No such file or directory
```
export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH
./rpc-server -p 50052 --host 0.0.0.0
```
## 運行本地模型加上 RPC 功能
```
./llama-server -m "model.gguf" --host 0.0.0.0 --rpc 192.168.213.116:50052 -ngl 25
```

### 參考文獻
#### https://hyd.ai/2025/03/07/llamacpp-on-jetson-orin-agx/
#### https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
#### https://medium.com/@EricChou711/nvidia-jetson-orin-nano-%E6%89%8B%E6%8A%8A%E6%89%8B%E5%AE%8C%E6%95%B4%E5%AE%89%E8%A3%9D%E6%95%99%E5%AD%B8-pytorch-tensorflow-opencv-cuda%E7%89%88%E6%9C%AC-683271bfaa42
