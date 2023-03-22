
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../src/chuck/
CHUGINS_SRC_ROOT=../../src/chugins
CHUCK_EXAMPLES=../../src/chuck/examples

VERSION_MK=$(MINI_SRC_ROOT)/src/version.mk

include $(VERSION_MK)
WIN32_VERSION=$(shell echo $(PKG_VERSION) | egrep -o '^[0-9]+(\.[0-9]+(\.[0-9]+(\.[0-9]+)?)?)?')

CHUGIN_NAMES=ABSaturator AmbPan Bitcrusher KasFilter MagicSine FIR FoldbackSaturator \
	PanN PitchTrack GVerb Mesh2D Spectacle Elliptic Sigmund ExpDelay ExpEnv Overdrive \
	Multicomb PowerADSR WinFuncEnv WPDiodeLadder WPKorg35
CHUGINS=$(addprefix chugins/,$(addsuffix .chug,$(CHUGIN_NAMES)))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/x64/Release/$(CHUG).chug)

WIXOBJ=ChucK.wixobj examples.wixobj qt6dlls.wixobj chugins.wixobj

INSTALLER=chuck-$(PKG_VERSION).msi

# edit this pattern if your build dir is different
QT_BUILD_DIR=$(wildcard $(MINI_SRC_ROOT)/build-miniAudicle-Desktop_Qt_*-Release)

default: $(INSTALLER)

upload: $(INSTALLER)
	scp $(INSTALLER) spencer@ccrma-gate.stanford.edu:Library/Web/chuck

$(INSTALLER): $(WIXOBJ) miniAudicle.exe chuck.exe $(CHUGINS) ck_dialog.bmp ck_banner.bmp gpl2.rtf
	light -dPKG_VERSION="$(WIN32_VERSION)" -ext WixUIExtension -out "$@" $(WIXOBJ)

%.wixobj: %.wxs
	candle -dPlatform=x64 -dPKG_VERSION="$(WIN32_VERSION)" $<

examples.wxs: examples
	heat dir examples -gg -dr INSTALLDIR -cg examples -out $@
	sed -i 's/SourceDir/examples/g' $@
	sed -i "s/<Component /<Component Win64='yes' /g" $@

examples: $(CHUCK_EXAMPLES)
	cp -arf $< .
	touch $@

miniAudicle.exe: $(QT_BUILD_DIR)/release/miniAudicle.exe
	cp -af $< .
	touch $@

chuck.exe: $(CHUCK_SRC_ROOT)/src/visual-studio/x64/Release/chuck.exe
	cp -af $< .
	touch $@

chugins.wxs: $(CHUGINS)
	heat dir chugins -gg -dr INSTALLDIR -cg chugins -out $@
	sed -i 's/SourceDir/chugins/g' $@
	sed -i "s/<Component /<Component Win64='yes' /g" $@

$(CHUGINS): $(CHUGINS_ORIGINAL)
	mkdir -p chugins/
	cp -af $(CHUGINS_SRC_ROOT)/x64/Release/$(notdir $@) chugins/
	touch $@

$(CHUGINS_ORIGINAL): 
	make -C $(CHUGINS_SRC_ROOT)/$(basename $(notdir $@)) win32

clean: 
	rm -rf miniAudicle.exe chuck.exe $(CHUGINS) *.wixobj *.wixpdb *.msi examples examples.wxs
clean-all: clean
	make -C $(CHUCK_SRC_ROOT)/src clean
	make -C $(CHUGINS_SRC_ROOT) clean


