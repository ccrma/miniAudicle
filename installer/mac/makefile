
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=../../../chuck
CHUGINS_SRC_ROOT=../../../chugins

VERSION_MK=$(MINI_SRC_ROOT)/src/version.mk

include $(VERSION_MK)

CHUGIN_NAMES=ABSaturator AmbPan Bitcrusher FIR KasFilter PanN PitchTrack GVerb Mesh2D Spectacle Elliptic
CHUGINS=$(addsuffix .chug,$(CHUGIN_NAMES))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

# PKGS=$(addsuffix .pkg,$(CHUGINS) miniAudicle.app chuck)
APP_PKGS=$(addsuffix .pkg,miniAudicle.app)
BIN_PKGS=$(addsuffix .pkg,chuck)
CHUGIN_PKGS=$(addsuffix .pkg,$(CHUGINS))
PKGS=$(APP_PKGS) $(BIN_PKGS) $(CHUGIN_PKGS)
EXAMPLES=

INSTALLER=chuck-$(PKG_VERSION).pkg

APP_DIR=/Applications
BIN_DIR=/usr/bin
CHUG_DIR=/usr/lib/chuck
EXAMPLES_DIR=/Library/ChucK/

IDENTIFIER_BASE=edu.stanford.chuck
CERT=Developer ID Installer: Spencer Salazar (9GU9FHJ3JC)

.PHONY: all
all: $(INSTALLER)

upload: $(INSTALLER)
	scp $(INSTALLER) ccrma-gate.stanford.edu:Library/Web/chuck
	@echo "uploaded to URL: "
	@echo "https://ccrma.stanford.edu/~spencer/chuck/$(INSTALLER)"

$(INSTALLER): $(PKGS) miniAudicle.app chuck $(CHUGINS) $(VERSION_MK) Distribution.xml
	@echo "Creating installer"
	@echo "    chuck path:" $(realpath $(CHUCK_SRC_ROOT))
	@echo "    miniAudicle path:" $(realpath $(MINI_SRC_ROOT))
	@echo "    chugin path:" $(realpath $(CHUGINS_SRC_ROOT))
	productbuild --distribution Distribution.xml --version $(PKG_VERSION) --package-path . --sign "$(CERT)" --resources resources $@

$(APP_PKGS): %.pkg: %
	mkdir -p $<.tmp/$(APP_DIR)
	cp -af $< $<.tmp/$(APP_DIR)
	pkgbuild --root $<.tmp --identifier $(IDENTIFIER_BASE).$(basename $<) --component-plist $@.plist $@
	rm -rf $<.tmp

$(BIN_PKGS): %.pkg: %
	mkdir -p $<.tmp/$(BIN_DIR)
	cp -af $< $<.tmp/$(BIN_DIR)
	pkgbuild --root $<.tmp --identifier $(IDENTIFIER_BASE).$(basename $<) $@
	rm -rf $<.tmp

$(CHUGIN_PKGS): %.pkg: %
	mkdir -p $<.tmp/$(CHUG_DIR)
	cp -af $< $<.tmp/$(CHUG_DIR)
	pkgbuild --root $<.tmp --identifier $(IDENTIFIER_BASE).$(basename $<) $@
	rm -rf $<.tmp

miniAudicle.app: $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app
	rm -rf miniAudicle.app
	cp -af $< .
	touch $@

$(MINI_SRC_ROOT)/src/macosx/miniAudicle.app:
	ARCHS="i386 x86_64" make -C $(MINI_SRC_ROOT)/src osx

chuck: $(CHUCK_SRC_ROOT)/src/chuck
	cp -af $< .
	touch $@

$(CHUCK_SRC_ROOT)/src/chuck:
	ARCHS="i386 x86_64" make -C $(CHUCK_SRC_ROOT)/src/ osx

$(CHUGINS): $(CHUGINS_ORIGINAL)
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $@)/$@  .
	touch $@
$(CHUGINS_ORIGINAL): 
	make -C $(dir $@) osx

clean: 
	rm -rf miniAudicle.app chuck $(CHUGINS) *.pkg
clean-all: clean
	rm -rf miniAudicle.app chuck $(CHUGINS) *.pkg
	make -C $(CHUCK_SRC_ROOT)/src clean
	make -C $(MINI_SRC_ROOT)/src clean
	make -C $(CHUGINS_SRC_ROOT) clean

