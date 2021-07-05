[![](https://images.microbadger.com/badges/image/meyay/overlayfs-mount.svg)](https://microbadger.com/images/meyay/overlayfs-mount "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/meyay/overlayfs-mount.svg)](https://microbadger.com/images/meyay/overlayfs-mount "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/commit/meyay/overlayfs-mount.svg)](https://microbadger.com/images/meyay/overlayfs-mount "Get your own commit badge on microbadger.com")
# overlayfs-mount

Create a fuse-overlayfs mount, merging the content of a read only source, and a read/write source folder.

It is based on alpine linux, uses fuse3 from the edge repository, is compiled from fuse-overlayfs sources and leverages s6-overlay's SIGTERM handling to achieve clean fuse-overlayfs unmounts when the container is stopped.

See for further details on fuse-overlaysfs: https://github.com/containers/fuse-overlayfs

## Docker CLI Usage 
```sh
docker run -d \
 --name=overlayfs-mount \
 --network none \
 --privileged \
 --env TZ=Europe/Berlin \
 --env PUID=1026 \
 --env PGID=100 \
 --volume $PWD/lower:/lower:ro \
 --volume $PWD/upper:/upper:rw \
 --volume $PWD/work:/work:shared \
 --volume $PWD/merged:/merged:shared \
  meyay/overlayfs-mount:0.4.0
```

## Docker Compose Usage 
```
version: '2.2'
services:
  overlayfs:
    image: meyay/overlayfs-mount:0.4.0
    container_name: overlayfs-mount
    network_mode: 'none'
    privileged: true
    environment:
      TZ: 'Europe/Berlin'
      PUID: '1026'
      PGID: '100'
    volumes:
    - $PWD/lower:/lower:ro
    - $PWD/upper:/upper:rw
    - $PWD/work:/work:shared
    - $PWD/merged:/merged:shared
```

## Parameters
The environment parameters are split into two halves, separated by an equal, the left hand side representing the variable name and the right the value of it.

| ENV| DEFAULT | DESCRIPTION |
| ------ | ------ | ------ |
| TZ | Europe/Berlin | The timezone to use for file operations and the log. |
| PUID | 1000 | The user id used to access files. |
| PGID | 1000 | The group id used to access files. |
| LOWER_DIR  | /lower |  Optional: the container target path for the `/lower` volume mapping. |
| UPPER_DIR  | /upper |  Optional: the container target path for the `/upper` volume mapping. |
| WORK_DIR  | /work |  Optional: the container target path for the `/work` volume mapping. |
| MERGED_DIR  | /merged |  Optional: the container target path for the `/merged` volume mapping. |

The volume parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

| VOLUMES |  DESCRIPTION |
| ------ | ------ |
| /lower |  The read only mount point. Needs to match `LOWER_DIR`. |
| /upper |  The read write mount point. Needs to match `UPPER_DIR`. |
| /work |  The work dir mount. Needs to be on the same volume `/merged`. Needs to match `WORK_DIR`. |
| /merged |  The unionfs mount. Needs to match `MERGED_DIR`. |


The examples form above assume that `/lower` and `/upper` exist localy in your filesystem.

If the host path for the `/lower` bind is a mounted remote share, you might want to switch the propagation from `ro` to `shared`.

If the host path for the `/upper` bind is a mounted remote share, you might want to switch the propagation from `rw` to `shared`.

See for further details on docker bind propagation: https://docs.docker.com/storage/bind-mounts/#configure-bind-propagation

## Shell access
For shell access while the container is running, `docker exec -it overlayfs-mount /bin/sh`

## Troubleshooting
The filesystem where the host path is located needs to be marked as shared. Otherwise the volume bindings for `/work` and `/merged` will result in an error and the container will not start. To mark a filesystem as shared, adopt following line to your needs:
```sh
mount --make-shared /
```
Please use the mount point of your volume, as the mount point "/" is just an example.

If you expose your unionfs folder as a remote share: 
- nfs: overlayfs folder is empty
- cifs: overlayfs folder can see and access the content

## Docker Swarm
Since the container needs to be run in privliged mode, this image can not be used on Docker Swarm. Sadly, Docker Swarm lacks support for priviliged containers. 
