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

; y-value in SCRIPT_COND_FN_INPUT.w
ScriptCondCameraTopYLessThan:
    move.l CURRENT_SCRIPT_ITEM,a1
    move.w SCRIPT_COND_FN_INPUT(a1),d0 ; y-value
    sub.w CAMERA_TOP_Y,d0 ; y-value - camera_top_y
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
    move.l CURRENT_SCRIPT_ITEM,a1
    move.w SCRIPT_ACTION_FN_INPUT(a1),d0
    jsr UtilFindLiveEntityOfType
    tst.b d0
    ble .end ; quit if no such entity found
    ; our entity is in a0.
    move #ENEMY_STATE_DEAD,N_ENEMY_STATE(a0)
.end
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

ScriptActionCameraFollowHero:
    move.w #CAMERA_STATE_FOLLOW_HERO,CURRENT_CAMERA_STATE
    rts

; motion_dir is in SCRIPT_ACTION_FN_INPUT.b
ScriptActionMoveOgre:
    ; first find our ogre enemy.
    move.w #ENTITY_TYPE_OGRE,d0
    jsr UtilFindLiveEntityOfType
    tst.b d0
    ble .end ; if no ogre found, just quit
    ; our ogre enemy is in a0
    move.l CURRENT_SCRIPT_ITEM,a1
    move.b SCRIPT_ACTION_FN_INPUT(a1),d0
    ; move direction into bottom 2 bits of enemy_data2 so that ogre faces in direction of motion.
    move.b (N_ENEMY_DATA2+1)(a0),d1
    and.b #%11111100,d1
    or.b d0,d1
    move.b d1,(N_ENEMY_DATA2+1)(a0)
    ; now, move direction into top 2 bits of d0.b
    ror.b #2,d0
    ; set "is moving" bit and "is manual" bit
    or.b #%00110000,d0
    ; set the appropriate ogre data
    move.b N_ENEMY_DATA1(a0),d1
    and.b #%00001111,d1 ; only want to set the manual-motion-relevant bits
    or.b d0,d1
    move.b d1,N_ENEMY_DATA1(a0)
.end
    rts