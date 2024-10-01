#!/bin/sh

# Notes:
# A.1 - This tag means that the reg value was verified after the driver runs

# devmem2: glossary
# h - write word - 4 bytes, 8 pairs
# h - write halfword - 2 bytes, 4 pairs
# b - write byte - 1 byte, 2 pairs
ifconfig eth1 169.254.48.197
clear
modprobe phy_j721e_wiz


update_register() {
    local address=$1
	local size=$2  # w = 32-bit, h = 16-bit, b = 8-bit
	local expected_value=$3

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
	expected_value=$(printf "0x%x" $expected_value)
    new_value=$(devmem2 $address $size | grep "Read at address" | awk '{print $NF}')
    new_value_hex=$(printf "0x%x" $new_value)
    if [ "$new_value_hex" != "$expected_value" ]; then
		echo "-----------------------------------------------------------------------------"
        echo "** ERROR! address: $address_hex - expected: $expected_value - obtained: $new_value_hex"
		echo "-----------------------------------------------------------------------------"
    fi
	devmem2 $address $size
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
    local address=$1      	# Register's address
    local expected_value=$2 # Expected value after applied the mask
	local mask=$3          	# Mask to apply

    local delay=$4        	# Delay in seconds between readings
	local timeout=$5       	# Timeout in seconds

    start_time=$(date +%s)  	# Start time
	
	expected_value=$(printf "%x" "$expected_value")
	address=$(printf "0x%x" $address)
    while [ $(($(date +%s) - start_time)) -lt "$timeout" ]; do
        value=$(read_register $address)
        masked_value=$((value & mask))
		masked_value=$(printf "%x" "$masked_value")
        echo "[READ] addr: $address - curr value: 0x$value"
		echo "Masked value: 0x$masked_value"
		echo "Expected value: 0x$expected_value"
        if [ "$masked_value" -eq "$expected_value" ]; then
            echo "Value matched: 0x$masked_value"
			echo
            return 0
        fi

        sleep "$delay"
    done

    echo "Timeout reached, value not matched."
	echo
    return 1
}

header() {
	echo
	echo "###############################################################"
	echo "# $1"
	echo "###############################################################"
}

BASE_ADDR_WIZ0=0x5060000
BASE_ADDR_WIZ1=0x5070000
BASE_ADDR_WIZ2=0x5020000
BASE_ADDR_WIZ4=0x5050000

