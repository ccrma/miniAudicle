#-------------------------------------------------
# Project created by QtCreator 2011-11-21T18:38:04
#-------------------------------------------------
# miniAudicle:
# IDE for ChucK audio programming language
#-------------------------------------------------

#-------------------------------------------------
# some useful references | 1.5.0.1 added
# https://doc.qt.io/qt-6/qmake-environment-reference.html
# https://doc.qt.io/qt-6/qmake-variable-reference.html
# https://forum.qt.io/topic/65778/qmake-and-qt-installation-root-directory/2
#-------------------------------------------------
# NOTE: build command will output 'message' to the compile output;
# this is a way to debug .pro files; e.g., uncomment these two lines:
# message(Qt installed headers location: $$[QT_INSTALL_HEADERS])
# message(Qt installed libs location: $$[QT_INSTALL_LIBS])
#-------------------------------------------------

# build target
TARGET = miniAudicle

# build as application
TEMPLATE = app

# Qt modules
QT += core gui network widgets

# c++ language dialect
CONFIG += c++11
CONFIG += warn_off
MAKEFILE = makefile.qt
PRECOMPILED_HEADER = qt/miniAudicle_pc.h

# miniAudicle enable color console
DEFINES += __MA_COLOR_CONSOLE__
# for liblo
DEFINES += HAVE_CONFIG_H

# (unix systems) where to put intermediate/generated files
unix:BUILD_DIR = qt-build
unix:OBJECTS_DIR = qt-build
unix:MOC_DIR = qt-build
unix:UI_DIR = qt-build
unix:RCC_DIR = qt-build

# add the qt source directory to include path; generated ui_* file may include headers
QMAKE_CXXFLAGS += -I$$shell_path($$_PRO_FILE_PWD_)/qt
QMAKE_CFLAGS += -I$$shell_path($$_PRO_FILE_PWD_)/qt


#-------------------------------------------------
# macOS build configurations
#-------------------------------------------------
macx {
# specific architecture(s); use x86_64 and arm64 for universal binary
QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64

# set application bundle identifier prefix
QMAKE_TARGET_BUNDLE_PREFIX = edu.stanford.chuck
# set application bundle identifier name
QMAKE_BUNDLE = miniAudicle

# #defines
CFLAGS += -D__MACOSX_CORE__
# header paths; assumes Qsci/ in $$[QT_INSTALL_HEADERS]
CFLAGS += -I../src/chuck/src -I../src -I../src/chuck/src/core  -I../src/chuck/src/host

# qmake compiler flags
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS

# qmake library flags
QMAKE_LFLAGS +=
# qmake libraries and frameworks to link against
QMAKE_LIBS += -framework Cocoa -framework CoreAudio -framework CoreMIDI \
    -framework CoreFoundation -framework Carbon -framework IOKit -lstdc++ -lm \
    -F/System/Library/PrivateFrameworks -weak_framework MultitouchSupport

# controls whether to link against dynamic or static qscintilla
# (comment out this next line for dynamic linking / shared libs)
QSCINTILLA_LINKING = static

# check linking preference
equals( QSCINTILLA_LINKING, "static" ) { # use static linking
    # provide header search path for Qsci/ headers
    QMAKE_CXXFLAGS += -I$$[QT_INSTALL_HEADERS]
    # expect qscintilla2_qt6(d).a in src/qt/lib/
    QMAKE_LFLAGS += -L$${_PRO_FILE_PWD_}/qt/lib
    # which version of the library: debug or release
    CONFIG(debug, debug|release) { QMAKE_LIBS += -lqscintilla2_qt6d }
    else { QMAKE_LIBS += -lqscintilla2_qt6 }
} else {  # use framework (dynamic linking)
    # include path for the headers in the framework
    QMAKE_CXXFLAGS += -I$$[QT_INSTALL_LIBS]/qscintilla2_qt6.framework/Headers/
    # expect qscintilla2_qt6.framework in $$[QT_INSTALL_LIBS]
    QMAKE_LFLAGS += -F$$[QT_INSTALL_LIBS]
    # link against the framework
    QMAKE_LIBS += -framework qscintilla2_qt6
}

# icon
ICON = qt/icon/miniAudicle.ico
}


