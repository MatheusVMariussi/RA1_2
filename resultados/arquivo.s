@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Sequência RPN: 8 expressão(ões)
@   [0] 1 3 * 15 2 + 4 - /
@   [1] 3 2 //
@   [2] 2 MEM
@   [3] MEM
@   [4] 2 RES
@   [5] 78 45 / 12 +
@   [6] MEM
@   [7] 8 5 *
.global _start

.section .data

C0:  .double 1
C1:  .double 3
C2:  .double 15
C3:  .double 2
C4:  .double 4
C6:  .double 10.0
C7:  .double 0.5

@ slot de persistência — expressão '1 3 * 15 2 + 4 - /'
_RES_SLOT_12:  .double 0.0

@ slot de persistência — expressão '3 2 //'
_RES_SLOT_18:  .double 0.0
MEM_MEM:  .double 0.0  @ variável MEM

@ slot de persistência — expressão '2 MEM'
_RES_SLOT_24:  .double 0.0

@ slot de persistência — expressão 'MEM'
_RES_SLOT_30:  .double 0.0

@ slot de persistência — expressão '2 RES'
_RES_SLOT_36:  .double 0.0
C37:  .double 78
C38:  .double 45
C39:  .double 12

@ slot de persistência — expressão '78 45 / 12 +'
_RES_SLOT_45:  .double 0.0

@ slot de persistência — expressão 'MEM'
_RES_SLOT_51:  .double 0.0
C52:  .double 8
C53:  .double 5

@ slot de persistência — expressão '8 5 *'
_RES_SLOT_59:  .double 0.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

.section .text
_start:

    @ --- bloco 0: 1 3 * 15 2 + 4 - / ---
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
    @ d2 / d7 → d8
    VDIV.F64  d8, d2, d7

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d8, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG8
    VADD.F64    d30, d30, d31
    B           ROUND_END9
ROUND_NEG8:
    VSUB.F64    d30, d30, d31
ROUND_END9:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop5:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop10:
    CMP     r5, r3
    BLT     div_end11
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop10
div_end11:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop5
    ORR     r2, r2, #0x80
no_dot_seg_loop5:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop5
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_12
    LDR     r5, =_RES_SLOT_12
    VSTR    d8, [r5]
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
    @ double→int seguro: d2 → r2
    VMOV.F64    d30, d2
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG13
    VADD.F64    d30, d30, d31
    B           ROUND_END14
ROUND_NEG13:
    VSUB.F64    d30, d30, d31
ROUND_END14:
    VCVT.S32.F64 s28, d30
    VMOV         r2, s28

    MOV     r10, r2
    MOV     r11, #0
    MOV     r6, #0
seg_loop15:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop16:
    CMP     r5, r3
    BLT     div_end17
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop16
div_end17:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop15
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_18
    LDR     r3, =_RES_SLOT_18
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

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d0, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG20
    VADD.F64    d30, d30, d31
    B           ROUND_END21
ROUND_NEG20:
    VSUB.F64    d30, d30, d31
ROUND_END21:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop19:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop22:
    CMP     r5, r3
    BLT     div_end23
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop22
div_end23:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop19
    ORR     r2, r2, #0x80
no_dot_seg_loop19:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop19
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_24
    LDR     r2, =_RES_SLOT_24
    VSTR    d0, [r2]
    BKPT    #0   @ pausa — fim do bloco 2 (Continue no CPUlator para prosseguir)

    @ --- bloco 3: MEM ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d0, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG26
    VADD.F64    d30, d30, d31
    B           ROUND_END27
ROUND_NEG26:
    VSUB.F64    d30, d30, d31
ROUND_END27:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop25:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop28:
    CMP     r5, r3
    BLT     div_end29
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop28
div_end29:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop25
    ORR     r2, r2, #0x80
no_dot_seg_loop25:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop25
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_30
    LDR     r1, =_RES_SLOT_30
    VSTR    d0, [r1]
    BKPT    #0   @ pausa — fim do bloco 3 (Continue no CPUlator para prosseguir)

    @ --- bloco 4: 2 RES ---
    @ carrega 2 → d0
    LDR     r0, =C3
    VLDR    d0, [r0]
    @ RES(2): copia reg vivo d0 → d0
    VMOV    d0, d0

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d0, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG32
    VADD.F64    d30, d30, d31
    B           ROUND_END33
ROUND_NEG32:
    VSUB.F64    d30, d30, d31
