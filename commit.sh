#!/bin/bash
echo '/***************请输入commit***************/'
read input
echo "Your commit is:$input"
echo '/***************start hexo g***************/'
hexo generate
cp -R public/* deploy/wyhljn.github.io
cd deploy/wyhljn.github.io
echo '/***************start push***************/'
git add  -A .
git commit -m "$input"
git push origin master
echo '/***************end push***************/'
exit 1