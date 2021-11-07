HERO_DASH_INIT_SPEED: equ 0
HERO_DASH_ACCEL: equ (5*65536)
HERO_DASH_MAX_SPEED: equ (5*65536)
HERO_DASH_DECEL: equ (65536/6)
HERO_DASH_MIN_SPEED: equ 65536

HeroStateUpdate:
    move.l #.HeroStateJumpTable,a0
    clr.l d0
    move.w HERO_STATE,d0; ; direction hero will move during hurt
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.HeroStateJumpTable dc.l HeroStateIdle,HeroStateSlashStartup,HeroStateSlashActive,HeroStateSlashRecovery,HeroStateHurt,HeroStateDashing
HeroStateIdle:
    jsr HeroStateIdleUpdate
    rts
HeroStateSlashStartup:
    jsr HeroStateSlashStartupUpdate
    jsr DashSlashPositionUpdate
    rts
HeroStateSlashActive:
    jsr HeroStateSlashActiveUpdate
    jsr DashSlashPositionUpdate
    rts
HeroStateSlashRecovery:
    jsr HeroStateSlashRecoveryUpdate
    jsr DashSlashPositionUpdate
    rts
HeroStateHurt:
    jsr HeroStateHurtUpdate
    rts
HeroStateDashing:
    jsr HeroStateDashingUpdate
    rts

; Update FACING_DIRECTION,NEW_ANIM_STATE,NEW_X,NEW_Y
HeroStateIdleUpdate:
    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    beq.w HeroStateHurt

    ; Slash Transition
    jsr HeroStateMaybeStartSlash
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_STARTUP,d0
    beq.s HeroStateSlashStartup

    ; Dash Transition
    ; jsr HeroStateMaybeStartDash
    ; move.w HERO_STATE,d0
    ; cmp.w #HERO_STATE_DASHING,d0
    ; beq.s HeroStateDashing

    ; default to anim facing previous direction first.
    move.l #.DefaultAnimJumpTable,a0
    clr.l d0
    move.w FACING_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.DefaultAnimJumpTable dc.l .DefaultFacingUp,.DefaultFacingDown,.DefaultFacingLeft,.DefaultFacingRight
.DefaultFacingUp
    move.w #RIGHT_IDLE_STATE,NEW_ANIM_STATE
    bra.s .AfterDefaultAnim
.DefaultFacingDown
    move.w #LEFT_IDLE_STATE,NEW_ANIM_STATE
    bra.s .AfterDefaultAnim
.DefaultFacingLeft
    move.w #LEFT_IDLE_STATE,NEW_ANIM_STATE
    bra.s .AfterDefaultAnim
.DefaultFacingRight
    move.w #RIGHT_IDLE_STATE,NEW_ANIM_STATE
.AfterDefaultAnim

    clr.w d4 ; dx = 0
    clr.w d5 ; dy = 0

    move.b CONTROLLER,d7
    btst.l #UP_BIT,d7
    beq.s .UpNotPressed
    sub.w #HERO_SPEED,d5
    move.w #WALK_RIGHT_STATE,NEW_ANIM_STATE
    move.w #FACING_UP,FACING_DIRECTION
.UpNotPressed
    btst.l #DOWN_BIT,d7
    beq.s .DownNotPressed
    add.w #HERO_SPEED,d5
    move.w #WALK_LEFT_STATE,NEW_ANIM_STATE
    move.w #FACING_DOWN,FACING_DIRECTION
.DownNotPressed
    btst.l #LEFT_BIT,d7
    beq.s .LeftNotPressed
    sub.w #HERO_SPEED,d4
    move.w #WALK_LEFT_STATE,NEW_ANIM_STATE
    move.w #FACING_LEFT,FACING_DIRECTION
.LeftNotPressed
    btst.l #RIGHT_BIT,d7
    beq.s .RightNotPressed
    add.w #HERO_SPEED,d4
    move.w #WALK_RIGHT_STATE,NEW_ANIM_STATE
    move.w #FACING_RIGHT,FACING_DIRECTION
