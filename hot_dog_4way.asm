HotDogVTable:
    dc.l HotDogUpdate
    dc.l HotDogMaybeHurtHero
    dc.l UtilEmptyFn
    dc.l HotDogDrawEnemy
    dc.l HotDogBlockHero
    dc.l HotDogLoad

HOT_DOG_FIREBALL_COOLDOWN: equ 60
; HOT_DOG_STOP_TIME: equ 120
HOT_DOG_STOP_TIME: equ 0
HOT_DOG_MOVE_TIME: equ 60
HOT_DOG_DESIRED_DIST: equ 48 ; pixels
HOT_DOG_WALK_SPEED: equ (ONE_PIXEL_LONG_UNIT)
HOT_DOG_TARGET_UPDATE_LAG: equ 32 ; frames

; ENEMY_DATA1.w: timer-until-next-fireball
; ENEMY_DATA2: (target_update_timer,8) 000(is_new_state,1) (is_moving,4)
; ENEMY_DATA3: (target_x.w)
; ENEMY_DATA4: (target_y.w)
; ENEMY_STATE_FRAMES_LEFT

HOT_DOG_STATE_STOPPED: equ 0
HOT_DOG_STATE_MOVING: equ 1
; a2: entity struct
; output: d0
HotDogGetState:
    move.b (N_ENEMY_DATA2+1)(a2),d0
    and.b #$0F,d0
    rts

; a2: entity struct
; input state: d0.b (assume only the state bits are set)
HotDogSetState:
    move.b (N_ENEMY_DATA2+1)(a2),d1
    and.b #$F0,d1
    or.b d0,d1
    move.b d1,(N_ENEMY_DATA2+1)(a2)
    rts

; update status reg
HotDogCheckNewStateBit:
    btst.b #4,(N_ENEMY_DATA2+1)(a2)
    rts
HotDogSetNewStateBit:
    bset.b #4,(N_ENEMY_DATA2+1)(a2)
    rts
HotDogClearNewStateBit:
    bclr.b #4,(N_ENEMY_DATA2+1)(a2)
    rts

; output: d0.b
HotDogGetTargetUpdateFramesLeft:
    move.b N_ENEMY_DATA2(a2),d0
    rts

HotDogSetTargetUpdateFramesLeft:
    move.b d0,N_ENEMY_DATA2(a2)
    rts

HotDogDecrTargetUpdateFramesLeft:
    sub.b #1,N_ENEMY_DATA2(a2)
    rts

HOT_DOG_TARGET_X: equ N_ENEMY_DATA3
HOT_DOG_TARGET_Y: equ N_ENEMY_DATA4

; a2: entity struct
; d2: not allowed
HotDogUpdate:
    jsr HotDogUpdateFromSlash
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l HotDogDead,HotDogAlive,HotDogDying
HotDogDead:
    ; shouldn't happen
    rts
HotDogAlive:
    jsr HotDogAliveUpdate
    rts
HotDogDying:
    jsr HotDogDyingUpdate
    rts

; d0.b : returns 0 if no slash
HotDogUpdateFromSlash:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_ALIVE,d0
    bne .Done
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
    move.w #ENEMY_DYING_FRAMES,N_ENEMY_STATE_FRAMES_LEFT(a2)
.AfterNewState
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .StillDying
    ; we dead
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
    rts
.StillDying
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
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

; a2: enemy struct
; d2: not allowed
HotDogAliveUpdate:
    jsr HotDogMaybeShootFireballAtHero
    clr.l d0
    jsr HotDogGetState ; motion state in d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Stopped,.Moving
.Stopped
    jsr HotDogStoppedUpdate
    rts
.Moving
    jsr HotDogMovingUpdate
    rts

HotDogStoppedUpdate:
    jsr HotDogCheckNewStateBit
    beq .AfterNewState
    move.w #HOT_DOG_STOP_TIME,N_ENEMY_STATE_FRAMES_LEFT(a2)
    jsr HotDogClearNewStateBit
.AfterNewState
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .StayStopped
    ; transition to moving
    jsr HotDogSetNewStateBit
    move.b #HOT_DOG_STATE_MOVING,d0
    jsr HotDogSetState
    rts
.StayStopped
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    rts

HotDogMovingUpdate:
    jsr HotDogCheckNewStateBit
    beq .AfterNewState
    move.w #HOT_DOG_MOVE_TIME,N_ENEMY_STATE_FRAMES_LEFT(a2)
    move.b #0,d0
    jsr HotDogSetTargetUpdateFramesLeft
    jsr HotDogClearNewStateBit
.AfterNewState
    tst.w N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .StayMoving
    ; transition to stopped
    jsr HotDogSetNewStateBit
    move.b #HOT_DOG_STATE_STOPPED,d0
    jsr HotDogSetState
    rts
.StayMoving
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    ; Is it time to update the target?
    jsr HotDogGetTargetUpdateFramesLeft ; d0
    bgt .AfterTargetUpdate
    ; target update
    move.w #HOT_DOG_DESIRED_DIST,d0
    jsr UtilGetEnemy4WayTargetPos
    move.w d0,HOT_DOG_TARGET_X(a2)
    move.w d1,HOT_DOG_TARGET_Y(a2)
    move.w #HOT_DOG_TARGET_UPDATE_LAG,d0
    jsr HotDogSetTargetUpdateFramesLeft
