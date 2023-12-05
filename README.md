# miniAudicle
<img src="https://chuck.stanford.edu/doc/images/miniAudicle-1.jpg" width="720"/>

## IDE for ChucK
**miniAudicle** is an integrated development environment (IDE) for the **ChucK** music programming language. It provides graphical user interfaces for code editing, on-the-fly proramming commands (`add`, `replace`, `remove`), visualization of ChucK virtual machines shreds, and tools for probing and setting audio and HID devices. miniAudicle integrates these front-end features with a full ChucK virtual machine and synthesis engine running within miniAudicle.

## Installing miniAudicle
To download and install **miniAudicle** and command-line **chuck**, visit https://chuck.stanford.edu/release/

miniAudicle submodules: [ChucK](https://github.com/ccrma/chuck) | [Chugins](https://github.com/ccrma/chugins)

## Building miniAudicle
To build the latest miniAudicle from source, clone the `miniAudicle` repo from github:
```
git clone --recurse-submodules https://github.com/ccrma/miniAudicle.git
```
### macOS (Cocoa)
By default, miniAudicle on macOS builds with **Cocoa** for windowing and graphical user interfaces.

To build miniAudicle, navigate to the `miniAudicle/src` directory, and run `make`:
```
cd miniAudicle/src
make mac
```
OR to build a universal binary (intel + apple sillicon):
```
make mac-ub
```

This should build a `miniAudicle.app` application in `src/macosx`.

### macOS (Qt)
Alternately, miniAudicle can be built using Qt on macOS. This requires **Qt6** and the **QScintilla** library. **Qt6** development tools can be installed from [here](https://www.qt.io/download-open-source). **QScintilla** can be built from [source](https://riverbankcomputing.com/software/qscintilla/download) using `Qt Creator` or `qmake`. Or you can use our [pre-built qscintilla2_qt6 libraries](https://chuck.stanford.edu/release/files/extra/qscintilla2_qt6.zip) (following the included instructions to copy the necessary headers and libraries files). From here, these are several ways to build miniAudicle with Qt on macOS. For one, you can use `Qt Creator` to open `miniAudicle/src/miniAudicle.pro` and build.

As an alternative to installing/buliding Qt and Qscintilla as described above, you can also install these libraries using Homebrew:
```
brew install qt
brew install qscintilla2
```
If you have multiple Qt versions installed, set this variable to avoid mixing in Qt5 content:
```
export QT_SELECT=qt6
```
To build from the command line (either of the two approaches above should work, as long as the headers and paths are in place):
```
cd miniAudicle/src
make mac-qt
```

This should build a `miniAudicle.app` (Qt edition, universal binary) in `src`.


### Linux
Dependencies: gcc, g++, make, bison, flex, Qt6, QScintilla, libsndfile, ALSA, PulseAudio (for linux-pulse builds), JACK (for linux-jack builds)

To set up a build environment for **miniAudicle** on Debian or Ubuntu:
```
sudo apt install build-essential bison flex libqt6-base-dev libqscintilla2-qt6-dev \
  libsndfile1-dev libasound2-dev libpulse-dev libjack-jackd2-dev
```
For other Linux distributions, the setup should be similar although the package install tools and package names may be slightly different. NOTE: setups that do not need JACK or PulseAudio can omit either or both of these packages. ALSA is needed for MIDI support on Linux.

If you have multiple Qt versions installed, set this variable to avoid mixing in Qt5 content:
```
export QT_SELECT=qt6
```

To build **miniAudicle** (with all supported drivers: ALSA, PulseAudio, and JACK), navigate to the `miniAudicle/src` directory and run 'make':
```
cd miniAudicle/src
make linux
```

To build **miniAudicle** with support for a subset of ALSA, PulseAudio, or JACK,  run `make` with desired driver(s). For example, to build for ALSA and PulseAudio only:
```
make linux-alsa linux-pulse
```

Or, to build for ALSA only:
```
make linux-alsa
```

This should build a `miniAudicle` executable in `src`.


### Windows
miniAudicle on Windows requires [**Qt6**](https://www.qt.io/download-open-source) and the QScintilla library. In the `Qt Creator` IDE, open `miniAudicle/src/miniAudicle.pro` and build.

**QScintilla** can be built from [source](https://riverbankcomputing.com/software/qscintilla/download) using `Qt Creator` or `qmake`. Alternately, you can use our [pre-built qscintilla_qt6 libraries](https://chuck.stanford.edu/release/files/extra/qscintilla2_qt6.zip) (following the included instructions to copy the necessary headers and libraries files).


## miniAudicle History
**miniAudicle** was created by Spencer Salazar in 2005, two years after the initial release of the ChucK programming language, originated by Ge Wang and Perry R. Cook, and one year after the creation of the **the Audicle** (see [2004 paper](https://ccrma.stanford.edu/~ge/publish/files/2004-icmc-audicle.pdf)). The original Audicle was designed as a 3D graphics-based IDE for live-coding ChucK programs while visualizing these programs' deep structure. (Perry Cook had suggested the name 'audicle' could be the all-_hearing_ equivalent of an all-_seeing_ "oracle".) While the Audicle showed potential, its 3D-graphics intensive backend (in OpenGL) was extremely time-consuming to develop into an usable tool. This gave rise to the _miniAudicle_, which was to be a lighter version of the Audicle, using establish windowing and GUI frameworks (like Cocoa and Qt, instead of implementing from scratch in OpenGL). Released in 2005, the miniAudicle immediately became a de facto tool for working with ChucK, and has remained so for many ChucK users to the present day.

See [ChucK publications page](https://chuck.stanford.edu/doc/publish/) and (the historic) https://audicle.cs.princeton.edu/mini/ for more info on the origin of miniAudicle.


_Happy ChucKing!_
