#!/bin/bash

# Function to start services with error checking
start_service() {
    "$@"  # Run the command
    if [ $? -ne 0 ]; then
        echo "Failed to start $1" >&2
        exit 1
    fi
}

# Start D-Bus daemon
start_service dbus-daemon --system --fork

# Start Bluetooth daemon
start_service bluetoothd &

# Wait for services to initialize
sleep 2

# Start PulseAudio server
start_service pulseaudio --start --system

# Give some time for D-Bus and Bluetooth to start
sleep 2

# Initialize Bluetooth settings
bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent
bluetoothctl discoverable on
bluetoothctl pairable on

# Load PulseAudio Bluetooth modules
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

# Monitor for new Bluetooth sources and route them automatically
while true; do
    route_bluetooth_audio
    sleep 5  # Check for new connections every 5 seconds
done
