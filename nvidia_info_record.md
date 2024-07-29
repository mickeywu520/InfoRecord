# install jtop utils
## https://hackmd.io/@YungHuiHsu/H1kx5WdJn
 - sudo apt-get install python3-pip
 - sudo pip3 install -U jetson-stats


# nvcc not found
## https://forums.developer.nvidia.com/t/cuda-nvcc-not-found/118068
 - $ export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
 - $ export LD_LIBRARY_PATH=/usr/local/cuda/lib64/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
## if cuda not install
 - $ sudo apt update
 - $ sudo apt install nvidia-jetpack

# nvOCDR
## https://github.com/NVIDIA-AI-IOT/NVIDIA-Optical-Character-Detection-and-Recognition-Solution
 - if wanna open video need to link: -lopencv_videoio -lopencv_imgproc -lopencv_highgui
 - $ g++ ./video_test.cpp -I../include -L../ -I/usr/include/opencv4/ -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart -lopencv_core -lopencv_imgcodecs -lopencv_videoio -lopencv_imgproc -lopencv_highgui -lnvocdr -o video_test
 - ### test sample drag5.cpp
 - $ sudo apt install libxcomposite-dev
 - $ g++ ./drag5.cpp -I../include -L../ -I/usr/include/opencv4/ -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lX11 -lXcomposite -lXrender -lcudart -lopencv_core -lopencv_imgcodecs -lopencv_videoio -lopencv_imgproc -lopencv_highgui -lnvocdr -pthread -o drag5.out
# Compile the libnvocdr.so:
 - cd NVIDIA-Optical-Character-Detection-and-Recognition-Solution
 - make
 - export LD_LIBRARY_PATH=$(pwd)
# Compile TensorRT libnvinfer_plugin.so 
 ### (if CUDA version not compatible, which need to rebuild the libnvinfer_plugin.so)
 - mkdir build && cd build
 - ### On X86 platform
 - cmake .. 
 - ### On Jetson platform
 - cmake .. -DTRT_LIB_DIR=/usr/lib/aarch64-linux-gnu/
 - make nvinfer_plugin -j4
# Copy the libnvinfer_plugin.so to the system library path
 - ### On X86 platform
 - cp libnvinfer_plugin.so.8.6.0 /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.8.5.1
 - ### On Jetson platform:
 - cp libnvinfer_plugin.so.8.6.x /usr/lib/aarch64-linux-gnu/libnvinfer_plugin.so.8.5.2

# Jetson Orin Nx CLB 开发套件上的 Qt 部署安装
## https://blog.csdn.net/u014597198/article/details/135688224

# Nvidia Jetson developer guide fourm(r36.3)
## https://docs.nvidia.com/jetson/archives/r36.3/DeveloperGuide/

# Nvidia Jetson Orin Kernel Customization 
## https://docs.nvidia.com/jetson/archives/r35.4.1/DeveloperGuide/text/SD/Kernel/KernelCustomization.html
