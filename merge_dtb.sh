#!/bin/bash

set -xe

if ! [ -f ./platdriver/plat.dtb ]
then
	echo "please make the device tree"
	echo "cd platdriver"
	echo "make dtc"
	exit 1
fi
# dump current qemu dtb
./qemu/build/qemu-system-arm -M virt -m 256 -kernel linux/arch/arm/boot/zImage -initrd rootfs.cpio.gz -append "root=/dev/mem/" -nographic --bios u-boot.bin -machine dumpdtb=qemu.dtb

# merge dtb
cat  <(dtc -I dtb qemu.dtb) <(dtc -I dtb ./platdriver/plat.dtb | grep -v /dts-v1/) | dtc - -o qemu.dtb
