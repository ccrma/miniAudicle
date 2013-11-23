
DESTDIR=/usr/bin
CHUCK_SRC_DIR=chuck/src

ifneq ($(shell which qmake-qt4),)
QMAKE?=qmake-qt4
else
QMAKE?=qmake
endif

CHUGINS_SRC_ROOT=chugins
CHUGINS=ABSaturator Bitcrusher FIR KasFilter PanN
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGINS),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

ifneq ($(MA_PLATFORM),)
ifeq ($(MAKECMDGOALS),)

target:
	-+make -f makefile.$(MA_PLATFORM)

endif

$(MAKECMDGOALS):
	-+make -f makefile.$(MA_PLATFORM) $(MAKECMDGOALS)

else

.PHONY: current osx linux-jack linux-alsa linux-pulse win32 windows

current: 
	@echo "[miniAudicle build]: please use one of the following configurations:"
	@echo "   make linux-alsa, make linux-pulse, make linux-jack, make osx, or make win32"

osx: 
	-+make -f makefile.osx $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

linux-jack: makefile.qt-jack 
	-+make -f $< $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

makefile.qt-jack: miniAudicle.pro
	+$(QMAKE) "RTAUDIO_BACKEND=JACK" -o $@ $<

linux-alsa: makefile.qt-alsa
	-+make -f $< $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

makefile.qt-alsa: miniAudicle.pro
	+$(QMAKE) "RTAUDIO_BACKEND=ALSA" -o $@ $<

linux-pulse: makefile.qt-pulse
	-+make -f $< $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

makefile.qt-pulse: miniAudicle.pro
	+$(QMAKE) "RTAUDIO_BACKEND=PULSE" -o $@ $<

windows: 
	-+make -f makefile.win32 $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

win32: 
	-+make -f makefile.win32 $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

clean: 
	-make -f makefile.qt* clean
	rm -rf *.{o,d} qt/*.o miniAudicle macosx/*.{o,d} macosx/miniAudicle.app \
        macosx/Resources/English.lproj/*.nib makefile.qt*
	-make -C $(CHUCK_SRC_DIR) clean

endif
