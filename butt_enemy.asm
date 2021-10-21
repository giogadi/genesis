BUTT_ENEMY_STEPPING: equ 0
BUTT_ENEMY_CHARGING: equ 1
BUTT_ENEMY_ZOOMING: equ 2
BUTT_ENEMY_COOLDOWN: equ 3

; ENEMY_DATA_1: 000(stepping_state,1) (step_counter,2) (motion_state,2) (EMPTY,8)
; ENEMY_DATA_2: 0000 000(zig,1) (motion_direction,8)

; a2: butt struct
; d2: not allowed
ButtUpdateEnemy:
    clr.l d0
    move.b N_ENEMY_DATA1(a2),d0 ; get upper byte. lowest 2 bits are motion_state
    and.b #$03,d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Stepping,.Charging,.Zooming,.Cooldown
.Stepping:
    jsr ButtStepUpdate
    rts
.Charging:
    rts
.Zooming:
    rts
.Cooldown:
    rts

; a2: enemy_state
; a3: enemy_x
; a4: enemy_y
; a5: enemy_data_1
; a6: enemy_data_2
; d2: not allowed
; UpdateButtEnemy:
;     rts ; DEBUGGGGG
;     ; State:
;     ; motion states: stepping, charging, zooming, zoom-cooldown. Need 2 bits for this.
;     ; frame counter for current state. 8 bits.
;     ; current motion direction. 8 bits
;     ; zig/zag. 1 bit
;     ; stepping moved/stopped. 1 bit
;     ; step counter during stepping. 2 bits
;     ; ENEMY_DATA_1: 000(stepping_state,1) (step_counter,2) (motion_state,2) (frame_counter,8)
;     ; ENEMY_DATA_2: 0000 000(zig,1) (motion_direction,8)
;     move.l #.ButtEnemyStateJumpTable,a0
;     clr.l d0
;     move.w (a5),d0; ENEMY_DATA_1. need motion_state
;     lsr.w #6,d0; ; equivalently, we shift right 8, AND with $0003, then shift left 2 to go from longs to bytes.
;     and.w #%0000000000001100,d0
;     add.l d0,a0
;     ; dereference jump table to get address to jump to
;     move.l (a0),a0
;     jmp (a0)
; .ButtEnemyStateJumpTable dc.l .ButtEnemyStepping,.ButtEnemyCharging,.ButtEnemyZooming,.ButtEnemyCooldown
; .ButtEnemyStepping:
;     jsr ButtEnemySteppingUpdate
;     rts
; .ButtEnemyCharging:
;     jsr ButtEnemyChargingUpdate
;     rts
; .ButtEnemyZooming:
;     jsr ButtEnemyZoomingUpdate
;     rts
; .ButtEnemyCooldown:
;     jsr ButtEnemyCooldownUpdate
;     rts

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

; a2: enemy_state
; a3: enemy_x
; a4: enemy_y
; a5: enemy_data_1
; a6: enemy_data_2
; ButtEnemySteppingUpdate:
;     move.w (a5),d0 ; enemy_data_1. frame_counter is in bottom byte
;     sub.b #1,d0 ; decrement counter
;     move.b d0,1(a5) ; save frame_counter
;     bgt.w .ButtEnemyAfterStepStateChange
;     ; change stepping state and put back in memory. We'll reset the frame counter a little later.
;     bchg.l #12,d0
;     move.w d0,(a5)
;     btst.l #12,d0
;     beq.s .ButtEnemyStepStopping
;     ; If we're about to move, pick a motion direction.
;     move.w CURRENT_X,d0 ; hero.p - enemy.p
;     sub.w (a3),d0
;     move.w CURRENT_Y,d1
;     sub.w (a4),d1
;      ; push x,y onto the stack to call atan2
;     move.w d1,-(sp)
;     move.w d0,-(sp)
;     jsr Atan2
;     add.l #4,sp ; pop arguments back off stack
;     move.b d0,1(a6); copy angle into enemy_data_2's lower byte
;     ; reset frame counter
;     move.b #10,1(a5)
;     bra.s .ButtEnemyAfterStepStateChange
; .ButtEnemyStepStopping
;     ; when we stop, we increment step_counter. after some stops, we switch to charging mode.
;     move.b (a5),d0 ; get top byte of enemy_data_1
;     lsr.b #2,d0 ; put step counter in lsb
;     and.b #%00000011,d0 ; mask out all but the step_counter bits
;     add.b #1,d0
;     cmp.b #3,d0 ; have we hit 3 steps yet?
;     bge.s .ButtEnemyFinishedStepping
;     ; Not finished stepping. reset frame counter and save incremented step count
;     move.b #30,1(a5)
;     lsl.b #2,d0 ; but step counter in correct bit position
;     move.b (a5),d1
;     and.b #%11110011,d1 ; clear the step counter bits so we can set them from d0
;     or.b d0,d1
;     move.b d1,(a5)
;     bra.s .ButtEnemyAfterStepStateChange
; .ButtEnemyFinishedStepping
;     ; clear all enemy_data_1 except for motion_state, which is now CHARGING
;     move.w #(256*BUTT_ENEMY_CHARGING),d0 ; charging state shifted left 8
;     move.w d0,(a5)
;     bra.s .ButtEnemyAfterStepMotion
; .ButtEnemyAfterStepStateChange
;     ; Handle moving and non-moving states
;     move.w (a5),d0
;     btst.l #12,d0 ; check stepping state
;     beq.s .ButtEnemyAfterStepMotion
;     clr.l d0
;     move.b 1(a6),d0 ; get angle from enemy_data_2
;     jsr Cos
;     ext.l d0 ; output is a word, but we want to add to do a signed add to a long
;     lsl.l #8,d0 ; divide out 256, multiply 65536 (1 pixel per frame)
;     add.l d0,(a3) ; update enemy_x
;     clr.l d0
;     move.b 1(a6),d0 ; get angle again for sin
;     jsr Sin
;     ext.l d0
;     lsl.l #8,d0
;     add.l d0,(a4) ; update enemy_y
; .ButtEnemyAfterStepMotion
;     rts

