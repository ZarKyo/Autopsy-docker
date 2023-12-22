# Autopsy Docker

Dockerfile for building a version of Autopsy for Linux.

## Run

Note: The xhost + command is in the documentation for convienience. It is a security risk (https://laurentschneider.com/wordpress/2007/03/xhost-is-a-huge-security-hole.html). If you have concerns about your X security, please using xauth instead.

### Docker

Build :

```shell
$ docker build . -t "autopsy:latest"
```

Launch :

```shell
$ xhost +
$ docker run \
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

### Docker Compose

```shell
$ xhost + && docker-compose up -d
```

## Loading an image file for a case

The volume mounted in the local folder ./case/ should be used to share disk images and cases files, so put here your evidence and load it in the Autopsy wizard.

## Credits

- [bannsec](https://github.com/bannsec/autopsy_docker)
- [sleuthkit](https://github.com/sleuthkit/autopsy/blob/develop/Running_Linux_OSX.md#installing-prerequisites)
