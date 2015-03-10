
;变量
BaseOfLoader	    	equ	1000h	    ; 根目录 被加载到的位置 ----  段地址
OffsetOfLoader	        equ	4000h	    ; 根目录 被加载到的位置 ---- 偏移地址
RootDirSectors	        equ	14		    ; 根目录占用的扇区数
SectorNoOfRootDirectory	equ	19	        ; 根目录区的首扇区号
SectorNoOfFAT1	        equ	1		    ; FAT#1的首扇区号 = BPB_RsvdSecCnt
DeltaSectorNo		    equ	17		    ; DeltaSectorNo = BPB_RsvdSecCnt + 
							            ; (BPB_NumFATs * FATSz) - 2 = 1 + (2*9) -2 = 17
					            		; 文件的开始扇区号 = 目录条目中的开始扇区号 
						            	; + 根目录占用扇区数目 + DeltaSectorNo

wRootDirSizeForLoop	    dw	RootDirSectors	; 根目录区剩余扇区数
										; 初始化为14，在循环中会递减至零
wSectorNo	         	dw	0           ; 当前扇区号，初始化为0，在循环中会递增
bOdd         			db	0          	; 奇数还是偶数FAT项
filename                dw  0           ; 文件名指针
baseAddress             dw  0           ; 文件加载段地址
offsetAddress           dw  0           ; 文件加载偏移地址

BPB_BytsPerSec       	dw 512          ; 每扇区字节数
BPB_SecPerTrk	        dw 18	        ; 每磁道扇区数
BS_DrvNum		        db 0	        ; 中断 13 的驱动器号（软盘

;==============================================================

; ****************************************
;   void _loadFile(char* filename,int baseAddress,int offsetAddress);
; ; ****************************************
; 加载程序到内存
public _loadFile
_loadFile proc
    push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
    push es
	push si
	push di

	mov ax,[bp+4]                     ; 把传递进来的文件名指针放到 filename
	mov word ptr[filename],ax
	mov ax,[bp+6]
	mov word ptr[baseAddress],ax      ; 把传递进来的基地址放到 baseAddress
	mov ax,[bp+8]
	mov word ptr[offsetAddress],ax    ; 把传递进来的偏移地址放到 offsetAddress

; 软驱复位
	xor	ah, ah                        ; 功能号ah=0（复位磁盘驱动器）
	xor	dl, dl                        ; dl=0（软驱，硬盘和U盘为80h）
	int	13h		                      ; 磁盘中断
	
; 下面在A盘根目录中寻找 LOADER.BIN
	mov	word ptr [wSectorNo], SectorNoOfRootDirectory 	; 给表示当前扇区号的变量wSectorNo赋初值为根目录区的首扇区号（=19）

LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word ptr [wRootDirSizeForLoop], 0	; 判断根目录区是否已读完
	jz	LABEL_NO_LOADERBIN	             	; 若读完则表示未找到LOADER.BIN
	dec	word ptr [wRootDirSizeForLoop]	    ; 递减变量wRootDirSizeForLoop的值
	; 调用读扇区函数读入一个根目录扇区到装载区
	mov	ax, BaseOfLoader
	mov	es, ax			                    ; ES <- BaseOfLoader
	mov	bx, OffsetOfLoader	                ; BX <- OffsetOfLoader
	mov	ax, word ptr [wSectorNo]	        ; AX <- 根目录中的当前扇区号
	mov	cl, 1				                ; 只读一个扇区
	call	ReadSector		                ; 调用读扇区函数

	mov	ax,word ptr[filename]	            ; DS:SI -> "LOADER  BIN"
	mov si,ax
	mov	di, OffsetOfLoader	                ; ES:DI -> BaseOfLoader:0100
	cld					                    ; 清除DF标志位
						                    ; 置比较字符串时的方向为左/上[索引增加]
	mov	dx, 10h			                    ; 循环次数=16（每个扇区有16个文件条目：512/32=16）
LABEL_SEARCH_FOR_LOADERBIN:
	cmp	dx, 0			                    ; 循环次数控制
	jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR   ; 若已读完一扇区
	dec	dx				                    ; 递减循环次数值，跳到下一扇区
	mov	cx, 11			                    ; 初始循环次数为11，为文件名字节数
