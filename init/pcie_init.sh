#!/bin/sh

# Notes:
# A.1 - This tag means that the reg value was verified after the driver runs

# devmem2: glossary
# h - write word - 4 bytes, 8 pairs
# h - write halfword - 2 bytes, 4 pairs
# b - write byte - 1 byte, 2 pairs

clear
modprobe phy_j721e_wiz


update_register() {
    local address=$1
    local expected_value=$2
    local size=$3  # w = 32-bit, h = 16-bit, b = 8-bit
	address_hex=$(printf "0x%x" $address)

    current_value=$(devmem2 $address $size | grep "Read at address" | awk '{print $NF}')
    current_value_hex=$(printf "0x%x" $current_value)
	
	if [ -z "$expected_value" ]; then
		# echo "============================================================================="
		echo "[READ] addr: $address_hex - curr value: $current_value_hex"
		devmem2 $address $size $expected_value
		#echo "===================================================="
		echo ""
        return
    fi
	
	# echo "============================================================================="
	echo "[WRITE] addr: $address_hex - curr value: $current_value_hex - expected value: $expected_value"
	devmem2 $address $size $expected_value

    new_value=$(devmem2 $address $size | grep "Read at address" | awk '{print $NF}')
    new_value_hex=$(printf "0x%x" $new_value)
    if [ "$new_value_hex" != "$expected_value" ]; then
		echo "-----------------------------------------------------------------------------"
        echo "** ERROR! address: $address_hex - expected: $expected_value - obtained: $new_value_hex"
		echo "-----------------------------------------------------------------------------"
    fi
	#echo "===================================================="
	echo ""
}

read_register() {
    local address=$1

    value=$(devmem2 $address | grep "Read at address" | awk '{print $NF}')
    echo "$value"
}

add_part() {
	local value_base=$1
	local add_value=$2
	local shift=$3
	local mask=$4

	part=$(( $value_base & $mask ))
	value=$(( ($add_value << $shift) + $part ))
	value=$(printf "0x%X" $value)
	echo "$value"
}

wait_for_register_value() {
    local address="$1"       	# Register's address
    local expected_value="$2" 	# Expected value after applied the mask
	local mask="$3"          	# Mask to apply

    local delay="$4"         	# Delay in seconds between readings
	local timeout="$5"       	# Timeout in seconds

    start_time=$(date +%s)  	# Start time
	
	expected_value=$(printf "%x" "$expected_value")
    while [ $(($(date +%s) - start_time)) -lt "$timeout" ]; do
        value=$(read_register $address)
        masked_value=$((value & mask))
		masked_value=$(printf "%x" "$masked_value")
        
		echo "Read value: 0x$value"
		echo "Masked value: 0x$masked_value"
		echo "Expected value: 0x$expected_value"
        if [ "$masked_value" -eq "$expected_value" ]; then
            echo "Value matched: $masked_value"
            return 0
        fi

        sleep "$delay"
    done

    echo "Timeout reached, value not matched."
    return 1
}

header() {
	echo
	echo "###############################################################"
	echo "# $1"
	echo "###############################################################"
}

BASE_ADDRESS_PHY=0x5060000
BASE_ADDRESS_DBN=0xd800000
BASE_ADDRESS_CFG=0x2917000
BASE_ADDRESS_INTD=0x2910000
BASE_ADDR_CTRL_MMR=0x100000

BASE_ADDRESS_PHY=0x5060000

