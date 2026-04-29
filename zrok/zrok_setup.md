# OOB Gateway Setup (Ubuntu)

## 🎯 架構

```
[Internet / 4G]
      ↓
    zrok (cloud)
      ↓
 PC LAN1 (enp3s0: WAN)
      ↓ NAT
 PC LAN2 (enp2s0: LAN 192.168.10.1)
      ↓ DHCP
 Device (Jetson / OOB)
```

---

## 1️⃣ Netplan 設定, 將enp3s0 設定為外網來源(WAN), enp2s0 設定為內網 for OOB或其他裝置(LAN)

```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp3s0:
      dhcp4: true   # WAN

    enp2s0:
      addresses:
        - 192.168.10.1/24   # LAN
```

```bash
sudo netplan try
sudo netplan apply
```

---

## 2️⃣ 安裝 dnsmasq（DHCP）

```bash
sudo apt update
sudo apt install -y dnsmasq
```

### 設定

```conf
# /etc/dnsmasq.conf
interface=enp2s0
bind-interfaces

dhcp-range=192.168.10.50,192.168.10.150,12h
dhcp-option=3,192.168.10.1
dhcp-option=6,8.8.8.8

# (optional) static lease
# dhcp-host=AA:BB:CC:DD:EE:FF,192.168.10.100
```
- Example
```
# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
interface=enp2s0
....
# On systems which support it, dnsmasq binds the wildcard address,
# even when it is listening on only some interfaces. It then discards
# requests that it shouldn't reply to. This has the advantage of
# working even when interfaces come and go and change address. If you
# want dnsmasq to really bind only the interfaces it is listening on,
# uncomment this option. About the only time you may need this is when
# running another nameserver on the same machine.
bind-interfaces
...
# Uncomment this to enable the integrated DHCP server, you need
# to supply the range of addresses available for lease and optionally
# a lease time. If you have more than one network, you will need to
# repeat this for each network on which you want to supply DHCP
# service.
dhcp-range=192.168.10.50,192.168.10.150,12h
...
# Override the default route supplied by dnsmasq, which assumes the
# router is the same machine as the one running dnsmasq.
dhcp-option=3,192.168.10.1
dhcp-option=6,8.8.8.8
```
- 重新啟動 dnsmasq 服務
```bash
sudo systemctl restart dnsmasq
```

---

## 3️⃣ 開啟 IP Forward

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

永久化：

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
```

---

## 4️⃣ NAT (iptables)

```bash
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o enp3s0 -j MASQUERADE
sudo iptables -A FORWARD -i enp3s0 -o enp2s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i enp2s0 -o enp3s0 -j ACCEPT
```

### 永久化

```bash
sudo apt install -y iptables-persistent
sudo netfilter-persistent save
```

---

## 5️⃣ 安裝 zrok

### 官方安裝下載
- Linux x86_x64 (推薦)
```
https://github.com/openziti/zrok/releases/download/v2.0.2/zrok_2.0.2_linux_amd64.tar.gz
```
- bash install (未測試)
```bash
curl -sSfL https://get.openziti.io/install.sh | sudo bash
```
- 註冊zrok帳號, 並取得token
```
https://netfoundry.io/docs/zrok/get-started/
```
- 初始化：

```bash
./zrok2 enable <TOKEN>
```

---

## 6️⃣ 建立 Tunnel

```bash
./zrok2 share public http://192.168.10.X:PORT
```

Example:

```bash
./zrok2 share public http://192.168.10.87:8080
```
- Example: 執行畫面
```
╭────────────────────────────────────────────────────────────────────╮╭──────────────────────────╮
│                    xlvkv5tx3z3a.shares.zrok.io                     ││     [PUBLIC] [PROXY]     │
╰────────────────────────────────────────────────────────────────────╯╰──────────────────────────╯
╭────────────────────────────────────────────────────────────────────────────────────────────────╮
│Wednesday, 29-Apr-26 13:09:12 CST [] ->                                                         │
│GET /redfish/v1/Systems/1/EthernetInterfaces/l4tbr0                                             │
│Wednesday, 29-Apr-26 13:09:12 CST [] ->                                                         │
│GET /redfish/v1/Systems/1/EthernetInterfaces/usb0                                               │
│Wednesday, 29-Apr-26 13:09:12 CST [] ->                                                         │
│GET /redfish/v1/Systems/1/EthernetInterfaces/eth0                                               │
│Wednesday, 29-Apr-26 13:09:12 CST [] ->                                                         │
│GET /redfish/v1/Systems/1/EthernetInterfaces/usb1                                               │
│Wednesday, 29-Apr-26 13:09:12 CST [] ->                                                         │
│GET /redfish/v1/Managers/BMC/EthernetInterfaces/eth0                                            │
│Wednesday, 29-Apr-26 13:18:48 CST [] ->                                                         │
│GET /                                                                                           │
│Wednesday, 29-Apr-26 13:18:48 CST [] ->                                                         │
│GET /js/app.4f20f871.js                                                                         │
│Wednesday, 29-Apr-26 13:18:49 CST [] ->                                                         │
│GET /css/app.92ec9f4b.css                                                                       │
│Wednesday, 29-Apr-26 13:22:34 CST [] ->                                                         │
│GET /                                                                                           │
│Wednesday, 29-Apr-26 13:22:34 CST [] ->                                                         │
│GET /js/app.4f20f871.js                                                                         │
│Wednesday, 29-Apr-26 13:22:34 CST [] ->                                                         │
│GET /css/app.92ec9f4b.css                                                                       │
╰────────────────────────────────────────────────────────────────────────────────────────────────╯
```
- 在行動網路或外網的裝置上, 透過瀏覽器輸入URL: xlvkv5tx3z3a.shares.zrok.io 即可從外網穿透

---

## 7️⃣ systemd 自動啟動

```ini
# /etc/systemd/system/zrok-oob.service
[Unit]
Description=zrok OOB tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/zrok2 share public http://192.168.10.87:8080
Restart=always
User=demo

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reexec
sudo systemctl enable zrok-oob
sudo systemctl start zrok-oob
```

---

## 8️⃣ Debug 快速檢查

```bash
# DHCP
ip neigh

# LAN connectivity
ping 192.168.10.X

# Service
curl 192.168.10.X:PORT

# NAT
iptables -t nat -L

# zrok
systemctl status zrok-oob
```

---

## 9️⃣ 已知注意事項

* service port 不一定是 80（例如 8080）
* 建議固定 DHCP IP
* 直連設備可能遇到 ARP/PHY 不穩（可加 switch）
* 建議關閉 rp_filter：

```bash
sudo sysctl -w net.ipv4.conf.all.rp_filter=0
```
