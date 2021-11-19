CrabSpawnerVTable:
    dc.l CrabSpawnerUpdate
    dc.l UtilEmptyFn ; hurt hero
    dc.l UtilEmptyFn ; over draw
    dc.l UtilEmptyFn ; draw
    dc.l CrabSpawnerBlockHero ; block hero
    dc.l CrabSpawnerLoad ; load

; ENEMY_DATA_1: 0000 0000 0000 000(has_spawned)
; ENEMY_DATA_2: 0000 0000 0000 0000

CrabSpawnerLoad:
    rts

; a2: entity struct
; d2: not allowed
CrabSpawnerUpdate:
    tst.b (N_ENEMY_DATA1+1)(a2)
    bne .End
    ; first, we find the first dead enemy in the enemy list
    move.l #N_ENEMIES,a0 ; pointer to first enemy
    move.w #MAX_NUM_ENEMIES,d0
.find_empty_entity_loop
    dbeq d0,.after_find_entity_loop
    move.w N_ENEMY_STATE(a0),d1
    cmp.w #ENEMY_STATE_DEAD,d1
    beq .after_find_entity_loop
    ; not empty; try next entity
    add.l #N_ENEMY_SIZE,a0
    bra .find_empty_entity_loop
.after_find_entity_loop
    ; If we finished the loop without finding an empty entity, just return.
    tst.w d0
    ble .End
    ; a0 is pointing to a free entity, yay! Let's spawn our crab here.
    ; TODO: spawning a butt for now
    move.w #0,N_ENEMY_TYPE(a0)
    move.w N_ENEMY_X(a2),N_ENEMY_X(a0)
    move.w N_ENEMY_Y(a2),N_ENEMY_Y(a0)
    ; to use the entity's virtual load function, we gotta have the output struct in a2.
    ; so we push the current a2 onto the stack to make room.
    move.l a2,-(sp)
    move.l a0,a2
    jsr UtilEnemyLoadVirtual
    move.l (sp)+,a2
    ; change spawner state so we don't spawn another crab.
    move.b #1,(N_ENEMY_DATA1+1)(a2)
.End
    rts

CrabSpawnerBlockHero
    move.b #0,d0
    rts