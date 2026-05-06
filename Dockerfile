FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG PROTON_VERSION=GE-Proton9-27

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
    wget curl tar xvfb \
    wine wine32 wine64 \
    lib32gcc-s1 \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD
RUN mkdir -p /opt/steamcmd \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    | tar -zxvf - -C /opt/steamcmd

# GE-Proton — install to home directory so it's writable
RUN mkdir -p /home/container/proton \
    && curl -sqL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${PROTON_VERSION}/${PROTON_VERSION}.tar.gz" \
    | tar -zxvf - -C /home/container/proton --strip-components=1

ENV PATH="/opt/steamcmd:${PATH}"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/container/proton
ENV STEAM_COMPAT_DATA_PATH=/home/container/.proton
ENV DISPLAY=:1

RUN useradd -m -d /home/container container
RUN chown -R container:container /home/container
WORKDIR /home/container
USER container

CMD ["bash", "start.sh"]
