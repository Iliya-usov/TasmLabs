;	goto build
	.model tiny
	.386
	.code
	org 100h

_:
	jmp start
code		db "__", 10, 13, '$'

esc_flag	db 0

int9_old_cs	dw 0
int9_old_ip	dw 0

int9_handler:
	pusha

	in al, 60h
	call set_esc_flag

	call print_scancode
	call send_acknowledgment_to_keyboard
	call notify_about_termination_of_interruption

	popa

	iret

set_esc_flag:
	cmp al, 1
	jnz exit_from_set_esc_flag

	mov esc_flag, 1

exit_from_set_esc_flag:	
	ret

print_scancode:
	lea di, code
	call save_byte

	lea dx, code
	mov ah, 09h
	int 21h
	ret

send_acknowledgment_to_keyboard:
	in al, 61h
	mov ah, al

	or al, 80h
	out 61h, al

	mov al, ah
	out 61h, al
	ret

notify_about_termination_of_interruption:
	mov al, 20h
	out 20h, al
	ret

start:
	call save_old_handler_addr
	call set_new_handler

program_loop:
	cmp esc_flag, 1
	jnz program_loop

exit:
	call set_old_handler
	ret

set_handler:
	push es

	push 0
	pop es

	push ax
	mov al, 4
	mul bl
	mov bx, ax 			; get handler addr

	pop ax			

	cli

	mov [es:bx], ax		; set ip
	mov [es:bx + 2], cx	; set cs

	sti

	pop es
	ret

set_old_handler:
	mov ax, int9_old_ip
	mov cx, int9_old_cs

	mov bl, 9 			; set interrupt number

	call set_handler
	ret

set_new_handler:
 	lea ax, int9_handler
 	mov cx, cs

 	mov bl, 9			; set interrupt number
	
	call set_handler
 	ret

save_handler_addr:
	push es

	push 0
	pop es

	mov al, 4
	mul bl
	mov bx, ax			; get handler addr

	mov ax, [es:bx]		; save ip 
    mov cx, [es:bx + 2]	; save cs

	pop es
	ret

save_old_handler_addr:
	mov bl, 9

	call save_handler_addr

    mov int9_old_ip, ax
    mov int9_old_cs, cx
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