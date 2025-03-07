# Crank Software Torizon Docker Containers Repository

This repository contains projects showcasing how to create Docker containers that package Storyboard applications for Torizon. It uses Weston as the Wayland compositor to manage the graphical stack and leverage GPU acceleration. The objective of this guide is for users to build and run their own Crank containers. **Please note that the runtime engine code is not included in these demos but can be found in the Storyboard installation path.**

## OVERVIEW

This guide highlights the process of creating a Crank container, a Docker container that packages a Storyboard application for deployment on your target device. For this example, we will utilize Weston as the Wayland compositor. Specifically, we will use a Weston container to manage the graphical stack, leveraging GPU acceleration and simplifying the development process.

However, you can choose to:
- **Build everything in one container**: This is another viable design choice.
- **Run the Crank container with a software render engine**: An alternative approach based on your needs.
- **Not use the Weston container**: Install the Wayland drivers directly on the base system (not recommended).

These are all design decisions that can be adapted based on your specific requirements and constraints.
In this repository you will find several projects for creating different images for different target devices. You can choose the one that best suits your needs. In some cases, you may need to make some changes to your system requirements

Link to [cheat sheet](/README-cheatsheet.md)

## PREREQUISITES
Before going through this guide, we advise you to have at least:
- Basic knowledge in Docker, sufficient to push, pull and run containers. 
- Basic knowledge in Storyboard, sufficient to understand its development concept.
- Basic knowledge in Command line, to execute basic instructions in shell.
-	Docker installed on the target device (installed by default in Torizon).
-	Torizon Core 6.x.y installed on the target device.
-	Display screen connected to the target device.
-	LAN connection to access internet from the target device
-	Docker installed on the host PC.
-	Storyboard installed on the host PC.
-	Visual Studio Code installed on the host PC.
-	Terra Term or similar installed on the host PC / Any Software to scann your network

## SET UP
This setup was used for building and testing. While it is not necessary to replicate it exactly, it serves as a useful guide.

Software:
- Storyboard v8.1
- Windows v10
- Terra Term v4.106
- Docker Desktop v4.25.2
- Docker Engine v24.0.6
- Visual Studio Code v1.87.0

Embedded software:
- Linux verdin-imx8mp-07174518 5.4.193-5.7.0+git.f78299297185 #1-TorizonCore SMP PREEMPT Mon Jul 11 14:42:03 UTC 2022 aarch64 aarch64 aarch64 GNU/Linux
- Docker v19.03.14-ce

Hardware:
- Toradex Verdin: <https://www.toradex.com/de/computer-on-modules/verdin-arm-family>
- Gechic Touch Monitor T151A: <https://www.gechic.com/de/touch-monitor>

## TARGET DEVICE PREPARATION: PULLING TORIZON CONTAINER TO ACCESS THE WAYLAND COMPOSITOR

Torizon OS is a container-based embedded system. Which means that the applications run in isolated environments called containers.
To run GPU accelerated applications on Linux in general you need some components in the userspace and some other components in the kernel space. 
The Crank application, when using GPU acceleration, needs access to the OpenGL graphics API. For that we need to run first the Torizon base container with the Graphical libraries.
Different devices require different configurations, this is way Torizon provides different base containers for different platforms.
a couple of examples of this:

- Command to run Wayland based container on a IMX8 in Torizon OS 6:
`docker run -e ACCEPT_FSL_EULA=1 -d --rm --name=weston --net=host --cap-add CAP_SYS_TTY_CONFIG  -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 199:* rmw' --device-cgroup-rule='c 226:* rmw' torizon/weston-vivante:$CT_TAG_WESTON_VIVANTE --developer --tty=/dev/tty7`

- Command to run Wayland based container on a TI62 in Torizon OS 6:
`docker run -e ACCEPT_FSL_EULA=1 -d --rm --name=weston --net=host --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 226:* rmw' torizon/weston-am62:$CT_TAG_WESTON --developer --tty=/dev/tty7`

Notes:
- Note1: if you run this command and the image is not in your system docker will automatically look for it on the internet, pull it first and run it after.
- Note2: The CT_TAG variables are already set on Torizon. Example, on your IMX8 you can echo ${CT_TAG_WAYLAND_BASE_VIVANTE}
- Note3: Torizon OS 6 command references to run Weston container on different platforms: <https://developer.toradex.com/torizon/application-development/use-cases/gui/web-browser-kiosk-mode-with-torizoncore/>

After successfully launching your weston container you should see a grey screen (may be blue or different color depending on the container you are using) that looks like this:

![alt text](/images/weston_container_up.png?raw=true)

if you run docker `-ps` you should see the container with the status `Up`:

![alt text](/images/weston_container_ps_up.PNG?raw=true)

Notes: 
- Note1: To enter your container you can use this command: 	
`docker exec -t -i [ContainerID] /bin/bash`
- Note2: To check Weston Information, you can run:	
`weston --version`
weston-info
- Note3: Find your weston.ini configuration with this command:	
`find / -name *weston.ini*`
- Note4: To edit the weston.ini file you probably must copy it outside the container first, edit it and copy it back inside.

