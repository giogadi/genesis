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

UtilEmptyFn:
    rts

; return false (byte) in d0
UtilReturnFalse:
    move.b #0,d0
    rts

; return true (byte) in d0
UtilReturnTrue:
    move.b #1,d0
    rts

ENEMY_UPDATE_FN_IX: equ 0
ENEMY_HURT_FN_IX: equ 1
ENEMY_OVER_DRAW_FN_IX: equ 2
ENEMY_DRAW_FN_IX: equ 3
ENEMY_BLOCK_HERO_FN_IX: equ 4
ENEMY_LOAD_FN_IX: equ 5

; \1 is vtable function index
; Update,Hurt,OverDraw,DrawBlock,Load
; a2 is enemy struct
; a0,a1,d1 get CLOBBERED
; CURRENTLY LIMITED TO 64 VIRTUAL FUNCTIONS lmao
M_UtilEnemyVTable: macro
    move.l \1,a0
    add.l a0,a0 ; multiply by 4 to convert function index into vtable address offset (longs to bytes)
    add.l a0,a0
    clr.l d1
    move.w N_ENEMY_TYPE(a2),d1
    M_JumpTable #.EnemyJumpTable,a1,d1
.EnemyJumpTable: dc.l .Butt,.HotDog,.Ogre,.RedSeal,.CrabSpawner,.FireballVTable
.Butt
    add.l #ButtVTable,a0
    bra .AfterJump
.HotDog
    add.l #HotDogVTable,a0
    bra .AfterJump
.Ogre
    add.l #OgreVTable,a0
    bra .AfterJump
.RedSeal
    add.l #RedSealVTable,a0
    bra .AfterJump
.CrabSpawner
    add.l #CrabSpawnerVTable,a0
    bra .AfterJump
.FireballVTable
    add.l #FireballVTable,a0
    bra .AfterJump
.AfterJump
    move.l (a0),a0
    jsr (a0)
endm

UtilEnemyUpdateVirtual:
    M_UtilEnemyVTable #ENEMY_UPDATE_FN_IX
    rts
UtilEnemyHurtVirtual:
    M_UtilEnemyVTable #ENEMY_HURT_FN_IX
    rts
UtilEnemyOverDrawVirtual:
    M_UtilEnemyVTable #ENEMY_OVER_DRAW_FN_IX
    rts
UtilEnemyDrawVirtual:
    M_UtilEnemyVTable #ENEMY_DRAW_FN_IX
    rts

; new x,y in NEW_X,NEW_Y
; enemy struct in a2
; DO NOT TOUCH d2
; return 1 in d0 if hero can't occupy new position, 0 if hero can
UtilEnemyBlockHeroVirtual:
    M_UtilEnemyVTable #ENEMY_BLOCK_HERO_FN_IX
    rts

; output enemy struct in a2
; DOES NOT TOUCH d2
; clobbers a0,a1,d1
UtilEnemyLoadVirtual:
    M_UtilEnemyVTable #ENEMY_LOAD_FN_IX
    rts

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
    lsl.w #TILEMAP_WIDTH_LOG2,d1 ; 64 * y
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

; tile idx in d0. collision result in d0
; checks both layers of tiles.
UtilDoesTileCollide:
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
    ; if we found a "full collision" (2) return early.
    cmp.w #2,d0
    beq .end
    ; Now store the first layer's collision result in d2 and
    ; look for a collision in the other layer
    move.w d0,-(sp)
    clr.l d0
    move.w 2(sp),d0 ; move tile ix back into d0
    move.l #(TileMap+TILEMAP_SIZE*2),a0
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
    ; compare this layer's collision result to the other layer's
    move.w (sp)+,d1
    cmp.w d0,d1
    ble .end
    ; other layer had a higher collision value. use that one.
    move.w d1,d0
.end
    add.l #2,sp
    rts

