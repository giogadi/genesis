HERO_DASH_INIT_SPEED: equ 0
HERO_DASH_ACCEL: equ (5*65536)
HERO_DASH_MAX_SPEED: equ (5*65536)
HERO_DASH_DECEL: equ (65536/6)
HERO_DASH_MIN_SPEED: equ 65536

HERO_PARRY_STARTUP_FRAMES: equ 4
HERO_PARRY_ACTIVE_FRAMES: equ 30
HERO_PARRY_FAIL_RECOVERY_FRAMES: equ 30
;HERO_PARRY_SUCCESS_RECOVERY_FRAMES: equ 30
HERO_PARRY_SUCCESS_RECOVERY_FRAMES: equ 1

HeroStateUpdate:
    move.l #.HeroStateJumpTable,a0
    clr.l d0
    move.w HERO_STATE,d0; ; direction hero will move during hurt
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.HeroStateJumpTable
    dc.l .HeroStateIdle,.HeroStateSlashStartup,.HeroStateSlashActive,.HeroStateSlashRecovery
    dc.l .HeroStateHurt,.HeroStateDashing,.HeroStateParryStartup,.HeroStateParryActive
    dc.l .HeroStateParrySuccessRecovery,.HeroStateParryFailRecovery
.HeroStateIdle:
    jsr HeroStateIdleUpdate
    bra .AfterJumpTable
.HeroStateSlashStartup:
    jsr HeroStateSlashStartupUpdate
    bra .AfterJumpTable
.HeroStateSlashActive:
    jsr HeroStateSlashActiveUpdate
    bra .AfterJumpTable
.HeroStateSlashRecovery:
    jsr HeroStateSlashRecoveryUpdate
    bra .AfterJumpTable
.HeroStateHurt:
    jsr HeroStateHurtUpdate
    bra .AfterJumpTable
.HeroStateDashing:
    jsr HeroStateDashingUpdate
    bra .AfterJumpTable
.HeroStateParryStartup:
    jsr HeroStateParryStartupUpdate
    bra .AfterJumpTable
.HeroStateParryActive:
    jsr HeroStateParryActiveUpdate
    bra .AfterJumpTable
.HeroStateParrySuccessRecovery:
    jsr HeroStateParrySuccessRecoveryUpdate
    bra .AfterJumpTable
.HeroStateParryFailRecovery:
    jsr HeroStateParryFailRecoveryUpdate
