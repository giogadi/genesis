; ROM HEADER
; ------------------------------------------------------------------------------
rom_header:
    dc.l   $00FFFFFE        ; Initial stack pointer value
    dc.l   EntryPoint       ; Start of program
    dc.l   ignore_handler   ; Bus error
    dc.l   ignore_handler   ; Address error
    dc.l   ignore_handler   ; Illegal instruction
    dc.l   ignore_handler   ; Division by zero
    dc.l   ignore_handler   ; CHK exception
    dc.l   ignore_handler   ; TRAPV exception
    dc.l   ignore_handler   ; Privilege violation
    dc.l   ignore_handler   ; TRACE exception
    dc.l   ignore_handler   ; Line-A emulator
    dc.l   ignore_handler   ; Line-F emulator
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Spurious exception
    dc.l   ignore_handler   ; IRQ level 1
    dc.l   ignore_handler   ; IRQ level 2
    dc.l   ignore_handler   ; IRQ level 3
    dc.l   ignore_handler   ; IRQ level 4 (horizontal retrace interrupt)
    dc.l   ignore_handler   ; IRQ level 5
    dc.l   v_interrupt_handler   ; IRQ level 6 (vertical retrace interrupt)
    dc.l   ignore_handler   ; IRQ level 7
    dc.l   ignore_handler   ; TRAP #00 exception
    dc.l   ignore_handler   ; TRAP #01 exception
    dc.l   ignore_handler   ; TRAP #02 exception
    dc.l   ignore_handler   ; TRAP #03 exception
    dc.l   ignore_handler   ; TRAP #04 exception
    dc.l   ignore_handler   ; TRAP #05 exception
    dc.l   ignore_handler   ; TRAP #06 exception
    dc.l   ignore_handler   ; TRAP #07 exception
    dc.l   ignore_handler   ; TRAP #08 exception
    dc.l   ignore_handler   ; TRAP #09 exception
    dc.l   ignore_handler   ; TRAP #10 exception
    dc.l   ignore_handler   ; TRAP #11 exception
    dc.l   ignore_handler   ; TRAP #12 exception
    dc.l   ignore_handler   ; TRAP #13 exception
    dc.l   ignore_handler   ; TRAP #14 exception
    dc.l   ignore_handler   ; TRAP #15 exception
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    
    dc.b "SEGA GENESIS    " ; Console name
    dc.b "(C) NAMELESS    " ; Copyright holder and release date
    dc.b "VERY MINIMAL GENESIS CODE BY NAMELESS ALGORITHM   " ; Domest. name
    dc.b "VERY MINIMAL GENESIS CODE BY NAMELESS ALGORITHM   " ; Intern. name
    dc.b "2018-07-02    "   ; Version number
    dc.w $0000              ; Checksum
    dc.b "J               " ; I/O support
    dc.l $00000000          ; Start address of ROM
    dc.l __end              ; End address of ROM
    dc.l $00FF0000          ; Start address of RAM
    dc.l $00FFFFFF          ; End address of RAM
    dc.l $00000000          ; SRAM enabled
    dc.l $00000000          ; Unused
    dc.l $00000000          ; Start address of SRAM
    dc.l $00000000          ; End address of SRAM
    dc.l $00000000          ; Unused
    dc.l $00000000          ; Unused
    dc.b "                                        " ; Notes (unused)
    dc.b "JUE             "                         ; Country codes
        


; CONSTANTS
; ------------------------------------------------------------------------------
vdp_control     = $C00004 ; Memory mapped I/O
vdp_data        = $C00000 ;
hv_counter      = $C00008 ;
psg_port        = $C00011 ;

; VDP REGISTERS

VDPREG_MODE1:     equ $8000  ; Mode register #1
VDPREG_MODE2:     equ $8100  ; Mode register #2
VDPREG_MODE3:     equ $8B00  ; Mode register #3
VDPREG_MODE4:     equ $8C00  ; Mode register #4

VDPREG_PLANEA:    equ $8200  ; Plane A table address
VDPREG_PLANEB:    equ $8400  ; Plane B table address
VDPREG_SPRITE:    equ $8500  ; Sprite table address
VDPREG_WINDOW:    equ $8300  ; Window table address
VDPREG_HSCROLL:   equ $8D00  ; HScroll table address

VDPREG_SIZE:      equ $9000  ; Plane A and B size
VDPREG_WINX:      equ $9100  ; Window X split position
VDPREG_WINY:      equ $9200  ; Window Y split position
VDPREG_INCR:      equ $8F00  ; Autoincrement
VDPREG_BGCOL:     equ $8700  ; Background color
VDPREG_HRATE:     equ $8A00  ; HBlank interrupt rate