; x in d0, y in d1. outputs result in d0. 
; 0 if collision-free, 1 if collision
; Assume that x and y can be longs.
UtilCheckCollisions:
    ; get the tile that CURRENT_X,CURRENT_Y corresponds to.
    ; usually done by dividing CURRENT_X by TILE_WIDTH; but we know that TILE_WIDTH is 8px. ezpz.
    lsr.l #3,d0 ; divide by 8 (tile width)
    lsr.l #3,d1
    ; Now d0,d1 is our tile coordinate. But we need to turn that into a single index.
    lsl.l #TILEMAP_WIDTH_LOG2,d1 ; TILEMAP_WIDTH tiles per row, so multiply by TILEMAP_WIDTH by left-shifting
    add.l d1,d0
    move.l d0,d1
    ; d0 and d1 now both hold our tile index. We gotta check this tile and the neighboring tiles that the hero
    ; is also touching. Because the hero position is on the top-left corner of the sprite, we only
    ; need to check right and down. So we should *always* check 6 cells in the 2x3 area of the sprite.
    ; we'll also check the next column/row over for offset within the top-left cell, so that makes it
    ; 3x4.
    move.w #(HERO_WIDTH_IN_TILES+1-1),d2
    move.w #(HERO_HEIGHT_IN_TILES+1-1),d3
    ; the min value that will impede hero position update is in d4
    ; push d0 onto stack because we need it to check if hero is dashing.
    move.l d0,-(sp)
    jsr HeroStateIsDashActive
    move.b d0,d4
    move.l (sp)+,d0
    tst.b d4
    bne .DashingCollisionNumber
    ; also use dashing collision number if hero is recoiling from damage
    move.w #HERO_STATE_HURT,d4
    cmp.w HERO_STATE,d4
    beq .DashingCollisionNumber
    ; not dashing
    move.w #1,d4
    bra .AfterDashingCollisionNumber
.DashingCollisionNumber
    move.w #2,d4
.AfterDashingCollisionNumber
.row_loop
.column_loop
    ; store d1 on stack since it'll get clobbered in the next function
    move.l d1,-(sp)
    jsr UtilDoesTileCollide
    move.l (sp)+,d1
    cmp.w d4,d0
    bge .CheckCollisionsDone
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
    ; Now d0,d1 is our tile coordinate. But we need to turn that into a single index.
    lsl.w #TILEMAP_WIDTH_LOG2,d1 ; TILEMAP_WIDTH tiles per row, so mult by left shifting
    add.w d1,d0
    ; Now d0 is our tile index. Check the tilemap+collision-table if this tile collides.
    jsr UtilDoesTileCollide
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

; a2: enemy struct
; d2: do not touch
; d0.b: return value
UtilIsEnemyHitBySlash:
    ; skip if hero not slashing
    ; TODO: consider checking this just once to skip all slash updates
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    ;bne .end
    beq .AfterStateCheck
    cmp.w #HERO_STATE_DASHING,d0
    bne .end
.AfterStateCheck
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
    ; we have an overlap! return 1
    moveq #1,d0
    rts
.end
    clr.b d0
    rts

UtilUpdateEnemies:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    jsr UtilEnemyUpdateVirtual
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
.end_loop
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

UtilUpdateDashDirectionFromControllerInD0
    clr.b HERO_DASH_DIRECTION_X
    clr.b HERO_DASH_DIRECTION_Y
    ; now look for a direction and update FACING_DIRECTION if we find one
    ; up
    btst.l #UP_BIT,d0
    beq.s .AfterUp
    sub.b #1,HERO_DASH_DIRECTION_Y
.AfterUp
    ; down
    btst.l #DOWN_BIT,d0
    beq.s .AfterDown
    add.b #1,HERO_DASH_DIRECTION_Y
.AfterDown
    ; left
    btst.l #LEFT_BIT,d0
    beq.s .AfterLeft
    sub.b #1,HERO_DASH_DIRECTION_X
.AfterLeft
    ; right
    btst.l #RIGHT_BIT,d0
    beq.s .AfterRight
    add.b #1,HERO_DASH_DIRECTION_X
.AfterRight
    rts

; Should be called during freeze only
CheckForDashBuffer:
    tst.b (DASH_BUFFERED+1) ; if dash is already buffered, exit
    bne .End
    ; if slash is active, this is an attack hitstop. can dash buffer.
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    beq .CanDashBuffer
    ; If dash is active, this is a dash attack hitstop. can dash buffer.
    cmp.w #HERO_STATE_DASHING,d0
    bne .End
