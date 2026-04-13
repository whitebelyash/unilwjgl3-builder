#!/bin/bash

if [ -z $LWJGL_VERSION ]; then
	echo "LWJGL Version not set!"
	exit 1
fi

TARGET="release_jars"
RELEASE_DIR="lwjgl3/bin/RELEASE"

if [ ! -f "release_jars" ]; then
	mkdir -p $TARGET
fi
if [ ! -f "$RELEASE_DIR" ]; then
	echo "No build files!"
	exit 1
fi

install() {
	echo "Installing $1 onto $TARGET/$2"
	cp $1 $TARGET/$2
}

find $RELEASE_DIR -type f -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | while read -r jar; do
	targetname="$(basename $jar).$LWJGL_VERSION"
	install $jar $targetname
done

echo "Success"



