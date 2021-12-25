; y-value in SCRIPT_COND_FN_INPUT.w
ScriptCondHeroYLessThan:
    move.l CURRENT_SCRIPT_ITEM,a1
    move.w SCRIPT_COND_FN_INPUT(a1),d0 ; y-value
    sub.w CURRENT_Y,d0 ; y-value - hero_y
    ; cond is satisfied if d0 > 0
    bgt .satisfied
    ; unsatisfied
    move.b #0,d0
    rts
.satisfied
    move.b #1,d0
    rts

; entity_type in SCRIPT_ACTION_FN_INPUT.w
; spawn_x in (SCRIPT_ACTION_FN_INPUT+2).w
; spawn_y in (SCRIPT_ACTION_FN_INPUT+4).w
; last word empty
ScriptActionSpawnEntity:
    ; first, we find the first dead entity in the enemy list
    jsr UtilFindEmptyEntity
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

; entity_type in SCRIPT_ACTION_FN_INPUT.w
ScriptActionDeleteFirstEntityOfType:
    move.l #N_ENEMIES,a0 ; pointer to first enemy
    move.w #MAX_NUM_ENEMIES,d0
    move.l CURRENT_SCRIPT_ITEM,a1
.find_empty_entity_loop
    tst.w d0
    ble .after_find_entity_loop
    sub.w #1,d0
    move.w N_ENEMY_STATE(a0),d1
    ; if this enemy is dead, move onto next entity
    cmp.w #ENEMY_STATE_DEAD,d1
    beq .continue_loop
    move.w N_ENEMY_TYPE(a0),d1
    cmp.w SCRIPT_ACTION_FN_INPUT(a1),d1
    ; if this is not the requested enemy type, move onto next entity
    bne .continue_loop
    ; this is the one. kill it!!!
    move #ENEMY_STATE_DEAD,N_ENEMY_STATE(a0)
.continue_loop
    add.l #N_ENEMY_SIZE,a0
    bra .find_empty_entity_loop
.after_find_entity_loop
    rts

ScriptActionFreezeHero:
    move.w #1,HERO_FROZEN
    move.w #HERO_STATE_IDLE,HERO_STATE
    move.w #1,HERO_NEW_STATE ; do we need this?
    rts

ScriptActionUnfreezeHero:
    move.w #0,HERO_FROZEN
    rts

; camera_pan_x_per_frame is in SCRIPT_ACTION_FN_INPUT.b
; camera_pan_y_per_frame is in SCRIPT_ACTION_FN_INPUT+1.b
ScriptActionPanCamera:
    move.w #CAMERA_STATE_MANUAL_PAN,CURRENT_CAMERA_STATE
    move.l CURRENT_SCRIPT_ITEM,a1
    move.b SCRIPT_ACTION_FN_INPUT(a1),CAMERA_MANUAL_PAN_X
    move.b (SCRIPT_ACTION_FN_INPUT+1)(a1),CAMERA_MANUAL_PAN_Y
    rts