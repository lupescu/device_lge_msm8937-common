#!/system/bin/sh

target=`getprop ro.board.platform`
platformid=`cat /sys/devices/soc0/soc_id`

start_battery_monitor()
{
	if ls /sys/bus/spmi/devices/qpnp-bms-*/fcc_data ; then
		chown -h root.system /sys/module/pm8921_bms/parameters/*
		chown -h root.system /sys/module/qpnp_bms/parameters/*
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_data
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_temp
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_chgcyl
		chmod 0660 /sys/module/qpnp_bms/parameters/*
		chmod 0660 /sys/module/pm8921_bms/parameters/*
		mkdir -p /data/bms
		chown -h root.system /data/bms
		chmod 0770 /data/bms
		start battery_monitor
	fi
}

start_charger_monitor()
{
	if ls /sys/module/qpnp_charger/parameters/charger_monitor; then
		chown -h root.system /sys/module/qpnp_charger/parameters/*
		chown -h root.system /sys/class/power_supply/battery/input_current_max
		chown -h root.system /sys/class/power_supply/battery/input_current_trim
		chown -h root.system /sys/class/power_supply/battery/input_current_settled
		chown -h root.system /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/class/power_supply/battery/input_current_max
		chmod 0664 /sys/class/power_supply/battery/input_current_trim
		chmod 0664 /sys/class/power_supply/battery/input_current_settled
		chmod 0664 /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/module/qpnp_charger/parameters/charger_monitor
		start charger_monitor
	fi
}

start_vm_bms()
{
	if [ -e /dev/vm_bms ]; then
		chown -h root.system /sys/class/power_supply/bms/current_now
		chown -h root.system /sys/class/power_supply/bms/voltage_ocv
		chmod 0664 /sys/class/power_supply/bms/current_now
		chmod 0664 /sys/class/power_supply/bms/voltage_ocv
		start vm_bms
	fi
}

start_msm_irqbalance_8939()
{
	if [ -f /system/bin/msm_irqbalance ]; then
		case "$platformid" in
		    "239" | "293" | "294" | "295" | "304" | "313" | "338")
			start msm_irqbalance;;
		esac
	fi
}

start_msm_irqbalance()
{
	if [ -f /system/bin/msm_irqbalance ]; then
		start msm_irqbalance
	fi
}

start_copying_prebuilt_qcril_db()
{
    if [ -f /system/vendor/qcril.db -a ! -f /data/misc/radio/qcril.db ]; then
        cp /system/vendor/qcril.db /data/misc/radio/qcril.db
        chown -h radio.radio /data/misc/radio/qcril.db
    fi
}

baseband=`getprop ro.baseband`
echo 1 > /proc/sys/net/ipv6/conf/default/accept_ra_defrtr

case "$baseband" in
        "svlte2a")
        start bridgemgrd
        ;;
esac

case "$target" in
    "msm8937")
        start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$soc_id" in
             "294" | "295" | "303" | "307" | "308" | "309" | "313" | "320")
                  case "$hw_platform" in
                       "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                  esac
                  ;;
       esac
        ;;
esac

start_copying_prebuilt_qcril_db
echo 1 > /data/misc/radio/db_check_done
if [ -f /data/misc/radio/ver_info.txt ]; then
    prev_version_info=`cat /data/misc/radio/ver_info.txt`
else
    prev_version_info=""
fi
cur_version_info=`cat /firmware/verinfo/ver_info.txt`
build_product=`getprop ro.build.product`
product_name=`getprop ro.product.name`
target_operator=`getprop ro.build.target_operator`
laop_brand=`getprop ro.lge.laop.brand`
sku_carrier=`getprop ro.lge.sku_carrier`
mcfg_group_1=("gsm/tm" "gsm/ro_tm")
mcfg_group_2=("gsm/tm" "gsm/ro_tm")
mcfg_group_3=("cdma_na/tr_hV" "cdma_na/ro_tr_hv")
mcfg_group_4=("gsm/tr_at" "gsm/tr_cl" "gsm/tr_si" "gsm/tr_tm" "gsm/ro_tr_at")
mcfg_group_5=("gsm/at" "gsm/cc" "gsm/cc_ti" "gsm/tm" "gsm/tr_at" "gsm/tr_si" "gsm/tr_tm" "gsm/ro_at")
mcfg_group_6=("cdma_na/us" "cdma_na/ro_us")
mcfg_group_7=("cdma_na/hv" "cdma_na/ro_us")
mcfg_group_8=("canada/be" "canada/es" "canada/rg" "canada/te" "canada/vt" "canada/wi" "canada/ro_rg")
mcfg_group_9=("cdma_na/hv" "cdma_na/ro_hv")
rm -rf /data/misc/radio/modem_config
mkdir /data/misc/radio/modem_config
chmod 770 /data/misc/radio/modem_config
`setprop persist.radio.sw_mbn_loaded 0`
mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na
chmod 770 /data/misc/radio/modem_config/mcfg_sw/generic/na
cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_hw /data/misc/radio/modem_config
cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/common /data/misc/radio/modem_config/mcfg_sw/generic
for value in "${mcfg_group_2[@]}"; do
    if [ ! -d /data/misc/radio/modem_config/mcfg_sw/generic/na/$value ]; then
        mkdir -p /data/misc/radio/modem_config/mcfg_sw/generic/na/$value
    fi
    cp -rf /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/na/"$value"/* /data/misc/radio/modem_config/mcfg_sw/generic/na/"$value"
done
cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
chown -hR radio.radio /data/misc/radio/modem_config
cp /firmware/verinfo/ver_info.txt /data/misc/radio/ver_info.txt
chown radio.radio /data/misc/radio/ver_info.txt
chown -h radio.system /data/misc/radio/modem_config
chmod -R 770 /data/misc/radio/modem_config/mcfg_sw
chown -hR radio.system /data/misc/radio/modem_config/mcfg_sw
cp /firmware/image/modem_pr/mbn_ota.txt /data/misc/radio/modem_config
chown radio.radio /data/misc/radio/modem_config/mbn_ota.txt
echo 1 > /data/misc/radio/copy_complete
