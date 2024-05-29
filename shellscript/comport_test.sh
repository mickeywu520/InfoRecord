#!/bin/bash

COM3="/dev/ttymxc2"
COM4="/dev/ttymxc3"
BAUD_RATE="9600"

setupGpio() {
	sudo chmod 777 /sys/class/gpio/export
	# switch com3 to RS485 mode
	sudo echo 97 > /sys/class/gpio/export
	sudo echo 83 > /sys/class/gpio/export 
	sudo echo 84 > /sys/class/gpio/export
	sudo chmod 777 /sys/class/gpio/gpio97/direction
	sudo chmod 777 /sys/class/gpio/gpio83/direction
	sudo chmod 777 /sys/class/gpio/gpio84/direction
	echo out > /sys/class/gpio/gpio97/direction
	echo out > /sys/class/gpio/gpio83/direction
	echo out > /sys/class/gpio/gpio84/direction
	sudo chmod 777 /sys/class/gpio/gpio97/value
	sudo chmod 777 /sys/class/gpio/gpio83/value
	sudo chmod 777 /sys/class/gpio/gpio84/value
	echo 0 > /sys/class/gpio/gpio97/value
	echo 1 > /sys/class/gpio/gpio83/value
	echo 1 > /sys/class/gpio/gpio84/value

	# switch com4 to RS485 mode
	echo 114 > /sys/class/gpio/export
	echo 115 > /sys/class/gpio/export
	echo 96 > /sys/class/gpio/export
	sudo chmod 777 /sys/class/gpio/gpio114/direction
	sudo chmod 777 /sys/class/gpio/gpio115/direction
	sudo chmod 777 /sys/class/gpio/gpio96/direction
	echo out > /sys/class/gpio/gpio114/direction
	echo out > /sys/class/gpio/gpio115/direction
	echo out > /sys/class/gpio/gpio96/direction
	sudo chmod 777 /sys/class/gpio/gpio114/value
	sudo chmod 777 /sys/class/gpio/gpio115/value
	sudo chmod 777 /sys/class/gpio/gpio96/value
	echo 0 > /sys/class/gpio/gpio114/value
	echo 1 > /sys/class/gpio/gpio115/value
	echo 1 > /sys/class/gpio/gpio96/value
}

setBaudrate() {
	stty -F "$COM3" raw speed "$BAUD_RATE" -echo
	stty -F "$COM4" raw speed "$BAUD_RATE" -echo
}

sendMsg() {
while true; do
    # ?�e?��?�u�� COM3
    random_data=$(openssl rand -base64 32)
    echo "Sending random data from COM3: $random_data"
    echo -ne '\x12' > "$COM3"   # ?�m RTS on send
    echo "$random_data" > "$COM3"

    sleep 1

    # ? COM4 ����?�u
    received_data=$(cat "$COM4")
    echo "Received data from COM4: $received_data"
done
}

receive_terminal() {
    gnome-terminal --title="COM4 RECEIVER" --geometry 35x20 -- bash -c "~/test_tool/receive_message"
}

send_terminal() {
    gnome-terminal --title="COM3 SENDER" --geometry 35x20 -- bash -c "~/test_tool/send_message"
}

setupGpio
receive_terminal
send_terminal

#setBaudrate
#sendMsg



