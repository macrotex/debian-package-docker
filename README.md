# Build a Debian package using a container

This image does a Debian package build. You mount the directory where the
debian repository lives and the image will run `dpkg-buildpackage` on that
directory. The results are thrown away unless the `OUTPUT_DIRECTORY`
directory is set. You can optionally run lintian on the resulting build.
Finaly, if the `DPUT_CF` environment is set and points to a
`dput.cf` file the package will be uploaded using `dput`.

## Tags

To build for a specific Debian release specify the release using the Docker tag.
For example, to build a Debian package for the sid (unstable) release
use the `sid` tag:
```
$ docker run --rm docker-package-build:sid [other options]
```

Currently, the following Debian distribution tags are supported:
```
buster
bullseye
sid
unstable (same as sid)
```

## Building Docker image

This Docker image has a single build argument `DEBIAN_DISTRIBUTION`. To build
for a specific Debian distribution you must set `DEBIAN_DISTRIBUTION`
during the build process. Exampes:
```
$ docker build --build-arg DEBIAN_DISTRIBUTION=sid      --tag debian-package:sid      .
$ docker build --build-arg DEBIAN_DISTRIBUTION=bullseye --tag debian-package:bullseye .
```

## Configuration

* `BUILD_DIRECTORY`: [REQUIRED] Set this environment variable equal to the
full path of the directory containing the Debian package.

* `RUN_LINTIAN`: [OPTIONAL] Set this environment variable equal to any
non-empty string to run lintian at the end of the package build. Any
lintian warnings will result in failure.

* `OUTPUT_DIRECTORY`: [OPTIONAL] Normally the image deletes the build
results after the build is finished, but if you want to keep the package
artifacts after build, set `OUTPUT_DIRECTORY` to the directory path where
the package build results should be copied.

* `DPUT_CF`: [OPTIONAL] The path to the `dput` configuration file. This path will
be passed to `dput` as `-c $DPUT_CF`. If `DPUT_CF` is not defined the
`dput` step will be skipped.
See "Uploading package using `dput`" below for details.

* `DPUT_HOST`: [OPTIONAL] The host to use with `dput`.
See "Uploading package using `dput`" below for details.

* `VERBOSE`: [OPTIONAL] If set to a non-empty string more details will
be output.

## Uploading package using `dput`

If `DPUT_CF` is not empty then this command will be called
after the package is built:
```
dput -c "$DPUT_CF" "$DPUT_HOST" *.changes
```
For the above to work the environment variable `DPUT_CF` must point to a
valid `dput.cf` file that contains an entry for `DPUT_HOST`. If
`VERBOSE` is set to a non-empty string the `--debug` option will be added
to the above command.

You are, of course, responsible for mounting the `dput` configuration file
pointed to by `DPUT_CF` into the running container.

If the `dput` host requires credentials for uploading you will need to
provide those as well. For example, if the `dput` uses `scp` you will need
to provide the login credentials; see the man pages for
`dput` and `dput.cf` for more information.


## Examples

### Build but throw-away the result

There are times you want to build the package but not keep the result, for
example, you are not ready to use the package but just want to be sure it
builds without error. For this case be sure that `OUTPUT_DIRECTORY` is
_unset_. Let's assume that we have Debian package source is in our local
directory `/tmp/mypack`. You would build the package (and throw away the
results) by doing this:
```
$ ls /tmp/mypack
test.txt
debian/
$ docker run --rm -v /tmp/mypack:/root/mypack --env BUILD_DIRECTORY=/root/mypack docker-package-build
```

### Build and `dput`

This image supports building the package and uploading it to a Debian
package repository using `dput`. To do this you will need to supply a
`dput.cf` file to the container. Point to this file using the `DPUT_CF`
environment. Unless uploading to the official Debian repository you will
also need to indicate which respository to upload to; you indicate this
with the `DPUT_HOST` environment.

Let's look at an example. Assume that the following content is in the file
`/tmp/dput.cf` on the machine running your Docker container:
```
# /tmp/dput.cf
[DEFAULT]
hash = md5
allow_unsigned_uploads = 1

[upload-host]
method = scp
fqdn = upload-host.example.com
incoming = /srv/repos/incoming
```

You would then run the container:
```
$ docker run --rm -v /tmp/mypack:/root/mypack --env BUILD_DIRECTORY=/root/mypack \
                  -v /tmp/build-area:/root/build-area --env BUILD_DIRECTORY=/root/build-area \
                  -v /tmp/dput.cf:/root/dput.cf --env DPUT_CF=/root/dput.cf \
                  --env DPUT_HOST=upload-host \
                  docker-package-build
```

### Build and keep the build artifacts

This is much like the previous example except this time we want to keep
the Debian package build artifacts. To do that we set the
`OUTPUT_DIRECTORY` to a persistent directory.
```
$ ls /tmp/mypack
test.txt
debian/
$ docker run --rm -v /tmp/mypack:/root/mypack --env BUILD_DIRECTORY=/root/mypack \
                  -v /tmp/build-area:/root/build-area --env BUILD_DIRECTORY=/root/build-area \
                  docker-package-build
```
The package biuld artificts will be left in `/tmp/build-area`.

