#!/system/bin/sh

target=`getprop ro.board.platform`

function configure_memory_parameters() {
    arch_type=`uname -m`
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}
    MemTotalPg=$((MemTotal / 4))
    adjZeroMinFree=18432
    adj_series=`cat /sys/module/lowmemorykiller/parameters/adj`
    adj_1="${adj_series#*,}"
    set_almk_ppr_adj="${adj_1%%,*}"
    set_almk_ppr_adj=$(((set_almk_ppr_adj * 6) + 6))
    echo $set_almk_ppr_adj > /sys/module/lowmemorykiller/parameters/adj_max_shift
    echo $set_almk_ppr_adj > /sys/module/process_reclaim/parameters/min_score_adj
    echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
    echo 70 > /sys/module/process_reclaim/parameters/pressure_max
    echo 30 > /sys/module/process_reclaim/parameters/swap_opt_eff
    echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
    echo 50 > /sys/module/process_reclaim/parameters/pressure_min
    echo 512 > /sys/module/process_reclaim/parameters/per_swap_size
    echo "15360,19200,23040,26880,34415,43737" > /sys/module/lowmemorykiller/parameters/minfree
    echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
    adjZeroMinFree=15360
    clearPercent=$((((adjZeroMinFree * 100) / MemTotalPg) + 1))
    echo $clearPercent > /sys/module/zcache/parameters/clear_percent
    echo 30 >  /sys/module/zcache/parameters/max_pool_percent
    zram_enable=`getprop ro.config.zram`
    echo 792723456 > /sys/block/zram0/disksize
    mkswap /dev/block/zram0
    swapon /dev/block/zram0 -p 32758
    SWAP_ENABLE_THRESHOLD=1048576
    swap_enable=`getprop ro.config.swap`
    soc_id=`cat /sys/devices/soc0/soc_id`
    soc_id=`cat /sys/devices/system/soc/soc0/id`
    if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
        echo 1 > /proc/sys/vm/swap_ratio_enable
        echo 70 > /proc/sys/vm/swap_ratio
        if [ ! -f /data/system/swap/swapfile ]; then
            dd if=/dev/zero of=/data/system/swap/swapfile bs=1m count=200
        fi
        mkswap /data/system/swap/swapfile
        swapon /data/system/swap/swapfile -p 32758
    fi
}

soc_id=`cat /sys/devices/soc0/soc_id`
hw_platform=`cat /sys/devices/soc0/hw_platform`
echo 3 > /proc/sys/kernel/sched_window_stats_policy
echo 3 > /proc/sys/kernel/sched_ravg_hist_size
echo 20000000 > /proc/sys/kernel/sched_ravg_window
echo 1 > /proc/sys/kernel/sched_restrict_tasks_spread
echo 0 > /proc/sys/kernel/sched_boost
echo 20 > /proc/sys/kernel/sched_small_task
echo 30 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_load
echo 30 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_load
echo 30 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_load
echo 30 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_load
echo 3 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run
echo 0 > /sys/devices/system/cpu/cpu0/sched_prefer_idle
echo 0 > /sys/devices/system/cpu/cpu1/sched_prefer_idle
echo 0 > /sys/devices/system/cpu/cpu2/sched_prefer_idle
echo 0 > /sys/devices/system/cpu/cpu3/sched_prefer_idle
echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/disable
for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
do
    echo "cpufreq" > $devfreq_gov
done
for devfreq_gov in /sys/class/devfreq/soc:qcom,cpubw/governor
do
    echo "bw_hwmon" > $devfreq_gov
    for cpu_io_percent in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/io_percent
    do
        echo 20 > $cpu_io_percent
    done
for cpu_guard_band in /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/guard_band_mbps
    do
        echo 30 > $cpu_guard_band
    done
done

for gpu_bimc_io_percent in /sys/class/devfreq/soc:qcom,gpubw/bw_hwmon/io_percent
do
    echo 40 > $gpu_bimc_io_percent
done
echo 0 > /sys/module/msm_thermal/core_control/enabled
echo 1 > /sys/devices/system/cpu/cpu0/online
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "19000 1094400:39000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
echo 85 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
echo 1094400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
echo 0 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
echo "1 960000:85 1094400:90" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
echo 960000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1 > /sys/module/msm_thermal/core_control/enabled
echo N > /sys/module/lpm_levels/perf/perf-l2-gdhs/idle_enabled
echo N > /sys/module/lpm_levels/perf/perf-l2-gdhs/suspend_enabled
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
echo 1 > /sys/devices/system/cpu/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpufreq/interactive/use_migration_notif
echo 50000 > /proc/sys/kernel/sched_freq_inc_notify
echo 50000 > /proc/sys/kernel/sched_freq_dec_notify
echo 2 > /sys/class/net/rmnet0/queues/rx-0/rps_cpus
echo 1 > /sys/module/lpm_levels/lpm_workarounds/dynamic_clock_gating
echo 1 > /proc/sys/kernel/power_aware_timer_migration
configure_memory_parameters
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
echo 128 > /sys/block/mmcblk0/bdi/read_ahead_kb
echo 128 > /sys/block/mmcblk0/queue/read_ahead_kb
echo 128 > /sys/block/dm-0/queue/read_ahead_kb
echo 128 > /sys/block/dm-1/queue/read_ahead_kb
setprop sys.post_boot.parsed 1
image_version="10:"
image_version+=`getprop ro.build.id`
image_version+=":"
image_version+=`getprop ro.build.version.incremental`
image_variant=`getprop ro.product.name`
image_variant+="-"
image_variant+=`getprop ro.build.type`
oem_version=`getprop ro.build.version.codename`
echo 10 > /sys/devices/soc0/select_image
echo $image_version > /sys/devices/soc0/image_version
echo $image_variant > /sys/devices/soc0/image_variant
echo $oem_version > /sys/devices/soc0/image_crm_version
echo 0 > /proc/sys/kernel/printk
