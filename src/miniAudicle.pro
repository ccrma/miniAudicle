#-------------------------------------------------
#
# Project created by QtCreator 2011-11-21T18:38:04
#
#-------------------------------------------------

QT       += core gui network

CONFIG += warn_off

win32 {
    CONFIG += static
}

TARGET = miniAudicle
TEMPLATE = app

MAKEFILE = makefile.qt
MOC_DIR = build
RCC_DIR = build
UI_DIR = build
OBJECTS_DIR = build

PRECOMPILED_HEADER = qt/miniAudicle_pc.h

LIBS += -lqscintilla2

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

CFLAGS += -D__CK_SNDFILE_NATIVE__ -D__LINUX__ -D__PLATFORM_LINUX__ -Ichuck/src -DHAVE_CONFIG_H
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
CFLAGS = -D__PLATFORM_WIN32__ -D__WINDOWS_DS__ -I../src -I../src/chuck/src -DWIN32 -D_WINDOWS
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LFLAGS += wsock32.lib dinput.lib kernel32.lib user32.lib gdi32.lib dsound.lib dxguid.lib winmm.lib ole32.lib

RC_FILE = qt/icon/miniAudicle.rc
}

SOURCES += \
    qt/mAMainWindow.cpp \
    qt/main.cpp \
    chuck/src/util_xforms.c \
    chuck/src/util_thread.cpp \
    chuck/src/util_string.cpp \
    chuck/src/util_raw.c \
    chuck/src/util_opsc.cpp \
    chuck/src/util_network.c \
    chuck/src/util_math.c \
    chuck/src/util_hid.cpp \
    chuck/src/util_console.cpp \
    chuck/src/util_buffers.cpp \
    chuck/src/ulib_std.cpp \
    chuck/src/ulib_opsc.cpp \
    chuck/src/ulib_math.cpp \
    chuck/src/ulib_machine.cpp \
    chuck/src/ulib_regex.cpp \
    chuck/src/ugen_xxx.cpp \
    chuck/src/ugen_stk.cpp \
    chuck/src/ugen_osc.cpp \
    chuck/src/ugen_filter.cpp \
    chuck/src/uana_xform.cpp \
    chuck/src/uana_extract.cpp \
    chuck/src/rtmidi.cpp \
    chuck/src/midiio_rtmidi.cpp \
    chuck/src/hidio_sdl.cpp \
    chuck/src/digiio_rtaudio.cpp \
    chuck/src/chuck_vm.cpp \
    chuck/src/chuck_utils.cpp \
    chuck/src/chuck_ugen.cpp \
    chuck/src/chuck_type.cpp \
    chuck/src/chuck_table.cpp \
    chuck/src/chuck_symbol.cpp \
    chuck/src/chuck_stats.cpp \
    chuck/src/chuck_shell.cpp \
    chuck/src/chuck_scan.cpp \
    chuck/src/chuck_parse.cpp \
    chuck/src/chuck_otf.cpp \
    chuck/src/chuck_oo.cpp \
    chuck/src/chuck_lang.cpp \
    chuck/src/chuck_instr.cpp \
    chuck/src/chuck_globals.cpp \
    chuck/src/chuck_frame.cpp \
    chuck/src/chuck_errmsg.cpp \
    chuck/src/chuck_emit.cpp \
    chuck/src/chuck_dl.cpp \
    chuck/src/chuck_console.cpp \
    chuck/src/chuck_compile.cpp \
    chuck/src/chuck_bbq.cpp \
    chuck/src/chuck_absyn.cpp \
    chuck/src/RtAudio/RtAudio.cpp \
    chuck/src/lo/address.c \
    chuck/src/lo/blob.c \
    chuck/src/lo/bundle.c \
    chuck/src/lo/message.c \
    chuck/src/lo/method.c \
    chuck/src/lo/pattern_match.c \
    chuck/src/lo/send.c \
    chuck/src/lo/server.c \
    chuck/src/lo/timetag.c \
    qt/madocumentview.cpp \
    miniAudicle.cpp \
    # miniAudicle_shell.cpp \
    miniAudicle_log.cpp \
    qt/mAConsoleMonitor.cpp \
    qt/mAVMMonitor.cpp \
    chuck/src/util_serial.cpp \
    chuck/src/chuck_io.cpp \
    qt/mAsciLexerChucK.cpp \
    qt/mAPreferencesWindow.cpp \
    qt/mAExportDialog.cpp \
    qt/ZSettings.cpp \
    qt/mASocketManager.cpp \ 
    qt/mADeviceBrowser.cpp
