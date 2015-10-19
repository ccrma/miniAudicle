
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../src/chuck/
CHUGINS_SRC_ROOT=../../src/chugins
CHUCK_EXAMPLES=../../src/chuck/src/examples

VERSION_MK=$(MINI_SRC_ROOT)/src/version.mk

include $(VERSION_MK)
WIN32_VERSION=$(shell echo $(PKG_VERSION) | egrep -o '^[0-9]+(\.[0-9]+(\.[0-9]+(\.[0-9]+)?)?)?')

CHUGIN_NAMES=ABSaturator AmbPan Bitcrusher KasFilter MagicSine FIR FoldbackSaturator \
	PanN PitchTrack GVerb Mesh2D Spectacle Elliptic Sigmund ExpDelay Overdrive \
	Multicomb PowerADSR WinFuncEnv WPDiodeLadder WPKorg35
CHUGINS=$(addprefix chugins/,$(addsuffix .chug,$(CHUGIN_NAMES)))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/Release/$(CHUG).chug)

INSTALLER=chuck-$(PKG_VERSION).msi

default: $(INSTALLER)

upload: $(INSTALLER)
	scp $(INSTALLER) spencer@ccrma-gate.stanford.edu:Library/Web/chuck

$(INSTALLER): ChucK.wixobj examples.wixobj miniAudicle.exe chuck.exe $(CHUGINS) chugins.wixobj ck_dialog.bmp ck_banner.bmp gpl2.rtf
	light -dPKG_VERSION="$(WIN32_VERSION)" -ext WixUIExtension -out "$@" ChucK.wixobj examples.wixobj chugins.wixobj

%.wixobj: %.wxs
	candle -dPKG_VERSION="$(WIN32_VERSION)" $<

examples.wxs: examples
	heat dir examples -gg -dr INSTALLDIR -cg examples -out examples.wxs
	sed -i 's/SourceDir/examples/g' examples.wxs

examples: ../../src/chuck/src/examples
	cp -arf $< .
	touch $@

miniAudicle.exe: $(MINI_SRC_ROOT)/build-miniAudicle-Static-Release/release/miniAudicle.exe
	cp -af $< .
	touch $@

chuck.exe: $(CHUCK_SRC_ROOT)/src/Release/chuck.exe
	cp -af $< .
	touch $@
$(CHUCK_SRC_ROOT)/src/Release/chuck.exe:
	make -C $(CHUCK_SRC_ROOT)/src/ win32

chugins.wxs: $(CHUGINS)
	heat dir chugins -gg -dr INSTALLDIR -cg chugins -out chugins.wxs
	sed -i 's/SourceDir/chugins/g' chugins.wxs

$(CHUGINS): $(CHUGINS_ORIGINAL)
	mkdir -p chugins/
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $(notdir $@))/Release/$(notdir $@) chugins/
	touch $@

$(CHUGINS_ORIGINAL): 
	make -C $(CHUGINS_SRC_ROOT)/$(basename $(notdir $@)) win32

clean: 
	rm -rf miniAudicle.exe chuck.exe $(CHUGINS) *.wixobj *.wixpdb *.msi examples examples.wxs
clean-all: clean
	make -C $(CHUCK_SRC_ROOT)/src clean
	make -C $(CHUGINS_SRC_ROOT) clean


