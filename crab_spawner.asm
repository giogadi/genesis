CrabSpawnerVTable:
    dc.l CrabSpawnerUpdate
    dc.l UtilEmptyFn ; hurt hero
    dc.l UtilEmptyFn ; over draw
    dc.l UtilEmptyFn ; draw
    dc.l CrabSpawnerBlockHero ; block hero
    dc.l CrabSpawnerLoad ; load

; ENEMY_DATA_1: (frames_til_next_spawn)
; ENEMY_DATA_2: (num_frames_between_spawns)

CrabSpawnerLoad:
    move.w #2*60,(N_ENEMY_DATA1)(a2)
    move.w #2*60,(N_ENEMY_DATA2)(a2)
    rts

; a2: entity struct
; d2: not allowed
CrabSpawnerUpdate:
    tst.w (N_ENEMY_DATA1)(a2)
    ble .AfterTimerCheck
    sub.w #1,(N_ENEMY_DATA1)(a2)
    bra .End
.AfterTimerCheck
    ; first, we find the first dead enemy in the enemy list
    jsr FindEmptyEntity
    ; If we finished the loop without finding an empty entity, just return.
    tst.w d0
    ble .End
    ; a0 is pointing to a free entity, yay! Let's spawn our crab here.
    ; TODO: spawning a butt for now
    move.w #ENEMY_STATE_ALIVE,N_ENEMY_STATE(a0)
    move.w #ENTITY_TYPE_BUTT,N_ENEMY_TYPE(a0)
    move.w N_ENEMY_X(a2),N_ENEMY_X(a0)
    move.w N_ENEMY_Y(a2),N_ENEMY_Y(a0)
    ; to use the entity's virtual load function, we gotta have the output struct in a2.
    ; so we push the current a2 onto the stack to make room.
    move.l a2,-(sp)
    move.l a0,a2
    jsr UtilEnemyLoadVirtual
    move.l (sp)+,a2
    ; reset spawn timer
    move.w (N_ENEMY_DATA2)(a2),(N_ENEMY_DATA1)(a2)
.End
    rts

CrabSpawnerBlockHero
    move.b #0,d0
    rts