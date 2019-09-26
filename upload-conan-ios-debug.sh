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

set -e

#=======================================================================================================================
# settings

declare LIBRARY_VERSION=1.70.0

declare CONAN_USER=rgpaul
declare CONAN_CHANNEL=stable
declare CONAN_REPOSITORY=rgpaul

#=======================================================================================================================
# globals

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare IOS_SDK_VERSION=$(xcodebuild -showsdks | grep iphoneos | awk '{print $4}' | sed 's/[^0-9,\.]*//g')

#=======================================================================================================================

function extractZipArchive()
{
    rm -rf "${ABSOLUTE_DIR}/conan" || true
    mkdir "${ABSOLUTE_DIR}/conan"
    
    echo "Extracting boost-ios-sdk${IOS_SDK_VERSION}-debug-${LIBRARY_VERSION}.zip ..."
    unzip -q "${ABSOLUTE_DIR}/builds/${LIBRARY_VERSION}/boost-ios-sdk${IOS_SDK_VERSION}-debug-${LIBRARY_VERSION}.zip" -d "${ABSOLUTE_DIR}/conan"
}

#=======================================================================================================================

function removeArchFromLibraries()
{
    cd "${ABSOLUTE_DIR}/conan/lib"

    for file in *.a; do
        lipo -remove $1 $file -output $file
    done

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function createConanPackage()
{
    conan export-pkg . boost/${LIBRARY_VERSION}@${CONAN_USER}/${CONAN_CHANNEL} -s os=iOS \
          -s os.version=${IOS_SDK_VERSION} \
    	  -s compiler=apple-clang -s compiler.libcxx=libc++ -s build_type=Debug -s arch=$1 -s os_build=Macos \
    	  -s arch_build=x86_64
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

declare DEVICE_ARCHS=("armv7" "armv7s" "arm64" "arm64e")
declare SIMULATOR_ARCHS=("i386" "x86_64")

extractZipArchive
for arch in ${SIMULATOR_ARCHS[@]}; do removeArchFromLibraries $arch; done
createConanPackage armv8
cleanup

extractZipArchive
for arch in ${DEVICE_ARCHS[@]}; do removeArchFromLibraries $arch; done
createConanPackage x86_64
cleanup

uploadConanPackages
