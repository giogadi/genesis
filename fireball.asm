FireballVTable:
    dc.l FireballUpdate
    dc.l FireballMaybeHurtHero
    dc.l UtilEmptyFn
    dc.l FireballDraw
    dc.l UtilReturnFalse
    dc.l FireballLoad

; ENEMY_DATA_1: 0000 0000 0000 0000
; ENEMY_DATA_2: 0000 0000 0000 0000

FIREBALL_SPEED: equ (65536/2) ; 1 pixel per frame

; a2: entity struct
; d2: not allowed
FireballUpdate:
    add.l #FIREBALL_SPEED,N_ENEMY_Y(a2)
    rts

; a2: enemy struct start
; d2: don't touch
FireballDraw:
    add.w #1,SPRITE_COUNTER
    move.w #0,d0 ; 1x1
    or.w SPRITE_COUNTER,d0 ; link to next sprite
    move.w N_ENEMY_Y(a2),d1
    sub.w N_ENEMY_HALF_H(a2),d1
    sub.w CAMERA_TOP_Y,d1
    add.w #MIN_DISPLAY_Y,d1
    move.w d1,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d0,LAST_LINK_WRITTEN
    move.w #FIREBALL_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d1
    sub.w N_ENEMY_HALF_W(a2),d1
    add.w #MIN_DISPLAY_X,d1
    move.w d1,vdp_data ; x
    bra.w .End
.End
    rts

FireballMaybeHurtHero:
    move.w CURRENT_Y,-(sp)
    move.w CURRENT_X,-(sp)
    move.w N_ENEMY_HALF_H(a2),-(sp)
    move.w N_ENEMY_Y(a2),-(sp)
    move.w N_ENEMY_HALF_W(a2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilMinAABBOverlapHero
    add.l #(6*2),sp
    tst.b d0
    blt.b .end
    ; overlap
    move.w #HERO_STATE_HURT,HERO_STATE
    move.w #1,HERO_NEW_STATE
    move.b d0,(HURT_DIRECTION+1)
.end
    rts

FireballLoad
    move.w #4,N_ENEMY_HALF_W(a2)
    move.w #4,N_ENEMY_HALF_H(a2)
    move.w #1,N_ENEMY_HP(a2)
    clr.w N_ENEMY_DATA1(a2)
    clr.w N_ENEMY_DATA2(a2)
    rts