## Download the Docker
```
sudo apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
## Make a Dockerfile
```
touch Dockerfile
```
## Build Docker image
```
docker build -f Dockerfile .
```
 - Ex:
   ```
   docker build -t px30_build_env:v1 -f Dockerfile
   ```
- Explain: using the arguments of -t to specific the Repo. name and TAG

## Check the docker image
```
docker images
```
## or
```
docker image ls
```
## Display
```
REPOSITORY       TAG       IMAGE ID       CREATED       SIZE
px30_build_env   v1        8a6e80273916   3 hours ago   1GB
imx-yocto        latest    d27c927ee673   7 weeks ago   999MB
ubuntu           20.04     817578334b4d   2 years ago   72.8MB
hello-world      latest    feb5d9fea6a5   3 years ago   13.3kB
```

## Run the docker
```
docker run -it --rm "IMAGE ID" or "Repo:TAG"
```
- Ex:
  ```
  docker run -it --rm 8a6e80273916
  ```

## mapping the local Src folder
```
docker run -it --rm --privileged -v "PC_Host_Src_folder":"Container_target_mapping_folder" 
```
 - Ex:
  ```
  docker run -it --rm --privileged -v /media/14t_disk/mickey_bsp/ROCKCHIP/PX30_chipset/android/iot800n:/home/px30/source px30_build_env:v1
  ```
