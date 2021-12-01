# Build a Debian package using a container

This image does a Debian package build. You mount the directory where the
debian repository lives and the image will run `dpkg-buildpackage` on that
directory. The results are thrown away unless the `OUTPUT_DIRECTORY`
directory is set. You can optionally run lintian on the resulting build.

## Tags

To build for a specific Debian release specify the release using the Docker tag.
For example, to build a Debian package for the sid (unstable) release
use the `sid` tag:
```
$ docker run --rm docker-package-build:sid [other options]
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