!linux-g++ {
    SOURCES += chuck/src/util_sndfile.c
}

win32 {
    SOURCES += chuck/src/chuck_win32.c
    SOURCES += chuck/src/regex/regcomp.c \
    chuck/src/regex/regerror.c \
    chuck/src/regex/regexec.c \
    chuck/src/regex/tre-ast.c \
    chuck/src/regex/tre-compile.c \
    chuck/src/regex/tre-filter.c \
    chuck/src/regex/tre-match-approx.c \
    chuck/src/regex/tre-match-backtrack.c \
    chuck/src/regex/tre-match-parallel.c \
    chuck/src/regex/tre-mem.c \
    chuck/src/regex/tre-parse.c \
    chuck/src/regex/tre-stack.c \
    chuck/src/regex/xmalloc.c

    INCLUDEPATH += chuck/src/regex/
}

HEADERS  += qt/mAMainWindow.h \
    chuck/src/util_xforms.h \
    chuck/src/util_thread.h \
    chuck/src/util_string.h \
    chuck/src/util_sndfile.h \
    chuck/src/util_raw.h \
    chuck/src/util_opsc.h \
    chuck/src/util_network.h \
    chuck/src/util_math.h \
    chuck/src/util_hid.h \
    chuck/src/util_console.h \
    chuck/src/util_buffers.h \
    chuck/src/ulib_std.h \
    chuck/src/ulib_opsc.h \
    chuck/src/ulib_math.h \
    chuck/src/ulib_machine.h \
    chuck/src/ugen_xxx.h \
    chuck/src/ugen_stk.h \
    chuck/src/ugen_osc.h \
    chuck/src/ugen_filter.h \
    chuck/src/uana_xform.h \
    chuck/src/uana_extract.h \
    chuck/src/rtmidi.h \
    chuck/src/midiio_rtmidi.h \
    chuck/src/hidio_sdl.h \
    chuck/src/digiio_rtaudio.h \
    chuck/src/chuck_win32.h \
    chuck/src/chuck_vm.h \
    chuck/src/chuck_utils.h \
    chuck/src/chuck_ugen.h \
    chuck/src/chuck_type.h \
    chuck/src/chuck_table.h \
    chuck/src/chuck_symbol.h \
    chuck/src/chuck_stats.h \
    chuck/src/chuck_shell.h \
    chuck/src/chuck_scan.h \
    chuck/src/chuck_parse.h \
    chuck/src/chuck_otf.h \
    chuck/src/chuck_oo.h \
    chuck/src/chuck_lang.h \
    chuck/src/chuck_instr.h \
    chuck/src/chuck_globals.h \
    chuck/src/chuck_frame.h \
    chuck/src/chuck_errmsg.h \
    chuck/src/chuck_emit.h \
    chuck/src/chuck_dl.h \
    chuck/src/chuck_def.h \
    chuck/src/chuck_console.h \
    chuck/src/chuck_compile.h \
    chuck/src/chuck_bbq.h \
    chuck/src/chuck_absyn.h \
    chuck/src/RtAudio/RtError.h \
    chuck/src/RtAudio/RtAudio.h \
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
    chuck/src/util_serial.h \
    chuck/src/chuck_io.h \
    qt/mAsciLexerChucK.h \
    qt/mAPreferencesWindow.h \
    qt/mAExportDialog.h \
    qt/ZSettings.h \
    qt/mASocketManager.h \
    version.h \
    chuck/src/lo/lo_types_internal.h \
    chuck/src/lo/lo_types.h \
    chuck/src/lo/lo_throw.h \
    chuck/src/lo/lo_osc_types.h \
    chuck/src/lo/lo_macros.h \
    chuck/src/lo/lo_lowlevel.h \
    chuck/src/lo/lo_internal.h \
    chuck/src/lo/lo_errors.h \
    chuck/src/lo/lo_endian.h \
    chuck/src/lo/lo.h \
    chuck/src/lo/config.h \ 
    qt/mADeviceBrowser.h

FORMS += \
    qt/mAMainWindow.ui \
    qt/madocumentview.ui \
    qt/mAConsoleMonitor.ui \
    qt/mAVMMonitor.ui \
    qt/mAPreferencesWindow.ui \
    qt/mAExportDialog.ui \
    qt/mADeviceBrowser.ui

!win32 {
FLEXSOURCES = chuck/src/chuck.lex
BISONSOURCES = chuck/src/chuck.y
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

!win32 {
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

