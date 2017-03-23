; goto build
	.model tiny
	.386
	.code
	org 100h

_:
	jmp start
file_name	db '..\hw\hw.com', 0

start_mes	db "Begin", 13, 10, '$'
end_mes		db "End", 13, 10, '$'
error_mes	db "ERROR!!!", 13, 10, '$'

addr 		db "____:____", 13, 10, '$'

handle		dw 0

int1_handler:
	push bp	
	mov bp, sp
	add bp, 2 ;save ptr on ip

	push ds
	push di
	push ax
	push dx

	push cs
	pop ds

	call print_addr

	pop dx
	pop ax
	pop di
	pop ds
	pop bp
	iret

print_addr:
	lea di, addr
	mov ax, [bp + 2]
	call save_hex_word
	inc di
	mov ax, [bp]
	call save_hex_word

	lea dx, addr
	call print_message
	ret

save_hex_word:
	xchg ah, al
	call save_hex_byte

	xchg ah, al
	call save_hex_byte
	ret

save_hex_byte:
	push ax
	shr al, 4
	call save_hex_digit

	pop ax
	call save_hex_digit
	ret

save_hex_digit:
	push ax
	and al, 0fh
	cmp al, 10
	sbb al, 69h
	das
	stosb
	pop ax
	ret

start:
	lea dx, start_mes
	call print_message

	call open_file
	call read_file_into_buffer
	call close_file	

	call set_int1_handler

	call set_after_debug
	call set_addr_for_hw

	call set_tf
	retf

set_int1_handler:
	mov ah, 25h
	mov al, 01h
	lea dx, int1_handler
	int 21h	
	ret

set_addr_for_hw:
	pop dx

	lea ax, psp
	shr ax, 4
	mov bx, ds
	add ax, bx	
	push ax

	push 100h

	push ax
	pop ds 

	push dx
	ret

set_after_debug:
	pop dx

	pushf
	push ds
	lea ax, after_debug
	push ax
	push 0 

	push dx
	ret

set_tf:
	pop dx

	pushf
	pop ax
	or ax, 0100h
	
	push ax 
	push cs  
	push dx 
	iret

read_file_into_buffer:
	mov bx, handle
	mov ah, 3fh
	mov cx, 100h
	lea dx, buffer
	int 21h
	ret

open_file:
	mov ah, 3dh
	mov al, 00h
	lea dx, file_name
	int 21h 		
	
	jc error
	mov handle, ax
	ret

close_file:
	mov ah, 3eh
	mov bx, handle
	int 21h	
	
	jc error
	ret

print_message:
	mov ah, 09h
	int 21h
	ret

after_debug:
	push cs
	pop ds

	lea dx, end_mes
	call print_message
	ret

error:
	lea dx, error_mes
	call print_message
	int 20h

align 16

psp 		db 0cfh, 0ffh dup (0)
buffer 		db 100h dup (0)

end _

; :build
;	tasm /m debug.bat
;	tlink /x/t debug