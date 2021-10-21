M_InfiniteLoop: macro
.infinite\@:
    move.b #0,d7
    beq.s .infinite\@
    endm

; \1: jump table start address, \2: address register, \3: index register
M_JumpTable: macro
    move.l \1,\2
    lsl.l #2,\3 ; translate longs into bytes
    add.l \3,\2
    ; dereference jump table to get address to jump to
    move.l (\2),\2
    jmp (\2)
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

; d0: x
; d1: y
; both are gonna get clobbered.
UtilSetScrollAWriteAt:
    lsl.w #6,d1 ; 64 * y
    add.w d0,d1 ; x + 64 * y
    add.w d1,d1 ; go from tiles to bytes
    add.w #SCROLL_A_BASE_ADDR,d1
    SetVramAddr d1,d0
    rts

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

; \1: x, \2: min, output in \1. All words
M_ClampMinL: macro
    cmp.l \2,\1 ; x - min
    bge.s .ClampMinDone\@
    move.l \2,\1
.ClampMinDone\@
    endm

; \1: x, \2: max, output in \1. all words
M_ClampMaxL: macro
    cmp.l \1,\2 ; max - x
    bge.s .ClampMaxDone\@
    move.l \2,\1
.ClampMaxDone\@
    endm

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
; checks both layers of tiles.
DoesTileCollide:
    ; push original ix on stack for use later
    move.w d0,-(sp)
    move.l #TileMap,a0
    ; need to move d0 words forward, which is the same as 2*d0 bytes.
    add.l d0,d0
    add.l d0,a0
    move.w (a0),d0
    and.l #$000007FF,d0 ; only keep the tile index part
    ; now d0 holds the index into TileCollisions we need to check.
    move.l #TILE_COLLISIONS,a0
    ; need to move d0 words forward, which is the same as 2*d0 bytes.
    add.l d0,d0
    add.w d0,a0
    ; now load in the collision info to d0
    move.w (a0),d0
    bne.s .end  ; if we found a collision, exit here
    ; Now look for a collision in the other layer
    clr.l d0
    move.w (sp),d0 ; move tile ix back into d0
    move.l #(TileMap+TILEMAP_WIDTH*TILEMAP_HEIGHT*2),a0
    ; need to move d0 words forward, which is the same as 2*d0 bytes.
    add.l d0,d0
    add.l d0,a0
    move.w (a0),d0
    and.l #$000007FF,d0 ; only keep the tile index part
    ; now d0 holds the index into TileCollisions we need to check.
    move.l #TILE_COLLISIONS,a0
    ; need to move d0 words forward, which is the same as 2*d0 bytes.
    add.l d0,d0
    add.w d0,a0
    ; now load in the collision info to d0
    move.w (a0),d0
.end
    add.l #2,sp
    rts

; NOTE: THIS ASSUMES THAT TILEMAP_WIDTH == 64!!!!
; x in d0, y in d1. outputs result in d0. 0 if collision-free, 1 if collision
; Assume that x and y can be longs.
CheckCollisions:
    ; get the tile that CURRENT_X,CURRENT_Y corresponds to.
    ; usually done by dividing CURRENT_X by TILE_WIDTH; but we know that TILE_WIDTH is 8px. ezpz.
    lsr.l #3,d0 ; divide by 8 (tile width)
    lsr.l #3,d1
    ; Now d0,d1 is our tile coordinate. But we need to turn that into a single index. Oh lord,
    ; this means querying the tilemap at this location to get the tileset value, and then querying
    ; the collision data for that tileset value. omg
    ; TODO: ouch, MUL is 70 cycles. Maybe we should keep track of both a (x,y) and a linear index?
    ;mulu.w #40,d1 ; 40 tiles per row in this tilemap (UGH I KNOW OK)
    lsl.l #6,d1 ; 64 tiles per row, so multiply by 64 by left-shifting 6 times
    add.l d1,d0
    move.l d0,d1
    ; d0 and d1 now both hold our tile index. We gotta check this tile and the neighboring tiles that the hero
    ; is also touching. Because the hero position is on the top-left corner of the sprite, we only
    ; need to check right and down. So we should *always* check 6 cells in the 2x3 area of the sprite.
    ; we'll also check the next column/row over for offset within the top-left cell, so that makes it
    ; 3x4.
    move.w #(HERO_WIDTH_IN_TILES+1-1),d2
    move.w #(HERO_HEIGHT_IN_TILES+1-1),d3
