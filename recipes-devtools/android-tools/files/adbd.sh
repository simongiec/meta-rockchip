#!/bin/sh -e
### BEGIN INIT INFO
# Provides:          adbd
# Required-Start:    mountvirtfs
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Android Debug Bridge
### END INIT INFO

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

test -f /var/usb-debugging-enabled || exit 0

start_adbd()
{
	android-gadget-setup

	start-stop-daemon -S -b -n adbd -a \
		/usr/bin/env PROC_service.adb.tcp.port=5555 /usr/bin/adbd

	android-gadget-start
}

stop_adbd()
{
	start-stop-daemon -K -o -n adbd

	android-gadget-cleanup
}

case "$1" in
	start)
		echo -n "Starting Android Debug Bridge"
		start_adbd
		echo "."
		;;
	stop)
		echo -n "Stopping Android Debug Bridge"
		stop_adbd
		echo "."
		;;
	restart|reload)
		echo -n "Stopping Android Debug Bridge"
		stop_adbd
		echo "."
		echo -n "Starting Android Debug Bridge"
		start_adbd
		echo "."
		;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
esac
echo 0 > /sys/class/rfkill/rfkill0/state
echo 0 > /proc/bluetooth/sleep/btwrite
sleep 0.5
echo 1 > /sys/class/rfkill/rfkill0/state
echo 1 > /proc/bluetooth/sleep/btwrite
sleep 0.5
insmod  /lib/modules/5.10.198-rockchip-standard/kernel/drivers/bluetooth/bluetooth_uart_driver/hci_uart.ko
rtk_hciattach -n -s 115200 /dev/ttyS8 rtk_h5 &
exit 0
