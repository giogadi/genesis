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
    mulu.w #40,d1 ; 40 tiles per row in this tilemap (UGH I KNOW OK)
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
    add.w #40,d0 ; (0,1)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #41,d0 ; (1,1)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #42,d0 ; (2,1)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #80,d0 ; (0,2)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #81,d0 ; (1,2)
    jsr DoesTileCollide
    tst.w d0
    bne.s .CheckCollisionsDone
    move.w d1,d0
    add.w #82,d0 ; (2,2)
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
    mulu.w #40,d1 ; 40 tiles per row in this tilemap (UGH I KNOW OK)
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

; new state is in d0. d0 gets clobbered. No return value
UpdateAnimState:
    cmp.w PREVIOUS_ANIM_STATE,d0
    beq.s .UpdateAnimStateEnd
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
.NewAnimStateJumpTable dc.l .LeftIdle,.RightIdle,.LeftWalk,.RightWalk,.LeftSlashState,.RightSlashState,.LeftWindupState,.RightWindupState
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
.UpdateAnimStateEnd
    rts

CheckSlashAndUpdate:
    ; First check if slash button has been released to unlock slashing again
    move.b CONTROLLER,d0
    btst.l #A_BIT,d0
    bne.s .AfterSlashButtonCheck
    move.w #1,BUTTON_RELEASED_SINCE_LAST_SLASH ; button's released, slashing unlocked.
.AfterSlashButtonCheck
    move.w SLASH_STATE,d3
    tst.w d3
    bne.s .AfterSlashStateNone
    ; no slash
    tst.w BUTTON_RELEASED_SINCE_LAST_SLASH
    beq .CheckSlashEarlyReturn ; did we release slash button since last slash?
    btst.l #A_BIT,d0 ; is the button pushed now?
    beq.w .CheckSlashEarlyReturn
    move.w #SLASH_STATE_WINDUP,SLASH_STATE
    move.w #SLASH_WINDUP_ITERS,SLASH_STATE_ITERS_LEFT
    move.w #0,BUTTON_RELEASED_SINCE_LAST_SLASH
    move.l #.WindupAnimJumpTable,a0
    clr.l d0
    move.w FACING_DIRECTION,d0; offset in longs into jump table
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.WindupAnimJumpTable dc.l .WindupFacingUp,.WindupFacingDown,.WindupFacingLeft,.WindupFacingRight
.WindupFacingUp
    move.w #WINDUP_RIGHT_STATE,NEW_ANIM_STATE
    bra.s .AfterSlashStateNone
.WindupFacingDown
    move.w #WINDUP_LEFT_STATE,NEW_ANIM_STATE
    bra.s .AfterSlashStateNone
.WindupFacingLeft
    move.w #WINDUP_LEFT_STATE,NEW_ANIM_STATE
    bra.s .AfterSlashStateNone
.WindupFacingRight
    move.w #WINDUP_RIGHT_STATE,NEW_ANIM_STATE
.AfterSlashStateNone
    ; we're in windup
    move SLASH_STATE,d3
    cmp.w #SLASH_STATE_WINDUP,d3
    bne.w .AfterSlashStateWindup
    sub.w #1,SLASH_STATE_ITERS_LEFT
    bgt.w .CheckSlashEarlyReturn
    move.w #1,SLASH_ON_THIS_FRAME
    move.w #SLASH_STATE_RELEASE,SLASH_STATE
    move.w #0,BUTTON_RELEASED_SINCE_LAST_SLASH
    move.w #SLASH_COOLDOWN_ITERS,SLASH_STATE_ITERS_LEFT
    ; update animation
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
.AfterSlashStateWindup
    ; we're in cooldown
    sub.w #1,SLASH_STATE_ITERS_LEFT
    bgt.s .CheckSlashEarlyReturn
    move.w #SLASH_STATE_NONE,SLASH_STATE
.CheckSlashEarlyReturn
    rts

; d0: please don't touch
; d1: enemy state
; d2: x
; d3: y
; d4: please don't touch
; d6: enemy dying frames left
DrawButtEnemy:
    cmp.w #ENEMY_STATE_DYING,d1
    beq.s .DrawButtEnemyDying
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d5 ; 2x2
    or.w SPRITE_COUNTER,d5 ; link to next sprite
    move.w d3,vdp_data
    move.w d5,vdp_data
    move.w d5,LAST_LINK_WRITTEN
    move.w #BUTT_SPRITE_TILE_START,vdp_data
    move.w d2,vdp_data
    bra.s .DrawButtEnemyEnd
.DrawButtEnemyDying:
    ; only draw every other frame for a blinking effect
    btst.l #0,d6
    bne.s .DrawButtEnemyEnd
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
    move.w #BUTT_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
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
    move.w #BUTT_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
    move.w d2,vdp_data