init_phy()
{
	header "INIT PHY"

	echo "++ wiz_clk_mux_set_parent ++"
	update_register $((BASE_ADDRESS_PHY + 0x040c)) "0x22800000" "w"
	#update_register $((BASE_ADDRESS_PHY + 0x040c)) "0x2000000" "w"

	update_register $((BASE_ADDRESS_PHY + 0x00a0)) "0x252" "h"
	
	# Enable APB
	# missing torrent_phy_probe

	echo "++ link_cmn_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0xc01c)) "0x3" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0342)) "0x601" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0362)) "0x400" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0382)) "0x8600" "h"
	
	echo "++ xcvr_diag_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x41cc)) "0x0" "h"
	update_register $((BASE_ADDRESS_PHY + 0x41ce)) "0x1" "h"
	update_register $((BASE_ADDRESS_PHY + 0x41ca)) "0x12" "h"
	update_register $((BASE_ADDRESS_PHY + 0x45cc)) "0x0" "h"
	update_register $((BASE_ADDRESS_PHY + 0x45ce)) "0x1" "h"
	update_register $((BASE_ADDRESS_PHY + 0x45ca)) "0x12" "h"

	echo "++ cmn_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x0388)) "0x28" "h"
	update_register $((BASE_ADDRESS_PHY + 0x01aa)) "0x1e" "h"
	update_register $((BASE_ADDRESS_PHY + 0x01ac)) "0xc" "h"

	echo "++ rx_ln_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x82e2)) "0x19" "h"
	update_register $((BASE_ADDRESS_PHY + 0x82e4)) "0x19" "h"
	update_register $((BASE_ADDRESS_PHY + 0x83fe)) "0x1" "h"
	update_register $((BASE_ADDRESS_PHY + 0x86e2)) "0x19" "h"
	update_register $((BASE_ADDRESS_PHY + 0x86e4)) "0x19" "h"
	update_register $((BASE_ADDRESS_PHY + 0x87fe)) "0x1" "h"

	echo "++ Link reset ++"
	value=$(read_register $((BASE_ADDRESS_PHY + 0xf004)))
	# echo $value
	value=$(($value | 0x1000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDRESS_PHY + 0xf004)) $value "w"
	
	echo "++ P0_FORCE_ENABLE ++"
	value=$(read_register $((BASE_ADDRESS_PHY + 0x0480)))
	# echo $value
	value=($value + 0x40000000)
	# echo $value
	update_register $((BASE_ADDRESS_PHY + 0x04c0)) $value "w"

	echo "++ P1_FORCE_ENABLE ++"
	value=$(read_register $((BASE_ADDRESS_PHY + 0x04c0)))
	# echo $value
	value=($value + 0x40000000)
	#value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDRESS_PHY + 0x04c0)) $value "w"

	# echo "Take the PHY out of reset"
	# echo "++ PHY_RESET_N ++"
	
	# value=$(read_register $((BASE_ADDRESS_PHY + 0x040c)))
	# value=$(($value | 0x80000000))
	# value=$(printf "0x%x" "$value")
	# update_register $((BASE_ADDRESS_PHY + 0x040c)) $value "w"
	
	echo "++ link_cmn_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x0342)) "0x601" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0362)) "0x400" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0382)) "0x8600" "h"

	echo "++ xcvr_diag_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x4dcc)) "0x11" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4dce)) "0x1" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4dca)) "0xc9" "h"

	echo "++ pcs_cmn_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0xc040)) "0xa0a" "h"
	update_register $((BASE_ADDRESS_PHY + 0xc044)) "0x1000" "h"
	update_register $((BASE_ADDRESS_PHY + 0xc046)) "0x10" "h"

	echo "++ cmn_vals ++"
	# 0x506 0080h
	update_register $((BASE_ADDRESS_PHY + 0x0082)) "0x8700" "h"
	# echo "++ PHY_RESET_N ++"
	# update_register $((BASE_ADDRESS_PHY + 0x040c)) 0xa2800000 "w"
	# 0x22800000
	# 0x506 008Ch
	update_register $((BASE_ADDRESS_PHY + 0x008e)) "0x8700" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0206)) "0x7f" "h"
	update_register $((BASE_ADDRESS_PHY + 0x0216)) "0x7f" "h"

	echo "++ tx_ln_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x4e00)) "0x2ff" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4e02)) "0x6af" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4e04)) "0x6ae" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4e06)) "0x6ae" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4c80)) "0x2a82" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4c9a)) "0x14" "h"
	update_register $((BASE_ADDRESS_PHY + 0x4dd6)) "0x3" "h"

	echo "++ rx_ln_vals ++"
	update_register $((BASE_ADDRESS_PHY + 0x8c00)) "0xd1d" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8c02)) "0xd1d" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8c04)) "0xd00" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8c06)) "0x500" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8d20)) "0x13" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8e10)) "0x0" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8e92)) "0xc02" "h"

	update_register $((BASE_ADDRESS_PHY + 0x8eee)) "0x330" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8ef0)) "0x300" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8ee2)) "0x19" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8ee4)) "0x19" "h"

	update_register $((BASE_ADDRESS_PHY + 0x8fd0)) "0x1004" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8fca)) "0xf9" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8fc4)) "0xc01" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8fc6)) "0x2" "h"

	update_register $((BASE_ADDRESS_PHY + 0x8fea)) "0x0" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8fe8)) "0x31" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8ffe)) "0x1" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8d00)) "0x18c" "h"
	update_register $((BASE_ADDRESS_PHY + 0x8d04)) "0x3" "h"
	
	echo " ++ Link reset ++"
	offset=0xf204
	value=$(read_register $((BASE_ADDRESS_PHY + offset)))
	value=$((value | 0x1000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDRESS_PHY + $offset)) $value "w"
	echo "++ P3_FORCE_ENABLE ++"
	offset=0x0540
	value=$(read_register $((BASE_ADDRESS_PHY + offset)))
	value=($value + 0x40000000)
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDRESS_PHY + $offset)) $value "w"
	
	echo "++ typec_ln10_swap ++"
	offset=0x0410
	value=$(read_register $((BASE_ADDRESS_PHY + offset)))
	# echo $value
	value=($value \& 0xBFFFFFFF)
	# echo $value
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDRESS_PHY + $offset)) $value "w"

	header "Take the PHY out of reset"
	echo "++ PHY_RESET_N ++"
	offset=0x040c
	value=$(read_register $((BASE_ADDRESS_PHY + offset)))
	echo $value
	value=$((value | 0x80000000))
	echo $value
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDRESS_PHY + $offset)) $value "w"

	# update_register $((BASE_ADDRESS_PHY + 0x040c)) 0xa2800000 "w"
	
	echo "++ Wait for cmn_ready assertion ++"
	# regmap_field_read_poll_timeout
	wait_for_register_value $((BASE_ADDRESS_PHY + 0xe000)) 0x1 0x1 0.1 2
	if [ "$?" -eq "1" ]; then
		echo "stopping script..."
		exit 1
	fi
	exit 1
	echo "++ Wait for phy_status ++"
	# regmap_field_read_poll_timeout
	wait_for_register_value $((BASE_ADDRESS_PHY + 0xd014)) 0x20000 0x20000 0.1 2
	if [ "$?" -eq "1" ]; then
		echo "stopping script..."
		exit 1
	fi
	
}

