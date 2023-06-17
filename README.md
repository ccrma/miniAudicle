# miniAudicle
<img src="https://chuck.stanford.edu/doc/images/miniAudicle-1.jpg" width="720"/>

## IDE for ChucK
**miniAudicle** is an integrated development environment (IDE) for the **ChucK** music programming language. It provides graphical user interfaces for code editing, on-the-fly proramming commands (`add`, `replace`, `remove`), visualization of ChucK virtual machines shreds, and tools for probing and setting audio and HID devices. miniAudicle integrates these front-end features with a full ChucK virtual machine and synthesis engine running internally within miniAudicle.

## Installing miniAudicle
To download and install **miniAudicle** and command-line **chuck**, visit https://chuck.stanford.edu/release/

miniAudicle submodules: [ChucK](https://github.com/ccrma/chuck) | [Chugins](https://github.com/ccrma/chugins)

## Building miniAudicle
To build the latest miniAudicle from source, clone the `miniAudicle` repo from github:
```
git clone --recurse-submodules https://github.com/ccrma/miniAudicle.git
```

### macOS (Cocoa)
By default, miniAudicle on macOS uses **Cocoa** for its windowing and graphical user interface.

navigate to the `miniAudicle/src` directory, and run `make`:
```
cd miniAudicle/src
make mac
```
OR to build a universal binary (intel + apple sillicon):
```
make mac-ub
```

### macOS (Qt)
Alternately, it is also possible to build the Qt version of the miniAudicle. This requires [**Qt6**](https://www.qt.io/download-open-source) (we recommend Qt-6.5.0 or higher) and the QScintilla library. These are several ways to build miniAudicle with Qt. One way is to use the `Qt Creator` IDE to open `miniAudicle/src/miniAudicle.pro`; another is to use `qmake` directly and build from the command line.

QScintilla can be built from [source](https://riverbankcomputing.com/software/qscintilla/download) using `Qt Creator` or `qmake`. Alternately, you can use our [pre-built `qscintilla_qt6` libraries](https://chuck.stanford.edu/release/files/extra/qscintilla2_qt6.zip).

### Linux
Dependencies: miniAudicle on Linux requires `Qt6` and `qscintilla-qt6` development packages to be installed.

navigate to the `miniAudicle/src` directory, and run `make`:
```
cd miniAudicle/src
make linux
```

This should build a `miniAudicle` executable support Pulse, ALSA, and Jack.

### Windows
miniAudicle on Windows requires [**Qt6**](https://www.qt.io/download-open-source) (we recommend Qt-6.5.0 or higher) and the [QScintilla](https://riverbankcomputing.com/software/qscintilla/download) library. In the `Qt Creator` IDE, open `miniAudicle/src/miniAudicle.pro` and build.

## miniAudicle History
**miniAudicle** was created by Spencer Salazar in 2005, two years after the initial release of the ChucK programming language, originated by Ge Wang and Perry R. Cook, and one year after the creation of the **the Audicle** (see [2004 paper](https://ccrma.stanford.edu/~ge/publish/files/2004-icmc-audicle.pdf)). The original Audicle was designed as a 3D graphics-based IDE for live-coding ChucK programs while visualizing these programs' deep structure. Perry Cook had suggested the name 'audicle' could be the all-_hearing_ equivalent of an all-_seeing_ "oracle". While the Audicle demonstrated potential, it's 3D-graphics intensive backend (in OpenGL) was extremely to develop into an usable tool. This gave rise to the _miniAudicle_, which was to be a lighter version of the Audicle, using establish windowing and GUI toolkits (like Cocoa and Qt, instead of implementing from scratch in OpenGL). Released in 2005, the miniAudicle immediately became a de facto tool for working with ChucK, and has remained so for many ChucK users to the present day.

See [ChucK publications page](https://chuck.stanford.edu/doc/publish/) and (the historic) https://audicle.cs.princeton.edu/mini/ for more info on the origin of miniAudicle.
