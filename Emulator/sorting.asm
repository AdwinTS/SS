data SEGMENT
    MSG1 DB 10,13, 'Enter digits (0-9), then press Enter:$'
    MSG2 DB 10,13, 'Sorted digits: $'
    STR DB 20 DUP(0)       
data ENDS

code SEGMENT
ASSUME CS:code, DS:data

START:
    MOV AX, data
    MOV DS, AX

    LEA DX, MSG1
    MOV AH, 09h
    INT 21h
                 
    LEA DI, STR
    MOV CX, 0         

READ_LOOP:
    MOV AH, 01h      
    INT 21h
    CMP AL, 0Dh      
    JE SORT_START
    CMP AL, '0'
    JB READ_LOOP      
    CMP AL, '9'
    JA READ_LOOP      

    MOV [DI], AL     
    INC DI
    INC CX            
    CMP CX, 20        
    JE SORT_START
    JMP READ_LOOP

SORT_START:
    LEA SI, STR      
    MOV BX, CX      

    DEC DI             
    MOV CX, BX         

OUTER_LOOP:
    DEC CX
    JZ SORT_DONE     

    MOV SI, 0      
    MOV DX, CX      

INNER_LOOP:
    MOV AL, [STR + SI]
    MOV BL, [STR + SI + 1]
    CMP AL, BL
    JBE NOSWAP

    MOV [STR + SI], BL
    MOV [STR + SI + 1], AL

NOSWAP:
    INC SI
    DEC DX
    JNZ INNER_LOOP

    JMP OUTER_LOOP

SORT_DONE:
    LEA DX, MSG2
    MOV AH, 09h
    INT 21h

    MOV CX, BX       
    MOV SI, 0

PRINT_LOOP:
    MOV DL, [STR + SI]
    MOV AH, 02h
    INT 21h
    INC SI
    LOOP PRINT_LOOP

    MOV AH, 4Ch
    INT 21h

code ENDS
END START