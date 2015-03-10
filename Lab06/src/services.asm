; 本文件为系统中断的所有程序

;*************** ********************
;*  21 号中断                      *
;**************** *******************
;
MOS_21h:
	push bx
	push cx
	push dx
	push bp

	cmp ah,0
	jnz cmp1
	call MOS_21h_0
    jmp exit_21h
cmp1:
    cmp ah,1
	jnz cmp2
	call MOS_21h_1
    jmp exit_21h
cmp2:
    cmp ah,2
	jnz cmp3
	call MOS_21h_2
    jmp exit_21h
cmp3:
    cmp ah,3
	jnz cmp4
	call MOS_21h_3
    jmp exit_21h
cmp4:
    cmp ah,4
	jnz cmp5
	call MOS_21h_4
    jmp exit_21h
cmp5:
    cmp ah,5
	jnz cmp6
	call MOS_21h_5
    jmp exit_21h
cmp6:
    cmp ah,6
	jnz cmp7
	call MOS_21h_6
    jmp exit_21h
cmp7:
    cmp ah,7
	jnz cmp8
	call MOS_21h_7
    jmp exit_21h
cmp8:
    cmp ah,8
	jnz exit_21h
	call MOS_21h_8
    jmp exit_21h

exit_21h:
	pop bp
	pop dx
	pop cx
	pop bx

	iret						; 从中断返回

;*************** ********************
;*  21 号中断 0 号功能               *
;**************** *******************
; 屏幕中央显示 OUCH
MOS_21h_0:

    call Clear

	mov ah,13h 	                ; 功能号
	mov al,0 	             	; 光标放到串尾
	mov bl,71h 	                ; 白底深蓝
	mov bh,0 	                ; 第0页
	mov dh,12 	                ; 第18行
	mov dl,38 	                ; 第46列
	mov bp,offset MES_OUCH 	        ; BP=串地址
	mov cx,5 	                ; 串长为 28
	int 10h 		            ; 调用10H号中断

	ret

MES_OUCH:
    db "OUCH!"

;*************** ********************
;*  21 号中断 1 号功能                     *
;**************** *******************
; 字符串转为大写
MOS_21h_1:
 
    push dx
    

	mov ax,dx
	push ax                     ; 字符串首地址压栈
	call near ptr _to_upper     ; 调用 C 过程
	pop cx

	pop dx

	ret

;*************** ********************
;*  21 号中断 2 号功能                     *
;**************** *******************
; 字符串转为小写
MOS_21h_2:

    push dx
    
	mov ax,dx
	push ax                     ; 字符串首地址压栈                
	call near ptr _to_lower     ; 调用 C 过程
	pop cx

	pop dx

	ret

;*************** ********************
;*  21 号中断 3 号功能                     *
;**************** *******************
; 数字字符串转为数值
MOS_21h_3:

    push dx

	push dx                     ; 字符串首地址压栈
	call near ptr _to_digit     ; 调用 C 过程
	pop cx
	
	pop dx

	ret

;*************** ********************
;*  21 号中断 4 号功能                     *
;**************** *******************
; 数值转化为数字字符串
MOS_21h_4:

    push bx

	push bx                     ; 数值压栈
	call near ptr _digit_to_str ; 调用 C 过程
	pop cx
	
	pop bx

	ret
	
;*************** ********************
;*  21 号中断 5 号功能                     *
;**************** *******************
; 在指定位置显示字符串
MOS_21h_5:

    push si
	mov si,dx

    mov bh,0   ;页号
	mov ah,02h ;功能号 
	mov dh,ch  ;行数
	mov dl,cl  ;列数
	int 10h
 
MOS_21h_5_compare:
	cmp byte ptr[si],0
	je MOS_21h_5_end

    mov al,byte ptr[si]
	mov bl,0
	mov ah,0eh
	int 10h
	inc si
	jmp MOS_21h_5_compare

MOS_21h_5_end:
    pop si
	ret

