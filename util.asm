InfiniteLoop: macro
.infinite:
    move.b #0,d7
    beq.s .infinite
    endm

; \1: address, \2: aux register, \3: ram id code
SetXramAddr: macro
    move.w \1,\2
    and.w #$3FFF,\1 ; zero out top 2 bits of address
    lsl.l #$08,\1 ; want to shift 16 bits; but maximum shift is 8 bits per instruction
    lsl.l #$08,\1 ; TODO: maybe register shift can do full 16 bits?
    lsr.w #$08,\2
    lsr.w #$06,\2
    move.w \2,\1
    or.l #\3,\1
    move.l \1,(vdp_control)
    endm

SetVramAddr: macro
    SetXramAddr \1,\2,VRAM_ADDR_CMD
    endm

SetCramAddr: macro
    SetXramAddr \1,\2,CRAM_ADDR_CMD
    endm

SetVsramAddr: macro
    SetXramAddr \1,\2,VSRAM_ADDR_CMD
    endm

; uses \1 and \2 registers. updates CONTROLLER
GetControls: macro
    move.b #$40,$A10003 ; prepare controller 1 for reading part 1
    nop ; wait a moment
    nop
    nop
    nop
    move.b $A10003,\1 ; get first few buttons
    not.b \1
    move.b #$00,$A10003 ; prepare controller 1 for reading part 2
    nop
    nop
    nop
    nop
    move.b $A10003,\2 ; get next few buttons
    not.b \2
    ; now reorganize buttons into d7 as SACBRLDU
    and.b #$3F,\1
    and.b #$30,\2
    lsl.b #2,\2
    or.b \2,\1
    move.b \1,CONTROLLER
    endm

; d0: x, d1: min, output in d0
ClampMin:
    cmp.w d1,d0 ; x - min
    bge.s .ClampMinDone
    move.w d1,d0
.ClampMinDone:
    rts

; d0: x, d1: max, output in d0
ClampMax:
    cmp.w d0,d1 ; max - x
    bge.s .ClampMaxDone
    move.w d1,d0
.ClampMaxDone:
    rts

; d0: x, d1: min, d2: max. output in d0
; Clamp:
;     cmp.w d1,d0 ; x - min
;     bge.s .ClampMax
;     move.w d1,d0
;     rts
; .ClampMax
;     cmp.w d0,d2 ; max - x
;     bge.s .ClampDone
;     move.w d2,d0
; .ClampDone
;     rts

@test_psg:
    ; Set pitch of channel 0.
    move.w #0,d0    ; channel 0
    move.w #425,d1  ; frequency (C-2)

    ; Split the frequency into
    ; its two parts
    move.w  d1,d2
    lsr.w   #4,d2
    and.b   #$0F,d1
    and.b   #$3F,d2

    ; Prepare the first byte (the
    ; second one is d2 as-is)
    ror.b   #3,d0
    or.b    d1,d0
    or.b    #$80,d0

    ; Send the bytes
    move.b  d0,psg_port
    move.b  d2,psg_port

    ; Set channel 0 to max volume
    move.w #0,d0    ; channel 0
    move.w #0,d1    ; attenuation 0
    ror.b #3,d0
    or.b d1,d0
    or.b #$90,d0
    move.b d0,psg_port

    rts

WaitUntilFmNotBusy:
    add.b #1,d1
fm_test_wait_loop
    move.b FM_PART1_ADDR,d0
    and.b #%10000000,d0
    bne.s fm_test_wait_loop
    rts

; tile idx in d0
DoesTileCollide:
    move.l #TILEMAP_RAM,a0
    ; need to move d0 words forward, which is the same as 2*d0 bytes.
    lsl.w #1,d0
    add.w d0,a0
    move.w (a0),d0
    ; now d0 holds the index into TileCollisions we need to check.
    move.l #TILE_COLLISIONS,a0
    ; need to move d0 words forward, which is the same as 2*d0 bytes.
    lsl.w #1,d0
    add.w d0,a0
    ; now load in the collision info to d0
    move.w (a0),d0
    rts