.row_loop
.column_loop
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    add.l #1,d1
    move.l d1,d0
    dbra d2,.column_loop
    move.w #(HERO_WIDTH_IN_TILES+1-1),d2
    add.l #(TILEMAP_WIDTH-(HERO_WIDTH_IN_TILES+1)),d1
    move.l d1,d0
    dbra d3,.row_loop
    ; After the loop, if no collisions then clear d0
    clr.b d0
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
    move.w CURRENT_Y,d0
    sub.w CAMERA_TOP_Y,d0
    add.w #MIN_DISPLAY_Y,d0
    move.w d0,vdp_data
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
    move.w CURRENT_X,d0
    add.w #MIN_DISPLAY_X,d0
    move.w d0,vdp_data
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

UtilUpdateEnemies:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    move.w N_ENEMY_TYPE(a2),d0
    M_JumpTable #.TypeJumpTable,a0,d0
.TypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    jsr ButtUpdateEnemy
    bra.s .AfterJumpTable
.HotDog:
    bra.s .AfterJumpTable
.Ogre:
    jsr OgreEnemyUpdate
    bra.s .AfterJumpTable
.AfterJumpTable
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
.end_loop
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
    M_JumpTable #.TypeJumpTable,a0,d0
.TypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    jsr UpdateButtEnemy
    bra.s .EnemyUpdateLoopContinue
.HotDog:
    jsr UpdateHotDogEnemy
    bra.s .EnemyUpdateLoopContinue
.Ogre:
    ;jsr UpdateOgreEnemy
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

LoadPalettes:
    clr.w d0
    SetCramAddr d0,d1
    move #(16*4-1),d0
    move.l #AllPalettes,a0
.loop
    move.w (a0)+,vdp_data
    dbra d0,.loop
    rts

LoadInversePaletteIntoFirst:
    clr.w d0
    SetCramAddr d0,d1
    move #(16-1),d0
    move.l #InversePalette,a0
.inverse_palette_loop
    move.w (a0)+,vdp_data
    dbra d0,.inverse_palette_loop
    rts

LoadNormalPaletteIntoFirst:
    clr.w d0
    SetCramAddr d0,d1
    move #(16-1),d0
    move.l #SimplePalette,a0
.normal_palette_loop
    move.w (a0)+,vdp_data
    dbra d0,.normal_palette_loop
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

; don't touch a0
UtilLoadEnemies:
    move (a0)+,d2 ; enemy count is in d2
    sub.w #1,d2
    blt.w .after_loop
    move.l #N_ENEMIES,a1
.loop
    move.w #ENEMY_STATE_ALIVE,N_ENEMY_STATE(a1)
    clr.l d3
    move.w (a0)+,d3 ; enemy_type is in d3. Storing to use it later
    move.w d3,N_ENEMY_TYPE(a1)
    move.w (a0)+,d4 ; enemy_x
    move.w d4,N_ENEMY_X(a1)
    move.w (a0)+,d4 ; enemy_y
    move.w d4,N_ENEMY_Y(a1)
    M_JumpTable #.EnemyTypeJumpTable,a2,d3
.EnemyTypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    move.w #8,N_ENEMY_HALF_W(a1)
    move.w #8,N_ENEMY_HALF_H(a1)
    move.w #1,N_ENEMY_HP(a1)
    bra.s .AfterJumpTable
.HotDog:
    move.w #8,N_ENEMY_HALF_W(a1)
    move.w #8,N_ENEMY_HALF_H(a1)
    move.w #1,N_ENEMY_HP(a1)
    bra.s .AfterJumpTable
.Ogre:
    move.w #24,N_ENEMY_HALF_W(a1)
    move.w #24,N_ENEMY_HALF_H(a1)
    move.w #OGRE_HP,N_ENEMY_HP(a1)
    move.w #120,N_ENEMY_STATE_FRAMES_LEFT(a1)
    bra.s .AfterJumpTable
