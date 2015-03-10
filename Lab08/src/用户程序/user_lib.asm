; 用于生成库文件
.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
start:

;************ *****************************
; *SCOPY@                               *
;****************** ***********************
; 实参为局部字符串带初始化异常问题的补钉程序
public SCOPY@
SCOPY@ proc 
	arg_0 = dword ptr 6
	arg_4 = dword ptr 0ah
	push bp
	mov bp,sp
	push si
	push di
	push ds
	lds si,[bp+arg_0]
	les di,[bp+arg_4]
	cld
	shr cx,1
	rep movsw
	adc cx,cx
	rep movsb
	pop ds
	pop di
	pop si
	pop bp
	retf 8
SCOPY@ endp

;*************** ********************
;*  int _fork()                       *
;**************** *******************
; 
public _fork
_fork proc 
	mov ah,6
	int 21h
	ret
_fork endp

;*************** ********************
;*  int _wait()                       *
;**************** *******************
; 
public _wait
_wait proc 
	mov ah,7
	int 21h
	ret
_wait endp

;*************** ********************
;*  void _exit()                       *
;**************** *******************
; 
public _exit
_exit proc 
    push bp
	mov bp,sp
	push bx

	mov ah,8
	mov bx,[bp+4]
	int 21h

	pop bx
	pop bp

	ret
_exit endp

;*************** ********************
;*  void _cls()                       *
;**************** *******************
; 清屏
public _cls
_cls proc 
	mov ax,0003H
	int	10h		; 显示中断
	ret
_cls endp

;**** ***********************************
;* void _PrintChar()                       *
;******* ********************************
; 字符输出
public _printChar
_printChar proc 
	push bp
	mov bp,sp
	push ax
	push bx
	;***
	mov al,[bp+4]
	mov bl,0
	mov ah,0eh
	int 10h
	;***
	pop bx
	pop ax
	mov sp,bp
	pop bp
	ret
_printChar endp

;*********** ****************************
;*  void _GetChar()                       *
;****************** *********************
; 读入一个字符
public _getChar
_getChar proc
	mov ah,0
	int 16h
	ret
_getChar endp

;*************** ********************
;*  void _delay()                       *
;**************** *******************
; 延迟
public _delay
_delay proc 
    push bp
	mov bp,sp
    push cx

    mov cx,word ptr[bp+4]    
delay_Continue:
	mov word ptr es:[t],cx          ; 把 cx 的值保存到 t 中
	mov cx,word ptr [bp+4]
	delay_loop:loop delay_loop
	mov cx,word ptr es:[t]          ; 把 t 的值放回 cx ，恢复 cx
	loop delay_Continue
   
	pop cx
	pop bp
	ret
_delay endp

    t dw 0
;*************** ********************
;*  void _gettime()                       *
;**************** *******************
; 获取时间
public _backspace
_backspace proc 
    push ax
    push bx
    push cx
    push dx		
		
	;读光标位置，(dh,dl) = (行，列)
	mov bh,0
    mov ah,3h
    int 10h

	add dl,-1

    ;设置光标位置(dh,dl) = (行，列)
    mov bh,0
    mov ah,2h
    int 10h

    mov al,' '
	mov bl,1
	mov ah,0eh
	int 10h
	
    ;设置光标位置(dh,dl) = (行，列)
    mov bh,0
    mov ah,2h
    int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_backspace endp


_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start