; x in d0, y in d1. outputs result in d0. 0 if collision-free, 1 if collision
CheckCollisions:
    ; get the tile that CURRENT_X,CURRENT_Y corresponds to.
    ; first we have translate such that (0,0) corresponds to top-left of tilemap.
    sub.w #MIN_DISPLAY_X,d0
    sub.w #MIN_DISPLAY_Y,d1
    ; usually done by dividing CURRENT_X by TILE_WIDTH; but we know that TILE_WIDTH is 8px. ezpz.
    lsr.w #3,d0 ; divide by 8 (tile width)
    lsr.w #3,d1
    ; Now d0,d1 is our tile coordinate. But we need to turn that into a single index. Oh lord,
    ; this means querying the tilemap at this location to get the tileset value, and then querying
    ; the collision data for that tileset value. omg
    ; TODO: ouch, MUL is 70 cycles. Maybe we should keep track of both a (x,y) and a linear index?
    ;mulu.w #40,d1 ; 40 tiles per row in this tilemap (UGH I KNOW OK)
    lsl.w #6,d1 ; 64 tiles per row, so multiply by 64 by left-shifting 6 times
    add.w d1,d0
    move.w d0,d1
    ; d0 and d1 now both hold our tile index. We gotta check this tile and the neighboring tiles that the hero
    ; is also touching. Because the hero position is on the top-left corner of the sprite, we only
    ; need to check right and down. So we should *always* check 6 cells in the 2x3 area of the sprite.
    ; we'll also check the next column/row over for offset within the top-left cell.
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0 ; put tile index back in d0
    add.w #1,d0 ; (1,0)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #2,d0 ; (2,0)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #TILEMAP_WIDTH,d0 ; (0,1)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #(TILEMAP_WIDTH+1),d0 ; (1,1)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #(TILEMAP_WIDTH+2),d0 ; (2,1)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #(2*TILEMAP_WIDTH),d0 ; (0,2)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #(2*TILEMAP_WIDTH+1),d0 ; (1,2)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #(2*TILEMAP_WIDTH+2),d0 ; (2,2)
    jsr DoesTileCollide
    tst.w d0
    ;bne.s .CheckCollisionsDone
.CheckCollisionsDone:
    rts


; x in d0, y in d1. outputs result in d0. 0 if collision-free, 1 if collision
CheckCollisionsPositionOnly:
    ; get the tile that CURRENT_X,CURRENT_Y corresponds to.
    ; first we have translate such that (0,0) corresponds to top-left of tilemap.
    sub.w #MIN_DISPLAY_X,d0
    sub.w #MIN_DISPLAY_Y,d1
    ; usually done by dividing CURRENT_X by TILE_WIDTH; but we know that TILE_WIDTH is 8px. ezpz.
    lsr.w #3,d0 ; divide by 8 (tile width)
    lsr.w #3,d1
    ; Now d0,d1 is our tile coordinate. But we need to turn that into a single index. Oh lord,
    ; this means querying the tilemap at this location to get the tileset value, and then querying
    ; the collision data for that tileset value. omg
    ; TODO: ouch, MUL is 70 cycles. Maybe we should keep track of both a (x,y) and a linear index?
    ;mulu.w #40,d1 ; 40 tiles per row in this tilemap (UGH I KNOW OK)
    lsl.w #6,d1 ; 64 tiles per row, so mult by 64 by << 6 (UGH I KNOW OK)
    add.w d1,d0
    ; Now d0 is our tile index. Check the tilemap+collision-table if this tile collides.
    jsr DoesTileCollide
    rts

SetLeftIdleAnim:
    move.w #SAMURAI_SPRITE_TILE_START,ANIM_START_INDEX
    move.w #SAMURAI_SPRITE_TILE_START,ANIM_LAST_INDEX
    move.w #SAMURAI_SPRITE_TILE_START,ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetRightIdleAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+2*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+2*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+2*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetWalkLeftAnim:
    move.w #SAMURAI_SPRITE_TILE_START,ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+6),ANIM_LAST_INDEX
    move.w #SAMURAI_SPRITE_TILE_START,ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetWalkRightAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+2*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+3*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+2*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetSlashLeftAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+4*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+4*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+4*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetSlashRightAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+5*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+5*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+5*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetWindupLeftAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+6*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+6*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+6*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetWindupRightAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+7*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+7*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+7*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetHurtLeftAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+8*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+8*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+8*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

