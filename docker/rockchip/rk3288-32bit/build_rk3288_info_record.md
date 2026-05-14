# Build android 32bit with RK3288, info record

### Build docker & run
```
# build docker
docker build -t rk3288-32bit-build-env .
# run docker
docker run -it -v /media/14t_disk/mickey_bsp/ROCKCHIP/RK3288_chipset/rm1000a:/home/rk3288-env/build rk3288-32bit-build-env
```

### Error Msg
```
/bin/sh: 1: lzop: not found
arch/arm/boot/compressed/Makefile:187: recipe for target 'arch/arm/boot/compressed/piggy.lzo' failed
make[2]: *** [arch/arm/boot/compressed/piggy.lzo] Error 1
make[2]: *** Waiting for unfinished jobs....
make[2]: *** wait: No child processes.  Stop.
arch/arm/boot/Makefile:61: recipe for target 'arch/arm/boot/compressed/vmlinux' failed
make[1]: *** [arch/arm/boot/compressed/vmlinux] Error 2
arch/arm/Makefile:332: recipe for target 'zImage' failed
make: *** [zImage] Error 2
```

### lzop install
```
sudo apt update
sudo apt install lzop
```

### lzo official website
- www.oberhumer.com
- http://www.oberhumer.com/opensource/lzo/#download

### additional info.
- lzo install
```
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
sudo su
tar xzvf lzo-2.10.tar.gz 
cd lzo-2.10
./configure --enable-shared 
make
make install
```
---

### Error Msg
```
Jack server failed to (re)start, try 'jack-diagnose' or see Jack server log
SSL error when connecting to the Jack server. Try 'jack-diagnose'
SSL error when connecting to the Jack server. Try 'jack-diagnose'
```
### TLSv1.1 compatible issue
- modify java.security
```
sudo sed -i 's/TLSv1, TLSv1.1,//g' /etc/java-8-openjdk/security/java.security
```
- restart jack-server
```
rm -rf ~/.jack-server/
rm -rf ~/.jack-settings

./prebuilts/sdk/tools/jack-admin kill-server
./prebuilts/sdk/tools/jack-admin start-server
```

### Error Msg
```
Jack server installation not found
```
- intstall jack server
```
./prebuilts/sdk/tools/jack-admin install-server ./prebuilts/sdk/tools/jack-launcher.jar ./prebuilts/sdk/tools/jack-server-4.8.ALPHA.jar
```