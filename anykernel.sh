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

mount -o remount,rw /vendor

ui_print " "
ui_print "Flashing Custom Thermal-engine conf"
ui_print " "

# Thermal conf
cp -f $home/patch/vendor/etc/thermal-engine.conf /vendor/etc/thermal-engine-t.conf

ui_print "Flashing T-Weaks"
ui_print "Which brings you yet more Optimizations"

# T-Weaks Post boot script
do_t_weaks() {
	sed -i '$a chk=$(uname -r | grep -Eio Triton)' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a if [ "$chk" == "Triton" ]; then' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \    \ setprop ro.lmk.use_psi true' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \    \ setprop ro.config.low_ram true' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \    \ setprop ro.lmk.psi_complete_stall_ms 200' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \    \ setprop ro.lmk.thrashing_limit 30' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \    \ setprop ro.lmk.swap_util_max 100' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \	\ if [ -f /vendor/etc/thermal-engine-t.conf ]; then' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \ 		\mv /vendor/etc/thermal-engine.conf /vendor/etc/thermal-engine.conf~' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \		\mv /vendor/etc/thermal-engine-t.conf  /vendor/etc/thermal-engine.conf' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \	\ fi' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \         \source /vendor/bin/t-weaks.sh' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a else' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \	\if [ -f /vendor/etc/thermal-engine.conf~ ]; then' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \ 		\mv /vendor/etc/thermal-engine.conf~ /vendor/etc/thermal-engine.conf' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a \	\fi' /vendor/bin/init.qcom.post_boot.sh;
	sed -i '$a fi' /vendor/bin/init.qcom.post_boot.sh;
}

cp -f $home/patch/vendor/bin/init.qcom.post_boot.sh /vendor/bin/t-weaks.sh;
chmod 0755 /vendor/bin/t-weaks.sh;

cie=$(grep -Eio -m 1 Triton /vendor/bin/init.qcom.post_boot.sh);
if [ $cie = Triton ]; then
        ui_print "T-Weaks already exits"
else
        ui_print "T-Weaks not found, Performing T-Weaks"
        do_t_weaks;
	sleep 2;
	ui_print "Done!"
fi

ui_print " "
ui_print "Done! Don't forget to follow @tboxxx for  more updates"
ui_print "*** Enjoy! *****"
ui_print "*******************"

write_boot;
## end install

