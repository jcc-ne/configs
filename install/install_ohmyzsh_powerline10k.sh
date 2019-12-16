#!/bin/sh

if [[ -z  ~/.oh-my-zsh/custom ]];then
    mkdir -v f~/.oh-my-zsh/custom
fi
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

