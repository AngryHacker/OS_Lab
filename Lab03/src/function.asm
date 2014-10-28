;**************************************************
;* 内核库过程版本信息                             *
;**************************************************

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
;*  void _cls()                       *
;**************** *******************
; 清屏
public _cls
_cls proc 
; 清屏
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
		;***
		mov al,[bp+4]
		mov bl,0
		mov ah,0eh
		int 10h
		;***
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
	mov byte ptr[_in],al
	ret
_getChar endp

;*************** ********************
;*  void _getdate()                       *
;**************** *******************
; 获取日期
public _getdate
_getdate proc 
    push ax
    push bx
    push cx
    push dx		
		
	mov ah,4h
    int 1ah

	mov byte ptr[_ch1],ch       ; 将年高位放到 ch1
	mov byte ptr[_ch2],cl       ; 将年低位放到 ch2
	mov byte ptr[_ch3],dh       ; 将月放到 ch3
	mov byte ptr[_ch4],dl       ; 将日放到 ch4

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_getdate endp

;*************** ********************
;*  void _gettime()                       *
;**************** *******************
; 获取时间
public _gettime
_gettime proc 
    push ax
    push bx
    push cx
    push dx		
		
    mov ah,2h
    int 1ah

	mov byte ptr[_ch1],ch       ; 将时放到 ch1
	mov byte ptr[_ch2],cl       ; 将分放到 ch2
	mov byte ptr[_ch3],dh       ; 将秒放到 ch3

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_gettime endp

;*************** ********************
;*  void _run()                       *
;**************** *******************
; 加载并运行程序
public _run
_run proc 
    push ax
    push bx
    push cx
    push dx
	push es

	mov ax,1000h
	mov es,ax 		                ; ES=0
	mov bx,1400h                    ; ES:BX=读入数据到内存中的存储地址
	mov ah,2 		                ; 功能号
	mov al,1 	                	; 要读入的扇区数 1
	mov dl,0                 		; 软盘驱动器号（对硬盘和U盘，此处的值应改为80H）
	mov dh,0 		                ; 磁头号
	mov ch,0                 		; 柱面号
	mov cl,byte ptr[_p]          	; 起始扇区号（编号从1开始）
	int 13H 		                ; 调用13H号中断

	mov bx,1400h                    ; 将偏移量放到 bx
	call 1000h:bx                   ; 跳转到该内存地址

	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_run endp

