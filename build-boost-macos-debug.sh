#!/usr/bin/env bash
# ----------------------------------------------------------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2019-2020 Ralph-Gordon Paul. All rights reserved.
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

declare LIBRARY_VERSION=1.73.0

#=======================================================================================================================
# globals

declare ABSOLUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare MACOS_SDK_VERSION=$(xcodebuild -showsdks | grep " macosx" | awk '{print $4}' | sed 's/[^0-9,\.]*//g')

#=======================================================================================================================

function build()
{
    cd "${ABSOLUTE_DIR}/Apple"

    ./boost.sh -macos --macos-sdk "${MACOS_SDK_VERSION}" --min-macos-version 10.12 \
               --boost-version ${LIBRARY_VERSION} --no-framework --debug --macos-archs "x86_64" \
               --boost-libs "atomic chrono container context coroutine date_time exception fiber filesystem graph graph_parallel iostreams locale log math program_options python random regex serialization system test thread timer type_erasure wave"

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function archive()
{
    cd "${ABSOLUTE_DIR}/Apple/build/boost/${LIBRARY_VERSION}/macos/debug/prefix"

    mkdir -p "${ABSOLUTE_DIR}/builds/${LIBRARY_VERSION}" || true

    zip -r "${ABSOLUTE_DIR}/builds/${LIBRARY_VERSION}/boost-macos-sdk${MACOS_SDK_VERSION}-debug-clang-${LIBRARY_VERSION}.zip" include lib

    cd "${ABSOLUTE_DIR}"
}

#=======================================================================================================================

function cleanup()
{
    rm -r "${ABSOLUTE_DIR}/Apple/build" "${ABSOLUTE_DIR}/Apple/src"
}

#=======================================================================================================================

echo "################################################################################"
echo "###                                  Boost                                   ###"
echo "################################################################################"

build
archive
cleanup
