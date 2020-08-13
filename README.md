# Build a Debian package using a container

## Configuration

* `BUILD_DIRECTORY`: [REQUIRED] Set this environment variable equal to the
full path of the directory containing the Debian package.

* `RUN_LINTIAN`: [OPTIONAL] Set this environment variable equal to any
non-empty string to run lintian at the end of the package build. Any
lintian warnings will result in failure.

## Examples

## Build but throw-away the result

There are times you want to build the package but not keep the result, for
example, you are not ready to use the package but just want to be sure it
builds without error.

```
$ ls /tmp/mypack
test.txt
debian/
$ docker run -v /tmp/mypack:/root/mypack --env BUILD_DIRECTORY=/root/mypack
```

