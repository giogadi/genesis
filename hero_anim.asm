M_HeroAnimGetFirstAnimFrame: macro
    move.l \1,\2
    add.l #2,\2
    endm

M_HeroAnimGetAnimLength: macro
    move.b 1(\1),\2
    endm

M_HeroAnimGetAnimFlip: macro
    move.b (\1),\2
    endm

; In these, \1 is an address register for the current anim frame.
M_HeroAnimGetAnimFrameLength: macro
    move.w (\1),\2
    endm
M_HeroAnimGetAnimFrameTileIndex: macro
    move.w 2(\1),\2
    add.w #SAMURAI_SPRITE_TILE_START,\2
    endm

HeroAnimFrameSize: equ 4

M_HeroAnimNewState: macro
    move.l \1,HERO_CURRENT_ANIM_PTR
    move.b #-1,HERO_CURRENT_ANIM_FRAME_INDEX
    endm

HeroAnimUpdate:
    move.l HERO_NEW_ANIM_PTR,a0
    clr.l d0
    cmp.l HERO_CURRENT_ANIM_PTR,a0
    beq .notNewAnimState
    move.l a0,HERO_CURRENT_ANIM_PTR
    M_HeroAnimGetFirstAnimFrame a0,a1
    move.l a1,HERO_CURRENT_ANIM_FRAME_PTR
    M_HeroAnimGetAnimFrameTileIndex a1,HERO_CURRENT_ANIM_TILE_INDEX
    move.b #0,HERO_CURRENT_ANIM_FRAME_INDEX
    move.b #0,HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED
    rts
.notNewAnimState
    move.l HERO_CURRENT_ANIM_FRAME_PTR,a1
    M_HeroAnimGetAnimFrameLength a1,d1
    blt .end ; if frame length < 0, we never change frames.
    ; check if it's time to switch frames
    move.b HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED,d0
    cmp.b d1,d0 ; time_elapsed - frame_time
    blt .stayOnFrame
    ; { switching anim frames
    move.b #0,HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED
    move.b HERO_CURRENT_ANIM_FRAME_INDEX,d0
    add.b #1,d0 ; increment frame index
    M_HeroAnimGetAnimLength a0,d1
    cmp.b d1,d0 ; current_index - frame_length
    blt .no_loop
    ; need to loop back to 1st frame of anim
    M_HeroAnimGetFirstAnimFrame a0,a1
    move.b #0,HERO_CURRENT_ANIM_FRAME_INDEX
    bra .afterFrameChange
.no_loop:
    add.b #1,HERO_CURRENT_ANIM_FRAME_INDEX
    add.l #HeroAnimFrameSize,a1
    
.afterFrameChange:
    move.l a1,HERO_CURRENT_ANIM_FRAME_PTR
    M_HeroAnimGetAnimFrameTileIndex a1,HERO_CURRENT_ANIM_TILE_INDEX
    rts
    ; } switching anim frame
.stayOnFrame:
    add.b #1,d0 ; in this case, d0 still holds frame time elapsed
    move.b d0,HERO_CURRENT_ANIM_FRAME_TIME_ELAPSED
.end:
    rts

    align 2

HeroLeftIdleAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,0 ; frame_count0,tile_index0

    align 2

HeroRightIdleAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,2*6

    align 2

HeroLeftWalkAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 2 ; anim frame count
    dc.w 20,1*6
    dc.w 20,0*6

    align 2

HeroRightWalkAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 2 ; anim frame count
    dc.w 20,3*6
    dc.w 20,2*6

    align 2

HeroLeftWindupAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,6*6    

    align 2

HeroRightWindupAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,7*6    

    align 2

HeroLeftSlashAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,4*6

    align 2

HeroRightSlashAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,5*6

    align 2

HeroLeftHurtAnim:
    dc.b ((0<<1)|0)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,8*6

    align 2

HeroRightHurtAnim:
    dc.b ((0<<1)|1)<<3 ; flip_v | flip_h
    dc.b 1 ; anim frame count
    dc.w -1,8*6

    align 2

