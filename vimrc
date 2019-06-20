#set cursorline
#
# set tabstop=4
#
# set shiftwidth=4
#
# set expandtab
#
# function PythonHeader()
# call setline(1,"#!/usr/bin/env python3")
# call setline(2,"# -*- coding:utf-8 -*-")
# call setline(3,"# author:你的名字")
# normal G
# normal o
# normal o
# endfunc
#
# autocmd BufNewfile *.py call PythonHeader()
#
# map <F5> :!clear ;python3 % <CR> #用Python3 执行当前shell

#####

set tabstop=4
set shiftwidth=4
set expandtab
function PythonHeader()
    call setline(1,"#!/usr/bin/env python")
    call setline(2,"# -*- coding:utf-8 -*-")
    call setline(3,"# author:sunlge")
    normal G
    normal o
    normal o
endfunc
autocmd BufNewfile *.py call PythonHeader()
map <F5> :!clear ;python % <CR>

