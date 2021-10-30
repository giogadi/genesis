OGRE_DESIRED_DIST: equ 48 ; pixels
OGRE_WIDTH: equ 48 ; pixels
OGRE_HEIGHT: equ 48 ; pixels
OGRE_WALK_SPEED: equ (65536/2) ; 1 pixel per frame
OGRE_HITSTUN_DURATION: equ 20 ; frames
OGRE_STARTUP_DURATION: equ 30 ; frames
OGRE_RECOVERY_DURATION: equ 30 ; frames
OGRE_HURT_FLICKER_DURATION: equ 30

OGRE_HP: equ 10

; State:
; ENEMY_DATA_1: 0000 00(next_state,2) 0000 00(state,2)
; ENEMY_DATA_2: (hit-blink,8) 0000 00(facing_direction,2)
OGRE_STATE_MASK: equ %00000011
OGRE_DIRECTION_MASK: equ %00000011

OGRE_STATE_IDLE: equ 0
OGRE_STATE_STARTUP: equ 1
OGRE_STATE_SLASHING: equ 2
OGRE_STATE_RECOVERY: equ 3

OGRE_IDLE_HALF_W: equ 9
OGRE_IDLE_HALF_H: equ 20

OGRE_LEFT_STARTUP_HALF_W: equ 15
OGRE_LEFT_STARTUP_HALF_H: equ 20
OGRE_LEFT_SLASHING_HALF_W: equ 17
OGRE_LEFT_SLASHING_HALF_H: equ 19

OGRE_RIGHT_STARTUP_HALF_W: equ 15
OGRE_RIGHT_STARTUP_HALF_H: equ 20
OGRE_RIGHT_SLASHING_HALF_W: equ 17
OGRE_RIGHT_SLASHING_HALF_H: equ 19

OGRE_DOWN_STARTUP_HALF_W: equ 10
OGRE_DOWN_STARTUP_HALF_H: equ 22
OGRE_DOWN_SLASHING_HALF_W: equ 13
OGRE_DOWN_SLASHING_HALF_H: equ 21

OGRE_UP_STARTUP_HALF_W: equ 10
OGRE_UP_STARTUP_HALF_H: equ 22
OGRE_UP_SLASHING_HALF_W: equ 13
OGRE_UP_SLASHING_HALF_H: equ 21

OGRE_VERT_SLASH_SPRITE_W: equ (10*8)
OGRE_VERT_SLASH_SPRITE_H: equ (8*8)
OGRE_HORIZ_SLASH_SPRITE_W: equ (8*8)
OGRE_HORIZ_SLASH_SPRITE_H: equ (10*8)

OgreGetIdleTileIndex:
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    btst.b #4,(FRAME_COUNTER+1)
    bne.s .Up2
    ; right walk 1
    move.w #(OGRE_SPRITE_TILE_START+5*36),d1
    rts
.Up2
    move.w #(OGRE_SPRITE_TILE_START+6*36),d1
    rts
.Down
    btst.b #4,(FRAME_COUNTER+1)
    bne.s .Down2
    ; left walk 1
    move.w #OGRE_SPRITE_TILE_START,d1
    rts
.Down2
    move.w #(OGRE_SPRITE_TILE_START+36),d1
    rts
.Left
    bra.s .Down
.Right
    bra.s .Up

OgreGetStartupTileIndex:
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    move.w #(OGRE_SPRITE_TILE_START+13*36),d1
    rts
.Down
    move.w #(OGRE_SPRITE_TILE_START+10*36),d1
    rts
.Left
    move.w #(OGRE_SPRITE_TILE_START+2*36),d1
    rts
.Right
    move.w #(OGRE_SPRITE_TILE_START+7*36),d1
    rts

OgreGetSlashingTileIndex:
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    move.w #(OGRE_SPRITE_TILE_START+14*36),d1
    rts
.Down
    move.w #(OGRE_SPRITE_TILE_START+11*36),d1
    rts
.Left
    move.w #(OGRE_SPRITE_TILE_START+3*36),d1
    rts
