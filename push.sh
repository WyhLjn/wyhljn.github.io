#!/bin/bash
hexo generate
cp -R public/* ../deploy/wyhljn.github.io
cd ../deploy/wyhljn.github.io
git add .
git commit -m “update”
git push origin master