;	goto build
	.model tiny
	.386
	.code
	org 100h
_:
	jmp start

addr		db "NAMES\"
file_path	db "____\____.txt",0

handle		dw 0

nf_mes  	db "not fount specification",13,10,'$'
nf_len 		dw (nf_len - nf_mes)

start:
	call find_devices
	ret

find_devices:
	mov dx, 0cf8h 		;config addr
	mov ecx, 80000000h	;set 0 bus
search_loop:	
	call print_device
	add ecx, 0800h 		;set next device
	test ecx, 01000000h
	jz search_loop
	ret	

print_device:
	call check_mult
	cmp al, 1
	mov ebp, 0		;func number
	je mult
non_mult:
	call get_info
	cmp ax, -1
	je exit_print_device
	call save_info
	jmp after
mult:	
	call get_info
	cmp ax, -1
	je nxt
	call save_info
	push dx
	lea dx, bdf
	call print_mes
	pop dx
nxt:
	inc bp
	cmp bp, 8
	jl mult
	ret
after:
	push dx
	lea dx, bdf
	call print_mes
	pop dx
exit_print_device:
	ret

;ebp - function number
get_info:
	mov eax, ecx
	shl ebp, 8 
	add eax, ebp
	shr ebp, 8
	out dx, eax		
	add dx, 4		;set config data
	in eax, dx		;get did and vid
	sub dx, 4
	ret

save_info:
	lea di, bdf
	call save_bus_num
	inc di
	call save_device_num
	inc di
	call save_func_num
	inc di
	call save_vid
	inc di
	call save_did
	inc di
	call save_specification	
	ret

save_bus_num:
	push ecx
	push ax
	shr ecx, 10h		;get bus number
	mov al, cl
	call save_byte
	pop ax
	pop ecx
	ret

save_device_num:
	push ecx
	push ax
	shr ecx, 11
	and cl, 00011111b
	mov al, al
	call save_byte
	pop ax
	pop ecx
	ret

save_func_num:
	push ax
	mov ax, bp
	call save_digit
	pop ax
	ret

save_vid:
	call save_word
	ret

save_did:
	push ax
	shr eax, 10h
	call save_word
	pop ax
	ret

save_specification:
	push dx
	push cx
	lea di, file_path
	lea dx, vid_buf
	mov cx, 4
	call copy
	inc di
	inc dx
	mov cx, 4
	call copy
	call save_file	
	pop cx
	pop dx
	ret

save_word:
	xchg ah, al
	call save_byte

	xchg ah, al
	call save_byte
	ret

save_byte:
	push ax
	shr al, 4
	call save_digit

	pop ax
	call save_digit
	ret

save_digit:
	push ax
	and al, 0fh
	cmp al, 10
	sbb al, 69h
	das
	stosb
	pop ax
	ret

check_mult:
	mov eax, ecx
	add eax, 0ch
	out dx, eax
	add dx, 4
	in eax, dx
	sub dx, 4
	
	shr eax, 23
	and ax, 0001h
	ret

save_file:
	push dx
	lea dx, addr
	call open_file
	jc save_nf_mes

	call read_file
	call close_file
	pop dx
	ret
save_nf_mes:
	lea dx, nf_mes
	lea di, info
	mov cx, nf_len
	call copy
	pop dx
	ret

read_file:
	push dx
	mov bx, handle
	mov ah, 3fh
	mov cx, 100h
	lea dx, info
	int 21h
	pop dx
	ret

open_file:
	mov ax, 3d00h
	int 21h
	mov handle, ax	
	ret

close_file:
	mov ah, 3eh
	mov bx, handle
	int 21h
	ret

print_mes:
	mov ah, 09h
	int 21h
	ret

;dx - source 
;di - destination
;cx - len
copy:
	push di
	mov di, dx
	mov al, [di]
	pop di
	inc dx
	stosb
	loop copy
	ret

;bus device func

bdf	db "__:__:_ "
vid_buf	db 4 dup (0)
colon 	db ':'
did_buf	db 4 dup (0)
space	db ' '
info	db 100h dup (0)

end _
;	:build
;	tasm /m pci.bat
;	tlink /x/t pci
