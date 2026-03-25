@ Expressão RPN: ( MEM )
@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Expressão RPN: MEM
.global _start

.section .data

MEM_MEM:  .double 0.0  @ variável MEM
C5:  .double 10.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

.section .text
_start:

    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]
    @ double→int: d0 → r1
    VCVT.S32.F64 s28, d0
    VMOV         r1, s28

    @ === seven segment display ===
    @ copia r1 → r0
    MOV     r0, r1
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS0
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS0:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP1:
    CMP     r6, #6
    BGE     SEG_DONE2
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C5
    VLDR         d14, [r5]
    VDIV.F64     d15, d15, d14
    VCVT.S32.F64 s30, d15
    VMOV         r5, s30
    MUL          r2, r5, r7
    MOV     r7, #10
    MUL     r2, r5, r7
    SUB     r2, r0, r2
    MOV     r0, r5
    LDRB    r3, [r1, r2]
    @ empacota dígito no display correto
    CMP     r6, #4
    BGE     SEG_HI3
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT4
SEG_HI3:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT4:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP1
SEG_DONE2:
    @ === display atualizado ===

    @ resultado final em d0 (float)
    B   .   @ halt