.Right
    move.w #(OGRE_SPRITE_TILE_START+8*36),d1
    rts

OgreSetIdleHurtboxSize:
    ; same size regardless of direction
    move.w #OGRE_IDLE_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_IDLE_HALF_H,N_ENEMY_HALF_H(a2)
    rts

OgreSetSlashStartupHurtboxSize:
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    move.w #OGRE_UP_STARTUP_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_UP_STARTUP_HALF_H,N_ENEMY_HALF_H(a2)
    rts
.Down
    move.w #OGRE_DOWN_STARTUP_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_DOWN_STARTUP_HALF_H,N_ENEMY_HALF_H(a2)
    rts
.Left
    move.w #OGRE_LEFT_STARTUP_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_LEFT_STARTUP_HALF_H,N_ENEMY_HALF_H(a2)
    rts
.Right
    move.w #OGRE_RIGHT_STARTUP_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_RIGHT_STARTUP_HALF_H,N_ENEMY_HALF_H(a2)
    rts

OgreSetSlashingHurtboxSize:
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    move.w #OGRE_UP_SLASHING_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_UP_SLASHING_HALF_H,N_ENEMY_HALF_H(a2)
    rts
.Down
    move.w #OGRE_DOWN_SLASHING_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_DOWN_SLASHING_HALF_H,N_ENEMY_HALF_H(a2)
    rts
.Left
    move.w #OGRE_LEFT_SLASHING_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_LEFT_SLASHING_HALF_H,N_ENEMY_HALF_H(a2)
    rts
.Right
    move.w #OGRE_RIGHT_SLASHING_HALF_W,N_ENEMY_HALF_W(a2)
    move.w #OGRE_RIGHT_SLASHING_HALF_H,N_ENEMY_HALF_H(a2)
    rts

; a2: enemy struct start
; d2: don't touch
DrawOgreEnemy:
    ; Do a two-level jump table (across state + direction) to figure out what
    ; the starting tile index should be. tile index will be in d1 after the dust settles.
    clr.l d0
    move.b (N_ENEMY_DATA1+1)(a2),d0 ; load state
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Idle,.Startup,.Slashing,.Recovery
.Idle
    jsr OgreGetIdleTileIndex
    bra.s .AfterTileIndex
.Startup
    jsr OgreGetStartupTileIndex
    bra.s .AfterTileIndex
.Slashing
    jsr OgreGetSlashingTileIndex
    bra.s .AfterTileIndex
.Recovery
    jsr OgreGetSlashingTileIndex
    bra.s .AfterTileIndex
.AfterTileIndex
    ; store palette in d5. If in hitstun, we'll be flickering the palette.
    clr.w d5
    ; move.w N_ENEMY_STATE(a2),d0
    ; cmp.w #ENEMY_STATE_HITSTUN,d0
    tst.b N_ENEMY_DATA2(a2) ; check if we are flickering on hurt
    ble.s .NoFlicker
    move.w N_ENEMY_STATE_FRAMES_LEFT(a2),d0
    btst.l #2,d0
    bne.s .NoFlicker
    bset.l #13,d5 ; set color palette to 1 (inverse palette)
.NoFlicker

    move.w #$0A00,d0 ; 3x3 (to be combined with link data)
    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w N_ENEMY_Y(a2),d3 ; y
    sub.w #24,d3
    sub.w CAMERA_TOP_Y,d3
    add.w #MIN_DISPLAY_Y,d3
    move.w N_ENEMY_X(a2),d4 ; x
    sub.w #24,d4
    add.w #MIN_DISPLAY_X,d4
    and.w #$F800,d5 ; clear tile data from d5
    or.w d1,d5 ; add tile data from d1 to d5
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d5,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(3*3),d1 ; next tile group start
    add.w #(3*8),d4 ; position of next tile group start (1,0)
    and.w #$F800,d5 ; clear tile data from d5
    or.w d1,d5 ; add tile data from d1 to d5
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d5,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(3*3),d1 ; next tile group start
    sub.w #(3*8),d4 ; position of next tile group start (0,1)
    add.w #(3*8),d3
    and.w #$F800,d5 ; clear tile data from d5
    or.w d1,d5 ; add tile data from d1 to d5
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d5,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(3*3),d1 ; next tile group start
    add.w #(3*8),d4 ; position of next tile group start (1,1)
    and.w #$F800,d5 ; clear tile data from d5
    or.w d1,d5 ; add tile data from d1 to d5
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d5,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x
    rts

