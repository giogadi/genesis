HOT_DOG_SLASHING: equ 0
HOT_DOG_RECOVERY: equ 1

HOT_DOG_SLASH_DURATION: equ 10
HOT_DOG_RECOVERY_DURATION: equ 30

HOT_DOG_SLASH_SPEED: equ 3

; a2: enemy_state
; a3: enemy_x
; a4: enemy_y
; a5: enemy_data_1
; a6: enemy_data_2
; d2: not allowed
;
; State:
; ENEMY_DATA_1: 0000 000(AI_state,1) (frame_counter,8)
; ENEMY_DATA_2: 0000 000(old_state,1) 0000 00(motion_direction,2)
UpdateHotDogEnemy:
    move.l #.StateJumpTable,a0
    clr.l d0
    move.b (a5),d0; ENEMY_DATA_1. need AI_state
    add.b d0,d0 ; longs to bytes
    add.b d0,d0
    and.w #%0000000000000100,d0
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.StateJumpTable dc.l HotDogSlashing,HotDogRecovery
HotDogSlashing:
    jsr HotDogSlashingUpdate
    bra.s UpdateHotDogEnemyEnd
HotDogRecovery:
    jsr HotDogRecoveryUpdate
    bra.s UpdateHotDogEnemyEnd
UpdateHotDogEnemyEnd
    bset.b #0,(a6) ; clear the "new state" field of enemy_data_2 (by setting "old state")
    rts

HotDogSlashingUpdate:
    btst.b #0,(a6) ; 0 if this is a new state
    bne.s .AfterNewState
    jsr HotDogSlashingNewState
.AfterNewState
    ; maybe transition to recovery if done slashing
    tst.b 1(a5)
    bgt.s .NoTransition
    move.b #HOT_DOG_RECOVERY,(a5)
    move.b #0,(a6) ; set new state
    bra.s HotDogRecovery
.NoTransition
    sub.b #1,1(a5) ; decrement frame counter
    move.l #.DirectionJumpTable,a0
    clr.l d0
    move.b 1(a6),d0 ; bottom byte of ENEMY_DATA_2 for current direction
    add.b d0,d0 ; longs to bytes
    add.b d0,d0 
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up:
    sub.w #HOT_DOG_SLASH_SPEED,(a4)
    rts
.Down:
    add.w #HOT_DOG_SLASH_SPEED,(a4)
    rts
.Left:
    sub.w #HOT_DOG_SLASH_SPEED,(a3)
    rts
.Right:
    add.w #HOT_DOG_SLASH_SPEED,(a3)
    rts

HotDogSlashingNewState:
    move.b #HOT_DOG_SLASH_DURATION,1(a5) ; reset frame timer
    ; pick the slashing direction. We see whether we are farther from hero in x or y dir,
    ; then go in that dir.
    move.w (a3),d0 ; enemy_x
    move.w (a4),d1 ; enemy_y
    sub.w CURRENT_X,d0 ; enemy_x - hero_x
    sub.w CURRENT_Y,d1 ; enemy_y - hero_y
    move.w d0,d3 ; enemy_x - hero_x in d3
    jsr AbsValue
    move.w d0,d4 ; abs(dx) in d4
    move.w d1,d0
    jsr AbsValue ; abs(dy) in d0
    cmp.w d4,d0
    ble.s .FartherInX
    ; farther in y. now check whether to go up or down
    tst.w d1
    blt.s .GoingDown
    ; going up
    move.b #FACING_UP,1(a6) ; enemy_data_2
    bra.s .End
.GoingDown
    move.b #FACING_DOWN,1(a6) ; enemy_data_2
    bra.s .End
.FartherInX
    tst.w d3
    blt.s .GoingRight
    ; going left
    move.b #FACING_LEFT,1(a6)
    bra.s .End
.GoingRight
    move.b #FACING_RIGHT,1(a6)
    bra.s .End
.End
    rts

HotDogRecoveryUpdate:
    ; do new state setup
    btst.b #0,(a6) ; 0 if this is a new state
    bne.s .AfterNewState
    move.b #HOT_DOG_RECOVERY_DURATION,1(a5)
.AfterNewState
    ; maybe transition back to slashing if done with recovery
    tst.b 1(a5)
    bgt.s .NoTransition
    move.b #HOT_DOG_SLASHING,(a5)
    move.b #0,(a6) ; set new state
    bra.w HotDogSlashing
.NoTransition
    sub.b #1,1(a5) ; decrement frame counter
    rts

; d0: please don't touch
; d1: enemy state
; d2: x
; d3: y
; d6: enemy dying frames left
DrawHotDogEnemy:
    cmp.w #ENEMY_STATE_DYING,d1
    beq.s .DrawDying
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d5 ; 2x2
    or.w SPRITE_COUNTER,d5 ; link to next sprite
    move.w d3,vdp_data
    move.w d5,vdp_data
    move.w d5,LAST_LINK_WRITTEN
    ; add global_palette
    move.w GLOBAL_PALETTE,d5
    ror.w #3,d5
    or.w #HOT_DOG_SPRITE_TILE_START,d5
    move.w d5,vdp_data
    move.w d2,vdp_data
    bra.s .End
.DrawDying:
    ; only draw every other frame for a blinking effect
    btst.l #0,d6
    bne.s .End
    ; gonna scale slice anim by dying frames left.
    move.w #ENEMY_DYING_FRAMES,d7
    sub.w d6,d7 ; number of frames since enemy started dying in d7
    ; left slice first. offset a few pixels down-left
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d5 ; 2x2
    or.w SPRITE_COUNTER,d5
    add.w d7,d3 ; y +=
    sub.w d7,d2 ; x -=
    move.w d3,vdp_data
    move.w d5,vdp_data
    move.w d5,LAST_LINK_WRITTEN
    move.w #HOT_DOG_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
    move.w d2,vdp_data
    ; right slice next. offset a few pixels up-right
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d5 ; 2x2
    or.w SPRITE_COUNTER,d5
    sub.w d7,d3 ; y -=
    sub.w d7,d3 ; twice to undo change from first half
    add.w d7,d2 ; x +=
    add.w d7,d2
    move.w d3,vdp_data
    move.w d5,vdp_data
    move.w d5,LAST_LINK_WRITTEN
    move.w #HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
    move.w d2,vdp_data
.End:
    rts