#define dev_fmt(fmt) KBUILD_MODNAME ": %s: " fmt, __func__

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>

static int plat_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	const char *name;

	device_property_read_string(dev, "plat_name", &name);

	dev_info(dev,"hello %s!\n", name);
	return 0;
}

static void plat_remove(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;

	dev_info(dev,"goodbye\n");
}

struct of_device_id plat_example_table[] = {
	{.compatible = "plat,example"},
	{},
};

MODULE_DEVICE_TABLE(of, plat_example_table);

struct platform_driver plat_example_platform = {
	.driver = {
		.name = "plat-example",
		.of_match_table = plat_example_table,
	},
	.probe = plat_probe,
	.remove_new = plat_remove,
};

module_platform_driver(plat_example_platform);
MODULE_LICENSE("GPL");
