#!/bin/bash

./qemu/build/qemu-system-arm -M virt -m 256 -kernel linux/arch/arm/boot/zImage -initrd rootfs.cpio.gz -append "root=/dev/mem/" -nographic --bios u-boot.bin --dtb qemu.dtb -virtfs local,path=$PWD/platdriver,security_model=mapped,mount_tag=host