.AfterJumpTable
    add.l #N_ENEMY_SIZE,a1
    dbra d2,.loop
.after_loop
    rts

LoadEnemies:
    move.w (a0)+,d0 ; enemy count is in d0
    sub.w #1,d0
    blt.s .after_loop
    move.l #ENEMY_STATE,a1
    move.l #ENEMY_X,a2
    move.l #ENEMY_Y,a3
    move.l #ENEMY_DATA_1,a4
    move.l #ENEMY_TYPE,a5
    move.l #ENEMY_SIZE,a6
    clr.l d3
.loop
    move.w #ENEMY_STATE_ALIVE,(a1)+
    ; push a1 onto the stack so we can reuse it for this jump table
    move.l a1,-(sp)

    move.l #.EnemyTypeJumpTable,a1
    move.w (a0),d3 ; Enemy type is in a0 right now.
    lsl.l #2,d3 ; translate longs into bytes
    add.l d3,a1
    ; dereference jump table to get address to jump to
    move.l (a1),a1
    jmp (a1)
    ; TODO: consider making the entries into actual branch instructions.
    ; Can be 2 cycles faster apparently?
.EnemyTypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    move.w #$1010,(a6)+
    bra.s .AfterJumpTable
.HotDog:
    move.w #$1010,(a6)+
    bra.s .AfterJumpTable
.Ogre:
    move.w #$3030,(a6)+
    bra.s .AfterJumpTable
.AfterJumpTable

    move.l (sp)+,a1

    move.w (a0)+,(a5)+ ; enemy type
    move.w (a0)+,d1 ; enemy x
    add.w #MIN_DISPLAY_X,d1 ; add min display offset TODO: do this properly
    move.w d1,(a2)
    add.l #4,a2
    move.w (a0)+,d1 ; enemy y
    add.w #MIN_DISPLAY_Y,d1
    move.w d1,(a3)
    add.l #4,a3
    move.w #0,(a4)+ ; enemy_data_1
    dbra d0,.loop
.after_loop
    rts

UtilDrawEnemies:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
    clr.l d0
.loop
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    move.w N_ENEMY_TYPE(a2),d0
    M_JumpTable #.TypeJumpTable,a0,d0
.TypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    jsr ButtDrawEnemy
    bra.s .AfterJumpTable
.HotDog:
    bra.s .AfterJumpTable
.Ogre:
    jsr DrawOgreEnemy
    bra.s .AfterJumpTable
.AfterJumpTable
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
.end_loop
    rts

; DrawEnemies:
;     clr.l d2
;     move.b #0,d2
; .loop
;     cmp.b #MAX_NUM_ENEMIES,d2
;     bge.w .end
;     move.l #ENEMY_STATE,a0
;     clr.w d3
;     move.b d2,d3
;     add.b d3,d3
;     move.w 0(a0,d3),d0
;     ; if dead, skip to next enemy
;     beq.s .loop_continue
;     ; push everything we need onto the stack: state, dying_frames, data1, data2, x, y
;     move.w d0,-(sp) ; state
;     move.l #ENEMY_DYING_FRAMES_LEFT,a0
;     move.w 0(a0,d3),-(sp)
;     move.l #ENEMY_DATA_1,a0
;     move.w 0(a0,d3),-(sp)
;     move.l #ENEMY_DATA_2,a0
;     move.w 0(a0,d3),-(sp)
;     move.l #ENEMY_TYPE,a0
;     clr.l d0
;     move.w 0(a0,d3),d0 ; enemy type in d0
;     ; X and Y are 4 bytes, so multiply d3 by 2 again
;     add.b d3,d3
;     move.l #ENEMY_X,a0
;     move.l (0,a0,d3),-(sp)
;     move.l #ENEMY_Y,a0
;     move.l (0,a0,d3),-(sp)
;     ; now jump to draw function appropriate to this enemy type
;     move.l #.TypeJumpTable,a0
;     lsl.l #2,d0 ; translate longs into bytes
;     add.l d0,a0
;     ; dereference jump table to get address to jump to
;     move.l (a0),a0
;     jmp (a0)
; .TypeJumpTable dc.l .Butt,.HotDog,.Ogre
; .Butt:
;     jsr DrawButtEnemy
;     bra.s .AfterJumpTable
; .HotDog:
;     jsr DrawHotDogEnemy
;     bra.s .AfterJumpTable
; .Ogre:
;     ;jsr DrawOgreEnemy
;     bra.s .AfterJumpTable
; .AfterJumpTable
;     add.l #(2+2+4+4+2+2),sp
; .loop_continue
;     add.b #1,d2
;     bra.w .loop
; .end

