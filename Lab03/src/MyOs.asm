;**************************************************
;* 程序版本信息                                   *
;**************************************************
extrn  _cmain:near         ; 声明一个c程序函数cmain()
extrn _in:near             ; C 中的变量，用于存储读入的字符
extrn _ch1:near            ; C 中变量，存放临时字符
extrn _ch2:near            ; C 中变量，存放临时字符
extrn _ch3:near            ; C 中变量，存放临时字符
extrn _ch4:near            ; C 中变量，存放临时字符
extrn _p:near              ; C 中变量，代表 应该读入的扇区号

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h
start:
	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp,  64*1024-4    ; SP指向本段高端－4
	call near ptr _cmain   ; 调用C语言程序cmain()
	jmp $

include function.asm       ; 包含内核库过程 function.asm
  
_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start