.AfterJumpTable
    ; if there was a state transition, evaluate the state machine again.
    tst.w HERO_NEW_STATE
    beq .Done
    ; it's possible that we buffer a dash during hitstop, and then on the very first hero state update afterward,
    ; we change state (so the dash buffer doesn't get "consumed"). So we clear it here to ensure this doesn't happen.
    ; move.b #eBufferedNone,(gBufferedAction+1)
    bra HeroStateUpdate
.Done
    rts

; return value in d0
HeroStateIsDashActive:
    tst.l HERO_DASH_CURRENT_SPEED
    beq .Inactive
    ; active!
    move.b #1,d0
    rts
.Inactive
    move.b #0,d0
    rts

; Update FACING_DIRECTION,HERO_NEW_ANIM_PTR,NEW_X,NEW_Y
HeroStateIdleUpdate:
    clr.w HERO_NEW_STATE

    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    bne .AfterHurtTransition
    rts
.AfterHurtTransition

    ; Parry transition
    jsr HeroStateMaybeStartParry
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_PARRY_STARTUP,d0
    bne .AfterParryTransition
    rts
.AfterParryTransition

    ; Slash Transition
    jsr HeroStateMaybeStartSlash
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_STARTUP,d0
    bne .AfterSlashTransition
    rts
.AfterSlashTransition

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
    move.l #HeroRightIdleAnim,HERO_NEW_ANIM_PTR
    bra.s .AfterDefaultAnim
.DefaultFacingDown
    move.l #HeroLeftIdleAnim,HERO_NEW_ANIM_PTR
    bra.s .AfterDefaultAnim
.DefaultFacingLeft
    move.l #HeroLeftIdleAnim,HERO_NEW_ANIM_PTR
    bra.s .AfterDefaultAnim
.DefaultFacingRight
    move.l #HeroRightIdleAnim,HERO_NEW_ANIM_PTR
.AfterDefaultAnim

    clr.w d4 ; dx = 0
    clr.w d5 ; dy = 0

    ; if hero frozen, don't take any controller input.
    tst.w HERO_FROZEN
    bne .AfterControllerInput

    move.b CONTROLLER,d7
    btst.l #UP_BIT,d7
    beq.s .UpNotPressed
    sub.w #HERO_SPEED,d5
    move.l #HeroRightWalkAnim,HERO_NEW_ANIM_PTR
    move.w #FACING_UP,FACING_DIRECTION
.UpNotPressed
    btst.l #DOWN_BIT,d7
    beq.s .DownNotPressed
    add.w #HERO_SPEED,d5
    move.l #HeroLeftWalkAnim,HERO_NEW_ANIM_PTR
    move.w #FACING_DOWN,FACING_DIRECTION
.DownNotPressed
    btst.l #LEFT_BIT,d7
    beq.s .LeftNotPressed
    sub.w #HERO_SPEED,d4
    move.l #HeroLeftWalkAnim,HERO_NEW_ANIM_PTR
    move.w #FACING_LEFT,FACING_DIRECTION
.LeftNotPressed
    btst.l #RIGHT_BIT,d7
    beq.s .RightNotPressed
    add.w #HERO_SPEED,d4
    move.l #HeroRightWalkAnim,HERO_NEW_ANIM_PTR
    move.w #FACING_RIGHT,FACING_DIRECTION
.RightNotPressed
    add.w CURRENT_X,d4
    add.w CURRENT_Y,d5
    move.w d4,NEW_X
    move.w d5,NEW_Y

.AfterControllerInput

    rts

; Update HERO_STATE_FRAMES_LEFT,NEW_X,NEW_Y
HeroStateHurtUpdate:
    ; New state setup
    tst.w HERO_NEW_STATE
    beq.s .HeroStateHurtUpdateAfterNewState
    jsr MaybeSetNewlyHurtState
    clr.w HERO_NEW_STATE
.HeroStateHurtUpdateAfterNewState

    ; Transitions!
    move.w HERO_STATE_FRAMES_LEFT,d2
    bgt.s .AfterIdleTransition
    ; Transition to idle
    move.w #HERO_STATE_IDLE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    rts
.AfterIdleTransition

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

HeroStateMaybeStartParry
    tst.w BUTTON_RELEASED_SINCE_LAST_PARRY
    beq .End
    move.b CONTROLLER,d0
    btst.l #B_BIT,d0
    beq .End
    move.w #HERO_STATE_PARRY_STARTUP,HERO_STATE
    move.w #1,HERO_NEW_STATE
    ; In order to enable parrying in a different direction from dash, we check if a direction
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

HeroStateParryStartupUpdate
    tst.w HERO_NEW_STATE
    beq .AfterNewState
    move.w #HERO_PARRY_STARTUP_FRAMES,HERO_STATE_FRAMES_LEFT
    ; set parry startup anim
    clr.l d0
    move.w FACING_DIRECTION,d0
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightWindupAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingDown
    move.l #HeroLeftWindupAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingLeft
    move.l #HeroLeftWindupAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingRight
    move.l #HeroRightWindupAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.AfterAnimState
    move.w #0,HERO_NEW_STATE
.AfterNewState
    tst.w HERO_STATE_FRAMES_LEFT
    bgt .StillInStartup
    ; transition to parry active
    move.w #1,HERO_NEW_STATE
    move.w #HERO_STATE_PARRY_ACTIVE,HERO_STATE
    rts
.StillInStartup
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

HeroStateParryActiveUpdate
    tst.w HERO_NEW_STATE
    beq .AfterNewState
    move.w #HERO_PARRY_ACTIVE_FRAMES,HERO_STATE_FRAMES_LEFT
    ; set parry active anim
    clr.l d0
    move.w FACING_DIRECTION,d0
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightParryAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingDown
    move.l #HeroLeftParryAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingLeft
    move.l #HeroLeftParryAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingRight
    move.l #HeroRightParryAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.AfterAnimState
    move.w #0,HERO_NEW_STATE
.AfterNewState

    jsr CheckIfHeroNewlyHurt
    tst.w HERO_NEW_STATE ; check if parry succeeded
    beq .ParryNoHit
    rts
.ParryNoHit

    tst.w HERO_STATE_FRAMES_LEFT
    bgt .ContinueInState
    ; transition to parry failure
    move.w #1,HERO_NEW_STATE
    move.w #HERO_STATE_PARRY_FAIL_RECOVERY,HERO_STATE
    rts
.ContinueInState
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

HeroStateParrySuccessRecoveryUpdate
    tst.w HERO_NEW_STATE
    beq .AfterNewState
    ; start some hitstop.
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    move.w #HERO_PARRY_SUCCESS_RECOVERY_FRAMES,HERO_STATE_FRAMES_LEFT
    clr.w HERO_NEW_STATE
.AfterNewState

    ; handle transitions into quick-slash and dash.
    jsr HeroStateMaybeStartSlash
    tst.w HERO_NEW_STATE
    beq .AfterSlashTransition
    rts
.AfterSlashTransition

    jsr HeroStateMaybeStartDash
    tst.w HERO_NEW_STATE
    beq .AfterDashTransition
    rts
.AfterDashTransition

    ; TODO maybe allow transition into another parry to do like simul-parries? that'd be rad.
    tst.w HERO_STATE_FRAMES_LEFT
    bgt .ContinueInState
    ; transition back into idle
    move.w #1,HERO_NEW_STATE
    move.w #HERO_STATE_IDLE,HERO_STATE
    rts
.ContinueInState
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

HeroStateParryFailRecoveryUpdate
    tst.w HERO_NEW_STATE
    beq .AfterNewState
    move.w #HERO_PARRY_FAIL_RECOVERY_FRAMES,HERO_STATE_FRAMES_LEFT
    ; set parry fail anim
    clr.l d0
    move.w FACING_DIRECTION,d0
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightHurtAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingDown
    move.l #HeroLeftHurtAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingLeft
    move.l #HeroLeftHurtAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.FacingRight
    move.l #HeroRightHurtAnim,HERO_NEW_ANIM_PTR
    bra .AfterAnimState
.AfterAnimState
    move.w #0,HERO_NEW_STATE
.AfterNewState
    tst.w HERO_STATE_FRAMES_LEFT
    bgt .ContinueInState
    ; transition to idle
    move.w #1,HERO_NEW_STATE
    move.w #HERO_STATE_IDLE,HERO_STATE
    rts
.ContinueInState
    sub.w #1,HERO_STATE_FRAMES_LEFT
    rts

HeroStateMaybeStartSlash
    tst.w BUTTON_RELEASED_SINCE_LAST_SLASH
    beq .End
    move.b CONTROLLER,d0
    btst.l #A_BIT,d0
    beq .End
    ; In order to enable slashing in a different direction from dash, we check if a direction
    ; is also being pressed and turn the hero that way if so
    ; up
    btst.l #UP_BIT,d0
    beq.s .AfterUp
    move.w #FACING_UP,FACING_DIRECTION
    bra .AfterDirection
.AfterUp
    ; down
    btst.l #DOWN_BIT,d0
    beq.s .AfterDown
    move.w #FACING_DOWN,FACING_DIRECTION
    bra .AfterDirection
.AfterDown
    ; left
    btst.l #LEFT_BIT,d0
    beq.s .AfterLeft
    move.w #FACING_LEFT,FACING_DIRECTION
    bra .AfterDirection
.AfterLeft
    ; right
    btst.l #RIGHT_BIT,d0
    beq.s .AfterDirection
    move.w #FACING_RIGHT,FACING_DIRECTION
    bra .AfterDirection
.AfterDirection
    ; Decide whether hero can quick-slash. Possible if still dashing or in parry-success state
    jsr HeroStateIsDashActive
    tst.w d0
    bne .CanQuickSlash
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_PARRY_SUCCESS_RECOVERY,d0
    beq .CanQuickSlash
    ; can't quick-slash.
    move.w #0,HERO_CAN_QUICK_SLASH
    bra .AfterQuickSlash
.CanQuickSlash
    move.w #1,HERO_CAN_QUICK_SLASH
.AfterQuickSlash
    move.w #HERO_STATE_SLASH_STARTUP,HERO_STATE
    move.w #1,HERO_NEW_STATE
.End
    rts

HeroStateSlashStartupUpdate
    ; New state setup
    tst.w HERO_NEW_STATE
    beq .AfterNewState
    jsr SlashStartupNewState
    clr.w HERO_NEW_STATE
.AfterNewState

    ; if dashing, hero can't get hurt.
    jsr HeroStateIsDashActive
    tst.w d0
    bne .AfterHurtCheck

    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    bne .AfterHurtCheck
    rts

.AfterHurtCheck
    ; Transition to SLASH_ACTIVE if ready
    tst.w HERO_STATE_FRAMES_LEFT
    bgt.w .NoTransition
    move.w #HERO_STATE_SLASH_ACTIVE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    rts
.NoTransition
    sub.w #1,HERO_STATE_FRAMES_LEFT
    jsr DashSlashPositionUpdate
    rts

; direction in d0
GetSlash1WindupFromDirection
    M_JumpTable #.AnimJumpTable,a0,d0
.AnimJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingDown
    move.l #HeroLeftWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingLeft
    move.l #HeroLeftWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingRight
    move.l #HeroRightWindupAnim,HERO_NEW_ANIM_PTR
    rts

; direction in d0
GetSlash2WindupFromDirection
    M_JumpTable #.AnimJumpTable,a0,d0
.AnimJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightVertWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingDown
    move.l #HeroLeftVertWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingLeft
    move.l #HeroLeftVertWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingRight
    move.l #HeroRightVertWindupAnim,HERO_NEW_ANIM_PTR
    rts

; direction in d0
GetSlash1ActiveFromDirection
    M_JumpTable #.AnimJumpTable,a0,d0
.AnimJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightSlashAnim,HERO_NEW_ANIM_PTR
    rts
.FacingDown
    move.l #HeroLeftSlashAnim,HERO_NEW_ANIM_PTR
    rts
.FacingLeft
    move.l #HeroLeftSlashAnim,HERO_NEW_ANIM_PTR
    rts
.FacingRight
    move.l #HeroRightSlashAnim,HERO_NEW_ANIM_PTR
    rts

; direction in d0
GetSlash2ActiveFromDirection
    M_JumpTable #.AnimJumpTable,a0,d0
.AnimJumpTable dc.l .FacingUp,.FacingDown,.FacingLeft,.FacingRight
.FacingUp
    move.l #HeroRightVertSlashAnim,HERO_NEW_ANIM_PTR
    rts
.FacingDown
    move.l #HeroLeftVertSlashAnim,HERO_NEW_ANIM_PTR
    rts
.FacingLeft
    move.l #HeroLeftVertSlashAnim,HERO_NEW_ANIM_PTR
    rts
.FacingRight
    move.l #HeroRightVertSlashAnim,HERO_NEW_ANIM_PTR
    rts

; HERO_STATE_FRAMES_LEFT,BUTTON_RELEASED_SINCE_LAST_SLASH,HERO_NEW_ANIM_PTR
SlashStartupNewState
    ; ; if dashing, slash should start up instantly.
    ; jsr HeroStateIsDashActive
    ; tst.b d0
    ; beq .DashNotActive
    ; ; dash active! instant slash

    tst.w HERO_CAN_QUICK_SLASH
    beq .CannotQuickSlash
    ; quick-slash!
    move.w #0,HERO_STATE_FRAMES_LEFT
    bra .AfterSetFramesLeft
.CannotQuickSlash
    ; no quick-slash. add default startup.
    move.w #SLASH_STARTUP_ITERS,HERO_STATE_FRAMES_LEFT
.AfterSetFramesLeft
    move.w #0,BUTTON_RELEASED_SINCE_LAST_SLASH
    clr.l d0
    move.b gHeroComboState,d0
    M_JumpTable #.ComboJumpTable,a0,d0
.ComboJumpTable dc.l .Slash1,.Slash2
.Slash1
    move.w FACING_DIRECTION,d0
    jsr GetSlash1WindupFromDirection
    rts
.Slash2
    move.w FACING_DIRECTION,d0
    jsr GetSlash2WindupFromDirection
    rts

UpdateButtonReleasedSinceLastSlash
    tst.w BUTTON_RELEASED_SINCE_LAST_SLASH
    bne .End
    ; move.w HERO_STATE,d0
    ; cmp.w #HERO_STATE_SLASH_STARTUP,d0
    ; beq.s .End
    ; cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    ; beq.s .End
    ; cmp.w #HERO_STATE_SLASH_RECOVERY,d0
    ; beq.s .End
    move.b CONTROLLER,d0
    btst.l #A_BIT,d0
    bne .End
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

UpdateButtonReleasedSinceLastParry
    tst.w BUTTON_RELEASED_SINCE_LAST_PARRY
    bne.s .End
    move.b CONTROLLER,d0
    btst.l #B_BIT,d0
    bne.s .End
    move.w #1,BUTTON_RELEASED_SINCE_LAST_PARRY
.End
    rts

HeroStateSlashActiveUpdate
    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    jsr StateSlashActiveNewState
    clr.w HERO_NEW_STATE
.AfterNewState

    ; if dashing, hero can't get hurt.
    jsr HeroStateIsDashActive
    tst.w d0
    bne .AfterHurtCheck

    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    bne .AfterHurtCheck
    rts

.AfterHurtCheck

    ; Maybe start a dash if requested
    jsr HeroStateMaybeStartDash
    tst.b (HERO_NEW_STATE+1)
    beq .AfterDashTransition
    rts
    ; tst.w DASH_BUFFERED
    ; beq.s .AfterDashTransition
    ; move.w #HERO_STATE_DASHING,HERO_STATE
    ; move.w #1,HERO_NEW_STATE
    ; move.w #0,DASH_BUFFERED
    ; rts
.AfterDashTransition

    ; Maybe transition to recovery
    tst.w HERO_STATE_FRAMES_LEFT
    bgt.s .NoTransition
    move.w #HERO_STATE_SLASH_RECOVERY,HERO_STATE
    move.w #1,HERO_NEW_STATE
    rts
.NoTransition
    sub.w #1,HERO_STATE_FRAMES_LEFT
    jsr DashSlashPositionUpdate
    rts

; HERO_STATE_FRAMES_LEFT,SLASH AABB,HERO_NEW_ANIM_PTR
StateSlashActiveNewState
    move.w #1,HERO_STATE_FRAMES_LEFT ; 1 active frame
    ; update animation state
    clr.l d0
    move.b gHeroComboState,d0
    M_JumpTable #.ComboJumpTable,a0,d0
.ComboJumpTable dc.l .Slash1,.Slash2
.Slash1
    move.w FACING_DIRECTION,d0
    jsr GetSlash1ActiveFromDirection
    bra .AfterAnim
.Slash2
    move.w FACING_DIRECTION,d0
    jsr GetSlash2ActiveFromDirection
    bra .AfterAnim
.AfterAnim
    
    ; update Slash AABB
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
    rts
.SlashFacingDown
    move.w d0,SLASH_MIN_X
    add.w #3*8,d0
    move.w d0,SLASH_MAX_X
    add.w #3*8,d1 ; hero height
    move.w d1,SLASH_MIN_Y
    add.w #4*8,d1 ; slash height
    move.w d1,SLASH_MAX_Y
    rts
.SlashFacingLeft
    move.w d0,SLASH_MAX_X
    sub.w #4*8,d0
    move.w d0,SLASH_MIN_X
    move.w d1,SLASH_MIN_Y
    add.w #3*8,d1
    move.w d1,SLASH_MAX_Y
    rts
.SlashFacingRight
    add.w #2*8,d0 ; hero width
    move.w d0,SLASH_MIN_X
    add.w #4*8,d0 ; slash width
    move.w d0,SLASH_MAX_X
    move.w d1,SLASH_MIN_Y
    add.w #3*8,d1
    move.w d1,SLASH_MAX_Y
    rts

HeroStateSlashRecoveryUpdate
    ; Hurt Transition
    jsr CheckIfHeroNewlyHurt
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_HURT,d0
    bne .AfterHurtTransition
    rts
.AfterHurtTransition

    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    clr.w HERO_NEW_STATE
    ; check if we can cancel recovery into another attack
    ; Maybe transition to new attack if buffered
    move.b #eBufferedAttack,d0
    cmp.b (gBufferedAction+1),d0
    bne .AfterAttackTransition
    move.b #eBufferedNone,(gBufferedAction+1)
    ; figure out what combo state to transition into
    clr.l d0
    move.b gHeroComboState,d0
    M_JumpTable #.ComboJumpTable,a0,d0
.ComboJumpTable dc.l .FromSlash1,.FromSlash2
.FromSlash1
    move.b #eHeroComboStateSlash2,gHeroComboState
    bra .AfterComboJump
.FromSlash2
    ; We don't combo out of slash 2. So just skip to recovery transition logic.
    bra .AfterAttackTransition
    bra .AfterComboJump
.AfterComboJump
    ; Transition to next attack
    move.w #HERO_STATE_SLASH_STARTUP,HERO_STATE
    move.w #1,HERO_NEW_STATE
    rts
.AfterAttackTransition
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
    ; Reset combo state when we transition back to idle
    move.b #eHeroComboStateSlash1,gHeroComboState
    move.w #HERO_STATE_IDLE,HERO_STATE
    move.w #1,HERO_NEW_STATE
    rts
.NoTransition
    sub.w #1,HERO_STATE_FRAMES_LEFT
    jsr DashSlashPositionUpdate
    rts

; go hog wild on registers
CheckIfHeroNewlyHurt:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    ; if enemy is not alive, skip to next enemy
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_DEAD,d0
    beq.s .continue_loop
    jsr UtilEnemyHurtVirtual
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
    rts

MaybeSetNewlyHurtState
    ; flip palette
    jsr LoadInversePaletteIntoFirst
    ; add hitstop
    move.w #3,HITSTOP_FRAMES_LEFT
    ; set hurt frame counter
    move.w #8,HERO_STATE_FRAMES_LEFT
    ; reset dash state
    clr.l HERO_DASH_CURRENT_SPEED
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
    move.l #HeroLeftHurtAnim,HERO_NEW_ANIM_PTR
    rts
.HurtAnimMovingDown:
    move.l #HeroRightHurtAnim,HERO_NEW_ANIM_PTR
    rts
.HurtAnimMovingLeft:
    move.l #HeroRightHurtAnim,HERO_NEW_ANIM_PTR
    rts
.HurtAnimMovingRight:
    move.l #HeroLeftHurtAnim,HERO_NEW_ANIM_PTR
.SetNewHurtStateEnd
    rts

; HeroStateMaybeStartDash
;     tst.w BUTTON_RELEASED_SINCE_LAST_DASH
;     beq .End
;     tst.w HERO_DASH_COOLDOWN_FRAMES_LEFT
;     bgt .End
;     move.b CONTROLLER,d0
;     btst.l #C_BIT,d0
;     beq .End
;     move.w #HERO_STATE_DASHING,HERO_STATE
;     move.w #1,HERO_NEW_STATE
;     move.w #0,DASH_BUFFERED
;     jsr UtilUpdateDashDirectionFromControllerInD0
; .End    
;     rts

HeroStateMaybeStartDash
    ; Check hero dash cooldown (TODO: are we still doing this?)
    tst.b (HERO_DASH_COOLDOWN_FRAMES_LEFT+1)
    bgt .End
    ; first check dash buffer
    move.b #eBufferedDash,d0
    cmp.b (gBufferedAction+1),d0
    bne .End
    ; ; if no dash buffer, check controller
    ; move.b CONTROLLER,d0
    ; tst.b (BUTTON_RELEASED_SINCE_LAST_DASH+1)
    ; beq .End
    ; btst.l #C_BIT,d0
    ; beq .End
    ; we dashin!
.StartNewDash
    move.w #HERO_STATE_DASHING,HERO_STATE
    move.b #1,(HERO_NEW_STATE+1)
    ; TODO maybe not necessary anymore
    move.b #eBufferedNone,(gBufferedAction+1)
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
    move.l #HeroRightWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingDown
    move.l #HeroLeftWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingLeft
    move.l #HeroLeftWindupAnim,HERO_NEW_ANIM_PTR
    rts
.FacingRight
    move.l #HeroRightWindupAnim,HERO_NEW_ANIM_PTR
    rts

HeroStateDashingUpdate
    ; handle new state
    tst.w HERO_NEW_STATE
    beq.s .AfterNewState
    move.l #HERO_DASH_INIT_SPEED,HERO_DASH_CURRENT_SPEED
    move.w #0,HERO_DASH_CURRENT_STATE
    move.w #0,BUTTON_RELEASED_SINCE_LAST_DASH
    ;move.w #10,HITSTOP_FRAMES_LEFT
    move.w #0,HERO_STATE_FRAMES_LEFT ; used for flicker
    ; set current anim to windup
    jsr SetWindupFromFacingDirection
    clr.w HERO_NEW_STATE
    rts ; no movement until after freeze time.
.AfterNewState

    ; Maybe start new dash (new direction, speed) if requested
    jsr HeroStateMaybeStartDash
    tst.b (HERO_NEW_STATE+1)
    beq .AfterDashTransition
.AfterDashTransition

    ; Slash Transition
    jsr HeroStateMaybeStartSlash
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_STARTUP,d0
    bne .AfterSlashTransition
.AfterSlashTransition

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
    rts
.NoTransition
    move.l HERO_DASH_CURRENT_SPEED,d0

    tst.b HERO_DASH_DIRECTION_X
    beq .AfterDashX
    blt .DashLeft
    ; Dash right
    add.l d0,NEW_X
    bra .AfterDashX
.DashLeft
    sub.l d0,NEW_X
.AfterDashX

    tst.b HERO_DASH_DIRECTION_Y
    beq .AfterDashY
    blt .DashUp
    ; Dash down
    add.l d0,NEW_Y
    bra .AfterDashY
.DashUp
    sub.l d0,NEW_Y
.AfterDashY

    ; We slashing now
    move.w NEW_X,SLASH_MIN_X
    move.w NEW_Y,SLASH_MIN_Y
    move.w SLASH_MIN_X,SLASH_MAX_X
    add.w #HERO_WIDTH,SLASH_MAX_X
    move.w SLASH_MIN_Y,SLASH_MAX_Y
    add.w #HERO_HEIGHT,SLASH_MAX_Y
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
    move.l HERO_DASH_CURRENT_SPEED,d0
    beq .End

    tst.b HERO_DASH_DIRECTION_X
    beq .AfterDashX
    blt .DashLeft
    ; Dash right
    add.l d0,NEW_X
    bra .AfterDashX
.DashLeft
    sub.l d0,NEW_X
.AfterDashX

    tst.b HERO_DASH_DIRECTION_Y
    beq .AfterDashY
    blt .DashUp
    ; Dash down
    add.l d0,NEW_Y
    bra .AfterDashY
.DashUp
    sub.l d0,NEW_Y
.AfterDashY
.End
    rts