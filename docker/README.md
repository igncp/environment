## Useful Commands

- Rename container: `docker rename CONTAINER NEW_NAME`
- Rename image: `docker tag OLD_NAME NEW_NAME; docker rmi OLD_NAME`
- Stop and remove container: `docker rm -f CONTAINER`
- Stats about disk usage: `docker system df -v | less -S # takes a few seconds`

## Docker Images

These images purpose is to ease development. They will be used within a VM.

See [TODO.md](./TODO.md) for ideas of images.

## Objectives

- Minimize disk space
- Zero inter-dependencies between images (but copy-paste definitions to reduce image size)
- Prefer custom images than unmaintained ones
- Maximize automation
- Optimize commands to manage disk space
