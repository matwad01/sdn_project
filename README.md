# docker-mininet

The Docker image for [Mininet](http://mininet.org/)


## Docker Run Command

```
$ docker run -it --rm --privileged -e DISPLAY \
             -v /tmp/.X11-unix:/tmp/.X11-unix \
             -v /lib/modules:/lib/modules \
             docker-container-name
