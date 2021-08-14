; sp: rts
; sp+4: ENEMY_Y
; sp+8: ENEMY_X
; SP+12: ENEMY_DATA_2
; sp+14: ENEMY_DATA_1
; sp+16: dying_frame_left
; sp+18: state
;
; DON'T TOUCH d2
DrawOgreEnemy:
    ; get the appropriate pose based on direction
    move.l #.DirectionJumpTable,a0
    clr.l d0
    move.b 13(sp),d0 ; direction
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
    ; TODO: consider making the entries into actual branch instructions.
    ; Can be 2 cycles faster apparently?
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    move.w #(OGRE_SPRITE_TILE_START+5*36),d1
    bra.s .AfterDirectionJump
.Down
    move.w #OGRE_SPRITE_TILE_START,d1
    bra.s .AfterDirectionJump
.Left
    move.w #OGRE_SPRITE_TILE_START,d1
    bra.s .AfterDirectionJump
.Right
    move.w #(OGRE_SPRITE_TILE_START+5*36),d1
    bra.s .AfterDirectionJump
.AfterDirectionJump

    move.w #$0A00,d0 ; 3x3 (to be combined with link data)
    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w 4(sp),d3 ; y
    move.w 8(sp),d4 ; x
    ;move.w #OGRE_SPRITE_TILE_START,d1
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(3*3),d1 ; next tile group start
    add.w #(3*8),d4 ; position of next tile group start (1,0)
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(3*3),d1 ; next tile group start
    sub.w #(3*8),d4 ; position of next tile group start (0,1)
    add.w #(3*8),d3
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x

    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    add.w #(3*3),d1 ; next tile group start
    add.w #(3*8),d4 ; position of next tile group start (1,1)
    move.w d3,vdp_data ; y
    move.w d0,vdp_data ; link data
    move.w d1,vdp_data ; tile (default palette)
    move.w d4,vdp_data ; x
    rts

; draw ogre dying
; .DrawDying:
;     ; only draw every other frame for a blinking effect
;     btst.l #0,d6
;     bne.s .End
;     ; gonna scale slice anim by dying frames left.
;     move.w #ENEMY_DYING_FRAMES,d7
;     sub.w d6,d7 ; number of frames since enemy started dying in d7
;     ; left slice first. offset a few pixels down-left
;     add.w #1,SPRITE_COUNTER
;     move.w #$0500,d5 ; 2x2
;     or.w SPRITE_COUNTER,d5
;     add.w d7,d3 ; y +=
;     sub.w d7,d2 ; x -=
;     move.w d3,vdp_data
;     move.w d5,vdp_data
;     move.w d5,LAST_LINK_WRITTEN
;     move.w #HOT_DOG_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
;     move.w d2,vdp_data
;     ; right slice next. offset a few pixels up-right
;     add.w #1,SPRITE_COUNTER
;     move.w #$0500,d5 ; 2x2
;     or.w SPRITE_COUNTER,d5
;     sub.w d7,d3 ; y -=
;     sub.w d7,d3 ; twice to undo change from first half
;     add.w d7,d2 ; x +=
;     add.w d7,d2
;     move.w d3,vdp_data
;     move.w d5,vdp_data
;     move.w d5,LAST_LINK_WRITTEN
;     move.w #HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
;     move.w d2,vdp_data

; a2: enemy_state
; a3: enemy_x
; a4: enemy_y
; a5: enemy_data_1
; a6: enemy_data_2
; d2: not allowed
;
; ENEMY_DATA_1: 0000 0000 0000 0000
; ENEMY_DATA_2: 0000 0000 0000 00(direction,2)
UpdateOgreEnemy:
    move.w (a3),d0 ; enemy_x
    sub.w CURRENT_X,d0 ; enemy_x - hero_x
    jsr AbsValue ; | enemy_x - hero_x |
    move.w d0,d1
    move.w (a4),d0 ; enemy_y
    sub.w CURRENT_Y,d0 ; enemy_y - hero_y
    jsr AbsValue ; | enemy_y - hero_y |
    cmp.w d0,d1 ; |dx| - |dy|
    bgt.s .FacingX
    ; facing y
    move.w (a4),d0 ; enemy_y
    sub.w CURRENT_Y,d0 ; enemy_y - hero_y
    blt.s .FacingDown
    ; facing up
    move.b #FACING_UP,1(a6)
    bra.s .End
.FacingDown
    move.b #FACING_DOWN,1(a6)
    bra.s .End
.FacingX
    move.w (a3),d0 ; enemy_x
    sub.w CURRENT_X,d0 ; enemy_x - hero_x
    blt.s .FacingRight
    ; facing left
    move.b #FACING_LEFT,1(a6)
    bra.s .End
.FacingRight
    move.b #FACING_RIGHT,1(a6)
.End
    rts