.CanDashBuffer
    GetControls d0,d1
    move.b CONTROLLER,d0
    btst.l #C_BIT,d0
    beq.s .End
    move.b #1,(DASH_BUFFERED+1)
    jsr UtilUpdateDashDirectionFromControllerInD0
.End
    rts

UtilLoadEnemies:
    ; data input pointer is at a0. We're gonna clobber it below, so we put it in a3, which
    ; is safe. To ensure a3 is safe for others, we push and pop the previous value of a3.
    move.l a3,-(sp)
    move.l a0,a3
    move (a3)+,d2 ; enemy count is in d2
    sub.w #1,d2
    blt.w .after_loop
    move.l #N_ENEMIES,a2
.loop
    move.w #ENEMY_STATE_ALIVE,N_ENEMY_STATE(a2)
    clr.l d3
    move.w (a3)+,d3 ; enemy_type is in d3. Storing to use it later
    move.w d3,N_ENEMY_TYPE(a2)
    move.w (a3)+,d4 ; enemy_x
    move.w d4,N_ENEMY_X(a2)
    move.w (a3)+,d4 ; enemy_y
    move.w d4,N_ENEMY_Y(a2)
    jsr UtilEnemyLoadVirtual
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
.after_loop
    move.l (sp)+,a3
    rts

UtilDrawEnemies:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
    clr.l d0
.loop
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    jsr UtilEnemyDrawVirtual
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop
.end_loop
    rts

UtilDrawEnemySlashes:
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    clr.l d0
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    jsr UtilEnemyOverDrawVirtual
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
    clr.l d0
    move.b (CURRENT_CAMERA_STATE+1),d0
    M_JumpTable #.CameraStateJumpTable,a0,d0
.CameraStateJumpTable: dc.l .Follow,.Manual
.Follow:
    ; Constantly trying to position camera to center on hero.
    move.w CAMERA_TOP_Y,d0
    add.w #(VISIBLE_TILE_H*8/2),d0 ; camera center
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1 ; hero center
    sub.w d0,d1 ; d1 = hero - camera
    beq .FollowEnd
    blt .FollowLess
    move.w #1,d1
    bra .FollowEnd
.FollowLess
    move.w #-1,d1
.FollowEnd
    move.w #0,4(sp)
    move.w d1,6(sp)
    rts
.Manual:
    clr.w d0
    move.b CAMERA_MANUAL_PAN_X,d0
    ext.w d0
    move.w d0,4(sp)
    move.b CAMERA_MANUAL_PAN_Y,d0
    ext.w d0
    move.w d0,6(sp)
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
    lsl.w #(TILEMAP_WIDTH_LOG2+1),d3 ; multiply by TILEMAP_WIDTH*2 to get tile offset in bytes
    move.w #SCROLL_B_BASE_ADDR,d0
    add.w NEXT_UP_SCROLL_VRAM_OFFSET,d0 ; HOWDY
    SetVramAddr d0,d1
    move.w #(SCROLL_TILE_W-1),d0
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
    move.w #(SCROLL_TILE_W-1),d0
    move.l #(TileMap+TILEMAP_SIZE*2),a0
    add.l d3,a0
.UpScrollALoop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.UpScrollALoop
    ; Update next VRAM offsets, wrapping as necessary.
    sub.w #(SCROLL_TILE_W*2),NEXT_DOWN_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_DOWN_SCROLL_VRAM_OFFSET
    sub.w #(SCROLL_TILE_W*2),NEXT_UP_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_UP_SCROLL_VRAM_OFFSET
    bra .AfterTileScroll

.TileScrollDown
    ; Get TileMap offset and put it in d3. one scroll field down from prev cam top
    move.w d0,d3 ; row ix
    and.l #$0000FFFF,d3
    add.w #29,d3 ; one visible playfield plus 2 (bottom edge of scroll from current camera top)
    lsl.w #(TILEMAP_WIDTH_LOG2+1),d3 ; multiply by TILEMAP_WIDTH*2 to get tile offset in bytes
    move.w #SCROLL_B_BASE_ADDR,d0
    add.w NEXT_DOWN_SCROLL_VRAM_OFFSET,d0
    SetVramAddr d0,d1
    move.w #(SCROLL_TILE_W-1),d0
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
    move.w #(SCROLL_TILE_W-1),d0
    move.l #(TileMap+TILEMAP_SIZE*2),a0
    add.l d3,a0
