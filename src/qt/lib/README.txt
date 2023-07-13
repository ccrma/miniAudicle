The Qt build of miniAudicle is configured to link against the QScintilla
library.

Linux:
---
qscintilla for Qt6 is an package for many distributions; see build
instructions for more details here:

  https://github.com/ccrma/miniAudicle#readme

All platforms:
---
If you are building your own qscintilla library from source, the
library files could go here.

These library files can be either compiled from source or downloaded as
pre-compiled library files. The latest builds of the above can be found
here for Windows and macOS-qt, as prepared by the ChucK Team:

  https://chuck.stanford.edu/release/files/extra/qscintilla2_qt6.zip
    OR
  https://drive.google.com/drive/folders/1VC9vi5NaC9LvTt7GtacjiOpF34txjwoT

Instructions are included within the ZIP file. Also package is the
qscintilla source and modified Qt6 .pro file used to build the libraries.

Windows:
---
static libraries
  qscintilla2_qt6.lib (release library)
  qscintilla2_qt6d.lib (debug library)
  qscintilla2_qt6d.pdb (debug symbols)
dynamic libraries:
  qscintilla2_qt6.lib (release library)
  qscintilla2_qt6.dll (release DLL)
  qscintilla2_qt6d.lib (debug library)
  qscintilla2_qt6d.dll (debug DLL)
  qscintilla2_qt6d.pdb (debug symbols)

MacOS (Qt edition):
---
static libraries
  libqscintilla2d_qt6.a (debug library)
  libqscintilla2_qt6.a (release library)
dynamic libraries
  qscintilla2_qt6.framework
