ARG BUILD_FROM
FROM $BUILD_FROM

# Install pulseaudio and bluetooth-related packages
RUN apt-get update && \
    apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez bluetoothctl && \
    apt-get clean

# Add run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]