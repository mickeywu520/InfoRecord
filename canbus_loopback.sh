#!/bin/bash

CAN0="can0"
CAN1="can1"
CAN0_STATE=""
CAN1_STATE=""

canState() {
  CAN0_STATE="$(cat /sys/class/net/can0/operstate)"
  CAN1_STATE="$(cat /sys/class/net/can1/operstate)"
  #echo "CANBus0 State : $CAN0_STATE"
  #echo "CANBus1 State : $CAN1_STATE"
}

canUp() {
  sudo ip link set can0 up type can bitrate 500000 dbitrate 5000000 fd on
  sudo ip link set can1 up type can bitrate 500000 dbitrate 5000000 fd on
    echo "trying to start up can0 & can1"
}

startUpCanDump() {
    gnome-terminal -- bash -c "candump -a $CAN1"
}

sendCanMsg() {
while true
do
        CAN_MSG=""
        for ((i=0; i<64;i++))
        do
            randomByte=$(printf "%02X" $((RANDOM%256)))
            CAN_MSG+=$randomByte
        done

        #while [ ${#CAN_MSG} -lt 64 ]
        #do
        #        randomByte=$(printf "%02X" $((RANDOM%256)))
        #        CAN_MSG+=$randomByte
        #done

        #raw_data=$(cansend "$CAN0" "1F334455#$CAN_MSG" | awk -F ' ' '{}print $2')
	raw_data=$(cansend "$CAN0" "1F334455##1.$CAN_MSG")
        echo "send can msg : can0 => $CAN_MSG"
	LEN=${#CAN_MSG}
	echo "len : $((LEN / 2)) byte"
        sleep 1
done
}

checkCanState() {
canState
    if [[ $CAN0_STATE == "down" ]]; 
        then
        echo "canbus is down"
        canUp
	sleep 1
	startUpCanDump
	sleep 1
	sendCanMsg
else
        echo "canbus already up"
        startUpCanDump
        sleep 1
        sendCanMsg
    fi
}

checkCanState
