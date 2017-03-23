; goto build
	.model tiny
	.386
	.code
	org 100h
_: 
	jmp start
cc		db 0
int8_old_cs	dw 0
int8_old_ip 	dw 0
symbols		db '\|/-'
int8_handler:
	push ax
	push es
	mov ax, 0b800h
	push bx
	mov es, ax
		movzx bx, [cs:cc]
		inc bx
		and bx, 03h
		mov [cs:cc], bl
		add bx, offset symbols
		mov bl, [cs:bx]
		mov[es:2],bl
	pop bx	
	pop es
	pop ax
	push [cs:int8_old_cs]
	push [cs:int8_old_ip]
	retf
start:
	mov ah, 35h
	mov al, 08h
	int 21h
	mov int8_old_ip, bx
	mov int8_old_cs, es
	lea dx, int8_handler
	mov al, 08h
	mov ah, 25h
	int 21h
	lea dx, start
	int 27h
	ret
end _

; :build
;	tasm /m inttime.bat
;	tlink /x/t inttime