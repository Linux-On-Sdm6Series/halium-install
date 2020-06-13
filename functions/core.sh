#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs_to_img() {
	image_size=$1

	qemu-img create -f raw "$IMAGE_DIR/rootfs.img" $image_size
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F "$IMAGE_DIR/rootfs.img"
	sudo mount "$IMAGE_DIR/rootfs.img" "$ROOTFS_DIR"
	sudo tar --numeric-owner -xpf "$ROOTFS_TAR" -C "$ROOTFS_DIR"
}

function convert_rootfs_to_dir() {
	sudo tar --numeric-owner -xpf "$ROOTFS_TAR" -C "$ROOTFS_DIR"
}

function convert_androidimage() {
	if file "$AND_IMAGE" | grep "ext[2-4] filesystem"; then
		cp "$AND_IMAGE" "$IMAGE_DIR/system.img"
	else
		simg2img "$AND_IMAGE" "$IMAGE_DIR/system.img"
	fi
}

function shrink_images() {
	[ -f "$IMAGE_DIR/system.img" ] && sudo e2fsck -fy "$IMAGE_DIR/system.img" >/dev/null || true
	[ -f "$IMAGE_DIR/system.img" ] && sudo resize2fs -p -M "$IMAGE_DIR/system.img"
}

function inject_androidimage() {
	# Move android image into rootfs location (https://github.com/Halium/initramfs-tools-halium/blob/halium/scripts/halium#L259)
	sudo mv "$IMAGE_DIR/system.img" "$ROOTFS_DIR/var/lib/lxc/android/"

	# Make sure the mount path is correct
	if chroot_run "command -v dpkg-divert"; then # On debian distros, use dpkg-divert
		chroot_run "dpkg-divert --add --rename --divert /lib/systemd/system/system.mount.image /lib/systemd/system/system.mount"
		sed 's,/data/system.img,/var/lib/lxc/android/system.img,g' "$ROOTFS_DIR/lib/systemd/system/system.mount.image" | sudo tee -a "$ROOTFS_DIR/lib/systemd/system/system.mount" >/dev/null 2>&1
	else # Else just replace the path directly (not upgrade safe)
		sed -i 's,/data/system.img,/var/lib/lxc/android/system.img,g' "$ROOTFS_DIR/lib/systemd/system/system.mount.image"
	fi
}

function unmount() {
	sudo umount "$ROOTFS_DIR"
}

function flash_img() {
	mkdir -p out
	if $DO_ZIP ; then
		echo "Repack Rootfs						"
		pigz --fast "$IMAGE_DIR/rootfs.img					"
		echo "Move Rootfs To Host				"

		echo "Repack System						"
		pigz --fast "$IMAGE_DIR/system.img					"
		echo "Move System To Host				"
		mv "$IMAGE_DIR/"*.img.gz out/
		mv out/*.img.gz flashable-sar/data/
	else
		echo "Move Rootfs To Out				"
		echo "Move System To Out				"
		mv "$IMAGE_DIR/"*.img out/
		mv out/*.img flashable-sar/data/
#		echo "Download Vendor With Google Drive						"
#		wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1jUs5qo6Op06iglOafE4ifizZGdpci2b0' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1jUs5qo6Op06iglOafE4ifizZGdpci2b0" -O flashable-legacy/data/vendor.img && rm -rf /tmp/cookies.txt
#		echo "Create Flashable Zip 					"
#		cd flashable-legacy
#		zip -rv9 UbPorts-16.04-Legacy-whyred-$(date +"%m""%d"-"%H""%M").zip ubports.sh tools data META-INF
#		cd ..
	fi

	if $SYSTEM_AS_ROOT; then
		echo "Rename Android Legacy Rootfs To System-As-Root Rootfs		"
		mv flashable-sar/data/system.img flashable-sar/data/android-rootfs.img
		echo "Download Vendor With Google Drive						"
		wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1DTesz7zqbH_CuzM_PIMlEns75iB8lagt' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1DTesz7zqbH_CuzM_PIMlEns75iB8lagt" -O flashable-sar/data/vendor.img && rm -rf /tmp/cookies.txt
		cd flashable-sar
		echo "Create Flashable Zip"
		zip -rv9 UbPorts-16.04-SAR-whyred-$(date +"%m""%d"-"%H""%M").zip ubports.sh tools data META-INF
		cd ..
		rm -rf flashable-sar/data/*.img
		rm -rf out
	fi
}

function flash_dir() {
	echo "Done							"
}

# function clean() {
# 	echo "Done								"
# }

# function clean_device() {
# 	echo "Done						"
# }

function clean_exit() {
#	echo "Done							"
	unmount || true
# 	clean || true
#	clean_device || true
}
