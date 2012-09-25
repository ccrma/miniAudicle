
DESTDIR=/usr/bin
CHUCK_SRC_DIR=chuck

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
	@echo "[chuck build]: please use one of the following configurations:"; echo "   make linux-alsa, make linux-jack, make linux-oss"; echo "   make osx-ppc, make osx-intel, make osx-ub or make win32"

osx-ub: 
	-+make -f makefile.osx-ub $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

osx: 
	-+make -f makefile.osx $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

linux-oss: 
	-+make -f makefile.oss $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

linux-jack:
	-+make -f makefile.jack $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

linux-alsa: 
	-+make -f makefile.alsa $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

windows: 
	-+make -f makefile.win32 $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

win32: 
	-+make -f makefile.win32 $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

clean: 
	rm -rf *.o wxw/*.o wxw/miniAudicle wxw/miniAudicle.exe macosx/*.o macosx/miniAudicle.app macosx/English.lproj/*.nib
	-make -C $(CHUCK_SRC_DIR) clean

endif
