HOT_DOG_MOVING: equ 0
HOT_DOG_SLASHING: equ 1
HOT_DOG_RECOVERY: equ 2

UpdateHotDogEnemy:
    rts

; d0: please don't touch
; d1: enemy state
; d2: x
; d3: y
; d6: enemy dying frames left
DrawHotDogEnemy:
    cmp.w #ENEMY_STATE_DYING,d1
    beq.s .DrawDying
    add.w #1,SPRITE_COUNTER
    move.w #$0500,d5 ; 2x2
    or.w SPRITE_COUNTER,d5 ; link to next sprite
    move.w d3,vdp_data
    move.w d5,vdp_data
    move.w d5,LAST_LINK_WRITTEN
    ; add global_palette
    move.w GLOBAL_PALETTE,d5
    ror.w #3,d5
    or.w #HOT_DOG_SPRITE_TILE_START,d5
    move.w d5,vdp_data
    move.w d2,vdp_data
    bra.s .End
.DrawDying:
    ; only draw every other frame for a blinking effect
    btst.l #0,d6
    bne.s .End
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
    move.w #HOT_DOG_SLASHED_LEFT_SPRITE_TILE_START,vdp_data
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
    move.w #HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START,vdp_data
    move.w d2,vdp_data
.End:
    rts