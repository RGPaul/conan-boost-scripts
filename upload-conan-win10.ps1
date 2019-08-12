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

#=======================================================================================================================
# settings

$LIBRARY_VERSION = "1.70.0"
$TARBALL_COMPILER = "msvc14.1"
$VS_VERSION = 15                  # Visual Studio 15 2017

#=======================================================================================================================
# globals

$LIBRARY_TARBALL = "boost-win10-${TARBALL_COMPILER}-mt-s-${LIBRARY_VERSION}.zip"
$LIBRARY_TARBALL_PATH = "${PSScriptRoot}\${LIBRARY_TARBALL}"
$LIBRARY_CONAN_FOLDER = "${PSScriptRoot}\conan"

#=======================================================================================================================

function ExtractZipArchive($arch, $build_type)
{
    if ((test-path $LIBRARY_TARBALL_PATH))
    {
        Expand-Archive -Path $LIBRARY_TARBALL_PATH -DestinationPath $LIBRARY_CONAN_FOLDER

        # delete unnecessary architectures
        if ($arch.equals("x86"))
        {
            # for x86 we will delete the x86_64 libraries
            Remove-Item "${LIBRARY_CONAN_FOLDER}\lib\*-x64-*.lib"
        }
        elseif ($arch.equals("x86_64"))
        {
            # for x86_64 we will delete the x86 libraries
            Remove-Item "${LIBRARY_CONAN_FOLDER}\lib\*-x32-*.lib"
        }

        # delete unnecessary build types
        if ($build_type.equals("Release"))
        {
            # for the release builds we will delete the debug libraries
            Remove-Item "${LIBRARY_CONAN_FOLDER}\lib\*-sgd-*.lib"
        }
        elseif ($build_type.equals("Debug"))
        {
            # for the debug builds we will delete the release libraries
            Remove-Item "${LIBRARY_CONAN_FOLDER}\lib\*-s-*.lib"
        }
    }
    else
    {
        Write-Host "File ${LIBRARY_TARBALL} not existing"
    }
}

#=======================================================================================================================

function CreateConanPackage($arch, $build_type, $runtime)
{
    & conan export-pkg . boost/${LIBRARY_VERSION}@rgpaul/stable -s os=Windows `
        -s compiler="Visual Studio" `
        -s compiler.runtime=$runtime `
        -s compiler.version=$VS_VERSION `
        -s arch=$arch `
        -s build_type=$build_type `
        -o shared=False
}

#=======================================================================================================================

function UploadConanPackages()
{
    & conan upload boost/${LIBRARY_VERSION}@rgpaul/stable -r rgpaul --all
}

#=======================================================================================================================

function Cleanup()
{
    Remove-Item -Recurse -Path ${LIBRARY_CONAN_FOLDER}
}

#=======================================================================================================================

ExtractZipArchive x86 Release
CreateConanPackage x86 Release MT
Cleanup
ExtractZipArchive x86 Debug
CreateConanPackage x86 Debug MTd
Cleanup
ExtractZipArchive x86_64 Release
CreateConanPackage x86_64 Release MT
Cleanup
ExtractZipArchive x86_64 Debug
CreateConanPackage x86_64 Debug MTd
Cleanup
UploadConanPackages

#Write-Host "`nPress any key to close...";
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
