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
    xor ax,ax				        		        ; AX = 0
	mov es,ax					                    ; ES = 0
	mov ax,offset Timer
	mov word ptr es:[20h],offset Timer		        ; 设置时钟中断向量的偏移地址
	mov ax,cs 
	mov word ptr es:[22h],cs				        ; 设置时钟中断向量的段地址=CS
	
	;设置 33h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[51*4],offset BIOSService_1		; 设置 33h 的偏移地址
	mov ax,cs 
	mov word ptr es:[51*4+2],ax

	;设置 34h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[52*4],offset BIOSService_2		; 设置 34h 的偏移地址
	mov ax,cs 
	mov word ptr es:[52*4+2],ax

	;设置 35h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[53*4],offset BIOSService_3		; 设置 35h 的偏移地址
	mov ax,cs 
	mov word ptr es:[53*4+2],ax

	;设置 36h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[54*4],offset BIOSService_4		; 设置 36h 的偏移地址
	mov ax,cs 
	mov word ptr es:[54*4+2],ax

	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp,  64*1024-4    ; SP指向本段高端－4
	call near ptr _cmain   ; 调用C语言程序cmain()
	jmp $

include function.asm       ; 包含内核库过程 function.asm
include services.asm       ; 包含系统服务程序
 
_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start