.RightNotPressed
    add.w CURRENT_X,d4
    add.w CURRENT_Y,d5
    move.w d4,NEW_X
    move.w d5,NEW_Y

    rts

; Update HERO_STATE_FRAMES_LEFT,NEW_X,NEW_Y
HeroStateHurtUpdate:
    ; New state setup
    tst.w HERO_NEW_STATE
    beq.s .HeroStateHurtUpdateAfterNewState
    jsr MaybeSetNewlyHurtState
.HeroStateHurtUpdateAfterNewState

    ; Transitions!
    move.w HERO_STATE_FRAMES_LEFT,d2
    bgt.s .HeroStateHurtUpdateAfterIdleTransition
    ; Transition to idle
    move.w #HERO_STATE_IDLE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    bra.w HeroStateIdle
.HeroStateHurtUpdateAfterIdleTransition

    ; state update
    sub.w #1,HERO_STATE_FRAMES_LEFT
    ; when hitstop is over, go back to normal palette
    tst.w HITSTOP_FRAMES_LEFT
    bgt.w .HurtUpdateAfterPaletteReset
    jsr LoadNormalPaletteIntoFirst
.HurtUpdateAfterPaletteReset
    move.l #.HurtMotionJumpTable,a0
    clr.l d0
    move.w HURT_DIRECTION,d0; ; direction hero will move during hurt
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    move.w CURRENT_X,d4
    move.w CURRENT_Y,d5
    move.w #4,d2 ; speed
    jmp (a0)
.HurtMotionJumpTable dc.l .HurtMovingUp,.HurtMovingDown,.HurtMovingLeft,.HurtMovingRight
.HurtMovingUp:
    sub.w d2,d5
    bra.s .AfterHurtMotion
.HurtMovingDown:
    add.w d2,d5
    bra.s .AfterHurtMotion
.HurtMovingLeft:
    sub.w d2,d4
    bra.s .AfterHurtMotion
.HurtMovingRight:
    add.w d2,d4
.AfterHurtMotion
    move.w d4,NEW_X
    move.w d5,NEW_Y
    rts

HeroStateMaybeStartSlash
    tst.w BUTTON_RELEASED_SINCE_LAST_SLASH
    beq.s .End
    move.b CONTROLLER,d0
    btst.l #A_BIT,d0
    beq.s .End
    move.w #HERO_STATE_SLASH_STARTUP,HERO_STATE
    move.w #1,HERO_NEW_STATE
    ; In order to enable slashing in a different direction from dash, we check if a direction
    ; is also being pressed and turn the hero that way if so
    ; up
    btst.l #UP_BIT,d0
    beq.s .AfterUp
    move.w #FACING_UP,FACING_DIRECTION
    rts
.AfterUp
    ; down
    btst.l #DOWN_BIT,d0
    beq.s .AfterDown
    move.w #FACING_DOWN,FACING_DIRECTION
    rts
.AfterDown
    ; left
    btst.l #LEFT_BIT,d0
    beq.s .AfterLeft
    move.w #FACING_LEFT,FACING_DIRECTION
    rts
.AfterLeft
    ; right
    btst.l #RIGHT_BIT,d0
    beq.s .AfterRight
    move.w #FACING_RIGHT,FACING_DIRECTION
    rts
.AfterRight
.End    
    rts

HeroStateSlashStartupUpdate
    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    beq.w HeroStateHurt

    ; New state setup
    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    jsr SlashStartupNewState
.AfterNewState
    ; Transition to SLASH_ACTIVE if ready
    tst.w HERO_STATE_FRAMES_LEFT
    bgt.w .NoTransition
    move.w #HERO_STATE_SLASH_ACTIVE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    bra HeroStateSlashActive
.NoTransition
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

