# WesTek HA Dashboard

A lightweight macOS dashboard app for controlling smart home devices via MQTT.

## Features

- Connects to a Mosquitto MQTT broker to monitor and control Sonoff devices
- LED-style status indicators (green = on, red = off) for each device
- Tap to toggle devices on/off
- Always-on-top floating window for easy access
- Queries device state on startup for accurate status

## Devices

- **Lamp** — `stat/sonoff/office/lamp/POWER`
- **Party Lights** — `stat/sonoff/office/partylights/POWER`

## Requirements

- macOS 13+
- Xcode 15+
- [CocoaMQTT](https://github.com/emqx/CocoaMQTT) 2.2.3 (added via Swift Package Manager)

## Setup

1. Open `Westek HA Dashboard.xcodeproj` in Xcode
2. Build and run (Cmd+R)
3. The app connects to the MQTT broker at `172.16.100.11:1883`
