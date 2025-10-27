
  ; Assume DATA segment is for DS and CODE segment is for CS

; ----------------------
; DATA SEGMENT
; ----------------------
DATA SEGMENT
MSG1 DB 10,13,"ENTER FIRST NUMBER$"       ; Prompt for first number
MSG2 DB 0AH,0DH,"ENTER SECOND NUMBER$"      ; Prompt for second number
MSG3 DB 0AH,0DH,"SUM IS$"                   ; Message for displaying sum
ENDS

; ----------------------
; CODE SEGMENT
; ----------------------
ASSUME DS:DATA, CS:CODE 
CODE SEGMENT
START:

    ; Initialize DS with DATA segment
    MOV AX,DATA
    MOV DS,AX

    ; ----------------------
    ; Input FIRST number
    ; ----------------------
    LEA DX,MSG1      ; Load address of MSG1 into DX
    MOV AH,09H       ; DOS function: Display string
    INT 21H          ; Call DOS

    ; Read first digit of first number
    MOV AH,01H       ;  read char from keyboard into AL
    INT 21H
    MOV BH,AL        ; Store first digit in BH

    ; Read second digit of first number
    MOV AH,01H
    INT 21H
    MOV BL,AL        ; Store second digit in BL

    ; ----------------------
    ; Input SECOND number
    ; ----------------------
    LEA DX,MSG2
    MOV AH,09H
    INT 21H          ; Display second prompt

    ; Read first digit of second number
    MOV AH,01H
    INT 21H
    MOV CH,AL        ; Store first digit in CH

    ; Read second digit of second number
    MOV AH,01H
    INT 21H
    MOV CL,AL        ; Store second digit in CL

    ; ----------------------
    ; Calculate Sum
    ; BX = first number (digits in BH, BL)
    ; CX = second number (digits in CH, CL)
    ; ----------------------
    MOV AL,BL        ; Add second digits
    MOV AH,00H
    ADD AL,CL
    AAA              ; Adjust result to unpacked BCD
    MOV CL,AH        ; Store carry in CL
    ADD AL,30H       ; Convert to ASCII
    MOV BL,AL        ; Store result digit

    MOV AH,00H       ; Add first digits
    MOV AL,BH
    ADD AL,CH
    ADD AL,CL        ; Add carry from previous addition
    AAA              ; Adjust result to unpacked BCD
    ADD AL,30H
    MOV BH,AL        ; Store result digit
    MOV CH,AH        ; Store carry for possible third digit

    ; ----------------------
    ; Display Sum
    ; ----------------------
DISP:
    LEA DX,MSG3      ; Display "SUM IS"
    MOV AH,09H
    INT 21H

    CMP CH,0         ; Check if there’s a carry (third digit)
    JE NO_CARRY      ; If no carry, skip printing it
    MOV DL,CH        ; Print carry digit (e.g., '1' for 100+)
    ADD DL,30H       ; Convert carry to ASCII
    MOV AH,02H
    INT 21H

NO_CARRY:
    MOV DL,BH        ; Print first digit
    MOV AH,02H
    INT 21H

    MOV DL,BL        ; Print second digit
    MOV AH,02H
    INT 21H

    ; ----------------------
    ; Exit Program
    ; ----------------------
FULL:
    MOV AH,4CH       ; DOS terminate program
    INT 21H

CODE ENDS
END START