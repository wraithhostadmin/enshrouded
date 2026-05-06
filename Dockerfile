FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# 32-bit support for Wine
RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
    wget curl tar xvfb \
    wine wine32 wine64 \
    lib32gcc-s1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD
RUN mkdir -p /opt/steamcmd \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    | tar -zxvf - -C /opt/steamcmd

ENV PATH="/opt/steamcmd:${PATH}"
ENV WINEDEBUG=-all
ENV WINEPREFIX=/home/container/.wine
ENV DISPLAY=:0

RUN useradd -m -d /home/container container
WORKDIR /home/container
USER container

CMD ["bash", "start.sh"]
