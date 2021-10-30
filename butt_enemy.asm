BUTT_ENEMY_STEPPING: equ 0
BUTT_ENEMY_CHARGING: equ 1
BUTT_ENEMY_ZOOMING: equ 2
BUTT_ENEMY_COOLDOWN: equ 3

; ENEMY_DATA_1: 000(stepping_state,1) (step_counter,2) (motion_state,2) (NEW_STATE,1) (EMPTY,7)
; ENEMY_DATA_2: 0000 000(zig,1) (motion_direction,8)

; a2: butt struct
; d2: not allowed
ButtUpdate:
    ; TODO: try to make this only run in alive update
    jsr ButtUpdateFromSlash
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Dead,.Alive,.Dying
.Dead:
    ; shouldn't happen
    rts
.Alive:
    jsr ButtAliveUpdate
    rts
.Dying:
    jsr ButtDyingUpdate
    rts

; a2: butt struct
; d2: not allowed
ButtAliveUpdate:
    clr.l d0
    move.b N_ENEMY_DATA1(a2),d0 ; get upper byte. lowest 2 bits are motion_state
    and.b #$03,d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Stepping,.Charging,.Zooming,.Cooldown
.Stepping:
    jsr ButtStepUpdate
    rts
.Charging:
    jsr ButtChargingUpdate
    rts
.Zooming:
    jsr ButtZoomingUpdate
    rts
.Cooldown:
    jsr ButtCooldownUpdate
    rts

ButtDyingUpdate:
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

; d0.b : returns 0 if no slash
ButtUpdateFromSlash:
    jsr UtilIsEnemyHitBySlash
    beq .Done
    ; Enemy is hit! switch to dying and activate hitstop.
    move.w #ENEMY_STATE_DYING,N_ENEMY_STATE(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    bset.b #7,(N_ENEMY_DATA1+1)(a2) ; set NEW_STATE
.Done
    rts

; a2: butt struct
; d2: do not touch
ButtStepUpdate:
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d0
    sub.w #1,d0
    move.w d0,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .AfterStepStateChange
    ; change stepping state and put back in memory. We'll reset the frame counter a little later.
    move.b N_ENEMY_DATA1(a2),d0 ; get upper byte
    bchg.l #4,d0
    move.b d0,N_ENEMY_DATA1(a2)
    btst.l #4,d0
    beq .StepStop
    ; If we're about to move, pick a motion direction.
    move.w CURRENT_X,d0 ; hero.p - enemy.p
    sub.w N_ENEMY_X(a2),d0
    move.w CURRENT_Y,d1
    sub.w N_ENEMY_Y(a2),d1
     ; push x,y onto the stack to call atan2
    move.w d1,-(sp)
    move.w d0,-(sp)
    jsr Atan2
    add.l #4,sp ; pop arguments back off stack
    move.b d0,(N_ENEMY_DATA2+1)(a2) ; copy angle into enemy_data_2's lower byte
    ; reset frame counter
    move.w #10,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bra.s .AfterStepStateChange
.StepStop
    ; when we stop, we increment step_counter. after some stops, we switch to charging mode.
    ; d0 already has top byte of data1
    lsr.b #2,d0 ; put step counter in lsb
    and.b #%00000011,d0 ; mask out all but the step_counter bits
    add.b #1,d0
    cmp.b #3,d0 ; have we hit 3 steps yet?
    bge.s .FinishedStepping
    ; Not finished stepping. reset frame counter and save incremented step count
    move.w #30,N_ENEMY_STATE_FRAMES_LEFT(a2)
    and.b #%00000011,d0
    lsl.b #2,d0 ; put step counter in correct bit position
    move.b N_ENEMY_DATA1(a2),d1
    and.b #%11110011,d1 ; clear the step counter bits so we can set them from d0
    or.b d0,d1
    move.b d1,N_ENEMY_DATA1(a2)
    bra.s .AfterStepStateChange
.FinishedStepping
    ; clear all enemy_data_1 except for motion_state, which is now CHARGING
    move.w #(256*BUTT_ENEMY_CHARGING),d0 ; charging state shifted left 8
    bset.l #7,d0 ; set NEW_STATE
    move.w d0,N_ENEMY_DATA1(a2)
    bra.s .AfterStepMotion
