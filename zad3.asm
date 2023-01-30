; prints prime numbers from 1 to 100000

section .text
	global _start

_start:
    mov     eax, 659840

    mov     ecx, 0
.main_loop:
    inc     ecx
    mov     edx, 0
    mov     esi, 10
    idiv    esi
    push    edx
    cmp     eax, 0
    jg      .main_loop

.main_print_loop:
    pop     eax
    call    print_eax
    dec     ecx
    cmp     ecx, 0
    jg      .main_print_loop

    mov     eax, 0x0A
    push    eax
    mov     edx, 1
    mov     ecx, esp
    mov     ebx, 1
    mov     eax, 4
    int     0x80

    mov     ebx, 0
    mov     eax, 1
    int     0x80

; functions prints binary number from eax on 4 bits + space
print_eax:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi

    mov     ecx, 4

.divide_loop:
    dec     ecx
    mov     edx, 0
    mov     esi, 2
    idiv    esi
    add     edx, 48
    push    edx
    cmp     ecx, 0
    jnz     .divide_loop

.print_loop:
    inc     ecx
    mov     eax, esp
    push    ecx

    mov     edx, 1
    mov     ecx, eax
    mov     ebx, 1
    mov     eax, 4
    int     0x80

    pop     ecx
    pop     eax
    cmp     ecx, 4
    jnz     .print_loop

.exit:
    mov     eax, 0x20
    push    eax
    mov     edx, 1
    mov     ecx, esp
    mov     ebx, 1
    mov     eax, 4
    int     0x80

    pop     eax
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax

    ret
