#!/usr/bin/env bash
# ----------------------------------------------------------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2018-2019 Ralph-Gordon Paul. All rights reserved.
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

# set -e

#=======================================================================================================================
# settings

declare LIBRARY_VERSION="1.71.0"

#=======================================================================================================================
# globals

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare LIBRARY_VERSION2=${LIBRARY_VERSION//./_}
declare LIBRARY_TARBALL="boost_${LIBRARY_VERSION2}.zip"
declare LIBRARY_DOWNLOAD_URI="https://dl.bintray.com/boostorg/release/${LIBRARY_VERSION}/source/${LIBRARY_TARBALL}"
declare LIBRARY_FOLDER="${ABSOLUTE_DIR}/boost_${LIBRARY_VERSION2}"
declare LIBRARY_INSTALL_FOLDER="${ABSOLUTE_DIR}/install"
declare LIBRARY_BUILD_FOLDER="${ABSOLUTE_DIR}/build"

#=======================================================================================================================

function download()
{
    # only download if not already present
    if [ ! -s ${LIBRARY_TARBALL} ]; then

        echo "Downloading ${LIBRARY_TARBALL}"
        
        curl -L -o ${LIBRARY_TARBALL} ${LIBRARY_DOWNLOAD_URI}
    else
        echo "${LIBRARY_TARBALL} already existing"
    fi
}

#=======================================================================================================================

function unpack()
{
    [ -f "${LIBRARY_TARBALL}" ] || abort "Source tarball missing."

    echo "Unpacking \"${LIBRARY_TARBALL}\"..."

    unzip -o "${LIBRARY_TARBALL}"
}

#=======================================================================================================================

function build()
{
    rm -r "${LIBRARY_BUILD_FOLDER}" ${LIBRARY_INSTALL_FOLDER} || true
    mkdir -p "${LIBRARY_BUILD_FOLDER}" "${LIBRARY_INSTALL_FOLDER}/lib" "${LIBRARY_INSTALL_FOLDER}/include"
    
    cd "${LIBRARY_FOLDER}/tools/build"

    ./bootstrap.sh

    # Build x86_64

    ./b2 "--prefix=${LIBRARY_BUILD_FOLDER}" toolset=gcc architecture=x86 address-model=64 link=static \
        runtime-link=static threading=multi variant=release install

    export "PATH=$PATH:${LIBRARY_BUILD_FOLDER}/bin"

    cd "${LIBRARY_FOLDER}"

    b2 "--build-dir=${LIBRARY_BUILD_FOLDER}" toolset=gcc architecture=x86 address-model=64 link=static \
        runtime-link=static threading=multi variant=release stage

    mv "${LIBRARY_FOLDER}/stage/lib" "${LIBRARY_INSTALL_FOLDER}/lib/x86_64"

    # Build x86

    rm -r "${LIBRARY_BUILD_FOLDER}" && mkdir -p "${LIBRARY_BUILD_FOLDER}"

    cd "${LIBRARY_FOLDER}/tools/build"

    ./b2 "--prefix=${LIBRARY_BUILD_FOLDER}" toolset=gcc architecture=x86 address-model=32 link=static \
        runtime-link=static threading=multi variant=release install

    cd "${LIBRARY_FOLDER}"

    b2 "--build-dir=${LIBRARY_BUILD_FOLDER}" toolset=gcc architecture=x86 address-model=32 link=static \
        runtime-link=static threading=multi variant=release stage

    mv "${LIBRARY_FOLDER}/stage/lib" "${LIBRARY_INSTALL_FOLDER}/lib/x86"

    cp -r "${LIBRARY_FOLDER}/boost" "${LIBRARY_INSTALL_FOLDER}/include/"

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function cleanup()
{
    rm -r "${LIBRARY_FOLDER}" "${LIBRARY_BUILD_FOLDER}" "${LIBRARY_INSTALL_FOLDER}"
}

#=======================================================================================================================

function archive()
{
    echo "Archive ..."

    cd "${LIBRARY_INSTALL_FOLDER}"
    zip -r "${ABSOLUTE_DIR}/boost-debian-${LIBRARY_VERSION}.zip" include lib
}

#=======================================================================================================================

echo "################################################################################"
echo "###                                   Boost                                  ###"
echo "################################################################################"
    

download
unpack
build
archive
cleanup
