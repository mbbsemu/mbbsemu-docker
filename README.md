# MBBSEmu Docker image

## Todos

- [x] Put all config, database, module files into /config , not read only
- [] When MBBSEmu fails to start or crashes, should the container stop? Or have s6 restart it? Or ???? Check other LinuxServer.io projects for reference.
- [x] Figure out if there is a way to map /config, and also have /config/modules be :delegated in docker-compose.yml
- [x] Figure out how to get the VERSION arg passed in / configured in the Dockerfile - maybe download directly from mbbsemu?
- [x] Go through files changed on the linuxserver.io branch; remove commented out reference code from the old implementation
- [] Update this README to account for linuxserver changeover

## Motivation

Truth be told, as of 2020-02-16 it's probably easiest to run and tinker with the emulator locally,

That said, I made this image to:

* Make it easier to run the emulator on my computer
* Prove out running the emulator in a Linux container. In the long run, I imagine many sysdamins will want to run this in a container or a virtual machine.
* Get all of these learnings into version control
* Make all of these commands and learnings executable and automated

## Supported platforms

Although ideally this should work well across Windows, macOS, and Linux, I've only personally tested it on macOS.

I expect Linux will worth without trouble. Windows is the wildcard.

## Prerequisites

* Docker
  * I'm using Docker Desktop for Mac 2.2.0.3 as of 2020-02-16
* An unzipped MBBSEmu package
  * I'm using private alpha 6
* Unzipped MajorBBS modules
  * I've only used `GWWARROW` and `RTSLORD` as of 2020-03-08

## Quick start

* Clone the repository.
* Unpack MBBSEmu into the a subdirectory of the `pkg` directory
  * It should be named something like `mbbs-linux-x64-*`
  * This directory will not be committed to source control.
* Put unzipped and installed MajorBBS modules into subdirectories under `modules` directory
  * Many modules require a separate installation process. I have not tried that yet since `GWWARROW` does not.
  * Hint: Put pristine modules that have only gone through the installation process into `pkg/post-install-modules`. This helps keep a pristine copy around in case the runtime modules get messed up during testing.
* Ensure you are currently in the root directory of the repository.
* `docker-compose up`
  * This with run MBBSEmu on port 2323 of the host and the modules specified in `config/modules.json`

## In-depth setup

### External package setup

External (meaning not checked into source control) package all live in `pkg`. `pkg` itself is checked into source control, but not directories or files under it.

MBBSEmu itself should be located in a directory in `pkg`. It will be copied into the Docker image during build time.

MBBS modules should be in the `modules` subdirectory. The files should have both been unzipped and installed (if necessary). So far I've only tested `GWWARROW`, which does not require installation

My understanding is that the installers can be run under Dosbox or a DOS virtual machine.

Your `modules` and `pkg` directories should look something like this once everything is in place:

```sh
modules
  ├── GWWARROW
  └── WCCMMUD
pkg
├── mbbsemu-linux-x64-020320
│   └── MBBSEmu
└── post-install-modules
    ├── GWWARROW
    └── WCCMMUD
```

### MBBSEmu configuration and database

MBBSEmu's database directory should be volume mapped to the `data` directory.

Modules should be volume mapped to the `modules` directory.

The MBBSEmu comes with a sample configuration file but it is ignored.

Instead, the file in `config/appsettings.json` is mapped as a read-only volume into the container at runtime.

If you need to make configuration file changes, then `config/appsettings.json` is your friend. Restart the container after your changes and they should be applied.

Modules to be run by MBBSEmu are specified in `config/modules.json`.

### Building the image

Build the image `docker-compose build` or with a minimal Docker build command à la `docker build -t mbbsemu .`

Changes to the MBBSEmu package or MBBS modules will require a rebuild of the image. Changes to `config/appsettings.json` or `config/modules.json` only require a container restart.

### Running a container

Running the container requires:
  
* a port mapping of port 23 in the container to a host port.
* volume mappings to the configuration files, database directory, and modules directory

I recommend using `docker-compose up` with the included `docker-compose.yml`.

#### Running a shell for debugging purposes

If you need to get into the container to test & debug things, a command that specifies `bash` as the entry point is handy.

This should drop you into the same directory as MBBSEmu with a `run.sh` script to help run the emulator.

Sample command:

```sh
docker run --rm \
           -it \
           -p 2323:23 \
           -v `pwd`/modules:/modules \
           -v `pwd`/data:/data \
           -v `pwd`/config/appsettings.json:/mbbsemu/appsettings.json:ro \
           -v `pwd`/config:/config:ro
           --entrypoint bash \
           mbbsemu
```

## Todos

* [ ] Remove `modules.json` from source control. Instead, provide an example and have the end user configure it for their own needs.
* [x] Volume map the modules directory -- modules are simply too messy to be copied in with one of two data files mapped. They drop stuff all over the place :(
* [x] Do MBBS modules that save data dump all their data files in the same directory as the bbs exectuables themselves? I believe so. Test if there is a way to dump the static bbs files during build time, but volume map the data files at runtime into the same directory. Need one or two modules to test this with first.
* [ ] Identify a slimmer base image to build from. (I chose this one because I know the app is being developed on .net, but I suspect something smaller can be used for runtime only)
* [x] See if a generic `docker-compose.yml` can be created to ease running this beast.
* [ ] Figure out if there is a way to use `ENTRYPOINT` or `CMD` directives to make it easy to run a module directly _or_ run a shell to debug.
