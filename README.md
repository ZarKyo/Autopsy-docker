# Autopsy Docker

Dockerfile to run [Autopsy](https://www.autopsy.com/) - the digital forensics platform

## Versions

| Component | Version |
|---|---|
| Base image | Ubuntu 24.04 |
| Autopsy | 4.23.0 |
| SleuthKit | 4.15.0 |
| Java | OpenJDK 17 |

## Requirements

- Docker (with `docker compose` plugin) or Docker Engine, with BuildKit (default since Docker 23)
- Default mode: Linux host with a running X11 server
- SSH mode: any host with an SSH client that supports X11 forwarding (MobaXterm, `ssh -X`…)

## Usage

### Build

```shell
docker build . -t autopsy:latest
```

The build is multi-stage: SleuthKit is compiled in a builder stage, and the final image only contains the JRE, the runtime libraries and Autopsy. Compilers, headers, `ant`, `git` and the full JDK are not shipped.

### Run with Docker

Allow local X connections, then start the container:

```shell
xhost +local:docker
docker run \
    -d \
    -it \
    --shm-size 2G \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd)/case/:/home/autopsy/case \
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

### SSH mode (optional)

Use this mode when the host has no local X server (Windows, macOS) or to work from another machine. Autopsy is started over `ssh -X` and displayed by the client's X server.

```shell
docker compose -f docker-compose.ssh.yml up -d
ssh -X -p 2222 autopsy@localhost
autopsy --nosplash
```

- Login is `autopsy` / `forensics` by default. Override it at startup with `SSH_PASSWORD='<password>' docker compose -f docker-compose.ssh.yml up -d`. The password is set when the container starts, not stored in the image.
- SSH host keys are generated when the container starts, so they are never shared between users of the image.
- The port is bound to `127.0.0.1` by default. To reach it from another machine, set `SSH_BIND=0.0.0.0` and **your own `SSH_PASSWORD`** (the default one is public):

  ```shell
  SSH_BIND=0.0.0.0 SSH_PASSWORD='<password>' docker compose -f docker-compose.ssh.yml up -d
  # from the other machine
  ssh -X -p 2222 autopsy@<docker-host-ip>
  ```

  On Linux, Docker bypasses `ufw`: a published port is reachable even if `ufw` denies it.
- To stop: `docker compose -f docker-compose.ssh.yml down`

## Mounting Images with FUSE (optional)

The image includes `ewf-tools` (`ewfmount`, `ewfinfo`, `ewfverify`). To mount an image inside the container, uncomment the `/dev/fuse`, `cap_add: SYS_ADMIN` and `security_opt: apparmor:unconfined` lines in the compose file you use (privileged mode is not required), then:

```shell
docker exec -u root autopsy sh -c 'mkdir -p /mnt/ewf && ewfmount -X allow_other /home/autopsy/case/evidence.E01 /mnt/ewf'
```

The container is named `autopsy` in both modes. The raw image is then available to Autopsy at `/mnt/ewf/ewf1`. The mount only exists inside the container. Autopsy reads E01 files directly, so this is only needed for other tools or special cases.

## Evidence and Case Files

Place disk images and evidence files in the `./case/` directory. This folder is mounted inside the container at `/home/autopsy/case`.

When creating a new case in Autopsy, point the data source path to `/home/autopsy/case/<your-image>`.

```
Autopsy-docker/
└── case/
    ├── evidence.E01
    └── my-case/          ← Autopsy case directory
```

## X11 Security Note

`xhost +` opens X access to **all** hosts - do not use it on a shared or networked machine. Prefer the safer `xhost +local:docker` (grants access only to local Unix socket connections) or use `xauth` cookie forwarding.

Reference: [xhost security risks](https://laurentschneider.com/wordpress/2007/03/xhost-is-a-huge-security-hole.html)

## Credits

- [bannsec/autopsy_docker](https://github.com/bannsec/autopsy_docker) - original Dockerfile
- [digitalsleuth/autopsy-docker](https://github.com/digitalsleuth/autopsy-docker/blob/main/docker-compose.yaml) - SSH X11-forwarding mode and FUSE options
- [sleuthkit/autopsy - Linux install guide](https://github.com/sleuthkit/autopsy/blob/develop/Running_Linux_OSX.md#installing-prerequisites)
