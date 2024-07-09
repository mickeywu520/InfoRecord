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
# Compile the libnvocdr.so:
 - cd NVIDIA-Optical-Character-Detection-and-Recognition-Solution
 - make
 - export LD_LIBRARY_PATH=$(pwd)

# Jetson Orin Nx CLB 开发套件上的 Qt 部署安装
## https://blog.csdn.net/u014597198/article/details/135688224
