QMK_REPO ?= zsa/qmk_firmware
QMK_BRANCH ?= firmware23
ORYX_HASH ?= NY75B
ORYX_NAME ?= voyager_felix_source # TODO: remove need for this? or parse this from zip? is it keyboard_layout_name_source?

# TODO: support different keyboards

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
	git checkout oryx

	curl --location 'https://oryx.zsa.io/graphql' \
	--header 'Content-Type: application/json' \
	--data '{"query":"query getLayout($$hashId: String!, $$revisionId: String!, $$geometry: String) {\n  layout(hashId: $$hashId, geometry: $$geometry, revisionId: $$revisionId) {\n    revision {\n      hashId\n    }\n  }\n}\n","variables":{"hashId":"NY75B","geometry":"voyager","revisionId":"latest"}}' | \
	jq -r '.data.layout.revision.hashId' > .latest_oryx_hash

	# TODO: combine with call above
	curl --location 'https://oryx.zsa.io/graphql' \
	--header 'Content-Type: application/json' \
	--data '{"query":"query getLayout($$hashId: String!, $$revisionId: String!, $$geometry: String) {\n  layout(hashId: $$hashId, geometry: $$geometry, revisionId: $$revisionId) {\n    revision {\n      hashId\n title   }\n  }\n}\n","variables":{"hashId":"NY75B","geometry":"voyager","revisionId":"latest"}}' | \
	jq -r '.data.layout.revision.title' > .latest_oryx_title

	curl -L "https://oryx.zsa.io/source/$(shell cat .latest_oryx_hash)" -o .latest_oryx_source.zip
	rm -rf .wip_layout
	unzip -oj .latest_oryx_source.zip '*_source/*' -d mylayout
	
	git add .
	echo "Latest title: $(shell cat .latest_oryx_title)"
	echo "Latest hash: $(shell cat .latest_oryx_hash)"
	git commit -a -m "$(shell cat .latest_oryx_title)" -m "oryx: $(shell cat .latest_oryx_hash)"
	git checkout main
	git merge oryx
