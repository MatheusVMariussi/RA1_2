@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)
@ Sequência RPN: 10 expressão(ões)
@   [0] 2 5 * 18 3 / +
@   [1] 4 3 ^
@   [2] MEM
@   [3] MEM 6 + 9 3 / *
@   [4] 7 2 //
@   [5] 14 2 * 8 3 - /
@   [6] MEM
@   [7] 5 5 ^ 2 10 + -
@   [8] 6 RES
@   [9] MEM 2 ^ 6 4 % +
.global _start

.section .data

C0:  .double 2
C1:  .double 5
C2:  .double 18
C3:  .double 3

@ slot de persistência — expressão '2 5 * 18 3 / +'
_RES_SLOT_4:  .double 0.0
C5:  .double 4
C6:  .double 1.0

@ slot de persistência — expressão '4 3 ^'
_RES_SLOT_9:  .double 0.0
MEM_MEM:  .double 0.0  @ variável MEM

@ slot de persistência — expressão 'MEM'
_RES_SLOT_10:  .double 0.0
C11:  .double 6
C12:  .double 9

@ slot de persistência — expressão 'MEM 6 + 9 3 / *'
_RES_SLOT_13:  .double 0.0
C14:  .double 7

@ slot de persistência — expressão '7 2 //'
_RES_SLOT_15:  .double 0.0
C16:  .double 14
C17:  .double 8

@ slot de persistência — expressão '14 2 * 8 3 - /'
_RES_SLOT_18:  .double 0.0

@ slot de persistência — expressão 'MEM'
_RES_SLOT_19:  .double 0.0
C22:  .double 10

@ slot de persistência — expressão '5 5 ^ 2 10 + -'
_RES_SLOT_23:  .double 0.0

@ slot de persistência — expressão '6 RES'
_RES_SLOT_24:  .double 0.0

@ slot de persistência — expressão 'MEM 2 ^ 6 4 % +'
_RES_SLOT_27:  .double 0.0

@ gfedcba: dígitos 0-9
SEG7_TABLE:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
             .byte 0x00   @ vazio
             .byte 0x40   @ traço
             .align 2

@ uart constants
UART_FLOAT10:  .double 10.0
UART_HALF:     .double 0.5

.section .text
_start:

    @ --- bloco 0: 2 5 * 18 3 / + ---
    @ carrega 2 → d0
    LDR     r0, =C0
    VLDR    d0, [r0]
    @ carrega 5 → d1
    LDR     r0, =C1
    VLDR    d1, [r0]
    @ d0 * d1 → d2
    VMUL.F64  d2, d0, d1
    @ carrega 18 → d3
    LDR     r0, =C2
    VLDR    d3, [r0]
    @ carrega 3 → d4
    LDR     r0, =C3
    VLDR    d4, [r0]
    @ d3 / d4 → d5
    VDIV.F64  d5, d3, d4
    @ d2 + d5 → d6
    VADD.F64  d6, d2, d5

    @ persiste resultado final em _RES_SLOT_4
    LDR     r0, =_RES_SLOT_4
    VSTR    d6, [r0]

    @ === JTAG UART output ===
    VMOV.F64    d0, d6
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 0 (Continue no CPUlator para prosseguir)

    @ --- bloco 1: 4 3 ^ ---
    @ carrega 4 → d0
    LDR     r0, =C5
    VLDR    d0, [r0]
    @ carrega 3 → d1
    LDR     r0, =C3
    VLDR    d1, [r0]
    @ double→int (truncate): d1 → r0
    VMOV.F64    d30, d1
    VCVT.S32.F64 s28, d30
    VMOV         r0, s28
    @ d0 ^ r0 → d2
    LDR      r2, =C6
    VLDR     d2, [r2]
    MOV      r1, r0
POW_LP7:
    CMP      r1, #0
    BLE      POW_END8
    VMUL.F64 d2, d2, d0
    SUB      r1, r1, #1
    B        POW_LP7
