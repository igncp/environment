#!/usr/bin/env bash

set -e

# Needs an example.mp4 file in this directory. Then, from the container, run:
# `sh /project/example.sh`

packager input=/project/example.mp4,stream=audio,output=/media/audio.mp4 \
   input=/project/example.mp4,stream=video,output=/media/video.mp4 \
   --mpd_output /media/example.mpd