#-------------------------------------------------
# linux build configurations
#-------------------------------------------------
linux-* {
# for non-system/self-compiled version of QScintilla, comment out / modify following lines as appropriate
# QSCI_PATH = qt/qscintilla2_qt6/src/QScintilla_src-2.14.0
# CFLAGS += -I$$QSCI_PATH/src/
# LDFLAGS += -L$$QSCI_PATH/src/

contains(RTAUDIO_BACKEND,PULSE){
    message(compiling for PulseAudio)
    CFLAGS += -D__LINUX_PULSE__
    LIBS += -lpulse-simple -lpulse 
}

contains(RTAUDIO_BACKEND,ALSA){
    message(compiling for ALSA)
    CFLAGS += -D__LINUX_ALSA__
}

contains(RTAUDIO_BACKEND,JACK){
    message(compiling for JACK)
    CFLAGS += -D__LINUX_JACK__ -D__UNIX_JACK__
    LIBS += -ljack
}

# adjust flags
QMAKE_CXXFLAGS_RELEASE -= -O2
QMAKE_CXXFLAGS_RELEASE += -O3
QMAKE_CFLAGS_RELEASE -= -O2
QMAKE_CFLAGS_RELEASE += -O3
QMAKE_LFLAGS_RELEASE -= -O1

# defines
CFLAGS += -D__CK_SNDFILE_NATIVE__
# include paths
CFLAGS += -Ichuck/src/core -Ichuck/src/host

# qmake flags
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LFLAGS += $$LDFLAGS
LIBS += -lasound -lstdc++ -lm -lsndfile -ldl -lqscintilla2_qt6

target.path = /usr/local/bin
examples.path = /usr/local/share/doc/chuck/examples/
examples.files = chuck/src/examples/*

INSTALLS += target examples
}


#-------------------------------------------------
# windows build configurations
#-------------------------------------------------
win32 {
# 2022 QTSIN
DEFINES -= UNICODE
DEFINES -= _UNICODE

# defines
CFLAGS += -D__WINDOWS_DS__ -D__WINDOWS_WASAPI__ -D__WINDOWS_ASIO__ -D_WINSOCKAPI_
# include paths
CFLAGS += -I../src -I../src/chuck/src/core -I../src/chuck/src/host -I../src/chuck/src/host/RtAudio/include

# qmake flags
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LFLAGS += /libpath:../src/qt/lib ws2_32.lib dinput8.lib advapi32.lib kernel32.lib user32.lib gdi32.lib dsound.lib dxguid.lib winmm.lib ole32.lib

# link different
Debug {
    QMAKE_LFLAGS += qscintilla2_qt6d.lib
}

Release {
    QMAKE_LFLAGS += qscintilla2_qt6.lib
}

# resources
RC_FILE = qt/icon/miniAudicle.rc

# for windows add ASIO source
SOURCES += \
chuck/src/host/RtAudio/include/asio.cpp \
chuck/src/host/RtAudio/include/asiodrivers.cpp \
chuck/src/host/RtAudio/include/asiolist.cpp \
chuck/src/host/RtAudio/include/iasiothiscallresolver.cpp
}


#-------------------------------------------------
# source files to compile
#-------------------------------------------------
SOURCES += \
    miniAudicle.cpp \
    miniAudicle_log.cpp \
    util_rterror.cpp \
    chuck/src/core/util_xforms.c \
    chuck/src/core/util_thread.cpp \
    chuck/src/core/util_string.cpp \
    chuck/src/core/util_serial.cpp \
    chuck/src/core/util_raw.c \
    chuck/src/core/util_platforms.cpp \
    chuck/src/core/util_opsc.cpp \
    chuck/src/core/util_network.c \
    chuck/src/core/util_math.cpp \
    chuck/src/core/util_hid.cpp \
    chuck/src/core/util_console.cpp \
    chuck/src/core/util_buffers.cpp \
    chuck/src/core/ulib_std.cpp \
    chuck/src/core/ulib_opsc.cpp \
    chuck/src/core/ulib_math.cpp \
    chuck/src/core/ulib_machine.cpp \
    chuck/src/core/ulib_doc.cpp \
    chuck/src/core/ulib_ai.cpp \
    chuck/src/core/ugen_xxx.cpp \
    chuck/src/core/ugen_stk.cpp \
    chuck/src/core/ugen_osc.cpp \
    chuck/src/core/ugen_filter.cpp \
    chuck/src/core/uana_xform.cpp \
    chuck/src/core/uana_extract.cpp \
    chuck/src/core/rtmidi.cpp \
    chuck/src/core/midiio_rtmidi.cpp \
    chuck/src/core/hidio_sdl.cpp \
    chuck/src/core/chuck.cpp \
    chuck/src/core/chuck_vm.cpp \
    chuck/src/core/chuck_utils.cpp \
    chuck/src/core/chuck_ugen.cpp \
    chuck/src/core/chuck_type.cpp \
    chuck/src/core/chuck_table.cpp \
    chuck/src/core/chuck_symbol.cpp \
    chuck/src/core/chuck_stats.cpp \
    chuck/src/core/chuck_shell.cpp \
    chuck/src/core/chuck_scan.cpp \
    chuck/src/core/chuck_parse.cpp \
    chuck/src/core/chuck_otf.cpp \
    chuck/src/core/chuck_oo.cpp \
    chuck/src/core/chuck_lang.cpp \
    chuck/src/core/chuck_globals.cpp \
    chuck/src/core/chuck_instr.cpp \
    chuck/src/core/chuck_io.cpp \
    chuck/src/core/chuck_frame.cpp \
    chuck/src/core/chuck_errmsg.cpp \
    chuck/src/core/chuck_emit.cpp \
    chuck/src/core/chuck_dl.cpp \
    chuck/src/core/chuck_compile.cpp \
    chuck/src/core/chuck_carrier.cpp \
    chuck/src/core/chuck_absyn.cpp \
    chuck/src/core/lo/address.c \
    chuck/src/core/lo/blob.c \
    chuck/src/core/lo/bundle.c \
    chuck/src/core/lo/message.c \
    chuck/src/core/lo/method.c \
    chuck/src/core/lo/pattern_match.c \
    chuck/src/core/lo/send.c \
    chuck/src/core/lo/server.c \
    chuck/src/core/lo/timetag.c \
    chuck/src/host/chuck_audio.cpp \
    chuck/src/host/chuck_console.cpp \
    chuck/src/host/RtAudio/RtAudio.cpp \
    qt/ZSettings.cpp \
    qt/mAMainWindow.cpp \
    qt/madocumentview.cpp \
    qt/mAConsoleMonitor.cpp \
    qt/mAVMMonitor.cpp \
    qt/mAsciLexerChucK.cpp \
    qt/mAPreferencesWindow.cpp \
    qt/mAExportDialog.cpp \
    qt/mASocketManager.cpp \ 
    qt/mADeviceBrowser.cpp \
    qt/main.cpp


# everything except on linux...
!linux-g++ {
    SOURCES += chuck/src/core/util_sndfile.c
}

# only on windows
win32 {
    SOURCES += chuck/src/core/chuck_yacc.c
    INCLUDEPATH +=
}


#-------------------------------------------------
# header files
#-------------------------------------------------
HEADERS  += qt/mAMainWindow.h \
    miniAudicle.h \
    miniAudicle_ui_elements.h \
    miniAudicle_shell.h \
    miniAudicle_log.h \
    miniAudicle_import.h \
    miniAudicle_debug.h \
    qt/mAConsoleMonitor.h \
    qt/mAVMMonitor.h \
    qt/mAsciLexerChucK.h \
    qt/mAPreferencesWindow.h \
    qt/mAExportDialog.h \
    qt/mASocketManager.h \
    qt/madocumentview.h \
    qt/ZSettings.h \
    qt/miniAudicle_pc.h \
    qt/mADeviceBrowser.h \
    util_rterror.h \
    version.h \
    chuck/src/core/chuck.h \
    chuck/src/core/chuck_absyn.h \
    chuck/src/core/chuck_def.h \
    chuck/src/host/chuck_console.h \
    chuck/src/core/chuck_carrier.h \
    chuck/src/core/chuck_compile.h \
    chuck/src/core/chuck_dl.h \
    chuck/src/core/chuck_emit.h \
    chuck/src/core/chuck_errmsg.h \
    chuck/src/core/chuck_frame.h \
    chuck/src/core/chuck_instr.h \
    chuck/src/core/chuck_io.h \
    chuck/src/core/chuck_lang.h \
    chuck/src/core/chuck_oo.h \
    chuck/src/core/chuck_otf.h \
    chuck/src/core/chuck_parse.h \
    chuck/src/core/chuck_scan.h \
    chuck/src/core/chuck_shell.h \
    chuck/src/core/chuck_stats.h \
    chuck/src/core/chuck_table.h \
    chuck/src/core/chuck_symbol.h \
    chuck/src/core/chuck_ugen.h \
    chuck/src/core/chuck_type.h \
    chuck/src/core/chuck_utils.h \
    chuck/src/core/chuck_vm.h \
    chuck/src/core/chuck_yacc.h \
    chuck/src/core/util_xforms.h \
    chuck/src/core/util_thread.h \
    chuck/src/core/util_string.h \
    chuck/src/core/util_sndfile.h \
    chuck/src/core/util_serial.h \
    chuck/src/core/util_raw.h \
    chuck/src/core/util_platforms.h \
    chuck/src/core/util_opsc.h \
    chuck/src/core/util_network.h \
    chuck/src/core/util_math.h \
    chuck/src/core/util_hid.h \
    chuck/src/core/util_console.h \
    chuck/src/core/util_buffers.h \
    chuck/src/core/ulib_doc.h \
    chuck/src/core/ulib_std.h \
    chuck/src/core/ulib_opsc.h \
    chuck/src/core/ulib_math.h \
    chuck/src/core/ulib_machine.h \
    chuck/src/core/ulib_ai.h \
    chuck/src/core/ugen_xxx.h \
    chuck/src/core/ugen_stk.h \
    chuck/src/core/ugen_osc.h \
    chuck/src/core/ugen_filter.h \
    chuck/src/core/uana_xform.h \
    chuck/src/core/uana_extract.h \
    chuck/src/core/rtmidi.h \
    chuck/src/core/midiio_rtmidi.h \
    chuck/src/core/hidio_sdl.h \
    chuck/src/core/lo/lo_types_internal.h \
    chuck/src/core/lo/lo_types.h \
    chuck/src/core/lo/lo_throw.h \
    chuck/src/core/lo/lo_osc_types.h \
    chuck/src/core/lo/lo_macros.h \
    chuck/src/core/lo/lo_lowlevel.h \
    chuck/src/core/lo/lo_internal.h \
    chuck/src/core/lo/lo_errors.h \
    chuck/src/core/lo/lo_endian.h \
    chuck/src/core/lo/lo.h \
    chuck/src/core/lo/config.h \ 
    chuck/src/host/RtAudio/include/asio.h \
    chuck/src/host/RtAudio/include/asiodrivers.h \
    chuck/src/host/RtAudio/include/asiodrvr.h \
    chuck/src/host/RtAudio/include/asiolist.h \
    chuck/src/host/RtAudio/include/asiosys.h \
    chuck/src/host/RtAudio/include/dsound.h \
    chuck/src/host/RtAudio/include/functiondiscoverykeys_devpkey.h \
    chuck/src/host/RtAudio/include/ginclude.h \
    chuck/src/host/RtAudio/include/iasiodrv.h \
    chuck/src/host/RtAudio/include/iasiothiscallresolver.h \
    chuck/src/host/RtAudio/include/soundcard.h \
    chuck/src/host/RtAudio/RtAudio.h \
    chuck/src/host/chuck_audio.h


#-------------------------------------------------
# ui
#-------------------------------------------------
FORMS += \
    qt/mAMainWindow.ui \
    qt/madocumentview.ui \
    qt/mAConsoleMonitor.ui \
    qt/mAVMMonitor.ui \
    qt/mAPreferencesWindow.ui \
    qt/mAExportDialog.ui \
    qt/mADeviceBrowser.ui

# everywhere except windows
!win32 {
FLEXSOURCES = chuck/src/core/chuck.lex
BISONSOURCES = chuck/src/core/chuck.y
}

flex.commands = flex -o ${QMAKE_FILE_BASE}.yy.c ${QMAKE_FILE_IN}
flex.input = FLEXSOURCES
flex.output = ${QMAKE_FILE_BASE}.yy.c
flex.variable_out = SOURCES
flex.depends = ${QMAKE_FILE_BASE}.tab.h
flex.name = flex
QMAKE_EXTRA_COMPILERS += flex

bison.commands = bison -dv -b ${QMAKE_FILE_BASE} ${QMAKE_FILE_IN}
bison.input = BISONSOURCES
bison.output = ${QMAKE_FILE_BASE}.tab.c
bison.variable_out = SOURCES
bison.name = bison
QMAKE_EXTRA_COMPILERS += bison

bisonheader.commands = @true
bisonheader.input = BISONSOURCES
bisonheader.output = ${QMAKE_FILE_BASE}.tab.h
bisonheader.variable_out = HEADERS
bisonheader.name = bison header
bisonheader.depends = ${QMAKE_FILE_BASE}.tab.c
QMAKE_EXTRA_COMPILERS += bisonheader

!win32:system(git rev-parse 2> /dev/null) {
gitrev.commands = echo \\$${LITERAL_HASH}define GIT_REVISION $$quote(\\\")`git rev-parse --short HEAD`$$quote(\\\") > .git-rev-tmp;\
    cmp -s .git-rev-tmp git-rev.h || cp .git-rev-tmp git-rev.h;\
    rm .git-rev-tmp
gitrev.target = git-rev.h
gitrev.depends = gitrev_FORCE
gitrev.CONFIG += recursive
QMAKE_EXTRA_TARGETS += gitrev

gitrev_FORCE.commands = 
gitrev_FORCE.CONFIG += recursive
QMAKE_EXTRA_TARGETS += gitrev_FORCE
}

RESOURCES += \
    qt/miniAudicle.qrc

OTHER_FILES += \
    qt/icon/miniAudicle.png \
    qt/icon/remove.png \
    qt/icon/add.png \
    qt/icon/replace.png \
    qt/icon/removelast.png \
    qt/icon/removeall.png \
    qt/icon/miniAudicle.rc

DISTFILES += \
    chuck/src/host/RtAudio/include/asioinfo.txt