.AfterTargetUpdate
    jsr HotDogDecrTargetUpdateFramesLeft
    move.w HOT_DOG_TARGET_X(a2),d0
    move.w HOT_DOG_TARGET_Y(a2),d1
    sub.w N_ENEMY_X(a2),d0 ; target_x - ogre_x
    blt.s .MoveLeft
    ; move right
    move.l N_ENEMY_X(a2),d0
    add.l #HOT_DOG_WALK_SPEED,d0
    ; move.l #((MAX_DISPLAY_X-24)<<16),d3 ; max_x - half_ogre_width
    ; M_ClampMaxL d0,d3
    move.l d0,N_ENEMY_X(a2)
    bra.s .Next
.MoveLeft
    move.l N_ENEMY_X(a2),d0
    sub.l #HOT_DOG_WALK_SPEED,d0
    ; move.l #((MIN_DISPLAY_X+24)<<16),d3 ; min_x + half_ogre_width
    ; M_ClampMinL d0,d3
    move.l d0,N_ENEMY_X(a2)
.Next
    sub.w N_ENEMY_Y(a2),d1 ; target_y - ogre_y
    blt.s .MoveUp
    ; move down
    move.l N_ENEMY_Y(a2),d0
    add.l #HOT_DOG_WALK_SPEED,d0
    ; move.l #((MAX_DISPLAY_Y-24)<<16),d3 ; max_y - half_ogre_height
    ; M_ClampMaxL d0,d3
    move.l d0,N_ENEMY_Y(a2)
    bra.s .AfterWalk
.MoveUp
    move.l N_ENEMY_Y(a2),d0
    sub.l #HOT_DOG_WALK_SPEED,d0
    ; move.l #((MIN_DISPLAY_Y+24)<<16),d3 ; min_y + half_ogre_height
    ; M_ClampMinL d0,d3
    move.l d0,N_ENEMY_Y(a2)
.AfterWalk
    rts

HotDogMaybeShootFireballAtHero:
    ; check fireball timer
    move.w N_ENEMY_DATA1(a2),d0
    ble .FireballTime
    ; not fireball time yet. decrement timer and exit
    sub.w #1,N_ENEMY_DATA1(a2)
    bra .end ; not time for fireball yet
.FireballTime
    ; empty entity in a0 if d0 > 0
    jsr UtilFindEmptyEntity    
    tst.w d0
    ; if no empty entity found, just give up
    ble .end
    move.w #ENEMY_STATE_ALIVE,N_ENEMY_STATE(a0)
    move.w #ENTITY_TYPE_FIREBALL,N_ENEMY_TYPE(a0)
    move.w N_ENEMY_X(a2),N_ENEMY_X(a0)
    move.w N_ENEMY_Y(a2),N_ENEMY_Y(a0)
    ; to use the entity's load function, we gotta have the output struct in a2.
    ; so we push the current a2 onto the stack to make room.
    move.l a2,-(sp)
    move.l a0,a2
    jsr FireballLoad
    ; set fireball's velocity toward hero at 1px/s
    move.w CURRENT_X,d0
    add.w #(HERO_WIDTH/2),d0
    sub.w N_ENEMY_X(a2),d0 ; hero.x - enemy.x
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1
    sub.w N_ENEMY_Y(a2),d1 ; hero.y - enemy.y
    ; push x,y onto the stack to call atan2
    move.w d1,-(sp)
    move.w d0,-(sp)
    jsr Atan2
    add.l #4,sp ; pop arguments back off stack
    ; angle is in d0. we need to get cos and sin of it.
    move.b d0,d1 ; make copy of angle
    jsr Cos
    ext.l d0 ; output is a word, but we want to do a signed add to a long
    ; push d2 onto the stack so we can use it
    move.b d2,-(sp)
    move.b #(ONE_PIXEL_LONG_UNIT_LOG2-8),d2
    lsl.l d2,d0 ; cos(theta) * 1px/s
    move.l d0,N_ENEMY_DATA1(a2) ; set x_vel
    ; now sin
    move.b d1,d0
    jsr Sin
    ext.l d0
    move.b #(ONE_PIXEL_LONG_UNIT_LOG2-8),d2
    lsl.l d2,d0 ; sin(theta) * 1px/s
    move.l d0,N_ENEMY_DATA3(a2) ; set y_vel
    move.b (sp)+,d2
    move.l (sp)+,a2 ; we're done with fireball in a2, so put back previous value of a2 (hotdog)
    ; reset fireball timer
    move.w #HOT_DOG_FIREBALL_COOLDOWN,N_ENEMY_DATA1(a2)
.end
    rts

; a2: enemy struct start
; d2: don't touch
HotDogDrawEnemy:
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_DYING,d0
    beq .DrawDying
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
    bra .End
.DrawDying
    ; only draw every few frames for a blinking effect
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d0
    btst.l #1,d0
    bne .DoDraw
    ; If we're in hitstop, always draw
    tst.w HITSTOP_FRAMES_LEFT
    ble .End
.DoDraw
    ; gonna scale slice anim by dying frames left.
    move.w #(ENEMY_DYING_FRAMES-1),d1
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
    move.w #3,N_ENEMY_HP(a2)
    move.w #HOT_DOG_FIREBALL_COOLDOWN,N_ENEMY_DATA1(a2)
    clr.w N_ENEMY_DATA2(a2)
    jsr HotDogSetNewStateBit
    rts
