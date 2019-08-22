#!/bin/sh
# Prepare to build the FTDI module for LT4 21.4 on the NVIDIA Jetson TK1
if [ $(id -u) != 0 ]; then
   echo "This script requires root permissions"
   echo "$ sudo "$0""
   exit
fi
# Get the kernel source for LT4 21.4
cd /usr/src/
wget -O kernel_src.tbz2 https://developer.nvidia.com/embedded/dlc/l4t-Jetson-TK1-Kernel-Sources-R21-5# Decompress
tar -xvf kernel_src.tbz2
cd kernel/include/linux
wget https://raw.githubusercontent.com/siemens/u-boot/master/include/linux/compiler-gcc5.h
cd ../../
# Get the kernel configuration file
zcat /proc/config.gz > .config
# Enable FTDI compilation
sudo sed -i 's/# CONFIG_USB_SERIAL_FTDI_SIO is not set/CONFIG_USB_SERIAL_FTDI_SIO=m/' .config
# Make sure that the local kernel version is set
LOCALVERSION=$(uname -r)
# vodoo incantation; This removes everything from the beginning to the last occurrence of "-"
# of the local version string i.e. 3.10.40 is removed
release="${LOCALVERSION##*-}"
CONFIGVERSION="CONFIG_LOCALVERSION=\"-$release\""
# Replace the empty local version with the local version of this kernel
sudo sed -i 's/CONFIG_LOCALVERSION=""/'$CONFIGVERSION'/' .config
# Prepare the module for compilation
make prepare
make modules_prepare
# Compile the module
make M=drivers/usb/serial/
# After compilation, copy the compiled module to the system area
cp drivers/usb/serial/ftdi_sio.ko /lib/modules/$(uname -r)/kernel
depmod -a
/bin/echo -e "\e[1;32mFTDI Driver Module Installed.\e[0m"

