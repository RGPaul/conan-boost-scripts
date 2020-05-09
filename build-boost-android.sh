#!/usr/bin/env bash
# ----------------------------------------------------------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2018-2020 Ralph-Gordon Paul. All rights reserved.
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

set -e

#=======================================================================================================================
# settings

declare LIBRARY_VERSION=1.70.0

#=======================================================================================================================
# globals

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare LIBRARY_VERSION2=${LIBRARY_VERSION//./_}

#=======================================================================================================================

function getAndroidNdkVersion()
{
    # get properties file that contains the ndk revision number
    local NDK_RELEASE_FILE=$ANDROID_NDK_PATH"/source.properties"
    if [ -f "${NDK_RELEASE_FILE}" ]; then
        local NDK_RN=`cat $NDK_RELEASE_FILE | grep 'Pkg.Revision' | sed -E 's/^.*[=] *([0-9]+[.][0-9]+)[.].*/\1/g'`
    else
        echo "ERROR: can not find android ndk version"
        exit 1
    fi

    # convert ndk revision number
    case "${NDK_RN#*'.'}" in
        "0")
            NDK_VERSION="r${NDK_RN%%'.'*}"
            ;;

        "1")
            NDK_VERSION="r${NDK_RN%%'.'*}b"
            ;;

        "2")
            NDK_VERSION="r${NDK_RN%%'.'*}c"
            ;;
        
        "3")
            NDK_VERSION="r${NDK_RN%%'.'*}d"
            ;;

        "4")
            NDK_VERSION="r${NDK_RN%%'.'*}e"
            ;;

        *)
            echo "Undefined or not supported Android NDK version: $NDK_RN"
            exit 1
    esac
}

#=======================================================================================================================

function build()
{
    cd "${ABSOLUTE_DIR}/Android"

    ./build-android.sh --boost=${LIBRARY_VERSION} ${ANDROID_NDK_PATH}

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function restructureOutput()
{
    cd "${ABSOLUTE_DIR}/Android/build"

    # copy header files
    mkdir -p "${ABSOLUTE_DIR}/Android/build/include"
    mkdir "${ABSOLUTE_DIR}/Android/build/lib"
    cp -r "${ABSOLUTE_DIR}/Android/boost_${LIBRARY_VERSION2}/boost" "${ABSOLUTE_DIR}/Android/build/include/"

    # goto created library files and iterate over all architectures
    cd "${ABSOLUTE_DIR}/Android/build/out"

    for folder in *; do
        echo "folder: $folder"

        rm -r "${ABSOLUTE_DIR}/Android/build/out/${folder}/include"
        
        cd "${ABSOLUTE_DIR}/Android/build/out/${folder}/lib"

        for file in *.a; do
            mv $file "../${file%%-*}.a"
        done

        rm -r "${ABSOLUTE_DIR}/Android/build/out/${folder}/lib"
        mv "${ABSOLUTE_DIR}/Android/build/out/${folder}" "${ABSOLUTE_DIR}/Android/build/lib/"
    done

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function archive()
{
    cd "${ABSOLUTE_DIR}/Android/build"

    mkdir -p "${ABSOLUTE_DIR}/builds/${LIBRARY_VERSION}" || true

    zip -r "${ABSOLUTE_DIR}/builds/${LIBRARY_VERSION}/boost-android-${NDK_VERSION}-${LIBRARY_VERSION}.zip" include lib

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function cleanup()
{
    rm -rf "${ABSOLUTE_DIR}/Android/boost_${LIBRARY_VERSION2}" "${ABSOLUTE_DIR}/Android/build"
}

#=======================================================================================================================

echo "################################################################################"
echo "###                                  Boost                                   ###"
echo "################################################################################"

getAndroidNdkVersion
build
restructureOutput
archive
cleanup


