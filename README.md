# MBBSEmu Docker image

A Docker image for running MBBSEmu.

## Motivation

Truth be told, as of 2020-01-30 it's probably easiest to run and tinker with the emulator locally,

That said, I made this image to:

* Make it easier to run the emulator on my computer
* Prove out running the emulator in a Linux container. In the long run, I imagine most sysdamins will want to run this in a container or a virtual machine.
* Get all of these learnings into version control
* Make all of these commands and learnings executable and automated

## Supported platforms

Although ideally this should work well across Windows, macOS, and Linux, I've only personally tested it on macOS.

I expect Linux will worth without trouble. Windows is the wildcard.

## Prerequisites

* Docker
  * I'm using Docker Desktop for Mac 2.2.0.0 as of 2020-01-30
* An unzipped MBBSEmu package
  * I'm using private alpha 2.2 as of 2020-01-30
* Unzipped MajorBBS modules
  * I've only used `GWWARROW` as of 2020-01-30

## Quick start

* Clone the repository.
* Unpack MBBSEmu into the a subdirectory of the `pkg` directory
  * It should be named something like `mbbs-linux-x64-*`
  * This directory will not be committed to source control.
* Put unzipped and installed MajorBBS modules into subdirectories under `pkg/modules`
  * Many modules require a separate installation process. I have not tried that yet since `GWWARROW` does not.
* Ensure you are currently in the root directory of the repository.
* `docker build -t mbbsemu .`
* `docker run --rm -p [host_port]:23 -v `pwd`/data:/data -v `pwd`/config/appsettings.json:/mbbsemu/appsettings.json:ro mbbsemu [module_name]`
  * Fill in `[module_name]` with the module you want to run, e.g. `GWWARROW`
  * Fill in `[host_port]` with the port you want opened on the host, e.g. `2323`

## In-depth setup

### External package setup

External (meaning not checked into source control) package all live in `pkg`. `pkg` itself is checked into source control, but not directories or files under it.

MBBSEmu itself should be located in a directory in `pkg`. It will be copied into the Docker image during build time.

MBBS modules should be in the `pkg/modules` subdirectory. The files should have both been unzipped and installed (if necessary). So far I've only tested `GWWARROW`, which does not require installation

My understanding is that the installers can be run under Dosbox or a DOS virtual machine.

Your `pkg` directory should look something like this once everything is in place:

```sh
pkg
├── mbbsemu-linux-x64-012720_2
│   └── MBBSEmu
└── modules
    ├── GWWARROW
    └── WCCMMUD
```

### MBBSEmu configuration and database

MBBSEmu's database directory should be volume mapped to the `data` directory.

The MBBSEmu comes with a sample configuration file but it is ignored.

Instead, the file in `config/appsettings.json` is mapped as a read-only volume into the container at runtime.

If you need to make configuration file changes, then `config/appsettings.json` is your friend. Restart the container after your changes and they should be applied.

### Building the image

Build the image with a minimal Docker build command à la `docker build -t mbbsemu .`

Changes to the MBBSEmu package or MBBS modules will require a rebuild of the image. Changes to `config/appsettings.json` only require a container restart.

### Running a container

Running the container requires:
  
* a port mapping of port 23 in the container to a host port.
* a volume mapping of the configuration file.
* a volume mapping to the database directory.
* a specific module name to run.

The command should look something like the below. Fill in your prefered host port and module name.

(Assuming you are running this command in the root of the repository.)

```sh
docker run --rm \
           -p [host_port]:23 \
           -v `pwd`/data:/data \
           -v `pwd`/config/appsettings.json:/mbbsemu/appsettings.json:ro \ mbbsemu [module_name]
```

#### Running a shell for debugging purposes

If you need to get into the container to test & debug things, a command that specifies `bash` as the entry point is handy.

This should drop you into the same directory as MBBSEmu with a `run.sh` script to help run the emulator.

Sample command:

```sh
docker run --rm \
           -p 2323:23 \
           -v `pwd`/data:/data \
           -v `pwd`/config/appsettings.json:/mbbsemu/appsettings.json:ro \
           --entrypoint bash
           mbbsemu
```

## Todos

- [ ] See if a generic `docker-compose.yml` can be created to ease running this beast.
- [ ] Figure out if there is a way to use `ENTRYPOINT` or `CMD` directives to make it easy to run a module directly _or_ run a shell to debug.
- [ ] Test this setup with a module that needed to be installed first.
- [ ] Do MBBS modules that save data dump all their data files in the same directory as the bbs exectuables themselves? I believe so. Test if there is a way to dump the static bbs files during build time, but volume map the data files at runtime into the same directory.
