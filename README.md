# Docker Deb Test

### Dependencies
#### External
* [yq] (http://http://mikefarah.github.io/yq/)
* [curl] (https://curl.haxx.se/)
* [docker] (https://docs.docker.com)
* [docker-compose] (https://docs.docker.com/compose/)

### About
This is a basic application that can take both local and remote .deb
files, create a simple Docker Linux image and install the .deb files
into it.

**Note:  **One or more .deb files are required.  They can be local,
remote, or a mixture of the two.

#### Running the program
The following commands should be run from the project root, where
`docker-compose.yml` lives.

Run the program with:

```
./UnpackDeb.sh -l <local_deb_file(s)> -r <remote_deb_files> -b
```

...where *-b* directs the script to rebuild the image and container,
after tearing down the volume attached to an already running
container.

When the container is running, it is possible to log into it and
check the .deb packages have correctly installed with the following:

```
docker exec -it <container_name> /bin/bash
```

***Note:  ***The default `<container_name>` is *deb-test*, as
discussed in the [Docker configuration](#docker-configuration)
section.

#### Cleanup
The container can be shut down with:

```
docker-compose down
```

...add `-v` to tear down the container's volume.  You should do
this if you plan to get rid of the container completely.

The Docker images from which the container is built can be removed
with:

```
docker rmi $(docker images -a | grep "<image>" | awk '{print $3}')
docker rmi $(docker images -a | grep "<BASE_IMAGE>" | awk '{print $3}')
```

***Note:  ***The default `<image>` is *deb_test_image*, and the
`<BASE_IMAGE>` will depend on the base Linux image chosen, as discussed
in the [Docker configuration](#docker-configuration) section.  When
removing the base image, you do **not** need to specify the version.
For example, if using `ubuntu:16.04`, you would only specify `ubuntu`
when removing it.

#### Docker configuration
The following items are set in the `docker-compose.yml` file:

* `BASE_IMAGE` - The base Docker Linux image, set to `ubuntu:16.04`.
  If not set, `build/Dockerfile` specifies a default image of
  `debian:latest`.  Be careful to use a flavour of Linux that is
  apt-compatible, or you will need to make appropriate adjustments
  to the `build/InitEnv.sh` script.  **In particular, `alpine`
  images use `apk` rather than `apt`.**
* `container_name` - Set to deb-test, but this can be altered if
   another name is preferred.
* `image` - Set to deb_test_image, but this can be altered if
   another name is preferred.
* `EXTRA_INSTALLS` - If there are any additional dependencies
   (`apt` packages) required by the .deb file(s) that are not parts
   of the base Linux image, they should be mentioned here.
