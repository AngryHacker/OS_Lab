	org  7c00h					; 加载到 0:7C00 处
	jmp short LABEL_START		; 跳转到代码起始处
	nop							; 这个nop（无操作指令）不可少（占位字节）

	; 下面是 FAT12 磁盘的头（BPB+EBPB，占51B）
	BS_OEMName	DB 'MyOS 1.0' ; OEM String, 必须 8 个字节（不足补空格）
	BPB_BytsPerSec	DW 512		; 每扇区字节数
	BPB_SecPerClus	DB 1		; 每簇多少扇区
	BPB_RsvdSecCnt	DW 1		; Boot记录占用多少扇区
	BPB_NumFATs	DB 2		; 共有多少 FAT 表
	BPB_RootEntCnt	DW 224		; 根目录文件数最大值
	BPB_TotSec16	DW 2880		; 逻辑扇区总数
	BPB_Media		DB 0xF0		; 介质描述符
	BPB_FATSz16	DW 9		; 每FAT扇区数
	BPB_SecPerTrk	DW 18		; 每磁道扇区数
	BPB_NumHeads	DW 2		; 磁头数(面数)
	BPB_HiddSec		DD 0		; 隐藏扇区数
	BPB_TotSec32	DD 0		; BPB_TotSec16为0时这个值记录扇区数
	BS_DrvNum		DB 0		; 中断 13h 的驱动器号
	BS_Reserved1		DB 0		; 未使用
	BS_BootSig		DB 29h		; 扩展引导标记 (29h)
	BS_VolID		DD 12345678h; 卷序列号
	BS_VolLab		DB 'MyOS System'; 卷标, 必须 11 个字节（不足补空格）
	BS_FileSysType	DB 'FAT12   '	; 文件系统类型, 必须 8个字节（不足补空格）  

LABEL_START:
	mov	ax, cs		; 置DS和ES=CS
	mov	ds, ax
	mov	es, ax
	call	ScrollPg		; 向上滚动显示页
	call	DispStr		; 调用显示字符串例程
	jmp	$			; 无限循环

ScrollPg: ; 清屏例程
	mov	ah, 6			; 功能号
	mov	al, 0			; 滚动的文本行数（0=整个窗口）
	mov bh,0fh		; 设置插入空行的字符颜色为黑底亮白字
	mov cx, 0			; 窗口左上角的行号=CH、列号=CL
	mov dh, 24		; 窗口右下角的行号
	mov dl, 79		; 窗口右下角的列号
	int 10h			; 显示中断
	ret
	
DispStr:
	mov ah,13h 		; BIOS中断的功能号（显示字符串）
	mov al,1 			; 光标放到串尾
	mov bh,0 		; 页号=0
	mov bl,0ch 		; 字符颜色=黑底亮红字
	mov cx,16 		; 串长=16
	mov dx,0 		; 显示串的起始位置（0，0）：DH=行号、DL=列号
	mov bp,BootMsg	; ES:BP=串地址
	int 10h 			; 调用10H号显示中断
	ret				; 从例程返回

BootMsg:  
    db  "Hello, OS world!" ; 显示用字符串
	times 510-($-$$) db 0	; 用0填充剩下的扇区空间（软盘无分区表）
	db 	55h, 0aah			; 引导扇区结束标志

; 填充两个FAT表的头两个项（每个FAT占9个扇区）
	db 0f0h, 0ffh, 0ffh			; 介质描述符（F0h）和Fh、结束簇标志项FFFh
	times 512*9-3		db	0	; 用0填充FAT#1剩下的空间
	db 0f0h, 0ffh, 0ffh			; 介质描述符（F0h）和Fh、结束簇标志项FFFh
	times 512*9-3		db	0	; 用0填充FAT#2剩下的空间
; 根目录中的卷标条目
	db 'MyOS System' 			; 卷标, 必须 11 个字节（不足补空格）
	db 8						; 文件属性值（卷标条目的为08h）
	dw 0,0,0,0,0				; 10个保留字节
	dw 0,426Eh				; 创建时间，设为2013年3月14日0时0分0秒
	dw 0						; 开始簇号（卷标条目的必需为0）
	dd 0						; 文件大小（也设为0）


