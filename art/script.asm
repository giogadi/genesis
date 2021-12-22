    ; when hero is above 438, spawn butt spawner
    dc.l ScriptCondHeroYLessThan
    dc.w 438,0
    dc.l ScriptActionSpawnEntity
    dc.w ENTITY_TYPE_SPAWNER,152,344,0
    ; end
    dc.l UtilReturnFalse,0,UtilEmptyFn,0,0