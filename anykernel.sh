# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Triton 4.9 kernel by Thago
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=rolex
device.name2=redmi4a
device.name3=riva
device.name4=redmi5a
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties


block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

ui_print "Welcome To Triton"
ui_print "flavour- Storm Rova(Unified)"
ui_print "*Built from Proton Clang*"
ui_print "*********************"

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin/*;
chmod +x $ramdisk/sbin/spa
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;
patch_cmdline androidboot.usbconfigfs androidboot.usbconfigfs=true
patch_cmdline androidboot.selinux androidboot.selinux=permissive

chown system:system /sys/devices/platform/soc/78b7000.i2c/i2c-3/3-0014/enable_dt2w
chmod 0664 /sys/devices/platform/soc/78b7000.i2c/i2c-3/3-0014/enable_dt2w
chown system:system /proc/gesture/onoff
chmod 0664 /proc/gesture/onoff

write_boot;
## end install

