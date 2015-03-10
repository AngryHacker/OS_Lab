cls

tcc -mt -c -ouser.obj user.c

tasm user.asm uuser.obj

tasm user_lib.asm user_lib.lib

tlink /3 /t uuser.obj user.obj user_lib.lib,user.com

