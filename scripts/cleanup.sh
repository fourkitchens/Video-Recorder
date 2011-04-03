#!/bin/bash

# Clean up stale video files

find /mnt/webroot/recorder/ -cmin +60 -exec removing stable video file: {} \; -exec rm {} \;

