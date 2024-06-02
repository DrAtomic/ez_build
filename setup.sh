#!/bin/bash

set -xe

wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.xz
tar xvf gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.xz
mv gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf arm-gcc

wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar xvf busybox-1.36.1.tar.bz2

git clone git@github.com:u-boot/u-boot.git
pushd u-boot
git checkout fb5fe1bf84ff489211b333c0165418f0d119d328
git switch -c development
popd

git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/
pushd linux
git checkout 8a696a29c6905594e4abf78eaafcb62165ac61f1
git switch -c development
popd

git clone git@github.com:qemu/qemu.git
pushd qemu
git checkout 7a1dc45af581d2b643cdbf33c01fd96271616fbd
git switch -c development
popd

rm *.xz *.bz2

cat << EOF > .env
export ARCH=arm 
export CROSS_COMPILE=$PWD/arm-gcc/bin/arm-none-linux-gnueabihf- 
KERNEL=kernel7l
export KERNEL_SRC=$PWD/linux 
export INSTALL_MOD_PATH=$PWD/rootfs
EOF

source .env

pushd busybox-1.36.1
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config 
make -j12
make install
popd

mkdir -p rootfs/{bin,sbin,etc/init.d,proc,sys,usr/{bin,sbin},host_share}
cp -av busybox-1.36.1/_install/* rootfs
pushd rootfs
ln -sf bin/busybox init
mkdir dev
cd dev
fakeroot sh -c 'mknod -m 660 mem c 1 1 &&
mknod -m 660 tty0 c 4 0 &&
mknod -m 660 tty1 c 4 1 &&
mknod -m 660 tty2 c 4 2 && 
mknod -m 660 tty3 c 4 3 && 
mknod -m 660 tty4 c 4 4'
cd ../etc/init.d
cat << EOF >> rcS
mount -t sysfs none /sys
mount -t proc non /proc
mount -a
EOF
chmod +x rcS
cd ..
echo "host   /host_share   9p  trans=virtio,rw,_netdev 0   0" > fstab
popd

cp hacking_defconfig linux/arch/arm/configs
pushd linux
make hacking_defconfig
make -j12
make modules -j12
make modules_install -j12
popd

pushd rootfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../rootfs.cpio.gz
popd

pushd u-boot
make qemu_arm_defconfig
make -j12
mv u-boot.bin ..
popd

pushd qemu
mkdir build && cd build
../configure --target-list=arm-softmmu,arm-linux-user
make QEMU_VIRTFS_ENABLE=y -j12
popd

# get the dtb
./qemu/build/qemu-system-arm -M virt -m 256 -kernel linux/arch/arm/boot/zImage -initrd rootfs.cpio.gz -append "root=/dev/mem/" -nographic --bios u-boot.bin -machine dumpdtb=qemu.dtb