; a2: enemy struct
; d2: not allowed
OgreUpdateFacingDirection:
    move.w N_ENEMY_X(a2),d0 ; enemy_x
    sub.w CURRENT_X,d0 ; enemy_x - hero_x
    jsr AbsValue ; | enemy_x - hero_x |
    move.w d0,d1
    move.w N_ENEMY_Y(a2),d0 ; enemy_y
    sub.w CURRENT_Y,d0 ; enemy_y - hero_y
    jsr AbsValue ; | enemy_y - hero_y |
    cmp.w d0,d1 ; |dx| - |dy|
    bgt.s .FacingX
    ; facing y
    move.w N_ENEMY_Y(a2),d0 ; enemy_y
    sub.w CURRENT_Y,d0 ; enemy_y - hero_y
    blt.s .FacingDown
    ; facing up
    move.b #FACING_UP,(N_ENEMY_DATA2+1)(a2)
    rts
.FacingDown
    move.b #FACING_DOWN,(N_ENEMY_DATA2+1)(a2)
    rts
.FacingX
    move.w N_ENEMY_X(a2),d0 ; enemy_x
    sub.w CURRENT_X,d0 ; enemy_x - hero_x
    blt.s .FacingRight
    ; facing left
    move.b #FACING_LEFT,(N_ENEMY_DATA2+1)(a2)
    rts
.FacingRight
    move.b #FACING_RIGHT,(N_ENEMY_DATA2+1)(a2)
    rts

; a2: enemy struct
; d2: not allowed
; return target position in d0,d1
OgreGetTargetPosition:
    ; ogre above hero: y > x && y > -x
    ; ogre below hero: y < x && y < -x
    ; ogre left of hero: y > x && y < -x
    ; ogre right of hero: y < x && y > -x
    ; keep things simple; using sprite centerpoints for positions. but what can go wrong?
    move.w N_ENEMY_X(a2),d0 ; enemy_center_x
    sub.w CURRENT_X,d0 ; enemy_center_x - hero_min_x
    sub.w #(HERO_WIDTH/2),d0 ; enemy_center_x - hero_center_x
    
    move.w N_ENEMY_Y(a2),d1 ; enemy_center_y
    sub.w CURRENT_Y,d1 ; enemy_center_y - hero_min_y
    sub.w #(HERO_HEIGHT/2),d1 ; enemy_center_y - hero_center_y

    cmp.w d0,d1
    bgt.s .ygtx
    ; y <= x
    neg.w d0 ; -x
    cmp.w d0,d1
    bgt.s .RightOfHero
    bra.s .AboveHero
.ygtx
    neg.w d0 ; -x
    cmp.w d0,d1
    bgt.s .BelowHero
    bra.s .LeftOfHero
.AboveHero
    move.w CURRENT_X,d0
    add.w #(HERO_WIDTH/2),d0
    move.w CURRENT_Y,d1
    sub.w #OGRE_DESIRED_DIST,d1
    sub.w N_ENEMY_HALF_H(a2),d1
    rts
.BelowHero
    move.w CURRENT_X,d0
    add.w #(HERO_WIDTH/2),d0
    move.w CURRENT_Y,d1
    add.w #(OGRE_DESIRED_DIST+HERO_HEIGHT),d1
    add.w N_ENEMY_HALF_H(a2),d1
    rts
.LeftOfHero
    move.w CURRENT_X,d0
    sub.w #OGRE_DESIRED_DIST,d0
    sub.w N_ENEMY_HALF_W(a2),d0
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1
    rts
.RightOfHero
    move.w CURRENT_X,d0
    add.w #(OGRE_DESIRED_DIST+HERO_WIDTH),d0
    add.w N_ENEMY_HALF_W(a2),d0
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1
    rts

