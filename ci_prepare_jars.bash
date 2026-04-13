#!/bin/bash

if [ -z $LWJGL_VERSION ]; then
	echo "LWJGL Version not set!"
	exit 1
fi

TARGET="release_jars"
RELEASE_DIR="./lwjgl3/bin/RELEASE"

if [ ! -d "release_jars" ]; then
	mkdir -p $TARGET
fi
if [ ! -d "$RELEASE_DIR" ]; then
	echo "No build files!"
	exit 1
fi

install() {
	echo "Installing $1 onto $TARGET/$2"
	cp $1 $TARGET/$2
}

find $RELEASE_DIR -type f -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | while read -r jar; do
	base=$(basename $jar)
	targetname="${base%.jar}-${LWJGL_VERSION}.jar"
	install $jar $targetname
done

echo "Generating hashes"
pushd $TARGET
sha1sum * > hashes.sha1
popd

echo "Success"



