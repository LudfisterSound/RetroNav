# RetroNav software: Pi image

The image is Raspberry Pi OS Lite (64-bit, Trixie) with [LIVI](https://github.com/f-io/LIVI) as the head unit. It boots straight to the LIVI kiosk on the touchscreen: no desktop and no login.

## Getting an image

- **Download:** run the **Pi image** workflow from the repo's Actions tab. The `.img.xz` is attached to the run.
- **Build locally:** `image/build.sh` (needs Docker; uses [pi-gen](https://github.com/RPi-Distro/pi-gen)). Output goes to `image/deploy/`.

Flash the image with Raspberry Pi Imager. Before first boot, edit `retronav.conf` on the SD card's boot partition:

| Setting | Meaning |
|---------|---------|
| `MFI=yes` | An Apple MFi coprocessor is wired to the Pi's I2C pins (native CarPlay) |
| `MFI=no` | MFi comes from a LIVI Link dongle over USB (default) |
| `SPLASH` | `yes` shows LIVI's boot splash |

First boot runs LIVI's installer offline (about 1–2 minutes) and then reboots into LIVI. Default login for SSH is `retronav` / `retronav`, so change it.

## What's in the image

- LIVI AppImage and all of its runtime packages, preinstalled so the car needs no network
- LIVI's headless installer, run once on first boot (`retronav-firstboot.service`)
- Boot-time tuning: no boot delay or rainbow splash, quiet kernel, and update/maintenance timers disabled
- I2C enabled for an MFi chip or sensors

## How CarPlay gets authenticated

LIVI runs the CarPlay protocol itself. The iPhone still needs an Apple MFi authentication chip, which can't be emulated. There are two options:

1. **LIVI Link:** a Carlinkit dongle reflashed with LIVI's firmware (`livi-link-provision`). It supplies MFi, Wi-Fi, and Bluetooth over USB. This is the simplest route.
2. **On-board coprocessor:** an MFi chip on I2C (`MFI=yes`).

## What theming can reach

Apple's public CarPlay tools (Xcode 26.5 simulator, iOS 26.5 SDK) offer no head-unit control over CarPlay's own look, gauges, or vehicle data. LIVI can use car-maker themes that already ship in iOS (CarPlay Ultra), but a custom theme inside CarPlay is unlikely. RetroNav's vintage look lives in LIVI's own UI: the dashboard, gauge layouts, frame, and cluster screen.