; d0 is enemy_state. uses a0. result in d1
OgreCanBeHit:
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Dead,.Alive,.Dying,.Hitstun
.Dead
    move.b #0,d1
    rts
.Alive
    move.b #1,d1
    rts
.Dying
    move.b #0,d1
    rts
.Hitstun
    move.b #1,d1
    rts

; TODO: refactor to use UtilIsEnemyHitBySlash
; a2: ogre struct
; d2: not allowed
OgreUpdateFromSlash:
    ; skip if hero not slashing
    ; TODO: consider checking this just once to skip all slash updates
    clr.l d0
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    bne.s .end
    ; skip if enemy not hittable
    move.w N_ENEMY_STATE(a2),d0
    jsr OgreCanBeHit ; result in d1
    tst.b d1
    beq.s .end
    ; check slash AABB against enemy's AABB
    move.w SLASH_MAX_X,d0
    move.w N_ENEMY_X(a2),d1
    move.w N_ENEMY_HALF_W(a2),d3
    sub.w d3,d1 ; enemy_min_x
    cmp.w d0,d1 ; enemy_min_x - slash_max_x
    bgt.s .end
    add.w d3,d1
    add.w d3,d1 ; enemy_max_x
    move.w SLASH_MIN_X,d0
    cmp.w d1,d0 ; slash_min_x - enemy_max_x
    bgt.s .end
    move.w SLASH_MAX_Y,d0
    move.w N_ENEMY_Y(a2),d1
    move.w N_ENEMY_HALF_H(a2),d3
    sub.w d3,d1 ; enemy_min_y
    cmp.w d0,d1 ; enemy_min_y - slash_max_y
    bgt.s .end
    add.w d3,d1
    add.w d3,d1 ; enemy_max_y
    move.w SLASH_MIN_Y,d0
    cmp.w d1,d0 ; slash_min_y - enemy_max_y
    bgt.s .end
    ; we have an overlap! deduct a hitpoint and put enemy in either hitstun or dying
    sub.w #1,N_ENEMY_HP(a2)
    ble.s .KillEnemy
    ; enter hitstun
    ; move.w #ENEMY_STATE_HITSTUN,N_ENEMY_STATE(a2)
    ; move.w #OGRE_HITSTUN_DURATION,N_ENEMY_STATE_FRAMES_LEFT(a2)
    move.b #OGRE_HURT_FLICKER_DURATION,N_ENEMY_DATA2(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    bra.s .end
.KillEnemy
    ; TODO: enter dying instead of dead!
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
    move.w #ENEMY_DYING_FRAMES,N_ENEMY_STATE_FRAMES_LEFT(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
.end
    rts

; a2: ogre struct
; d2: not allowed
OgreEnemyUpdate:
    ; update hurt flicker
    tst.b N_ENEMY_DATA2(a2)
    beq.s .DoneFlickering
    sub.b #1,N_ENEMY_DATA2(a2)
.DoneFlickering
    jsr OgreUpdateFromSlash
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    M_JumpTable #.StateJumpTable,a0,d0
.StateJumpTable dc.l .Dead,.Alive,.Dying,.Hitstun
.Dead
    rts ; shouldn't happen
.Alive
    jsr OgreEnemyAliveUpdate
    bra.s .end
.Dying
    jsr OgreEnemyDyingUpdate
    bra.s .end
.Hitstun
    jsr OgreEnemyHitstunUpdate
    bra.s .end
.end
    rts

OgreIdleUpdate:
    jsr OgreUpdateFacingDirection
    jsr OgreGetTargetPosition ; position in d0,d1
    sub.w N_ENEMY_X(a2),d0 ; target_x - ogre_x
    blt.s .MoveLeft
    ; move right
    move.l N_ENEMY_X(a2),d0
    add.l #OGRE_WALK_SPEED,d0
    ; move.l #((MAX_DISPLAY_X-24)<<16),d3 ; max_x - half_ogre_width
    ; M_ClampMaxL d0,d3
    move.l d0,N_ENEMY_X(a2)
    bra.s .Next
