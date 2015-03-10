;
;   本文件为用户程序2的源码文件
;
    org  7e00h	    ; 加载到0:7e00h处，并开始执行
START:
	mov ax,cs		; 设置 DS和ES = CS
	mov ds,ax
	mov es,ax
	call Clear      ; 清屏
	call DispStr	; 显示字符串
		
	; 延迟
	mov cx,delayTime 
toDelay: 
	mov word[t],cx 
	mov cx,delayTime 
	loop1:loop loop1 
	mov cx,word[t]
	loop toDelay  

	ret 			; 段间返回

DispStr: ; 显示字符串
; 显示字符串 "Hello, Here is Program 1 ~"（开始）
	mov ah,13h 	    ; 功能号
	mov al,1 		; 光标放到串尾
	mov bl,0ch 	    ; 黑底红字
	mov bh,0 		; 第0页
	mov dh,05h 	    ; 第5行
	mov dl,1ch 	    ; 第28列
	mov bp,BootMsg 	; BP=串地址
	mov cx,Length1	; 串长为length1
	int 10h 		; 调用10H号中断
; 显示字符串（结束）
; 显示字符串2 "Please Key in Esc to quit:"（开始）
	mov ah,13h 	    ; 功能号
	mov al,1 		; 光标放到串尾
	mov bl,0dh 	    ; 黑底品红字
	mov bh,0 		; 第0页
	mov dh,07h 	    ; 第7行
	mov dl,18 	    ; 第28列
	mov bp,Tips 	; BP=串地址
	mov cx,Length2 	; 串长
	int 10h 		; 调用10H号中断
; 显示字符串2（结束）
	ret

Keyin: ; 读按键
	mov ah,0 		; 功能号
	int 16h 		; 调用16H号中断
    ret             ; 退出

Clear: ;清屏
    mov ax,0003H    ; 清屏属性
    int 10H         ; 调用中断
	ret             ; 返回

	delayTime equ 40000
	 t dw 0
BootMsg: ; 引导字符串
	db "Hi,I am program 2...."
Length1: equ ($-BootMsg) ; 欢迎字符串的长度
Tips: ; 退出提示
	db "Please wait for the program to quit..."
Length2: equ ($-Tips)    ; 提示的长度
	 

    times 512-($-$$) db 0 ; 用0填充扇区的剩余部分
	;db 55h,0aah	; 启动扇区的结束标志

