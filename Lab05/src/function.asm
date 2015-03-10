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
	push ds

	xor ax,ax
	mov es,ax
	push word ptr es:[9*4]                  ; 保存 9h 中断
	pop word ptr ds:[0]
	push word ptr es:[9*4+2]
	pop word ptr ds:[2]

	mov word ptr es:[24h],offset keyDo		; 设置键盘中断向量的偏移地址
	mov ax,cs 
	mov word ptr es:[26h],ax

	mov ax,1000h
	mov es,ax 		                         ; ES=0
	mov bx,7e00h                             ; ES:BX=读入数据到内存中的存储地址
	mov ah,2 		                         ; 功能号
	mov al,1 	                         	 ; 要读入的扇区数 1
	mov dl,0                 	             ; 软盘驱动器号（对硬盘和U盘，此处的值应改为80H）
	mov dh,1 		                         ; 磁头号
	mov ch,0                 	         	 ; 柱面号
	mov cl,byte ptr[_p]                   	 ; 起始扇区号（编号从1开始）
	int 13H 		                         ; 调用13H号中断

	mov bx,7e00h                             ; 将偏移量放到 bx
	call bx

	xor ax,ax
	mov es,AX
	push word ptr ds:[0]                     ; 恢复 9h 中断
	pop word ptr es:[9*4]
	push word ptr ds:[2]
	pop word ptr es:[9*4+2]
	int 9h

	pop ax
	mov ds,ax
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_run endp

;*************** ********************
;*  时钟中断程序
;**************** *******************
Timer:
    push ax
	push bx
	push cx
	push dx
	push bp
    push es
	
    dec byte ptr es:[count]				; 递减计数变量
	jnz End1						    ; >0：跳转
	inc byte ptr es:[bn]                ; 自增变量 bn
	cmp byte ptr es:[bn],1              ; 根据 bn 选择跳转地址，1 则显示 /
	jz ch1
	cmp byte ptr es:[bn],2              ; 2 则显示 |
	jz ch2
	cmp byte ptr es:[bn],3              ; 3 则显示 \
	jz ch3
	jmp showch
ch1:
    mov bp,offset str1
	jmp showch
ch2:
    mov bp,offset str2
	jmp showch
ch3:
	mov byte ptr es:[bn],0
    mov bp,offset str3
	jmp showch

showch:
	mov ah,13h 	                        ; 功能号
	mov al,0                     		; 光标放到串尾
	mov bl,0ah 	                        ; 亮绿
	mov bh,0 	                    	; 第0页
	mov dh,24 	                        ; 第24行
	mov dl,78 	                        ; 第78列
	mov cx,1 	                        ; 串长为 1
	int 10h 	                    	; 调用10H号中断
	mov byte ptr es:[count],delay
End1:
	mov al,20h					        ; AL = EOI
	out 20h,al						    ; 发送EOI到主8529A
	out 0A0h,al					        ; 发送EOI到从8529A

	pop ax                              ; 恢复寄存器信息
	mov es,ax
	pop bp
	pop dx 
	pop cx
	pop bx
	pop ax
	iret		

	str1 db '/'
	str2 db '|'
	str3 db '\'
	delay equ 10				        ; 计时器延迟计数
	count db delay					     ; 计时器计数变量，初值=delay
	bn db 0

;*************** ********************
;*  void _callBIOS()                       *
;**************** *******************
; 调用 BIOS 33h 34h 35h 36h 中断向量
public _callBIOS
_callBIOS proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call near ptr _cls                          ; 清屏

    int 33h
	int 34h
	int 35h
	int 36h

    call DelaySome                      ; 延迟

	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_callBIOS endp


;*************** ********************
;*  void _int33()                       *
;**************** *******************
; 调用 33h 
public _Int33
_Int33 proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call near ptr _cls

    int 33h

	call DelaySome
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_Int33 endp

;*************** ********************
;*  void _int34()                       *
;**************** *******************
; 调用 34h
public _Int34
_Int34 proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call near ptr _cls

    int 34h

	call DelaySome
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_Int34 endp

;*************** ********************
;*  void _int35()                       *
;**************** *******************
; 调用 35h
public _Int35
_Int35 proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call near ptr _cls

    int 35h

	call DelaySome
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_Int35 endp

;*************** ********************
;*  void _int36()                       *
;**************** *******************
; 调用 36h
public _Int36
_Int36 proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call near ptr _cls

    int 36h

	call DelaySome
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_Int36 endp

;*************** ********************
;*  键盘中断程序
;**************** *******************
keyDo:
    push ax
    push bx
    push cx
    push dx
	push bp

	inc byte ptr es:[c]
	cmp byte ptr es:[c],24
	jnz continue
	call keyInit

continue:
	inc byte ptr es:[odd]
	cmp byte ptr es:[odd],1
	je print
	mov byte ptr es:[odd],0
	jmp next

print:
    mov ah,13h 	                    ; 功能号
	mov al,0                 		; 光标放到串尾
	mov bl,0ah 	                    ; 亮绿
	mov bh,0 	                	; 第0页
	mov dh,byte ptr es:[c] 	        ; 第 c 行
	mov dl,35 	                    ; 第35列
	mov bp, offset OUCH 	        ; BP=串地址
	mov cx,10  	                    ; 串长为 10
	int 10h 		                ; 调用10H号中断
    
next:
	in al,60h

	mov al,20h					    ; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					    ; 发送EOI到从8529A
	
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	iret							; 从中断返回

;*************** ********************
;*  DelaySome                       *
;**************** *******************
; 延迟
DelaySome:                          ; 延迟一段时间
    mov cx,delayTime      
toDelay:
	mov word ptr es:[t],cx          ; 把 cx 的值保存到 t 中
	mov cx,delayTime
	loop1:loop loop1 
	mov cx,word ptr es:[t]          ; 把 t 的值放回 cx ，恢复 cx
	loop toDelay
	ret

Clear: ;清屏
    MOV AX,0003H
    INT 10H
	ret

keyInit:                            ; 初始化 OUCH！OUCH！显示的行数为 0 
    mov byte ptr es:[c],0           ; 设置变量 c
	ret

OUCH:
    db "OUCH!OUCH!"
	c db 10
	odd db 1

	delayTime equ 40000
	t dw 0