.MoveLeft
    move.l N_ENEMY_X(a2),d0
    sub.l #OGRE_WALK_SPEED,d0
    ; move.l #((MIN_DISPLAY_X+24)<<16),d3 ; min_x + half_ogre_width
    ; M_ClampMinL d0,d3
    move.l d0,N_ENEMY_X(a2)
.Next
    sub.w N_ENEMY_Y(a2),d1 ; target_y - ogre_y
    blt.s .MoveUp
    ; move down
    move.l N_ENEMY_Y(a2),d0
    add.l #OGRE_WALK_SPEED,d0
    ; move.l #((MAX_DISPLAY_Y-24)<<16),d3 ; max_y - half_ogre_height
    ; M_ClampMaxL d0,d3
    move.l d0,N_ENEMY_Y(a2)
    bra.s .AfterWalk
.MoveUp
    move.l N_ENEMY_Y(a2),d0
    sub.l #OGRE_WALK_SPEED,d0
    ; move.l #((MIN_DISPLAY_Y+24)<<16),d3 ; min_y + half_ogre_height
    ; M_ClampMinL d0,d3
    move.l d0,N_ENEMY_Y(a2)
.AfterWalk
    ; check if should switch to slash startup state. For now, it's on a timer.
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt.s .NoTransition
    and.b #%11111100,N_ENEMY_DATA1(a2) ; set next_state to startup
    or.b #OGRE_STATE_STARTUP,N_ENEMY_DATA1(a2)
    ; GROSS: figure out a good way to do new state init in the state itself
    move.w #OGRE_STARTUP_DURATION,N_ENEMY_STATE_FRAMES_LEFT(a2)
.NoTransition
    rts

OgreStartupUpdate:
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt.s .NoTransition
    ; Transition to slashing
    and.b #%11111100,N_ENEMY_DATA1(a2) ; set next_state to slashing
    or.b #OGRE_STATE_SLASHING,N_ENEMY_DATA1(a2)
.NoTransition
    rts

OgreSlashingUpdate:
    ; only slashing for one frame. Transition to recovery.
    and.b #%11111100,N_ENEMY_DATA1(a2) ; set next_state to recovery
    or.b #OGRE_STATE_RECOVERY,N_ENEMY_DATA1(a2)
    move.w #OGRE_RECOVERY_DURATION,N_ENEMY_STATE_FRAMES_LEFT(a2)
    rts

OgreRecoveryUpdate:
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt.s .NoTransition
    ; Transition to idle
    and.b #%11111100,N_ENEMY_DATA1(a2)
    or.b #OGRE_STATE_IDLE,N_ENEMY_DATA1(a2)
    move.w #30,N_ENEMY_STATE_FRAMES_LEFT(a2)
.NoTransition
    rts

; a2: ogre struct
; d2: not allowed
OgreEnemyAliveUpdate:
    clr.l d0
    ; transition to "next state" by copying next state into current state.
    move.b N_ENEMY_DATA1(a2),d0
    and.b #OGRE_STATE_MASK,d0
    and.b #%11111100,(N_ENEMY_DATA1+1)(a2)
    or.b d0,(N_ENEMY_DATA1+1)(a2)
    M_JumpTable #.StateJumpTable,a0,d0 ; new state still in d0
.StateJumpTable dc.l .Idle,.Startup,.Slashing,.Recovery
.Idle:
    jsr OgreSetIdleHurtboxSize ; TODO: figure out how to not do this every frame
    jsr OgreIdleUpdate
    rts
.Startup:
    jsr OgreSetSlashStartupHurtboxSize ; TODO: figure out how to not do this every frame
    jsr OgreStartupUpdate
    rts
.Slashing:
    jsr OgreSetSlashingHurtboxSize ; TODO: figure out how to not do this every frame
    jsr OgreSlashingUpdate
    rts
.Recovery:
    jsr OgreSetSlashingHurtboxSize ; TODO: figure out how to not do this every frame
    jsr OgreRecoveryUpdate
    rts

