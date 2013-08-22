
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../../chuck
CHUGINS_SRC_ROOT=../../../chugins

VERSION_MK=$(MINI_SRC_ROOT)/src/version.mk

include $(VERSION_MK)

CHUGIN_NAMES=ABSaturator Bitcrusher FIR KasFilter PanN
CHUGINS=$(addsuffix .chug,$(CHUGIN_NAMES))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

OWNER=root
GROUP=wheel

INSTALLER=ChucK-$(VERSION).pkg

PACKAGEMAKER=/Applications/PackageMaker.app/Contents/MacOS/PackageMaker
CERT=Developer ID Installer: Spencer Salazar (9GU9FHJ3JC)

default: $(INSTALLER)

upload: $(INSTALLER)
	scp $< ccrma-gate.stanford.edu:Library/Web/chuck

$(INSTALLER): ChucK.pmdoc miniAudicle.app chuck $(CHUGINS) $(VERSION_MK)
	$(PACKAGEMAKER) --doc $< --out $@ --certificate "$(CERT)" --version $(VERSION)
	mv $@ $@-unsigned
	productsign --sign "$(CERT)" $@-unsigned $@
	rm $@-unsigned

miniAudicle.app: $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app/Contents/MacOS/miniAudicle
	rm -rf miniAudicle.app
	cp -af $< .
#	sudo chown -R $(OWNER) $@
#	sudo chgrp -R $(GROUP) $@

chuck: $(CHUCK_SRC_ROOT)/trunk/src/chuck
	cp -af $< .

$(CHUGINS): $(CHUGINS_ORIGINAL)
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $@)/$@  .

clean: 
	rm -rf miniAudicle.app chuck $(CHUGINS) *.pkg
