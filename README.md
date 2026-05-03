# Autopsy Docker

Dockerfile to run [Autopsy](https://www.autopsy.com/) — the digital forensics platform — on Linux via Docker with X11 forwarding.

## Versions

| Component | Version |
|---|---|
| Base image | Ubuntu 24.04 |
| Autopsy | 4.23.0 |
| SleuthKit | 4.15.0 |
| Java | OpenJDK 17 |

## Requirements

- Docker (with `docker compose` plugin) or Docker Engine
- A running X11 server on the host
- Linux host (X11 forwarding required)

## Usage

### Build

```shell
docker build . -t autopsy:latest
```

### Run with Docker

Allow local X connections, then start the container:

```shell
xhost +local:docker
docker run \
    -d \
    -it \
    --shm-size 2G \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd)/case/:/home/app/case \
    -e DISPLAY=$DISPLAY \
    -e JAVA_TOOL_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel' \
    --network host \
    --device /dev/dri \
    autopsy:latest
```

### Run with Docker Compose

```shell
xhost +local:docker && docker compose up -d
```

To stop:

```shell
docker compose down
```

## Evidence and Case Files

Place disk images and evidence files in the `./case/` directory. This folder is mounted inside the container at `/home/app/case`.

When creating a new case in Autopsy, point the data source path to `/home/app/case/<your-image>`.

```
Autopsy-docker/
└── case/
    ├── evidence.E01
    └── my-case/          ← Autopsy case directory
```

## X11 Security Note

`xhost +` opens X access to **all** hosts — do not use it on a shared or networked machine.
Prefer the safer `xhost +local:docker` (grants access only to local Unix socket connections) or use `xauth` cookie forwarding.

Reference: [xhost security risks](https://laurentschneider.com/wordpress/2007/03/xhost-is-a-huge-security-hole.html)

## Credits

- [bannsec/autopsy_docker](https://github.com/bannsec/autopsy_docker) — original Dockerfile
- [sleuthkit/autopsy — Linux install guide](https://github.com/sleuthkit/autopsy/blob/develop/Running_Linux_OSX.md#installing-prerequisites)
