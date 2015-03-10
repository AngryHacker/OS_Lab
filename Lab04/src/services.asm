; 本程序为 4 个系统服务程序
BIOSService_1:
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
	mov bp,offset MES1          ; BP=串地址
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

MES1:
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

BIOSService_2:
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
	mov bp,offset MES2 	        ; BP=串地址
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

MES2:
    db "You can see me by call int 34h"

BIOSService_3:
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
	mov bp,offset MES3 	         ; BP=串地址
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

MES3:
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


BIOSService_4:
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
	mov bp,offset MES4 	        ; BP=串地址
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

MES4:
    db "Tomorrow is another day~ ^_^"
