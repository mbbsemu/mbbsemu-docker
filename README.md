# MBBSEmu Docker image

## Big thanks to LinuxServer.io

This image is based on the fantastic base image built & maintained by [LinuxServer.io](https://www.linuxserver.io). LinuxServer.io distributes dozens of software packages following repeatable patterns. Thank you so much LinuxServer.io for making a base image available that anybody, including our project, can use.

## Supported platforms

macOS and Linux work well. Development of this image is done on my macOS laptop. I run MBBSEmu on a Linux server.

Windows should work in principle but I have not personally tried it. I also include a `build.sh` helper script to build the image. It's a bourne shell script, so it certainly won't work out of the box on Windows. But it woudldn't be too hard to do its work manually.

## Prerequisites

- Docker
  - I've personally run on Docker Desktop macOS and Docker on Linux.
- An unzipped MBBSEmu package
  - Grab your preferred build from [the MBBSEmu website](https://www.mbbsemu.com).
  - Since development is so rapid right now, I generally use [the latest build from GitHub Actions](https://github.com/mbbsemu/MBBSEmu/actions).
  - You can also use the `download-latest-mbbsemu.sh` shell script to grab the latest build. (I do suggest you review this file before running it.)
- Unzipped MajorBBS modules
  - MBBSEmu-ready modules can be found on [the MBBSEmu website Modules section](https://www.mbbsemu.com/Modules).

## Setup

Broadly speaking we will be going three steps to build, setup, and run this image.

1. Build the image from source.
2. Prepare the runtime and configuration directory.
3. Create a `compose.yml` file and run a container.

### Build the image

- Clone and cd into the repository.
- Download and unzip MBBSEmu into the a subdirectory of the `pkg` directory
  - Get the Linux x86 build
  - The directory needs to be named like `mbbs-linux-x64-*`
    - It should already be in this format if you unzipped a package from the website
  - This directory will not be committed to source control.
- Run `./build.sh`
  - This assumes Linux or macOS.
  - This script wraps a `docker build` command. On Windows, you can refer to the script and run `docker build` by hand.
  - The image is now built and we can get it running.

### Prepare the runtime and configuration directory

Now we need to prepare a directory for running our container and storing configuration. Where we are headed is a directory structure like this:

```sh
mbbsemu-runtime
├── config
│   ├── appsettings.json
│   ├── mbbsemu.db
│   ├── modules
│   │   ├── HVSXROAD
│   │   ├── pkg
│   │   ├── TSGARN
│   │   └── WCCMMUD
│   └── modules.json
└── docker-compose.yml
```

#### Module preparation

As seen above, unzipped modules are kept in in `config/modules`. Here I've got the `HVSXROAD` (Crossroads), `TSGARN` (Tele-Arena), and `WCCMMUD` (MajorMUD) modules.

I also chose to archive the zip file packages from MBBSEmu in the `config/modules/pkg` directory but this is not required.

Next up is the required `config/modules.json` file, which specifies the modules to load and their path. In this example, `modules.json` looks like this:

```javascript
 {
  "Modules": [
    {
      "Identifier": "HVSXROAD",
      "Path": "/config/modules/HVSXROAD"
    },
    {
      "Identifier": "TSGARN",
      "Path": "/config/modules/TSGARN"
    },
    {
      "Identifier": "WCCMMUD",
      "Path": "/config/modules/WCCMMUD"
    }
  ]
}
```

Note the leading slash in the paths -- this is because, inside of the container, this `config` directory will be mounted at `/config`.

#### Emulator settings and database

##### Database

Next we need to create the `mbbsemu.db` file. This is the main database for MBBSEmu (duh)

Setting up the database will also set the Sysop account password.

To do this, we'll use `docker run` to run the MBBSEmu command to set the Sysop password.

Here is an example of what that looks like:

```sh
docker run \
  -e "PUID=1000" \
  -e "PGID=999" \
  -e "TZ=America/Detroit" \
  -v /host/path/to/config:/config -it \
  --entrypoint /app/MBBSEmu mbbsemu -DBRESET <FILL IN PASSWORD HERE>
```

The first two environment variables set the user and group ids you want this to run as. This is following LinuxServer.io's pattern. Set these values to the same user and group ids as the user you want to run this as.

The third environment variable sets the timezone.

The `-v` volume mapping the `/config` directory in the container to the local `./config` directory relative to this script. The left side of the colon should be the config path on your host system. You need to include this kind of bind volume so that the new database file is persisted.

Finally, the `--entrypoint` and remaining syntax runs the emulator with the `-DBRESET` parameter.

Fill you preferred sysop password in at the end.

##### Settings

Lastly we need to prep the `config/appsettings.json` file. The MBBSEmu zip package from the website should come with a sample file. Copy it in here.

We'll for sure need to change the `Database.File` key in that file. Given our directory structure above, we want that line to read as:

```javascript
"Database.File": "/config/mbbsemu.db",
```

Take note of the telnet port and rlogin ports specified in this file. We'll need to map those ports when running the container.

At this point our runtime and configuration directory should be all setup. Now we can actually run a container.

### Run a container

Inside of our directory, create a `docker-compose.yml` that looks like the following.

```yaml
services:
  mbbsemu:
    image: mbbsemu # this is the name of the image built by build.sh

    environment:
      - PUID=ABC # fill in with uid of the user running the container
      - PGID=XYZ # fill in with gid of the user running the container
      - TZ=America/Detroit # fill in with your preferred timezone
    ports:
      - "2323:23" # set your preferred port mapping for telnet. The syntax is host:container port numbers.
    volumes:
      - ./config:/config
```

Follow the comments above on which values need to be filled in where.

The `PUID` and `PGID` will likely match the values you used while creating the database and setting the sysop password.

At last we can run a conatiner. `docker-compose up`

Note the output from running the container. The majority of it is the LinuxServer.io base setting up the environment and running our command.

## Todos

- [] Build and push images to Github container registry - avoids people needing to build this themselves.
- [] Update `svc-mbbsemu` to be of `type` `longrun` instead of `oneshot`. This way s6 will restart the daemon if it crashes.
  - Note: leaving it as `oneshot` for now until the stability of the application is pretty solid and we can assume restarting the daemon is ok.
  - Also note: when switching to `longrun` we can delete the `up` file in `svn-mbbsemu`.
- [x] Update to use newer LinuxServer.io base images, including the new version of s6 they use.
- [x] Test whether the :delegated flag on the modules volume mapping makes a difference on a linux host.
- [x] Finish authoring te section about creating the database file.
- [x] Put all config, database, module files into /config , not read only
- [x] Figure out if there is a way to map /config, and also have /config/modules be :delegated in docker-compose.yml
- [x] Figure out how to get the VERSION arg passed in / configured in the Dockerfile - maybe download directly from mbbsemu?
- [x] Go through files changed on the linuxserver.io branch; remove commented out reference code from the old implementation
- [x] Update this README to account for linuxserver changeover
- [x] Remove `modules.json` from source control. Instead, provide an example and have the end user configure it for their own needs.
- [x] Volume map the modules directory -- modules are simply too messy to be copied in with one of two data files mapped. They drop stuff all over the place :(
- [x] Do MBBS modules that save data dump all their data files in the same directory as the bbs exectuables themselves? I believe so. Test if there is a way to dump the static bbs files during build time, but volume map the data files at runtime into the same directory. Need one or two modules to test this with first.
- [x] Identify a slimmer base image to build from. (I chose this one because I know the app is being developed on .net, but I suspect something smaller can be used for runtime only)
- [x] See if a generic `docker-compose.yml` can be created to ease running this beast.
