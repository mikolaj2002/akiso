; printing hex number

global _start

section .text
_start:
    mov     eax, 0x3E5FD9
    call    print_eax

    mov     ebx, 0
    mov     eax, 1
    int     0x80

; functions prints hex number stored in eax and adds new line
print_eax:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi

    mov     ecx, 0

.divide_loop:
    inc     ecx
    mov     edx, 0
    mov     esi, 16
    idiv    esi

    cmp     edx, 9
    jg      .is_letter
    add     edx, 48
    jmp     .end_if
.is_letter:
    add     edx, 55
.end_if:

    push    edx
    cmp     eax, 0
    jnz     .divide_loop

.print_loop:
    dec     ecx
    mov     eax, esp
    push    ecx

    mov     edx, 1
    mov     ecx, eax
    mov     ebx, 1
    mov     eax, 4
    int     80h

    pop     ecx
    pop     eax
    cmp     ecx, 0
    jnz     .print_loop

.exit:
    mov     eax, 0Ah
    push    eax
    mov     edx, 1
    mov     ecx, esp
    mov     ebx, 1
    mov     eax, 4
    int     80h

    pop     eax
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax

    ret
