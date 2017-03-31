;	goto build
	.model tiny
	.386
	.code
	org 100h

_:
	jmp start
code	db "__ _", 10, 13, '$'

start:
	mov ax, 0
	int 16h
	cmp ah, 01h
	jz exit

	call print
	jmp start

exit:
	ret

print:	
	push ax

	lea di, code
	xchg ah, al
	call save_byte

	pop ax
	
	inc di
	stosb

	lea dx, code
	mov ah, 09h
	int 21h
	ret

save_byte:
 	push ax  

 	shr al, 4
 	call save_digit
 	
 	pop ax
 	call save_digit
 	ret

 save_digit:
 	and al, 0fh

 	cmp al, 10
 	sbb al, 69h
 	das

 	stosb
 	ret

end _
;	:build
;	tasm /m int16.bat
;	tllink /x/t int16