POW_END8:

    @ persiste resultado final em _RES_SLOT_9
    LDR     r3, =_RES_SLOT_9
    VSTR    d2, [r3]

    @ === JTAG UART output ===
    VMOV.F64    d0, d2
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 1 (Continue no CPUlator para prosseguir)

    @ --- bloco 2: MEM ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]

    @ persiste resultado final em _RES_SLOT_10
    LDR     r0, =_RES_SLOT_10
    VSTR    d0, [r0]

    @ === JTAG UART output ===
    VMOV.F64    d0, d0
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 2 (Continue no CPUlator para prosseguir)

    @ --- bloco 3: MEM 6 + 9 3 / * ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]
    @ carrega 6 → d1
    LDR     r0, =C11
    VLDR    d1, [r0]
    @ d0 + d1 → d2
    VADD.F64  d2, d0, d1
    @ carrega 9 → d3
    LDR     r0, =C12
    VLDR    d3, [r0]
    @ carrega 3 → d4
    LDR     r0, =C3
    VLDR    d4, [r0]
    @ d3 / d4 → d5
    VDIV.F64  d5, d3, d4
    @ d2 * d5 → d6
    VMUL.F64  d6, d2, d5

    @ persiste resultado final em _RES_SLOT_13
    LDR     r0, =_RES_SLOT_13
    VSTR    d6, [r0]

    @ === JTAG UART output ===
    VMOV.F64    d0, d6
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 3 (Continue no CPUlator para prosseguir)

    @ --- bloco 4: 7 2 // ---
    @ carrega 7 → d0
    LDR     r0, =C14
    VLDR    d0, [r0]
    @ carrega 2 → d1
    LDR     r0, =C0
    VLDR    d1, [r0]
    @ divisão inteira FPU: d0 // d1 → d2 (r0)
    VDIV.F64    d2, d0, d1
    @ double→int (truncate): d2 → r0
    VMOV.F64    d30, d2
    VCVT.S32.F64 s28, d30
    VMOV         r0, s28

    @ persiste resultado final em _RES_SLOT_15
    LDR     r1, =_RES_SLOT_15
    VMOV         s28, r0
    VCVT.F64.S32 d14, s28
    VSTR         d14, [r1]

    @ === JTAG UART output ===
    MOV         r0, r0
    ASR         r1, r0, #31
    BL          uart_print_int64
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 4 (Continue no CPUlator para prosseguir)

    @ --- bloco 5: 14 2 * 8 3 - / ---
    @ carrega 14 → d0
    LDR     r0, =C16
    VLDR    d0, [r0]
    @ carrega 2 → d1
    LDR     r0, =C0
    VLDR    d1, [r0]
    @ d0 * d1 → d2
    VMUL.F64  d2, d0, d1
    @ carrega 8 → d3
    LDR     r0, =C17
    VLDR    d3, [r0]
    @ carrega 3 → d4
    LDR     r0, =C3
    VLDR    d4, [r0]
    @ d3 - d4 → d5
    VSUB.F64  d5, d3, d4
    @ d2 / d5 → d6
    VDIV.F64  d6, d2, d5

    @ persiste resultado final em _RES_SLOT_18
    LDR     r0, =_RES_SLOT_18
    VSTR    d6, [r0]

    @ === JTAG UART output ===
    VMOV.F64    d0, d6
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 5 (Continue no CPUlator para prosseguir)

    @ --- bloco 6: MEM ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]

    @ persiste resultado final em _RES_SLOT_19
    LDR     r0, =_RES_SLOT_19
    VSTR    d0, [r0]

    @ === JTAG UART output ===
    VMOV.F64    d0, d0
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 6 (Continue no CPUlator para prosseguir)

    @ --- bloco 7: 5 5 ^ 2 10 + - ---
    @ carrega 5 → d0
    LDR     r0, =C1
    VLDR    d0, [r0]
    @ carrega 5 → d1
    LDR     r0, =C1
    VLDR    d1, [r0]
    @ double→int (truncate): d1 → r0
    VMOV.F64    d30, d1
    VCVT.S32.F64 s28, d30
    VMOV         r0, s28
    @ d0 ^ r0 → d2
    LDR      r2, =C6
    VLDR     d2, [r2]
    MOV      r1, r0