.DrawButtEnemyEnd:
    rts

UpdateEnemies:
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
.EnemyUpdateLoop
    move.w (a6),d5 ; alive (don't increment pointer because we may update it below)
    beq.w .EnemyUpdateLoopContinue
    cmp.w #ENEMY_STATE_ALIVE,d5
    beq.s .CheckSlashEnemy
    ; otherwise, enemy is dying (TODO use a jump table idiot)
    sub.w #1,(a3)
    bne.w .EnemyUpdateLoopContinue ; not dead yet, go to next enemy
    move.w #ENEMY_STATE_DEAD,(a6)
    bra.w .EnemyUpdateLoopContinue
.CheckSlashEnemy
    ; check slash AABB against enemy's AABB
    tst.w SLASH_ON_THIS_FRAME
    beq.s .EnemyAI
    move.w (a1),d5 ; min_enemy_x
    move.w (a2),d6 ; min_enemy_y
    cmp.w d2,d5 ; slash_max_x < min_enemy_x?
    bgt.s .EnemyAI
    cmp.w d4,d6 ; slash_max_y < min_enemy_y?
    bgt.s .EnemyAI
    add.w #2*8,d5 ; max_enemy_x (2x2 enemy)
    cmp.w d5,d1 ; max_enemy_x < slash_min_x?
    bgt.s .EnemyAI
    add.w #2*8,d6 ; max_enemy_y
    cmp.w d6,d3 ; max_enemy_y < slash_min_y?
    bgt.s .EnemyAI
    ; we have an overlap! put enemy in "dying" state and activate hitstop
    move.w #2,(a6)
    move.w #ENEMY_DYING_FRAMES,(a3)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
    bra.s .EnemyUpdateLoopContinue
.EnemyAI
    ; ENEMY_DATA_1: byte 15 is 1 if moving. lower byte is frame counter for moving state
    move.w (a4),d5
    sub.b #1,d5
    move.w d5,(a4) ; update DATA_1
    tst.b d5
    bgt.s .EnemyAIAfterStateSwap
    move.b #30,d5 ; frame countdown
    bchg.l #15,d5 ; flip moving bit
    move.w d5,(a4) ; update DATA_1
    ; if we're about to move, compute angle of motion and save it in DATA_2
    btst.l #15,d5
    beq.s .EnemyAIAfterStateSwap
    clr.l d0
    clr.l d5
    move.w CURRENT_X,d0 ; get (hero - enemy)
    sub.w (a1),d0
    move.w CURRENT_Y,d5
    sub.w (a2),d5
    jsr Atan2
    move.w d0,(a5)
.EnemyAIAfterStateSwap
    move.w (a4),d5 ; get DATA_1
    btst.l #15,d5
    beq.s .EnemyUpdateLoopContinue
    move.w (a5),d0 ; get DATA_2
    move.w d0,d5
    jsr Cos
    ext.l d0 ; output is a word, but we want to add to do a signed add to a long
    move.b #8,d6
    lsl.l d6,d0 ; divide out 256, multiply 65536 (1 pixel per frame)
    add.l d0,(a1)
    move.w d5,d0
    jsr Sin
    ext.l d0
    move.b #8,d6
    lsl.l d6,d0
    add.l d0,(a2)
.EnemyUpdateLoopContinue
    add.w #2,a6 ; move alive pointer to next entry
    add.w #4,a1
    add.w #4,a2
    add.w #2,a3
    add.w #2,a4
    add.w #2,a5
    dbra d7,.EnemyUpdateLoop
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

; d0: x, d5: y, output in d0
Atan2:
    ; 64x64 table. each axis corresponds to [-32,31].
    ; First we gotta shift each value until it's in that range.
.Atan2ShiftLoop
    cmp.w #-32,d0
    blt.s .Atan2Shift
    cmp.w #31,d0
    bgt.s .Atan2Shift
    cmp.w #-32,d5
    blt.s .Atan2Shift
    cmp.w #31,d5
    bgt.s .Atan2Shift
    bra.s .Atan2AfterShift
.Atan2Shift
    asr.w #1,d0 ; arithmetic shift maintains the sign of the input value!!
    asr.w #1,d5 ; gotta shift both to maintain the right proportion
    bra.s .Atan2ShiftLoop
.Atan2AfterShift
    ; convert into x/y indices [0,63]
    add.w #32,d0
    add.w #32,d5
    move.l #atan2LookupTable,a0
    ; index into table = 2*(64*y + x)
    lsl.l #6,d5
    add.l d0,d5
    add.l d5,d5
    add.l d5,a0
    move.w (a0),d0
    rts
