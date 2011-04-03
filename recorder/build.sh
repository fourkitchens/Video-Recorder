#!/bin/bash
TARGET=/tmp/recorder
CWD=$(pwd)
mkdir $TARGET
cp -a allowedHTMLdomains.txt allowedSWFdomains.txt Application.xml readme.txt $TARGET
cd far/
/opt/adobe/fms/tools/far -package -archive $TARGET/main.far -files *
cd $CWD
