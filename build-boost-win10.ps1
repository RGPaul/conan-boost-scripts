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

#=======================================================================================================================
# settings

$LIBRARY_VERSION = "1.68.0"

#=======================================================================================================================
# globals

$LIBRARY_VERSION2 = $LIBRARY_VERSION.Replace(".","_")
$LIBRARY_TARBALL = "boost_${LIBRARY_VERSION2}.zip"
$LIBRARY_DOWNLOAD_URI = "https://dl.bintray.com/boostorg/release/${LIBRARY_VERSION}/source/${LIBRARY_TARBALL}"
$LIBRARY_TARBALL_PATH = "${PSScriptRoot}\${LIBRARY_TARBALL}"
$LIBRARY_FOLDER = "${PSScriptRoot}\boost_${LIBRARY_VERSION2}"
$LIBRARY_INSTALL_FOLDER = "${PSScriptRoot}\install"
$LIBRARY_BUILD_FOLDER = "${PSScriptRoot}\build"

#=======================================================================================================================

function Download()
{
    # only download if not already present
    if (!(test-path $LIBRARY_TARBALL_PATH))
    {
        Write-Host "File ${LIBRARY_TARBALL} does not exist. Download now...`n`n"

        # set protocol to tls version 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $LIBRARY_DOWNLOAD_URI -OutFile $LIBRARY_TARBALL_PATH
    }
    else
    {
        Write-Host "File ${LIBRARY_TARBALL} already existing"
    }
}

#=======================================================================================================================

function Unpack()
{
    Write-Host "Unpacking zip file..."
    Expand-Archive -Path $LIBRARY_TARBALL_PATH -DestinationPath $PSScriptRoot
}

#=======================================================================================================================

function Build($arch, $model)
{
    Set-Location "${LIBRARY_FOLDER}\tools\build"
    $buildPath = "${LIBRARY_INSTALL_FOLDER}\${arch}_${model}"
    New-Item -ItemType Directory -Path "${buildPath}"

    & "${LIBRARY_FOLDER}\tools\build\bootstrap.bat"
    & .\b2 "--prefix=${buildPath}" toolset=msvc architecture=${arch} address-model=${model} link=static runtime-link=static threading=multi variant=debug install
    $env:Path += ";${buildPath}\bin"

    Set-Location "${LIBRARY_FOLDER}"
    & b2 "--build-dir=${buildPath}" toolset=msvc architecture=${arch} address-model=${model} link=static runtime-link=static threading=multi variant=debug stage

    Set-Location $PSScriptRoot
}

#=======================================================================================================================

function Cleanup()
{
    Remove-Item -Recurse -Path ${LIBRARY_BUILD_FOLDER}, ${LIBRARY_FOLDER}, ${LIBRARY_INSTALL_FOLDER}
}

#=======================================================================================================================

function Archive()
{
    New-Item -ItemType Directory -Path ${LIBRARY_INSTALL_FOLDER}\lib
    Move-Item -Path ${LIBRARY_INSTALL_FOLDER}\lib_x86 -Destination ${LIBRARY_INSTALL_FOLDER}\lib\x86
    Move-Item -Path ${LIBRARY_INSTALL_FOLDER}\lib_x64 -Destination ${LIBRARY_INSTALL_FOLDER}\lib\x64
    Move-Item -Path ${LIBRARY_INSTALL_FOLDER}\lib_arm -Destination ${LIBRARY_INSTALL_FOLDER}\lib\arm

    Compress-Archive -Force -Path ${LIBRARY_INSTALL_FOLDER}\include, ${LIBRARY_INSTALL_FOLDER}\lib `
        -DestinationPath boost-${LIBRARY_SEMVER}-win10.zip
}

#=======================================================================================================================

Write-Host  "################################################################################"
Write-Host  "###                                  Boost                                   ###"
Write-Host  "################################################################################`n"


#Push-Location "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools"
Push-Location "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"
cmd /c "VsDevCmd.bat&set" | 
ForEach-Object { 
    if ($_ -match "=") { 
        $v = $_.split("="); set-item -force -path "ENV:\$($v[0])" -value "$($v[1])" 
    } 
} 
Pop-Location 
Write-Host "`nVisual Studio 2017 Command Prompt variables set." -ForegroundColor Yellow

Download
Unpack
#Build Win32
Build "x86" "64"
#Build ARM
#Archive
#Cleanup

Write-Host "`nPress any key to close...";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
