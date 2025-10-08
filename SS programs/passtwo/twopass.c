#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_TEXT 60 // Max text record length in half-bytes (30 bytes)

int main() {
    int start = 0, length = 0, locctr = 0, temp;
    char label[10], opcode[10], operand[10];
    char mnemonic[10], code[10];
    char symbol[10], symaddr[10];
    char locctr_str[10];

    FILE *inter = fopen("intermediate3.txt", "r");
    FILE *optab = fopen("optab3.txt", "r");
    FILE *symtab = fopen("symtab3.txt", "r");
    FILE *asml = fopen("asml.txt", "w");
    FILE *objc = fopen("obj.txt", "w");
    FILE *leng = fopen("length3.txt", "r");

    if (!inter || !optab || !symtab || !asml || !objc || !leng) {
        printf("Error: Could not open one or more files.\n");
        return 1;
    }

    fscanf(leng, "%d", &length);

    // Read first line
    fscanf(inter, "%s %s %s", label, opcode, operand);

    if (strcmp(opcode, "START") == 0) {
        start = (int)strtol(operand, NULL, 16);
        fprintf(asml, "%-6s\t%-6s\t%-6s\n", label, opcode, operand);
        fprintf(objc, "H^%-6s^%06X^%06X\n", label, start, length);
        fscanf(inter, "%s %s %s %s", locctr_str, label, opcode, operand);
        if (strcmp(locctr_str, "*****") != 0)
            locctr = (int)strtol(locctr_str, NULL, 16);
    }

    char textRec[500] = "";
    int textLen = 0;
    int textStart = locctr;

    while (strcmp(opcode, "END") != 0) {
        int found = 0;
        rewind(optab);

        // Search OPTAB for instruction
        while (fscanf(optab, "%s %s", mnemonic, code) != EOF) {
            if (strcmp(mnemonic, opcode) == 0) {
                found = 1;
                rewind(symtab);
                int sym_found = 0;

                while (fscanf(symtab, "%s %s", symbol, symaddr) != EOF) {
                    if (strcmp(symbol, operand) == 0) {
                        char objCode[20];
                        sprintf(objCode, "%s%s", code, symaddr);
                        strcat(textRec, "^");
                        strcat(textRec, objCode);
                        textLen += 3;
                        fprintf(asml, "%-6X\t%-6s\t%-6s\t%-6s\t%s\n",
                                locctr, label, opcode, operand, objCode);
                        sym_found = 1;
                        break;
                    }
                }

                if (!sym_found) { // If symbol not found
                    char objCode[20];
                    sprintf(objCode, "%s0000", code);
                    strcat(textRec, "^");
                    strcat(textRec, objCode);
                    textLen += 3;
                    fprintf(asml, "%-6X\t%-6s\t%-6s\t%-6s\t%s\n",
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
                strcat(textRec, "^");
                strcat(textRec, objCode);
                textLen += 3;
                fprintf(asml, "%-6X\t%-6s\t%-6s\t%-6s\t%s\n",
                        locctr, label, opcode, operand, objCode);
            } else if (strcmp(opcode, "BYTE") == 0) {
                char objCode[100] = "";
                if (operand[0] == 'C') {
                    for (int i = 2; i < strlen(operand) - 1; i++) {
                        char hex[3];
                        sprintf(hex, "%02X", operand[i]);
                        strcat(objCode, hex);
                    }
                } else if (operand[0] == 'X') {
                    for (int i = 2; i < strlen(operand) - 1; i++) {
                        char hex[2];
                        sprintf(hex, "%c", operand[i]);
                        strcat(objCode, hex);
                    }
                }
                strcat(textRec, "^");
                strcat(textRec, objCode);
                textLen += strlen(objCode) / 2;
                fprintf(asml, "%-6X\t%-6s\t%-6s\t%-6s\t%s\n",
                        locctr, label, opcode, operand, objCode);
            } else if (strcmp(opcode, "RESW") == 0 || strcmp(opcode, "RESB") == 0) {
                if (textLen > 0) { // Flush existing text record
                    fprintf(objc, "T^%06X^%02X%s\n", textStart, textLen, textRec);
                    textRec[0] = '\0';
                    textLen = 0;
                }
                fprintf(asml, "%-6X\t%-6s\t%-6s\t%-6s\n", locctr, label, opcode, operand);
            }
        }

        // Flush text record if max length reached
        if (textLen >= MAX_TEXT) {
            fprintf(objc, "T^%06X^%02X%s\n", textStart, textLen, textRec);
            textRec[0] = '\0';
            textLen = 0;
            textStart = locctr + 3; // next instruction
        }

        fscanf(inter, "%s %s %s %s", locctr_str, label, opcode, operand);
        if (strcmp(locctr_str, "*****") != 0)
            locctr = (int)strtol(locctr_str, NULL, 16);
    }

    // Write final text record
    if (textLen > 0)
        fprintf(objc, "T^%06X^%02X%s\n", textStart, textLen, textRec);

    // END record
    fprintf(asml, "%-6X\t%-6s\t%-6s\t%-6s\n", locctr, label, opcode, operand);
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
