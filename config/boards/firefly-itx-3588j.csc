# Rockchip RK3588j Octa core 4GB-32GB eMMC GBE HDMI HDMI-IN PCIe SATA USB3 WiFi 4G 5G
BOARD_NAME="Firefly ITX-3588J"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER="SeeleVolleri"
BOOTCONFIG="rock-5b-rk3588_defconfig"
KERNEL_TARGET="vendor"
BOOT_FDT_FILE="rockchip/rk3588-firefly-itx-3588j.dtb"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
declare -g UEFI_EDK2_BOARD_ID="firefly-itx-3588j" # This _only_ used for uefi-edk2-rk3588 extension

function post_family_tweaks_bsp__firefly_itx_3588j() {
	display_alert "$BOARD" "Installing rk3588-bluetooth.service" "info"

	# Bluetooth on this board is handled by a Broadcom (AP6275PR3) chip and requires
	# a custom brcm_patchram_plus binary, plus a systemd service to run it at boot time
	install -m 755 $SRC/packages/bsp/rk3399/brcm_patchram_plus_rk3399 $destination/usr/bin
	cp $SRC/packages/bsp/rk3399/rk3399-bluetooth.service $destination/lib/systemd/system/rk3588-bluetooth.service

	# Reuse the service file, ttyS0 -> ttyS6; BCM4345C5.hcd -> BCM4362A2.hcd
	sed -i 's/ttyS0/ttyS6/g' $destination/lib/systemd/system/rk3588-bluetooth.service
	sed -i 's/BCM4345C5.hcd/BCM4362A2.hcd/g' $destination/lib/systemd/system/rk3588-bluetooth.service
	return 0
}

function post_family_tweaks__firefly_itx_3588j_naming_audios() {
	display_alert "$BOARD" "Renaming firefly-itx-3588j audios" "info"
	mkdir -p $SDCARD/etc/udev/rules.d/
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmi0-sound", ENV{SOUND_DESCRIPTION}="HDMI0 Audio"' > $SDCARD/etc/udev/rules.d/90-naming-audios.rules
	return 0
}

function post_family_tweaks__firefly_itx_3588j_enable_services() {
	display_alert "$BOARD" "Enabling rk3588-bluetooth.service" "info"
	chroot_sdcard systemctl enable rk3588-bluetooth.service
	return 0
}
