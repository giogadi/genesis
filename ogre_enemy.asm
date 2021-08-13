; sp: rts
; sp+4: ENEMY_Y
; sp+8: ENEMY_X
; SP+12: ENEMY_DATA_2
; sp+14: ENEMY_DATA_1
; sp+16: dying_frame_left
; sp+18: state
;
; Don't touch d2
DrawOgreEnemy:
    move.w #$0A00,d0 ; 3x3 (to be combined with link data)
    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w 4(sp),d3 ; y
    move.w 8(sp),d4 ; x
    move.w #OGRE_SPRITE_TILE_START,d1
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
    
    rts