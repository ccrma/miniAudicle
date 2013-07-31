
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../../chuck
CHUGINS_SRC_ROOT=../../../chugins

CHUGIN_NAMES=ABSaturator Bitcrusher FIR KasFilter PanN
CHUGINS=$(addsuffix .chug,$(CHUGIN_NAMES))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

OWNER=root
GROUP=wheel

default: miniAudicle.app chuck $(CHUGINS)

miniAudicle.app: $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app/Contents/MacOS/miniAudicle
	rm -rf miniAudicle.app
	cp -af $< .
#	sudo chown -R $(OWNER) $@
#	sudo chgrp -R $(GROUP) $@

chuck: $(CHUCK_SRC_ROOT)/trunk/src/chuck
	cp -af $< .
#	sudo chgrp -R $(GROUP) $@
#	sudo chown -R $(OWNER) $@

$(CHUGINS): $(CHUGINS_ORIGINAL)
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $@)/$@  .
#	sudo chgrp -R $(GROUP) $@
#	sudo chown -R $(OWNER) $@

clean: 
	rm -rf miniAudicle.app chuck $(CHUGINS)
