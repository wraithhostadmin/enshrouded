FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG PROTON_VERSION=GE-Proton9-27

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
    wget curl tar \
    xvfb \
    wine wine32 wine64 \
    lib32gcc-s1 \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD
RUN mkdir -p /opt/steamcmd \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    | tar -zxvf - -C /opt/steamcmd

# GE-Proton in /opt so it survives volume mount
RUN mkdir -p /opt/proton \
    && curl -sqL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${PROTON_VERSION}/${PROTON_VERSION}.tar.gz" \
    | tar -zxvf - -C /opt/proton --strip-components=1 \
    && chmod -R 777 /opt/proton

# Writable dirs for Proton and Xvfb
RUN mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && mkdir -p /opt/proton-data \
    && chmod 777 /opt/proton-data

ENV PATH="/opt/steamcmd:${PATH}"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH=/opt/proton
ENV STEAM_COMPAT_DATA_PATH=/opt/proton-data
ENV DISPLAY=:1
ENV WINEDEBUG=-all

RUN useradd -m -d /home/container container
RUN chown -R container:container /home/container
WORKDIR /home/container
USER container

CMD ["bash", "start.sh"]
