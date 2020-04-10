model small
.stack 256
.data

max db 50
len db ?
s db 50 dup(?)

.code
    carriage_return PROC
        PUSH AX
        PUSH DX     
        MOV DL, 10
        MOV AH, 02h
        INT 21h; /n
        POP DX
        POP AX        
        RET
    carriage_return ENDP
start:
  MOV AX, @data
  MOV DS, AX

  LEA DX, max
  MOV AH, 0Ah
  INT 21h

  CALL carriage_return

  xor dx, dx

  mov cl, len
  lea si, s
  cycle:
      mov dl, [si]
      mov ah, 02h
      int 21h
      inc si
  LOOP cycle

  MOV AH, 4ch
  INT 21h
end start