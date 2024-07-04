# PoliTO OS/161 Docker
[![Build Status](https://app.travis-ci.com/marcopalena/polito-os161-docker.svg?token=TwUrTvqp6M7vKrhM3xmD&branch=main)](https://app.travis-ci.com/marcopalena/polito-os161-docker)

A compact Docker image to compile, run and debug the teaching operating system OS/161. Built for the courses "System and Device Programming" (01NYHOV) and "Programmazione di Sistema" (02GRSOV) at Politecnico di Torino. The image is based on Ubuntu 20.04 and contains the following components:
- OS/161 sources
- System/161
- Build toolchain (gcc, gdb, etc.)

## Set up a remote development environment
To work on the course assignments running OS/161 inside the container, you need to set up a remote development environment on your host machine first. In the following you can find the instructions on how to set up such an environment using VSCode on different platforms. In the proposed setup we leverage the remote development capabilities of VSCode to:
 - Access, edit and compile source code of OS/161 stored in a named volume that is mounted into the container.
 - Run and debug both the kernel and user programs executing on System/161 inside the container.

Follow the appropriate instructions to set up the remote development environment on your platform.

### Linux
If you are using Linux, you can run the container natively using Docker Engine. Follow these steps:
1. Install Docker Engine.
  - Follow the official [install instructions for Docker Engine for your distribution](https://docs.docker.com/install/#supported-platforms).
  - Add your user to the `docker` group by running `sudo usermod -aG docker $USER`.
  - Sign out and back in again so your changes take effect.
2. Install [VSCode](https://code.visualstudio.com/).
3. Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension).
4. [Create a named volume](#create-a-named-volume) to persist the container data

### Windows
If you are using Windows, we suggest you to use Docker Desktop with WSL 2 backend. Follow these steps:
1. Enable the Windows Subsystem for Linux version 2 (WSL 2) feature on Windows. Refer to the [Microsoft documentation](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
2. Download and install the [Linux kernel update package](https://docs.microsoft.com/windows/wsl/wsl2-kernel).
3. Install [Docker Desktop with WSL 2 backend](https://docs.docker.com/desktop/windows/wsl/).
4. Install [VSCode](https://code.visualstudio.com/).
5. Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension).
6. [Create a named volume](#create-a-named-volume) in WSL 2 to persist the container data

### macOS
If you are using macOs, we suggest you to use Docker Desktop:
1. Install [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac). Be sure to select the appropriate version depending on whether your Mac has Intel or Apple silicon.
2. Install [VSCode](https://code.visualstudio.com/).
3. Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension).
4. [Create a named volume](#create-a-named-volume) to persist the container data

## Pull the image
If you are using an x86-64 machine you can pull the pre-built image directly from Docker Hub:
```
docker pull marcopalena/polito-os161:latest
```
or, with docker compose:
```
docker compose pull
```
Be sure to pull the image before starting the container with docker compose for the first time (as described [later](#run-the-container), otherwise docker compose will rebuild a local version of the image from scratch.

**NOTE** that the pre-built image is targeted at the `amd64` platform. If you are using Apple silicon you need to build your own image for your local platform.

## Build the image 
Alternatively you can build your own image by cloning this repository and building from source:
```
docker build -t polito-os161 .
```
or, using docker compose:
```
docker compose build
```

## Create a named volume
We suggest to use a named volume to persist the container data. To create a volume named `polito-os161-vol` using the default location on the host filesystem, use the following command:
```
docker volume create polito-os161-vol
```
You may want to create the volume at a custom location, for instance a location in which your user has full privileges so that you are able to make changes to the OS/161 source both from within the container and from the host. In that case, use the following command instead:
```
mkdir </path/to/custom/volume/location>
docker volume create --driver local \
                     --opt o=bind \
                     --opt type=none \
                     --opt device=</path/to/custom/volume/location> polito-os161-vol
```
You can inspect the volume with:
```
docker volume inspect polito-os161-vol
``` 

If you are using docker compose there is no need to create a volume beforehand. By default docker compose will create a volume named `polito-os161-vol` using the default location in the host filesystem. You can customize the location of the volume by editing the variables in the `.env` file like this:
```
MOUNTPOINT=/path/to/mount/point/
MOUNTPOINT_TYPE=custom
``` 

When you start the container for the first time as described [below](#run-the-container), the volume will be populated with the content of the `/home/os161user/` folder that comes pre-stored in the container. The volume is then mount in the container so that any change made to the content of that folder will be persisted on the host filesystem. The content of such a folder is the following:
- `/home/os161user/`
  - `os161/src/`: contains the source code of both kernel and userland.
  - `os161/tools/`: contains the binaries of System/161 and the build toolchain.
  - `os161/root/`: the install directory of both kernel and userland.

## Run the container
Run the container mounting the volume `polito-os161-vol` as the home folder of user `os161user`:
```
docker run --volume polito-os161-vol:/home/os161user --name polito-os161 -itd marcopalena/polito-os161 /bin/bash
```
Use the appropriate image name instead of `marcopalena/polito-os161` if you've built the image yourself.
Alternatively, using docker compose:
```
docker compose up -d
```
which will also automatically create the `polito-os161-vol` Docker volume, if you haven't already done so. 

You can install custom packages in the container (such as `git`) with:
1. `sudo apt update`
2. `sudo apt install <pkgname>`

The sudo password for os161user is `os161`. Note that the installed packages will not be stored in the volume, therefore they will not be persisted if you destroy and recreate the container. They will however still be available if you stop and restart the container.

## Attach VScode to the running container
Click on the Manage button in the bottom left, then "Extensions" and ensure that you have the "Remote - Containers" extension installed. (You can also open the Extensions tab with <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> on macOS.)

With the container running,  use the shortcut <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> (or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> if you are on macOS) to open the *Command Palette* and run the **Remote-Containers: Attach to Running Container...** command.

You will be asked to confirm that attaching means you trust the container. You need to confirm this only once, the first time you attach to the container.

Select the `polito-os161` container. The first time you attach to it, VSCode will install a server inside the container. This allows us to install and run extensions inside the container, where they have full access to the tools, platform, and file system. Wait until the installation is complete, you should see something like this in the bottom left-hand corner:
<p align="center">
  <img src="https://user-images.githubusercontent.com/29371432/158082590-a3a20e4c-0f9c-45e0-88e5-198c5b6653c2.png" />
</p>

Now you can go ahead to open the folder containing OS/161 inside the container by clicking on *File -> Open Folder* and searching for `/home/os161user/os161`. The window will reload with the opened folder.

<p align="center">
  <img src="https://user-images.githubusercontent.com/29371432/158080339-c345af3e-adea-44b4-9601-db11daffd741.png" />
</p>

## Configure VScode to work on OS/161

Before starting to work on OS/161 using VSCode, we suggest to install the [C/C++ Extension](https://code.visualstudio.com/docs/languages/cpp).

If you are using macOs, chances are that the C/C++ extension won't work correctly out-of-the-box within the container. If you get an error like this one when trying to launch the debugger:
```
Launching server using command /home/os161user/.vscode-server/extensions/ms-vscode.cpptools-<CPPTOOLS_VERSION>/bin failed.
```
you can try the following workaround:
1. Log into a terminal session within the container (the open session in the Terminal panel of VSCode works just fine).
2. Navigate to the directory containing the C/C++ extension binaries.
```
cd /home/os161user/.vscode-server/extensions/ms-vscode.cpptools-<CPPTOOLS_VERSION>/bin
```
3. Add execution permissions to `cpptools` and `cpptools-srv`.
```
chmod +x cpptools
chmod +x cpptools-srv
```

## VSCode tasks
The repository contains a set of tasks that can be used to compile, run, debug OS/161 and more. Tasks are defined in `.vscode/tasks.json`.

You can run a task by pressing `CTRL+SHIFT+P` -> `Tasks: Run Task` and selecting the desired task.

## Credits
- The Dockerfile structure is heavily inspired by https://github.com/johnramsden/os161-docker. 
- VSCode configuration is taken from https://github.com/thomascristofaro/os161vscode (after some minor paths modifications).

## References
* [The OS/161 Instructional Operating System](http://www.os161.org/)
* [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)

## License
Licensed MIT.
