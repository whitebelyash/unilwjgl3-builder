#!/bin/bash

set -e

git clone --depth 1 https://github.com/LWJGL/lwjgl3
cd lwjgl3

git apply --reject --whitespace=fix ../lwjgl3_droid_syscall.diff || echo "git apply failed (universal patch set)"

export ANTFLAGS="-Dplatform.linux=true -Dbinding.nfd=false -Dbinding.jawt=false -Dbinding.remotery=false"

ant $ANTFLAGS compile-templates compile

LWJGL_BUILD_ARCH=arm64 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=arm32 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=x86 bash ../ci_build_android.bash
LWJGL_BUILD_ARCH=x64 bash ../ci_build_android.bash

ant $ANTFLAGS -Dbuild.offline=true release