LABEL_CMP_FILENAME:
	repe cmpsb			                    ; 重复比较字符串中的字符，CX--，直到不相等或CX=0
	cmp	cx, 0
	jz	LABEL_FILENAME_FOUND	            ; 如果比较了11个字符都相等，表示找到
LABEL_DIFFERENT:
	and	di, 0FFE0h		                    ; DI &= E0为了让它指向本条目开头（低5位清零）
					                        ; FFE0h = 1111111111100000（低5位=32=目录条目大小）
	add	di, 20h		                    	; DI += 20h 下一个目录条目
	mov	ax,word ptr [filename]          	; SI指向装载文件名串的起始地址
	mov si,ax
	jmp	LABEL_SEARCH_FOR_LOADERBIN          ; 转到循环开始处

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word ptr [wSectorNo], 1             ; 递增当前扇区号
	jmp	LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
    call _loadErrorMsg                       ; 打印错误信息
    pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
    ret                                       ; 没有找到 文件，在这里返回

LABEL_FILENAME_FOUND:	                      ; 找到 文件 后便来到这里继续
	; 计算文件的起始扇区号
	mov	ax, RootDirSectors	                  ; AX=根目录占用的扇区数
	and	di, 0FFE0h	                          ; DI -> 当前条目的开始地址
	add	di, 1Ah			                      ; DI -> 文件的首扇区号在条目中的偏移地址
	mov cx, word ptr es:[di]	              ; CX=文件的首扇区号
	push cx				                      ; 保存此扇区在FAT中的序号
	add	cx, ax			                      ; CX=文件的相对起始扇区号+根目录占用的扇区数
	add	cx, DeltaSectorNo	                  ; CL <- LOADER.BIN的起始扇区号(0-based)
	mov ax,word ptr[baseAddress]              ; 取基地址
	mov	es, ax			                      ; ES <- BaseOfLoader（装载程序基址=9000h）
	mov bx,word ptr[offsetAddress]            ; 取偏移地址
	mov	ax, cx		                          ; AX <- 起始扇区号

LABEL_GOON_LOADING_FILE:
	push bx				                      ; 保存装载程序偏移地址
	mov	cl, 2				                  ; 2个扇区
	call	ReadSector		                  ; 读扇区


	; 计算文件的下一扇区号
	pop bx				                      ; 取出装载程序偏移地址
	pop	ax				                      ; 取出此扇区在FAT中的序号
	call GetFATEntry		                  ; 获取FAT项中的下一簇号
	cmp	ax, 0FF8h		                      ; 是否是文件最后簇
	jae	LABEL_FILE_LOADED                     ; ≥FF8h时跳转，否则读下一个簇
	push ax				                      ; 保存扇区在FAT中的序号
	mov	dx, RootDirSectors	                  ; DX = 根目录扇区数 = 14
	add	ax, dx			                      ; 扇区序号 + 根目录扇区数
	add	ax, DeltaSectorNo		              ; AX = 要读的数据扇区地址
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512指向装载程序区的下一个扇区地址
	jmp	LABEL_GOON_LOADING_FILE
	
LABEL_FILE_LOADED:                            ; 完成加载
	pop di
	pop si
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret

_loadFile endp

;----------------------------------------------------------------------------
; 函数名：ReadSector
;----------------------------------------------------------------------------
; 作用：从第 AX个扇区开始，将CL个扇区读入ES:BX中
ReadSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号->柱面号、起始扇区、磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                           ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	;   -------------- 	=> ┤      └ 磁头号 = y & 1
	;  每磁道扇区数     │
	;                   └ 余 z => 起始扇区号 = z + 1
	push bp		                    ; 保存BP
	mov bp, sp	                    ; 让BP=SP
	sub	sp, 2 	                    ; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]
	push ax
	push bx
	push cx
	push dx
	mov	byte [bp-2], cl	            ; 压CL入栈（保存表示读入扇区数的传递参数）
	push bx			                ; 保存BX
	mov	bl, byte ptr [BPB_SecPerTrk]; BL=18（磁道扇区数）为除数
	div	bl			                ; AX/BL，商y在AL中、余数z在AH中
	inc	ah	                		; z ++（因磁盘的起始扇区号为1）
	mov	cl, ah	                	; CL <- 起始扇区号
	mov	dh, al	                	; DH <- y
	shr	al, 1		                ; y >> 1 （等价于y/BPB_NumHeads，软盘有2个磁头）
	mov	ch, al	                	; CH <- 柱面号
	and	dh, 1	                	; DH & 1 = 磁头号
	pop	bx		                	; 恢复BX
	; 至此，"柱面号、起始扇区、磁头号"已全部得到
	mov	dl, byte ptr [BS_DrvNum]	; 驱动器号（0表示软盘A）