; a2: ogre struct
; d2: not allowed
OgreEnemyDyingUpdate:
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt.s .StillDying
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
.StillDying
    ; TODO: dying animation?
    rts

; a2: ogre struct
; d2: not allowed
OgreEnemyHitstunUpdate:
    sub.w #1,N_ENEMY_STATE_FRAMES_LEFT(a2)
    bgt.s .StillDying
    move.w #ENEMY_STATE_ALIVE,N_ENEMY_STATE(a2)
.StillDying
    ; TODO: dying animation?
    rts

; a2: ogre struct
; d2: do not touch
OgreMaybeDrawSlash:
    clr.l d0
    move.b (N_ENEMY_DATA1+1)(a2),d0 ; load state
    and.b #OGRE_STATE_MASK,d0
    cmp.b #OGRE_STATE_SLASHING,d0
    bne.s .end ; quit if ogre isn't slashing
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    jsr OgreDrawUpSlash
    rts
.Down
    jsr OgreDrawDownSlash
    rts
.Left
    jsr OgreDrawLeftSlash
    rts
.Right
    jsr OgreDrawRightSlash
    rts
.end
    rts

OgreDrawUpSlash:
    move.w #$0F00,d0 ; 4x4 (to be combined with link data)

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w N_ENEMY_X(a2),d3
    add.w #MIN_DISPLAY_X,d3
    sub.w #(OGRE_VERT_SLASH_SPRITE_W/2),d3
    move.w N_ENEMY_Y(a2),d4
    sub.w CAMERA_TOP_Y,d4
    add.w #MIN_DISPLAY_Y,d4
    sub.w #(24+OGRE_VERT_SLASH_SPRITE_H),d4
    move.w #OGRE_SLASH_UP_TILE_START,d1
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    ; drawing 2x4 this time
    move.w #$0700,d0
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    ; TODO: we're only drawing half of the slash right now because who cares
    rts

OgreDrawDownSlash:
    move.w #$0F00,d0 ; 4x4 (to be combined with link data)

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w N_ENEMY_X(a2),d3
    add.w #MIN_DISPLAY_X,d3
    sub.w #(OGRE_VERT_SLASH_SPRITE_W/2),d3
    move.w N_ENEMY_Y(a2),d4
    sub.w CAMERA_TOP_Y,d4
    add.w #MIN_DISPLAY_Y,d4
    add.w #(24+OGRE_VERT_SLASH_SPRITE_H/2),d4
    move.w #OGRE_SLASH_UP_TILE_START,d1
    bset.l #12,d1 ; flip vertical
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    ; drawing 2x4 this time
    move.w #$0700,d0
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    ; TODO only drawing half the slash.
    rts

OgreDrawRightSlash:
    move.w #$0F00,d0 ; 4x4 (to be combined with link data)

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w N_ENEMY_X(a2),d3
    add.w #MIN_DISPLAY_X,d3
    add.w #24,d3
    move.w N_ENEMY_Y(a2),d4
    sub.w CAMERA_TOP_Y,d4
    add.w #MIN_DISPLAY_Y,d4
    sub.w #(OGRE_VERT_SLASH_SPRITE_H/2),d4
    move.w #OGRE_SLASH_RIGHT_TILE_START,d1
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    sub.w #(4*8),d3 ; back to x start
    add.w #(4*8),d4 ; next y position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    ; TODO missing bottom of slash
    rts

OgreDrawLeftSlash:
    move.w #$0F00,d0 ; 4x4 (to be combined with link data)

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w N_ENEMY_X(a2),d3
    add.w #MIN_DISPLAY_X,d3
    sub.w #(24+OGRE_VERT_SLASH_SPRITE_W/2),d3
    move.w N_ENEMY_Y(a2),d4
    sub.w CAMERA_TOP_Y,d4
    add.w #MIN_DISPLAY_Y,d4
    sub.w #(OGRE_VERT_SLASH_SPRITE_H/2),d4
    move.w #OGRE_SLASH_RIGHT_TILE_START,d1
    bset.l #11,d1
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    sub.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(4*8),d3 ; back to x start
    add.w #(4*8),d4 ; next y position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    sub.w #(4*8),d3 ; next x position
    add.w #(4*4),d1 ; next tile start
    move.w d4,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d3,vdp_data ; x

    ; TODO missing bottom of slash
    rts

