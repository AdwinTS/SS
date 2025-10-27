DATA SEGMENT
MSG1 DB 10,13,"ENTER FIRST 4-DIGIT NUMBER (Minuend): $"
MSG2 DB 10,13,"ENTER SECOND 4-DIGIT NUMBER (Subtrahend): $"
MSG3 DB 10,13,"RESULT IS: $"
MSG_NEG DB "-"          ; New message for the minus sign
NUM1 DB 4 DUP(?)        ; Minuend (A)
NUM2 DB 4 DUP(?)        ; Subtrahend (B)
RESULT DB 5 DUP('$')    ; Result storage (4 digits + 1 extra $ to avoid printing garbage)
IS_NEGATIVE DB 0        ; Flag: 0 = Positive/Zero, 1 = Negative
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX

    ; --- INPUT ---
    ; Input NUM1
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    MOV CX, 4
    LEA SI, NUM1
NUM1_INPUT:
    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV [SI], AL
    INC SI
    LOOP NUM1_INPUT
    
    MOV AH, 02H ; Line break
    MOV DL, 10
    INT 21H
    MOV DL, 13
    INT 21H

    ; Input NUM2
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    MOV CX, 4
    LEA SI, NUM2
NUM2_INPUT:
    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV [SI], AL
    INC SI
    LOOP NUM2_INPUT

    MOV AH, 02H ; Line break
    MOV DL, 10
    INT 21H
    MOV DL, 13
    INT 21H
    
    ; --------------------------------
    ; Initial Subtraction (NUM1 - NUM2)
    ; --------------------------------
    CALL PERFORM_SUBTRACTION

    ; --------------------------------
    ; Check Final Borrow
    ; --------------------------------
    JNC POSITIVE_OR_ZERO ; Jump if No Carry (Result is NUM1 - NUM2 >= 0)
    
    ; --- NEGATIVE CASE ---
    MOV IS_NEGATIVE, 1   ; Set flag
    
    ; Swap NUM1 and NUM2 in memory for second subtraction (NUM2 - NUM1)
    CALL SWAP_NUMBERS
    
    ; Recalculate magnitude (NUM2 - NUM1)
    CALL PERFORM_SUBTRACTION
    
    JMP DISPLAY_MESSAGE

POSITIVE_OR_ZERO:
    MOV IS_NEGATIVE, 0

DISPLAY_MESSAGE:
    ; Display "RESULT IS: "
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H

    ; --------------------------------
    ; Display Sign if Negative
    ; --------------------------------
    CMP IS_NEGATIVE, 1
    JNE PRINT_RESULT_START ; Skip if not negative

    LEA DX, MSG_NEG     ; Load DX with address of "-"
    MOV AH, 09H         ; Print string service
    INT 21H             ; (Note: MOV AH, 09H is safer than 02H here for quick printing)

PRINT_RESULT_START:
    MOV SI, BX        ; Set SI to the start of the final result string (pointed to by BX)
    
PRINT_RESULT:
    MOV DL, [SI]      ; Load the current result character into DL
    
    CMP DL, '$'
    JE END_PROG
    
    MOV AH, 02H       ; Display character service
    INT 21H
    
    INC SI
    JMP PRINT_RESULT

END_PROG:
    MOV AH, 4CH
    INT 21H
    
; ----------------------------------------------------
; PROCEDURES / SUBROUTINES
; ----------------------------------------------------

; Subroutine to perform A - B and store in RESULT. Sets CF if borrow occurs.
PERFORM_SUBTRACTION PROC
    LEA SI, NUM1+3    ; A (Minuend)
    LEA DI, NUM2+3    ; B (Subtrahend)
    LEA BX, RESULT+4  ; Result storage end
    MOV CX, 4
    CLC               ; Clear Carry Flag (CF) to start without a borrow

SUBTRACT_LOOP:
    MOV AL, [SI]
    SBB AL, [DI]      ; Subtract digit 2 AND subtract previous borrow (SBB uses CF)
    
    DAS               ; Decimal Adjust AL after Subtraction
    
    PUSHF             ; Save CF for the next iteration's SBB
    
    ADD AL, 30H       ; Convert resulting BCD digit back to ASCII
    
    DEC BX
    MOV [BX], AL
    
    DEC SI
    DEC DI
    
    POPF              ; Restore CF
    LOOP SUBTRACT_LOOP
    
    RET
PERFORM_SUBTRACTION ENDP

; Subroutine to swap the contents of NUM1 and NUM2
SWAP_NUMBERS PROC
    MOV CX, 4         ; Loop 4 times for 4 bytes
    LEA SI, NUM1      ; Source 1
    LEA DI, NUM2      ; Source 2
    
SWAP_LOOP:
    MOV AL, [SI]      ; AL = NUM1[i]
    MOV BL, [DI]      ; BL = NUM2[i]
    MOV [SI], BL      ; NUM1[i] = NUM2[i]
    MOV [DI], AL      ; NUM2[i] = AL (NUM1[i])
    INC SI
    INC DI
    LOOP SWAP_LOOP
    
    RET
SWAP_NUMBERS ENDP

CODE ENDS
END START
