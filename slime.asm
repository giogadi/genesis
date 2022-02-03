SlimeVTable:
    dc.l SlimeUpdate
    dc.l SlimeMaybeHurtHero
    dc.l UtilEmptyFn
    dc.l SlimeDrawEnemy
    dc.l SlimeBlockHero
    dc.l SlimeLoad

SLIME_MOVING_FRAMES: equ 60
SLIME_STOPPED_FRAMES: equ 60
SLIME_WALK_SPEED: equ (ONE_PIXEL_LONG_UNIT/2)

; ENEMY_DATA1: 0000 0000 0000 000(moving_state,1)
; ENEMY_DATA2: 0000 0000 0000 000(move_left,1)
; ENEMY_DATA3: 0000 0000 0000 000(new_state,1)

SLIME_STATE_DYING: equ 1
SLIME_STATE_MOVING: equ 2
SLIME_STATE_STOPPED: equ 3

; \1: entity pointer
M_SlimeTestNewState: macro
    tst.b (N_ENEMY_DATA3+1)(\1)
    endm

M_SlimeClearNewState: macro
    and.b #$FE,(N_ENEMY_DATA3+1)(\1)
    endm

M_SlimeSetNewState: macro
    or.b #$01,(N_ENEMY_DATA3+1)(\1)
    endm

M_SlimeFlipDirection: macro
    bchg.b #0,(N_ENEMY_DATA2+1)(\1)
    endm

M_SlimeTestIsLeft: macro
    btst.b #0,(N_ENEMY_DATA2+1)(\1)
    endm

SlimeUpdate:
    jsr SlimeUpdateFromSlash
.StartUpdate
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Dead,.Dying,.Moving,.Stopped
.Dead:
    ; shouldn't happen
    rts
.Dying:
    jsr SlimeDyingUpdate
    bra .End
.Moving:
    jsr SlimeMovingUpdate
    bra .End
.Stopped:
    jsr SlimeStoppedUpdate
    bra .End
.End
    M_SlimeTestNewState a2
    bne .StartUpdate
    rts

SlimeDyingUpdate:
    M_SlimeTestNewState a2
    beq .AfterNewState
    move.w #ENEMY_DYING_FRAMES,N_ENEMY_STATE_FRAMES_LEFT(a2)
    M_SlimeClearNewState a2
.AfterNewState
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .AfterTransition
    ; transition to dead
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
    rts
.AfterTransition
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    rts

SlimeMovingUpdate:
    M_SlimeTestNewState a2
    beq .AfterNewState
    ; pick a direction to move in
    M_SlimeFlipDirection a2
    move.w #SLIME_MOVING_FRAMES,N_ENEMY_STATE_FRAMES_LEFT(a2)
    M_SlimeClearNewState a2
.AfterNewState
    ; check if we should transition to stopped
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .AfterTransition
    move.w #SLIME_STATE_STOPPED,N_ENEMY_STATE(a2)
    M_SlimeSetNewState a2
    rts
.AfterTransition
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    M_SlimeTestIsLeft a2
    beq .GoRight
    ; going left
    sub.l #SLIME_WALK_SPEED,N_ENEMY_X(a2)
    rts
.GoRight
    add.l #SLIME_WALK_SPEED,N_ENEMY_X(a2)
    rts

SlimeStoppedUpdate:
    M_SlimeTestNewState a2
    beq .AfterNewState
    move.w #SLIME_STOPPED_FRAMES,N_ENEMY_STATE_FRAMES_LEFT(a2)
    M_SlimeClearNewState a2
.AfterNewState
    ; check if we should transition to moving
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .AfterTransition
    move.w #SLIME_STATE_MOVING,N_ENEMY_STATE(a2)
    M_SlimeSetNewState a2
    rts
.AfterTransition
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    rts

SlimeUpdateFromSlash:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #SLIME_STATE_DYING,d0
    beq .Done
    jsr UtilIsEnemyHitBySlash
    beq .Done
    ; Enemy is hit! switch to dying and activate hitstop.
    move.w #SLIME_STATE_DYING,N_ENEMY_STATE(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    M_SlimeSetNewState a2
.Done
    rts

SlimeMaybeHurtHero:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #SLIME_STATE_DYING,d0
    beq .end
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
    cmp.w #SLIME_STATE_DYING,d0
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
    move.w #SLIME_STATE_MOVING,N_ENEMY_STATE(a2)
    rts