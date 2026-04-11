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

git clone --depth 1 --branch $LWJGL_VERSION https://github.com/LWJGL/lwjgl3
cd lwjgl3

git apply --reject --whitespace=fix ../lwjgl3_uni_cflags_ldflags.diff || echo "git apply failed (universal build system patch)"

if [ -f "./modules/lwjgl/core/src/templates/kotlin/core/linux/templates/uio.kt" ]; then
   git apply --reject --whitespace=fix ../lwjgl3_droid_syscall.diff || echo "git apply failed (droid_uio syscall patch)"
fi

export ANTFLAGS="-Dplatform.linux=true -Dbinding.nfd=false -Dbinding.jawt=false -Dbinding.remotery=false -Dbinding.zstd=false"

ant $ANTFLAGS compile-templates compile

mkdir debuginfo

LWJGL_BUILD_ARCH=arm64 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=arm32 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=x86 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=x64 bash ../ci_build_android.bash

ant $ANTFLAGS -Dbuild.offline=true release
