
DESTDIR=/usr/bin
CHUCK_SRC_DIR=chuck/src

ifneq ($(MA_PLATFORM),)
ifeq ($(MAKECMDGOALS),)

target:
	-+make -f makefile.$(MA_PLATFORM)

endif

$(MAKECMDGOALS):
	-+make -f makefile.$(MA_PLATFORM) $(MAKECMDGOALS)

else

.PHONY: current osx-ub osx linux-oss linux-jack linux-alsa win32 windows

current: 
	@echo "[miniAudicle build]: please use one of the following configurations:"
	@echo "   make linux-alsa, make linux-jack, make osx, or make win32"

osx: 
	-+make -f makefile.osx $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

linux-jack:
	-+qmake "CFLAGS+= -D__LINUX_JACK__ " miniAudicle.pro
	-+make -f makefile.qt $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

linux-alsa: 
	-+qmake "CFLAGS+= -D__LINUX_ALSA__ " miniAudicle.pro
	-+make -f makefile.qt $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

windows: 
	-+make -f makefile.win32 $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

win32: 
	-+make -f makefile.win32 $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

clean: 
	rm -rf *.{o,d} wxw/*.o wxw/miniAudicle wxw/miniAudicle.exe macosx/*.{o,d} macosx/miniAudicle.app macosx/Resources/English.lproj/*.nib
	-make -C $(CHUCK_SRC_DIR) clean

endif
