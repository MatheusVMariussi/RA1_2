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
C5:  .double 100.0
C12:  .double 10.0

@ slot de persistência — expressão '1 3 * 15 2 + 4 - 3 /'
_RES_SLOT_14:  .double 0.0

@ slot de persistência — expressão '3 2 //'
_RES_SLOT_20:  .double 0.0
MEM_MEM:  .double 0.0  @ variável MEM

@ slot de persistência — expressão '2 MEM'
_RES_SLOT_28:  .double 0.0

@ slot de persistência — expressão 'MEM'
_RES_SLOT_36:  .double 0.0

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

    @ === seven segment display ===
    @ float → display: d9 × 100 → inteiro com 2 casas decimais
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ detecta sinal
    VCMP.F64    d9, #0
    VMRS        APSR_nzcv, FPSCR
    MOV         r1, #0
    BGE         SEGF_POS6
    @ negativo: inverte e marca sinal
    VNEG.F64    d14, d9
    MOV         r1, #1
    B           SEGF_POS6+4
SEGF_POS6:
    VMOV        d14, d9
    @ multiplica por 100 e trunca
    LDR         r5, =C5
    VLDR        d15, [r5]
    VMUL.F64    d15, d14, d15
    VCVT.S32.F64 s28, d15
    VMOV        r0, s28
    @ exibe 5 dígitos: HEX0-HEX1=casas decimais, HEX2-HEX4=parte inteira
    MOV     r0, r0
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS7
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS7:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP8:
    CMP     r6, #5
    BGE     SEG_DONE9
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C12
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
    BGE     SEG_HI10
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT11
SEG_HI10:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT11:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP8
SEG_DONE9:
    @ acende ponto decimal em HEX2 (bit 7 = 0x80, posição 16)
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    MOV     r6, #0x80
    LSL     r6, r6, #16
    ORR     r5, r5, r6
    STR     r5, [r4]
    @ sinal negativo em HEX5
    CMP         r1, #0
    BEQ         SEGF_SKIP_SINAL13
    LDR         r4, =0xFF200030
    LDR         r5, [r4]
    MOV         r6, #0x40
    LSL         r6, r6, #8
    ORR         r5, r5, r6
    STR         r5, [r4]
SEGF_SKIP_SINAL13:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_14
    LDR     r6, =_RES_SLOT_14
    VSTR    d9, [r6]
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
    @ exibe inteiro r2
    MOV     r0, r2
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS15
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS15:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP16:
    CMP     r6, #6
    BGE     SEG_DONE17
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C12
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
    BGE     SEG_HI18
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT19
SEG_HI18:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT19:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP16
SEG_DONE17:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_20
    LDR     r3, =_RES_SLOT_20
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

    @ === seven segment display ===
    @ float → display: d0 × 100 → inteiro com 2 casas decimais
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ detecta sinal
    VCMP.F64    d0, #0
    VMRS        APSR_nzcv, FPSCR
    MOV         r1, #0
    BGE         SEGF_POS21
    @ negativo: inverte e marca sinal
    VNEG.F64    d14, d0
    MOV         r1, #1
    B           SEGF_POS21+4
SEGF_POS21:
    VMOV        d14, d0
    @ multiplica por 100 e trunca
    LDR         r5, =C5
    VLDR        d15, [r5]
    VMUL.F64    d15, d14, d15
    VCVT.S32.F64 s28, d15
    VMOV        r0, s28
    @ exibe 5 dígitos: HEX0-HEX1=casas decimais, HEX2-HEX4=parte inteira
    MOV     r0, r0
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS22
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS22:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP23:
    CMP     r6, #5
    BGE     SEG_DONE24
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C12
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
    BGE     SEG_HI25
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT26
SEG_HI25:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT26:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP23
SEG_DONE24:
    @ acende ponto decimal em HEX2 (bit 7 = 0x80, posição 16)
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    MOV     r6, #0x80
    LSL     r6, r6, #16
    ORR     r5, r5, r6
    STR     r5, [r4]
    @ sinal negativo em HEX5
    CMP         r1, #0
    BEQ         SEGF_SKIP_SINAL27
    LDR         r4, =0xFF200030
    LDR         r5, [r4]
    MOV         r6, #0x40
    LSL         r6, r6, #8
    ORR         r5, r5, r6
    STR         r5, [r4]
SEGF_SKIP_SINAL27:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_28
    LDR     r2, =_RES_SLOT_28
    VSTR    d0, [r2]
    BKPT    #0   @ pausa — fim do bloco 2 (Continue no CPUlator para prosseguir)

    @ --- bloco 3: MEM ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]

    @ === seven segment display ===
    @ float → display: d0 × 100 → inteiro com 2 casas decimais
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ detecta sinal
    VCMP.F64    d0, #0
    VMRS        APSR_nzcv, FPSCR
    MOV         r1, #0
    BGE         SEGF_POS29
    @ negativo: inverte e marca sinal
    VNEG.F64    d14, d0
    MOV         r1, #1
    B           SEGF_POS29+4
SEGF_POS29:
    VMOV        d14, d0
    @ multiplica por 100 e trunca
    LDR         r5, =C5
    VLDR        d15, [r5]
    VMUL.F64    d15, d14, d15
    VCVT.S32.F64 s28, d15
    VMOV        r0, s28
    @ exibe 5 dígitos: HEX0-HEX1=casas decimais, HEX2-HEX4=parte inteira
    MOV     r0, r0
    @ limpa HEX0-HEX3 e HEX4-HEX5
    LDR     r4, =0xFF200020
    MOV     r5, #0
    STR     r5, [r4]
    LDR     r4, =0xFF200030
    STR     r5, [r4]
    @ testa sinal
    CMP     r0, #0
    BGE     SEG_POS30
    @ negativo: abs e traço em HEX5
    RSB     r0, r0, #0
    LDR     r4, =0xFF200030
    MOV     r5, #0x40
    LSL     r5, r5, #8
    STR     r5, [r4]
SEG_POS30:
    LDR     r1, =SEG7_TABLE
    MOV     r6, #0
SEG_LOOP31:
    CMP     r6, #5
    BGE     SEG_DONE32
    @ extrai próximo dígito via FPU
    VMOV         s30, r0
    VCVT.F64.S32 d15, s30
    LDR          r5, =C12
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
    BGE     SEG_HI33
    MOV     r5, r6
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
    B       SEG_NEXT34
SEG_HI33:
    SUB     r5, r6, #4
    LSL     r5, r5, #3
    LSL     r3, r3, r5
    LDR     r4, =0xFF200030
    LDR     r5, [r4]
    ORR     r5, r5, r3
    STR     r5, [r4]
SEG_NEXT34:
    ADD     r6, r6, #1
    CMP     r0, #0
    BNE     SEG_LOOP31
SEG_DONE32:
    @ acende ponto decimal em HEX2 (bit 7 = 0x80, posição 16)
    LDR     r4, =0xFF200020
    LDR     r5, [r4]
    MOV     r6, #0x80
    LSL     r6, r6, #16
    ORR     r5, r5, r6
    STR     r5, [r4]
    @ sinal negativo em HEX5
    CMP         r1, #0
    BEQ         SEGF_SKIP_SINAL35
    LDR         r4, =0xFF200030
    LDR         r5, [r4]
    MOV         r6, #0x40
    LSL         r6, r6, #8
    ORR         r5, r5, r6
    STR         r5, [r4]
SEGF_SKIP_SINAL35:
    @ === display atualizado ===
    @ persiste resultado final em _RES_SLOT_36
    LDR     r1, =_RES_SLOT_36
    VSTR    d0, [r1]

    B   .   @ halt