RedSealVTable:
    dc.l RedSealUpdate
    dc.l UtilEmptyFn
    dc.l UtilEmptyFn
    dc.l RedSealDraw
    dc.l RedSealBlockHero

; a2: enemy struct start
; d2: don't touch
RedSealDraw:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_DYING,d0
    beq.s .DrawDying
    add.w #1,SPRITE_COUNTER
    move.w #$0E00,d0 ; 4x3
    or.w SPRITE_COUNTER,d0 ; link to next sprite
    move.w N_ENEMY_Y(a2),d1
    sub.w N_ENEMY_HALF_H(a2),d1
    sub.w CAMERA_TOP_Y,d1
    add.w #MIN_DISPLAY_Y,d1
    move.w d1,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d0,LAST_LINK_WRITTEN
    move.w #RED_SEAL_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d1
    sub.w N_ENEMY_HALF_W(a2),d1
    add.w #MIN_DISPLAY_X,d1
    move.w d1,vdp_data ; x
    bra.w .End
.DrawDying
.End
    rts

RedSealUpdate:
    rts

RedSealBlockHero:
    move.w NEW_Y,-(sp)
    move.w NEW_X,-(sp)
    move.w N_ENEMY_HALF_H(a2),-(sp)
    move.w N_ENEMY_Y(a2),-(sp)
    move.w N_ENEMY_HALF_W(a2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilMinAABBOverlapHero
    add.l #(6*2),sp
    tst.b d0
    blt.b .no_overlap
    ; overlap
    move.b #1,d0
    rts
.no_overlap
    move.b #0,d0
    rts