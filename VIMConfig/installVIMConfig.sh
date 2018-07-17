#!/bin/bash
curPATH=$PWD

if [ -d ~/.vim ]
then
    mv ~/.vim ~/.vim.bak
fi

if [ -f ~/.vimrc ]
then
    mv ~/.vimrc ~/.vimrc.bak
fi

# install git
sudo apt-get install -y git git-core git-gui gitk
# install ctags for taglist
sudo apt-get install -y exuberant-ctags
# install build tool for ycmd compiling
sudo apt-get install -y build-essential cmake python-dev python3-dev

# install pathogen for package management
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# install auto pair
git clone git://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs

# install NERDTree
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/NERDTree

# install taglist
cd ~/.vim/bundle
wget "http://www.vim.org/scripts/download_script.php?src_id=19574" -O taglist.zip && unzip taglist.zip -d taglist
rm taglist.zip
cd ${curPATH}

# install ycmd
git clone https://github.com/Valloric/ycmd.git ~/.vim/bundle/ycmd
cd ~/.vim/bundle/ycmd
git submodule update --init --recursive
./build.py --clang-completer
cd ${curPATH}

# install git plugin
git clone https://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive

# install minibuf explorer
# mkdir -p ~/.vim/bundle/minibufexplorer/plugin
# wget "http://www.vim.org/scripts/download_script.php?src_id=3640" -O ~/.vim/bundle/minibufexplorer/plugin/minibufexpl.vim

# install omnicppcomplete
# cd ~/.vim/bundle
# wget "http://www.vim.org/scripts/download_script.php?src_id=7722" -O omnicppcomplete.zip && unzip omnicppcomplete.zip -d omnicppcomplete
# rm omnicppcomplete.zip
# cd ${curPATH}

# install super tab
git clone https://github.com/ervandew/supertab.git ~/.vim/bundle/supertab

cp ${curPATH}/vimrc ~/.vimrc
# cp ${curPATH}/prepareCTags.sh ~/Documents/bin
