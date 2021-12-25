    ; when hero is above 438, spawn butt spawner
    dc.l ScriptCondHeroYLessThan
    dc.w 438,0
    dc.l ScriptActionSpawnEntity
    dc.w ENTITY_TYPE_SPAWNER,152,344,0
    ; when hero is above 215, despawn butt spawner
    dc.l ScriptCondHeroYLessThan
    dc.w 215,0
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
    ; end
    dc.l UtilReturnFalse,0,UtilEmptyFn,0,0