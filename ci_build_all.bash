#!/bin/bash

set -e

if [ -z "$LWJGL_VERSION" ]; then
   echo "LWJGL version not set"
   exit 1
fi

if [ -z "$LIBFFI_VERSION" ]; then
   echo "libffi version not set"
   exit 1
fi

mkdir lib
pushd lib
wget -nc -nv https://repo1.maven.org/maven2/org/openjdk/nashorn/nashorn-core/15.7/nashorn-core-15.7.jar
wget -nc -nv https://repo1.maven.org/maven2/org/ow2/asm/asm/7.3.1/asm-7.3.1.jar
wget -nc -nv https://repo1.maven.org/maven2/org/ow2/asm/asm-commons/7.3.1/asm-commons-7.3.1.jar
wget -nc -nv https://repo1.maven.org/maven2/org/ow2/asm/asm-tree/7.3.1/asm-tree-7.3.1.jar
wget -nc -nv https://repo1.maven.org/maven2/org/ow2/asm/asm-util/7.3.1/asm-util-7.3.1.jar
export NASHORN=$(pwd)
popd

git clone --depth 1 --branch $LWJGL_VERSION https://github.com/LWJGL/lwjgl3
cd lwjgl3

git apply --reject --whitespace=fix ../lwjgl3_uni_cflags_ldflags.diff || echo "git apply failed (universal build system patch)"

if [ -f "./modules/lwjgl/core/src/templates/kotlin/core/linux/templates/uio.kt" ]; then
   git apply --reject --whitespace=fix ../lwjgl3_droid_syscall.diff || echo "git apply failed (droid_uio syscall patch)"
fi

if [ -f "./modules/lwjgl/core/src/main/c/linux/LinuxLWJGL.h" ]; then
   git apply --reject --whitespace=fix ../lwjgl3_remove_x11_hdr.diff || echo "git apply failed (remove LinuxLWJGL.h)"
fi


export ANTFLAGS="-lib $NASHORN -Dplatform.linux=true -Dbinding.nfd=false -Dbinding.jawt=false -Dbinding.remotery=false -Dbinding.zstd=false -Dbinding.rpmalloc=false -Dbinding.yoga=false -Dbinding.meow=false"

ant $ANTFLAGS compile-templates compile

mkdir debuginfo

LWJGL_BUILD_ARCH=arm64 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=arm32 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=x86 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=x64 bash ../ci_build_android.bash

ant $ANTFLAGS -Dbuild.offline=true release
