#!/bin/bash

set -e

echo "=== OOB Gateway Setup ==="

read -p "WAN interface (default: enp3s0): " WAN_IF
WAN_IF=${WAN_IF:-enp3s0}

read -p "LAN interface (default: enp2s0): " LAN_IF
LAN_IF=${LAN_IF:-enp2s0}

read -p "LAN subnet (default: 192.168.10.1/24): " LAN_IP
LAN_IP=${LAN_IP:-192.168.10.1/24}

read -p "OOB device IP (e.g. 192.168.10.87): " OOB_IP
read -p "OOB service port (e.g. 8080): " OOB_PORT

read -p "zrok token: " ZROK_TOKEN

echo "=== Configure netplan ==="
sudo tee /etc/netplan/01-oob.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $WAN_IF:
      dhcp4: true
    $LAN_IF:
      addresses:
        - $LAN_IP
EOF

sudo netplan apply

echo "=== Install dnsmasq ==="
sudo apt update
sudo apt install -y dnsmasq

sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
interface=$LAN_IF
bind-interfaces
dhcp-range=192.168.10.50,192.168.10.150,12h
dhcp-option=3,192.168.10.1
dhcp-option=6,8.8.8.8
EOF

sudo systemctl restart dnsmasq

echo "=== Enable IP forward ==="
sudo sysctl -w net.ipv4.ip_forward=1

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

echo "=== Setup NAT ==="
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o $WAN_IF -j MASQUERADE
sudo iptables -A FORWARD -i $WAN_IF -o $LAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $LAN_IF -o $WAN_IF -j ACCEPT

sudo apt install -y iptables-persistent
sudo netfilter-persistent save

echo "=== Install zrok ==="
curl -sSfL https://get.openziti.io/install.sh | sudo bash

echo "=== Enable zrok ==="
zrok enable $ZROK_TOKEN

echo "=== Create systemd service ==="
sudo tee /etc/systemd/system/zrok-oob.service > /dev/null <<EOF
[Unit]
Description=zrok OOB tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/zrok share public http://$OOB_IP:$OOB_PORT
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl enable zrok-oob
sudo systemctl start zrok-oob

echo "=== DONE ==="
echo "Check status: systemctl status zrok-oob"