## BUILDING YOUR CRANK CONTAINER
We have created several Visual Studio Code projects than you can build on your PC. Here is an example of how the projects structure looks like:

![alt text](/images/project_structure.png?raw=true)

-	*apps*: Here you can place your application. We have packed some already
-	*runtimes*: This is a place holder for you to place the sbengine suitable for your device
-	*docker_sbengine.sh*: This is the launching script and should be edited to match your paths and project requirements.
-	*Dockerfile*: To build your docker image


### APPS: EXPORTING YOUR SB APPLICATION
There are four components that will be part of your container. The first one is your Storyboard application. We have packed some samples already.
Eventually, you will create your own application. For quick testing you can also select a different sample demo from the demos that we ship within Storyboard (File>>import>>Storyboard Development>>Storyboard Sample) or alternatively, as we did for this projects, you can grab one demo app from our repository: 
<https://github.com/crank-software/storyboard-demos>
Once you open your project in Storyboard, from the Storyboard Application Export Configuration window you can choose gapp packager, Filesystem transfer method and export your project to the apps directory.

![alt text](/images/sb_project_export.png?raw=true)

### RUNTIMES: EXPORTING YOUR SB ENGINE
The second bit is straightforward coping the runtime engine from the storyboard installation path to the runtimes directory created in the Visual Studio Code project.
Example, for the IMX8 you would use the linux-imx8yocto-armle-opengles_2.0-wayland-obj runtime:

![alt text](/images/sb_engine_selection.PNG?raw=true)

### DOCKER_SBENGINE.SH: EDITING THE LAUNCHING SCRIPT
The third step consists of, if necessary, editing and adapting the lunch script to your system needs.
On the one we have written and packed, the workflow goes as this: after the container is launched, we look into the scp folder first, and if we don't find a .gapp file there we launch the "default" application which is the one we have packed on the apps folder. This will allow you to run a different application if you want to by simply deploying another app to the scp directory, rather that rebuilding the container.

Notes:
-	Note1: Options that you can pass to the engine: <https://support.cranksoftware.com/hc/en-us/articles/360056945652-Storyboard-Engine-Plugin-Options> 
-	Note2: The path for the Wayland libraries as well as the for the XDG_RUNTIME_DIR and WAYLAND_DISPLAY variables and the mapping of the touch events may differ on your target device, so you need to inspect your base container. After you launch the base container, you may want to open it and look inside using this command: 
`docker exec -t -i [ContainerID] /bin/bash `
-	Note3: if you are working on a windows machine, you may need to modify the line ending of your script to properly crosscompile since windows ends lines with \r\n whereas Linux does it with \n. A quick way of doing that would be using the Replace function in Notepad++

### DOCKERFILE: BUILDING AND RUNNING
The four and last part is to, if necessary, edit the dockerfile, and build the project:

To build you can use something like this:

#build
`docker build -t crank_imx8_sb_8_1_weston-vivante_2 v:0.1 .`

#tag
`docker tag crank_imx8_sb_8_1_weston-vivante_2 cranksoftware/crank_imx8_sb_8_1_weston-vivante_2:v0.1`

#push
`docker push cranksoftware/crank_imx8_sb_8_1_weston-vivante_2:v0.1`

Here is the docker hub link to some of our projects <https://hub.docker.com/u/cranksoftware>

Notes:
-	Note1: When you copy the engine, some of the binary files have read and write permission only, but they need to be executable as well in Linux. If you were working on a Linux machine and deploy to a Linux target these permissions will be transfer as set on the host machine, if you otherwise use Windows you will need to explicitly force it using --chmod=777 
-	Note2: to use the --chmod=777 in Windows you need to explicitly configure Docker Engine by setting the buildkit to false:
`"features": { "buildkit": false } `

## PULLING AND RUNNING YOUR PROJECT ON TARGET
You can now pull and run the container on your target device running the a `docker run` command.
The flags you need to set will vary depending on the target device you are using. For example the `-v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw'` flag enables the use of GPU on the Verdin iMX8M Plus, where for the TI62 to get access to the GPU you need to set `--device-cgroup-rule='c 226`. Here a couple of examples

- Command to run the Crank container on a IMX8 in Torizon OS 6:
`docker run -it --rm --name=crank -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus -v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw'  cranksoftware/crank_imx8_sb_8_1_weston-vivante_3:v0.1 `

- Command to run the Crank container on a TI62 in Torizon OS 6:
`docker run -it --rm --name=crank -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus -v /dev/dri:/dev/dri  --device-cgroup-rule='c 226:* rmw'  cranksoftware/crank_ti62_sb_8_1_weston_am62_3:v0.1 `

## CONTRIBUTIONS

We welcome contributions from the community! If you have a demo that showcases Storyboard's integration with external tools, feel free to submit a pull request. Please ensure your demo includes:

- A clear and concise README file
- Step-by-step setup instructions
- Descriptions of the external tools used
- Any necessary code or configuration files

## SUPPORT

If you encounter any issues or have questions about the demos, please contact [Crank Software Support](https://support.cranksoftware.com/hc/en-us/requests/new).