; HERO_STATE_FRAMES_LEFT,BUTTON_RELEASED_SINCE_LAST_SLASH,NEW_ANIM_STATE
SlashStartupNewState
    move.w #SLASH_STARTUP_ITERS,HERO_STATE_FRAMES_LEFT
    move.w #0,BUTTON_RELEASED_SINCE_LAST_SLASH
    move.l #.AnimJumpTable,a0
    clr.l d0
    move.w FACING_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.AnimJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.w #WINDUP_RIGHT_STATE,NEW_ANIM_STATE
    rts
.FacingDown
    move.w #WINDUP_LEFT_STATE,NEW_ANIM_STATE
    rts
.FacingLeft
    move.w #WINDUP_LEFT_STATE,NEW_ANIM_STATE
    rts
.FacingRight
    move.w #WINDUP_RIGHT_STATE,NEW_ANIM_STATE
    rts

UpdateButtonReleasedSinceLastSlash
    tst.w BUTTON_RELEASED_SINCE_LAST_SLASH
    bne.s .End
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_STARTUP,d0
    beq.s .End
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    beq.s .End
    cmp.w #HERO_STATE_SLASH_RECOVERY,d0
    beq.s .End
    move.b CONTROLLER,d0
    btst.l #A_BIT,d0
    bne.s .End
    move.w #1,BUTTON_RELEASED_SINCE_LAST_SLASH
.End
    rts

UpdateButtonReleasedSinceLastDash
    tst.w BUTTON_RELEASED_SINCE_LAST_DASH
    bne.s .End
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_DASHING,d0
    beq.s .End
    move.b CONTROLLER,d0
    btst.l #C_BIT,d0
    bne.s .End
    move.w #1,BUTTON_RELEASED_SINCE_LAST_DASH
.End
    rts

HeroStateSlashActiveUpdate
    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    beq.w HeroStateHurt

    ; Dash Transition if buffered
    tst.w DASH_BUFFERED
    beq.s .AfterDashTransition
    move.w #HERO_STATE_DASHING,HERO_STATE
    move.w #1,HERO_NEW_STATE
    move.w #0,DASH_BUFFERED
    bra HeroStateDashing
.AfterDashTransition

    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    jsr StateSlashActiveNewState
.AfterNewState
    ; Maybe transition to recovery
    tst.w HERO_STATE_FRAMES_LEFT
    bgt.s .NoTransition
    move.w #HERO_STATE_SLASH_RECOVERY,HERO_STATE
    move.w #1,HERO_NEW_STATE
    bra HeroStateSlashRecovery
.NoTransition
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

; HERO_STATE_FRAMES_LEFT,SLASH AABB,NEW_ANIM_STATE
StateSlashActiveNewState
    move.w #1,HERO_STATE_FRAMES_LEFT ; 1 active frame
    ; update Slash AABB and Animation state
    move.l #.SlashAnimJumpTable,a0
    clr.l d0
    move.w FACING_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    move.w CURRENT_X,d0
    move.w CURRENT_Y,d1
    jmp (a0)
.SlashAnimJumpTable dc.l .SlashFacingUp,.SlashFacingDown,.SlashFacingLeft,.SlashFacingRight
.SlashFacingUp
    move.w d0,SLASH_MIN_X
    add.w #3*8,d0
    move.w d0,SLASH_MAX_X
    move.w d1,SLASH_MAX_Y
    sub.w #4*8,d1
    move.w d1,SLASH_MIN_Y
    move.w #SLASH_RIGHT_STATE,NEW_ANIM_STATE
    rts
.SlashFacingDown
    move.w d0,SLASH_MIN_X
    add.w #3*8,d0
    move.w d0,SLASH_MAX_X
    add.w #3*8,d1 ; hero height
    move.w d1,SLASH_MIN_Y
    add.w #4*8,d1 ; slash height
    move.w d1,SLASH_MAX_Y
    move.w #SLASH_LEFT_STATE,NEW_ANIM_STATE
    rts
