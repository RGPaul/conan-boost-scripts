# Building Boost for Windows 10

## Boost 1.68.0 for x86_64 (Command Prompt for Visual Studio 2017)

* Download the current boost sources from here: [boost_1_68_0.zip](https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.zip)
* Extract the files from the boost_1_68_0.zip to C:\boost_src
* Open the Command Prompt for Visual Studio 2017
* Change the directory to the tools\build folder: `cd C:\boost_src\tools\build`
* Bootstrap the boost sources: `bootstrap.bat`
* Depending on the target architecture and variant, execute the following b2 command:
    `b2 --prefix=C:\boost-build toolset=msvc architecture=x86 address-model=64 link=static runtime-link=static threading=multi variant=release install`
* Add the new bin folder to the PATH: `path=%PATH%;C:\boost-build\bin`
* Change the directory to the root of the boost source folder: `cd C:\boost_src`
* Build the libraries with the following b2 command:
    `b2 --build-dir=C:\boost-build toolset=msvc architecture=x86 address-model=64 link=static runtime-link=static threading=multi variant=release stage`

The final libraries can be found under: `C:\boost_src\stage\lib` and all headers under: `C:\boost_src\boost`

remove `C:\boost-build` and build the other variants

## Boost 1.68.0 for x86_64 (Developer Powershell for VS 2019)

* Download the current boost sources from here: [boost_1_68_0.zip](https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.zip)
* Extract the files from the boost_1_68_0.zip to C:\boost_src
* Open the ComDeveloper Powershell for VS 2019
* Change the directory to the tools\build folder: `cd C:\boost_src\tools\build`
* Bootstrap the boost sources: `.\bootstrap.bat`
* Depending on the target architecture and variant, execute the following b2 command:
    `.\b2 --prefix=C:\boost-build toolset=msvc architecture=x86 address-model=64 link=static runtime-link=static threading=multi variant=release install`
* Add the new bin folder to the PATH: `$env:Path += ";C:\boost-build\bin"`
* Change the directory to the root of the boost source folder: `cd C:\boost_src`
* Build the libraries with the following b2 command:
    `b2 --build-dir=C:\boost-build toolset=msvc architecture=x86 address-model=64 link=static runtime-link=static threading=multi variant=release stage`

The final libraries can be found under: `C:\boost_src\stage\lib` and all headers under: `C:\boost_src\boost`

remove `C:\boost-build` and build the other variants

### x86_64 debug

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=x86 address-model=64 link=static runtime-link=static threading=multi variant=debug install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=x86 address-model=64 link=static runtime-link=static threading=multi variant=debug stage`

### x86

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=x86 address-model=32 link=static runtime-link=static threading=multi variant=release install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=x86 address-model=32 link=static runtime-link=static threading=multi variant=release stage`

### x86 debug

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=x86 address-model=32 link=static runtime-link=static threading=multi variant=debug install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=x86 address-model=32 link=static runtime-link=static threading=multi variant=debug stage`

### arm 32

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=arm address-model=32 link=static runtime-link=static threading=multi variant=release install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=arm address-model=32 link=static runtime-link=static threading=multi variant=release stage`

### arm 32 debug

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=arm address-model=32 link=static runtime-link=static threading=multi variant=debug install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=arm address-model=32 link=static runtime-link=static threading=multi variant=debug stage`

### arm 64

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=arm address-model=64 link=static runtime-link=static threading=multi variant=release install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=arm address-model=64 link=static runtime-link=static threading=multi variant=release stage`

### arm 64 debug

* `Remove-Item -Recurse -Path C:\boost-build`
* `cd C:\boost_src\tools\build`
* `.\b2 --prefix=C:\boost-build toolset=msvc architecture=arm address-model=64 link=static runtime-link=static threading=multi variant=debug install`
* `cd C:\boost_src`
* `b2 --build-dir=C:\boost-build toolset=msvc architecture=arm address-model=64 link=static runtime-link=static threading=multi variant=debug stage`
