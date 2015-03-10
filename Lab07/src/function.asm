;**************************************************
;* 内核库过程版本信息                             *
;**************************************************
;*********** C 中导入的外部函数 ******************
; 主函数
extrn  _cmain:near
; 转化大写，21h 使用
extrn  _to_upper:near
; 转化小写，21h 使用
extrn  _to_lower:near
; 数字字符串转为数值，21h 使用
extrn  _to_digit:near
; 把时间转为字符串
extrn  _timeToString:near
; 数值转为数字字符串，21h 使用
extrn  _digit_to_str:near
; 保存进程控制块信息
extrn _SavePCB:near
; 得到当前进程的指针
extrn _getCurrentPCB:near
; 创建新的进程
extrn _createNewPCB:near
; 进程调度函数
extrn _Schedule:near
; 创建子进程
extrn _do_fork:near
; 进程等待
extrn _do_wait:near
; 进程结束
extrn _do_exit:near

;*********** C 中导入的外部函数 ******************
extrn _t:near
extrn _ch1:near
extrn _ch2:near
extrn _ch3:near
extrn _ch4:near
extrn _p:near
; 当前进程是否是第一次运行的标志
extrn _tinyFlag:near
; 当前进程的编号
extrn _current_PCB:near
; 进程数量
extrn _processNum:near
; 标志当前是用户态还是内核态
extrn _kernal_mode:near

;*********** C 中导入的外部函数 ******************
; 用户程序执行的返回时间
time_to_back dw 0

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

; ****************************************
;      void runProcess(int seg, int start,int num)
; ; ****************************************
; 将 start 开始的 num 个扇区放到段地址为 seg 的 100h 处
public _runProcess 
_runProcess proc
	push bp
	push ax
	mov bp, sp  

	mov ax,[bp+6]               ; 段地址
	mov es,ax                   ; 设置段地址
	mov bx,100h                 ; 段间偏移地址
	mov ah,2                    ; 功能号
	mov al,[bp+10]              ; 扇区数 
	mov dl,0                    ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,1                    ; 磁头号，起始编号为0，磁盘的第几面（0 或 1）
	mov ch,0                    ; 柱面号， 起始编号为0，磁盘的第几道
	mov cl,[bp+8]               ; 起始扇区号，起始编号为1
	int 13H 				    ; BIOS的13h功能调用

	call _createNewPCB          ; 将前面内存位置的程序创建新的进程

	mov sp, bp
	pop ax
	pop bp
	ret
_runProcess endp

; ****************************************
;  void setTimer()
; ****************************************
;	设置计时器函数，每秒20次中断
public _setTimer
_setTimer proc
	push ax
	mov al, 34h                 ; 设置控制字值
	out 43h,al                  ; 写控制字到控制字寄存器
	mov ax,23863                ; 1193182/59660=20次
	out 40h, al
	mov al, ah
	out 40h,al
	pop ax
	ret
_setTimer endp

; ****************************************
;  void setMyClock()
; ****************************************
; 安装时钟中断
public _startClock 
_startClock proc
	push ax
	push es

	call near ptr _setTimer

	xor ax,ax				        		        ; AX = 0
	mov es,ax					                    ; ES = 0
	mov ax,offset Timer
	mov word ptr es:[20h],offset Timer		        ; 设置时钟中断向量的偏移地址
	mov ax,cs 
	mov word ptr es:[22h],cs	                    ; 设置时钟中断向量的段地址=CS

	pop ax
	mov es,ax
	pop ax
	ret

_startClock endp

;*************** ********************
;*  时钟中断程序
;**************** *******************
Timer:
	cmp word ptr[_kernal_mode],1                    ; 判断当前是用户态还是内核态
	jnz Process_Timer                               ; 执行用户时钟中断
	jmp Kernal_Timer                                ; 执行内核时钟中断

Process_Timer:
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

	cmp word ptr [time_to_back],800                 ; 判断用户程序是否到达退出时间
	jnz Timer_Go_On                                 ; 否则继续
	mov word ptr [_current_PCB],0                   ; 若应该退出则将当前进程要恢复的进程号指定为操作系统进程
	mov word ptr [_kernal_mode],1                   ; 并置内核态
	call _PCB_Restore                                 ; 开始恢复进程
	