OgreMaybeHurtHero:
    jsr OgreCheckBodyHurtHero
    tst.b d0
    bge.s .overlap
    ; no body overlap, so now check slash
    jsr OgreCheckSlashHurtHero
    tst.b d0
    bge.s .overlap
    rts
.overlap
    move.w #HERO_STATE_HURT,HERO_STATE
    move.w #1,HERO_NEW_STATE
    move.b d0,(HURT_DIRECTION+1)
    rts

; a2: ogre struct
; don't touch d2
; d0: returns -1 if no overlap, or FACING_DIRECTION otherwise.
OgreCheckBodyHurtHero:
    move.w N_ENEMY_HALF_H(a2),-(sp)
    move.w N_ENEMY_Y(a2),-(sp)
    move.w N_ENEMY_HALF_W(a2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilMinAABBOverlapHero
    add.l #(4*2),sp
    rts

; TODO: change to not use UtilMinAABBOverlapHero to save some cycles.
;
; a2: ogre struct
; don't touch d2
; d0: returns -1 if no overlap, or FACING_DIRECTION otherwise
OgreCheckSlashHurtHero:
    move.b (N_ENEMY_DATA1+1)(a2),d0 ; state
    and.b #OGRE_STATE_MASK,d0
    cmp.b #OGRE_STATE_SLASHING,d0 ; no overlap if not slashing
    beq.s .slashing
    move.b #-1,d0
    rts
.slashing
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up:
    move.w #(OGRE_VERT_SLASH_SPRITE_H/2),-(sp)
    move.w N_ENEMY_Y(a2),d0
    sub.w #(24+OGRE_VERT_SLASH_SPRITE_H/2),d0
    move.w d0,-(sp)
    move.w #(OGRE_HORIZ_SLASH_SPRITE_W/2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilMinAABBOverlapHero
    bra.s .AfterJumpTable
.Down:
    move.w #(OGRE_VERT_SLASH_SPRITE_H/2),-(sp)
    move.w N_ENEMY_Y(a2),d0
    add.w #(24+OGRE_VERT_SLASH_SPRITE_H/2),d0
    move.w d0,-(sp)
    move.w #(OGRE_HORIZ_SLASH_SPRITE_W/2),-(sp)
    move.w N_ENEMY_X(a2),-(sp)
    jsr UtilMinAABBOverlapHero
    bra.s .AfterJumpTable
.Left:
    move.w #(OGRE_VERT_SLASH_SPRITE_H/2),-(sp)
    move.w N_ENEMY_Y(a2),-(sp)
    move.w #(OGRE_HORIZ_SLASH_SPRITE_W/2),-(sp)
    move.w N_ENEMY_X(a2),d0
    sub.w #(24+OGRE_HORIZ_SLASH_SPRITE_W/2),d0
    move.w d0,-(sp)
    jsr UtilMinAABBOverlapHero
    bra.s .AfterJumpTable
.Right
    move.w #(OGRE_VERT_SLASH_SPRITE_H/2),-(sp)
    move.w N_ENEMY_Y(a2),-(sp)
    move.w #(OGRE_HORIZ_SLASH_SPRITE_W/2),-(sp)
    move.w N_ENEMY_X(a2),d0
    add.w #(24+OGRE_HORIZ_SLASH_SPRITE_W/2),d0
    move.w d0,-(sp)
    jsr UtilMinAABBOverlapHero
    bra.s .AfterJumpTable
.AfterJumpTable
    add.l #(4*2),sp
    tst.b d0
    blt.s .end
    ; just use ogre's direction (ignore min overlap aabb)
    move.b (N_ENEMY_DATA2+1)(a2),d0 ; load direction
    and.b #OGRE_DIRECTION_MASK,d0 ; mask out direction (in case we add more data later)
.end
    rts