
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../../chuck
CHUGINS_SRC_ROOT=../../../chugins

CHUGIN_NAMES=ABSaturator Bitcrusher FIR KasFilter PanN
CHUGINS=$(addsuffix .chug,$(CHUGIN_NAMES))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

default: ChucK.msi

ChucK.msi: ChucK.wxs miniAudicle.exe # chuck $(CHUGINS)
	candle ChucK.wxs
	light -ext WixUIExtension ChucK.wixobj

miniAudicle.exe: $(MINI_SRC_ROOT)/src/Release/miniAudicle.exe
	cp -af $< .

chuck: $(CHUCK_SRC_ROOT)/trunk/src/chuck
	cp -af $< .

$(CHUGINS): $(CHUGINS_ORIGINAL)
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $@)/$@  .

clean: 
	rm -rf miniAudicle.exe chuck $(CHUGINS) *.wixobj *.wixpdb *.msi
