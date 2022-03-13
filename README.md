# PoliTO OS/161 Docker
[![Build Status](https://app.travis-ci.com/marcopalena/polito-os161-docker.svg?token=TwUrTvqp6M7vKrhM3xmD&branch=main)](https://app.travis-ci.com/marcopalena/polito-os161-docker)

A compact Docker image to compile, run and debug the teaching operating system OS/161. Built for the courses "System and Device Programming" (01NYHOV) and "Programmazione di Sistema" (02GRSOV) at Politecnico di Torino. The image is based on Ubuntu 20.04 and contains the following components:
- OS/161 sources
- System/161
- Build toolchain (gcc, gdb, etc.)

## Pull the image
You can pull the pre-built image directly from Docker Hub:
```
docker pull marcopalena/polito-os161:latest
```

## Build the image 
Alternatively you can build your own image by cloning this repository and building from source:
```
docker build -t polito-os161 .
```

## Set up a remote development environment
To work on the course assignments running OS/161 inside the container, you need to set up a remote development environment on your host machine first. In the following you can find the instructions on how to set up such an environment using VSCode on different platforms. In the proposed setup we leverage the remote development capabilities of VSCode to:
 - Access, edit and compile source code of OS/161 stored in a named volume that is mounted into the container.
 - Run and debug both the kernel and user programs executing on System/161 inside the container.

Follow the appropriate instructions to set up the remote development environment on your platform.

### Linux
If you are using Linux, you can run the container natively using Docker Engine. Follow these steps:
- Install Docker Engine.
  - Follow the official [install instructions for Docker Engine for your distribution](https://docs.docker.com/install/#supported-platforms).
  - Add your user to the `docker` group by running `sudo usermod -aG docker $USER`.
  - Sign out and back in again so your changes take effect.
- Install [VSCode](https://code.visualstudio.com/).
- Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension).
- [Create a named volume](#create-a-named-volume) to persist the container data

### Windows
If you are using Windows, we suggest you to use Docker Desktop with WSL 2 backend. Follow these steps:
- Enable the Windows Subsystem for Linux version 2 (WSL 2) feature on Windows. Refer to the [Microsoft documentation](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
- Download and install the [Linux kernel update package](https://docs.microsoft.com/windows/wsl/wsl2-kernel).
- Install [Docker Desktop with WSL 2 backend](https://docs.docker.com/desktop/windows/wsl/).
- Install [VSCode](https://code.visualstudio.com/).
- Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension).
- [Create a named volume](#create-a-named-volume) in WSL 2 to persist the container data

## Create a named volume
We suggest to use a named volume to persist the container data. To create a volume named `polito-os161-vol` using the default location on the host filesystem, use the following command:
```
docker volume create polito-os161-vol
```
You may want to create the volume at a custom location, for instance a location in which your user has full privileges so that you are able to make changes to the OS/161 source both from within the container and from the host. In that case, use the following command instead:
```
mkdir </path/to/custom/volume/location>
docker volume create --driver local --opt o=bind --opt type=none --opt device=</path/to/custom/volume/location> polito-os161-vol
```
You can inspect the volume with:
```
docker volume inspect polito-os161-vol
``` 

When you start the container for the first time as described [below](#run-the-container), the volume will be populated with the content of the `/home/os161user/` folder that comes pre-stored in the container. The volume is then mount in the container so that any change made to the content of that folder will be persisted on the host filesystem. The content of such a folder is the following:
- `/home/os161user/`
  - `os161/src/`: contains the source code of both kernel and userland.
  - `os161/tools/`: contains the binaries of System/161 and the build toolchain.
  - `os161/root/`: the install directory of both kernel and userland.

## Run the container
```
docker run --volume polito-os161-vol:/home/os161user --name polito-os161 -it marcopalena/polito-os161 /bin/bash
```

## Attach VScode to the running container
With the container running, use the shortcut 


you will be asked to confirm that attaching means you trust the container. This is only confirmed once.


## References

Licenced MIT
