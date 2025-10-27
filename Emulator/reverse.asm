; -----------------------------------------------------------
; PROGRAM: String Reversal (MASM / .EXE format)
; Reads a string, reverses it in place, and prints the result.
; -----------------------------------------------------------

DATA SEGMENT
    ; DOS input buffer: Max Length (100) | Actual Length | String Data
    STR_BUFF DB 100, ?, 100 DUP('$')
    
    ; Messages
    MSG1 DB 0AH, 0DH, 'ENTER A STRING TO REVERSE: $'
    MSG2 DB 0AH, 0DH, 'REVERSED STRING: $'
    
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX

    ; --- Read String ---
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR_BUFF
    MOV AH, 0AH          ; Function 0AH: Buffered input
    INT 21H
    
    ; Get the length of the string
    MOV CL, STR_BUFF[1]  ; CL = Actual length of input string
    MOV CH, 0            ; CX = Length

    ; =======================================================
    ;                 REVERSAL LOGIC
    ; =======================================================
    
    ; Pointers for swapping:
    ; SI points to the first character (start of string)
    ; DI points to the last character (end of string)
    
    LEA SI, STR_BUFF[2]  ; SI starts at the first character
    
    ; DI needs to point to the character at: [start_address] + [length] - 1
    LEA DI, STR_BUFF[2]  ; DI starts at the first character
    ADD DI, CX           ; DI points one byte past the last character
    DEC DI               ; DI points to the last character
    
    ; Calculate the number of swaps needed (Length / 2)
    SHR CX, 1            ; CX = CX / 2 (Number of iterations)

REVERSE_LOOP:
    PUSH CX              ; Save loop counter (CX)

    ; 1. Swap the characters pointed to by SI and DI
    MOV AL, [SI]         ; AL = character at start
    MOV BH, [DI]         ; BH = character at end
    
    MOV [DI], AL         ; Place start character at end
    MOV [SI], BH         ; Place end character at start

    ; 2. Move pointers
    INC SI               ; Move SI forward (to the right)
    DEC DI               ; Move DI backward (to the left)

    POP CX               ; Restore loop counter
    LOOP REVERSE_LOOP    ; Decrement CX and loop if CX != 0
    
    ; The string is already terminated by the original '$' 
    ; (or a space/CR/LF depending on the input termination)

    ; =======================================================
    
    ; --- Print Reversed String ---
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR_BUFF[2]  ; Print the string data starting at offset 2
    MOV AH, 09H
    INT 21H

    ; --- Exit ---
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START