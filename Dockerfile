FROM debian:12-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG GE_PROTON_VERSION=10-26

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
    procps ca-certificates winbind dbus \
    libfreetype6 curl jq locales \
    lib32gcc-s1 python3 \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD
RUN mkdir -p /opt/steamcmd \
    && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    | tar -zxvf - -C /opt/steamcmd

# Bootstrap SteamCMD to create linux64 directory and steamclient.so
RUN /opt/steamcmd/steamcmd.sh +quit || true

# Steam SDK symlinks — fixes Steamworks initialization
RUN ln -s /opt/steamcmd/linux64/steamclient.so /usr/lib/x86_64-linux-gnu/steamclient.so 2>/dev/null || true \
    && ln -s /opt/steamcmd/linux32/steamclient.so /usr/lib/i386-linux-gnu/steamclient.so 2>/dev/null || true

# GE-Proton inside SteamCMD compatibility tools
RUN mkdir -p /opt/steamcmd/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION} \
    && curl -sqL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz" \
    | tar -zxvf - -C /opt/steamcmd/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION} --strip-components=1

ENV PATH="/opt/steamcmd:${PATH}"
ENV WINEDEBUG=-all
ENV GE_PROTON_VERSION=${GE_PROTON_VERSION}

RUN useradd -m -d /home/container container
RUN chown -R container:container /home/container
WORKDIR /home/container
USER container

CMD ["bash", "start.sh"]
