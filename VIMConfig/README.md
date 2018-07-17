# A Basic Example to config vim to become c++ ide
I learn steps from [Here](https://blog.csdn.net/doc_sgl/article/details/47205779).

After the following steps, your vim should be able to do:
- code navigation
- code auto-complete
- show tag list for functions
- NERDTree
- mini-buffer managment

## Install pathogen
It is a package managment tool.
### install steps
```
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```
vim ~/.vimrc
```
" install pathogen for package management
execute pathogen#infect()
syntax on
filetype plugin indent on
```
restart vim
### check
You will see a tree under ~/.vim:
```
|---autoload
|---|---pathogen.vim
|---bundle
```

## auto-pair
### install steps
```
git clone git://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs
```

## NERDTree
### install steps
```
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/NERDTree
```
### add key mapping
vim ~/.vimrc
```
"""""""""""""""""""""""""""""""""""""""""""" key mapping start
map <C-n> :NERDTree<CR>
"""""""""""""""""""""""""""""""""""""""""""" key mapping end
```

## MiniBufExplorer
[Project page](http://www.vim.org/scripts/script.php?script_id=159)
### install steps
```
mkdir -p ~/.vim/bundle/minibufexplorer/plugin && wget "http://www.vim.org/scripts/download_script.php?src_id=3640" -O ~/.vim/bundle/minibufexplorer/plugin/minibufexpl.vim
```
### add user config
vim ~/.vimrc
```
"""""""""""""""""""""""""""""""""""""""""""" user config start
" mini buffer
let g:miniBufExplMaxSize = 2
"""""""""""""""""""""""""""""""""""""""""""" user config end
```
### usage
```
:ls    list all buffer
:b N   open buffer number of N
```

## ctags+taglist+omnicppcomplete
### ctags
#### install
on Ubuntu
```
sudo apt-get install ctags
```
#### usage
goto the root of your project
```
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++
```
### taglist
[Project page](http://www.vim.org/scripts/script.php?script_id=273)
#### install
```
cd ~/.vim/bundle && wget "http://www.vim.org/scripts/download_script.php?src_id=19574" -O taglist.zip && unzip taglist.zip -d taglist
```
#### user config
```
" omnicppcomplete
filetype plugin indent on
set completeopt=longest,menu
let OmniCpp_NamespaceSearch = 2     " search namespaces in the current buffer   and in included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function drop down list
let OmniCpp_MayCompleteScope = 1    " input :: then start autocomplete
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]"]"
```
#### usage
```
:TlistToggle
```

### omnicppcomplete
[Project page](http://www.vim.org/scripts/script.php?script_id=1520)
#### install
```
cd ~/.vim/bundle && wget "http://www.vim.org/scripts/download_script.php?src_id=7722" -O omnicppcomplete.zip && unzip omnicppcomplete.zip -d omnicppcomplete
```
#### add help document
```
:helptags ~/.vim/bundle/omnicppcomplete/doc
```
#### view help document
```
:help omnicppcomplete
```
#### usage
```
" omnicppcomplete
filetype plugin indent on
set completeopt=longest,menu
let OmniCpp_NamespaceSearch = 2     " search namespaces in the current buffer   and in included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function drop down list
let OmniCpp_MayCompleteScope = 1    " input :: then start autocomplete
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]"]"
```

## Add tags for thirtd party project
[Project page](http://www.vim.org/scripts/script.php?script_id=2358)
### install
```
mkdir -p ~/.vim/tags && cd ~/.vim/tags && wget "http://www.vim.org/scripts/download_script.php?src_id=9178" -O - | tar jxvf -
cd ~/.vim/tags/cpp_src
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++
```
vim ~/.vimrc
```
" ctags
set tags+=~/.vim/tags/cpp_src/tags
```

## super tab
Now you can use tab to do the selection
### install
```
git clone https://github.com/ervandew/supertab.git ~/.vim/bundle/supertab
```