; use frame counter to charge for only a bit before switching to ZOOM
ButtEnemyChargingUpdate:
    move.w (a5),d0
    add.b #1,d0
    cmp.b #60,d0 ; if we haven't charged for 30 frames yet, don't change state. branch forward
    blt.s .ButtEnemyChargingContinue
    ; clear all state except that we're in ZOOM moving state
    move.w #(256*BUTT_ENEMY_ZOOMING),d0
    move.w d0,(a5)
    rts
.ButtEnemyChargingContinue
    move.w d0,(a5)
    add.l #-5000,(a4)
    rts

ButtEnemyZoomingUpdate:
    move.w (a5),d0
    add.b #1,d0
    move.w d0,(a5) ; save frame count
    ; If we have zoomed enough, clear state except for COOLDOWN motion state.
    cmp.b #40,d0
    blt.s .ButtEnemyZoomingContinue
    move.w #(256*BUTT_ENEMY_COOLDOWN),(a5)
    rts
.ButtEnemyZoomingContinue
    ; if this is the first frame of zooming, we need to pick our direction.
    cmp.b #1,d0
    bne.b .ButtEnemyZoomingAfterNewState
    move.w CURRENT_X,d0 ; hero.p - enemy.p
    sub.w (a3),d0
    move.w CURRENT_Y,d1
    sub.w (a4),d1
     ; push x,y onto the stack to call atan2
    move.w d1,-(sp)
    move.w d0,-(sp)
    jsr Atan2
    add.l #4,sp ; pop arguments back off stack
    move.b d0,1(a6); copy angle into enemy_data_2's lower byte
.ButtEnemyZoomingAfterNewState:
    clr.l d0
    move.b 1(a6),d0 ; get angle from enemy_data_2
    jsr Cos
    ext.l d0 ; output is a word, but we want to add to do a signed add to a long
    move.b #10,d1 
    lsl.l d1,d0 ; divide out 256, multiply 65536 * 2 (2 pixel per frame)
    add.l d0,(a3) ; update enemy_x
    clr.l d0
    move.b 1(a6),d0 ; get angle again for sin
    jsr Sin
    ext.l d0
    lsl.l d1,d0
    add.l d0,(a4)
    rts

ButtEnemyCooldownUpdate:
    move.w (a5),d0
    add.b #1,d0
    cmp.b #60,d0 ; if we haven't charged for 30 frames yet, don't change state. branch forward
    blt.s .ButtEnemyChargingContinue
    ; clear all state except that we're in STEPPING moving state
    move.w #(256*BUTT_ENEMY_STEPPING),d0
    move.w d0,(a5)
    rts
.ButtEnemyChargingContinue
    move.w d0,(a5)
    add.l #5000,(a4)
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
    sub.w CAMERA_TOP_Y,d1
    add.w #MIN_DISPLAY_Y,d1
    move.w d1,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d0,LAST_LINK_WRITTEN
    move.w #BUTT_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d1
    add.w #MIN_DISPLAY_X,d1
    move.w d1,vdp_data ; x
    bra.w .End
.DrawDying
    ; only draw every other frame for a blinking effect
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d0
    btst.l #0,d0
    bne .End
    ; gonna scale slice anim by dying frames left.
    move.w #ENEMY_DYING_FRAMES,d1
    sub.w d0,d1 ; number of frames since enemy started dying in d1
    ; left slice first. offset a few pixels down-left
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d0 ; 2x2
    or.w SPRITE_COUNTER,d0
    move.w N_ENEMY_Y(a2),d3 ; y
    sub.w CAMERA_TOP_Y,d3
    add.w #MIN_DISPLAY_Y,d3
    add.w d1,d3 ; y +=
    move.w d3,vdp_data
    move.w d0,vdp_data
    move.w d0,LAST_LINK_WRITTEN
    move.w #BUTT_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d3 ; x
    add.w #MIN_DISPLAY_X,d3
    sub.w d1,d3 ; x -=
    move.w d3,vdp_data
    ; right slice next. offset up-right
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d0 ; 2x2
    or.w SPRITE_COUNTER,d0
    move.w N_ENEMY_Y(a2),d3 ; y
    sub.w CAMERA_TOP_Y,d3
    add.w #MIN_DISPLAY_Y,d3
    sub.w d1,d3 ; y -=
    move.w d3,vdp_data
    move.w d0,vdp_data
    move.w d0,LAST_LINK_WRITTEN
    move.w #BUTT_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
    move.w N_ENEMY_X(a2),d3 ; x
    add.w #MIN_DISPLAY_X,d3
    add.w d1,d3 ; x +=
    move.w d3,vdp_data
.End
    rts