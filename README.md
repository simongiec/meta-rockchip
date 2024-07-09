# meta-rockchip

Yocto BSP layer for the Rockchip SOC boards
  - wiki <http://opensource.rock-chips.com/wiki_Main_Page>.

This README file contains information on building and booting the meta-rockchip BSP layers.

Please see the corresponding sections below for details.

## Dependencies

This layer depends on:

* URI: git://git.yoctoproject.org/poky
* branch: kirkstone

* URI: git://git.openembedded.org/meta-openembedded
* layers: meta-oe
* branch: kirkstone

## Table of Contents

I. Configure yocto/oe Environment

II. Building meta-rockchip BSP Layers

III. Booting your Device

IV. Tested Hardwares

V. Supporting new Machine

### I. Configure yocto/oe Environment

In order to build an image with BSP support for a given release, you need to download the corresponding layers described in the "Dependencies" section. Be sure that everything is in the same directory.

```shell
~ $ mkdir yocto; cd yocto
~/yocto $ git clone git://git.yoctoproject.org/poky -b kirkstone
~/yocto $ git clone git://git.openembedded.org/meta-openembedded.git -b kirkstone
```

And put the meta-rockchip layer here too.

Then you need to source the configuration script:

```shell
~/yocto $ source poky/oe-init-build-env
```

Having done that, you can build a image for a rockchip board by adding the location of the meta-rockchip layer to bblayers.conf, along with any other layers needed.

For example:

```makefile
# build/conf/bblayers.conf
BBLAYERS ?= " \
  ${TOPDIR}/../poky/meta \
  ${TOPDIR}/../poky/meta-poky \
  ${TOPDIR}/../poky/meta-yocto-bsp \
  ${TOPDIR}/../meta-openembedded/meta-oe \
  ${TOPDIR}/../meta-openembedded/meta-multimedia \
  ${TOPDIR}/../meta-openembedded/meta-python \
  ${TOPDIR}/../meta-openembedded/meta-networking \
  ${TOPDIR}/../meta-rockchip \
```
Here is an example of our configuration of bblayer.conf: https://github.com/simongiec/build.git  
To enable a particular machine, you need to add a MACHINE line naming the BSP to the local.conf file:
```makefile
  MACHINE = "xxx"
```
This project's MACHINE is “rockchip-rk3568-evb”.  
All supported machines can be found in meta-rockchip/conf/machine.

### II. Building meta-rockchip BSP Layers

You should then be able to build a image as such:

```shell
$ bitbake core-image-minimal
```
All services we need can be found in meta-rockchip/conf/machine/rockchip-rk3568-evb.conf:
![image](https://github.com/simongiec/meta-rockchip/assets/169290270/32441d65-1441-4655-81a2-292aaf96b8e8)

At the end of a successful build, you should have an .wic image in `/path/to/yocto/build/tmp/deploy/images/<MACHINE>/`, also with an rockchip firmware image: `update.img`.

### III. Booting your Device
Under Windows,you can use RKDevTool_Release
Download link: https://drive.google.com/file/d/12XlHy0PA1AME0AE1xXZ9u_Lds6wYOyMk/view?usp=drive_link  
1. Put your device into rockusb mode:Turn off the machine, connect the adapter and use a USB cable to connect to the computer，press and hold the white button next to TypeC, press the power button, and release both buttons,the device will enter loader mode.  
2. Flash the image(update.img),as shown in the following figure,click "Upgrade".  
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/7b472c4a-6db7-4f70-93c0-bac38daacc07)

   
Under Linux, you can use upgrade_tool: <http://opensource.rock-chips.com/wiki_Upgradetool> to flash the image:

1. Put your device into rockusb mode: <http://opensource.rock-chips.com/wiki_Rockusb>

2. If it's maskrom rockusb mode, try to enter miniloader rockusb mode:

```shell
$ sudo upgrade_tool db <IMAGE PATH>/loader.bin
```

3. Flash the image (wic image or rockchip firmware image)

```shell
$ sudo upgrade_tool wl 0 <IMAGE PATH>/<IMAGE NAME>.wic # For wic image
```

```shell
$ sudo upgrade_tool uf <IMAGE PATH>/update.img # For rockchip firmware image
```

### IV. Tested Hardwares

