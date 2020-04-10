.MODEL  TINY
.CODE
bs=8
tab=9
cr=0Dh
lf=0ah
spc=20h
        ORG 80h
cmd_len db ?
cmd_line db ?
        ORG     100h
;---------------------------
vOldInt LABEL   WORD
Begin   PROC    NEAR
        jmp     Init
Begin   ENDP
        ORG     104h
;---------------------------
IntRout PROC    FAR
        cmp ah, 0Ah
        je  @0
        jmp dword ptr cs:[vOldInt]
@0:
    push    es
    push    di
    push    bx
    push    cx
    mov bx, dx
    push    si
    push    dx
    mov si, 1   
    xor ch, ch
    mov cl, [bx]
    inc bx      
    jcxz    @@exit
    mov ax, 0d00h
    mov [bx], ax
    dec cx
    jz  @@exit
    cld
    push    cs
    pop es
@@loop:
    call    Inp
    cmp al, cr
    je @@2exit
    cmp al, bs
    je @@bs
    call    IsConsonant
    jnz not_consonant
    dec al
not_consonant:
    call    Save2Buff
    jb  @@loop
    call    Output    
    jmp @@loop
@@bs:
    cmp si, 1
    je  @@loop
    mov [bx+si], byte ptr cr
    dec si
    dec byte ptr [bx]
    call    Output
    mov al, spc
    call    Output
    mov al, bs
    call    Output
    jmp @@loop
@@2exit:
    mov [bx+si], al
    call    Output
@@exit:
    pop dx
    pop si
    pop cx
    pop bx
    pop di
    pop es
    iret
IntRout ENDP
;---------------------------
Save2Buff       PROC    NEAR
        cmp     si, cx
        jb      @1
        stc
        ret
@1:
        inc     byte ptr [bx]
        mov     [bx+si], al
        mov     byte ptr [bx+si+1], cr
        inc     si
        clc
        ret
Save2Buff       ENDP
;---------------------------
Output  PROC    NEAR
        push    ax
        push    dx
        mov     dl, al
        mov     ah, 2
        int     21h
        pop     dx
        pop     ax
        ret
Output  ENDP
;---------------------------
Inp       PROC    NEAR
        mov     ah, 8
        int     21h
        ret
Inp       ENDP
;---------------------------
IsConsonant PROC    NEAR
        push    cx
        mov     di, offset Consonants
        mov     cx, SIZEOF_Consonants
        repne   scasb
        pop     cx
        ret
IsConsonant ENDP
Consonants db   'QWRTPSDFGHJKLZXCVBNMqwrtpsdfghjklzxcvbnm'
SIZEOF_Consonants=$-Consonants
flag dw 3478
;---------------------------
Init    PROC    NEAR
        mov     ax, 3521h
        int     21h

        cmp     byte ptr cmd_line[1], 'i'
        je      install
        cmp     byte ptr cmd_line[1], 'd'
        je      uninstall
        jmp     error

install:

        cmp     es:flag, 14327
        je      installed

        mov     flag, 14327

        mov     [vOldInt], bx
        mov     [vOldInt+2], es
 
        mov     dx, offset IntRout
        mov     ax, 2521h
        int     21h
 
        mov     dx, offset Init
        int     27h

uninstall:
        cmp     es:flag, 19864
        jne     uninstall_error

        mov     dx, es:vOldInt
        mov     ds, es:vOldInt+2
        mov     ax, 2521h
        int     21h

        mov     ax, 4ch
        int     21h

installed:
        mov     dx, offset installed_str
        mov     ah, 09h
        int     21h

        mov     ah, 4ch
        int     21h

error:
        mov     dx, offset error_str
        mov     ah, 09h
        int     21h

        mov     ah, 4ch
        int     21h
uninstall_error:
        mov     dx, offset uninstall_error_str
        mov     ah, 09h
        int     21h

        mov     ah, 4ch
        int     21h        
Init    ENDP
installed_str db "Already installed!$"
error_str db "Error! Use 'i' to install, 'd' to delete!$"
uninstall_error_str db "Error! Nothing to delete!$"
;---------------------------
        END     Begin
