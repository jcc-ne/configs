#!/bin/sh

set -e

if [ ! -d ~/.pyenv ]; then
    brew insall pyenv
    # git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi

# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
# echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
# echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc

if [ ! -d ~/.pyenv/plugins ]; then
    mkdir ~/.pyenv/plugins
fi
if [ ! -d ~/.pyenv/plugins/pyenv-virtualenv ]; then
    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
fi
# echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshenv

# exec "$SHELL"

echo  "installing..."
# pyenv install anaconda3-2020.02

# pyenv virtualenv anaconda3-2020.02 tf2
# pyenv activate tf2

# conda install python=3.7 tensorflow-gpu
pyenv install 3.7.7
pyenv virtualenv 3.7.7 py37
