#!/bin/bash
# Runs LIVI's headless installer once, offline, against the AppImage baked
# into the image, then reboots straight into the LIVI kiosk.
set -euo pipefail

CONF=/boot/firmware/retronav.conf
MFI=no
SPLASH=yes
# shellcheck source=/dev/null
[ -f "$CONF" ] && . "$CONF"

export LIVI_CHANNEL=release
export LIVI_MFI="$MFI"
export LIVI_SPLASH="$SPLASH"
export LIVI_HDMI_PR=no

bash /opt/retronav/livi/scripts/install/headless/install.sh "$HOME/LIVI/LIVI.AppImage" </dev/null

sudo install -d /var/lib/retronav
sudo touch /var/lib/retronav/firstboot.done
sudo systemctl disable retronav-firstboot.service
sudo systemctl reboot
