;演示程序 3
Init: ;程序初始化
    delayTime equ 4000  ;定义 delayTime 代表 50
	org 7e00h  ;程序装载到 7c00h
	call Clear
	mov ax,cs ;用 cs 中的值初始化 ds 和 es 寄存器
	mov ds,ax
	mov es, ax
	jmp main

main: ;可视为主函数
	mov ax,24  ;置 ax 为立即数 24 
	cmp ax,word[y]  ;比较 y 是否等于 24 ，即比较字符是否到达底端
	je DownToUp   ;如果 ZF 标志位为 1，即上述比较结果为相等，则跳转到 DownToUp 位置
	mov ax,0  ;在 ax 中放 0
	cmp ax,word[y] ;比较 y 是否为 0 ，判断字符是否到达屏幕顶端
	je UptoDown  ;上述条件成立则跳转至 UptoDown
	mov ax,79  ;把 ax 置为 79 ，即为屏幕最右端
	cmp ax,word[x] ;比较 x 是否为 79 ，即比较字符是否到达最右端
	je RightToLeft  ;如果上述条件成立则跳转至 RightToLeft
	mov ax,0 ;在 ax 中置 0 
	cmp ax,word[x]  ;比较 x 是否为 0 ，即比较字符是否到达最左端
	je LeftToRight ;如果上述条件成立则跳转到 LeftToRight
	jmp Usual  ;如果上述四个边界条件都没有触发则执行 Usual 的代码段，正常地进行显示

Usual: ;在没有触发边界时执行的代码块
	mov ax,0  ;ax 置零
	cmp ax,word[statey]  ;比较 statey 是否为 0 ,即此时状态是否向下
	je Down ;相等时跳转到 Down ，向下运动
	jmp Up  ;上一个语句没有跳转，则直接则跳到 Up ，向上运动

DownToUp: ;触底反弹
	mov word[statey],1  ;statey 置为 1，状态改为向上运动
    cmp byte[x],0 ;是否到达左下角
	je LeftToRight
	cmp byte[x],79 ;是否到达右下角
	je RightToLeft
	jmp Up  ;无条件跳转至 Up

UptoDown: ;触顶反弹
	mov word[statey],0  ;把 statey 置 0 ，状态变成向下
    cmp byte[x],0 ;是否到达左上角
	je LeftToRight
	cmp byte[x],79  ;是否到达右上角
	je RightToLeft
	jmp Down ;无条件跳转至 Down

RightToLeft:  ;在最右反弹
	mov word[statex],1 ;将 statex 置 1 ，状态改为向左
	mov ax,0  ;把 ax 置 0
	cmp ax,word[statey] ;判断 statey 是否为 0 ，0 则向下运动
	je Down ;是则跳转到 Down ，向下
	jmp Up ;否则跳转到 Up ，向上

LeftToRight:  ;在最左反弹
	mov word[statex],0  ;将 statex 置 0 ，状态改为向右
	mov ax,0 ;将 ax 置 0
	cmp ax,word[statey] ;判断 statey 是否为 0 ，0 为向下
	je Down ;是则跳转到 Down
	jmp Up ;否则跳转到 Up

Up:  ;向上运动
	dec word[y] ;y-- ，把纵坐标减 1，向上
	mov ax,0  ;ax 置 0
	cmp ax,word[statex] ;判断 statex 是否为 0 ，0 为向右
	je R  ;是的话跳转到 R
	jmp L ;不是的话跳转到 L

Down:  ;向下运动
	inc word[y]  ;y++，把纵坐标加 1 ，向下
	mov ax,0 ;置 ax 为 0
	cmp ax,word[statex] ;判断 statex 是否为 0 ，0 为向右
	je R  ;是的话跳转到 R
	jmp L ;不是的话跳转到 L

R:  ;向右运动
	inc word[x] ; x++，横坐标加 1，向右
	jmp Show  ;跳转至 Show 代码段

L: ;向左运动
	dec word[x] ;x--，横坐标减 1，向左
	jmp Show  ;跳转至 Show 代码段

Show:  ;显示字符
    inc word[num]
	mov ax,word[num]
	cmp ax,150
	je quit
	mov ax,0b800h  ;置 ax 为彩色显存起始地址 0b800h
	mov gs,ax   ;把 ax 的值加载到 es，作为存放字符的基址
	mov ax,160  ;置 ax 为160，根据屏幕 80x24 可得出偏移量 bx = 2(80*y + x)
	mul word[y] ;计算 160*y ，结果放在 ax 中
	mov word[t],ax  ;把 ax 的值放到 t 
	mov ax,word[x]  ;把 x 放到 ax
	add ax,ax  ;ax *= 2
	add ax,word[t] ;把 t 和 ax 相加放到 ax 中，完成 t = 160*y + x*2
	mov bx,ax  ;置 bx 等于 ax ，即为 t
	mov al,'A'  ;在 al 中放字符 'A'
	mov ah,0ch  ;在 ah 中放 0ch，表示黑底红字
	mov [gs:bx],ax  ;把 ax 的值放到 [es:bx] （基址+偏移量） 处，字符完成显示
	mov cx,delayTime ;初始化 cx 为 5000
	jmp delay  ;跳转到 delay ，进行延迟


Clear: ;清屏
    MOV AX,0003H
    INT 10H
	ret

quit:
    ret

delay: ;双重循环进行延迟，延迟时间为 5000*5000
	mov word[t],cx   ;把 cx 的值保存到 t 中
	mov cx,delayTime   ;置 cx 为 delayTime 的值（500）
	loop1:loop loop1    ;每执行一次循环 cx 值减 1,直到 cx = 0，循环为在当前语句跳转，用于延迟
	mov cx,word[t]  ;把 t 的值放回 cx ，恢复 cx
	loop delay   ;执行循环，跳转到 delay 处，每执行一次循环 cx 值减 1,直到 cx = 0
	jmp main  ;无条件跳转至 main ，继续执行

data:  ;数据声明部分
	x dw -1 ;声明变量 x ,并初始化 x 为 -1
	y dw -1 ;声明变量 y ，并初始化 y 为 -1
	t dw 0 ;声明变量 t ，并初始化 t 为 0
	num dw 0
	statey dw 0 ;声明变量 statey ,初始状态为向下，0 向下 1 向上  
	statex dw 0  ;声明变量 statex ,初始状态为向右，0 向右 1 向左 
	times 512-($-$$) db 0 ; 用0填充扇区的剩余部分（$$=当前节地址）
