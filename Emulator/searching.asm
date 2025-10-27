ASSUME CS:code, DS:data

data SEGMENT
    MSG1 DB 0AH,0DH,'Enter digits (0-9), then press Enter:$'
    MSG2 DB 0AH,0DH,'Enter digit to search (0-9):$'
    MSG3 DB 0AH,0DH,'Digit found at index: $'
    MSG4 DB 0AH,0DH,'Digit NOT found.$'
    STR  DB 20 DUP(?)      ; store up to 20 digits
data ENDS

code SEGMENT
START:
    MOV AX,data
    MOV DS,AX

    ; ---------------- Input digits ----------------
    LEA DX,MSG1
    MOV AH,09H
    INT 21H

    LEA DI,STR
    MOV CX,0               ; count digits

READ_LOOP:
    MOV AH,01H
    INT 21H
    CMP AL,0DH             ; Enter pressed?
    JE INPUT_DONE
    CMP AL,'0'
    JB READ_LOOP
    CMP AL,'9'
    JA READ_LOOP

    MOV [DI],AL            ; store digit
    INC DI
    INC CX
    CMP CX,20
    JL READ_LOOP

INPUT_DONE:

    ; ---------------- Ask for search digit ----------------
    LEA DX,MSG2
    MOV AH,09H
    INT 21H

    MOV AH,01H
    INT 21H
    MOV BL,AL              ; digit to search

    ; ---------------- Search loop ----------------
    MOV SI,0               ; index
SEARCH_LOOP:
    CMP SI,CX
    JAE NOT_FOUND          ; reached end

    MOV AL,[STR+SI]
    CMP AL,BL
    JE FOUND

    INC SI
    JMP SEARCH_LOOP

; ---------------- Found ----------------
FOUND:
    LEA DX,MSG3
    MOV AH,09H
    INT 21H

    MOV AX,SI              ; print index (0–19)
    ADD AL,'0'             ; only valid for <10
    MOV DL,AL
    MOV AH,02H
    INT 21H
    JMP EXIT

; ---------------- Not Found ----------------
NOT_FOUND:
    LEA DX,MSG4
    MOV AH,09H
    INT 21H

EXIT:
    MOV AH,4CH
    INT 21H

code ENDS
END START