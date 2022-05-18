
MINI_SRC_ROOT=../..
CHUCK_SRC_ROOT=$(MINI_SRC_ROOT)/src/chuck
CHUGINS_SRC_ROOT=$(MINI_SRC_ROOT)/src/chugins

VERSION_MK=$(MINI_SRC_ROOT)/src/version.mk

include $(VERSION_MK)

CHUGIN_NAMES=ABSaturator AmbPan Bitcrusher Elliptic ExpEnv ExpDelay FIR \
    FoldbackSaturator GVerb KasFilter MagicSine Mesh2D Multicomb \
    PanN PitchTrack PowerADSR Sigmund Spectacle WinFuncEnv WPDiodeLadder \
    WPKorg35
CHUGINS=$(addsuffix .chug,$(CHUGIN_NAMES))
CHUGINS_ORIGINAL=$(foreach CHUG,$(CHUGIN_NAMES),$(CHUGINS_SRC_ROOT)/$(CHUG)/$(CHUG).chug)

EXAMPLES=$(CHUCK_SRC_ROOT)/examples

# PKGS=$(addsuffix .pkg,$(CHUGINS) miniAudicle.app chuck)
APP_PKGS=$(addsuffix .pkg,miniAudicle.app)
BIN_PKGS=$(addsuffix .pkg,chuck)
CHUGIN_PKGS=$(addsuffix .pkg,$(CHUGINS))
EXAMPLES_PKG=examples.pkg
PKGS=$(APP_PKGS) $(BIN_PKGS) $(CHUGIN_PKGS) $(EXAMPLES_PKG)

INSTALLER=chuck-$(PKG_VERSION).pkg

APP_DIR=/Applications
BIN_DIR=/usr/local/bin
CHUG_DIR=/usr/local/lib/chuck
EXAMPLES_DST=/Library/ChucK

IDENTIFIER_BASE=edu.stanford.chuck
CERT_APP=Developer ID Application
CERT_INSTALLER=Developer ID Installer

.PHONY: all
all: $(INSTALLER)

upload: $(INSTALLER)
	scp $(INSTALLER) ccrma-gate.stanford.edu:Library/Web/chuck
	@echo "uploaded to URL: "
	@echo "https://ccrma.stanford.edu/~spencer/chuck/$(INSTALLER)"

$(INSTALLER): $(PKGS) miniAudicle.app chuck $(CHUGINS) $(VERSION_MK) Distribution.xml
	@echo "--- Creating installer ---"
	@echo "    chuck path:" $(realpath $(CHUCK_SRC_ROOT))
	@echo "    miniAudicle path:" $(realpath $(MINI_SRC_ROOT))
	@echo "    chugin path:" $(realpath $(CHUGINS_SRC_ROOT))
	productbuild --distribution Distribution.xml --version $(PKG_VERSION) --package-path . --sign "$(CERT_INSTALLER)" --resources resources $@

$(APP_PKGS): %.pkg: %
	rm -rf $<.tmp/$(APP_DIR)
	mkdir -p $<.tmp/$(APP_DIR)
	cp -af $< $<.tmp/$(APP_DIR)
	pkgbuild --root $<.tmp --identifier $(IDENTIFIER_BASE).$(basename $<) --component-plist $@.plist $@
	rm -rf $<.tmp

$(BIN_PKGS): %.pkg: %
	rm -rf $<.tmp/$(BIN_DIR)
	mkdir -p $<.tmp/$(BIN_DIR)
	cp -af $< $<.tmp/$(BIN_DIR)
	pkgbuild --root $<.tmp --identifier $(IDENTIFIER_BASE).$(basename $<) $@
	rm -rf $<.tmp

$(CHUGIN_PKGS): %.pkg: %
	rm -rf $<.tmp/$(CHUG_DIR)
	mkdir -p $<.tmp/$(CHUG_DIR)
	cp -af $< $<.tmp/$(CHUG_DIR)
	pkgbuild --root $<.tmp --identifier $(IDENTIFIER_BASE).$(basename $<) $@
	rm -rf $<.tmp

$(EXAMPLES_PKG): $(EXAMPLES)
	rm -rf $@.tmp/$(EXAMPLES_DST)
	mkdir -p $@.tmp/$(EXAMPLES_DST)
	cp -af $< $@.tmp/$(EXAMPLES_DST)
	pkgbuild --root $@.tmp --identifier $(IDENTIFIER_BASE).examples $@
	rm -rf $@.tmp

miniAudicle.app: $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app/Contents/MacOS/miniAudicle
	rm -rf miniAudicle.app
	cp -af $< .
	codesign --force --deep --options=runtime --sign "$(CERT_APP)" $@/Contents/Resources/chuck
	codesign --force --deep --options=runtime --sign "$(CERT_APP)" $@/Contents/Resources/oggenc
	codesign --force --deep --options=runtime --sign "$(CERT_APP)" $@/Contents/Frameworks/PSMTabBarControl.framework
	codesign --entitlements miniAudicle.entitlements --force --deep --options=runtime --sign "$(CERT_APP)" $@
	touch $@

$(MINI_SRC_ROOT)/src/macosx/miniAudicle.app/Contents/MacOS/miniAudicle $(MINI_SRC_ROOT)/src/macosx/miniAudicle.app:
	make -C $(MINI_SRC_ROOT)/src mac-ub

chuck: $(CHUCK_SRC_ROOT)/src/chuck
	cp -af $< .
	codesign --entitlements miniAudicle.entitlements --force --options=runtime --sign "$(CERT_APP)" $@
	touch $@

$(CHUCK_SRC_ROOT)/src/chuck:
	make -C $(CHUCK_SRC_ROOT)/src/ clean
	make -C $(CHUCK_SRC_ROOT)/src/ mac-ub

$(CHUGINS): $(CHUGINS_ORIGINAL)
	cp -af $(CHUGINS_SRC_ROOT)/$(basename $@)/$@  .
	codesign --entitlements miniAudicle.entitlements --force --options=runtime --sign "$(CERT_APP)" $@
	touch $@
$(CHUGINS_ORIGINAL): 
	ARCHS="arm64 x86_64" make -C $(dir $@) osx

clean: 
	rm -rf miniAudicle.app chuck $(CHUGINS) *.pkg *.tmp
clean-all: clean
	rm -rf miniAudicle.app chuck $(CHUGINS) *.pkg
	make -C $(CHUCK_SRC_ROOT)/src clean
	make -C $(MINI_SRC_ROOT)/src clean
	make -C $(CHUGINS_SRC_ROOT) clean

