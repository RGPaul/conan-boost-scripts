# Building Boost for Windows 10

## Boost 1.68.0 for x86_64

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


