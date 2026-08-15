#! /bin/sh
#
# setup_snippets_dir.sh
# Copyright (C) 2019 janine <janine@Janines-iMac.local>
#
# Distributed under terms of the GNU GPLv3 license.
#
# Links the mini.snippets source directory into the nvim config dir, where
# MiniSnippets.gen_loader.from_lang() looks for <lang>.json.
# (Was setup_ultisnips_dir.sh, which linked UltiSnips_local.)

# NOTE: the `python -c os.path.realpath` idiom used by the other install
# scripts here fails on machines that only have `python3`. This uses cd/pwd.
DIR=$(cd "$(dirname "$0")" && pwd -P)
my_cwd=$PWD

if [ ! $DIR = $PWD ]; then
   echo "need to execute the script from $DIR"
   echo "*** moving to working directory *** "
   echo
   cd $DIR
fi

mkdir -p ~/.config/nvim/
rm -f ~/.config/nvim/UltiSnips
ln -sfn $DIR/../nvim/snippets ~/.config/nvim/snippets

cd $my_cwd
