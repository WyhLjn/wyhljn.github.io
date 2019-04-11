#!/bin/bash

# set git global user
echo '/***************git global config start***************/'

git config --global user.name "WyhLjn"
git config --global user.email "wyhljn@gmail.com"

echo '/***************git global config end***************/'

# hexo g & d
echo '/***************hexo generate and deploy***************/'

hexo d -g

echo '/***************hexo deploy end***************/'

# unset user
echo '/***************unset git global config***************/'
git config --global --unset user.name
git config --global --unset user.email