;*************** ********************
;*  21 号中断 6 号功能                     *
;**************** *******************
; 把十六进制字符串转为十进制数值 
MOS_21h_6:

    push dx

	push dx                     ; 字符串首地址压栈
	call near ptr _to_deci      ; 调用 C 过程
	pop cx
	
	pop dx

	ret

;*************** ********************
;*  21 号中断 7 号功能                     *
;**************** *******************
; 将字符串反转
MOS_21h_7:

    push dx

	push cx
	push dx	                     ; 字符串首地址压栈
	call near ptr _to_reverse    ; 调用 C 过程
	pop cx
	pop cx
	
	pop dx

	ret		            ; 调用10H号中断


;*************** ********************
;*  21 号中断 8 号功能                     *
;**************** *******************
; 返回字符串长度
MOS_21h_8:

	push dx

	push dx                     ; 字符串首地址压栈
	call near ptr _get_strlen   ; 调用 C 过程
	pop cx
	
	pop dx

	ret

;*************** ********************
;*  33 号中断                     *
;**************** *******************
;
MOS_33h:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                ; 功能号
	mov al,0 	            	; 光标放到串尾
	mov bl,0ah 	                ; 亮绿
	mov bh,0 		            ; 第0页
	mov dh,0 	                ; 第0行
	mov dl,0 	                ; 第0列
	mov bp,offset MOS_33h_MES          ; BP=串地址
	mov cx,504 	                ; 串长为 504
	int 10h 		            ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,33h					; AL = EOI
	out 33h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MOS_33h_MES:
    db "****************************************"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
	db "****                                ****"
	db 0ah,0dh
    db "****************************************"
	db 0ah,0dh,'$'

;*************** ********************
;*  34 号中断                     *
;**************** *******************
;
MOS_34h:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                ; 功能号
	mov al,0             		; 光标放到串尾
	mov bl,0ch 	                ; 亮绿
	mov bh,0             		; 第0页
	mov dh,5 	                ; 第5行
	mov dl,44 	                ; 第44列
	mov bp,offset MOS_34h_MES 	        ; BP=串地址
	mov cx,30 	                ; 串长为 30
	int 10h 		            ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,34h					; AL = EOI
	out 34h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MOS_34h_MES:
    db "You can see me by call int 34h"

;*************** ********************
;*  35 号中断                     *
;**************** *******************
;
MOS_35h:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                 ; 功能号
	mov al,0 		             ; 光标放到串尾
	mov bl,0eh 	                 ; 黄色
	mov bh,0 	                 ; 第0页
	mov dh,13 	                 ; 第13行
	mov dl,0 	                 ; 第0列
	mov bp,offset MOS_35h_MES 	         ; BP=串地址
	mov cx,479 	                 ; 串长为 479
	int 10h 		             ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,35h					; AL = EOI
	out 35h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MOS_35h_MES:
    db "                  O                    "
	db 0ah,0dh
	db "                O   O                  "
	db 0ah,0dh
	db "              O       O                "
	db 0ah,0dh
	db "            O           O              "
	db 0ah,0dh
	db "          O               O            "
	db 0ah,0dh
	db "        O                   O          "
	db 0ah,0dh
	db "        O                   O          "
	db 0ah,0dh
	db "          O               O            "
	db 0ah,0dh
	db "            O           O              "
	db 0ah,0dh
	db "              O       O                "
	db 0ah,0dh
	db "                O   O                  "
	db 0ah,0dh
    db "                  O                    "
	db 0ah,0dh,'$'

;*************** ********************
;*  36 号中断                     *
;**************** *******************
;
MOS_36h:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                ; 功能号
	mov al,0 	             	; 光标放到串尾
	mov bl,71h 	                ; 白底深蓝
	mov bh,0 	                ; 第0页
	mov dh,18 	                ; 第18行
	mov dl,46 	                ; 第46列
	mov bp,offset MOS_36h_MES 	        ; BP=串地址
	mov cx,28 	                ; 串长为 28
	int 10h 		            ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,36h					; AL = EOI
	out 36h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MOS_36h_MES:
    db "Tomorrow is another day~ ^_^"

