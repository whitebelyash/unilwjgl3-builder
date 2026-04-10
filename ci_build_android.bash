#!/bin/bash
set -e

if   [ "$LWJGL_BUILD_ARCH" == "arm64" ]; then
  export TOOLCHAIN=arm64 TRIPLET=aarch64-linux-android FFI_SUFFIX=64
elif [ "$LWJGL_BUILD_ARCH" == "arm32" ]; then
  export TOOLCHAIN=arm TRIPLET=arm-linux-androideabi
elif [ "$LWJGL_BUILD_ARCH" == "x86" ]; then
  export TOOLCHAIN=x86 TRIPLET=i686-linux-android
elif [ "$LWJGL_BUILD_ARCH" == "x64" ]; then
  export TOOLCHAIN=x86_64 TRIPLET=x86_64-linux-android FFI_SUFFIX=64
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

LWJGL_NATIVE=bin/libs/native/linux/$LWJGL_BUILD_ARCH/org/lwjgl
mkdir -p $LWJGL_NATIVE

if [ "$SKIP_LIBFFI" != "1" ]; then
  export LIBFFI_PREFIX=/tmp/ffi-$TOOLCHAIN
  export LIBFFI_VERSION=3.5.2

  # Get libffi
  if [ ! -d libffi ]; then
    wget https://github.com/libffi/libffi/releases/download/v$LIBFFI_VERSION/libffi-$LIBFFI_VERSION.tar.gz
    tar xvf libffi-$LIBFFI_VERSION.tar.gz
    mv libffi-$LIBFFI_VERSION libffi
  fi
  pushd libffi

  # Build libffi
  bash configure --host=$TRIPLET --prefix=$LIBFFI_PREFIX
  make -j4
  make install

  popd

  # Copy libffi
  cp $LIBFFI_PREFIX/lib$FFI_SUFFIX/libffi.a $LWJGL_NATIVE/
fi

ant $ANTFLAGS -Dlinux.triplet=$TRIPLET compile-native