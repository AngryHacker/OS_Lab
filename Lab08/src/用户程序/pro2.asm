;
;   本文件为用户程序1的源码文件
;
    org  7e00h	    ; 加载到0:7e00h处，并开始执行
START:
	mov ax,cs		; 设置 DS和ES = CS
	mov ds,ax
	mov es,ax
	call Clear      ; 清屏

	mov ah,0
    int 21h

	call DispStr	; 显示字符串
	call Delay
	call Clear
	int 33h
	int 34h
	int 35h
	int 36h
	call Delay
	ret
		
Delay:
	mov cx,delayTime ;初始化 cx 为 5000
toDelay: ;双重循环进行延迟，延迟时间为 5000*5000
	mov word[t],cx   ;把 cx 的值保存到 t 中
	mov cx,delayTime   ;置 cx 为 delayTime 的值（500）
	loop1:loop loop1    ;每执行一次循环 cx 值减 1,直到 cx = 0，循环为在当前语句跳转，用于延迟
	mov cx,word[t]  ;把 t 的值放回 cx ，恢复 cx
	loop toDelay   ;执行循环，跳转到 delay 处，每执行一次循环 cx 值减 1,直到 cx = 0
	ret 			; 段间返回

DispStr: ; 显示字符串
; 显示字符串 （开始）
    mov ah,5
	mov dx,Msg                        ; dx 放字符串地址
	mov ch,5                          ; ch 放行号
	mov cl,23                         ; cl 放列号
    int 21h
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

Clear: ;清屏
    mov ax,0003H    ; 清屏属性
    int 10H         ; 调用中断
	ret             ; 返回

	delayTime equ 40000
	 t dw 0
Msg: ; 字符串
	db "Look! The 21h is still available....",0h
Tips: ; 退出提示
	db "Please wait for the program to quit..."
Length2: equ ($-Tips)    ; 提示的长度
	 

    times 512-($-$$) db 0 ; 用0填充扇区的剩余部分
	;db 55h,0aah	; 启动扇区的结束标志