VDPREG_DMALEN_L:  equ $9300  ; DMA length (low)
VDPREG_DMALEN_H:  equ $9400  ; DMA length (high)
VDPREG_DMASRC_L:  equ $9500  ; DMA source (low)
VDPREG_DMASRC_M:  equ $9600  ; DMA source (mid)
VDPREG_DMASRC_H:  equ $9700  ; DMA source (high)

VRAM_ADDR_CMD:  equ $40000000
CRAM_ADDR_CMD:  equ $C0000000
VSRAM_ADDR_CMD: equ $40000010

VRAM_MAX_ADDR:    equ $FFFF
CRAM_MAX_ADDR:    equ $7F
VSRAM_MAX_ADDR:   equ $4F

RAM_BASE_ADDR:  equ $FF0000
    setso RAM_BASE_ADDR

NEW_FRAME: so.w 1
FRAME_COUNTER: so.w 1

; SACBRLDU
CONTROLLER: so.w 1
UP_BIT: equ 0
DOWN_BIT: equ 1
LEFT_BIT: equ 2
RIGHT_BIT: equ 3
B_BIT: equ 4
C_BIT: equ 5
A_BIT: equ 6
START_BIT: equ 7

CURRENT_X: so.l 1
CURRENT_Y: so.l 1
NEW_X: so.l 1
NEW_Y: so.l 1
HERO_WIDTH: equ 16
HERO_HEIGHT: equ 24

MIN_DISPLAY_X: equ 128
MAX_DISPLAY_X: equ 447
MIN_DISPLAY_Y: equ 128
MAX_DISPLAY_Y: equ 351

ANIM_START_INDEX: so.w 1
ANIM_LAST_INDEX: so.w 1
ANIM_CURRENT_INDEX: so.w 1
ANIM_STRIDE: so.w 1

ENEMY_TYPE_BUTT: equ 0
ENEMY_TYPE_HOT_DOG: equ 1
ENEMY_TYPE_OGRE: equ 2

MAX_NUM_ENEMIES: equ 5
ENEMY_STATE_DEAD: equ 0
ENEMY_STATE_ALIVE: equ 1
ENEMY_STATE_DYING: equ 2
ENEMY_STATE: so.w MAX_NUM_ENEMIES
ENEMY_DYING_FRAMES: equ 10
ENEMY_DYING_FRAMES_LEFT: so.w MAX_NUM_ENEMIES ; only valid if DYING
ENEMY_TYPE: so.w MAX_NUM_ENEMIES
ENEMY_X: so.l MAX_NUM_ENEMIES
ENEMY_Y: so.l MAX_NUM_ENEMIES
ENEMY_SIZE: so.w MAX_NUM_ENEMIES
ENEMY_DATA_1: so.w MAX_NUM_ENEMIES
ENEMY_DATA_2: so.w MAX_NUM_ENEMIES

SPRITE_COUNTER: so.w 1 ; used to help with sprite link data
LAST_LINK_WRITTEN: so.w 1

    include util.asm
    include hero_state.asm
    include butt_enemy.asm
    include hot_dog_enemy.asm
    include ogre_enemy.asm

; INIT
; ------------------------------------------------------------------------------
EntryPoint:               ; Entry point address set in ROM header
    move    #$2500,sr     ; enable level 6 interrupts and above (for v-interrupt)


; TMSS
    move.b  $00A10001,d0  ; Move Megadrive hardware version to d0
    andi.b  #$0F,d0       ; The version is stored in last four bits,
                          ; so mask it with 0F
    beq     @Skip         ; If version is equal to 0,skip TMSS signature
    move.l  #'SEGA',$00A14000 ; Move the string "SEGA" to $A14000
@Skip:

; Z80
;     move.w  #$0100,$00A11100 ; Request access to the Z80 bus
;     move.w  #$0100,$00A11200 ; Hold the Z80 in a reset state
; @Wait:
;     btst    #$0,$00A11101    ; Check if we have access to the Z80 bus yet
;     bne     @Wait            ; If we don't yet have control,branch back up to Wait
;     move.l  #$00A00000,a1    ; Copy Z80 RAM address to a1
;     move.l  #$00C30000,(a1) ; Copy data,and increment the source/dest addresses
 
;     move.w  #$0000,$00A11200 ; Release reset state
;     move.w  #$0000,$00A11100 ; Release control of bus
 
; ; Initialize PSG to silence
;     ;move.l  #$9fbfdfff,psg_port  ; silence

; ; pause z80 dangerously?
; Z80BusReq:  equ $A11100  ; Z80 bus request line
;     move.w  #$100,Z80BusReq

Z80Ram:     equ $A00000  ; Where Z80 RAM starts
Z80BusReq:  equ $A11100  ; Z80 bus request line
Z80Reset:   equ $A11200  ; Z80 reset line
    move.w  #$000,(Z80Reset)
    moveq   #30,d0
    dbf     d0,*
    move.w  #$100,(Z80BusReq)
    move.w  #$100,(Z80Reset)

