;
;   本文件为引导程序的源码文件。
;
   org  7c00h	            ; BIOS将把引导扇区加载到0:7C00h处，并开始执行
START:
	mov ax,cs               ; 用 cs 的值初始化 ds,es
	mov ds,ax
	mov es,ax

	call ReadOS             ; 装载操作系统
	call dword 9000h;       ; 跳转到操作系统的执行

ReadOS:  ; 读入软盘第2和第3个扇区到7E00H处
	xor ax,ax 		        ; 相当于mov ax,0
	mov es,ax 		        ; ES=0
	mov bx,9000H            ; ES:BX=读入数据到内存中的存储地址
	mov ah,2 		        ; 功能号
	mov al,2 		        ; 要读入的扇区数
	mov dl,0 		        ; 软盘驱动器号（对硬盘和U盘，此处的值应改为80H）
	mov dh,0 		        ; 磁头号
	mov ch,0 		        ; 柱面号
	mov cl,2 		        ; 起始扇区号（编号从1开始）
	int 13H 		        ; 调用13H号中断
	ret 			        ; 从例程返回

	times 510-($-$$)  db 0	; 用0填充引导扇区剩下的空间
	db 	55h, 0aah			; 引导扇区结束标志
