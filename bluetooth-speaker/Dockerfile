# Use the official Home Assistant base image
FROM homeassistant/home-assistant:latest

# Install PulseAudio and Bluetooth-related packages
RUN apk update && \
    apk add --no-cache pulseaudio pulseaudio-alsa alsa-plugins-pulse pulseaudio-bluez bluez dbus pulseaudio-utils

# Copy the run script into the image
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set the default command to run the script
CMD ["/run.sh"]