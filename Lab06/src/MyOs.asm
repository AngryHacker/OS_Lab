;**************************************************
;* 程序版本信息                                   *
;**************************************************


.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h
start:
	
	;设置 21h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[33*4],offset MOS_21h		; 设置 21h 的偏移地址
	mov ax,cs 
	mov word ptr es:[33*4+2],ax

	;设置 33h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[51*4],offset MOS_33h		; 设置 33h 的偏移地址
	mov ax,cs 
	mov word ptr es:[51*4+2],ax

	;设置 34h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[52*4],offset MOS_34h		; 设置 34h 的偏移地址
	mov ax,cs 
	mov word ptr es:[52*4+2],ax

	;设置 35h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[53*4],offset MOS_35h		; 设置 35h 的偏移地址
	mov ax,cs 
	mov word ptr es:[53*4+2],ax

	;设置 36h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[54*4],offset MOS_36h	; 设置 36h 的偏移地址
	mov ax,cs 
	mov word ptr es:[54*4+2],ax

	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp,  100h         ; SP指向本段高端－4
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