.SlashFacingLeft
    move.w d0,SLASH_MAX_X
    sub.w #4*8,d0
    move.w d0,SLASH_MIN_X
    move.w d1,SLASH_MIN_Y
    add.w #3*8,d1
    move.w d1,SLASH_MAX_Y
    move.w #SLASH_LEFT_STATE,NEW_ANIM_STATE
    rts
.SlashFacingRight
    add.w #2*8,d0 ; hero width
    move.w d0,SLASH_MIN_X
    add.w #4*8,d0 ; slash width
    move.w d0,SLASH_MAX_X
    move.w d1,SLASH_MIN_Y
    add.w #3*8,d1
    move.w d1,SLASH_MAX_Y
    move.w #SLASH_RIGHT_STATE,NEW_ANIM_STATE
    rts

HeroStateSlashRecoveryUpdate
    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    beq.w HeroStateHurt

    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    move.w #SLASH_RECOVERY_ITERS,HERO_STATE_FRAMES_LEFT
.AfterNewState
    ; Maybe transition back to idle. Only transition after HERO_STATE_FRAMES_LEFT == 0 and
    ; HERO_DASH_CURRENT_SPEED == 0.
    tst.w HERO_STATE_FRAMES_LEFT
    bgt.s .NoTransition
    tst.l HERO_DASH_CURRENT_SPEED
    bgt.s .NoTransition
    ; Reset dash cooldown after slash
    move.w #HERO_DASH_COOLDOWN,HERO_DASH_COOLDOWN_FRAMES_LEFT
    move.w #HERO_STATE_IDLE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    bra HeroStateIdle
.NoTransition
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

; go hog wild on registers
CheckIfHeroNewlyHurt:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    ; if enemy is not alive, skip to next enemy
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop
    jsr UtilEnemyHurtVirtual
.continue_loop
    dbra d2,.loop
    rts

; Updates HERO_STATE,HERO_NEW_STATE,HURT_DIRECTION.
; TODO: currently clobbers a bunch of registers.
CheckIfHeroNewlyHurtOld:
    move.w #MAX_NUM_ENEMIES-1,d7
    move.w CURRENT_X,d2 ; hero_min_x
    move.w CURRENT_Y,d3 ; hero_min_y
    move.w d2,d4
    add.w #HERO_WIDTH,d4 ; hero_max_x
    move.w d3,d5
    add.w #HERO_HEIGHT,d5 ; hero_max_y
    move.l #ENEMY_X,a2
    move.l #ENEMY_Y,a3
    move.l #ENEMY_STATE,a4
    move.l #ENEMY_SIZE,a5
.CheckHurtLoop:
    ; if enemy is not alive, skip to next enemy
    move.w (a4),d6
    cmp.w #ENEMY_STATE_ALIVE,d6
    bne.s .CheckHurtLoopContinue
    ; check hero AABB vs enemy AABB.
    ; We're also gonna check which direction had the minimum overlap.
    ; This tells us which side the enemy is of the player, and thus which way the player should
    ; bounce.
    move.w #0,d0 ; this tracks which direction has least overlap
    move.w #$0FFF,d1 ; this tracks the overlap amount of least-overlap-direction
    move.w (a2),d6 ; enemy_min_x (top word is pixel pos)
    sub.w d4,d6 ; enemy_min_x - hero_max_x
    bgt.s .CheckHurtLoopContinue
    neg.w d6 ; make overlap positive
    cmp.w d1,d6 ; compare with previous overlap amount and keep smaller value
    bgt.s .CheckHurtNotLeastOverlap1
    move.w #FACING_LEFT,d0
    move.w d6,d1
