FireballVTable:
    dc.l FireballUpdate
    dc.l FireballMaybeHurtHero
    dc.l UtilEmptyFn
    dc.l FireballDraw
    dc.l UtilReturnFalse
    dc.l FireballLoad

; alive
; ENEMY_DATA1.l: x velocity
; ENEMY_DATA3.l: y velocity

; dying
; ENEMY_DATA1.b: new state

; a2: entity struct
; d2: not allowed
FireballUpdate:
    ; check if fireball is outside of camera view + some padding
    move.w N_ENEMY_Y(a2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilPointInCameraView
    add.w #4,sp
    tst.b d0
    bne .StillInView
    ; fireball is outside of view! despawn it.
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
    rts
.StillInView
    ; If enemy is dying, do dying update
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_DYING,d0
    bne .Alive
    tst.b N_ENEMY_DATA1(a2) ; new state?
    beq .AfterNewDyingState
    move.w #ENEMY_DYING_FRAMES,N_ENEMY_STATE_FRAMES_LEFT(a2)
    move.b #0,N_ENEMY_DATA1(a2)
.AfterNewDyingState
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .StillDying
    ; transition to dead.
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
    rts
.StillDying
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    rts
.Alive
    ; Check if hero is slashing the fireball.
    jsr UtilIsEnemyHitBySlash
    tst.b d0
    beq .NotSlashed
    ; hit by slash. set to dying and add hitstop
    move.w #ENEMY_STATE_DYING,N_ENEMY_STATE(a2)
    move.b #1,N_ENEMY_DATA1(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    rts
.NotSlashed
    move.l N_ENEMY_X(a2),d0
    add.l N_ENEMY_DATA1(a2),d0
    move.l d0,N_ENEMY_X(a2)
    move.l N_ENEMY_Y(a2),d0
    add.l N_ENEMY_DATA3(a2),d0
    move.l d0,N_ENEMY_Y(a2)
    rts

; a2: enemy struct start
; d2: don't touch
FireballDraw:
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
    ; overlap.
    ; check if hero is in parry state (TODO: ALSO CHECK THAT HERO PARRIED IN CORRECT DIRECTION)
    move.w HERO_STATE,d1
    cmp.w #HERO_STATE_PARRY_ACTIVE,d1
    bne .NotParry
    ; parry
    move.w #HERO_STATE_PARRY_SUCCESS_RECOVERY,HERO_STATE
    move.w #1,HERO_NEW_STATE
    ; when we parry, hero "kills" fireball like an enemy.
    move.w #ENEMY_STATE_DYING,N_ENEMY_STATE(a2)
    bra .end
.NotParry
    ; hurt hero.
    move.w #HERO_STATE_HURT,HERO_STATE
    move.w #1,HERO_NEW_STATE
    move.b d0,(HURT_DIRECTION+1)
    ; when we hit hero, fireball just disappears. TODO maybe do an explosion or smth
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
.end
    rts

FireballLoad
    move.w #3,N_ENEMY_HALF_W(a2)
    move.w #3,N_ENEMY_HALF_H(a2)
    move.w #1,N_ENEMY_HP(a2)
    clr.l N_ENEMY_DATA1(a2)
    clr.l N_ENEMY_DATA3(a2)
    rts