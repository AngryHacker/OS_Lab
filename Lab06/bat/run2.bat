cls

tcc -mt -c -omyos.obj MyOs.c

tasm MyOs.asm os.obj

tasm c_lib.asm c_lib.lib

tlink /3 /t os.obj myos.obj c_lib.lib,os.com

