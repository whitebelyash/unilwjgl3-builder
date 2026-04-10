#!/bin/bash
set -e

if   [ "$LWJGL_BUILD_ARCH" == "arm64" ]; then
  export TOOLCHAIN=arm64 TRIPLET=aarch64-linux-android
elif [ "$LWJGL_BUILD_ARCH" == "arm32" ]; then
  export TOOLCHAIN=arm TRIPLET=arm-linux-androideabi
elif [ "$LWJGL_BUILD_ARCH" == "x86" ]; then
  export TOOLCHAIN=x86 TRIPLET=i686-linux-android
elif [ "$LWJGL_BUILD_ARCH" == "x64" ]; then
  export TOOLCHAIN=x86_64 TRIPLET=x86_64-linux-android
fi

export TOOLCHAIN_PATH=/tmp/toolchain-$TOOLCHAIN

mkdir $TOOLCHAIN_PATH
pushd $TOOLCHAIN_PATH

wget -nc -nv https://github.com/MojoLauncher/gcc-toolchain/releases/download/prebuilt/gcc-13-$TOOLCHAIN-21.tar.xz
tar xf gcc-13-$TOOLCHAIN-21.tar.xz
rm gcc-13-$TOOLCHAIN-21.tar.xz

rm sysroot/usr/lib/libstdc++.a
rm sysroot/usr/lib/libstdc++.so

popd

export PATH=$TOOLCHAIN_PATH/bin:$PATH

ant $ANTFLAGS -Dlinux.triplet=$TRIPLET compile-native