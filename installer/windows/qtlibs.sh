#!/bin/sh

# script that outputs DLLs linked to by miniAudicle, which must be packaged
# alongside miniAudicle

# be sure to run qtenv2.bat from the QT_DIR/bin folder
# as well as vcvarsbat.dll [x64] to set up the environment
# assumes that QT_DIR/bin is on your path

# eg add C:\Qt\Qt6\6.4.1\msvc2019_64\bin 
# and C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\
# to your path, then run 
# qtenv2.bat
# vcvarsall.bat x64

# edit PATHs as appropriate
QT_DIR="/c/Qt/Qt6/6.4.1/msvc2019_64/bin"
VCVARS_DIR="/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Auxiliary/Build"
OUTPUT_DIR=dll

"$QT_DIR"/qtenv2.bat

"$VCVARS_DIR"/vcvarsall.bat x64

$QT_DIR/windeployqt --dir $OUTPUT_DIR \
  --no-translations \
  --no-system-d3d-compiler \
  --no-virtualkeyboard \
  --no-opengl-sw \
  miniAudicle.exe
