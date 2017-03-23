; goto build
  .model tiny
  .386
  .code
  org 100h
_:
  mov bx, 0
  mov ds, bx
  
dump:
  push bx
  call initialize_output
  call print_screen
  pop bx
  jmp listen
  
initialize_output:
  mov ax, 0b800h  
  mov es, ax
  mov di, 0
  mov dx, 160    
  mov cx, 25
  cld    
  ret

print_screen:
  call print_line
  mov di, dx
  add dx, 160  
  loop print_screen
  ret

print_line:
  call print_addr

  call print_space
  call print_pipeline
  call print_space

  call print_memory    
  ret

print_addr:
  mov ax, ds
  call print_hex_word
  
  call print_colon

  mov ax, bx
  call print_hex_word  
  ret

print_colon:
  mov al, ':'
  mov ah, 0fh
  stosw
  ret

print_space:
  mov ax, 0
  stosw
  ret

print_pipeline:
  mov ax, 0f7ch  ;'|'
  stosw
  ret

print_memory:
  push cx
  mov cx, 8

  print_word:
    mov ax, word ptr [ds:bx]

    xchg ah, al  ;little-endian  
    call print_hex_word

    call print_space
    add bx, 2
  
    loop print_word
  pop cx
  ret

print_hex_word:
  xchg ah, al
  call print_hex_byte
  
  xchg ah, al
  call print_hex_byte
  ret

print_hex_byte:
  push ax  
  shr al, 4
  call print_digit
  
  pop ax
  call print_digit
  ret
  
print_digit:
  push ax
  and al, 0fh
  cmp al, 10
  sbb al, 69h
  das
  mov ah, 0fh
  stosw
  pop ax 
  ret

listen:
  mov ax, 0
  int 16h
  cmp ah, 01h  ;esc
  je reboot
  cmp ah, 48h  ;up
  je up
  cmp ah, 50h  ;down
  je down
  cmp ah, 49h  ;pgup
  je pgup
  cmp ah, 51h  ;pgdn
  je pgdn
  jmp listen
reboot:
  ;mov ax, 0003h
  ;int 10h
  ;ret
  int 19h
  ret
up:
  sub bx, 010h
  jmp dump
down:
  add bx, 010h
  jmp dump
pgup:
  mov ax, ds
  dec ax
  mov ds, ax
  jmp dump
pgdn:
  mov ax, ds
  inc ax
  mov ds, ax
  jmp dump

append:
  db (510 - (append - _)) dup (0)
  db 55h, 0AAh  

end _

; :build
;  tasm /m dump.bat
;  tlink /x/t dump