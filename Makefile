INPUT ?= Readme
IMAGES_FOLDER ?= $(INPUT_FOLDER)/images
INPUT_FOLDER ?= $(shell pwd)
OUTPUT_FOLDER ?= $(shell pwd)/dist

slides:
	@pandoc $(INPUT).md \
	--to revealjs \
	--output index.html \
	--template template/index.html \
	-V theme=pascal-light \
	-V revealjs-url=template \
	--standalone --slide-level 1 \
	# --self-contained

pdf: slides
	@echo "This might take a while, I'll beep when it's done"
	@echo ""
	npx decktape reveal `pwd`/index.html $(INPUT).pdf
	@echo -e "\a"

beamer:
	cp -R $(IMAGES_FOLDER) $(OUTPUT_FOLDER); \
	cd $(INPUT_FOLDER); \
	pandoc $(INPUT).md \
	--base-header-level=1 \
	--table-of-contents \
	$(FILTER_OPTIONS) \
	--default-image-extension=pdf \
	--pdf-engine=xelatex \
	--standalone \
	--to=beamer --output=$(OUTPUT_FOLDER)/index.pdf;