ROUND_END33:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop31:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop34:
    CMP     r5, r3
    BLT     div_end35
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop34
div_end35:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop31
    ORR     r2, r2, #0x80
no_dot_seg_loop31:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop31
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_36
    LDR     r0, =_RES_SLOT_36
    VSTR    d0, [r0]
    BKPT    #0   @ pausa — fim do bloco 4 (Continue no CPUlator para prosseguir)

    @ --- bloco 5: 78 45 / 12 + ---
    @ carrega 78 → d0
    LDR     r0, =C37
    VLDR    d0, [r0]
    @ carrega 45 → d1
    LDR     r1, =C38
    VLDR    d1, [r1]
    @ d0 / d1 → d2
    VDIV.F64  d2, d0, d1
    @ carrega 12 → d3
    LDR     r2, =C39
    VLDR    d3, [r2]
    @ d2 + d3 → d4
    VADD.F64  d4, d2, d3

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d4, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG41
    VADD.F64    d30, d30, d31
    B           ROUND_END42
ROUND_NEG41:
    VSUB.F64    d30, d30, d31
ROUND_END42:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop40:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop43:
    CMP     r5, r3
    BLT     div_end44
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop43
div_end44:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop40
    ORR     r2, r2, #0x80
no_dot_seg_loop40:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop40
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_45
    LDR     r3, =_RES_SLOT_45
    VSTR    d4, [r3]
    BKPT    #0   @ pausa — fim do bloco 5 (Continue no CPUlator para prosseguir)

    @ --- bloco 6: MEM ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d0, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG47
    VADD.F64    d30, d30, d31
    B           ROUND_END48
ROUND_NEG47:
    VSUB.F64    d30, d30, d31
ROUND_END48:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop46:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop49:
    CMP     r5, r3
    BLT     div_end50
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop49
div_end50:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop46
    ORR     r2, r2, #0x80
no_dot_seg_loop46:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop46
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_51
    LDR     r1, =_RES_SLOT_51
    VSTR    d0, [r1]
    BKPT    #0   @ pausa — fim do bloco 6 (Continue no CPUlator para prosseguir)

    @ --- bloco 7: 8 5 * ---
    @ carrega 8 → d0
    LDR     r0, =C52
    VLDR    d0, [r0]
    @ carrega 5 → d1
    LDR     r1, =C53
    VLDR    d1, [r1]
    @ d0 * d1 → d2
    VMUL.F64  d2, d0, d1

    LDR     r12, =C6
    VLDR    d31, [r12]
    VMUL.F64 d30, d2, d31
    @ double→int seguro: d30 → r10
    VMOV.F64    d30, d30
    LDR         r12, =C7
    VLDR        d31, [r12]
    VCMP.F64    d30, #0
    VMRS        APSR_nzcv, FPSCR
    BLT         ROUND_NEG55
    VADD.F64    d30, d30, d31
    B           ROUND_END56
ROUND_NEG55:
    VSUB.F64    d30, d30, d31
ROUND_END56:
    VCVT.S32.F64 s28, d30
    VMOV         r10, s28
    MOV     r11, #0
    MOV     r6, #0
seg_loop54:
    MOV     r3, #10
    MOV     r4, #0
    MOV     r5, r10
div_loop57:
    CMP     r5, r3
    BLT     div_end58
    SUB     r5, r5, r3
    ADD     r4, r4, #1
    B       div_loop57
div_end58:
    MOV     r0, r5
    BL      digit_to_7seg
    MOV     r2, r0
    CMP     r6, #0
    BNE     no_dot_seg_loop54
    ORR     r2, r2, #0x80
no_dot_seg_loop54:
    MOV     r7, r6
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    ADD     r7, r7, r7
    MOV     r8, r2
    LSL     r8, r8, r7
    ORR     r11, r11, r8
    MOV     r10, r4
    ADD     r6, r6, #1
    CMP     r10, #0
    BNE     seg_loop54
    LDR     r0, =0xFF200020
    STR     r11, [r0]
    @ persiste resultado final em _RES_SLOT_59
    LDR     r2, =_RES_SLOT_59
    VSTR    d2, [r2]

    B   .   @ halt

@ -------- função auxiliar --------
digit_to_7seg:
    PUSH {r1, lr}
    LDR  r1, =SEG7_TABLE
    LDRB r0, [r1, r0]
    POP  {r1, lr}
    BX   lr