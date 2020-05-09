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


# ATTENTION: execute this script using "Developer Powershell for VS 2019"

#=======================================================================================================================
# settings

$LIBRARY_VERSION = "1.73.0"

#=======================================================================================================================
# globals

$LIBRARY_VERSION2 = $LIBRARY_VERSION.Replace(".", "_")
$LIBRARY_TARBALL = "boost_${LIBRARY_VERSION2}.zip"
$LIBRARY_DOWNLOAD_URI = "https://dl.bintray.com/boostorg/release/${LIBRARY_VERSION}/source/${LIBRARY_TARBALL}"
$LIBRARY_TARBALL_PATH = "${PSScriptRoot}\${LIBRARY_TARBALL}"
$LIBRARY_FOLDER = "${PSScriptRoot}\boost_${LIBRARY_VERSION2}"
$LIBRARY_INSTALL_FOLDER = "${PSScriptRoot}\install"
$LIBRARY_BUILD_FOLDER = "${PSScriptRoot}\build"
$OLD_PATH = $env:Path

#=======================================================================================================================

function Download() {
    # only download if not already present
    if (!(test-path $LIBRARY_TARBALL_PATH)) {
        Write-Host "File ${LIBRARY_TARBALL} does not exist. Download now...`n`n"

        # set protocol to tls version 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $LIBRARY_DOWNLOAD_URI -OutFile $LIBRARY_TARBALL_PATH
    }
    else {
        Write-Host "File ${LIBRARY_TARBALL} already existing"
    }
}

#=======================================================================================================================

function Unpack() {

    # only download if not already present
    if (!(test-path $LIBRARY_FOLDER)) {
        Write-Host "Unpacking zip file..."
        Expand-Archive -Path $LIBRARY_TARBALL_PATH -DestinationPath $PSScriptRoot
    }
    else {
        Write-Host "Not extracting: ${LIBRARY_FOLDER} already existing"
    }
}

#=======================================================================================================================

function Build($arch, $model, $variant) {
    Push-Location "${LIBRARY_FOLDER}\tools\build"
    $buildPath = "${LIBRARY_BUILD_FOLDER}_${arch}_${model}_${variant}"
    New-Item -ItemType Directory -Path "${buildPath}"

    ".\${LIBRARY_FOLDER}\tools\build\bootstrap.bat"
    .\b2 "--prefix=${buildPath}" toolset=msvc architecture=${arch} address-model=${model} link=static runtime-link=static threading=multi variant=${variant} install

    $env:Path = "${OLD_PATH};${buildPath}\bin"

    Push-Location "${LIBRARY_FOLDER}"
    b2 "--build-dir=${buildPath}" toolset=msvc architecture=${arch} address-model=${model} link=static runtime-link=static threading=multi variant=${variant} stage

    Pop-Location
    Pop-Location
}

#=======================================================================================================================

function Cleanup() {
    # Remove-Item -Recurse -Path ${LIBRARY_INSTALL_FOLDER}

    if (!(test-path "${LIBRARY_BUILD_FOLDER}_x86_32_release")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_x86_32_release"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_x86_32_debug")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_x86_32_debug"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_x86_64_release")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_x86_64_release"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_x86_64_debug")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_x86_64_debug"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_arm_32_release")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_arm_32_release"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_arm_32_debug")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_arm_32_debug"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_arm_64_release")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_arm_64_release"
    }
    if (!(test-path "${LIBRARY_BUILD_FOLDER}_arm_64_debug")) {
        Remove-Item -Recurse -Path "${LIBRARY_BUILD_FOLDER}_arm_64_debug"
    }
}

#=======================================================================================================================

function Archive() {
    New-Item -ItemType Directory -Path ${LIBRARY_INSTALL_FOLDER}\include

    Copy-Item -Path ${LIBRARY_FOLDER}\stage\lib -Destination ${LIBRARY_INSTALL_FOLDER}\
    Copy-Item -Path ${LIBRARY_FOLDER}\boost -Destination ${LIBRARY_INSTALL_FOLDER}\include\

    Compress-Archive -Force -Path ${LIBRARY_INSTALL_FOLDER}\include, ${LIBRARY_INSTALL_FOLDER}\lib `
        -DestinationPath boost-${LIBRARY_VERSION}-win10.zip
}

#=======================================================================================================================

Write-Host  "################################################################################"
Write-Host  "###                                  Boost                                   ###"
Write-Host  "################################################################################`n"

Push-Location ${PSScriptRoot}

Download
Unpack
Build "x86" "64" "release"
Build "x86" "64" "debug"
Build "x86" "32" "release"
Build "x86" "32" "debug"
Build "arm" "64" "release"
Build "arm" "64" "debug"
Build "arm" "32" "release"
Build "arm" "32" "debug"

#Archive

#Cleanup

Pop-Location

Write-Host "`nPress any key to close...";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
