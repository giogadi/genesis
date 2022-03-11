M_HeroAnimGetTileStart: macro
    move.w (\1),\2
    endm

M_HeroAnimGetFrameCount: macro
    move.w 3(\1),\2
    endm

M_HeroAnimNewState: macro
    move.l \1,HERO_CURRENT_ANIM_PTR
    move.b #-1,HERO_CURRENT_ANIM_FRAME_INDEX
    endm


HeroAnimUpdate:
    move.l HERO_CURRENT_ANIM_PTR,a0
    clr.l d0
    move.b HERO_CURRENT_ANIM_FRAME_INDEX,d0
    bge .notNewAnimState
    ; new state
    M_HeroAnimGetTileStart a0,d0
    move.w d0,HERO_CURRENT_ANIM_TILE_INDEX
    move.b #0,HERO_CURRENT_ANIM_FRAME_INDEX
    move.b #0,HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED
    rts
.notNewAnimState
    move.b 4(a0,d0),d1 ; d1 contains length of current anim frame
    blt .end ; if frame length < 0, we never change frames.
    ; check if it's time to switch frames
    move.b HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED,d0
    cmp.b d1,d0 ; time_elapsed - frame_time
    blt .stayOnFrame
    ; { switching anim frames
    move.b #0,HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED
    move.b HERO_CURRENT_ANIM_FRAME_INDEX,d0
    add.b #1,d0 ; increment frame index
    add.w #6,HERO_CURRENT_ANIM_TILE_INDEX ; increment tile index by anim frame stride
    M_HeroAnimGetFrameCount a0,d1 ; frame count in d1
    cmp.b d1,d0 ; current_index - frame_count
    blt .no_loop
    ; need to loop back to 1st frame of anim
    move.b #0,HERO_CURRENT_ANIM_FRAME_INDEX
    M_HeroAnimGetTileStart a0,d0
    move.w d0,HERO_CURRENT_ANIM_TILE_INDEX
    rts
.no_loop:
    add.b #1,HERO_CURRENT_ANIM_FRAME_INDEX
    rts
    ; } switching anim frames
.stayOnFrame:
    add.b #1,d0 ; in this case, d0 still holds frame time elapsed
    move.b d0,HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED
.end:
    rts

HeroLeftWalkAnim:
    dc.w SAMURAI_SPRITE_TILE_START ; anim's first tile index
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 2 ; anim frame count
    dc.b 20,20 ; frame counts

    align 2

HeroRightWalkAnim:
    dc.w SAMURAI_SPRITE_TILE_START+2*6 ; anim's first tile index
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 2 ; anim frame count
    dc.b 20,20 ; frame counts

    align 2

HeroWindupLeftAnim:
    dc.w SAMURAI_SPRITE_TILE_START+6*6
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 1 ; anim frame count
    dc.b -1 ; frame counts

    align 2

HeroWindupRightAnim:
    dc.w SAMURAI_SPRITE_TILE_START+7*6
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 1 ; anim frame count
    dc.b -1 ; frame counts

    align 2

HeroSlashLeftAnim:
    dc.w SAMURAI_SPRITE_TILE_START+4*6
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 1 ; anim frame count
    dc.b -1 ; frame counts

    align 2

HeroSlashRightAnim:
    dc.w SAMURAI_SPRITE_TILE_START+5*6
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 1 ; anim frame count
    dc.b -1 ; frame counts

    align 2

HeroHurtLeftAnim:
    dc.w SAMURAI_SPRITE_TILE_START+8*6
    dc.b (0|(0<<1)) ; flip_h | flip_v
    dc.b 1 ; anim frame count
    dc.b -1 ; frame counts

    align 2

HeroHurtRightAnim:
    dc.w SAMURAI_SPRITE_TILE_START+8*6
    dc.b (1|(0<<1)) ; flip_h | flip_v
    dc.b 1 ; anim frame count
    dc.b -1 ; frame counts

    align 2

