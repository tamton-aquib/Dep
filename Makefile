
build:
	npm run build
	cp manifest.json dist/
	cp main.js dist/
	mkdir -p dist/icons/
	cp ./icons/crates.png ./dist/icons/crates.png
