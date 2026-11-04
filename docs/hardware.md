# RetroNav hardware: parts list and architecture

This is a from-scratch CarPlay head unit built from off-the-shelf parts. The goals are, in order: easy to find, fast enough, simple to put together, and cheap. Physical mounting in the car is up to the builder.

## How it works

An iPhone only starts CarPlay with an accessory that has Apple's MFi authentication chip. LIVI runs the CarPlay protocol natively on the Pi, including the CarPlay Ultra cluster stream. A Carlinkit dongle reflashed as a **LIVI Link** supplies the MFi chip plus Wi-Fi and Bluetooth over USB. An MFi chip wired to the Pi's I2C bus also works. See [software.md](software.md).

```
 iPhone ──(wired USB or wireless Wi-Fi/BT)──> Carlinkit CPC200-CCPA
                                                   │ USB (H.264 video + audio, touch)
                                                   v
 Touchscreen <──DSI/HDMI── Raspberry Pi 5 ──I2S──> DAC/amp ──> speakers or existing amp
                              │   │   └──USB──> microphone (Siri, calls)
                              │   └──CSI/USB──> backup camera and dashcams (step 5)
                              └──GPIO──> ignition sense and safe-shutdown power board
                                             ^
                       car battery (6V/12V, either ground polarity) ── isolated DC-DC
```

Software: [LIVI](https://github.com/f-io/LIVI) (primary), with react-carplay/node-carplay as a fallback. LIVI is actively maintained, runs on Pi 4/5 with hardware video decoding on Raspberry Pi OS Trixie, and also supports Android Auto. RetroNav adds the theming, camera, and power-management layers on top (step 2).

## Bill of materials

Prices are approximate US street prices as of late 2026.

| # | Part | Recommended | Approx. | Notes |
|---|------|-------------|---------|-------|
| 1 | Computer | Raspberry Pi 5, 4 GB | $60 | Hardware HEVC decode, 2x CSI camera ports, PCIe for NVMe. A Pi 4 (2 GB+) works on a tight budget but can't handle multi-camera dashcam well. |
| 2 | Cooling | Official Pi 5 Active Cooler | $5 | Required: cabins get hot in summer. |
| 3 | CarPlay dongle | Carlinkit **CPC200-CCPA** | $50–70 | Reflashed as a LIVI Link (MFi + radios). Check LIVI-LINK.md for supported firmware before buying. Avoid "wired-to-wireless" adapters, which need a factory CarPlay head unit. |
| 4 | Display (default) | Raspberry Pi Touch Display 2, 7" (720×1280, DSI) | $60 | Official part, always in stock, no driver hassle, used in landscape. |
| 4a | Display (alt) | Waveshare 7" HDMI capacitive, 1024×600 | $50 | Choose this when the screen must sit away from the Pi. |
| 4b | Display (vintage alt) | Waveshare 5" round HDMI touch (1080×1080) | $75 | Fits a round gauge-style hole. CarPlay is letterboxed inside the round frame. |
| 5 | Audio out | I2S DAC HAT (e.g. InnoMaker/HiFiBerry DAC+ class) | $20–30 | The Pi 5 has no analog jack. Line out goes to an amp. |
| 5a | Audio out (no amp in car) | I2S amp HAT (e.g. HiFiBerry MiniAmp/Amp4 class) | $25–60 | Drives speakers directly. |
| 6 | Microphone | USB clip-on/boundary mic | $10–15 | For Siri and calls. Mount it near the driver. |
| 7 | Power | Isolated wide-input DC-DC to 5 V / 5 A | $15–25 | The isolated type works on 6 V and 12 V systems, positive or negative ground. Exact part chosen in step 3. |
| 8 | Safe shutdown | Ignition-sense input plus hold-up (supercap or small UPS HAT) | $10–40 | Keeps the SD card from corrupting when the key turns off. Designed in step 3. |
| 9 | Storage | 64 GB high-endurance microSD | $12 | For the OS. Add an M.2 HAT+ with NVMe (~$40) if using dashcam recording. |
| 10 | Cables | Short USB-A to USB-C (for the dongle), fuse holder, wire | $10 | Fuse at the battery feed. |

**Core build (items 1–4, 5, 6, 7–10): about $250–300.** Cameras are listed separately in step 5.

## How the vintage-specific requirements are handled

- **Theme:** iOS renders everything inside the CarPlay window, so we can't restyle it beyond iOS's own wallpaper and dark mode settings. RetroNav themes everything around that window instead: the boot screen, frame and bezel graphics, home screen, gauges, camera views, and fonts. CarPlay can also be shown inside a chrome or Bakelite-style frame. This is the closest practical equivalent of CarPlay Ultra's custom look.
- **Fast wireless connect:** the dongle reconnects to a paired iPhone on its own. The main delay is Pi boot time, so step 2 targets a cold boot to a working screen in under ~15 s. Options include a minimal OS image, starting LIVI first, and optionally keeping the Pi in a low-power standby state instead of off.
- **Vehicle data:** CarPlay Ultra's gauge features come from the car's own systems. Here, that's whatever sensors the builder connects to the Pi (GPIO/I2C/ADC, e.g. oil pressure, temperature, speed via GPS). RetroNav shows these on its own themed screens, but iOS won't put them inside the CarPlay UI.

## Open questions

- Does LIVI take the mic from the Pi or from the dongle? To check on hardware.
- Tethered mode also gets power through the CCPA, so check that the Pi's USB port supplies enough current to charge the phone.
