#!/bin/sh

if [[ -z  ~/.oh-my-zsh/fav_themes ]];then
    mkdir -v f~/.oh-my-zsh/fav_themes
fi
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH/fav_themes/powerlevel10k