.AfterStepStateChange
    ; Handle moving and non-moving states
    move.b N_ENEMY_DATA1(a2),d0
    btst.l #4,d0 ; check stepping state
    beq.s .AfterStepMotion
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; get angle from enemy_data_2
    jsr Cos
    ext.l d0 ; output is a word, but we want to add to do a signed add to a long
    lsl.l #8,d0 ; divide out 256, multiply 65536 (1 pixel per frame)
    add.l d0,N_ENEMY_X(a2) ; update enemy_x
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; get angle again for sin
    jsr Sin
    ext.l d0
    lsl.l #8,d0
    add.l d0,N_ENEMY_Y(a2) ; update enemy_y
.AfterStepMotion
    rts

ButtChargingUpdate:
    move.w N_ENEMY_DATA1(a2),d0
    btst.l #7,d0 ; is this a new state?
    beq .AfterNewState
    move.w #60,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bclr.b #7,(N_ENEMY_DATA1+1)(a2) ; no longer new
.AfterNewState
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d1
    sub.w #1,d1
    bgt .Continue ; if we still have frames left, don't change state
    ; set to ZOOMING state
    move.w #(256*BUTT_ENEMY_ZOOMING),d0
    bset.l #7,d0 ; set NEW_STATE
    move.w d0,N_ENEMY_DATA1(a2)
    rts
.Continue
    move.w d1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    add.l #-5000,N_ENEMY_Y(a2)
    rts

ButtZoomingUpdate:
    move.w N_ENEMY_DATA1(a2),d0
    btst.l #7,d0 ; is this a new state?
    beq .AfterNewState
    bclr.b #7,(N_ENEMY_DATA1+1)(a2) ; no longer new
    move.w #40,N_ENEMY_STATE_FRAMES_LEFT(a2)
    ; if this is the first frame of zooming, we need to pick our direction.
    move.w CURRENT_X,d0
    sub.w N_ENEMY_X(a2),d0 ; hero.x - enemy.x
    move.w CURRENT_Y,d1
    sub.w N_ENEMY_Y(a2),d1 ; hero.y - enemy.y
    ; push x,y onto the stack to call atan2
    move.w d1,-(sp)
    move.w d0,-(sp)
    jsr Atan2
    add.l #4,sp ; pop arguments back off stack
    move.b d0,(N_ENEMY_DATA2+1)(a2) ; copy angle into enemy_data2's lower byte
.AfterNewState
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    ; transition out of zooming if we're finished
    bgt .AfterStateTransition
    move.w #(256*BUTT_ENEMY_COOLDOWN),d0
    bset.l #7,d0 ; set NEW_STATE
    move.w d0,N_ENEMY_DATA1(a2)
    rts
.AfterStateTransition
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; get angle from enemy_data_2
    jsr Cos
    ext.l d0 ; output is a word, but we want to add to do a signed add to a long
    move.b #10,d1 
    lsl.l d1,d0 ; divide out 256, multiply 65536 * 2 (2 pixel per frame)
    add.l d0,N_ENEMY_X(a2) ; update enemy_x
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; get angle again for sin
    jsr Sin
    ext.l d0
    lsl.l d1,d0
    add.l d0,N_ENEMY_Y(a2) ; update enemy_y
    rts

ButtCooldownUpdate:
    move.w N_ENEMY_DATA1(a2),d0
    btst.l #7,d0 ; is this a new state?
    beq .AfterNewState
    bclr.b #7,(N_ENEMY_DATA1+1)(a2) ; no longer new
    move.w #60,N_ENEMY_STATE_FRAMES_LEFT(a2)
.AfterNewState
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt .AfterStateTransition
    move.w #(256*BUTT_ENEMY_STEPPING),N_ENEMY_DATA1(a2)
    rts
.AfterStateTransition
    add.l #5000,N_ENEMY_Y(a2)
    rts

; a2: enemy struct start
; d2: don't touch
ButtDrawEnemy:
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
    move.w #BUTT_SPRITE_TILE_START,vdp_data
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
    move.w #BUTT_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
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
    move.w #BUTT_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d3 ; x
    sub.w N_ENEMY_HALF_W(a2),d3
    add.w #MIN_DISPLAY_X,d3
    add.w d1,d3 ; x +=
    move.w d3,vdp_data
.End
    rts

ButtMaybeHurtHero:
    move.w N_ENEMY_HALF_H(a2),-(sp)
    move.w N_ENEMY_Y(a2),-(sp)
    move.w N_ENEMY_HALF_W(a2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilMinAABBOverlapHero
    add.l #(4*2),sp
    tst.b d0
    blt.b .end
    ; overlap
    move.w #HERO_STATE_HURT,HERO_STATE
    move.w #1,HERO_NEW_STATE
    move.b d0,(HURT_DIRECTION+1)
.end
    rts