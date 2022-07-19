
build:
	npm run build
	cp manifest.json dist/
	cp main.js dist/
	mkdir -p dist/icons/
	cp ./icons/border.png dist/icons/
