
# Docker Commands Cheat Sheet

-------------------
### VISUAL CODE
-------------------

#### build example
`docker build -t imx8-sb_8_1-wayland-base-vivante_3 .`

#### tag example
`docker tag imx8-sb_8_1-wayland-base-vivante_3 cranksoftware/imx8-sb_8_1-wayland-base-vivante_3:v0.1`

#### push example
`docker push cranksoftware/imx8-sb_8_1-wayland-base-vivante_3:v0.1`

-------------------
### TARGET 
-------------------

### TI62 TORIZON OS 6

#### run weston container

`docker run -e ACCEPT_FSL_EULA=1 -d --rm --name=weston --net=host --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 226:* rmw' torizon/weston-am62:$CT_TAG_WESTON --developer --tty=/dev/tty7`

#### run crank container [ GPU access TI62: --device-cgroup-rule='c 226 ]
`docker run -it --rm --name=crank -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus -v /dev/dri:/dev/dri  --device-cgroup-rule='c 226:* rmw'  cranksoftware/crank_ti62_sb_8_1_weston_am62_3:v0.1`

------------------

### IMX8 TORIZON OS 6

#### run weston container

`docker run -e ACCEPT_FSL_EULA=1 -d --rm --name=weston --net=host --cap-add CAP_SYS_TTY_CONFIG  -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 199:* rmw' --device-cgroup-rule='c 226:* rmw' torizon/weston-vivante:$CT_TAG_WESTON_VIVANTE --developer --tty=/dev/tty7`

#### run crank container [ GPU access Imx8 -v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw' ]

`docker run -it --rm --name=crank -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus -v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw'  cranksoftware/imx8-sb_8_1-wayland-base-vivante_3:v0.1`
