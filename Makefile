QMK_REPO ?= zsa/qmk_firmware
QMK_BRANCH ?= firmware23

# TODO: support different keyboards, and/or add everything "static" to subrepostitory that people can fork

.PHONY: build
build: qmk_setup
	rm -rf zsa_firmware/keyboards/voyager/keymaps/mylayout
	cp -r mylayout zsa_firmware/keyboards/voyager/keymaps/mylayout
	make -C zsa_firmware voyager:mylayout
	cp zsa_firmware/.build/voyager_mylayout.bin ./latest.bin

.PHONY: qmk_setup
qmk_setup:
	make -C zsa_firmware git-submodules
	cd zsa_firmware && qmk setup $(QMK_REPO) -b $(QMK_BRANCH) -y

.PHONY: fetch_latest
fetch_latest:
	./oryx_update.sh
