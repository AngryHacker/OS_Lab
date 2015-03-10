extrn _printInt:near
; 本文件为系统中断的所有程序

;*************** ********************
;*  21 号中断                      *
;**************** *******************
;
MOS_21h:

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
	jmp MOS_21h_6
cmp7:
    cmp ah,7
	jnz cmp8
	jmp MOS_21h_7
cmp8:
    cmp ah,8
	jnz cmp9
	jmp MOS_21h_8
cmp9:
    cmp ah,9
	jnz cmp10
	jmp MOS_21h_9
cmp10:
    cmp ah,10
	jnz cmp11
	jmp MOS_21h_10
cmp11:
    cmp ah,11
	jnz cmp12
	jmp MOS_21h_11
cmp12:
    cmp ah,12
	jnz exit_21h
	jmp MOS_21h_12

exit_21h:
	iret						; 从中断返回

;*************** ********************
;*  21 号中断 0 号功能               *
;**************** *******************
; 屏幕中央显示 OUCH
MOS_21h_0:
    push ax

    call Clear

    .386
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	gs,ax					; GS = B800h
	mov ah,71h
	mov al,'O'
	mov word[gs:((80 * 12 + 38) * 2)], ax    
	mov al,'U'
	mov word[gs:((80 * 12 + 39) * 2)], ax    
	mov al,'C'
	mov word[gs:((80 * 12 + 40) * 2)], ax    
	mov al,'H'
	mov word[gs:((80 * 12 + 41) * 2)], ax    
	.8086
       	
	pop ax

	ret

;*************** ********************
;*  21 号中断 1 号功能                     *
;**************** *******************
; 字符串转为大写
MOS_21h_1:
 

	push dx                     ; 字符串首地址压栈
	call near ptr _to_upper     ; 调用 C 过程
	pop dx

	ret

;*************** ********************
;*  21 号中断 2 号功能                     *
;**************** *******************
; 字符串转为小写
MOS_21h_2:

	push dx                     ; 字符串首地址压栈                
	call near ptr _to_lower     ; 调用 C 过程
	pop dx

	ret

;*************** ********************
;*  21 号中断 3 号功能                     *
;**************** *******************
; 数字字符串转为数值
MOS_21h_3:

	push dx                     ; 字符串首地址压栈
	call near ptr _to_digit     ; 调用 C 过程
	pop dx
	
	ret

;*************** ********************
;*  21 号中断 4 号功能                     *
;**************** *******************
; 数值转化为数字字符串
MOS_21h_4:

	push bx                     ; 数值压栈
	call near ptr _digit_to_str ; 调用 C 过程
	pop bx
	
	ret
	
;*************** ********************
;*  21 号中断 5 号功能                     *
;**************** *******************
; 在指定位置显示字符串
MOS_21h_5:

    push ax
	push bx
	push cx
	push dx
	push bp
    push si
	push es
	mov si,dx

	mov ax,0B800h
	mov es,ax

MOS_21h_5_LOOP:
    cmp byte ptr[si],0
	jz MOS_21h_5_end
    
    mov al,80
	mul ch
	mov bp,ax
	mov dl,cl
	mov dh,0
	add bp,dx
	add bp,bp

	mov ah,0eh
	mov al,byte ptr [si]
	mov es:[bp],ax

	inc si
	inc cl

	jmp MOS_21h_5_LOOP

MOS_21h_5_end:
    pop bx
	mov es,bx
    pop si
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	ret

;*************** ********************
;*  21 号中断 6 号功能                     *
;**************** *******************
; 进程创建 
MOS_21h_6:
    .386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB

	call near ptr _do_fork   ; 调用 C 过程

	iret

;*************** ********************
;*  21 号中断 7 号功能                     *
;**************** *******************
; 进程等待
MOS_21h_7:
    .386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB

	call near ptr _do_wait   ; 调用 C 过程

	iret

;*************** ********************
;*  21 号中断 8 号功能                     *
;**************** *******************
; 进程结束
MOS_21h_8:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB
    
	push bx
	call near ptr _do_exit   ; 调用 C 过程
    pop bx

	iret

;*************** ********************
;*  21 号中断 9 号功能                     *
;**************** *******************
; 申请信号量
MOS_21h_9:

    .386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call near ptr  _SavePCB
    
	mov bx,ax
	push bx
	call near ptr _semaGet   ; 调用 C 过程
    pop bx

	iret

