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
ui_print "Linux v4.9 "

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin/*;
chmod +x $ramdisk/sbin/spa
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

ui_print "*********************"
ui_print " "
ui_print "_____     _ _               "
ui_print "|_   _| __(_) |_ ___  _ __  "
ui_print "  | || '__| | __/ _ \| '_ \ "
ui_print "  | || |  | | || (_) | | | |"
ui_print "  |_||_|  |_|\__\___/|_| |_|"
ui_print "         Storm              "
ui_print "* Thago @ xda-developers ***"

patch_cmdline androidboot.usbconfigfs androidboot.usbconfigfs=true

ui_print " "
ui_print " "
ui_print "Flashing Custom Thermal-engine conf"
ui_print " "
ui_print " "

mount -o remount,rw /vendor
# Thermal conf
cp -f $home/patch/vendor/etc/thermal-engine.conf /vendor/etc/
chmod 0664 /vendor/etc/thermal-engine.conf

ui_print "Flashing Custom boot script (T-Weaks)"
ui_print "Which brings you yet more Optimizations"

# T-Weaks Post boot script
cp -f $home/patch/vendor/bin/init.qcom.post_boot.sh /vendor/bin/
chmod 0755 /vendor/bin/init.qcom.post_boot.sh

ui_print " "
ui_print " "
ui_print "Done! Don't forget to follow @tboxxx for  more updates"
ui_print "*** Enjoy! *****"
ui_print "*******************"

write_boot;
## end install

