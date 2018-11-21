INPUT ?= Readme

slides:
	pandoc $(INPUT).md \
	--to revealjs \
	--template template/index.html \
	--output index.html \
	-V revealjs-url=template \
	-V progress=true \
	-V slideNumber=true \
	-V history=true \
	--no-highlight -V highlighting-css=lib/css/solarized-light.css \
	--standalone
