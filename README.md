# Description

simple script to setup linux, qemu, busybox, and u-boot for virtualization

# Features

allows sharing a file between the host machine and the virtual environment via the "platdriver" folder.
can hack on uboot as well as linux kernel modules

# Usage

```bash
./setup.sh
./run_qemu.sh
```

this will clone everything into the current directory from there to start hacking on the kernel/u-boot
or whatever source the environment

```bash
source .env
```

to test out the changes to the system they need to either be built into the rootfs or put into the platdriver folder

# Platform Driver Example

there is an example kernel module in platdriver, it reads from a device tree. to use this driver,

```bash
cd platdriver
make
make dtc
cd ..
./merge_dtb.sh
./run_qemu.sh
```

once in the qemu session

```bash
insmod host_share/platdriver.ko
```

it should show the print statements in the kernel driver. updating the device tree requires qemu to be restarted.
