#!/bin/bash

# docker buildx build --no-cache --platform linux/arm64 -t nvim-mw .
docker buildx build --platform linux/arm64 -t nvim-mw .

# docker run \
#   --mount type=bind,source=/Users/mihira/c,target=/root/c \
#   -it nvim-centos bash
