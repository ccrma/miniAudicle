
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../../chuck
CHUGINS_SRC_ROOT=../../../chugins
CHUCK_EXAMPLES=../../src/chuck/src/examples

CHUGIN_NAMES=ABSaturator Bitcrusher FIR KasFilter PanN
CHUGINS=$(addsuffix .chug,$(CHUGIN_NAMES))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/Release/$(CHUG).chug)

VERSION=1.3.2.0-beta-14
INSTALLER=Install\ ChucK\ $(VERSION).msi

default: $(INSTALLER)

$(INSTALLER): ChucK.wxs examples.wxs miniAudicle.exe chuck.exe $(CHUGINS) ck_dialog.bmp ck_banner.bmp gpl2.rtf
	candle ChucK.wxs examples.wxs
	light -ext WixUIExtension -out "$@" ChucK.wixobj examples.wixobj

examples.wxs: examples
	heat dir examples -gg -dr INSTALLDIR -cg examples -out examples.wxs
	sed -i 's/SourceDir/examples/g' examples.wxs

examples: ../../src/chuck/src/examples
	cp -arf $< .

miniAudicle.exe: $(MINI_SRC_ROOT)/build-miniAudicle-Static-Release/release/miniAudicle.exe
	cp -af $< .

chuck.exe: $(CHUCK_SRC_ROOT)/trunk/src/Release/chuck.exe
	cp -af $< .

$(CHUGINS): $(CHUGINS_ORIGINAL)
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $@)/Release/$@  .

clean: 
	rm -rf miniAudicle.exe chuck $(CHUGINS) *.wixobj *.wixpdb *.msi examples examples.wxs