POW_LP20:
    CMP      r1, #0
    BLE      POW_END21
    VMUL.F64 d2, d2, d0
    SUB      r1, r1, #1
    B        POW_LP20
POW_END21:
    @ carrega 2 → d3
    LDR     r3, =C0
    VLDR    d3, [r3]
    @ carrega 10 → d4
    LDR     r3, =C22
    VLDR    d4, [r3]
    @ d3 + d4 → d5
    VADD.F64  d5, d3, d4
    @ d2 - d5 → d6
    VSUB.F64  d6, d2, d5

    @ persiste resultado final em _RES_SLOT_23
    LDR     r3, =_RES_SLOT_23
    VSTR    d6, [r3]

    @ === JTAG UART output ===
    VMOV.F64    d0, d6
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 7 (Continue no CPUlator para prosseguir)

    @ --- bloco 8: 6 RES ---
    @ carrega 6 → d0
    LDR     r0, =C11
    VLDR    d0, [r0]
    LDR     r0, =_RES_SLOT_10
    VLDR    d0, [r0]

    @ persiste resultado final em _RES_SLOT_24
    LDR     r0, =_RES_SLOT_24
    VSTR    d0, [r0]

    @ === JTAG UART output ===
    VMOV.F64    d0, d0
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc
    BKPT    #0   @ pausa — fim do bloco 8 (Continue no CPUlator para prosseguir)

    @ --- bloco 9: MEM 2 ^ 6 4 % + ---
    @ lê MEM → d0
    LDR     r0, =MEM_MEM
    VLDR    d0, [r0]
    @ carrega 2 → d1
    LDR     r0, =C0
    VLDR    d1, [r0]
    @ double→int (truncate): d1 → r0
    VMOV.F64    d30, d1
    VCVT.S32.F64 s28, d30
    VMOV         r0, s28
    @ d0 ^ r0 → d2
    LDR      r2, =C6
    VLDR     d2, [r2]
    MOV      r1, r0
POW_LP25:
    CMP      r1, #0
    BLE      POW_END26
    VMUL.F64 d2, d2, d0
    SUB      r1, r1, #1
    B        POW_LP25
POW_END26:
    @ carrega 6 → d3
    LDR     r3, =C11
    VLDR    d3, [r3]
    @ carrega 4 → d4
    LDR     r3, =C5
    VLDR    d4, [r3]
    @ divisão inteira FPU: d3 // d4 → d5 (r3)
    VDIV.F64    d5, d3, d4
    @ double→int (truncate): d5 → r3
    VMOV.F64    d30, d5
    VCVT.S32.F64 s28, d30
    VMOV         r3, s28
    @ módulo: reconverte quociente truncado → double
    VMOV         s12, r3
    VCVT.F64.S32 d6, s12
    VMUL.F64 d7, d6, d4
    VSUB.F64 d8, d3, d7
    @ double→int (truncate): d8 → r4
    VMOV.F64    d30, d8
    VCVT.S32.F64 s28, d30
    VMOV         r4, s28
    @ int→float: r4 → d9
    VMOV         s18, r4
    VCVT.F64.S32 d9, s18
    @ d2 + d9 → d10
    VADD.F64  d10, d2, d9

    @ persiste resultado final em _RES_SLOT_27
    LDR     r5, =_RES_SLOT_27
    VSTR    d10, [r5]

    @ === JTAG UART output ===
    VMOV.F64    d0, d10
    BL          uart_print_float1
    MOV         r0, #10
    BL          uart_putc

    B   .   @ halt


@ -------- UART helpers --------
uart_putc:
    PUSH {r1, r2, lr}
    LDR  r1, =0xFF201000
