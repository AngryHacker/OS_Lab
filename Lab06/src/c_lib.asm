; 用于生成库文件
.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
start:

;*************** ********************
;*  void _to_OUCH()                       *
;**************** *******************
; 调用 21h 0号功能
public _to_OUCH
_to_OUCH proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call Clear

	mov ah,0
    int 21h

	call DelaySome
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_to_OUCH endp

;*************** ********************
;*  void _upper()                       *
;**************** *******************
; 调用 21h 1号功能 
public _upper
_upper proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得字符串首地址

    push ax
    push bx
    push cx
    push dx
	push es

	mov ah,1
	mov dx,si                        ; 把字符串首地址给 dx 
    int 21h
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax

	pop si
	pop bp
	ret
_upper endp

;*************** ********************
;*  void _lower()                       *
;**************** *******************
; 调用 21h 2号功能 
public _lower
_lower proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得字符串首地址

    push ax
    push bx
    push cx
    push dx
	push es

	mov ah,2
	mov dx,si                        ; 把字符串首地址给 dx 
    int 21h
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax

	pop si
	pop bp
	ret
_lower endp

;*************** ********************
;*  void _digital()                       *
;**************** *******************
; 调用 21h 3号功能 
public _digital
_digital proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得字符串首地址

    push bx
    push cx
    push dx
	push es

	mov ah,3
	mov dx,si                        ; 把字符串首地址给 dx 
    int 21h

	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx

	pop si
	pop bp
	ret
_digital endp

;*************** ********************
;*  void _convertToString()                       *
;**************** *******************
; 调用 21h 4号功能 
public _convertToString
_convertToString proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得传递进来的整数

    push bx
    push cx
    push dx
	push es

	mov ah,4
	mov bx,si                        ; 把整数给 dx 
    int 21h

	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx

	pop si
	pop bp
	ret
_convertToString endp

;*************** ********************
;*  void _display()                       *
;**************** *******************
; 调用 21h 5号功能 
public _display
_display proc 
    push bp
	mov	bp,sp
	push si

    push bx
    push cx
    push dx
	push es

	call Clear

	mov	bx,word ptr [bp+4]           ; 获得行号
	mov ax,word ptr [bp+6]           ; 获得列号
	mov si,word ptr [bp+8]           ; 获得字符串首地址


	mov ah,5
	mov dx,si                        ; dx 放字符串地址
	mov ch,bl                        ; ch 放行号
	mov cl,al                        ; cl 放列号
    int 21h

	call DelaySome
	call Clear

	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx

	pop si
	pop bp
	ret
_display  endp

;*************** ********************
;*  void _convertHexToDec()                       *
;**************** *******************
; 调用 21h 6号功能 
public _convertHexToDec
_convertHexToDec  proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得字符串首地址

    push bx
    push cx
    push dx
	push es

	mov ah,6
	mov dx,si                        ; dx 放字符串地址
    int 21h

	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx

	pop si
	pop bp
	ret
_convertHexToDec endp

;*************** ********************
;*  void _reverse()                       *
;**************** *******************
; 调用 21h 7号功能 
public _reverse
_reverse proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得字符串首地址

    push bx
    push cx
    push dx
	push es


	mov ah,7
	mov dx,si                        ; dx 放字符串地址
	mov cx,word ptr[bp+6]            ; cx 放字符串长度
    int 21h

	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx

	pop si
	pop bp
	ret
_reverse endp

;*************** ********************
;*  void _strlen()                       *
;**************** *******************
; 调用 21h 8号功能 
public _strlen
_strlen proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; 获得字符串首地址

    push bx
    push cx
    push dx
	push es

	mov ah,8
	mov dx,si                        ; dx 放字符串地址
    int 21h

	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx

	pop si
	pop bp
	ret
_strlen endp

 
;*************** ********************
;*  DelaySome                       *
;**************** *******************
; 延迟
DelaySome:                          ; 延迟一段时间
    mov cx,delayTime      
toDelay:
	mov word ptr es:[t],cx          ; 把 cx 的值保存到 t 中
	mov cx,delayTime
	loop1:loop loop1 
	mov cx,word ptr es:[t]          ; 把 t 的值放回 cx ，恢复 cx
	loop toDelay
	ret

Clear: ;清屏
    MOV AX,0003H
    INT 10H
	ret

	delayTime equ 40000
	t dw 0

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start
