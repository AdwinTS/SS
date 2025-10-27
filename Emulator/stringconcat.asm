; -----------------------------------------------------------
; PROGRAM: String Concatenation (MASM / .EXE format)
; Reads two strings, appends string 2 to string 1, and prints
; -----------------------------------------------------------

DATA SEGMENT
    
    STR2_BUFF DB 100, ?, 100 DUP('$')
    RESULT_STR DB 201 DUP('$')
    
    MSG1 DB 0AH, 0DH, 'ENTER FIRST STRING: $'
    MSG2 DB 0AH, 0DH, 'ENTER SECOND STRING: $'
    MSG3 DB 0AH, 0DH, 'CONCATENATED STRING: $'
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX          ; ? Needed for REP MOVSB

    ; --- Read First String ---
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    LEA DX, STR1_BUFF
    MOV AH, 0AH
    INT 21H

    ; --- Read Second String ---
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H 
    
    LEA DX, STR2_BUFF
    MOV AH, 0AH
    INT 21H
    
    

    ; =======================================================
    ; CONCATENATION LOGIC
    ; =======================================================

    ; Copy STR1 to RESULT_STR
    MOV CL, STR1_BUFF[1]
    MOV CH, 0
    LEA SI, STR1_BUFF[2]
    LEA DI, RESULT_STR
    CLD
    REP MOVSB

    ; Append STR2
    MOV CL, STR2_BUFF[1]
    MOV CH, 0
    LEA SI, STR2_BUFF[2]
    REP MOVSB

    ; =======================================================
    ; Display concatenated string
    ; =======================================================
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H

    LEA DX, RESULT_STR
    MOV AH, 09H
    INT 21H

    ; Exit
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START
