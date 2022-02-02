SlimeVTable:
    dc.l SlimeUpdate
    dc.l SlimeMaybeHurtHero
    dc.l UtilEmptyFn
    dc.l SlimeDrawEnemy
    dc.l SlimeBlockHero
    dc.l SlimeLoad

SlimeUpdate:
    rts

SlimeMaybeHurtHero:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_ALIVE,d0
    bne .end
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

SlimeDrawEnemy:
    move.w N_ENEMY_STATE(a2),d0
    ; if dying, flicker sprite
    cmp.w #ENEMY_STATE_DYING,d0
    bne .DoDraw
    ; always draw sprite during hitstop
    tst.w HITSTOP_FRAMES_LEFT
    bgt .DoDraw
    ; otherwise, use frame counter to decide flicker
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d0
    btst.l #1,d0
    beq .End
.DoDraw
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d0 ; 2x2
    or.w SPRITE_COUNTER,d0 ; link to next sprite
    move.w N_ENEMY_Y(a2),d1
    sub.w N_ENEMY_HALF_H(a2),d1
    sub.w CAMERA_TOP_Y,d1
    add.w #MIN_DISPLAY_Y,d1
    move.w d1,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d0,LAST_LINK_WRITTEN
    move.w #SLIME_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d1
    sub.w N_ENEMY_HALF_W(a2),d1
    add.w #MIN_DISPLAY_X,d1
    move.w d1,vdp_data ; x
    bra.w .End
.End
    rts

SlimeBlockHero:
    move.b #0,d0
    rts

SlimeLoad:
    move.w #8,N_ENEMY_HALF_W(a2)
    move.w #8,N_ENEMY_HALF_H(a2)
    rts