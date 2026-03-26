@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Sequência RPN: 4 expressão(ões)
@   [0] 1 3 * 15 2 + 4 - 3 /
@   [1] 3 2 //
@   [2] 2 MEM
@   [3] MEM
.global _start

.section .data

C0:  .double 1
C1:  .double 3
C2:  .double 15
C3:  .double 2
C4:  .double 4
C10:  .double 10.0

@ slot de persistência — expressão '1 3 * 15 2 + 4 - 3 /'
_RES_SLOT_11:  .double 0.0

@ slot de persistência — expressão '3 2 //'
_RES_SLOT_17:  .double 0.0
MEM_MEM:  .double 0.0  @ variável MEM

@ slot de persistência — expressão '2 MEM'
_RES_SLOT_23:  .double 0.0

@ slot de persistência — expressão 'MEM'
_RES_SLOT_29:  .double 0.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

.section .text
_start:

    @ --- bloco 0: 1 3 * 15 2 + 4 - 3 / ---
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
    BKPT    #0   @ pausa — fim do bloco 0 (Continue no CPUlator para prosseguir)

    @ --- bloco 1: 3 2 // ---
    @ carrega 3 → d0
    LDR     r0, =C1
    VLDR    d0, [r0]
    @ carrega 2 → d1
    LDR     r1, =C3
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
    BGE     SEG_POS12
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS12:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP13:
    CMP     r6, #6
    BGE     SEG_DONE14
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C10
    VLDR         d14, [r5]
    VDIV.F64     d15, d15, d14
    VCVT.S32.F64 s30, d15
    VMOV         r5, s30
    MOV     r7, #10
    MUL     r2, r5, r7
    SUB     r2, r0, r2
    MOV     r0, r5
    LDRB    r3, [r1, r2]
    @ empacota dígito no display correto
    CMP     r6, #4
    BGE     SEG_HI15
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT16
SEG_HI15:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT16:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP13
SEG_DONE14:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_17
    LDR     r3, =_RES_SLOT_17
    VMOV         s28, r2
    VCVT.F64.S32 d14, s28
    VSTR         d14, [r3]
    BKPT    #0   @ pausa — fim do bloco 1 (Continue no CPUlator para prosseguir)

    @ --- bloco 2: 2 MEM ---
    @ carrega 2 → d0
    LDR     r0, =C3
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
    BGE     SEG_POS18
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS18:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP19:
    CMP     r6, #6
    BGE     SEG_DONE20
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C10
    VLDR         d14, [r5]
    VDIV.F64     d15, d15, d14
    VCVT.S32.F64 s30, d15
    VMOV         r5, s30
    MOV     r7, #10
    MUL     r2, r5, r7
    SUB     r2, r0, r2
    MOV     r0, r5
    LDRB    r3, [r1, r2]
    @ empacota dígito no display correto
    CMP     r6, #4
    BGE     SEG_HI21
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT22
SEG_HI21:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT22:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP19
SEG_DONE20:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_23
    LDR     r3, =_RES_SLOT_23
    VSTR    d0, [r3]
    BKPT    #0   @ pausa — fim do bloco 2 (Continue no CPUlator para prosseguir)

    @ --- bloco 3: MEM ---
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
    BGE     SEG_POS24
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS24:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP25:
    CMP     r6, #6
    BGE     SEG_DONE26
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C10
    VLDR         d14, [r5]
    VDIV.F64     d15, d15, d14
    VCVT.S32.F64 s30, d15
    VMOV         r5, s30
    MOV     r7, #10
    MUL     r2, r5, r7
    SUB     r2, r0, r2
    MOV     r0, r5
    LDRB    r3, [r1, r2]
    @ empacota dígito no display correto
    CMP     r6, #4
    BGE     SEG_HI27
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT28
SEG_HI27:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT28:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP25
SEG_DONE26:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_29
    LDR     r2, =_RES_SLOT_29
    VSTR    d0, [r2]

    B   .   @ halt