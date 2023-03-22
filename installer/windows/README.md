# Windows Installers How-to

## Initial setup
1. Download the DLLs package from <url>
2. Install Wix toolset (v3) from <http://wixtoolset.org>
3. Add the installed Wix toolset bin folder (e.g. "C:\Program Files (x86)\WiX Toolset v3.11\bin") to the Windows PATH environment variable

## Building prerequisites (miniAudicle + chuck + chugins)

The resulting installer packages the command line chuck binary, the miniAudicle binary, a standard set of chugins, the standard ChucK examples, an Ogg Vorbis audio encoder used for exporting ChucK programs, and . 
The miniAudicle + chuck + chugin binaries must all be built as a prerequisite to building the installer. 

1. Build miniAudicle for Windows (instructions in src/qt). 
Ensure you are building a Release version of miniAudicle. 
2. Note the folder that miniAudicle for Windows was built into (should be something like build-miniAudicle-Desktop_Qt_6_4_1_MSVC2019_64bit-Release). 
The installer makefile will automatically try to find it in a directory matching this general pattern. 
3. Also build chuck and all packaged chugins in their respective VS solutions files. 
These should also be in Release mode. 
The installer makefile automatically attempts to find the resulting binaries in the corresponding build folders.

The installer makefile will generate an error if any of the build output folders don't match its expectations, so you may need to make adjustments if it can't find any of these!

## Building the installer 

1. Before building, ensure that `src/version.mk` has the correct values for the version number. 
2. In this directory, run `make`. 
3. After this process completes, if no errors occurred, you should see a `chuck-[version].msi` file in this directory. 
This is your installer!

You can run `make clean` to re-run this process from the start. 