Timer_Go_On:
	inc word ptr [time_to_back]                     ; 递增用户程序执行的时间

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SavePCB                                   ; 开始保存进程控制块
	
	call _Schedule                                  ; 进程调度

	call _PCB_Restore                               ; 重新启动进程

	iret

public _PCB_Restore
_PCB_Restore proc
	mov ax, cs
	mov ds, ax
	call _getCurrentPCB                             ; 得到当前进程控制块的起始地址
	mov si, ax

	mov ss,word ptr ds:[si+0]                       ; 恢复 ss 寄存器
	mov sp,word ptr ds:[si+2*8]                     ; 恢复 sp

	cmp word ptr [_tinyFlag],1                      ; 进程是否第一次执行
	jnz Timer_NEXT                                  ; 跳过平衡堆栈的操作
	mov word ptr [_tinyFlag],0                      ; 置 0
	jmp PCB_Restart
Timer_NEXT:
	add sp, 11*2                                    ; 平衡堆栈，恢复进入时间中断前栈顶
	jmp PCB_Restart

PCB_Restart:
	push word ptr ds:[si+2*15]                      ; 恢复 fl
	push word ptr ds:[si+2*14]                      ; 恢复 cs
	push word ptr ds:[si+2*13]	                    ; 恢复 ip  按此顺序压栈，模拟中断进入操作
	
	mov ax,word ptr ds:[si+2*12]                    ; 恢复 ax
	mov cx,word ptr ds:[si+2*11]                    ; 恢复 cx
	mov dx,word ptr ds:[si+2*10]                    ; 恢复 dx
	mov bx,word ptr ds:[si+2*9]                     ; 恢复 bx
	mov bp,word ptr ds:[si+2*7]                     ; 恢复 bp
	mov di,word ptr ds:[si+2*5]                     ; 恢复 di
	mov es,word ptr ds:[si+2*3]                     ; 恢复 es
	.386
	mov fs,word ptr ds:[si+2*2]                     ; 恢复 fs
	mov gs,word ptr ds:[si+2*1]                     ; 恢复 gs
	.8086
	push word ptr ds:[si+2*6]                       ; push si ( ds 和 si 不可直接 mov)
	push word ptr ds:[si+2*4]                       ; push ds
	pop ds                                          ; 恢复 ds
	pop si                                          ; 恢复 si

Process_Timer_End:                                  ; 结束用户态中断
	push ax         
	mov al,20h                                      ; 发送中断处理结束消息给中断控制器
	out 20h,al                                      ; 发送EOI到主8529A
	out 0A0h,al                                     ; 发送EOI到从8529A
	pop ax
	iret
endp _PCB_Restore

Kernal_Timer:                                       ; 内核时钟中断
    push ax
	push bx
	push cx
	push dx
	push bp
    push es
	
    dec byte ptr es:[count]				            ; 递减计数变量
	jnz Kernal_Timer_End						    ; >0：跳转
	inc byte ptr es:[bn]                            ; 自增变量 bn
	cmp byte ptr es:[bn],1                          ; 根据 bn 选择跳转地址，1 则显示 /
	jz ch1
	cmp byte ptr es:[bn],2                          ; 2 则显示 |
	jz ch2
	cmp byte ptr es:[bn],3                          ; 3 则显示 \
	jz ch3
	jmp Kernal_Timer_Show
ch1:
    mov bl,'/'
	jmp Kernal_Timer_Show
ch2:
    mov bl,'|'
	jmp Kernal_Timer_Show
ch3:
	mov byte ptr es:[bn],0
    mov bl,'\'
	jmp Kernal_Timer_Show

Kernal_Timer_Show:
    .386
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	gs,ax					; GS = B800h
	mov ah,0eh
	mov al,bl
	mov word[gs:((80 * 24 + 78) * 2)], ax    
	.8086
	mov byte ptr es:[count],10