UtilDrawEnemySlashes:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    move.w N_ENEMY_TYPE(a2),d0
    M_JumpTable #.TypeJumpTable,a0,d0
.TypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    bra.s .AfterJumpTable
.HotDog:
    bra.s .AfterJumpTable
.Ogre:
    jsr OgreMaybeDrawSlash
    bra.s .AfterJumpTable
.AfterJumpTable
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
.end_loop
    rts

UtilLoadEnemySprites:
    ; set VRAM WRITE address to the start of the title tiles
    move.w #(TITLE_TILE_START*TILE_SIZE),d0
    SetVramAddr d0,d1
OgreSpriteLoad:
OGRE_SPRITE_TILE_START: equ TITLE_TILE_START
OGRE_SPRITE_TILE_SIZE: equ (16*6*6)
    move.w #(8*OGRE_SPRITE_TILE_SIZE)-1,d0
    move.l #OgreSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

OgreSlashRightSpriteLoad:
OGRE_SLASH_RIGHT_TILE_START: equ (OGRE_SPRITE_TILE_START+OGRE_SPRITE_TILE_SIZE)
OGRE_SLASH_RIGHT_TILE_SIZE: equ (8*10)
    move.w #(8*OGRE_SLASH_RIGHT_TILE_SIZE)-1,d0
    move.l #OgreSlashRightSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

OgreSlashUpSpriteLoad:
OGRE_SLASH_UP_TILE_START: equ (OGRE_SLASH_RIGHT_TILE_START+OGRE_SLASH_RIGHT_TILE_SIZE)
OGRE_SLASH_UP_TILE_SIZE: equ (8*10)
    move.w #(8*OGRE_SLASH_UP_TILE_SIZE)-1,d0
    move.l #OgreSlashUpSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

DashBarSpriteLoad:
DASH_BAR_SPRITE_TILE_START: equ (OGRE_SLASH_UP_TILE_START+OGRE_SLASH_UP_TILE_SIZE)
DASH_BAR_SPRITE_TILE_SIZE: equ (2*8)
    move.w #(8*DASH_BAR_SPRITE_TILE_SIZE)-1,d0
    move.l #DashBarSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

rts

UtilClearScrollA:
    move.w #SCROLL_A_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w #(SCROLL_TILE_W*SCROLL_TILE_H-1),d0
    move.w #0,d1
.loop
    move.w d1,vdp_data
    dbra d0,.loop
    rts

; 4(sp): cameraMotionX out-param
; 6(sp): cameraMotionY out-param
UtilGetCameraMotion:
    ; Constantly trying to position camera to center on hero.
    move.w CAMERA_TOP_Y,d0
    add.w #(VISIBLE_TILE_H*8/2),d0 ; camera center
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1 ; hero center
    sub.w d0,d1 ; d1 = hero - camera
    beq .end
    blt .Less
    move.w #1,d1
    bra .end
.Less
    move.w #-1,d1
.end
    move.w #0,4(sp)
    move.w d1,6(sp)
    rts

UtilUpdateCamera:
; move camera, update scroll vars, and do tile fill-in
    ; populate new camera direction, then decide whether to accept it
    ; sp-2 is cameraMotionX
    ; sp-4 is cameraMotionY
    sub.l #4,sp ; push 2 words onto stack for out-params
    jsr UtilGetCameraMotion
    ; move.w #0,-(sp)
    ; move.w #0,-(sp)
    move.w (sp)+,d6
    move.w (sp)+,d7
    ; cameraMotionX/Y in d6/d7
    ; get previous tile position of camera
    move.w CAMERA_TOP_Y,d0
    move.w d0,d1 ; copy current camera-top-y to d1
    add.w d7,d1 ; new camera position in d0
    ; check if we want to move in that direction
    cmp.w #(2*8),d1 ; if new position is above top of map (with 2 rows of padding), return
    bge.s .AfterTopCheck
    rts
