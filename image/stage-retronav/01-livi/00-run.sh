#!/bin/bash -e
# Bakes LIVI and its installer into the image. build.sh has already fetched
# them into files/. The installer needs a running systemd, so it runs once on
# first boot (retronav-firstboot.service).

HOME_DIR="${ROOTFS_DIR}/home/${FIRST_USER_NAME}"
LIVI_DIR="${ROOTFS_DIR}/opt/retronav/livi"

# Same layout as the LIVI repo, since the installer finds assets via ../../assets.
install -d "${LIVI_DIR}/scripts"
cp -r files/livi-src/scripts/install "${LIVI_DIR}/scripts/"
cp -r files/livi-src/assets "${LIVI_DIR}/"
# Packages are already in the image: skip 'apt-get update', which fails offline.
sed -i 's/sudo apt-get update && sudo apt-get install -y/sudo apt-get install -y --no-download/' \
	"${LIVI_DIR}/scripts/install/common.sh"

install -d -o 1000 -g 1000 "${HOME_DIR}/LIVI"
install -m 0755 -o 1000 -g 1000 files/LIVI.AppImage "${HOME_DIR}/LIVI/LIVI.AppImage"

install -m 0755 files/retronav-firstboot.sh "${ROOTFS_DIR}/opt/retronav/retronav-firstboot.sh"
install -m 0644 files/retronav-firstboot.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 0644 files/retronav.conf "${ROOTFS_DIR}/boot/firmware/retronav.conf"
sed -i "s/@USER@/${FIRST_USER_NAME}/g" \
	"${ROOTFS_DIR}/etc/systemd/system/retronav-firstboot.service"

on_chroot <<CHROOT
systemctl enable retronav-firstboot.service
CHROOT
