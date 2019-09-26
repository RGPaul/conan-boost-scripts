#!/usr/bin/env bash
# ----------------------------------------------------------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2019 Ralph-Gordon Paul. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the 
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ----------------------------------------------------------------------------------------------------------------------

#set -e

#=======================================================================================================================
# settings

declare LIBRARY_VERSION=1.71.0

declare CONAN_USER=rgpaul
declare CONAN_CHANNEL=stable
declare CONAN_REPOSITORY=rgpaul

# declare all precompiled ndks
declare ANDROID_NDKS=(
    "r20"
    "r19c"
    "r18b"
    "r17c"
    "r16b"
    )

declare ANDROID_ARCHS=(
    "armv7"
    "armv8"
    "x86"
    "x86_64"
    )

declare ANDROID_DEPRECATED_ARCHS=(
    "armv6"
    "mips"
    "mips64"
    )

declare NDK_CLANG_VERSIONS=(
    "r20:8.0"
    "r19c:8.0"
    "r18b:7.0"
    "r17c:6.0"
    "r16b:5.0"
    )

declare ARCH_API_LEVEL=(
    "armv6:19"
    "armv7:19"
    "armv8:21"
    "x86:19"
    "x86_64:21"
    "mips:19"
    "mips64:21"
    )

#=======================================================================================================================
# globals

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#=======================================================================================================================

function extractZipArchive()
{
    declare NDK_VERSION=$1
    declare ARCH=$2

    if [ "$ARCH" == "armv7" ]; then
        ARCH=armeabi-v7a
    elif [ "$ARCH" == "armv8" ]; then
        ARCH=arm64-v8a
    elif [ "$ARCH" == "armv6" ]; then
        ARCH=armeabi
    fi

    rm -rf "${ABSOLUTE_DIR}/conan" || true
    mkdir "${ABSOLUTE_DIR}/conan"
    
    echo "Extracting boost-android-${NDK_VERSION}-${ARCH}-${LIBRARY_VERSION}.zip ..."
    unzip -q "${ABSOLUTE_DIR}/builds/${LIBRARY_VERSION}/boost-android-${NDK_VERSION}-${ARCH}-${LIBRARY_VERSION}.zip" -d "${ABSOLUTE_DIR}/conan"

    cd "${ABSOLUTE_DIR}/conan/lib/${ARCH}"

    for file in *.a; do
        mv $file "../${file%%-*}"
    done

    cd "${ABSOLUTE_DIR}"
    rm -r "${ABSOLUTE_DIR}/conan/lib/${ARCH}"
}

#=======================================================================================================================

function createConanPackage()
{
    declare NDK_VERSION=$1
    declare ARCH=$2

    for ndk_clang_value in "${NDK_CLANG_VERSIONS[@]}" ; do
        KEY=${ndk_clang_value%%:*}
        VALUE=${ndk_clang_value#*:}
        if [ "$KEY" == "${NDK_VERSION}" ]; then
            declare COMPILER_VERSION=$VALUE
        fi
    done

    for arch_api_level_value in "${ARCH_API_LEVEL[@]}" ; do
        KEY=${arch_api_level_value%%:*}
        VALUE=${arch_api_level_value#*:}
        if [ "$KEY" == "${ARCH}" ]; then
            declare API_LEVEL=$VALUE
        fi
    done

    conan export-pkg . boost/${LIBRARY_VERSION}@${CONAN_USER}/${CONAN_CHANNEL} -s os=Android \
          -s os.api_level=${API_LEVEL} -s compiler=clang -s compiler.libcxx=libc++ \
          -s compiler.version=${COMPILER_VERSION} -s build_type=Release \
          -s arch=${ARCH} -s os_build=Linux -s arch_build=x86_64 -o android_ndk=${NDK_VERSION} \
          -o android_stl_type=c++_static
}

#=======================================================================================================================

function uploadConanPackages()
{
	conan upload boost/${LIBRARY_VERSION}@${CONAN_USER}/${CONAN_CHANNEL} -r ${CONAN_REPOSITORY} --all
}

#=======================================================================================================================

function cleanup()
{
    rm -r "${ABSOLUTE_DIR}/conan"
}

#=======================================================================================================================

for NDK in ${ANDROID_NDKS[@]}; do
    for ARCH in ${ANDROID_ARCHS[@]}; do

        extractZipArchive $NDK $ARCH
        createConanPackage $NDK $ARCH
        cleanup

    done

    if [ "$NDK" == "16b" ]; then
        for ARCH in ${ANDROID_DEPRECATED_ARCHS[@]}; do

            extractZipArchive $NDK $ARCH
            createConanPackage $NDK $ARCH
            cleanup

        done
    fi
done

uploadConanPackages
