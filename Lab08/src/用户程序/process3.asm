;;**********************************************************************************
;;    				程序功能：利用时钟中断，在显示框左下角画框
;;						程序原作：凌应标
;;						程序修改：廖锦城
;;						修改时间：2013-04-15
;;**********************************************************************************

delay equ 2000					; 计时器延迟计数,用于控制画框的速度
ddelay equ 580					; 计时器延迟计数,用于控制画框的速度


    org 100h					; 程序加载到100h，可用于生成COM
	;org 7c00h

;初始化段寄存器
	mov ax,300						; AX = 0
	mov es,ax					; ES = 0
	mov ds,ax					; DS = CS
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	gs,ax					; GS = B800h
    mov word[count],delay
	mov word[dcount],ddelay

LABEL_SHOW_LOVE:	
	mov ah,0bh
	mov al,'I'
	mov word[gs:((80 * 19 + 15) * 2)], ax
	mov al,'L'
	mov word[gs:((80 * 19 + 17) * 2)], ax
	mov al,'O'
	mov word[gs:((80 * 19 + 18) * 2)], ax
	mov al,'V'
	mov word[gs:((80 * 19 + 19) * 2)], ax
	mov al,'E'
	mov word[gs:((80 * 19 + 20) * 2)], ax
	mov al,'O'
	mov word[gs:((80 * 19 + 22) * 2)], ax
	mov al,'S'
	mov word[gs:((80 * 19 + 23) * 2)], ax
	
    mov word[x],13
    mov word[y],0
	mov byte[rdlu], 2             ; 当前画框的方向, 1-向右,2-向下,3-向左,4-向上
    mov word[char],'A'
	
loop1:
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转;
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
    jnz loop1
    call boxing
	mov word[count],delay
	mov word[dcount],ddelay
    jmp loop1	
	
	jmp $						; 死循环

datadef:

	count dw delay				; 计时器计数变量，初值=delay
	dcount dw ddelay			; 计时器计数变量，初值=delay
	x dw 0                      ; 当前字符显示位置的行号,0~24
	y dw 0                      ; 当前字符显示位置的列号,0~79
	rdlu db 2                   ; 当前画框的方向, 1-向右,2-向下,3-向左,4-向上
	char db 'A'                 ; 当前显示字符

	
boxing:
	
right:
    mov al,byte[rdlu]           ;右 
	cmp al,1
	jnz down
	mov ax,word[y]              ;最后一列?
	cmp ax, 39
	jz r2d
	inc byte[y]
	jmp show
r2d:
    mov byte[rdlu],4            ;改为向上
	dec byte[x]
	jmp show
	
down:
    mov al,byte[rdlu]           ;向下 
	cmp al,2
	jnz left
	mov ax,word[x]              ;最后一行?
	cmp ax, 24
	jz d2l
	inc byte[x]
	jmp show
d2l:
    mov byte[rdlu],1           ;改为向右
	inc byte[y]
	jmp show

left:
    mov al,byte[rdlu]           ;向左 
	cmp al,3
	jnz up
	mov ax,word[y]              ;最左一列?
	cmp ax,0 
	jz l2u
	dec byte[y]
	jmp show
l2u:
    mov byte[rdlu],2           ;改为向下
	inc byte[x]
	jmp show
	
up:
    mov al,byte[rdlu]           ;向上 
	cmp al,4
	jnz end
	mov ax,word[x]              ;最上一行?
	cmp ax,13
	jz u2r
	dec byte[x]
	jmp show
u2r:
    mov byte[rdlu],3            ;改为向左
	dec byte[y]
	mov al,byte[char]
	cmp al,'Z'
	jz returntoa
	inc byte[char]
	jmp show
	
returntoa:
    mov byte[char],'A' 
	jmp show

show:	
    xor ax,ax                      ; 计算当前字符的显存地址 gs:((80*x+y)*2)
    mov ax,word[x]
	mov bx,80                  ; (80*x
	mul bx
	add ax,word[y]             ; (80*x+y)
	mov bx,2
	mul bx                     ; ((80*x+y)*2)
	mov bp,ax
	mov ah,0ch		   ; 0000：黑底、1111：亮白字（默认值为07h）
	mov al,byte[char]	   ; AL = 显示字符值（默认值为20h=空格符）
	mov word[gs:bp],ax  	   ;   显示字符的ASCII码值

	
end:
	ret


    jmp $	
	
	;times 512-($-$$) db 0 ; $=当前地址、$$=当前节地址
; 写入启动扇区的结束标志
	;db 55h,0aah

	
;********************************************************************************************************
;*  修改一: 本程序画框是顺时针的,请把方向改为逆时间
;*  修改二: 本程序画框重复画最大的框,请改为先画最大的框,之后在所画的框内画最大的框,如此反复,直到画满屏幕
;*
;********************************************************************************************************