init_phy()
{
	header "INIT PHY"

	echo "++ wiz_clk_mux_set_parent ++"
	update_register $((BASE_ADDR_WIZ0 + 0x040c)) "w" "0xa2800000"
	#update_register $((BASE_ADDR_WIZ0 + 0x040c)) "w" "0x2000000"

	# [phy:0x0][cdns_torrent_refclk_driver_register:2241] [read] CMN_CDIAG_REFCLK_DRV0_CTRL_4 = 0x82aabc0, val = 0x0
	# [phy:0x0][cdns_torrent_refclk_driver_register:2242] [write] CMN_CDIAG_REFCLK_DRV0_CTRL_4 = 0x82aabc0, val = 0x1

	update_register $((BASE_ADDR_WIZ0 + 0x00a0)) "h" "0x252"
	
	# Enable APB
	# missing torrent_phy_probe

	echo "++ link_cmn_vals ++"
	update_register $((BASE_ADDR_WIZ0 + 0xc01c)) "h" "0x3"

	update_register $((BASE_ADDR_WIZ0 + 0x0342)) "h" "0x601"
	update_register $((BASE_ADDR_WIZ0 + 0x0362)) "h" "0x400"
	update_register $((BASE_ADDR_WIZ0 + 0x0382)) "h" "0x8600"

	echo "++ xcvr_diag_vals ++"
	update_register $((BASE_ADDR_WIZ0 + 0x41cc)) "h" "0x0"
	update_register $((BASE_ADDR_WIZ0 + 0x41ce)) "h" "0x1"
	update_register $((BASE_ADDR_WIZ0 + 0x41ca)) "h" "0x12"
	update_register $((BASE_ADDR_WIZ0 + 0x45cc)) "h" "0x0"
	update_register $((BASE_ADDR_WIZ0 + 0x45ce)) "h" "0x1"
	update_register $((BASE_ADDR_WIZ0 + 0x45ca)) "h" "0x12"

	echo "++ cmn_vals ++"                                    
	update_register $((BASE_ADDR_WIZ0 + 0x0388)) "h" "0x28"
	update_register $((BASE_ADDR_WIZ0 + 0x01aa)) "h" "0x1e"
	update_register $((BASE_ADDR_WIZ0 + 0x01ac)) "h" "0xc"

	echo "++ rx_ln_vals ++"                                  
	update_register $((BASE_ADDR_WIZ0 + 0x82e2)) "h" "0x19"
	update_register $((BASE_ADDR_WIZ0 + 0x82e4)) "h" "0x19"
	update_register $((BASE_ADDR_WIZ0 + 0x83fe)) "h" "0x1"
	update_register $((BASE_ADDR_WIZ0 + 0x86e2)) "h" "0x19"
	update_register $((BASE_ADDR_WIZ0 + 0x86e4)) "h" "0x19"
	update_register $((BASE_ADDR_WIZ0 + 0x87fe)) "h" "0x1"

	echo "++ Link reset ++"
	offset=0xf004
	value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# echo $value
	value=$(($value | 0x1000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value
	
	echo "++ P0_FORCE_ENABLE ++"
	offset=0x0480
	value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# echo $value
	value=$((value | 0x40000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value

	echo "++ P1_FORCE_ENABLE ++"
	offset=0x04c0
	value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# echo $value
	value=$((value | 0x40000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value

	# echo "Take the PHY out of reset"
	# echo "++ PHY_RESET_N ++"
	
	# value=$(read_register $((BASE_ADDR_WIZ0 + 0x040c)))
	# value=$(($value | 0x80000000))
	# value=$(printf "0x%x" "$value")
	# update_register $((BASE_ADDR_WIZ0 + 0x040c)) "w" $value

	echo "++ link_cmn_vals ++"                               
	update_register $((BASE_ADDR_WIZ0 + 0x0342)) "h" "0x601"
	update_register $((BASE_ADDR_WIZ0 + 0x0362)) "h" "0x400"
	update_register $((BASE_ADDR_WIZ0 + 0x0382)) "h" "0x8600"

	echo "++ xcvr_diag_vals ++"                              
	update_register $((BASE_ADDR_WIZ0 + 0x4dcc)) "h" "0x11"
	update_register $((BASE_ADDR_WIZ0 + 0x4dce)) "h" "0x1"
	update_register $((BASE_ADDR_WIZ0 + 0x4dca)) "h" "0xc9"

	echo "++ pcs_cmn_vals ++"                                
	update_register $((BASE_ADDR_WIZ0 + 0xc040)) "h" "0xa0a"
	update_register $((BASE_ADDR_WIZ0 + 0xc044)) "h" "0x1000"
	update_register $((BASE_ADDR_WIZ0 + 0xc046)) "h" "0x10"

	echo "++ cmn_vals ++"                                    
	# 0x506 0080h                                            
	update_register $((BASE_ADDR_WIZ0 + 0x0082)) "h" "0x8700"
	# echo "++ PHY_RESET_N ++"
	# update_register $((BASE_ADDR_WIZ0 + 0x040c)) "w" "0xa2800000" 
	# 0x22800000
	# 0x506 008Ch
	update_register $((BASE_ADDR_WIZ0 + 0x008e)) "h" "0x8700"

	update_register $((BASE_ADDR_WIZ0 + 0x0206)) "h" "0x7f"
	update_register $((BASE_ADDR_WIZ0 + 0x0216)) "h" "0x7f"

	echo "++ tx_ln_vals ++"
	update_register $((BASE_ADDR_WIZ0 + 0x4e00)) "h" "0x2ff"
	update_register $((BASE_ADDR_WIZ0 + 0x4e02)) "h" "0x6af"
	update_register $((BASE_ADDR_WIZ0 + 0x4e04)) "h" "0x6ae"
	update_register $((BASE_ADDR_WIZ0 + 0x4e06)) "h" "0x6ae"
	update_register $((BASE_ADDR_WIZ0 + 0x4c80)) "h" "0x2a82"
	update_register $((BASE_ADDR_WIZ0 + 0x4c9a)) "h" "0x14"
	update_register $((BASE_ADDR_WIZ0 + 0x4dd6)) "h" "0x3"

	echo "++ rx_ln_vals ++"                                  
	update_register $((BASE_ADDR_WIZ0 + 0x8c00)) "h" "0xd1d"
	update_register $((BASE_ADDR_WIZ0 + 0x8c02)) "h" "0xd1d"
	update_register $((BASE_ADDR_WIZ0 + 0x8c04)) "h" "0xd00"
	update_register $((BASE_ADDR_WIZ0 + 0x8c06)) "h" "0x500"
	update_register $((BASE_ADDR_WIZ0 + 0x8d20)) "h" "0x13"
	update_register $((BASE_ADDR_WIZ0 + 0x8e10)) "h" "0x0"
	update_register $((BASE_ADDR_WIZ0 + 0x8e92)) "h" "0xc02"

	update_register $((BASE_ADDR_WIZ0 + 0x8eee)) "h" "0x330"
	update_register $((BASE_ADDR_WIZ0 + 0x8ef0)) "h" "0x300"
	update_register $((BASE_ADDR_WIZ0 + 0x8ee2)) "h" "0x19"
	update_register $((BASE_ADDR_WIZ0 + 0x8ee4)) "h" "0x19"

	update_register $((BASE_ADDR_WIZ0 + 0x8fd0)) "h" "0x1004"
	update_register $((BASE_ADDR_WIZ0 + 0x8fca)) "h" "0xf9"
	update_register $((BASE_ADDR_WIZ0 + 0x8fc4)) "h" "0xc01"
	update_register $((BASE_ADDR_WIZ0 + 0x8fc6)) "h" "0x2"

	update_register $((BASE_ADDR_WIZ0 + 0x8fea)) "h" "0x0"
	update_register $((BASE_ADDR_WIZ0 + 0x8fe8)) "h" "0x31"
	update_register $((BASE_ADDR_WIZ0 + 0x8ffe)) "h" "0x1"
	update_register $((BASE_ADDR_WIZ0 + 0x8d00)) "h" "0x18c"
	update_register $((BASE_ADDR_WIZ0 + 0x8d04)) "h" "0x3"
	
	echo " ++ Link reset ++"
	offset=0xf204
	value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	value=$((value | 0x1000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value

	echo "++ P3_FORCE_ENABLE ++"
	offset=0x0540
	value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	value=$((value | 0x40000000))
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value 
	
	echo "++ typec_ln10_swap ++"
	offset=0x0410
	value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# echo $value
	value=$((value & 0xBFFFFFFF))
	# echo $value
	value=$(printf "0x%x" "$value")
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value 

	# offset=0xd014
	# value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# echo $value
	# value=$((value & $((~0x10000))))
	# echo $value
	# value=$(printf "0x%x" "$value")
	# update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value 
	
	# offset=0xd214
	# value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# echo $value
	# value=$((value & $((~0x10000))))
	# echo $value
	# value=$(printf "0x%x" "$value")
	# update_register $((BASE_ADDR_WIZ0 + $offset)) "w" $value
	
	echo "++ PHY_RESET_N ++"
	offset=0x040c
	# value=$(read_register $((BASE_ADDR_WIZ0 + offset)))
	# value=$((value | 0xc0000000))
	# value=$(printf "0x%x" "$value")
	# echo $value
	update_register $((BASE_ADDR_WIZ0 + $offset)) "w" 0xa2800000 
	update_register $((BASE_ADDR_WIZ1 + $offset)) "w" 0x22800000
	update_register $((BASE_ADDR_WIZ2 + $offset)) "w" 0xa2800000
	update_register $((BASE_ADDR_WIZ4 + $offset)) "w" 0x22800000
	
	echo "++ Wait for cmn_ready assertion ++"
	# regmap_field_read_poll_timeout
	wait_for_register_value $((BASE_ADDR_WIZ0 + 0xe000)) 0x1 0x1 0.1 2
	if [ "$?" -eq "1" ]; then
		echo "stopping script..."
		exit 1
	fi

	# It is missing configurations

	#
	echo "++ Wait for phy_status ++"
	# regmap_field_read_poll_timeout
	wait_for_register_value $((BASE_ADDR_WIZ0 + 0xd014)) 0x10000 0x10000 0.1 2
	#wait_for_register_value $((BASE_ADDR_WIZ0 + 0xd014)) 0x20000 0x20000 0.1 2
	if [ "$?" -eq "1" ]; then
		echo "stopping script..."
		exit 1
	fi
	
}

BASE_ADDR_DBN=0xd800000
BASE_ADDR_CFG=0x2917000
BASE_ADDR_INTD=0x2910000
BASE_ADDR_CTRL_MMR=0x100000

init_pcie()
{
	header "INIT PCIE"

	# update_register $((BASE_ADDR_CFG + 0x0010)) "w" "0x0007"
	# 
	echo "++ j721e_pcie_set_link_speed ++"
	update_register $((BASE_ADDR_CTRL_MMR + 0x4074)) "w" "0x80"
	echo "++ j721e_pcie_set_mode ++"
	update_register $((BASE_ADDR_CTRL_MMR + 0x4074)) "w" "0x82"
	echo "++ j721e_pcie_set_lane_count ++"
	update_register $((BASE_ADDR_CTRL_MMR + 0x4074)) "w" "0x182"

	echo "++ j721e_pcie_config_link_irq ++"
	update_register $((BASE_ADDR_INTD + 0x108)) "w" "0x400"

	echo "++ reset ++"
	echo "PHY_RESET_N"
	sleep 0.0001
	update_register $((BASE_ADDR_CFG + 0x08)) "w" "0x1"
	exit 0
	echo "++ cdns_pcie_host_enable_ptm_response ++"
	value=$(read_register $((BASE_ADDR_DBN + 0x100da8)))
	# echo $value
	value=$(add_part $value 0x2 16 0x0000FFFF)
	# echo $value
	update_register $((BASE_ADDR_DBN + 0x100da8)) "w" $value

	echo "++ j721e_pcie_start_link ++"
	update_register $((BASE_ADDR_CFG + 0x4)) "w" "0x0"
	update_register $((BASE_ADDR_CFG + 0x4)) "w" "0x1"
	echo "++ j721e_pcie_link_up ++"
	update_register $((BASE_ADDR_CFG + 0x14))

	echo "++ cdns_pcie_host_init_root_port ++"
	update_register $((BASE_ADDR_DBN + 0x100300)) "w" "0x1e0000" 
	update_register $((BASE_ADDR_DBN + 0x100044)) "w" "0x104c104c"
	update_register $((BASE_ADDR_DBN + 0x200002)) "h" "0xb013"
	update_register $((BASE_ADDR_DBN + 0x200008)) "b" "0x0"
	update_register $((BASE_ADDR_DBN + 0x200009)) "b" "0x0"
	update_register $((BASE_ADDR_DBN + 0x20000a)) "h" "0x604"
	update_register $((BASE_ADDR_DBN + 0x200008))

	echo ""
	echo "++ cdns_pcie_host_init_address_translation  ++"
	update_register $((BASE_ADDR_DBN + 0x400004)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x40000c)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x400018)) "w" "0x1800000b"
	update_register $((BASE_ADDR_DBN + 0x40001c)) "w" "0x0"

	echo ""
	echo "++ cdns_pcie_set_outbound_region ++"
	update_register $((BASE_ADDR_DBN + 0x400020)) "w" "0x7"
	update_register $((BASE_ADDR_DBN + 0x400024)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x400028)) "w" "0x800002" 
	update_register $((BASE_ADDR_DBN + 0x40002c)) "w" "0x0"
	echo ""
	echo "++ Set the PCI address  ++"
	update_register $((BASE_ADDR_DBN + 0x400038)) "w" "0x7" 
	update_register $((BASE_ADDR_DBN + 0x40003c)) "w" "0x0"

	echo ""
	echo "++ Set the PCIe header descriptor  ++"
	update_register $((BASE_ADDR_DBN + 0x400040)) "w" "0x1800100f"
	update_register $((BASE_ADDR_DBN + 0x400044)) "w" "0x0"
	echo ""
	echo "++ Set the CPU address  ++"
	update_register $((BASE_ADDR_DBN + 0x400048)) "w" "0x800006"
	update_register $((BASE_ADDR_DBN + 0x40004c)) "w" "0x0"
	echo ""
	echo "**********"
	echo "++ cdns_pcie_set_outbound_region  ++"
	update_register $((BASE_ADDR_DBN + 0x400058)) "w" "0x1800100f" 
	update_register $((BASE_ADDR_DBN + 0x40005c)) "w" "0x0"
	echo ""
	echo "++ Set the PCI address  ++"
	update_register $((BASE_ADDR_DBN + 0x400060)) "w" "0x1801101a"
	update_register $((BASE_ADDR_DBN + 0x400064)) "w" "0x0"
	echo ""
	echo "++ Set the PCIe header descriptor  ++"
	update_register $((BASE_ADDR_DBN + 0x400068)) "w" "0x800002"
	update_register $((BASE_ADDR_DBN + 0x40006c)) "w" "0x0"
	echo ""
	echo "++ Set the CPU address  ++"
	update_register $((BASE_ADDR_DBN + 0x400078)) "w" "0x1801101a"
	update_register $((BASE_ADDR_DBN + 0x40007c)) "w" "0x0"
	echo ""
	echo "++ cdns_pcie_host_bar_ib_config  ++"
	update_register $((BASE_ADDR_DBN + 0x400810)) "w" "0x2f"
	update_register $((BASE_ADDR_DBN + 0x400814)) "w" "0x0"
	echo "**********"

	echo ""
	echo "++ cdns_ti_pcie_config_write ++"
	update_register $((BASE_ADDR_DBN + 0x004)) "w" "0x400"
	update_register $((BASE_ADDR_DBN + 0x004)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x010)) "w" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x010)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x014)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x014)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x038)) "h" "0xfffff800"
	update_register $((BASE_ADDR_DBN + 0x038)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x028)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x028)) "h" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x0e8)) "b" "0x400" 
	update_register $((BASE_ADDR_DBN + 0x03e)) "b" "0x2" 
	update_register $((BASE_ADDR_DBN + 0x084)) "b" "0x8008" 
	update_register $((BASE_ADDR_DBN + 0x208)) "b" "0x0"
	update_register $((BASE_ADDR_DBN + 0x220)) "h" "0x1"
	update_register $((BASE_ADDR_DBN + 0x224)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x224)) "h" "0x4"
	update_register $((BASE_ADDR_DBN + 0x228)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x228)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x22c)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x22c)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x230)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x230)) "h" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x234)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x234)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x238)) "h" "0xffffffff"
	update_register $((BASE_ADDR_DBN + 0x238)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x210)) "b" "0x4"
	update_register $((BASE_ADDR_DBN + 0x210)) "b" "0x3" 
	update_register $((BASE_ADDR_DBN + 0x210)) "b" "0x2" 
	update_register $((BASE_ADDR_DBN + 0x210)) "b" "0x1" 
	update_register $((BASE_ADDR_DBN + 0x210)) "b" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x130)) "h" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x110)) "h" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x104)) "h" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x0c8)) "b" "0x281f"
	update_register $((BASE_ADDR_DBN + 0x03e)) "b" "0x2"
	update_register $((BASE_ADDR_DBN + 0x018)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x03e)) "b" "0x2"
	update_register $((BASE_ADDR_DBN + 0x03e)) "b" "0x2"
	update_register $((BASE_ADDR_DBN + 0x006)) "b" "0xffff"
	update_register $((BASE_ADDR_DBN + 0x018)) "h" "0xff0100"

	update_register $((BASE_ADDR_DBN + 0x100000))

	echo ""
	echo "++ cdns_ti_pcie_config_write ++"
	update_register $((BASE_ADDR_DBN + 0x1a)) "b" "0x1"
	update_register $((BASE_ADDR_DBN + 0x3e)) "b" "0x2"
	update_register $((BASE_ADDR_DBN + 0x224)) "h" "0x18400004"
	update_register $((BASE_ADDR_DBN + 0x228)) "h" "0x0" "h"
	update_register $((BASE_ADDR_DBN + 0x30)) "h" "0xffff"
	update_register $((BASE_ADDR_DBN + 0x1c)) "b" "0xf0"
	update_register $((BASE_ADDR_DBN + 0x30)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x20)) "h" "0xfff0"
	update_register $((BASE_ADDR_DBN + 0x2c)) "h" "0x0"
	update_register $((BASE_ADDR_DBN + 0x24)) "h" "0xfff0"
	update_register $((BASE_ADDR_DBN + 0x28)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x2c)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x3e)) "w" "0x2"
	update_register $((BASE_ADDR_DBN + 0x3c)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0xdc)) "w" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x04)) "w" "0x4"
	update_register $((BASE_ADDR_DBN + 0xb2)) "w" "0xc000"
	# update_register $((BASE_ADDR_DBN + 0xb2)) "0x0" "w"

	value=$(read_register $((BASE_ADDR_DBN + 0x92)))
	value=$(add_part $value 0x180 16 0x0000FFFF)
	update_register $((BASE_ADDR_DBN + 0x92)) "w" $value

	update_register $((BASE_ADDR_DBN + 0xa0)) "w" "0x1"
	update_register $((BASE_ADDR_DBN + 0x92)) "w" "0x180"
	update_register $((BASE_ADDR_DBN + 0x94)) "w" "0x1040000"
	update_register $((BASE_ADDR_DBN + 0x98)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x9c)) "w" "0x0"

	value=$(read_register $((BASE_ADDR_DBN + 0x4)))
	value=$(add_part $value 0x404 0 0xFFFF0000)
	update_register $((BASE_ADDR_DBN + 0x4)) "w" $value

	value=$(read_register $((BASE_ADDR_DBN + 0x0092)))
	value=$(add_part $value 0x181 16 0x0000FFFF)
	update_register $((BASE_ADDR_DBN + 0x92)) "w" $value

	update_register $((BASE_ADDR_DBN + 0x00dc)) "w" "0x0" 
	update_register $((BASE_ADDR_DBN + 0x00e0)) "w" "0x10000"
	update_register $((BASE_ADDR_DBN + 0x00a0)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x00dc)) "w" "0x8"

	value=$(read_register $((BASE_ADDR_DBN + 0x00ca)))
	value=$(add_part $value 0x0 16 0x0000FFFF)
	update_register $((BASE_ADDR_DBN + 0x00ca)) "w" $value

	update_register $((BASE_ADDR_DBN + 0x00dc)) "w" "0x8"
	update_register $((BASE_ADDR_DBN + 0x0130)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x0110)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x0104)) "w" "0x0"
	update_register $((BASE_ADDR_DBN + 0x012c)) "w" "0x7"

	update_register $((BASE_ADDR_DBN))
}


# read_phy

# update_register $((BASE_ADDR_CFG + 0x0010))

# echo "++ j721e_pcie_set_link_speed ++"
# update_register $((BASE_ADDR_CTRL_MMR + 0x4074))
# echo "++ j721e_pcie_set_mode ++"
# update_register $((BASE_ADDR_CTRL_MMR + 0x4074))
# echo "++ j721e_pcie_set_lane_count ++"
# update_register $((BASE_ADDR_CTRL_MMR + 0x4074))

# echo "++ j721e_pcie_config_link_irq ++"
# update_register $((BASE_ADDRESS_INTD + 0x108))

init_phy
init_pcie
