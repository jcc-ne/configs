#!/bin/sh

# sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

git clone https://github.com/jcc-ne/ohmyzsh.git ~/.oh-my-zsh
cd ~/.oh-my-zsh
git checkout dev
git update --init
./cp_dot_files.sh