.DownScrollALoop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.DownScrollALoop
    ; Update next VRAM offsets, wrapping as necessary.
    add.w #(SCROLL_TILE_W*2),NEXT_DOWN_SCROLL_VRAM_OFFSET
    and.w #$0FFF,NEXT_DOWN_SCROLL_VRAM_OFFSET
    add.w #(SCROLL_TILE_W*2),NEXT_UP_SCROLL_VRAM_OFFSET
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

; sp + 4: aabb_center_x
; sp + 6: aabb_half_w
; sp + 8; aabb_center_y
; sp + 10; aabb_half_h
; sp + 12; hero_min_x
; sp + 14; hero_min_y
;
; d0.b: returns -1 if no overlap, otherwise direction of minimum overlap
; doesn't touch d2
UtilMinAABBOverlapHero:
    move.w 12(sp),d0 ; hero_min_x
    move.w 4(sp),d1 ; aabb_center_x
    move.w d1,d3
    add.w 6(sp),d3 ; aabb_max_x
    move.w d0,d4
    sub.w d3,d4 ; hero_min_x - aabb_max_x
    bgt.s .no_overlap
    ; d4 will hold the least overlap amount, d5 holds direction
    move.b #FACING_RIGHT,d5
    add.w #HERO_WIDTH,d0 ; hero_max_x
    sub.w 6(sp),d1 ; aabb_min_x
    sub.w d0,d1 ; aabb_min_x - hero_max_x
    bgt.s .no_overlap
    cmp.w d4,d1
    ble.s .NotLeastOverlap1
    move.w d1,d4
    move.b #FACING_LEFT,d5
.NotLeastOverlap1
    move.w 14(sp),d0 ; hero_min_y
    move.w 8(sp),d1 ; aabb_center_y
    move.w d1,d3
    add.w 10(sp),d3 ; aabb_max_y
    move.w d0,d6
    sub.w d3,d6 ; hero_min_y - aabb_max_y
    bgt.s .no_overlap
    cmp.w d4,d6
    ble.s .NotLeastOverlap2
    move.w d6,d4
    move.b #FACING_DOWN,d5
.NotLeastOverlap2
    add.w #HERO_HEIGHT,d0 ; hero_max_y
    sub.w 10(sp),d1 ; aabb_min_y
    sub.w d0,d1 ; aabb_min_y - hero_max_y
    bgt.s .no_overlap
    cmp.w d4,d1
    ble.s .NotLeastOverlap3
    move.w d1,d4
    move.b #FACING_UP,d5
.NotLeastOverlap3
    ; we have an overlap!
    move.b d5,d0
    rts
.no_overlap
    move.b #-1,d0
    rts

; sp + 4: x
; sp + 6: y
; return value in d0.b
UtilPointInCameraView:
    move.w 4(sp),d0 ; x
    move.w CAMERA_LEFT_X,d1
    ; x < camera_left_x : return false
    cmp.w d0,d1
    bgt .PointNotInside
    add.w #(VISIBLE_TILE_W*8),d1 ; camera_right_x
    ; camera_right_x <= x: return false
    cmp.w d1,d0
    bge .PointNotInside
    move.w 6(sp),d0 ; y
    move.w CAMERA_TOP_Y,d1
    ; if y < camera_top_y : return false
    cmp.w d0,d1
    bgt .PointNotInside
    add.w #(VISIBLE_TILE_H*8),d1 ; camera_bottom_y
    ; camera_bottom_y <= y: return false
    cmp.w d1,d0
    bgt .PointNotInside
    ; point is inside!
    move.b #1,d0
    rts
.PointNotInside
    move.b #0,d0
    rts

