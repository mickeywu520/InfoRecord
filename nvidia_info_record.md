# install jtop utils
## https://hackmd.io/@YungHuiHsu/H1kx5WdJn
 - sudo pip3 install -U jetson-stats


# nvcc not found
## https://forums.developer.nvidia.com/t/cuda-nvcc-not-found/118068
 - $ export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
 - $ export LD_LIBRARY_PATH=/usr/local/cuda/lib64/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