.CheckHurtNotLeastOverlap1
    clr.w d6
    move.b (a5),d6 ; enemy_width
    add.w (a2),d6 ; enemy_min_x + enemy_width = enemy_max_x
    sub.w d2,d6 ; enemy_max_x - hero_min_x
    blt.s .CheckHurtLoopContinue
    cmp.w d1,d6 ; compare with previous overlap amount and keep smaller value
    bge.s .CheckHurtNotLeastOverlap2
    move.w #FACING_RIGHT,d0
    move.w d6,d1
.CheckHurtNotLeastOverlap2
    move.w (a3),d6 ; enemy_min_y
    sub.w d5,d6 ; enemy_min_y - hero_max_y
    bgt.s .CheckHurtLoopContinue
    neg.w d6 ; make overlap positive
    cmp.w d1,d6 ; compare with previous overlap amount and keep smaller value
    bge.s .CheckHurtNotLeastOverlap3
    move.w #FACING_UP,d0
    move.w d6,d1
.CheckHurtNotLeastOverlap3
    clr.w d6
    move.b 1(a5),d6 ; enemy_height
    add.w (a3),d6 ; enemy_min_x + enemy_width = enemy_max_x
    sub.w d3,d6 ; enemy_max_y - hero_min_y
    blt.s .CheckHurtLoopContinue
    cmp.w d1,d6 ; compare with previous overlap amount and keep smaller value
    bge.s .CheckHurtNotLeastOverlap4
    move.w #FACING_DOWN,d0
    move.w d6,d1
.CheckHurtNotLeastOverlap4
    ; OK we have an overlap. update hero state and break out of loop
    move.w #HERO_STATE_HURT,HERO_STATE
    move.w #1,HERO_NEW_STATE
    move.w d0,HURT_DIRECTION
    rts
.CheckHurtLoopContinue
    add.l #4,a2
    add.l #4,a3
    add.w #2,a4
    add.w #2,a5
    dbra d7,.CheckHurtLoop
    rts

MaybeSetNewlyHurtState
    ; flip palette
    jsr LoadInversePaletteIntoFirst
    ; add hitstop
    move.w #3,HITSTOP_FRAMES_LEFT
    ; set hurt frame counter
    move.w #8,HERO_STATE_FRAMES_LEFT
    ; reset slash state
    ; move.w #SLASH_STATE_NONE,SLASH_STATE
    move.l #.HurtAnimJumpTable,a0
    clr.l d0
    move.w HURT_DIRECTION,d0; ; direction hero will move during hurt
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.HurtAnimJumpTable dc.l .HurtAnimMovingUp,.HurtAnimMovingDown,.HurtAnimMovingLeft,.HurtAnimMovingRight
.HurtAnimMovingUp:
    move.w #HURT_LEFT_STATE,NEW_ANIM_STATE
    rts
.HurtAnimMovingDown:
    move.w #HURT_RIGHT_STATE,NEW_ANIM_STATE
    rts
.HurtAnimMovingLeft:
    move.w #HURT_RIGHT_STATE,NEW_ANIM_STATE
    rts
.HurtAnimMovingRight:
    move.w #HURT_LEFT_STATE,NEW_ANIM_STATE
.SetNewHurtStateEnd
    rts

HeroStateMaybeStartDash
    tst.w BUTTON_RELEASED_SINCE_LAST_DASH
    beq.s .End
    tst.w HERO_DASH_COOLDOWN_FRAMES_LEFT
    bgt.s .End
    move.b CONTROLLER,d0
    btst.l #C_BIT,d0
    beq.s .End
    move.w #HERO_STATE_DASHING,HERO_STATE
    move.w #1,HERO_NEW_STATE
.End    
    rts

; TODO re-use this in slash startup?
; uses d0 and a0
SetWindupFromFacingDirection:
    move.l #.AnimJumpTable,a0
    clr.l d0
    move.w FACING_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.AnimJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.w #WINDUP_RIGHT_STATE,NEW_ANIM_STATE
    rts
.FacingDown
    move.w #WINDUP_LEFT_STATE,NEW_ANIM_STATE
    rts
