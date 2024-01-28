# Description

simple script to setup linux, qemu, busybox, and u-boot for virtualization

# Features

allows sharing a file between the host machine and the virtual environment via the "host\_share" folder

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

to test out the changes to the system they need to either be built into the rootfs or put into the host\_share foler


