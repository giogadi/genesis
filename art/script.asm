    ; spawn butt spawner
    dc.l UtilReturnTrue
    dc.w 0,0
    dc.l ScriptSpawnEntity
    dc.w ENTITY_TYPE_SPAWNER,152,600,0
    ; end
    dc.l UtilReturnFalse,0,UtilEmptyFn,0,0