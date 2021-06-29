FM_PART1_ADDR: equ $A04000
FM_PART1_DATA: equ $A04001
FM_PART2_ADDR: equ $A04002
FM_PART2_DATA: equ $A04003

    clr.b d1

; Before writing, read an address to check that it's not busy
    jsr WaitUntilFmNotBusy

; LFO off
    move.b #$22,FM_PART1_ADDR
    move.b #0,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Channel 3 mode normal
    move.b #$27,FM_PART1_ADDR
    move.b #0,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$28,FM_PART1_ADDR
    move.b #0,FM_PART1_DATA

    jsr WaitUntilFmNotBusy
    
    move.b #$28,FM_PART1_ADDR
    move.b #1,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$28,FM_PART1_ADDR
    move.b #2,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$28,FM_PART1_ADDR
    move.b #3,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$28,FM_PART1_ADDR
    move.b #4,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$28,FM_PART1_ADDR
    move.b #5,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$28,FM_PART1_ADDR
    move.b #6,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; DAC off
    move.b #$2B,FM_PART1_ADDR
    move.b #0,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; DT1/MUL (lol wat?)
    move.b #$30,FM_PART1_ADDR
    move.b #$71,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$34,FM_PART1_ADDR
    move.b #$0D,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$38,FM_PART1_ADDR
    move.b #$33,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$3C,FM_PART1_ADDR
    move.b #$01,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Total Level
    move.b #$40,FM_PART1_ADDR
    move.b #$23,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$44,FM_PART1_ADDR
    move.b #$2D,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$48,FM_PART1_ADDR
    move.b #$26,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$4C,FM_PART1_ADDR
    move.b #$00,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; RS/AR
    move.b #$50,FM_PART1_ADDR
    move.b #$5F,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$54,FM_PART1_ADDR
    move.b #$99,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$58,FM_PART1_ADDR
    move.b #$5F,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$5C,FM_PART1_ADDR
    move.b #$94,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; AM/D1R
    move.b #$60,FM_PART1_ADDR
    move.b #$05,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$64,FM_PART1_ADDR
    move.b #$05,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$68,FM_PART1_ADDR
    move.b #$05,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$6C,FM_PART1_ADDR
    move.b #$07,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; D2R
    move.b #$70,FM_PART1_ADDR
    move.b #$02,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$74,FM_PART1_ADDR
    move.b #$02,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$78,FM_PART1_ADDR
    move.b #$02,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$7C,FM_PART1_ADDR
    move.b #$02,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; D1L/RR
    move.b #$80,FM_PART1_ADDR
    move.b #$11,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$84,FM_PART1_ADDR
    move.b #$11,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$88,FM_PART1_ADDR
    move.b #$11,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$8C,FM_PART1_ADDR
    move.b #$A6,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Proprietary
    move.b #$90,FM_PART1_ADDR
    move.b #$00,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$94,FM_PART1_ADDR
    move.b #$00,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$98,FM_PART1_ADDR
    move.b #$00,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$9C,FM_PART1_ADDR
    move.b #$00,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Feedback/Algorithm
    move.b #$B0,FM_PART1_ADDR
    move.b #$32,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Both speakers on
    move.b #$B4,FM_PART1_ADDR
    move.b #$C0,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Key off
    move.b #$28,FM_PART1_ADDR
    move.b #$00,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Set frequency
    move.b #$A4,FM_PART1_ADDR
    move.b #$22,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

    move.b #$A0,FM_PART1_ADDR
    move.b #$69,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Key on
    move.b #$28,FM_PART1_ADDR
    move.b #$F0,FM_PART1_DATA

    jsr WaitUntilFmNotBusy

; Key off