; if d0.b > 0, a0 points to an empty entity.
; if d0.b <= 0, no empty entity was found.
UtilFindEmptyEntity:
    move.l #N_ENEMIES,a0 ; pointer to first enemy
    move.w #MAX_NUM_ENEMIES,d0
.find_empty_entity_loop
    tst.w d0
    ble .after_find_entity_loop
    sub.w #1,d0
    move.w N_ENEMY_STATE(a0),d1
    cmp.w #ENEMY_STATE_DEAD,d1
    beq .after_find_entity_loop
    ; not empty; try next entity
    add.l #N_ENEMY_SIZE,a0
    bra .find_empty_entity_loop
.after_find_entity_loop
    ; at this point, d0 > 0 if a0 has an empty entity, <= 0 if none found.
    rts

; input: entity type in d0
; output:
; if d0.b > 0, a0 points to the entity
; else, no entity was found.
UtilFindLiveEntityOfType:
    move.l #N_ENEMIES,a0 ; pointer to first enemy
    move.l d2,-(sp) ; push d2 onto the stack, because we gonna use it.
    move.w d0,d2 ; copy entity type into d2
    move.w #MAX_NUM_ENEMIES,d0
.find_entity_loop
    tst.w d0
    ble .after_find_entity_loop
    sub.w #1,d0
    move.w N_ENEMY_STATE(a0),d1
    cmp.w #ENEMY_STATE_DEAD,d1
    ; if enemy is dead, continue to next enemy
    beq .continue_loop
    move.w N_ENEMY_TYPE(a0),d1
    cmp.w d1,d2 ; is this enemy the right type? If so, exit loop.
    beq .after_find_entity_loop
.continue_loop
    add.l #N_ENEMY_SIZE,a0
    bra .find_entity_loop
.after_find_entity_loop
    ; at this point, d0 > 0 if a0 has an empty entity, <= 0 if none found.
    move.l (sp)+,d2 ; restore previous value of d2.
    rts

; return random number in d0.w using xorshift16
UtilRand16:
    move.w d2,-(sp)
    move.w RNG_SEED,d0
    move.w d0,d1
    lsl.w #7,d1
    eor.w d1,d0 ; d0: x ^= x << 7
    move.w d0,d1 ; d1 = d0
    move.b #9,d2
    lsr.w d2,d1 ; x >> 9
    eor.w d1,d0 ; d0: x ^= x >> 9
    move.w d0,d1
    lsl.w #8,d1 ; x << 8
    eor.w d1,d0 ; x ^= x << 8
    move.w (sp)+,d2
    move.w d0,RNG_SEED
    rts

; a2: enemy struct
; d0: desired enemy dist
; return target position in d0,d1
UtilGetEnemy4WayTargetPos:
    ; push enemy dist onto stack
    move.w d0,-(sp)

    ; enemy above hero: y > x && y > -x
    ; enemy below hero: y < x && y < -x
    ; enemy left of hero: y > x && y < -x
    ; eney right of hero: y < x && y > -x
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
    ; sub out desired dist
    sub.w 0(sp),d1
    sub.w N_ENEMY_HALF_H(a2),d1
    bra .End
.BelowHero
    move.w CURRENT_X,d0
    add.w #(HERO_WIDTH/2),d0
    move.w CURRENT_Y,d1
    ; add desired dist + hero height
    add.w 0(sp),d1
    add.w #HERO_HEIGHT,d1
    ;add.w #(OGRE_DESIRED_DIST+HERO_HEIGHT),d1
    add.w N_ENEMY_HALF_H(a2),d1
    bra .End
.LeftOfHero
    move.w CURRENT_X,d0
    sub.w 0(sp),d0
    ;sub.w #OGRE_DESIRED_DIST,d0
    sub.w N_ENEMY_HALF_W(a2),d0
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1
    bra .End
.RightOfHero
    move.w CURRENT_X,d0
    add.w 0(sp),d0
    add.w #HERO_WIDTH,d0
    ;add.w #(OGRE_DESIRED_DIST+HERO_WIDTH),d0
    add.w N_ENEMY_HALF_W(a2),d0
    move.w CURRENT_Y,d1
    add.w #(HERO_HEIGHT/2),d1
.End
    ; reset stack
    add.l #2,sp
    rts