;*************** ********************
;*  21 号中断 10 号功能                     *
;**************** *******************
; 释放信号量
MOS_21h_10:

    .386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB
    
	mov bx,ax
	push bx
	call near ptr _semaFree   ; 调用 C 过程
    pop bx

	iret

;*************** ********************
;*  21 号中断 11 号功能                     *
;**************** *******************
; P 操作
MOS_21h_11:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB

	mov bx,ax
	push bx
	call near ptr _semaP   ; 调用 C 过程
    pop bx

	iret

;*************** ********************
;*  21 号中断 12 号功能                     *
;**************** *******************
; V 操作
MOS_21h_12:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         ; 以上所有 push 为把寄存器的值当做参数传给 savePCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB
    
	mov bx,ax
	push bx
	call near ptr _semaV   ; 调用 C 过程
    pop bx

	iret

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

    push si
	push es
	mov si,offset MOS_33h_MES

	mov ax,0B800h
	mov es,ax
	mov cx,0

MOS_33h_LOOP:
    cmp byte ptr[si],0
	jz MOS_33h_end
    
    mov al,80
	mul ch
	mov bp,ax
	mov dl,cl
	mov dh,0
	add bp,dx
	add bp,bp

	mov ah,0ah
	mov al,byte ptr [si]
	mov es:[bp],ax

	inc si
	inc cl
	cmp cl,40
	jnz MOS_33h_Next
	mov cl,0
	inc ch
MOS_33h_Next:
	jmp MOS_33h_LOOP
	
MOS_33h_end:
    pop ax
	mov es,ax
	pop si
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
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
	db "****                                ****"
    db "****************************************",0

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

	push si
	push es
	mov si,offset MOS_34h_MES

	mov ax,0B800h
	mov es,ax
	mov cH,5
	mov cl,44

MOS_34h_LOOP:
    cmp byte ptr[si],0
	jz MOS_34h_end
    
    mov al,80
	mul ch
	mov bp,ax
	mov dl,cl
	mov dh,0
	add bp,dx
	add bp,bp

	mov ah,0dh
	mov al,byte ptr [si]
	mov es:[bp],ax

	inc si
	inc cl
	cmp cl,80
	jnz MOS_34h_Next
	mov cl,40
	inc ch
MOS_34h_Next:
	jmp MOS_34h_LOOP
	
MOS_34h_end:
    pop ax
	mov es,ax
	pop si

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
    db "You can see me by call int 34h",0

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

    push si
	push es
	mov si,offset MOS_35h_MES

	mov ax,0B800h
	mov es,ax
	mov ch,13
	mov cl,0

MOS_35h_LOOP:
    cmp byte ptr[si],0
	jz MOS_35h_end
    
    mov al,80
	mul ch
	mov bp,ax
	mov dl,cl
	mov dh,0
	add bp,dx
	add bp,bp

	mov ah,0eh
	mov al,byte ptr [si]
	mov es:[bp],ax

	inc si
	inc cl
	cmp cl,40
	jnz MOS_35h_Next
	mov cl,0
	inc ch
MOS_35h_Next:
	jmp MOS_35h_LOOP
	
MOS_35h_end:
    pop ax
	mov es,ax
	pop si
	
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
    db "                  O                     "
	db "                O   O                   "
	db "              O       O                 "
	db "            O           O               "
	db "          O               O             "
	db "        O                   O           "
	db "        O                   O           "
	db "          O               O             "
	db "            O           O               "
	db "              O       O                 "
	db "                O   O                   "
    db "                  O                     ",0

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

	push si
	push es
	mov si,offset MOS_36h_MES

	mov ax,0B800h
	mov es,ax
	mov cH,18
	mov cl,46

MOS_36h_LOOP:
    cmp byte ptr[si],0
	jz MOS_36h_end
    
    mov al,80
	mul ch
	mov bp,ax
	mov dl,cl
	mov dh,0
	add bp,dx
	add bp,bp

	mov ah,71h
	mov al,byte ptr [si]
	mov es:[bp],ax

	inc si
	inc cl
	cmp cl,80
	jnz MOS_36h_Next
	mov cl,40
	inc ch
MOS_36h_Next:
	jmp MOS_36h_LOOP
	
MOS_36h_end:
    pop ax
	mov es,ax
	pop si
	
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
    db "Tomorrow is another day~ ^_^",0

