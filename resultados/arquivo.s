@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Expressão RPN: 1 3 * 15 2 + 4 - 3 /
.global _start

.section .data

C0:  .double 1
C1:  .double 3
C2:  .double 15
C3:  .double 2
C4:  .double 4
C10:  .double 10.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

@ slot de persistência para RES entre expressões
_RES_SLOT_11:  .double 0.0

.section .text
_start:

    @ carrega 1 → d0
    LDR     r0, =C0
    VLDR    d0, [r0]
    @ carrega 3 → d1
    LDR     r1, =C1
    VLDR    d1, [r1]
    @ d0 * d1 → d2
    VMUL.F64  d2, d0, d1
    @ carrega 15 → d3
    LDR     r2, =C2
    VLDR    d3, [r2]
    @ carrega 2 → d4
    LDR     r3, =C3
    VLDR    d4, [r3]
    @ d3 + d4 → d5
    VADD.F64  d5, d3, d4
    @ carrega 4 → d6
    LDR     r4, =C4
    VLDR    d6, [r4]
    @ d5 - d6 → d7
    VSUB.F64  d7, d5, d6
    @ carrega 3 → d8
    LDR     r5, =C1
    VLDR    d8, [r5]
    @ d7 / d8 → d9
    VDIV.F64  d9, d7, d8
    @ double→int: d9 → r6
    VCVT.S32.F64 s28, d9
    VMOV         r6, s28

    @ === seven segment display ===
    @ copia r6 → r0
    MOV     r0, r6
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS5
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS5:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP6:
    CMP     r6, #6
    BGE     SEG_DONE7
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C10
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
    BGE     SEG_HI8
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT9
SEG_HI8:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT9:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP6
SEG_DONE7:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_11
    LDR     r7, =_RES_SLOT_11
    VSTR    d9, [r7]

    @ resultado final em d9 (float)
    B   .   @ halt@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Expressão RPN: 3 2 //
.global _start

.section .data

C0:  .double 3
C1:  .double 2
C7:  .double 10.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

@ slot de persistência para RES entre expressões
_RES_SLOT_8:  .double 0.0

.section .text
_start:

    @ carrega 3 → d0
    LDR     r0, =C0
    VLDR    d0, [r0]
    @ carrega 2 → d1
    LDR     r1, =C1
    VLDR    d1, [r1]
    @ divisão inteira FPU: d0 // d1 → d2 (r2)
    VDIV.F64    d2, d0, d1
    @ double→int: d2 → r2
    VCVT.S32.F64 s28, d2
    VMOV         r2, s28

    @ === seven segment display ===
    @ copia r2 → r0
    MOV     r0, r2
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS2
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS2:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP3:
    CMP     r6, #6
    BGE     SEG_DONE4
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C7
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
    BGE     SEG_HI5
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT6
SEG_HI5:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT6:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP3
SEG_DONE4:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_8
    LDR     r3, =_RES_SLOT_8
    VMOV         s28, r2
    VCVT.F64.S32 d14, s28
    VSTR         d14, [r3]

    @ resultado final em r2 (int)
    B   .   @ halt@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Expressão RPN: 2 MEM
.global _start

.section .data

C0:  .double 2
MEM_MEM:  .double 0.0  @ variável MEM
C6:  .double 10.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

@ slot de persistência para RES entre expressões
_RES_SLOT_7:  .double 0.0

.section .text
_start:

    @ carrega 2 → d0
    LDR     r0, =C0
    VLDR    d0, [r0]
    @ grava d0 → MEM
    LDR     r1, =MEM_MEM
    VSTR    d0, [r1]
    @ double→int: d0 → r2
    VCVT.S32.F64 s28, d0
    VMOV         r2, s28

    @ === seven segment display ===
    @ copia r2 → r0
    MOV     r0, r2
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS1
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS1:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP2:
    CMP     r6, #6
    BGE     SEG_DONE3
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C6
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
    BGE     SEG_HI4
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT5
SEG_HI4:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT5:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP2
SEG_DONE3:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_7
    LDR     r3, =_RES_SLOT_7
    VSTR    d0, [r3]

    @ resultado final em d0 (float)
    B   .   @ halt@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
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

@ slot de persistência para RES entre expressões
_RES_SLOT_6:  .double 0.0

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
    @ persiste resultado final em _RES_SLOT_6
    LDR     r2, =_RES_SLOT_6
    VSTR    d0, [r2]

    @ resultado final em d0 (float)
    B   .   @ halt