#### 1. WiFi test
   Run "ifconfig -a",you will see wlan0，use iw to test wifi. Please refer to the following diagram for the testing process.
 ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/9399e5b0-f0bd-4e96-956e-7c94a81bb028)

      ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/1334a9f8-b763-484d-9cb6-a02ab49b79fc)

####  2. BT test
   Run "hciconfig -a".  
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/8d3879c5-1727-41fe-a0db-fe5bc233c99c)

#### 3. Ethernet test  
   eth0, after connecting the network cable,first，use "ifup eth0",then use “ping www.baidu.com" to test network,ping OK.  
   eth1, after connecting the network cable, use “ping www.baidu.com" to test network,ping OK.  
#### 4. HDMI test
   Firstly，you need to install desktop services，add to build/conf/bblayers.conf.
   ```shell
   DISPLAY_PLATFORM ?= "wayland"
   DISTRO_FEATURES:append = " ${@d.getVar('DISPLAY_PLATFORM')}"
   DISTRO_FEATURES:remove = " ${@'x11' if d.getVar('DISPLAY_PLATFORM') == 'wayland' else 'wayland'}"
   IMAGE_FEATURES:append = " ${@'x11-base' if d.getVar('DISPLAY_PLATFORM') == 'x11' else ''}"
   IMAGE_INSTALL:append = " ${@'weston weston-init weston-examples' if d.getVar('DISPLAY_PLATFORM') == 'wayland' else 'xf86-video-modesetting xserver-xorg-module-exa'}"
   ```
   Then connect the monitor with an HDMI cable, display ok.
#### 5. USB test
   Connect a USB drive to any USB port. Please refer to the following diagram for the testing process.
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/cd2f7e1c-dc2d-4f94-8265-85d2da9e5207)
#### 6. OTG test
   Connect the USB drive with an OTG cable and then connect it to the TypeC port,use cmd "mount",same with step 5.
#### 7. SATA test
   Use cmd "mount",same with step 5.
#### 8. DB9 test  
   (1) The wiring method is shown in the following figure. Connect the other side to the computer.   
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/5af714cb-4a3e-41dd-920e-86ae9bf3fd95)  
   (2) Configuration of serial port to be tested  
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/a0fd15a9-ad47-4af7-8cad-f8445924050a)  
   (3) Send instructions from the device to the computer.  
   device: echo testSerialCharString > /dev/ttyS4  
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/7d060d17-b90e-4601-9d09-21e7e5c04392)  
   (4) Send instructions from the computer to the device.  
   device: cat /dev/ttyS4&  
   ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/057c640c-20fe-43bc-bc44-5696a2e36eb3)  
#### 9. 4G test  
(1) The card insertion method is shown in the following figure.  
    ![image](https://github.com/simongiec/meta-rockchip/assets/169290270/3fdb6f45-b96a-4a33-81d1-fef150790f29)  
(2) Enter the following commands  
  ```shell
    cat /dev/ttyUSB1 & echo -e "AT+CPIN?\r\n" > /dev/ttyUSB1   
    echo -en 'AT+CGPADDR\r\n' > /dev/ttyUSB1 && cat /dev/ttyUSB1   
    echo -en 'AT+QNETDEVCTL=1,1,1\r\n' > /dev/ttyUSB1 && cat /dev/ttyUSB1   
    udhcpc -i usb0  
  ```
(3) ping test OK  
   
#### 10. GPU test  
(1) Add glmark2 in bblayers.conf
  ```shell
  # For glmark2  
  DISTRO_FEATURES:append = " opengl"  
  IMAGE_INSTALL:append = " glmark2"  
  PACKAGECONFIG:pn-glmark2 = \  
	  "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11-gles2', '', d)} \  
	  ${@bb.utils.contains('DISTRO_FEATURES', 'wayland opengl', 'wayland-gles2', '', d)} \  
	  drm-gles2"
  ```
(2) Test GPU
Run the following comman to test GPU in terminal or adb 
 ```shell
XDG_RUNTIME_DIR=/run/user/1000 glmark2-es2-wayland  
```
Test result is shown in the following figure.   
![image](https://github.com/simongiec/meta-rockchip/assets/169290270/3d7cd93e-a045-41b8-b67e-df7d1a5f68b4)  

(3) View GPU occupancy rate 
```shell
 cat /sys/class/devfreq/fde60000.gpu/load
```




   

   




