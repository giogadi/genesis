HotDogVTable:
    dc.l HotDogUpdate
    dc.l HotDogMaybeHurtHero
    dc.l UtilEmptyFn
    dc.l HotDogDrawEnemy
    dc.l HotDogBlockHero
    dc.l HotDogLoad

HOT_DOG_SLASHING: equ 0
HOT_DOG_RECOVERY: equ 1

HOT_DOG_SLASH_DURATION: equ 10
HOT_DOG_RECOVERY_DURATION: equ 30

HOT_DOG_SLASH_SPEED: equ 4

; a2: butt struct
; d2: not allowed
HotDogUpdate:
    ; TODO: try to make this only run in alive update
    jsr HotDogUpdateFromSlash
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Dead,.Alive,.Dying
.Dead:
    ; shouldn't happen
    rts
.Alive:
    ; do nothing
    rts
.Dying:
    jsr HotDogDyingUpdate
    rts

; d0.b : returns 0 if no slash
HotDogUpdateFromSlash:
    jsr UtilIsEnemyHitBySlash
    beq .Done
    ; Enemy is hit! switch to dying and activate hitstop.
    move.w #ENEMY_STATE_DYING,N_ENEMY_STATE(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    bset.b #7,(N_ENEMY_DATA1+1)(a2) ; set NEW_STATE
.Done
    rts

HotDogDyingUpdate:
    ; If this is a new state, set the frame counter
    btst.b #7,(N_ENEMY_DATA1+1)(a2)
    beq .AfterNewState
    bclr.b #7,(N_ENEMY_DATA1+1)(a2) ; not a new state anymore
    move.w #(ENEMY_DYING_FRAMES+1),N_ENEMY_STATE_FRAMES_LEFT(a2)
.AfterNewState
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .AfterStateTransition
    ; We're dead now
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
.AfterStateTransition
    rts

HotDogMaybeHurtHero:
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

; ; a2: enemy_state
; ; a3: enemy_x
; ; a4: enemy_y
; ; a5: enemy_data_1
; ; a6: enemy_data_2
; ; d2: not allowed
; ;
; ; State:
; ; ENEMY_DATA_1: 0000 000(AI_state,1) (frame_counter,8)
; ; ENEMY_DATA_2: 0000 000(old_state,1) 0000 00(motion_direction,2)
; UpdateHotDogEnemy:    
;     rts ; DEBUG
;     move.l #.StateJumpTable,a0
;     clr.l d0
;     move.b (a5),d0; ENEMY_DATA_1. need AI_state
;     add.b d0,d0 ; longs to bytes
;     add.b d0,d0
;     and.w #%0000000000000100,d0
;     add.l d0,a0
;     ; dereference jump table to get address to jump to
;     move.l (a0),a0
;     jmp (a0)
; .StateJumpTable dc.l HotDogSlashing,HotDogRecovery
; HotDogSlashing:
;     jsr HotDogSlashingUpdate
;     bra.s UpdateHotDogEnemyEnd
; HotDogRecovery:
;     jsr HotDogRecoveryUpdate
;     bra.s UpdateHotDogEnemyEnd
; UpdateHotDogEnemyEnd
;     bset.b #0,(a6) ; clear the "new state" field of enemy_data_2 (by setting "old state")
;     rts

; HotDogSlashingUpdate:
;     btst.b #0,(a6) ; 0 if this is a new state
;     bne.s .AfterNewState
;     jsr HotDogSlashingNewState
; .AfterNewState
;     ; maybe transition to recovery if done slashing
;     tst.b 1(a5)
;     bgt.s .NoTransition
;     move.b #HOT_DOG_RECOVERY,(a5)
;     move.b #0,(a6) ; set new state
;     bra.s HotDogRecovery
; .NoTransition
;     sub.b #1,1(a5) ; decrement frame counter
;     move.l #.DirectionJumpTable,a0
;     clr.l d0
;     move.b 1(a6),d0 ; bottom byte of ENEMY_DATA_2 for current direction
;     add.b d0,d0 ; longs to bytes
;     add.b d0,d0 
;     add.l d0,a0
;     ; dereference jump table to get address to jump to
;     move.l (a0),a0
;     jmp (a0)
; .DirectionJumpTable dc.l .Up,.Down,.Left,.Right
; .Up:
;     sub.w #HOT_DOG_SLASH_SPEED,(a4)
;     rts
; .Down:
;     add.w #HOT_DOG_SLASH_SPEED,(a4)
;     rts
; .Left:
;     sub.w #HOT_DOG_SLASH_SPEED,(a3)
;     rts
; .Right:
;     add.w #HOT_DOG_SLASH_SPEED,(a3)
;     rts

