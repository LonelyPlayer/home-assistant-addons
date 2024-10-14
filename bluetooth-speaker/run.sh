#!/bin/bash
# Start pulseaudio
pulseaudio --start --log-target=syslog

# Start bluetooth service
bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent
bluetoothctl discoverable on
bluetoothctl pairable on

# Automatically load pulseaudio modules for Bluetooth devices
pactl load-module module-bluetooth-policy
pactl load-module module-bluetooth-discover

# Optionally, set a default audio sink (e.g., HDMI, speakers, etc.)
DEFAULT_SINK=$(pactl info | grep 'Default Sink' | awk '{print $3}')

# Function to route audio from all available Bluetooth sources to the default sink
route_bluetooth_audio() {
    for source in $(pactl list short sources | grep bluez | awk '{print $2}'); do
        if ! pactl list modules short | grep -q "module-loopback.*source=$source"; then
            echo "Routing Bluetooth audio from $source to $DEFAULT_SINK"
            pactl load-module module-loopback source=$source sink=$DEFAULT_SINK
        fi
    done
}

# Monitor for new Bluetooth sources and route them automatically and keep the container alive
while true; do
    route_bluetooth_audio
    sleep 5  # Check for new connections every 5 seconds
done
