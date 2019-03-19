#!/bin/sh

if [[ -z  ~/.oh-my-zsh/fav_themes ]];then
    mkdir -v f~/.oh-my-zsh/fav_themes
fi
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/fav_themes/powerlevel9k 
