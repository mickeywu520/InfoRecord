#!/bin/bash

# clear eth0 and eth1 origin IPv6 addr
sudo ip -6 addr flush dev eth0
sudo ip -6 addr flush dev eth1

# startup eth0 and eth1 interface
sudo ip link set eth0 up
sudo ip link set eth1 up

# get eth0 and eth1 assign IPv6 addr
get_ipv6_addr() {
    ETH0_IPV6=$(ip -6 addr show dev eth0 | awk '/inet6/ {print $2}' | cut -d'/' -f1)
    ETH1_IPV6=$(ip -6 addr show dev eth1 | awk '/inet6/ {print $2}' | cut -d'/' -f1)
}

# check is got both IPv6 addr
check_ipv6_addr() {
    if [ -z "$ETH0_IPV6" ] || [ -z "$ETH1_IPV6" ]; then
        return 1
    else
        return 0
    fi
}

startEth1Ping() {
    echo "start!!!!!!!"
    gnome-terminal --title="ETH1 PING" --geometry=35x20 -- bash -c "ping6 $ETH0_IPV6 -I eth1"
}

# loop to get IPv6 addresses
while true; do
    get_ipv6_addr
    check_ipv6_addr
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 1
done

# add eth0 and eth1 route
sudo ip -6 route add "$ETH0_IPV6/128" dev eth0
sudo ip -6 route add "$ETH1_IPV6/128" dev eth1

# from eth0 ping eth1 IPv6 addr
ping6 "$ETH1_IPV6" -I eth0

# start a new terminal to ping from eth1 to eth0
startEth1Ping