; Set up controller 1 for reading data (https://www.plutiedev.com/controllers)
; TODO wtf is this
    move.b #$40,$A10009
    move.b #$40,$A10003

; Initialising the VDP
    tst.w   (vdp_control)   ; read port to cancel whatever was going on

    ; Mode register #1
    ; Disable H interrupt, Enable read, H, V counter
    move.w  #VDPREG_MODE1|$04,vdp_control  ; Mode register #1

    ; Mode register #2
    ; ENABLE display, enable v interrupt, disable DMA, NTSC (V 28 cell mode)
    move.w #VDPREG_MODE2|$64,vdp_control

    ; Mode register #3
    ; Disable external interrupt, VSCR full scroll, HSCR/LSCR full scroll
    move.w  #VDPREG_MODE3|$00,vdp_control

    ; Mode register #4
    ; 40 horizontal cells (so resulting screen size in cells is 40x28)
    move.w  #VDPREG_MODE4|$81,vdp_control

    ; Pattern Name Table Base Address for Scroll A
    ; At VRAM address %1100 0000 0000 0000
    ; TODO: figure out how to use the def here for setting the reg
    SCROLL_A_BASE_ADDR: equ $C000
    move.w #SCROLL_A_BASE_ADDR,d0
    lsr.w #8,d0
    lsr.b #2,d0
    and.b #%00111000,d0
    or.w #VDPREG_PLANEA,d0
    move.w d0,vdp_control

    ; Pattern Name Table Base Address for Scroll B
    ; At VRAM address %1110 0000 0000 0000
    move.w  #VDPREG_PLANEB|$07,vdp_control ; Plane B address

    ; Sprite Attribute Table Base Address
    ; VRAM address for H40 mode: %1111 0000 0000 0000
    SPRITE_TABLE_BASE_ADDR: equ $F000
    move.w #SPRITE_TABLE_BASE_ADDR,d0
    rol.w #7,d0
    or.w #VDPREG_SPRITE,d0
    move.w d0,vdp_control
    ;move.w  #VDPREG_SPRITE|$78,vdp_control ; Sprite address

    ; Pattern Name Table Base Address for Window
    ; VRAM address for H40 mode: %1101 0000 0000 0000
    move.w  #VDPREG_WINDOW|$34,vdp_control ; Window address

    ; H Scroll Data Table Base Address
    ; VRAM address %1111 0100 0000 0000
    move.w  #VDPREG_HSCROLL|$3D,vdp_control    ; HSCROLL address

    ; Scroll Size
    ; V 32 cell, H 64 cell
    move.w  #VDPREG_SIZE|$01,vdp_control     ; Tilemap size

    ; Window H Position
    ; Window is on left side of base point
    move.w  #VDPREG_WINX|$00,vdp_control     ; Window X split

    ; Window V Position
    ; Window is on upper side of base point
    move.w  #VDPREG_WINY|$00,vdp_control     ; Window Y split

    ; Autoincrement
    ; increment address by 2 bytes after every VRAM/CRAM/VSRAM access
    move.w  #VDPREG_INCR|$02,vdp_control     ; Autoincrement

    ; Background color
    ; %00PPCCCC - palette and color. currently 0th palette 0th color
    move.w  #VDPREG_BGCOL|$00,vdp_control    ; Background color

    ; H interrupt register
    ; If H interrupt is enabled (see VDPREG_MODE1), trigger after every n rasters,
    ; where n is in this register
    move.w  #VDPREG_HRATE|$FF,vdp_control    ; HBlank IRQ rate

; Zero out VRAM
; TODO: can we set the autoincrement to 4 since we're writing 4 bytes at a time?
    move.l #VRAM_ADDR_CMD,(vdp_control)
    move.w #(VRAM_MAX_ADDR+1)/4-1,d0
@vram_loop
    move.l #0,(vdp_data)
    dbf d0,@vram_loop

; Zero out CRAM
    move.l #CRAM_ADDR_CMD,(vdp_control)
    move.w #(CRAM_MAX_ADDR+1)/4-1,d0
@cram_loop
    move.l #0,(vdp_data)
    dbf d0,@cram_loop

; Zero out VSRAM
    move.l #VSRAM_ADDR_CMD,(vdp_control)
    move.w #(VSRAM_MAX_ADDR+1)/4-1,d0
@vsram_loop
    move.l #0,(vdp_data)
    dbf d0,@vsram_loop

    jsr LoadNormalPalette

; Load in our palettes
;     clr.w d0
;     SetCramAddr d0,d1

;     move #15,d0
;     move.l #SimplePalette,a0
; @palette_loop
;     move.w (a0)+,vdp_data
;     dbra d0,@palette_loop

;     move #15,d0
;     move.l #InversePalette,a0
; @inverse_palette_loop
;     move.w (a0)+,vdp_data
;     dbra d0,@inverse_palette_loop

; Load in one simple tile at 2nd loc. Need to start writing to VRAM at $0020 = %0000 0000 0010 0000
; NOTE: we don't set the autoincrement to 4 because when 68k does longword writes to VDP, VDP
; interprets as 2 separate word writes, so the increment between each of these should still be 2.
TILE_SIZE: equ $0020
FIRST_TILE_INDEX: equ 1
    move.l #(TILE_SIZE*FIRST_TILE_INDEX),d0
    SetVramAddr d0,d1
    
SAMURAI_SPRITE_TILE_START: equ FIRST_TILE_INDEX
NUM_SAMURAI_TILES: equ (3*2*9) ; 3x2 sprite with 9 frames
    move #(8*NUM_SAMURAI_TILES)-1,d0
    move.l #SamuraiLeft1Sprite,a0
@samurai_sprite_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@samurai_sprite_load_loop

TILE_SET_SIZE: equ 30
TILE_SET_START_INDEX: equ (SAMURAI_SPRITE_TILE_START+NUM_SAMURAI_TILES)
    move.w #(8*TILE_SET_SIZE)-1,d0
    move.l #TileSet,a0
@tileset_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@tileset_load_loop

; Load sword slash sprite (4x3 tiles) into VRAM
HORIZ_SLASH_SPRITE_TILE_START: equ (TILE_SET_START_INDEX+TILE_SET_SIZE)
HORIZ_SLASH_SPRITE_TILE_SIZE: equ (4*3)
    move.w #(8*HORIZ_SLASH_SPRITE_TILE_SIZE)-1,d0
    move.l #SlashRightSprite,a0
@horiz_slash_sprite_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@horiz_slash_sprite_load_loop

VERT_SLASH_SPRITE_TILE_START: equ (HORIZ_SLASH_SPRITE_TILE_START+HORIZ_SLASH_SPRITE_TILE_SIZE)
VERT_SLASH_SPRITE_TILE_SIZE: equ (3*4)
    move.w #(8*VERT_SLASH_SPRITE_TILE_SIZE)-1,d0
    move.l #SlashUpSprite,a0
@vert_slash_sprite_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@vert_slash_sprite_load_loop

BUTT_SPRITE_TILE_START: equ (VERT_SLASH_SPRITE_TILE_START+VERT_SLASH_SPRITE_TILE_SIZE)
BUTT_SPRITE_TILE_SIZE: equ (2*2)
    move.w #(8*BUTT_SPRITE_TILE_SIZE)-1,d0
    move.l #ButtSprite,a0
@butt_sprite_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@butt_sprite_load_loop

BUTT_SLASHED_LEFT_SPRITE_TILE_START: equ (BUTT_SPRITE_TILE_START+BUTT_SPRITE_TILE_SIZE)
BUTT_SLASHED_LEFT_SPRITE_TILE_SIZE: equ (2*2)
    move.w #(8*BUTT_SLASHED_LEFT_SPRITE_TILE_SIZE)-1,d0
    move.l #ButtSlashedLeftSprite,a0
@butt_sprite_slashed_left_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@butt_sprite_slashed_left_load_loop

BUTT_SLASHED_RIGHT_SPRITE_TILE_START: equ (BUTT_SLASHED_LEFT_SPRITE_TILE_START+BUTT_SLASHED_LEFT_SPRITE_TILE_SIZE)
BUTT_SLASHED_RIGHT_SPRITE_TILE_SIZE: equ (2*2)
    move.w #(8*BUTT_SLASHED_RIGHT_SPRITE_TILE_SIZE)-1,d0
    move.l #ButtSlashedRightSprite,a0
@butt_sprite_slashed_right_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@butt_sprite_slashed_right_load_loop

HotDogSpriteLoad:
HOT_DOG_SPRITE_TILE_START: equ (BUTT_SLASHED_RIGHT_SPRITE_TILE_START+BUTT_SLASHED_RIGHT_SPRITE_TILE_SIZE)
HOT_DOG_SPRITE_TILE_SIZE: equ (2*2)
    move.w #(8*HOT_DOG_SPRITE_TILE_SIZE)-1,d0
    move.l #HotDogSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

HotDogSlashedLeftSpriteLoad:
HOT_DOG_SLASHED_LEFT_SPRITE_TILE_START: equ (HOT_DOG_SPRITE_TILE_START+HOT_DOG_SPRITE_TILE_SIZE)
HOT_DOG_SLASHED_LEFT_SPRITE_TILE_SIZE: equ (2*2)
    move.w #(8*HOT_DOG_SLASHED_LEFT_SPRITE_TILE_SIZE)-1,d0
    move.l #HotDogSlashedLeftSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

HotDogSlashedRightSpriteLoad:
HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START: equ (HOT_DOG_SLASHED_LEFT_SPRITE_TILE_START+HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_SIZE)
HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_SIZE: equ (2*2)
    move.w #(8*HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_SIZE)-1,d0
    move.l #HotDogSlashedRightSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

OgreSpriteLoad:
OGRE_SPRITE_TILE_START: equ (HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START+HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_SIZE)
OGRE_SPRITE_TILE_SIZE: equ (16*6*6)
    move.w #(8*OGRE_SPRITE_TILE_SIZE)-1,d0
    move.l #OgreSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

DashBarSpriteLoad:
DASH_BAR_SPRITE_TILE_START: equ (OGRE_SPRITE_TILE_START+OGRE_SPRITE_TILE_SIZE)
DASH_BAR_SPRITE_TILE_SIZE: equ (2*8)
    move.w #(8*DASH_BAR_SPRITE_TILE_SIZE)-1,d0
    move.l #DashBarSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

; Now we load the collision data of the above tileset in RAM
TILE_COLLISIONS: so.w TILE_SET_SIZE
    move.w #TILE_SET_SIZE-1,d0
    move.l #TileCollisions,a0
    move.l #TILE_COLLISIONS,a1
.tile_collisions_load_loop
    move.w (a0)+,(a1)+
    dbra d0,.tile_collisions_load_loop

; Dump the tilemap into RAM for easy access, like for collision data.
; TODO: maybe figure out how to dedup this with the vram load below.
; TODO: Do we even need to do this? Should we just keep it in ROM and access it directly?
; Is that faster/slower?
TILEMAP_WIDTH: equ 64
TILEMAP_HEIGHT: equ 32
TILEMAP_SIZE: equ TILEMAP_WIDTH*TILEMAP_HEIGHT
TILEMAP_RAM: so.w TILEMAP_SIZE
    move.w #TILEMAP_SIZE-1,d0
    move.l #TileMap,a0
    move.l #TILEMAP_RAM,a1
@tilemap_ram_load_loop
    move.w (a0)+,(a1)+
    dbra d0,@tilemap_ram_load_loop

LoadTileMap:
; Now let's set the entire scroll table to be one tile
; We start placing stuff in SCROLL_A_BASE_ADDR. Scroll A is currently set to 
; 64H x 32V. Scroll is laid out in row-major order, where each cell is 2 bytes. These
; 2 bytes are the "scroll pattern name" of the cell, which is as follows:
; pri,cp1,cp0,vf,hf,pt10,pt9,pt8
; pt7,pt6,pt5,pt4,pt3,pt2,pt1,pt0
; where pri is priority (TODO figure that out)
; cp is the color palette, vf/hf reverse the layout, and pt is the "pattern number" (tile index)
; we need to start writing vram at SCROLL_A_BASE_ADDR. To do that, we must send 4 bytes of data
; to vdp_control:
; with SCROLL_A_BASE_ADDR = $C000 =  %1100 0000 0000 0000
    move.w #SCROLL_A_BASE_ADDR,d0
    SetVramAddr d0,d1

    move.w #(64*32)-1,d0
    move.l #TileMap,a0
.loop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.loop

LoadEnemies:
    move.w (a0)+,d0 ; enemy count is in d0
    sub.w #1,d0
    blt.s .after_loop
    move.l #ENEMY_STATE,a1
    move.l #ENEMY_X,a2
    move.l #ENEMY_Y,a3
    move.l #ENEMY_DATA_1,a4
    move.l #ENEMY_TYPE,a5
    move.l #ENEMY_SIZE,a6
.loop
    move.w #ENEMY_STATE_ALIVE,(a1)+
    ; push a1 onto the stack so we can reuse it for this jump table
    move.l a1,-(sp)

    move.l #.EnemyTypeJumpTable,a1
    clr.l d3
    move.w (a0),d3 ; Enemy type is in a0 right now.
    lsl.l #2,d3 ; translate longs into bytes
    add.l d3,a1
    ; dereference jump table to get address to jump to
    move.l (a1),a1
    jmp (a1)
    ; TODO: consider making the entries into actual branch instructions.
    ; Can be 2 cycles faster apparently?
.EnemyTypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    move.w #$1010,(a6)+
    bra.s .AfterJumpTable
.HotDog:
    move.w #$1010,(a6)+
    bra.s .AfterJumpTable
.Ogre:
    move.w #$3030,(a6)+
    bra.s .AfterJumpTable
.AfterJumpTable

    move.l (sp)+,a1

    move.w (a0)+,(a5)+ ; enemy type
    move.w (a0)+,d1 ; enemy x
    add.w #MIN_DISPLAY_X,d1 ; add min display offset TODO: do this properly
    move.w d1,(a2)
    add.l #4,a2
    move.w (a0)+,d1 ; enemy y
    add.w #MIN_DISPLAY_Y,d1
    move.w d1,(a3)
    add.l #4,a3
    move.w #0,(a4)+ ; enemy_data_1
    dbra d0,.loop
.after_loop

; start with default/idle animation
    jsr SetLeftIdleAnim

; FM TEST FM TEST FM TEST
    include fm_test.asm

; MAIN PROGRAM
; ------------------------------------------------------------------------------
__main
; PSG test.
    ;jsr @test_psg

    move.w #287,CURRENT_X
    move.w #310,CURRENT_Y

LEFT_IDLE_STATE: equ 0
RIGHT_IDLE_STATE: equ 1
WALK_LEFT_STATE: equ 2
WALK_RIGHT_STATE: equ 3
SLASH_LEFT_STATE: equ 4
SLASH_RIGHT_STATE: equ 5
WINDUP_LEFT_STATE: equ 6
WINDUP_RIGHT_STATE: equ 7
HURT_LEFT_STATE: equ 8
HURT_RIGHT_STATE: equ 9
PREVIOUS_ANIM_STATE: so.w 1
    move.w #LEFT_IDLE_STATE,PREVIOUS_ANIM_STATE
NEW_ANIM_STATE: so.w 1
    move.w PREVIOUS_ANIM_STATE,NEW_ANIM_STATE

FACING_UP: equ 0
FACING_DOWN: equ 1
FACING_LEFT: equ 2
FACING_RIGHT: equ 3
FACING_DIRECTION: so.w 1
    move.w #FACING_LEFT,FACING_DIRECTION

;SLASH_STARTUP_ITERS: equ 20
SLASH_STARTUP_ITERS: equ 2
;SLASH_RECOVERY_ITERS: equ 20
SLASH_RECOVERY_ITERS: equ 2

ITERATIONS_PER_ANIM_FRAME: equ 20
ITERATIONS_UNTIL_NEXT_ANIM_FRAME: so.w 1
    move.w #ITERATIONS_PER_ANIM_FRAME,ITERATIONS_UNTIL_NEXT_ANIM_FRAME

HITSTOP_FRAMES_LEFT: so.w 1
HITSTOP_FRAMES: equ 15
;HITSTOP_FRAMES: equ 20

HERO_SPEED: equ 1
DASHING_SPEED: equ (5*HERO_SPEED)
;HERO_DASH_COOLDOWN: equ 32
HERO_DASH_COOLDOWN: equ 2

HERO_STATE: so.w 1
    move.w #HERO_STATE_IDLE,HERO_STATE
HERO_STATE_IDLE: equ 0
HERO_STATE_SLASH_STARTUP: equ 1
HERO_STATE_SLASH_ACTIVE: equ 2
HERO_STATE_SLASH_RECOVERY: equ 3
HERO_STATE_HURT: equ 4
HERO_STATE_DASHING: equ 5

HERO_NEW_STATE: so.w 1
    move.w #1,HERO_NEW_STATE

HERO_STATE_FRAMES_LEFT: so.w 1

; Hero-state-specific fields
HURT_DIRECTION: so.w 1
BUTTON_RELEASED_SINCE_LAST_SLASH: so.w 1
    move.w #1,BUTTON_RELEASED_SINCE_LAST_SLASH
; these only valid if SLASH_ACTIVE
SLASH_MIN_X: so.w 1
SLASH_MIN_Y: so.w 1
SLASH_MAX_X: so.w 1
SLASH_MAX_Y: so.w 1
BUTTON_RELEASED_SINCE_LAST_DASH: so.w 1
    move.w #1,BUTTON_RELEASED_SINCE_LAST_DASH
HERO_DASH_COOLDOWN_FRAMES_LEFT: so.w 1
HERO_DASH_CURRENT_SPEED: so.l 1
HERO_DASH_CURRENT_STATE: so.w 1 ; 0: accel, 1: decel
HERO_DASH_DIRECTION: so.w 1

GLOBAL_PALETTE: so.w 1
    move.w #0,GLOBAL_PALETTE

DASH_BUFFERED: so.w 1
    move.w #0,DASH_BUFFERED

loop
    tst.w HITSTOP_FRAMES_LEFT
    beq.w NoHitstop
    sub.w #1,HITSTOP_FRAMES_LEFT
    jsr CheckForDashBuffer
    jmp WaitNewFrame

NoHitstop
    GetControls d0,d1
    
    ; TODO: should we move this to the bottom of the loop?
    move.w #0,HERO_NEW_STATE
    move.l CURRENT_X,NEW_X
    move.l CURRENT_Y,NEW_Y

    jsr UpdateButtonReleasedSinceLastSlash
    jsr UpdateButtonReleasedSinceLastDash
    ; Update Dash cooldown.
    tst.w HERO_DASH_COOLDOWN_FRAMES_LEFT
    ble.s .AfterCooldownUpdate
    sub.w #1,HERO_DASH_COOLDOWN_FRAMES_LEFT
.AfterCooldownUpdate


    jsr HeroStateUpdate

.CheckNewPosition ; new position is in NEW_X,NEW_Y
    move.w NEW_X,d4
    move.w NEW_Y,d5

    ; TODO: we should probably clamp the subpixel part of position as well
    ; clamp sprite x
    move.w d4,d0
    move.w #MIN_DISPLAY_X,d1
    jsr ClampMin
    move.w #MAX_DISPLAY_X,d1
    jsr ClampMax
    move.w d0,d4

    ; ; clamp sprite y
    move.w d5,d0
    move.w #MIN_DISPLAY_Y,d1
    jsr ClampMin
    move.w #MAX_DISPLAY_Y-24,d1 ; -24 is to account for sprite's origin being at top-left
    jsr ClampMax
    move.w d0,d5

    ; check collisions
    move.w d4,d0
    move.w d5,d1
    jsr CheckCollisions
    ; clr.w d0 ; disable collision result (debug)
    tst.w d0
    bne.s .skipPositionUpdate

    ; update sprite position
    move.w d4,CURRENT_X
    move.w d5,CURRENT_Y
    ; move.l NEW_X,CURRENT_X
    ; move.l NEW_Y,CURRENT_Y

.skipPositionUpdate

    move.w NEW_ANIM_STATE,d0 ; move new anim state to d0
    jsr UpdateAnimState

    ; update animation
    sub.w #1,ITERATIONS_UNTIL_NEXT_ANIM_FRAME
    bgt.w .AfterAnimFrameIncrement
    move.w ANIM_STRIDE,d0
    add.w d0,ANIM_CURRENT_INDEX
    move.w ANIM_LAST_INDEX,d0
    cmp.w ANIM_CURRENT_INDEX,d0
    bge.w .AfterAnimFrameFlip
    move.w ANIM_START_INDEX,ANIM_CURRENT_INDEX
.AfterAnimFrameFlip
    move.w #ITERATIONS_PER_ANIM_FRAME,ITERATIONS_UNTIL_NEXT_ANIM_FRAME
.AfterAnimFrameIncrement:

    ; update enemies' alive states
    jsr UpdateEnemiesFromSlash

    ; update alive enemies' behavior
    jsr UpdateEnemies

    ; SPRITE DRAWING!
    move.w #SPRITE_TABLE_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w #0,SPRITE_COUNTER

    jsr DrawDashBar

    jsr DrawHero

    ; SLASH
    ; TODO: with our improved link data handling, see if we can just skip all this if no slash
    add.w #1,SPRITE_COUNTER ; whether we slash or not we have a sprite for it
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    bne.w .NoSlash
    ; figure out position/orientation/image of slash sprite
    move.w CURRENT_X,d0
    move.w CURRENT_Y,d1
    move.l #.SlashDirectionJumpTable,a0
    clr.l d3
    move.w FACING_DIRECTION,d3 ; offset in longs into jump table
    lsl.l #2,d3 ; translate longs into bytes
    add.l d3,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
    ; TODO: consider making the entries into actual branch instructions.
    ; Can be 2 cycles faster apparently?
.SlashDirectionJumpTable dc.l .SlashUp,.SlashDown,.SlashLeft,.SlashRight
.SlashUp
    sub.w #24,d1
    move.w #VERT_SLASH_SPRITE_TILE_START,d4
    move.w #$0B00,d3 ; 3x4
    bra.s .AfterSlashDirection
.SlashDown
    add.w #24,d1
    move.w #VERT_SLASH_SPRITE_TILE_START,d4
    move.w #$0B00,d3 ; 3x4
    bset.l #$0C,d4 ; v-flip
    bra.s .AfterSlashDirection
.SlashLeft
    sub.w #32,d0
    move.w #HORIZ_SLASH_SPRITE_TILE_START,d4
    move.w #$0E00,d3 ; 4x3
    bset.l #$0B,d4 ; h-flip
    bra.s .AfterSlashDirection
.SlashRight
    add.w #16,d0
    move.w #HORIZ_SLASH_SPRITE_TILE_START,d4
    move.w #$0E00,d3 ; 4x3
.AfterSlashDirection
    ; move.w #SLASH_SPRITE_ADDR,d0
    ; SetVramAddr d0,d1
    move.w d1,vdp_data
    or.w SPRITE_COUNTER,d3 ; add link data computed way above
    move.w d3,vdp_data
    move.w d3,LAST_LINK_WRITTEN
    ; set global palette onto d4
    move.w GLOBAL_PALETTE,d1
    ror.w #3,d1
    or.w d1,d4
    move.w d4,vdp_data
    move.w d0,vdp_data
    bra.s .AfterSlash
.NoSlash
    ; don't draw slash sprite (but give it a proper link data)
    move.w #0,vdp_data
    move.w SPRITE_COUNTER,vdp_data
    move.w SPRITE_COUNTER,LAST_LINK_WRITTEN
    move.w #0,vdp_data
    move.w #0,vdp_data
.AfterSlash

DrawEnemiesNew:
    clr.l d2
    move.b #0,d2
.loop
    cmp.b #MAX_NUM_ENEMIES,d2
    bge.w .end
    move.l #ENEMY_STATE,a0
    clr.w d3
    move.b d2,d3
    add.b d3,d3
    move.w 0(a0,d3),d0
    ; if dead, skip to next enemy
    beq.s .loop_continue
    ; push everything we need onto the stack: state, dying_frames, data1, data2, x, y
    move.w d0,-(sp) ; state
    move.l #ENEMY_DYING_FRAMES_LEFT,a0
    move.w 0(a0,d3),-(sp)
    move.l #ENEMY_DATA_1,a0
    move.w 0(a0,d3),-(sp)
    move.l #ENEMY_DATA_2,a0
    move.w 0(a0,d3),-(sp)
    move.l #ENEMY_TYPE,a0
    move.w 0(a0,d3),d0 ; enemy type in d0
    ; X and Y are 4 bytes, so multiply d3 by 2 again
    add.b d3,d3
    move.l #ENEMY_X,a0
    move.l (0,a0,d3),-(sp)
    move.l #ENEMY_Y,a0
    move.l (0,a0,d3),-(sp)
    ; now jump to draw function appropriate to this enemy type
    move.l #.TypeJumpTable,a0
    lsl.l #2,d0 ; translate longs into bytes
    add.l d0,a0
    ; dereference jump table to get address to jump to
    move.l (a0),a0
    jmp (a0)
.TypeJumpTable dc.l .Butt,.HotDog,.Ogre
.Butt:
    jsr DrawButtEnemy
    bra.s .AfterJumpTable
.HotDog:
    jsr DrawHotDogEnemy
    bra.s .AfterJumpTable
.Ogre:
    jsr DrawOgreEnemy
    bra.s .AfterJumpTable
.AfterJumpTable
    add.l #(2+2+4+4+2+2),sp
.loop_continue
    add.b #1,d2
    bra.w .loop
.end

    ; set last sprite's link data to 0
    clr.l d0
    clr.l d1
    move.w SPRITE_COUNTER,d0
    sub.w #1,d0
    lsl.w #3,d0 ; now d0 is offset in sprite-entries
    add.w #SPRITE_TABLE_BASE_ADDR+2,d0 ; get to link data entry of table
    SetVramAddr d0,d1
    move.w LAST_LINK_WRITTEN,d0
    and.w #$FF00,d0 ; zero out link data
    move.w d0,vdp_data


WaitNewFrame
    cmp.b #1,NEW_FRAME
    bne.s WaitNewFrame
    clr.b NEW_FRAME
    add.w #1,FRAME_COUNTER
    jmp     loop

; EXCEPTION AND INTERRUPT HANDLERS
; ----------------------------------------------------------------------------
    align 2 ; word-align code

ignore_handler
    move.w #$0001,a0 ; debug
    rte ; return from exception (seems to restore PC)

v_interrupt_handler:
    move.b #1,NEW_FRAME
    rte

; DATA
; ----------------------------------------------------------------------------

SimplePalette:
    include art/simple_palette.asm

InversePalette:
    include art/inverse_palette.asm

TileSet:
    include art/tileset.asm

TileCollisions:
    include art/tile_collisions.asm

TileMap:
    include art/tiles/map1_large.asm

SamuraiLeft1Sprite:
    include art/samurai/left1.asm

SamuraiLeft2Sprite:
    include art/samurai/left2.asm

SamuraiRight1Sprite:
    include art/samurai/right1.asm

SamuraiRight2Sprite:
    include art/samurai/right2.asm

SamuraSlashLeftSprite:
    include art/samurai/slash_left.asm

SamuraSlashRightSprite:
    include art/samurai/slash_right.asm

WindupLeftSprite:
    include art/samurai/windup_left.asm

WindupRightSprite:
    include art/samurai/windup_right.asm

HurtLeftSprite:
    include art/samurai/hurt_left.asm

SlashRightSprite:
    include art/slash_sprite.asm

SlashUpSprite:
    include art/slash_vertical.asm

ButtSprite:
    include art/butt.asm

ButtSlashedLeftSprite:
    include art/butt_slashed_left.asm

ButtSlashedRightSprite:
    include art/butt_slashed_right.asm

HotDogSprite:
    include art/hot_dog_sprite.asm
HotDogSlashedLeftSprite:
    include art/hot_dog_slashed_left.asm
HotDogSlashedRightSprite:
    include art/hot_dog_slashed_right.asm

OgreSprite:
    include art/ogre_sprite.asm

DashBarSprite:
    include art/ui/dash_bar.asm

SineLookupTable:
    include sine_lookup_table.asm

atan2LookupTable:
    include atan2_lookup_table.asm

__end: