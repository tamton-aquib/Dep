# Dep
A browser extension (meant for chrome/brave) built with svelte to show dependencies of github repos.
Only works on Cargo.toml for now.

## Install
Currently there isnt a way to install via webstore.
In brave:
1. `npm install` after cloning the repo.
2. `make build`. A `dist` folder will appear.
3. Click on hamburger menu in browser -> "Extensions" -> "Load Unpacked" -> Select dist folder.
4. profit

## Todo
- [ ] Support for package.json, pyproject.toml, pubspec.yaml
- [ ] Support for workspaces.
- [ ] Support for firefox, etc.
- [ ] Better styling (priority: high).
- [ ] item info on hover?
- [ ] Better structuring for multiple sources.