.AfterTopCheck
    cmp.w #((TILEMAP_HEIGHT-28)*8),d1 ; if camera-bottom goes below tilemap bottom, return
    ble.s .AfterBottomCheck
    rts
.AfterBottomCheck
    add.w d7,CAMERA_TOP_Y
    ; TODO: should we wrap these?
    add.w d7,CURRENT_VSCROLL_A
    add.w d7,CURRENT_VSCROLL_B

    lsr.w #3,d0 ; d0: previous camera world row in tiles
    lsr.w #3,d1 ; d1: new camera world row in tiles
    cmp.w d0,d1
    beq .AfterTileScroll
    bgt .TileScrollDown
    ; Tile Scroll Up
    ; Get TileMap offset and put it in d3. two rows up from prev pos
    move.w d0,d3 ; row ix
    and.l #$0000FFFF,d3
    sub.w #2,d3 ; HOWDY
    lsl.w #7,d3 ; multiply by 64*2 to get tile offset in bytes
    move.w #SCROLL_B_BASE_ADDR,d0
    add.w NEXT_UP_SCROLL_VRAM_OFFSET,d0 ; HOWDY
    SetVramAddr d0,d1
    move.w #(64-1),d0
    move.l #TileMap,a0
    add.l d3,a0
.UpScrollBLoop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.UpScrollBLoop
    ; Now prepare A scroll
    move.w #SCROLL_A_BASE_ADDR,d0
    add.w NEXT_UP_SCROLL_VRAM_OFFSET,d0 ; HOWDY
    SetVramAddr d0,d1
    move.w #(64-1),d0
    move.l #(TileMap+TILEMAP_WIDTH*TILEMAP_HEIGHT*2),a0
    add.l d3,a0
.UpScrollALoop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.UpScrollALoop
    ; Update next VRAM offsets, wrapping as necessary.
    sub.w #(64*2),NEXT_DOWN_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_DOWN_SCROLL_VRAM_OFFSET
    sub.w #(64*2),NEXT_UP_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_UP_SCROLL_VRAM_OFFSET
    bra .AfterTileScroll

.TileScrollDown
    ; Get TileMap offset and put it in d3. one scroll field down from prev cam top
    move.w d0,d3 ; row ix
    and.l #$0000FFFF,d3
    add.w #29,d3 ; one visible playfield plus 2 (bottom edge of scroll from current camera top)
    lsl.w #7,d3 ; multiply by 64*2 to get tile offset in bytes
    move.w #SCROLL_B_BASE_ADDR,d0
    add.w NEXT_DOWN_SCROLL_VRAM_OFFSET,d0
    SetVramAddr d0,d1
    move.w #(64-1),d0
    move.l #TileMap,a0
    add.l d3,a0
.DownScrollBLoop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.DownScrollBLoop
    move.w #SCROLL_A_BASE_ADDR,d0
    add.w NEXT_DOWN_SCROLL_VRAM_OFFSET,d0
    SetVramAddr d0,d1
    move.w #(64-1),d0
    move.l #(TileMap+TILEMAP_WIDTH*TILEMAP_HEIGHT*2),a0
    add.l d3,a0
.DownScrollALoop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.DownScrollALoop
    ; Update next VRAM offsets, wrapping as necessary.
    add.w #(64*2),NEXT_DOWN_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_DOWN_SCROLL_VRAM_OFFSET
    add.w #(64*2),NEXT_UP_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_UP_SCROLL_VRAM_OFFSET
.AfterTileScroll
    ; actually do vscroll
    move.w #0,d0
    SetVsramAddr d0,d1
    move.w CURRENT_VSCROLL_A,d0
    move.w d0,vdp_data
    move.w CURRENT_VSCROLL_B,d0
    move.w d0,vdp_data
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