.GoOnReading: ; 使用磁盘中断读入扇区
	mov	ah, 2			        	; 功能号（读扇区）
	mov	al, byte [bp-2]		        ; 读AL个扇区
	int	13h			             	; 磁盘中断
	jc	.GoOnReading                ; 如果读取错误，CF会被置为1，
					              	; 这时就不停地读，直到正确为止
	pop dx 
	pop cx
	pop BX
	pop ax
	add	sp, 2				        ; 栈指针+2
	pop	bp				            ; 恢复BP

	ret
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; 函数名：GetFATEntry
;----------------------------------------------------------------------------
; 作用：找到序号为AX的扇区在FAT中的条目，结果放在AX中。需要注意的
;     是，中间需要读FAT的扇区到ES:BX处，所以函数一开始保存了ES和BX
GetFATEntry:
	push es			             ; 保存ES、BX和AX（入栈）
	push bp
	push ax
; 设置读入的FAT扇区写入的基地址
	mov ax,word ptr[baseAddress]
	sub	ax, 100h	          	; 在BaseOfLoader后面留出4K空间用于存放FAT
	mov	es, ax		            ; ES=8F00h
; 判断FAT项的奇偶
	pop	ax	            		; 取出FAT项序号（出栈）
	mov	byte ptr [bOdd], 0 ; 初始化奇偶变量值为0（偶）
	mov	bx, 3            		; AX*1.5 = (AX*3)/2
	mul	bx		            	; DX:AX = AX * 3（AX*BX 的结果值放入DX:AX中）
	mov	bx, 2	            	; BX = 2（除数）
	xor	dx, dx	            	; DX=0	
	div	bx		            	; DX:AX / 2 => AX <- 商、DX <- 余数
	cmp	dx, 0	            	; 余数 = 0（偶数）？
	jz LABEL_EVEN            	; 偶数跳转
	mov	byte ptr [bOdd], 1    	; 奇数
LABEL_EVEN:	                	; 偶数
	; 现在AX中是FAT项在FAT中的偏移量，下面来
	; 计算FAT项在哪个扇区中(FAT占用不止一个扇区)
	xor	dx, dx	            	; DX=0	
	mov	bx, [BPB_BytsPerSec]	; BX=512
	div	bx		            	; DX:AX / 512
		  		            	; AX <- 商 (FAT项所在的扇区相对于FAT的扇区号)
		  		            	; DX <- 余数 (FAT项在扇区内的偏移)
	push dx		            	; 保存余数（入栈）
	mov bx, 0 	            	; BX <- 0 于是，ES:BX = 8F00h:0
	add	ax, SectorNoOfFAT1      ; 此句之后的AX就是FAT项所在的扇区号
	mov	cl, 2			        ; 读取FAT项所在的扇区，一次读两个，避免在边界
	call ReadSector            	; 发生错误, 因为一个 FAT项可能跨越两个扇区
	pop	dx		            	; DX= FAT项在扇区内的偏移（出栈）
	add	bx, dx	            	; BX= FAT项在扇区内的偏移
	mov bp,bx
	mov	ax, word ptr es:[bx]	; AX= FAT项值
	cmp	byte ptr [bOdd], 1	    ; 是否为奇数项？
	jnz	LABEL_EVEN_2         	; 偶数跳转
	shr	ax, 4			        ; 奇数：右移4位（取高12位）
LABEL_EVEN_2:	            	; 偶数
	and	ax, 0FFFh            	; 取低12位
LABEL_GET_FAT_ENRY_OK:
    pop bp
	pop	ax		            	; 恢复ES、BX（出栈）
	mov es,ax
	ret
