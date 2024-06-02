obj-m += platdriver.o

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean

dtc:
	dtc -I dts plat.dts -o plat.dtb
