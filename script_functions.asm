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
    cmp.w CAMERA_TOP_Y,d0 ; y-value - camera_top_y
    ; cond is satisfied if > 0
    bgt .satisfied
    ; unsatisfied
    move.b #0,d0
    rts
.satisfied
    move.b #1,d0
    rts

; y-value in SCRIPT_COND_FN_INPUT.w
ScriptCondStoredEntityYGreaterThan:
    move.l CURRENT_SCRIPT_ITEM,a1
    move.w SCRIPT_COND_FN_INPUT(a1),d0 ; y-value
    move.l SCRIPT_STORED_ENTITY,a0
    move.w N_ENEMY_Y(a0),d1 ; entity y
    cmp.w d1,d0 ; y-value - entity_y
    ; cond is satisfied if (d0 - d1) < 0
    blt .satisfied
    ; unsatisfied
    move.b #0,d0
    rts
.satisfied
    move.b #1,d0
    rts

; counter is assumed to be SCRIPT_DATA.l
; target value is in SCRIPT_COND_FN_INPUT.l
ScriptCondAddCounterAndCheckValue:
    move.l SCRIPT_DATA,d0
    move.l CURRENT_SCRIPT_ITEM,a1
    move.l SCRIPT_COND_FN_INPUT(a1),d1
    cmp.l d1,d0
    bge .satisfied
    ; unsatisfied
    add.l #1,SCRIPT_DATA ; increment counter
    move.b #0,d0
    rts
.satisfied
    move.b #1,d0
    rts

; counter is assumed to be SCRIPT_DATA.l
ScriptActionResetCounter:
    clr.l SCRIPT_DATA
    rts

; entity_type in SCRIPT_ACTION_FN_INPUT.w
; spawn_x in (SCRIPT_ACTION_FN_INPUT+2).w
; spawn_y in (SCRIPT_ACTION_FN_INPUT+4).w
; last word empty
ScriptActionSpawnEntityAndStore:
    jsr ScriptActionSpawnEntity
    move.l LAST_SPAWNED_ENTITY,SCRIPT_STORED_ENTITY
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
    move.l a0,SCRIPT_STORED_ENTITY
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

ScriptActionCameraStopFollowingHero:
    move.w #CAMERA_STATE_MANUAL_PAN,CURRENT_CAMERA_STATE
    rts

; motion_dir is in SCRIPT_ACTION_FN_INPUT.b
ScriptActionMoveStoredOgre:
    move.l SCRIPT_STORED_ENTITY,a0
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

ScriptActionStopStoredOgre:
    move.l SCRIPT_STORED_ENTITY,a0
    ; clear "is moving" bit of ogre
    bclr.b #5,N_ENEMY_DATA1(a0)
    rts

; desired state is in SCRIPT_ACTION_FN_INPUT.b
ScriptActionStoredOgreSetState:
    move.l SCRIPT_STORED_ENTITY,a0
    ; ogre is in a0
    ; get desired state from action input
    move.l CURRENT_SCRIPT_ITEM,a1
    move.b SCRIPT_ACTION_FN_INPUT(a1),d0
    move.b (N_ENEMY_DATA1+1)(a0),d1
    and.b #(!OGRE_STATE_MASK),d1
    or.b d0,d1
    move.b d1,(N_ENEMY_DATA1+1)(a0)
.end
    rts

ScriptActionStoredOgreEnableAI:
    move.l SCRIPT_STORED_ENTITY,a0
    ; clear top 4 bits (all manual-control related) of ogre enemy data
    and.b #%00001111,N_ENEMY_DATA1(a0)
    rts