BASE_ADDRESS_DBN=0xd800000
BASE_ADDRESS_CFG=0x2917000
BASE_ADDRESS_INTD=0x2910000
BASE_ADDR_CTRL_MMR=0x100000

init_pcie()
{
	header "INIT PCIE"
	# 
	echo "++ j721e_pcie_set_link_speed ++"
	update_register $((BASE_ADDR_CTRL_MMR + 0x4074)) "0x80" "w"
	echo "++ j721e_pcie_set_mode ++"
	update_register $((BASE_ADDR_CTRL_MMR + 0x4074)) "0x82" "w"
	echo "++ j721e_pcie_set_lane_count ++"
	update_register $((BASE_ADDR_CTRL_MMR + 0x4074)) "0x182" "w"

	echo "++ j721e_pcie_config_link_irq ++"
	update_register $((BASE_ADDRESS_INTD + 0x108)) "0x2" "w"
	
	exit 0
	echo "++ reset ++"
	echo "PHY_RESET_N"
	sleep 0.0001
	update_register $((BASE_ADDRESS_CFG + 0x08)) "0x1" "w"
	
	echo "++ cdns_pcie_host_enable_ptm_response ++"
	value=$(read_register $((BASE_ADDRESS_DBN + 0x100da8)))

	# echo $value
	value=$(add_part $value 0x2 16 0x0000FFFF)
	# echo $value
	update_register $((BASE_ADDRESS_DBN + 0x100da8)) $value "w"

	echo "++ j721e_pcie_start_link ++"
	update_register $((BASE_ADDRESS_CFG + 0x4)) "0x0" "w"
	update_register $((BASE_ADDRESS_CFG + 0x4)) "0x1" "w"
	echo "++ j721e_pcie_link_up ++"
	update_register $((BASE_ADDRESS_CFG + 0x14))
	exit 0
	echo "++ cdns_pcie_host_init_root_port ++"
	update_register $((BASE_ADDRESS_DBN + 0x100300)) "0x1e0000" "w"
	update_register $((BASE_ADDRESS_DBN + 0x100044)) "0x104c104c" "w"
	update_register $((BASE_ADDRESS_DBN + 0x200002)) "0xb013" "h"
	update_register $((BASE_ADDRESS_DBN + 0x200008)) "0x0" "b"
	update_register $((BASE_ADDRESS_DBN + 0x200009)) "0x0" "b"
	update_register $((BASE_ADDRESS_DBN + 0x20000a)) "0x604" "h"
	update_register $((BASE_ADDRESS_DBN + 0x200008))

	echo ""
	echo "++ cdns_pcie_host_init_address_translation  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400004)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40000c)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x400018)) "0x1800000b" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40001c)) "0x0" "w"

	echo ""
	echo "++ cdns_pcie_set_outbound_region ++"
	update_register $((BASE_ADDRESS_DBN + 0x400020)) "0x7" "w"
	update_register $((BASE_ADDRESS_DBN + 0x400024)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x400028)) "0x800002" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40002c)) "0x0" "w"
	echo ""
	echo "++ Set the PCI address  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400038)) "0x7" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40003c)) "0x0" "w"

	echo ""
	echo "++ Set the PCIe header descriptor  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400040)) "0x1800100f" "w"
	update_register $((BASE_ADDRESS_DBN + 0x400044)) "0x0" "w"
	echo ""
	echo "++ Set the CPU address  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400048)) "0x800006" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40004c)) "0x0" "w"
	echo ""
	echo "**********"
	echo "++ cdns_pcie_set_outbound_region  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400058)) "0x1800100f" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40005c)) "0x0" "w"
	echo ""
	echo "++ Set the PCI address  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400060)) "0x1801101a" "w"
	update_register $((BASE_ADDRESS_DBN + 0x400064)) "0x0" "w"
	echo ""
	echo "++ Set the PCIe header descriptor  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400068)) "0x800002" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40006c)) "0x0" "w"
	echo ""
	echo "++ Set the CPU address  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400078)) "0x1801101a" "w"
	update_register $((BASE_ADDRESS_DBN + 0x40007c)) "0x0" "w"
	echo ""
	echo "++ cdns_pcie_host_bar_ib_config  ++"
	update_register $((BASE_ADDRESS_DBN + 0x400810)) "0x2f" "w"
	update_register $((BASE_ADDRESS_DBN + 0x400814)) "0x0" "w"
	echo "**********"

	echo ""
	echo "++ cdns_ti_pcie_config_write ++"
	update_register $((BASE_ADDRESS_DBN + 0x4)) "0x400" "w"
	update_register $((BASE_ADDRESS_DBN + 0x4)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x10)) "0xffffffff" "w"
	update_register $((BASE_ADDRESS_DBN + 0x10)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x14)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x14)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x38)) "0xfffff800" "h"
	update_register $((BASE_ADDRESS_DBN + 0x38)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x28)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x28)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0xe8)) "0x400" "b"
	update_register $((BASE_ADDRESS_DBN + 0x3e)) "0x2" "b"
	update_register $((BASE_ADDRESS_DBN + 0x84)) "0x8008" "b"
	update_register $((BASE_ADDRESS_DBN + 0x208)) "0x0" "b"
	update_register $((BASE_ADDRESS_DBN + 0x220)) "0x1" "h"
	update_register $((BASE_ADDRESS_DBN + 0x224)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x224)) "0x4" "h"
	update_register $((BASE_ADDRESS_DBN + 0x228)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x228)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x22c)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x22c)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x230)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x230)) "0x0" "h" 
	update_register $((BASE_ADDRESS_DBN + 0x234)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x234)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x238)) "0xffffffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x238)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x210)) "0x4" "b"
	update_register $((BASE_ADDRESS_DBN + 0x210)) "0x3" "b"
	update_register $((BASE_ADDRESS_DBN + 0x210)) "0x2" "b"
	update_register $((BASE_ADDRESS_DBN + 0x210)) "0x1" "b"
	update_register $((BASE_ADDRESS_DBN + 0x210)) "0x0" "b"
	update_register $((BASE_ADDRESS_DBN + 0x130)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x110)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x104)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0xc8)) "0x281f" "b" 
	update_register $((BASE_ADDRESS_DBN + 0x3e)) "0x2" "b"
	update_register $((BASE_ADDRESS_DBN + 0x18)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x3e)) "0x2" "b"
	update_register $((BASE_ADDRESS_DBN + 0x3e)) "0x2" "b"
	update_register $((BASE_ADDRESS_DBN + 0x6)) "0xffff" "b"
	update_register $((BASE_ADDRESS_DBN + 0x18)) "0xff0100" "h"

	update_register $((BASE_ADDRESS_DBN + 0x100000))

	echo ""
	echo "++ cdns_ti_pcie_config_write ++"
	update_register $((BASE_ADDRESS_DBN + 0x1a)) "0x1" "b"
	update_register $((BASE_ADDRESS_DBN + 0x3e)) "0x2" "b"
	update_register $((BASE_ADDRESS_DBN + 0x224)) "0x18400004" "h"
	update_register $((BASE_ADDRESS_DBN + 0x228)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x30)) "0xffff" "h"
	update_register $((BASE_ADDRESS_DBN + 0x1c)) "0xf0" "b"
	update_register $((BASE_ADDRESS_DBN + 0x30)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x20)) "0xfff0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x2c)) "0x0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x24)) "0xfff0" "h"
	update_register $((BASE_ADDRESS_DBN + 0x28)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x2c)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x3e)) "0x2" "w"
	update_register $((BASE_ADDRESS_DBN + 0x3c)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0xdc)) "0x0" "w" 
	update_register $((BASE_ADDRESS_DBN + 0x4)) "0x4" "w"
	update_register $((BASE_ADDRESS_DBN + 0xb2)) "0xc000" "w"
	# update_register $((BASE_ADDRESS_DBN + 0xb2)) "0x0" "w"

	value=$(read_register $((BASE_ADDRESS_DBN + 0x92)))
	value=$(add_part $value 0x180 16 0x0000FFFF)
	update_register $((BASE_ADDRESS_DBN + 0x92)) $value "w"

	update_register $((BASE_ADDRESS_DBN + 0xa0)) "0x1" "w"
	update_register $((BASE_ADDRESS_DBN + 0x92)) "0x180" "w"
	update_register $((BASE_ADDRESS_DBN + 0x94)) "0x1040000" "w"
	update_register $((BASE_ADDRESS_DBN + 0x98)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x9c)) "0x0" "w"

	value=$(read_register $((BASE_ADDRESS_DBN + 0x4)))
	value=$(add_part $value 0x404 0 0xFFFF0000)
	update_register $((BASE_ADDRESS_DBN + 0x4)) $value "w"

	value=$(read_register $((BASE_ADDRESS_DBN + 0x92)))
	value=$(add_part $value 0x181 16 0x0000FFFF)
	update_register $((BASE_ADDRESS_DBN + 0x92)) $value "w"

	update_register $((BASE_ADDRESS_DBN + 0xdc)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0xe0)) "0x10000" "w"
	update_register $((BASE_ADDRESS_DBN + 0xa0)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0xdc)) "0x8" "w"

	value=$(read_register $((BASE_ADDRESS_DBN + 0xca)))
	value=$(add_part $value 0x0 16 0x0000FFFF)
	update_register $((BASE_ADDRESS_DBN + 0xca)) $value "w"

	update_register $((BASE_ADDRESS_DBN + 0xdc)) "0x8" "w"
	update_register $((BASE_ADDRESS_DBN + 0x130)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x110)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x104)) "0x0" "w"
	update_register $((BASE_ADDRESS_DBN + 0x12c)) "0x7" "w"

	update_register $((BASE_ADDRESS_DBN))
}

init_phy
# init_pcie
