[![](https://images.microbadger.com/badges/image/meyay/overlayfs-mount.svg)](https://microbadger.com/images/meyay/overlayfs-mount "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/meyay/overlayfs-mount.svg)](https://microbadger.com/images/meyay/overlayfs-mount "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/commit/meyay/overlayfs-mount.svg)](https://microbadger.com/images/meyay/overlayfs-mount "Get your own commit badge on microbadger.com")
# overlayfs-mount

Create an overlayfs mount, merging the content of a read only source, and a read/write source folder.

It is based on alpine linux, compiled from sources and  and leverages s6-overlay's SIGTERM handling to achieve a clean unionfs unmount when the container is stopped.


## Docker CLI Usage 
```sh
docker run -d \
 --name=overlayfs-mount \
 --privileged \
 --env TZ=Europe/Berlin \
 --env PUID=1026 \
 --env PGID=100 \
 --volume $PWD/lower:/lower:ro \
 --volume $PWD/upper:/upper:rw \
 --volume $PWD/work:/work:shared \
 --volume $PWD/merge:/merge:shared \
  meyay/overlayfs-mount:0.0.3
```

## Docker Compose Usage 
```
version: '2.2'
services:
  overlayfs:
    image: meyay/overlayfs-mount:0.0.3
    container_name: overlayfs-mount
    privileged: true
    volumes:
    - $PWD/lower:/lower:ro
    - $PWD/upper:/upper:rw
    - $PWD/work:/work:shared
    - $PWD/merge:/merge:shared
    environment:
      TZ: 'Europe/Berlin'
      PUID: '1026'
      PGID: '100'
    network_mode: 'none'
```

## Parameters
The environment parameters are split into two halves, separated by an equal, the left hand side representing the host and the right the container side.

| ENV| DEFAULT | DESCRIPTION |
| ------ | ------ | ------ |
| TZ | Europe/Berlin | The timezone to use for file operations and the log. |
| PUID | 1000 | The user id used to access files. |
| PGID | 1000 | The group id used to access files. |
| LOWER_DIR  | /lower |  Optional: the container target path for the read-only volume mapping. |
| UPPER_DIR  | /upper |  Optional: the container target path for the read-write volume mapping. |
| WORK_DIR  | /work |  Optional: the container target path for the work volume mapping. |
| MERGE_DIR  | /merge |  Optional: the container target path for the merge volume mapping. |

The volume parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

| VOLUMES |  DESCRIPTION |
| ------ | ------ |
| /lower |  The read only mount point. Needs to match LOWER_DIR. |
| /upper |  The read write mount point. Needs to match UPPER_DIR. |
| /work |  The work dir mount. Needs to be on the same volume /merge. Needs to match WORK_DIR. |
| /merge |  The unionfs mount. Needs to match MERGE_DIR. |


The examples form above assume that `/lower` and `/upper` exist localy in your filesystem.

If the host path for the `/lower` bind is a mounted remote share, you might want to switch the propagation from `ro` to `shared`.

If the host path for the `/upper` bind is a mounted remote share, you might want to switch the propagation from `rw` to `shared`.

See for further details: https://docs.docker.com/storage/bind-mounts/#configure-bind-propagation

## Shell access
For shell access while the container is running, `docker exec -it overlayfs-mount /bin/sh`

## Troubleshooting
The filesystem where the host path is located needs to be marked as shared. Otherwise the volume bindings for /work and /merge will result in an error and the container will not start. To mark a filesystem as shared, adopt following line to your needs:
```sh
mount --make-shared /
```
Please use the mount point of your volume, as the mount point "/" is just an example.

If you expose your unionfs folder as a remote share: 
- nfs: overlayfs folder is empty
- cifs: overlayfs folder can see and access the content

## Docker Swarm
Since the container needs to be run in privliged mode, this image can not be used on Docker Swarm. Sadly, Docker Swarm lacks support for priviliged containers. 