; HotDogSlashingNewState:
;     move.b #HOT_DOG_SLASH_DURATION,1(a5) ; reset frame timer
;     ; pick the slashing direction. We see whether we are farther from hero in x or y dir,
;     ; then go in that dir.
;     move.w (a3),d0 ; enemy_x
;     move.w (a4),d1 ; enemy_y
;     sub.w CURRENT_X,d0 ; enemy_x - hero_x
;     sub.w CURRENT_Y,d1 ; enemy_y - hero_y
;     move.w d0,d3 ; enemy_x - hero_x in d3
;     jsr AbsValue
;     move.w d0,d4 ; abs(dx) in d4
;     move.w d1,d0
;     jsr AbsValue ; abs(dy) in d0
;     cmp.w d4,d0
;     ble.s .FartherInX
;     ; farther in y. now check whether to go up or down
;     tst.w d1
;     blt.s .GoingDown
;     ; going up
;     move.b #FACING_UP,1(a6) ; enemy_data_2
;     bra.s .End
; .GoingDown
;     move.b #FACING_DOWN,1(a6) ; enemy_data_2
;     bra.s .End
; .FartherInX
;     tst.w d3
;     blt.s .GoingRight
;     ; going left
;     move.b #FACING_LEFT,1(a6)
;     bra.s .End
; .GoingRight
;     move.b #FACING_RIGHT,1(a6)
;     bra.s .End
; .End
;     rts

; HotDogRecoveryUpdate:
;     ; do new state setup
;     btst.b #0,(a6) ; 0 if this is a new state
;     bne.s .AfterNewState
;     move.b #HOT_DOG_RECOVERY_DURATION,1(a5)
; .AfterNewState
;     ; maybe transition back to slashing if done with recovery
;     tst.b 1(a5)
;     bgt.s .NoTransition
;     move.b #HOT_DOG_SLASHING,(a5)
;     move.b #0,(a6) ; set new state
;     bra.w HotDogSlashing
; .NoTransition
;     sub.b #1,1(a5) ; decrement frame counter
;     rts

; a2: enemy struct start
; d2: don't touch
HotDogDrawEnemy:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_DYING,d0
    beq.s .DrawDying
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
    move.w #HOT_DOG_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d1
    sub.w N_ENEMY_HALF_W(a2),d1
    add.w #MIN_DISPLAY_X,d1
    move.w d1,vdp_data ; x
    bra.w .End
.DrawDying
    ; only draw every few frames for a blinking effect
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d0
    btst.l #1,d0
    beq .End
    ; gonna scale slice anim by dying frames left.
    move.w #ENEMY_DYING_FRAMES,d1
    sub.w d0,d1 ; number of frames since enemy started dying in d1
    ; left slice first. offset a few pixels down-left
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d0 ; 2x2
    or.w SPRITE_COUNTER,d0
    move.w N_ENEMY_Y(a2),d3 ; y
    sub.w N_ENEMY_HALF_H(a2),d3
    sub.w CAMERA_TOP_Y,d3
    add.w #MIN_DISPLAY_Y,d3
    add.w d1,d3 ; y +=
    move.w d3,vdp_data
    move.w d0,vdp_data
    move.w d0,LAST_LINK_WRITTEN
    move.w #HOT_DOG_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d3 ; x
    sub.w N_ENEMY_HALF_W(a2),d3
    add.w #MIN_DISPLAY_X,d3
    sub.w d1,d3 ; x -=
    move.w d3,vdp_data
    ; right slice next. offset up-right
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d0 ; 2x2
    or.w SPRITE_COUNTER,d0
    move.w N_ENEMY_Y(a2),d3 ; y
    sub.w N_ENEMY_HALF_H(a2),d3
    sub.w CAMERA_TOP_Y,d3
    add.w #MIN_DISPLAY_Y,d3
    sub.w d1,d3 ; y -=
    move.w d3,vdp_data
    move.w d0,vdp_data
    move.w d0,LAST_LINK_WRITTEN
    move.w #HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d3 ; x
    sub.w N_ENEMY_HALF_W(a2),d3
    add.w #MIN_DISPLAY_X,d3
    add.w d1,d3 ; x +=
    move.w d3,vdp_data
.End
    rts

HotDogBlockHero:
    move.b #0,d0
    rts

HotDogLoad
    move.w #8,N_ENEMY_HALF_W(a2)
    move.w #8,N_ENEMY_HALF_H(a2)
    move.w #1,N_ENEMY_HP(a2)
    clr.w N_ENEMY_DATA1(a2)
    clr.w N_ENEMY_DATA2(a2)
    rts
