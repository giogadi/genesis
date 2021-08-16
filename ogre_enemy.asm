OGRE_DESIRED_DIST: equ 48 ; pixels
OGRE_WIDTH: equ 48 ; pixels
OGRE_HEIGHT: equ 48 ; pixels
OGRE_WALK_SPEED: equ (65536/2) ; 1 pixel per frame
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
    move.l #.DirectionJumpTable,a0
    clr.l d0
    move.b 13(sp),d0 ; direction
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    move.w FRAME_COUNTER,d0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
    ; TODO: consider making the entries into actual branch instructions.
    ; Can be 2 cycles faster apparently?
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    btst.l #4,d0
    bne.s .DrawRightWalk2
    bra.s .DrawRightWalk
.Down
    btst.l #4,d0
    bne.s .DrawLeftWalk2
    bra.s .DrawLeftWalk
.Left
    btst.l #4,d0
    bne.s .DrawLeftWalk2
    bra.s .DrawLeftWalk
.Right
    btst.l #4,d0
    bne.s .DrawRightWalk2
    bra.s .DrawRightWalk
.DrawLeftWalk
    move.w #OGRE_SPRITE_TILE_START,d1
    bra.s .AfterDirectionJump
.DrawLeftWalk2
    move.w #(OGRE_SPRITE_TILE_START+36),d1
    bra.s .AfterDirectionJump
.DrawRightWalk
    move.w #(OGRE_SPRITE_TILE_START+5*36),d1
    bra.s .AfterDirectionJump
.DrawRightWalk2
    move.w #(OGRE_SPRITE_TILE_START+6*36),d1
    bra.s .AfterDirectionJump
.AfterDirectionJump

    move.w #$0A00,d0 ; 3x3 (to be combined with link data)
    add.w #1,SPRITE_COUNTER
    move.b (SPRITE_COUNTER+1),d0 ; link to next sprite
    move.w d0,LAST_LINK_WRITTEN
    move.w 4(sp),d3 ; y
    move.w 8(sp),d4 ; x
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

; a2: enemy_state
; a3: enemy_x
; a4: enemy_y
; a5: enemy_data_1
; a6: enemy_data_2
; d2: not allowed
UpdateFacingDirection:
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
    rts
.FacingDown
    move.b #FACING_DOWN,1(a6)
    rts
.FacingX
    move.w (a3),d0 ; enemy_x
    sub.w CURRENT_X,d0 ; enemy_x - hero_x
    blt.s .FacingRight
    ; facing left
    move.b #FACING_LEFT,1(a6)
    rts
.FacingRight
    move.b #FACING_RIGHT,1(a6)
    rts

; put target position in d0,d1
GetTargetPosition:
    ; ogre above hero: y > x && y > -x
    ; ogre below hero: y < x && y < -x
    ; ogre left of hero: y > x && y < -x
    ; ogre right of hero: y < x && y > -x
    ; keep things simple; using sprite centerpoints for positions. but what can go wrong?
    move.w (a3),d0 ; enemy_min_x
    add.w #(OGRE_WIDTH/2),d0 ; enemy_center_x
    sub.w CURRENT_X,d0 ; enemy_center_x - hero_min_x
    sub.w #(HERO_WIDTH/2),d0 ; enemy_center_x - hero_min_x
    
    move.w (a4),d1 ; enemy_min_y
    add.w #(OGRE_WIDTH/2),d1 ; enemy_center_y
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
    add.w #((HERO_WIDTH/2)-(OGRE_WIDTH/2)),d0
    move.w CURRENT_Y,d1
    sub.w #(OGRE_DESIRED_DIST+OGRE_HEIGHT),d1
    rts
.BelowHero
    move.w CURRENT_X,d0
    add.w #((HERO_WIDTH/2)-(OGRE_WIDTH/2)),d0
    move.w CURRENT_Y,d1
    add.w #(OGRE_DESIRED_DIST+HERO_HEIGHT),d1
    rts
.LeftOfHero
    move.w CURRENT_X,d0
    sub.w #(OGRE_DESIRED_DIST+OGRE_WIDTH),d0
    move.w CURRENT_Y,d1
    add.w #((HERO_HEIGHT/2)-(OGRE_HEIGHT/2)),d1
    rts
.RightOfHero
    move.w CURRENT_X,d0
    add.w #(OGRE_DESIRED_DIST+HERO_WIDTH),d0
    move.w CURRENT_Y,d1
    add.w #((HERO_HEIGHT/2)-(OGRE_HEIGHT/2)),d1
    rts

; a2: enemy_state
; a3: enemy_x
; a4: enemy_y
; a5: enemy_data_1
; a6: enemy_data_2
; d2: not allowed
;
; ENEMY_DATA_1: 0000 0000 0000 0000
; ENEMY_DATA_2: 0000 0000 0000 00(direction,2)
; TODO: pass the ogre size in so maybe we can generalize this to any enemy
UpdateOgreEnemy:
    jsr UpdateFacingDirection
    jsr GetTargetPosition
    sub.w (a3),d0 ; target_x - ogre_x
    blt.s .MoveLeft
    ; move right
    add.l #OGRE_WALK_SPEED,(a3)
    bra.s .Next
.MoveLeft
    sub.l #OGRE_WALK_SPEED,(a3)
.Next
    sub.w (a4),d1 ; target_y - ogre_y
    blt.s .MoveUp
    ; move down
    add.l #OGRE_WALK_SPEED,(a4)
    bra.s .AfterWalk
.MoveUp
    sub.l #OGRE_WALK_SPEED,(a4)
.AfterWalk
    rts