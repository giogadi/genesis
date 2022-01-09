PsgPort: equ $7F11
; pitch first
    ld c, 0
    ld de, 425

    ; We need the low 4 bits
    ; of the frequency first
    ld a, e
    and $0F
    ld b, a
    
    ; Build the 1st byte
    ld a, c
    rrca
    rrca
    rrca
    or b
    or $80
    
    ; Send 1st byte
    ld (PsgPort), a
    
    ; We need the upper six
    ; bits of frequency now
    ld a, e
    and $F0
    rrca
    rrca
    rrca
    rrca
    ld b, a
    ld a, d
    rlca
    rlca
    rlca
    rlca
    or a ,b
    
    ; Send 2nd byte
    ld (PsgPort),a

; volume next
    ld a, 0
    ld b, 0
    rrca
    rrca
    rrca
    or b
    or $90
    
    ld (PsgPort), a