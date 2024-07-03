#FROM torizon/weston-vivante:3
FROM --platform=linux/arm64 torizon/wayland-base-vivante:3

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    libwayland-dev \
    net-tools \
    procps \
    mtdev-tools \
    libxkbcommon0 \
    libc6 \
    libts-dev \
    libasound2 \
&& apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY --chown=root:root --chmod=777 crank /usr/crank/
RUN mkdir -p /usr/crank
RUN chmod +x /usr/crank/docker_sbengine.sh

CMD /usr/crank/docker_sbengine.sh
#ENTRYPOINT ["/usr/crank/docker_sbengine.sh"]