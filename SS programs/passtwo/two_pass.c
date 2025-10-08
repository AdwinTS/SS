#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main() {
    int start, length, locctr, temp;
    char label[10], opcode[10], operand[10];
    char mnemonic[10], code[10];
    char symbol[10], symaddr[10];

    FILE *inter, *optab, *symtab, *asml, *objc, *leng;

    inter = fopen("intermediate3.txt", "r");
    optab = fopen("optab3.txt", "r");
    symtab = fopen("symtab3.txt", "r");
    asml = fopen("asml.txt", "w");
    objc = fopen("obj.txt", "w");
    leng = fopen("length3.txt", "r");

    if (!inter || !optab || !symtab || !asml || !objc || !leng) {
        printf("Error: Could not open one or more files.\n");
        return 1;
    }

    fscanf(leng, "%d", &length);

    // Read first line
    fscanf(inter, "%s %s %s", label, opcode, operand);

    if (strcmp(opcode, "START") == 0) {
    //start = (int)strtol(operand, NULL, 10); // pass1 stored DECIMAL locctr
     start = (int)strtol(operand, NULL, 16);
        fprintf(asml, "%-6s\t%-6s\t%-6s\t%-6s\n", label, opcode, operand, "");
        fprintf(objc, "H^%-6s^%06X^%06X\n", label, start, length);
        fscanf(inter, "%d %s %s %s", &locctr, label, opcode, operand);
    } else {
        start = 0;
    }

    // Text record buffer
    char textRec[500] = "";
    int textLen = 0;
    int textStart = start;

    while (strcmp(opcode, "END") != 0) {
        int found = 0;
        rewind(optab);

        // Search OPTAB
        while (fscanf(optab, "%s %s", mnemonic, code) != EOF) {
            if (strcmp(mnemonic, opcode) == 0) {
                found = 1;
                rewind(symtab);
                int sym_found = 0;

                while (fscanf(symtab, "%s %s", symbol, symaddr) != EOF) {
                    if (strcmp(symbol, operand) == 0) {
                        char objCode[20];
                        sprintf(objCode, "%s%s", code, symaddr);
                        sprintf(textRec + strlen(textRec), "^%s", objCode);
                        textLen += 3;
                        if (textLen >= 30) {
    fprintf(objc, "T^%06X^%02X^%s\n", textStart, textLen, textRec);
    
    // Reset for next text record
    textRec[0] = '\0';
    textLen = 0;
    textStart = locctr;
 // new starting address
}
                        fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\t%s\n",
                                locctr, label, opcode, operand, objCode);
                        sym_found = 1;
                        break;
                    }
                }
                if (!sym_found) {
                    char objCode[20];
                    sprintf(objCode, "%s0000", code);
                    sprintf(textRec + strlen(textRec), "^%s", objCode);
                    textLen += 3;
                    if (textLen >= 30) {
    fprintf(objc, "T^%06X^%02X^%s\n", textStart, textLen, textRec);
    
    // Reset for next text record
    textRec[0] = '\0';
    textLen = 0;
    textStart = locctr; // new starting address
}
                    fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\t%s\n",
                            locctr, label, opcode, operand, objCode);
                }
                break;
            }
        }

        // Directives
        if (!found) {
            if (strcmp(opcode, "WORD") == 0) {
                temp = atoi(operand);
                char objCode[20];
                sprintf(objCode, "%06X", temp);
                sprintf(textRec + strlen(textRec), "^%s", objCode);
                textLen += 3;
                if (textLen >= 30) {
    fprintf(objc, "T^%06X^%02X^%s\n", textStart, textLen, textRec);
    
    // Reset for next text record
    textRec[0] = '\0';
    textLen = 0;
    textStart = locctr; // new starting address
}
                fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\t%06X\n",
                        locctr, label, opcode, operand, temp);
            } else if (strcmp(opcode, "BYTE") == 0) {
                if (operand[0] == 'C') {
                    char objCode[100] = "";
                    for (int i = 2; i < (int)strlen(operand) - 1; i++) {
                        char hex[5];
                        sprintf(hex, "%02X", operand[i]);
                        strcat(objCode, hex);
                    }
                    sprintf(textRec + strlen(textRec), "^%s", objCode);
                    textLen += (strlen(operand) - 3);
                    if (textLen >= 30) {
    fprintf(objc, "T^%06X^%02X^%s\n", textStart, textLen, textRec);
    
    // Reset for next text record
    textRec[0] = '\0';
    textLen = 0;
    textStart = locctr; // new starting address = locctr; // new starting address
}
                    fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\t%s\n",
                            locctr, label, opcode, operand, objCode);
                } else if (operand[0] == 'X') {
                    char objCode[100] = "";
                    for (int i = 2; i < (int)strlen(operand) - 1; i++) {
                        char hex[5];
                        sprintf(hex, "%c", operand[i]);
                        strcat(objCode, hex);
                    }
                    sprintf(textRec + strlen(textRec), "^%s", objCode);
                    textLen += (strlen(operand) - 3) / 2;
                    if (textLen >= 30) {
    fprintf(objc, "T^%06X^%02X^%s\n", textStart, textLen, textRec);
    
    // Reset for next text record
    textRec[0] = '\0';
    textLen = 0;
    textStart  = locctr;// new starting address
}
                    fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\t%s\n",
                            locctr, label, opcode, operand, objCode);
                }
                else if (strcmp(opcode, "RESW") == 0 || strcmp(opcode, "RESB") == 0) {
    if (textLen > 0) {
        fprintf(objc, "T^%06X^%02X^%s\n", textStart, textLen, textRec);
        textRec[0] = '\0';
        textLen = 0;
    }
    fprintf(asml, "%-6s\t%-6s\t%-6s\t%-6s\n", locctr, label, opcode, operand);
}
            } else {
                // RESW / RESB no object code
                fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\n",
                        locctr, label, opcode, operand);
            }
        }

        fscanf(inter, "%d %s %s %s", &locctr, label, opcode, operand);
    }

    // Write final text record
    fprintf(objc, "T^%06X^%02X%s\n", textStart, textLen, textRec);

    // END
    fprintf(asml, "%-6d\t%-6s\t%-6s\t%-6s\n", locctr, label, opcode, operand);
    fprintf(objc, "E^%06X\n", start);

    fclose(optab);
    fclose(symtab);
    fclose(asml);
    fclose(objc);
    fclose(inter);
    fclose(leng);

    printf("Pass 2 completed successfully.\n");
    return 0;
}
