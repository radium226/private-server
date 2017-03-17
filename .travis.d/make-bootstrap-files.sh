#!/bin/bash

declare temp_folder_path="$( mktemp -d )"

# Copy post-install.sh
cp "./bootstrap/post-install.sh" "${temp_folder_path}"

# Create cloud.cfg.d.tar.gz
cd "./bootstrap/cloud.cfg.d"
tar cf "${temp_folder_path}/cloud.cfg.d.tar.gz" "."
cd -

# Create GitHub Pages
cd "${temp_folder_path}"
git init
git checkout -b "gh-pages"
git config user.name "Travis CI"
git config user.email "none@none.no"
git add "."
git commit -m "Deploy to GitHub Pages"
git push --force "https://radium226:${GITHUB_TOKEN}@github.com/radium226/private-server.git" "gh-pages:gh-pages"
