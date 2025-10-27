DATA SEGMENT
MSG1 DB 10,13,"ENTER FIRST 4-DIGIT NUMBER: $"
MSG2 DB 10,13,"ENTER SECOND 4-DIGIT NUMBER: $"
MSG3 DB 10,13,"SUM IS: $"
NUM1 DB 4 DUP(?)        ; Moved to DATA SEGMENT
NUM2 DB 4 DUP(?)        ; Moved to DATA SEGMENT
RESULT DB 6 DUP('$')    ; Moved to DATA SEGMENT (Large enough for 4+4 digits + carry + terminator)
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX

    ; --------------------------------
    ; Input FIRST number (4 digits)
    ; --------------------------------
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    MOV CX, 4
    LEA SI, NUM1
NUM1_INPUT:
    MOV AH, 01H
    INT 21H
    SUB AL, 30H       ; Convert ASCII to BCD (0-9)
    MOV [SI], AL
    INC SI
    LOOP NUM1_INPUT
    
    ; Add line break for cleaner console output
    MOV AH, 02H
    MOV DL, 10
    INT 21H
    MOV DL, 13
    INT 21H


    ; --------------------------------
    ; Input SECOND number (4 digits)
    ; --------------------------------
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    MOV CX, 4
    LEA SI, NUM2
NUM2_INPUT:
    MOV AH, 01H
    INT 21H
    SUB AL, 30H       ; Convert ASCII to BCD (0-9)
    MOV [SI], AL
    INC SI
    LOOP NUM2_INPUT

    ; Add line break
    MOV AH, 02H
    MOV DL, 10
    INT 21H
    MOV DL, 13
    INT 21H
    
    ; --------------------------------
    ; Perform Addition (Right to Left)
    ; --------------------------------
    LEA SI, NUM1+3    ; SI points to the last digit of NUM1
    LEA DI, NUM2+3    ; DI points to the last digit of NUM2
    LEA BX, RESULT+5  ; BX points ONE position PAST the storage area (RESULT[5])
    MOV CX, 4         ; Loop 4 times for 4 digits
    MOV AH, 0         ; Clear AH (used by AAM later)
    MOV CH, 0         ; CH used to hold the incoming/outgoing carry (0 or 1)

ADD_LOOP:
    MOV AL, [SI]      ; Load digit 1
    ADD AL, [DI]      ; Add digit 2
    ADD AL, CH        ; Add previous carry (CH holds carry)
    
    AAM               ; ASCII Adjust AX after Multiplication (AL/10 -> AH=Quotient (Carry), AL=Remainder (Digit))
    
    MOV CH, AH        ; Store new carry (0 or 1) back into CH
    MOV AH, 0         ; Reset AH before converting AL to ASCII
    
    ADD AL, 30H       ; Convert resulting digit (0-9) back to ASCII
    
    DEC BX            ; Move storage pointer one position left
    MOV [BX], AL      ; Store the digit (ASCII character)
    
    DEC SI            ; Move input pointers to the left (next digit)
    DEC DI
    LOOP ADD_LOOP

    ; --------------------------------
    ; Handle Final Carry
    ; --------------------------------
    CMP CH, 0
    JE NO_EXTRA_CARRY
    
    DEC BX            ; Move storage pointer left for the final carry
    MOV AL, CH
    ADD AL, 30H       ; Convert carry (0 or 1) to ASCII ('0' or '1')
    MOV [BX], AL
    
NO_EXTRA_CARRY:
    ; --------------------------------
    ; Display Result
    ; --------------------------------
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H

    MOV SI, BX        ; CRITICAL FIX: Set SI to the start of the result string (pointed to by BX)

PRINT_RESULT:
    MOV DL, [SI]      ; Load the current result character into DL
    
    ; The RESULT buffer is initialized with '$' terminators at the start.
    ; We are now reading from BX/SI, which is the start of the sum.
    ; We need to check for the string terminator, which is now guaranteed to be after the last digit.
    
    CMP DL, '$'       ; Check for the terminator (which should be placed outside the sum)
    JE END_PROG
    
    MOV AH, 02H       ; Display character service
    INT 21H
    
    INC SI            ; Move to the next character in the RESULT buffer
    JMP PRINT_RESULT

END_PROG:
    ; --------------------------------
    ; Terminate Program
    ; --------------------------------
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START
