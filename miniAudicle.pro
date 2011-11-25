#-------------------------------------------------
#
# Project created by QtCreator 2011-11-21T18:38:04
#
#-------------------------------------------------

QT       += core gui

CONFIG += warn_off

TARGET = miniAudicle
TEMPLATE = app

MAKEFILE = makefile.qt
MOC_DIR = build
RCC_DIR = build
UI_DIR = build
OBJECTS_DIR = build

macx {
CFLAGS = -D__MACOSX_CORE__ -m32 -O3 -I../qt/chuck
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LIBS += -framework Cocoa -framework CoreAudio -framework CoreMIDI \
    -framework CoreFoundation -framework Carbon -framework IOKit -lstdc++ -lm \
    -F/System/Library/PrivateFrameworks -weak_framework MultitouchSupport
QMAKE_LFLAGS += -m32
}

linux-g++ {
CFLAGS = -D__LINUX_ALSA__ -m32 -O3 -D__CK_SNDFILE_NATIVE__ -D__LINUX__ -Ichuck
QMAKE_CXXFLAGS += $$CFLAGS
QMAKE_CFLAGS += $$CFLAGS
QMAKE_LFLAGS += -m32 -lasound -lpthread -lstdc++ -ldl -lm -lsndfile
}

SOURCES += \
    qt/mAMainWindow.cpp \
    qt/main.cpp \
    chuck/util_xforms.c \
    chuck/util_thread.cpp \
    chuck/util_string.cpp \
    chuck/util_raw.c \
    chuck/util_opsc.cpp \
    chuck/util_network.c \
    chuck/util_math.c \
    chuck/util_hid.cpp \
    chuck/util_console.cpp \
    chuck/util_buffers.cpp \
    chuck/ulib_std.cpp \
    chuck/ulib_opsc.cpp \
    chuck/ulib_math.cpp \
    chuck/ulib_machine.cpp \
    chuck/ugen_xxx.cpp \
    chuck/ugen_stk.cpp \
    chuck/ugen_osc.cpp \
    chuck/ugen_filter.cpp \
    chuck/uana_xform.cpp \
    chuck/uana_extract.cpp \
    chuck/rtmidi.cpp \
    chuck/midiio_rtmidi.cpp \
    chuck/hidio_sdl.cpp \
    chuck/digiio_rtaudio.cpp \
    chuck/chuck_vm.cpp \
    chuck/chuck_utils.cpp \
    chuck/chuck_ugen.cpp \
    chuck/chuck_type.cpp \
    chuck/chuck_table.cpp \
    chuck/chuck_symbol.cpp \
    chuck/chuck_stats.cpp \
    chuck/chuck_shell.cpp \
    chuck/chuck_scan.cpp \
    chuck/chuck_parse.cpp \
    chuck/chuck_otf.cpp \
    chuck/chuck_oo.cpp \
    chuck/chuck_lang.cpp \
    chuck/chuck_instr.cpp \
    chuck/chuck_globals.cpp \
    chuck/chuck_frame.cpp \
    chuck/chuck_errmsg.cpp \
    chuck/chuck_emit.cpp \
    chuck/chuck_dl.cpp \
    chuck/chuck_console.cpp \
    chuck/chuck_compile.cpp \
    chuck/chuck_bbq.cpp \
    chuck/chuck_absyn.cpp \
    chuck/RtAudio/RtAudio.cpp

macx {
    SOURCES += chuck/util_sndfile.c
}

win32 {
    SOURCES += chuck/chuck_win32.c
}

HEADERS  += qt/mAMainWindow.h \
    chuck/util_xforms.h \
    chuck/util_thread.h \
    chuck/util_string.h \
    chuck/util_sndfile.h \
    chuck/util_raw.h \
    chuck/util_opsc.h \
    chuck/util_network.h \
    chuck/util_math.h \
    chuck/util_hid.h \
    chuck/util_console.h \
    chuck/util_buffers.h \
    chuck/ulib_std.h \
    chuck/ulib_opsc.h \
    chuck/ulib_math.h \
    chuck/ulib_machine.h \
    chuck/ugen_xxx.h \
    chuck/ugen_stk.h \
    chuck/ugen_osc.h \
    chuck/ugen_filter.h \
    chuck/uana_xform.h \
    chuck/uana_extract.h \
    chuck/rtmidi.h \
    chuck/midiio_rtmidi.h \
    chuck/hidio_sdl.h \
    chuck/digiio_rtaudio.h \
    chuck/chuck_win32.h \
    chuck/chuck_vm.h \
    chuck/chuck_utils.h \
    chuck/chuck_ugen.h \
    chuck/chuck_type.h \
    chuck/chuck_table.h \
    chuck/chuck_symbol.h \
    chuck/chuck_stats.h \
    chuck/chuck_shell.h \
    chuck/chuck_scan.h \
    chuck/chuck_parse.h \
    chuck/chuck_otf.h \
    chuck/chuck_oo.h \
    chuck/chuck_lang.h \
    chuck/chuck_instr.h \
    chuck/chuck_globals.h \
    chuck/chuck_frame.h \
    chuck/chuck_errmsg.h \
    chuck/chuck_emit.h \
    chuck/chuck_dl.h \
    chuck/chuck_def.h \
    chuck/chuck_console.h \
    chuck/chuck_compile.h \
    chuck/chuck_bbq.h \
    chuck/chuck_absyn.h \
    chuck/RtAudio/RtError.h \
    chuck/RtAudio/RtAudio.h

FORMS += \
    qt/mAMainWindow.ui

FLEXSOURCES = chuck/chuck.lex
BISONSOURCES = chuck/chuck.y

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

RESOURCES += \
    qt/miniAudicle.qrc

OTHER_FILES += \
    qt/icon/miniAudicle.png \
    qt/icon/remove.png \
    qt/icon/add.png \
    qt/icon/replace.png \
    qt/icon/removelast.png \
    qt/icon/removeall.png










