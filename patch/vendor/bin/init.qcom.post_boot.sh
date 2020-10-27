# Custom post boot script by Thago
function 8917_sched_dcvs_eas()
{
    #governor settings
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
    #set the hispeed_freq
    echo 960000 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8917 it should be 85
    echo 85 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
   echo 'ENERGY_AWARE' > /sys/kernel/debug/sched_features
}

function configure_zram_parameters() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    low_ram=`getprop ro.config.low_ram`

    # Zram disk - 75% for Go devices.
    # For 512MB Go device, size = 384MB, set same for Non-Go.
    # For 1GB Go device, size = 768MB, set same for Non-Go.
    # For 2GB Go device, size = 1536MB, set same for Non-Go.
    # For >2GB Non-Go devices, size = 50% of RAM size. Limit the size to 4GB.
    # And enable lz4 zram compression for Go targets.

    RamSizeGB=`echo "($MemTotal / 1048576 ) + 1" | bc`
    if [ $RamSizeGB -le 2 ]; then
        zRamSizeBytes=`echo "$RamSizeGB * 1024 * 1024 * 1024 * 3 / 4" | bc`
        zRamSizeMB=`echo "$RamSizeGB * 1024 * 3 / 4" | bc`
    else
        zRamSizeBytes=`echo "$RamSizeGB * 1024 * 1024 * 1024 / 2" | bc`
        zRamSizeMB=`echo "$RamSizeGB * 1024 / 2" | bc`
    fi

    # use MB avoid 32 bit overflow
    if [ $zRamSizeMB -gt 4096 ]; then
        zRamSizeBytes=4294967296
    fi

        echo lz4 > /sys/block/zram0/comp_algorithm

    if [ -f /sys/block/zram0/disksize ]; then
        if [ -f /sys/block/zram0/use_dedup ]; then
echo 1 > /sys/block/zram0/use_dedup
        fi
        echo $zRamSizeBytes > /sys/block/zram0/disksize

        # ZRAM may use more memory than it saves if SLAB_STORE_USER
        # debug option is enabled.
        if [ -e /sys/kernel/slab/zs_handle ]; then
echo 0 > /sys/kernel/slab/zs_handle/store_user
        fi
        if [ -e /sys/kernel/slab/zspage ]; then
echo 0 > /sys/kernel/slab/zspage/store_user
        fi
	echo 80 > /proc/sys/vm/swappiness
	echo 10 > /proc/sys/vm/dirty_ratio
        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi
}

function configure_memory_parameters() {
adj_series=`cat /sys/module/lowmemorykiller/parameters/adj`
adj_1="${adj_series#*,}"
set_almk_ppr_adj="${adj_1%%,*}"
minfree_series=`cat /sys/module/lowmemorykiller/parameters/minfree`
minfree_1="${minfree_series#*,}" ; rem_minfree_1="${minfree_1%%,*}"
minfree_2="${minfree_1#*,}" ; rem_minfree_2="${minfree_2%%,*}"
minfree_3="${minfree_2#*,}" ; rem_minfree_3="${minfree_3%%,*}"
minfree_4="${minfree_3#*,}" ; rem_minfree_4="${minfree_4%%,*}"
minfree_5="${minfree_4#*,}"

vmpres_file_min=$((minfree_5 + (minfree_5 - rem_minfree_4)))
echo $vmpres_file_min > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo 1 > /sys/module/lowmemorykiller/parameters/oom_reaper
 echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
echo 100 > /sys/module/vmpressure/parameters/allocstall_threshold
echo 4096 > /proc/sys/vm/min_free_kbytes
}

# Device releated changes
echo 0 > /proc/sys/kernel/sched_boost
echo 20000000 > /proc/sys/kernel/sched_ravg_window
echo 1 > /sys/module/msm_thermal/core_control/enabled

echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
# Enable low power modes
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

# Set rps mask
echo 2 > /sys/class/net/rmnet0/queues/rx-0/rps_cpus

# Enable dynamic clock gating
echo 1 > /sys/module/lpm_levels/lpm_workarounds/dynamic_clock_gating
# Enable timer migration to little cluster
echo 1 > /proc/sys/kernel/power_aware_timer_migration

# Set Read ahead values
dmpts=$(ls /sys/block/*/queue/read_ahead_kb | grep -e dm -e mmc)
echo 256 > /sys/block/mmcblk0/bdi/read_ahead_kb
echo 256 > /sys/block/mmcblk0rpmb/bdi/read_ahead_kb
echo 256 > /sys/block/sda/queue/read_ahead_kb
for dm in $dmpts; do
    echo 256 > $dm
done

# Power saving features
echo 1 > /sys/devices/soc/${ro.boot.bootdevice}/clkscale_enable
echo 1 > /sys/devices/soc/${ro.boot.bootdevice}/clkgate_enable
echo 1 > /sys/devices/soc/${ro.boot.bootdevice}/hibern8_on_idle_enable
echo N > /sys/module/lpm_levels/parameters/sleep_disabled

# Set Memory parameters
configure_memory_parameters

# Set zram parameters
configure_zram_parameters

# Set EAS parameters
8917_sched_dcvs_eas
