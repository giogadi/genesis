; entity_type in SCRIPT_ACTION_FN_INPUT.w
; spawn_x in (SCRIPT_ACTION_FN_INPUT+2).w
; spawn_y in (SCRIPT_ACTION_FN_INPUT+4).w
; last word empty
ScriptSpawnEntity:
    ; first, we find the first dead entity in the enemy list
    jsr FindEmptyEntity
    tst.w d0
    ble .end ; if no empty entity found, just return.
    ; our empty entity is in a0
    move.w #ENEMY_STATE_ALIVE,N_ENEMY_STATE(a0)
    move.l CURRENT_SCRIPT_ITEM,a1
    move.w SCRIPT_ACTION_FN_INPUT(a1),N_ENEMY_TYPE(a0)
    move.w (SCRIPT_ACTION_FN_INPUT+2)(a1),N_ENEMY_X(a0)
    move.w (SCRIPT_ACTION_FN_INPUT+4)(a1),N_ENEMY_Y(a0)
    ; to use the entity's virtual load function, we gotta have the output struct in a2.
    ; so we push the current a2 onto the stack to make room.
    move.l a2,-(sp)
    move.l a0,a2
    jsr UtilEnemyLoadVirtual
    move.l (sp)+,a2
.end
    rts