    ; when hero is above 438, spawn butt spawner
    dc.l ScriptCondHeroYLessThan
    dc.w 438,0
    dc.l ScriptActionSpawnEntity
    dc.w ENTITY_TYPE_SPAWNER,152,344,0
    ; when hero is above here, despawn butt spawner
    dc.l ScriptCondHeroYLessThan
    dc.w 330,0
    dc.l ScriptActionDeleteFirstEntityOfType
    dc.w ENTITY_TYPE_SPAWNER,0,0,0
    ;; when hero is above 202, start ogre enter cinematic.
    ; freeze hero.
    dc.l ScriptCondHeroYLessThan
    dc.w 202,0
    dc.l ScriptActionFreezeHero
    dc.l 0,0
    ; pan camera upward
    dc.l UtilReturnTrue
    dc.l 0
    dc.l ScriptActionPanCamera
    dc.b 0,-1
    dc.w 0,0,0
    ; freeze camera when camera reaches top
    dc.l ScriptCondCameraTopYLessThan
    dc.w 2*8+1,0
    dc.l ScriptActionPanCamera
    dc.b 0,0
    dc.w 0,0,0
    ; spawn ogre
    dc.l UtilReturnTrue
    dc.l 0
    dc.l ScriptActionSpawnEntity
    dc.w ENTITY_TYPE_OGRE,160,-40,0
    ; move ogre down
    dc.l UtilReturnTrue
    dc.l 0
    dc.l ScriptActionMoveOgre
    dc.b FACING_DOWN,0
    dc.w 0,0,0
    ; unfreeze hero
    dc.l UtilReturnTrue
    dc.l 0
    dc.l ScriptActionUnfreezeHero
    dc.l 0,0
    ; end
    dc.l UtilReturnFalse,0,UtilEmptyFn,0,0