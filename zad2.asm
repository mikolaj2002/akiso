; prints prime numbers from 1 to 100000

section .text
	global _start

_start:
	mov     ecx, 2
.main_loop:
    mov     eax, ecx
    call    print_if_prime
    inc     ecx
    cmp     ecx, 100000
    jnz     .main_loop

    mov     ebx, 0
    mov     eax, 1
    int     0x80

; function checks if number in eax is prime and prints it if it is
print_if_prime:
    push    ecx
    push    edx
    push    eax

    mov     ecx, eax
    dec     ecx

.is_prime_loop:
    cmp     ecx, 2
    jl      .finish_print_prime
    pop     eax
    push    eax
    mov     edx, 0
    idiv    ecx
    dec     ecx
    cmp     edx, 0
    jg     .is_prime_loop

    pop     eax
    pop     edx
    pop     ecx
    ret


.finish_print_prime:
    pop     eax
    call    print_eax
    pop     edx
    pop     ecx
    ret

; functions prints decimal number stored in eax and adds new line
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
    mov     esi, 10
    idiv    esi
    add     edx, 48
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
