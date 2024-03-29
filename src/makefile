
include version.mk

PREFIX=/usr

CHUCK_SRC_DIR=chuck/src

ifneq ($(shell which qmake-qt4),)
QMAKE?=qmake
else
QMAKE?=qmake
endif

CHUGINS_SRC_ROOT=chugins
CHUGINS=ABSaturator Bitcrusher FIR KasFilter PanN
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGINS),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

ifneq (,$(strip $(filter mac-ub,$(MAKECMDGOALS))))
ARCHS=x86_64 arm64
CFLAGS+=-D__MACOSX_UB__
# export for sub-make command
export ARCHS
export CFLAGS
endif

ifneq ($(CK_TARGET),)
target: $(CK_TARGET)
endif

.PHONY: current osx mac mac-ub linux-all linux linux-jack linux-alsa linux-pulse win32 windows

current: 
	@echo "[miniAudicle build]: please use the following configurations:"
	@echo "   linux-alsa, make linux-pulse, make linux-jack, make linux-all,"
	@echo "   make mac, mac-ub, mac-qt, or make win32"

mac mac-ub osx:
	-+make -f makefile.osx $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

mac-qt: makefile.qt-mac
	-+make -f $< $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

makefile.qt-mac: miniAudicle.pro
	+$(QMAKE) "RTAUDIO_BACKEND=COREAUDIO" -o $@ $<

linux-all linux: makefile.qt-linux
	-+make -f $< $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

makefile.qt-linux: miniAudicle.pro
	+$(QMAKE) "RTAUDIO_BACKEND=ALSA JACK PULSE" -o $@ $<

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

install:
ifneq ($(wildcard makefile.qt-*),)
# Linux/macOS-Qt install
	make -f $(firstword $(wildcard makefile.qt-*)) install

else ifneq ($(wildcard macosx/miniAudicle.app),)
# Mac install
	rm -rf /Applications/miniAudicle.app
	cp -a macosx/miniAudicle.app /Applications

endif

clean:
ifneq ($(wildcard makefile.qt-*),)
	make -f $(firstword $(wildcard makefile.qt-*)) clean
	rm $(wildcard makefile.qt-*)
	-make -C $(CHUCK_SRC_DIR) clean
	-make -C $(CHUGINS_SRC_ROOT) clean
else
	rm -rf *.{o,d} qt/*.o miniAudicle miniAudicle.app macosx/*.{o,d} macosx/miniAudicle.app \
        macosx/Resources/English.lproj/*.nib makefile.qt*
	-make -C $(CHUCK_SRC_DIR) clean
	-make -C $(CHUGINS_SRC_ROOT) clean
endif

PPA_CHUG_VERSION?=1.3.3a
PPA_DEB_VERSION?=1.3.3a-ppa1

PPA_CHUG_TGZ=../../miniAudicle_$(PPA_CHUG_VERSION).orig.tar.gz
SRCDIST_TGZ=miniAudicle-$(VERSION).tgz

FORCE:

ppa-tgz: $(PPA_CHUG_TGZ)

ppa-source: $(PPA_CHUG_TGZ) ppa-clean
	cd ..; debuild -S

$(PPA_CHUG_TGZ): FORCE 
	make -f makefile.source-dist
	mv $(SRCDIST_TGZ) $(PPA_CHUG_TGZ)

ppa-binary: $(PPA_CHUG_TGZ) ppa-clean
	cd ..; debuild -uc -us

ppa-upload:
	cd ..; dput ppa:t-spencer/chuck ../miniAudicle_$(PPA_DEB_VERSION)_source.changes

ppa-clean: 
	cd ..; debian/rules clean