SetHurtRightAnim:
    move.w #(SAMURAI_SPRITE_TILE_START+8*6),ANIM_START_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+8*6),ANIM_LAST_INDEX
    move.w #(SAMURAI_SPRITE_TILE_START+8*6),ANIM_CURRENT_INDEX
    move.w #6,ANIM_STRIDE
    rts

; new state is in d0. d0 gets clobbered. No return value
UpdateAnimState:
    cmp.w PREVIOUS_ANIM_STATE,d0
    bne.s .AfterEarlyReturn
    rts
.AfterEarlyReturn
    move.w #ITERATIONS_PER_ANIM_FRAME,ITERATIONS_UNTIL_NEXT_ANIM_FRAME
    move.w d0,PREVIOUS_ANIM_STATE

    move.l #.NewAnimStateJumpTable,a0
    and.l #$0000FFFF,d0 ; d0 is gonna be used as a long, so make sure the upper word is cleared out
    ; d0 is now the offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.NewAnimStateJumpTable dc.l .LeftIdle,.RightIdle,.LeftWalk,.RightWalk,.LeftSlashState,.RightSlashState,.LeftWindupState,.RightWindupState,.LeftHurtState,.RightHurtState
.LeftIdle
    jsr SetLeftIdleAnim
    rts
.RightIdle
    jsr SetRightIdleAnim
    rts
.LeftWalk
    jsr SetWalkLeftAnim
    rts
.RightWalk
    jsr SetWalkRightAnim
    rts
.LeftSlashState
    jsr SetSlashLeftAnim
    rts
.RightSlashState
    jsr SetSlashRightAnim
    rts
.LeftWindupState
    jsr SetWindupLeftAnim
    rts
.RightWindupState
    jsr SetWindupRightAnim
    rts
.LeftHurtState
    jsr SetHurtLeftAnim
    rts
.RightHurtState
    jsr SetHurtRightAnim
    rts
.UpdateAnimStateEnd
    rts

DrawHero:
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_DASHING,d0
    bne.s .DoDraw
    move.w HERO_STATE_FRAMES_LEFT,d0
    and.w #$0003,d0
    tst.b d0 ; flicker on every 4th frame
    beq.s .DoDraw
    rts
.DoDraw
    move.w CURRENT_Y,vdp_data
    move.w #$0600,d0 ; 2x3
    add.w #1,SPRITE_COUNTER
    or.w SPRITE_COUNTER,d0
    move.w d0,vdp_data
    move.w d0,LAST_LINK_WRITTEN
    ; construct 3rd entry from color palette number and tile number
    move.w ANIM_CURRENT_INDEX,d0
    move.w GLOBAL_PALETTE,d1
    ror.w #3,d1 ; put palette in position
    or.w d1,d0 ; add palette to d0
    move.w d0,vdp_data
    move.w CURRENT_X,vdp_data
    rts

DrawDashBar:
    ; only draw dash bar if dash is on cooldown
    ; TODO: keep drawing bar for a little longer after cooldown is done
    tst.w HERO_DASH_COOLDOWN_FRAMES_LEFT
    ble.s .End
    add.w #1,SPRITE_COUNTER
    move.w CURRENT_Y,d1
    sub.w #8,d1 ; move up above hero's head
    move.w #$0400,d2 ; 1x2 sprite
    or.w SPRITE_COUNTER,d2 ; add link data
    move.w d1,vdp_data
    move.w d2,vdp_data
    move.w d2,LAST_LINK_WRITTEN
    move.w HERO_DASH_COOLDOWN_FRAMES_LEFT,d0
    lsr.w #2,d0 ; divide by 4 to go from 32 to 8. Ugh what a terrible hack
    sub.w #1,d0
    ; clamp to 0
    bgt.s .AfterClamp
    move.w #0,d0
.AfterClamp
   ; flip it around so bar fills up
    neg.w d0
    add.w #7,d0
    add.w d0,d0; mult by 2 to go from frames to tiles.
    add.w #DASH_BAR_SPRITE_TILE_START,d0
    move.w d0,vdp_data
    move.w CURRENT_X,vdp_data