.FacingLeft
    move.w #WINDUP_LEFT_STATE,NEW_ANIM_STATE
    rts
.FacingRight
    move.w #WINDUP_RIGHT_STATE,NEW_ANIM_STATE
    rts

HeroStateDashingUpdate
    ; handle new state
    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    move.w FACING_DIRECTION,HERO_DASH_DIRECTION
    move.l #HERO_DASH_INIT_SPEED,HERO_DASH_CURRENT_SPEED
    move.w #0,HERO_DASH_CURRENT_STATE
    move.w #0,BUTTON_RELEASED_SINCE_LAST_DASH
    ;move.w #10,HITSTOP_FRAMES_LEFT
    move.w #0,HERO_STATE_FRAMES_LEFT ; used for flicker
    ; set current anim to windup
    jsr SetWindupFromFacingDirection
    rts ; no movement until after freeze time.
.AfterNewState
    ; Slash Transition
    jsr HeroStateMaybeStartSlash
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_STARTUP,d0
    beq HeroStateSlashStartup

    add.w #1,HERO_STATE_FRAMES_LEFT ; for flicker

    ; are we acceling or deceling?
    tst.w HERO_DASH_CURRENT_STATE
    bne.s .Deceling
    ; acceling
    add.l #HERO_DASH_ACCEL,HERO_DASH_CURRENT_SPEED
    ; if we've hit max speed, switch to deceling next frame.
    move.l HERO_DASH_CURRENT_SPEED,d0
    cmp.l #HERO_DASH_MAX_SPEED,d0
    blt.s .StillAcceling
    move.l #HERO_DASH_MAX_SPEED,HERO_DASH_CURRENT_SPEED ; clamp to max speed
    move.w #1,HERO_DASH_CURRENT_STATE
.StillAcceling
    bra.s .NoTransition ; continue dashing
.Deceling
    sub.l #HERO_DASH_DECEL,HERO_DASH_CURRENT_SPEED
    move.l HERO_DASH_CURRENT_SPEED,d0
    cmp.l #HERO_DASH_MIN_SPEED,d0
    ; if we've hit 0 speed, switch to idle.
    bgt.s .NoTransition
    move.l #0,HERO_DASH_CURRENT_SPEED
    move.w #HERO_DASH_COOLDOWN,HERO_DASH_COOLDOWN_FRAMES_LEFT
    move.w #HERO_STATE_IDLE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    bra HeroStateIdle
.NoTransition
    move.l #.DashDirectionJumpTable,a0
    clr.l d0
    move.w HERO_DASH_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    move.l HERO_DASH_CURRENT_SPEED,d0
    jmp (a0)
.DashDirectionJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    sub.l d0,NEW_Y
    rts
.FacingDown
    add.l d0,NEW_Y
    rts
.FacingLeft
    sub.l d0,NEW_X
    rts
.FacingRight
    add.l d0,NEW_X
    rts

; TODO: consider re-using this in DashingUpdate above
DashSlashPositionUpdate:
    sub.l #HERO_DASH_DECEL,HERO_DASH_CURRENT_SPEED
    ; clamp to 0 speed
    bgt.s .AfterClamp
    move.l #0,HERO_DASH_CURRENT_SPEED
.AfterClamp
    ; If 0 speed, skip position update
    ; TODO: can we skip this tst? Does the sub.l check still hold here?
    tst.l HERO_DASH_CURRENT_SPEED
    beq.s .End
    move.l #.FacingDirectionJumpTable,a0
    clr.l d0
    move.w HERO_DASH_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    move.l HERO_DASH_CURRENT_SPEED,d0
    jmp (a0)
.FacingDirectionJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    sub.l d0,NEW_Y
    rts
.FacingDown
    add.l d0,NEW_Y
    rts
.FacingLeft
    sub.l d0,NEW_X
    rts
.FacingRight
    add.l d0,NEW_X
.End
    rts