uart_putc_wait:
    LDR  r2, [r1, #4]
    LSR  r2, r2, #16
    BEQ  uart_putc_wait
    STRB r0, [r1]
    POP  {r1, r2, lr}
    BX   lr

uart_udivmod10_u64:
    PUSH {r3-r9, lr}
    MOV  r3, #0
    MOV  r4, #0
    MOV  r5, #0
    MOV  r6, r0
    MOV  r7, r1
    MOV  r8, #64
uart_udivmod10_u64_loop:
    MOV  r9, r7, LSR #31
    LSLS r6, r6, #1
    ADC  r7, r7, r7
    LSLS r3, r3, #1
    ADC  r4, r4, r4
    ADD  r5, r5, r5
    ADD  r5, r5, r9
    CMP  r5, #10
    SUBCS r5, r5, #10
    ORRCS r3, r3, #1
    SUBS r8, r8, #1
    BNE  uart_udivmod10_u64_loop
    MOV  r0, r3
    MOV  r1, r4
    MOV  r2, r5
    POP  {r3-r9, lr}
    BX   lr

uart_print_u64:
    PUSH {r4, r5, r6, r7, lr}
    CMP  r1, #0
    BNE  uart_print_u64_rec
    CMP  r0, #10
    BLT  uart_print_u64_digit
uart_print_u64_rec:
    BL   uart_udivmod10_u64
    MOV  r4, r2
    MOV  r5, r0
    MOV  r6, r1
    MOV  r0, r5
    MOV  r1, r6
    BL   uart_print_u64
    MOV  r0, r4
    ADD  r0, r0, #'0'
    BL   uart_putc
    POP  {r4, r5, r6, r7, lr}
    BX   lr
uart_print_u64_digit:
    ADD  r0, r0, #'0'
    BL   uart_putc
    POP  {r4, r5, r6, r7, lr}
    BX   lr

uart_print_int64:
    PUSH {r4, r5, r6, r7, lr}
    MOV  r4, r0
    MOV  r5, r1
    CMP  r5, #0
    BGE  uart_print_int64_pos
    MOV  r0, #'-'
    BL   uart_putc
    RSBS r4, r4, #0
    RSC  r5, r5, #0
uart_print_int64_pos:
    MOV  r0, r4
    MOV  r1, r5
    BL   uart_print_u64
    POP  {r4, r5, r6, r7, lr}
    BX   lr

uart_print_int:
    ASR  r1, r0, #31
    B    uart_print_int64

uart_print_float1:
    PUSH {r4, r5, r6, r7, lr}
    VCMP.F64    d0, #0
    VMRS        APSR_nzcv, FPSCR
    MOV         r4, #0
    BGE         uart_float_abs_ok
    MOV         r4, #1
    VNEG.F64    d0, d0
uart_float_abs_ok:
    LDR         r5, =UART_FLOAT10
    VLDR        d1, [r5]
    VMUL.F64    d0, d0, d1
    LDR         r5, =UART_HALF
    VLDR        d1, [r5]
    VADD.F64    d0, d0, d1
    VCVT.S32.F64 s0, d0
    VMOV        r0, s0
    MOV         r1, #0
    BL          uart_udivmod10_u64
    MOV         r5, r0
    MOV         r6, r1
    MOV         r7, r2
    CMP         r4, #0
    BEQ         uart_float_print_num
    MOV         r0, #'-'
    BL          uart_putc
uart_float_print_num:
    MOV         r0, r5
    MOV         r1, r6
    BL          uart_print_u64
    MOV         r0, #'.'
    BL          uart_putc
    ADD         r0, r7, #'0'
    BL          uart_putc
    POP         {r4, r5, r6, r7, lr}
    BX          lr

@ -------- função auxiliar --------
digit_to_7seg:
    PUSH {r1, lr}
    LDR  r1, =SEG7_TABLE
    LDRB r0, [r1, r0]
    POP  {r1, lr}
    BX   lr