# Docker Deb Test

### Dependencies
#### External
* [curl] (https://curl.haxx.se/)
* [docker] (https://docs.docker.com)
* [docker-compose] (https://docs.docker.com/compose/)
* [yq] (http://http://mikefarah.github.io/yq/)

### About
This is a basic application that can take both local and remote *.deb* files,
create a simple Docker Linux image and install the *.deb* files into it.

**Note:**  One or more *.deb* files are required.  They can be local, remote, or
a mixture of the two.

### Running the program
The following commands should be run from the project root, where
`docker-compose.yml` lives.

Run the program with:

```
./UnpackDeb.sh -l <local_deb_file(s)> -r <remote_deb_files> -b
```

...where file names are separated by whitespace and *-b* directs the script to
rebuild the image and container, after first tearing down the volume attached to
a container from a previous run.

When the container is running, it is possible to log into it and check the
*.deb* packages have correctly installed with the following:

```
docker exec -it <container_name> /usr/bin/env bash
```

**Note:**  The default `<container_name>` is *deb-test*, as discussed in the
[Docker configuration](#docker-configuration) section.

### Clean up
The container can be shut down from the project root with:

```
docker-compose down
```

...add `-v` to tear down the container's volume.  You should do this if you plan
to completely get rid of the container.

The Docker container, volume and images from which the container is built can
all be removed in one go with:

```
./Cleanup.sh
```

**Note:**  Do **not** add any service definitions ahead of the base test service
in the `docker-compose.yml` file, or the `Cleanup.sh` script will break.

### Docker configuration
The following items are set in the `docker-compose.yml` file:

* `BASE_IMAGE` - The base Docker Linux image, set to `ubuntu:16.04`.
  If not set, `build/Dockerfile` specifies a default image of `debian:latest`.
  Be careful to use a flavour of Linux that is apt-compatible, or you will need
  to make appropriate adjustments to the `build/InitEnv.sh` script.  **In
  particular,** `alpine` **images use** `apk` **rather than** `apt` **for
  package management.**
* `container_name` - Set to *deb-test*, but this can be altered if another name
  is preferred.
* `image` - Set to *deb_test_image*, but again can be altered if another name is
  preferred.
* `EXTRA_INSTALLS` - If there are any additional dependencies (`apt` packages)
  required by the *.deb* file(s) that are not part of the base Linux image,
  they should be mentioned here.  This is a whitespace-separated list - quoting
  is **not** required.
