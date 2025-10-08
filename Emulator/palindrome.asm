data SEGMENT
    MSG1 DB 10, 13, 'Enter the string:$'
    MSG2 DB 10, 13, 'String is Palindrome$'
    MSG3 DB 10, 13, 'String is not Palindrome$'
    STR1 DB 50 DUP(0)
data ENDS 

code SEGMENT
ASSUME CS:code, DS:data
START:
    MOV AX, DATA
    MOV DS, AX

    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    LEA SI, STR1
    LEA DI, STR1
    MOV AH, 01H

NEXT:
    INT 21H
    CMP AL, 0DH         
    JE TERMINATE
    MOV [DI], AL
    INC DI
    JMP NEXT

TERMINATE:
    MOV AL, '$'
    MOV [DI], AL        
    DEC DI              

CHECK_LOOP:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE NOTPALINDROME    
    INC SI
    DEC DI
    CMP SI, DI
    JLE CHECK_LOOP       

PALINDROME:
    MOV AH, 09H
    LEA DX, MSG2
    INT 21H
    JMP EXIT            

NOTPALINDROME:
    MOV AH, 09H
    LEA DX, MSG3
    INT 21H

EXIT:
    MOV AH, 4CH
    INT 21H
END START
code ENDS
ENDS