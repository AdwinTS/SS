; -----------------------------------------------------------
; PROGRAM: Integer Square Root (MASM / .EXE format)
; Reads 2-digit number (00–99), finds integer sqrt, prints it
; -----------------------------------------------------------

DATA SEGMENT
    MSG1 DB 0AH,0DH,'ENTER A 2-DIGIT NUMBER (00-99): $'
    MSG2 DB 0AH,0DH,'SQUARE ROOT IS: $'
    NUM  DB ?        ; input number (in decimal, 0-99)
    ANS  DB ?        ; store integer square root (0-9)
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX

    ; ---- Display prompt ----
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; ---- Read 2 characters (digits) ----
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV BL, AL       ; store tens digit in BL

    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV BH, AL       ; store ones digit in BH

    ; ---- Convert to number: (tens*10 + ones) ----
    ; Note: The original conversion logic was correct.
    MOV AL, BL       ; AL = tens digit
    MOV AH, 0        ; AX = tens digit (zero-extended)
    MOV CL, 10
    MUL CL           ; AX = tens * 10
    ADD AL, BH       ; AL = (tens*10) + ones
    MOV NUM, AL      ; store number

    ; ---- Find integer square root (Corrected Logic) ----
    XOR BL, BL       ; BL = 0 (i = 0, current guess for sqrt)
    
    ; Prepare the input number (NUM) for 16-bit comparison by moving it to CX (CH=0, CL=NUM)
    MOV CL, NUM
    MOV CH, 0
    
NEXT:
    MOV AL, BL       ; AL = i (current guess for sqrt)
    MOV AH, 0        ; Clear AH for the 16-bit result of MUL
    MUL BL           ; AX = AL * BL (i*i). The 16-bit result is in AX.

    ; Compare 16-bit i*i (AX) with 16-bit NUM (CX)
    CMP AX, CX       ; Compare AX with CX
    JA  PRINT_RESULT ; if i*i > number, stop

    MOV ANS, BL      ; store current i as the result
    INC BL
    
    ; Check if i reaches 10 (since 10^2 = 100 > 99 max input)
    CMP BL, 10
    JBE NEXT         ; If i <= 10, loop again

PRINT_RESULT:
    ; ---- Print result ----
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    ; The result (ANS) is a single digit (0-9), stored in DL
    MOV DL, ANS
    ADD DL, '0'      ; Convert digit back to its ASCII character
    MOV AH, 02H
    INT 21H

    ; ---- Exit ----
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START