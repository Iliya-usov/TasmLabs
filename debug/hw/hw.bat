	.model tiny
	.386
	.code
	org 100h
_:
	jmp start
mes	db "Hello, World!",13,10,'$'

start:
	lea dx, mes
	mov ah, 09h
	int 21h

	ret

end _