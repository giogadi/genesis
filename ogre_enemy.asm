OGRE_DESIRED_DIST: equ 48 ; pixels
OGRE_WIDTH: equ 48 ; pixels
OGRE_HEIGHT: equ 48 ; pixels
OGRE_WALK_SPEED: equ (65536/2) ; 1 pixel per frame

; a2: enemy struct start
NewDrawOgreEnemy:
    clr.l d0
    move.b (N_ENEMY_DATA2+1)(a2),d0
    M_JumpTable #.DirectionJumpTable,a0,d0
.DirectionJumpTable dc.l .Up,.Down,.Left,.Right
.Up
    btst.b #4,(FRAME_COUNTER+1)
    bne.s .DrawRightWalk2
    bra.s .DrawRightWalk
.Down
    btst.b #4,(FRAME_COUNTER+1)
    bne.s .DrawLeftWalk2
    bra.s .DrawLeftWalk
.Left
    btst.b #4,(FRAME_COUNTER+1)
    bne.s .DrawLeftWalk2
    bra.s .DrawLeftWalk
.Right
    btst.b #4,(FRAME_COUNTER+1)
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
    move.w N_ENEMY_Y(a2),d3 ; y
    sub.w N_ENEMY_HALF_H(a2),d3
    move.w N_ENEMY_X(a2),d4 ; x
    sub.w N_ENEMY_HALF_W(a2),d4
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

; a2: ogre struct
; d2: not allowed
OgreUpdateFromSlash:
    ; skip if hero not slashing
    ; TODO: consider checking this just once to skip all slash updates
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    bne.s .end
    ; skip if enemy not alive (definitely not dead here, but could be dying)
    move.w N_ENEMY_STATE(a2),d0
    cmp.w #ENEMY_STATE_ALIVE,d0
    bne.s .end
    ; TODO: handle dying state elsewhere in OgreEnemyUpdate.
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
    ; we have an overlap! put enemy in "dying" state and activate hitstop
    move.w #ENEMY_STATE_DEAD,N_ENEMY_STATE(a2)
    move.w #ENEMY_DYING_FRAMES,N_ENEMY_DYING_FRAMES_LEFT(a2)
    move.w #HITSTOP_FRAMES,HITSTOP_FRAMES_LEFT
.end
    rts

; a2: ogre struct
; d2: not allowed
OgreEnemyUpdate:
    jsr OgreUpdateFromSlash
    jsr OgreUpdateFacingDirection
    jsr OgreGetTargetPosition ; position in d0,d1
    sub.w N_ENEMY_X(a2),d0 ; target_x - ogre_x
    blt.s .MoveLeft
    ; move right
    add.l #OGRE_WALK_SPEED,N_ENEMY_X(a2)
    bra.s .Next
.MoveLeft
    sub.l #OGRE_WALK_SPEED,N_ENEMY_X(a2)
.Next
    sub.w N_ENEMY_Y(a2),d1 ; target_y - ogre_y
    blt.s .MoveUp
    ; move down
    add.l #OGRE_WALK_SPEED,N_ENEMY_Y(a2)
    bra.s .AfterWalk
.MoveUp
    sub.l #OGRE_WALK_SPEED,N_ENEMY_Y(a2)
.AfterWalk
    rts