from conans import ConanFile, tools

class BoostConan(ConanFile):
    name = "boost"
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False],
                "android_ndk": "ANY", "android_stl_type":["c++_static", "c++_shared"]}
    default_options = "shared=False", "android_ndk=None"
    description = "Boost is a set of libraries for the C++ programming language."
    url = "https://github.com/Manromen/conan-boost-scripts"
    license = "Boost Software License"

    def package(self):
        self.copy("*", dst="include", src='conan/include')
        self.copy("*.lib", dst="lib", src='conan/lib', keep_path=False)
        self.copy("*.dll", dst="bin", src='conan/lib', keep_path=False)
        self.copy("*.so", dst="lib", src='conan/lib', keep_path=False)
        self.copy("*.dylib", dst="lib", src='conan/lib', keep_path=False)
        self.copy("*.a", dst="lib", src='conan/lib', keep_path=False)
        
    def package_id(self):
        if "arm" in self.settings.arch and self.settings.os == "iOS":
            self.info.settings.arch = "AnyARM"

    def package_info(self):
        self.cpp_info.libs = tools.collect_libs(self)
        self.cpp_info.includedirs = ['include']

    def config_options(self):
        # remove android specific option for all other platforms
        if self.settings.os != "Android":
            del self.options.android_ndk
            del self.options.android_stl_type