.End
    rts

UpdateEnemiesFromSlash:
    move.w #MAX_NUM_ENEMIES-1,d7
    move.l #ENEMY_STATE,a6
    move.l #ENEMY_X,a1
    move.l #ENEMY_Y,a2
    move.l #ENEMY_DYING_FRAMES_LEFT,a3
    move.l #ENEMY_DATA_1,a4
    move.l #ENEMY_DATA_2,a5
    move.w SLASH_MIN_X,d1
    move.w SLASH_MAX_X,d2
    move.w SLASH_MIN_Y,d3
    move.w SLASH_MAX_Y,d4
.EnemyUpdateSlashLoop
    move.w (a6),d5 ; alive (don't increment pointer because we may update it below)
    beq.w .EnemyUpdateSlashLoopContinue
    cmp.w #ENEMY_STATE_ALIVE,d5
    beq.s .CheckSlashEnemy
    ; otherwise, enemy is dying (TODO use a jump table idiot)
    sub.w #1,(a3)
    bne.w .EnemyUpdateSlashLoopContinue ; not dead yet, go to next enemy
    move.w #ENEMY_STATE_DEAD,(a6)
    bra.w .EnemyUpdateSlashLoopContinue
.CheckSlashEnemy
    ; check slash AABB against enemy's AABB
    move.w HERO_STATE,d5
    cmp.w #HERO_STATE_SLASH_ACTIVE,d5
    bne.s .EnemyUpdateSlashLoopContinue
    move.w (a1),d5 ; min_enemy_x
    move.w (a2),d6 ; min_enemy_y
    cmp.w d2,d5 ; slash_max_x < min_enemy_x?
    bgt.s .EnemyUpdateSlashLoopContinue
    cmp.w d4,d6 ; slash_max_y < min_enemy_y?
    bgt.s .EnemyUpdateSlashLoopContinue
    add.w #2*8,d5 ; max_enemy_x (2x2 enemy)
    cmp.w d5,d1 ; max_enemy_x < slash_min_x?
    bgt.s .EnemyUpdateSlashLoopContinue
    add.w #2*8,d6 ; max_enemy_y
    cmp.w d6,d3 ; max_enemy_y < slash_min_y?
    bgt.s .EnemyUpdateSlashLoopContinue
    ; we have an overlap! put enemy in "dying" state and activate hitstop
    move.w #2,(a6)
    move.w #ENEMY_DYING_FRAMES,(a3)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
.EnemyUpdateSlashLoopContinue
    add.w #2,a6 ; move alive pointer to next entry
    add.w #4,a1
    add.w #4,a2
    add.w #2,a3
    add.w #2,a4
    add.w #2,a5
    dbra d7,.EnemyUpdateSlashLoop
    rts

UpdateEnemies:
    move.w #0,d2
    move.l #ENEMY_STATE,a2
    move.l #ENEMY_X,a3
    move.l #ENEMY_Y,a4
    move.l #ENEMY_DATA_1,a5
    move.l #ENEMY_DATA_2,a6
.EnemyUpdateLoop
    move (a2),d3 ; alive
    cmp.w #ENEMY_STATE_ALIVE,d3
    bne.s .EnemyUpdateLoopContinue
    ; get enemy type
    clr.l d0
    move.w d2,d0 ; get enemy index
    add.w d0,d0 ; multiply index by 2 to get address offset in bytes
    move.l #ENEMY_TYPE,a0 ; get start of enemy_type array
    move.w (a0,d0),d0 ; move enemy type into d0
    move.l #.TypeJumpTable,a0
    lsl.l #2,d0; ; longs to bytes.
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.TypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    jsr UpdateButtEnemy
    bra.s .EnemyUpdateLoopContinue
.HotDog:
    jsr UpdateHotDogEnemy
    bra.s .EnemyUpdateLoopContinue
.Ogre:
    jsr UpdateOgreEnemy
    bra.s .EnemyUpdateLoopContinue
.EnemyUpdateLoopContinue
    add.w #2,a2
    add.w #4,a3
    add.w #4,a4
    add.w #2,a5
    add.w #2,a6
    add.w #1,d2
    cmp.w #MAX_NUM_ENEMIES,d2
    blt.s .EnemyUpdateLoop
    rts

; d0 is sin(x)*256, where sin() does a full cycle every 256 units. a0 used
Sin:
    move.l #SineLookupTable,a0
    ; clamp angle to [0,255] and clear upper word
    and.l #$000000FF,d0
    add.l d0,d0 ; convert to byte address
    add.l d0,a0
    move.w (a0),d0
    rts

Cos:
    move.l #SineLookupTable,a0
    ; add 256/4 to input (like sin(x+90) normally)
    add.w #256/4,d0
    and.l #$000000FF,d0
    add.l d0,d0 ; convert to byte address
    add.l d0,a0
    move.w (a0),d0
    rts

; x and y pushed onto the stack behind the stack pointer
; return value in d0
Atan2:
    move.w 4(sp),d0 ; x
    move.w 6(sp),d1 ; y
    ; 64x64 table. each axis corresponds to [-32,31].
    ; First we gotta shift each value until it's in that range.
.Atan2ShiftLoop
    cmp.w #-32,d0
    blt.s .Atan2Shift
    cmp.w #31,d0
    bgt.s .Atan2Shift
    cmp.w #-32,d1
    blt.s .Atan2Shift
    cmp.w #31,d1
    bgt.s .Atan2Shift
    bra.s .Atan2AfterShift
.Atan2Shift
    asr.w #1,d0 ; arithmetic shift maintains the sign of the input value!!
    asr.w #1,d1 ; gotta shift both to maintain the right proportion
    bra.s .Atan2ShiftLoop
.Atan2AfterShift
    ; convert into x/y indices [0,63]
    add.w #32,d0
    add.w #32,d1
    move.l #atan2LookupTable,a0
    ; index into table = 2*(64*y + x)
    lsl.l #6,d1
    add.l d0,d1
    add.l d1,d1
    add.l d1,a0
    move.w (a0),d0
    rts

; dx and dy pushed onto the stack behind the stack pointer
LengthSqr:
    move.w 4(sp),d0 ; x
    move.w 6(sp),d1 ; y
    muls.w d0,d0
    muls.w d1,d1
    add.w d1,d0
    rts

LoadNormalPalette:
    clr.w d0
    SetCramAddr d0,d1
    move #(16-1),d0
    move.l #SimplePalette,a0
.normal_palette_loop
    move.w (a0)+,vdp_data
    dbra d0,.normal_palette_loop
    rts

LoadInversePalette:
    clr.w d0
    SetCramAddr d0,d1
    move #(16-1),d0
    move.l #InversePalette,a0
.inverse_palette_loop
    move.w (a0)+,vdp_data
    dbra d0,.inverse_palette_loop
    rts

; d0 in/out
AbsValue:
    tst.w d0
    bge.s .End
    neg.w d0
.End
    rts

; Should be called during freeze only
CheckForDashBuffer:
    ; if slash is active, this is an attack hitstop. look for a buffered input to dash.
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    bne.w .End
    tst.w DASH_BUFFERED ; if dash is already buffered, exit
    bne.w .End
    GetControls d0,d1
    move.b CONTROLLER,d0
    btst.l #C_BIT,d0
    beq.s .End
    move.w #1,DASH_BUFFERED
    ; now look for a direction and update FACING_DIRECTION if we find one
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

; d0 is x. Makes a smooth step from [0,65536] -> [0,65536].
; TODO try to avoid long math.
; SmoothStep:
;     lsr.l #8,d0 ; cx
;     move.l d0,d1 ; cx in d1
;     mulu d1,d0 ; (cx)^2 in d0
;     mulu d0,d1 ; (cx)^3 in d1
;     ; TODO AVOID THIS MULTIPLY BY 3
;     mulu #3,d0 ; 3(cx)^2 in d0
;     ; c in this case is 256. 2(cx^3)/c is just dividing by 128, or shifting right 7 times.
;     lsr.l #7,d1 ; 2(cx)^3/c in d1
;     sub.l d1,d0
;     rts