Kernal_Timer_End:                                   ; 结束内核态中断
	push ax         
	mov al,20h                                      ; 发送中断处理结束消息给中断控制器
	out 20h,al                                      ; 发送EOI到主8529A
	out 0A0h,al                                     ; 发送EOI到从8529A
	pop ax
	
	pop ax                                          ; 恢复寄存器信息
	mov es,ax
	pop bp
	pop dx 
	pop cx
	pop bx
	pop ax

	iret

	count db 10 			     ; 计时器计数变量，初值=delay
	bn db 0

; ****************************************
;   void _stackCopy(int sub_ss,int f_ss, int size);
; ; ****************************************
; 复制内存的数据
public _stackCopy
_stackCopy proc
	push bp
	mov bp, sp
	push ax
	push es
	push ds
	push di
	push si
	push cx

	mov ax,[bp+4]                ; 子进程 ss
	mov es,ax
	mov di, 0
	mov ax, [bp+6]               ; 父进程 ss
	mov ds, ax
	mov si, 0
	mov cx, [bp+8]               ; 栈的大小
	cld
	rep movsw                    ; ds:si->es:di

	pop cx
	pop si
	pop di
	pop ds
	pop es
	pop ax
	pop bp
	ret
_stackCopy endp

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
;*  void _gettime()                       *
;**************** *******************
; 获取时间
public _backspace
_backspace proc 
    push ax
    push bx
    push cx
    push dx		
		
	;读光标位置，(dh,dl) = (行，列)
	mov bh,0
    mov ah,3h
    int 10h

	add dl,-1

    ;设置光标位置(dh,dl) = (行，列)
    mov bh,0
    mov ah,2h
    int 10h

    mov al,' '
	mov bl,1
	mov ah,0eh
	int 10h
	

    ;设置光标位置(dh,dl) = (行，列)
    mov bh,0
    mov ah,2h
    int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_backspace endp


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
;*  键盘中断程序
;**************** *******************
keyDo:
    push ax
    push bx
    push cx
    push dx
	push bp
	push si
	push es

	inc byte ptr es:[c]
	cmp byte ptr es:[c],24
	jnz Key_Continue
	call keyInit

Key_Continue:
	inc byte ptr es:[odd]
	cmp byte ptr es:[odd],1
	je Key_Show
	mov byte ptr es:[odd],0
	jmp Key_Next

Key_Show:
    xor ax,ax                      ; 计算当前字符的显存地址 gs:((80*x+y)*2)
    mov al,byte ptr es:[c]
	mov bx,80
	mul bx
	add ax,25
	mov bx,2
	mul bx  
	mov bp,ax

	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	es,ax					; GS = B800h
	mov ah,0eh
	mov al,'O'
	mov es:[bp], ax    
	add bp,2
	mov al,'U'
	mov es:[bp], ax    
	add bp,2
	mov al,'C'
	mov es:[bp], ax    
	add bp,2
	mov al,'H'
	mov es:[bp], ax    
	
Key_Next:
	in al,60h

	mov al,20h					    ; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					    ; 发送EOI到从8529A
	
	pop ax
	mov es,ax
	pop si
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	iret

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

	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_callBIOS endp

;*************** ********************
;*  void _delay()                       *
;**************** *******************
; 延迟
public _delay
_delay proc 
    push bp
	mov bp,sp
    push cx

    mov cx,word ptr[bp+4]    
delay_Continue:
	mov word ptr es:[t],cx          ; 把 cx 的值保存到 t 中
	mov cx,word ptr [bp+4]
	delay_loop:loop delay_loop
	mov cx,word ptr es:[t]          ; 把 t 的值放回 cx ，恢复 cx
	loop delay_Continue
   
	pop cx
	pop bp
	ret
_delay endp


Clear: ;清屏
    MOV AX,0003H
    INT 10H
	ret

keyInit:                            ; 初始化 OUCH！OUCH！显示的行数为 0 
    mov byte ptr es:[c],0           ; 设置变量 c
	ret

OUCH:
	c db 10
	odd db 1
	t dw 0
