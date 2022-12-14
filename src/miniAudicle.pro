#-------------------------------------------------
#
# Project created by QtCreator 2011-11-21T18:38:04
#
#-------------------------------------------------

QT += core gui network widgets

CONFIG += warn_off static

TARGET = miniAudicle
TEMPLATE = app

MAKEFILE = makefile.qt

PRECOMPILED_HEADER = qt/miniAudicle_pc.h

LIBS += -lqscintilla2_qt6

DEFINES += HAVE_CONFIG_H

macx {
CFLAGS = -D__MACOSX_CORE__ -m32 -I../src/chuck/src
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LIBS += -framework Cocoa -framework CoreAudio -framework CoreMIDI \
    -framework CoreFoundation -framework Carbon -framework IOKit -lstdc++ -lm \
    -F/System/Library/PrivateFrameworks -weak_framework MultitouchSupport
QMAKE_LFLAGS += -m32
}


linux-* {

# use ALSA as default backend if no backend is specified
!contains(RTAUDIO_BACKEND,JACK){
    !contains(RTAUDIO_BACKEND,ALSA){
        !contains(RTAUDIO_BACKEND,PULSE){
            message("No audio backend specified; enabling PulseAudio mode")
        }
        else {
            CFLAGS += -D__LINUX_PULSE__
            LIBS += -lpulse-simple -lpulse 
        }
    }
    else {
        CFLAGS += -D__LINUX_ALSA__
    }
} else {
    CFLAGS += -D__LINUX_JACK__ -D__UNIX_JACK__
    LIBS += -ljack
}

QMAKE_CXXFLAGS_RELEASE -= -O2
QMAKE_CXXFLAGS_RELEASE += -O3
QMAKE_CFLAGS_RELEASE -= -O2
QMAKE_CFLAGS_RELEASE += -O3
QMAKE_LFLAGS_RELEASE -= -O1

CFLAGS += -D__CK_SNDFILE_NATIVE__ -D__CHUCK_NO_MAIN__ -D__LINUX__ -D__PLATFORM_LINUX__ -Ichuck/src/core -Ichuck/src/host -DHAVE_CONFIG_H
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LFLAGS +=
LIBS += -lasound -lstdc++ -lm -lsndfile -ldl

target.path = /usr/local/bin

examples.path = /usr/local/share/doc/chuck/examples/
examples.files = chuck/src/examples/*

INSTALLS += target examples
}


win32 {
DEFINES -= UNICODE
# 2022 QTSIN
DEFINES -= _UNICODE
CFLAGS = -D__PLATFORM_WIN32__ -D__WINDOWS_MODERN__ -D__CHUCK_NO_MAIN__ -D__WINDOWS_DS__ -D_WINSOCKAPI_ -I../src -I../src/chuck/src/core -I../src/chuck/src/host -DWIN32 -D_WINDOWS -D__CK_MATH_DEFINE_ROUND_TRUNC__
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LFLAGS += /libpath:../src/qt/lib ws2_32.lib dinput8.lib advapi32.lib kernel32.lib user32.lib gdi32.lib dsound.lib dxguid.lib winmm.lib ole32.lib qscintilla2_qt6.lib

RC_FILE = qt/icon/miniAudicle.rc
}

SOURCES += \
    qt/mAMainWindow.cpp \
    qt/main.cpp \
    chuck/src/host/chuck_audio.cpp \
    chuck/src/host/chuck_console.cpp \
    chuck/src/host/chuck_main.cpp \
    chuck/src/host/RtAudio/RtAudio.cpp \
    chuck/src/core/chuck_carrier.cpp \
    chuck/src/core/util_xforms.c \
    chuck/src/core/util_thread.cpp \
    chuck/src/core/util_string.cpp \
    chuck/src/core/util_raw.c \
    chuck/src/core/util_opsc.cpp \
    chuck/src/core/util_network.c \
    chuck/src/core/util_math.c \
    chuck/src/core/util_hid.cpp \
    chuck/src/core/util_console.cpp \
    chuck/src/core/util_buffers.cpp \
    chuck/src/core/ulib_std.cpp \
    chuck/src/core/ulib_opsc.cpp \
    chuck/src/core/ulib_math.cpp \
    chuck/src/core/ulib_machine.cpp \
    chuck/src/core/ulib_regex.cpp \
    chuck/src/core/ugen_xxx.cpp \
    chuck/src/core/ugen_stk.cpp \
    chuck/src/core/ugen_osc.cpp \
    chuck/src/core/ugen_filter.cpp \
    chuck/src/core/uana_xform.cpp \
    chuck/src/core/uana_extract.cpp \
    chuck/src/core/rtmidi.cpp \
    chuck/src/core/midiio_rtmidi.cpp \
    chuck/src/core/hidio_sdl.cpp \
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
    chuck/src/core/chuck_instr.cpp \
    chuck/src/core/chuck_frame.cpp \
    chuck/src/core/chuck_errmsg.cpp \
    chuck/src/core/chuck_emit.cpp \
    chuck/src/core/chuck_dl.cpp \
    chuck/src/core/chuck_compile.cpp \
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
    qt/madocumentview.cpp \
    miniAudicle.cpp \
    # miniAudicle_shell.cpp \
    miniAudicle_log.cpp \
    qt/mAConsoleMonitor.cpp \
    qt/mAVMMonitor.cpp \
    chuck/src/core/util_serial.cpp \
    chuck/src/core/chuck_io.cpp \
    qt/mAsciLexerChucK.cpp \
    qt/mAPreferencesWindow.cpp \
    qt/mAExportDialog.cpp \
    qt/ZSettings.cpp \
    qt/mASocketManager.cpp \ 
    qt/mADeviceBrowser.cpp \
    chuck/src/core/chuck.cpp \
    chuck/src/core/chuck_globals.cpp \
    chuck/src/core/util_platforms.cpp
!linux-g++ {
    SOURCES += chuck/src/core/util_sndfile.c
}

win32 {
    SOURCES += chuck/src/core/chuck_win32.c
    SOURCES += chuck/src/core/regex/regcomp.c \
    chuck/src/core/regex/regerror.c \
    chuck/src/core/regex/regexec.c \
    chuck/src/core/regex/tre-ast.c \
    chuck/src/core/regex/tre-compile.c \
    chuck/src/core/regex/tre-filter.c \
    chuck/src/core/regex/tre-match-approx.c \
    chuck/src/core/regex/tre-match-backtrack.c \
    chuck/src/core/regex/tre-match-parallel.c \
    chuck/src/core/regex/tre-mem.c \
    chuck/src/core/regex/tre-parse.c \
    chuck/src/core/regex/tre-stack.c \
    chuck/src/core/regex/xmalloc.c

    INCLUDEPATH += chuck/src/core/regex/
}

HEADERS  += qt/mAMainWindow.h \
    chuck/src/host/chuck_audio.h \
    chuck/src/host/chuck_console.h \
    chuck/src/host/RtAudio/RtError.h \
    chuck/src/host/RtAudio/RtAudio.h \
    chuck/src/core/chuck_carrier.h \
    chuck/src/core/util_xforms.h \
    chuck/src/core/util_thread.h \
    chuck/src/core/util_string.h \
    chuck/src/core/util_sndfile.h \
    chuck/src/core/util_raw.h \
    chuck/src/core/util_opsc.h \
    chuck/src/core/util_network.h \
    chuck/src/core/util_math.h \
    chuck/src/core/util_hid.h \
    chuck/src/core/util_console.h \
    chuck/src/core/util_buffers.h \
    chuck/src/core/ulib_std.h \
    chuck/src/core/ulib_opsc.h \
    chuck/src/core/ulib_math.h \
    chuck/src/core/ulib_machine.h \
    chuck/src/core/ugen_xxx.h \
    chuck/src/core/ugen_stk.h \
    chuck/src/core/ugen_osc.h \
    chuck/src/core/ugen_filter.h \
    chuck/src/core/uana_xform.h \
    chuck/src/core/uana_extract.h \
    chuck/src/core/rtmidi.h \
    chuck/src/core/midiio_rtmidi.h \
    chuck/src/core/hidio_sdl.h \
    chuck/src/core/chuck_win32.h \
    chuck/src/core/chuck_vm.h \
    chuck/src/core/chuck_utils.h \
    chuck/src/core/chuck_ugen.h \
    chuck/src/core/chuck_type.h \
    chuck/src/core/chuck_table.h \
    chuck/src/core/chuck_symbol.h \
    chuck/src/core/chuck_stats.h \
    chuck/src/core/chuck_shell.h \
    chuck/src/core/chuck_scan.h \
    chuck/src/core/chuck_parse.h \
    chuck/src/core/chuck_otf.h \
    chuck/src/core/chuck_oo.h \
    chuck/src/core/chuck_lang.h \
    chuck/src/core/chuck_instr.h \
    chuck/src/core/chuck_frame.h \
    chuck/src/core/chuck_errmsg.h \
    chuck/src/core/chuck_emit.h \
    chuck/src/core/chuck_dl.h \
    chuck/src/core/chuck_def.h \
    chuck/src/core/chuck_compile.h \
    chuck/src/core/chuck_absyn.h \
    chuck/src/core/util_serial.h \
    chuck/src/core/chuck_io.h \
    qt/madocumentview.h \
    qt/miniAudicle_pc.h \
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
    qt/ZSettings.h \
    qt/mASocketManager.h \
    version.h \
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
    qt/mADeviceBrowser.h \
    chuck/src/core/chuck.h

FORMS += \
    qt/mAMainWindow.ui \
    qt/madocumentview.ui \
    qt/mAConsoleMonitor.ui \
    qt/mAVMMonitor.ui \
    qt/mAPreferencesWindow.ui \
    qt/mAExportDialog.ui \
    qt/mADeviceBrowser.ui

!win32 {
FLEXSOURCES = chuck/src/core/chuck.lex
BISONSOURCES = chuck/src/core/chuck.y
}

flex.commands = flex -o $$OBJECTS_DIR/${QMAKE_FILE_BASE}.yy.c ${QMAKE_FILE_IN}
flex.input = FLEXSOURCES
flex.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}.yy.c
flex.variable_out = SOURCES
flex.depends = $$OBJECTS_DIR/${QMAKE_FILE_BASE}.tab.h
flex.name = flex
QMAKE_EXTRA_COMPILERS += flex

bison.commands = bison -dv -b $$OBJECTS_DIR/${QMAKE_FILE_BASE} ${QMAKE_FILE_IN}
bison.input = BISONSOURCES
bison.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}.tab.c
bison.variable_out = SOURCES
bison.name = bison
QMAKE_EXTRA_COMPILERS += bison

bisonheader.commands = @true
bisonheader.input = BISONSOURCES
bisonheader.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}.tab.h
bisonheader.variable_out = HEADERS
bisonheader.name = bison header
bisonheader.depends = $$OBJECTS_DIR/${QMAKE_FILE_BASE}.tab.c
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

