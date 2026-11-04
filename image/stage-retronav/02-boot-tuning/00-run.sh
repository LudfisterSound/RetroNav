#!/bin/bash -e
# Faster cold boot: the phone can't connect until LIVI is up.
CONFIG="${ROOTFS_DIR}/boot/firmware/config.txt"
CMDLINE="${ROOTFS_DIR}/boot/firmware/cmdline.txt"

cat >> "${CONFIG}" <<'CFG'

[all]
# RetroNav
boot_delay=0
disable_splash=1
# Allow full clocks during boot (Pi 4/5).
initial_turbo=30
# I2C for an on-board MFi coprocessor or sensors.
dtparam=i2c_arm=on
CFG

grep -q 'loglevel=' "${CMDLINE}" || sed -i 's/$/ quiet loglevel=3 logo.nologo/' "${CMDLINE}"

on_chroot <<'CHROOT'
for unit in apt-daily.timer apt-daily-upgrade.timer man-db.timer e2scrub_reap.service \
	NetworkManager-wait-online.service triggerhappy.service ModemManager.service \
	keyboard-setup.service; do
	systemctl disable "$unit" 2>/dev/null || true
done
CHROOT
