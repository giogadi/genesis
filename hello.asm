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

; struct Enemy
    setso 0
N_ENEMY_STATE: so.w 1
N_ENEMY_STATE_FRAMES_LEFT: so.w 1
N_ENEMY_TYPE: so.w 1
N_ENEMY_X: so.l 1
N_ENEMY_Y: so.l 1
N_ENEMY_HALF_W: so.w 1
N_ENEMY_HALF_H: so.w 1
N_ENEMY_HP: so.w 1
N_ENEMY_DATA1: so.w 1
N_ENEMY_DATA2: so.w 1
N_ENEMY_SIZE: equ __SO

; struct Script
    setso 0
SCRIPT_COND_FN: so.l 1
SCRIPT_COND_FN_INPUT: so.l 1
SCRIPT_ACTION_FN: so.l 1
SCRIPT_ACTION_FN_INPUT: so.l 2
SCRIPT_ITEM_SIZE: equ __SO

RAM_BASE_ADDR:  equ $FF0000
    setso RAM_BASE_ADDR

NEW_FRAME: so.w 1
FRAME_COUNTER: so.w 1

; SACBRLDU
; all data is in upper byte (exactly at CONTROLLER)
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
HERO_WIDTH_IN_TILES: equ 2
HERO_HEIGHT_IN_TILES: equ 3
HERO_WIDTH: equ HERO_WIDTH_IN_TILES*8
HERO_HEIGHT: equ HERO_HEIGHT_IN_TILES*8

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
ENEMY_TYPE_RED_SEAL: equ 3

MAX_NUM_ENEMIES: equ 5
ENEMY_STATE_DEAD: equ 0
ENEMY_STATE_ALIVE: equ 1
ENEMY_STATE_DYING: equ 2
;ENEMY_STATE_HITSTUN: equ 3
ENEMY_DYING_FRAMES: equ 10

N_ENEMIES: so.b (MAX_NUM_ENEMIES*N_ENEMY_SIZE)
ENTITY_TYPE_BUTT: equ 0
ENTITY_TYPE_HOT_DOG: equ 1
ENTITY_TYPE_OGRE: equ 2
ENTITY_TYPE_RED_SEAL: equ 3
ENTITY_TYPE_SPAWNER: equ 4

SPRITE_COUNTER: so.w 1 ; used to help with sprite link data
LAST_LINK_WRITTEN: so.w 1

VISIBLE_TILE_W: equ 40
VISIBLE_TILE_H: equ 28
SCROLL_TILE_W_LOG2: equ 6
SCROLL_TILE_H_LOG2: equ 5
SCROLL_TILE_W: equ (1<<SCROLL_TILE_W_LOG2)
SCROLL_TILE_H: equ (1<<SCROLL_TILE_H_LOG2)

    include util.asm
    include script_functions.asm
    include text.asm
    include hero_state.asm
    include butt_enemy.asm
    include hot_dog_enemy.asm
    include ogre_enemy.asm
    include red_seal.asm
    include crab_spawner.asm

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
    move.w  #$8B00,vdp_control

    ; Mode register #4
    ; 40 horizontal cells (so resulting screen size in cells is 40x28)
    move.w  #VDPREG_MODE4|$81,vdp_control

    ; Pattern Name Table Base Address for Scroll A
    SCROLL_A_BASE_ADDR: equ $C000
    move.w #SCROLL_A_BASE_ADDR,d0
    lsr.w #8,d0
    lsr.b #2,d0
    and.b #%00111000,d0
    or.w #VDPREG_PLANEA,d0
    move.w d0,vdp_control

    ; Pattern Name Table Base Address for Scroll B
    ; At VRAM address %1110 0000 0000 0000
    SCROLL_B_BASE_ADDR: equ $E000
    move.w #SCROLL_B_BASE_ADDR,d0
    rol.w #3,d0
    or.w #VDPREG_PLANEB,d0
    move.w d0,vdp_control

    ; Sprite Attribute Table Base Address
    SPRITE_TABLE_BASE_ADDR: equ $D000
    move.w #SPRITE_TABLE_BASE_ADDR,d0
    rol.w #7,d0
    or.w #VDPREG_SPRITE,d0
    move.w d0,vdp_control

    ; Pattern Name Table Base Address for Window
    WINDOW_TABLE_BASE_ADDR: equ $D000
    move.w #WINDOW_TABLE_BASE_ADDR,d0
    rol.w #6,d0
    or.w #VDPREG_WINDOW,d0
    move.w d0,vdp_control

    ; H Scroll Data Table Base Address
    H_SCROLL_TABLE_BASE_ADDR: equ $D400
    move.w #H_SCROLL_TABLE_BASE_ADDR,d0
    rol.w #6,d0
    or.w #VDPREG_HSCROLL,d0
    move.w d0,vdp_control

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

    jsr LoadPalettes

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

TILE_SET_SIZE: equ 150
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

RedSealSpriteLoad:
RED_SEAL_SPRITE_TILE_START: equ (HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_START+HOT_DOG_SLASHED_RIGHT_SPRITE_TILE_SIZE)
RED_SEAL_SPRITE_TILE_SIZE: equ (3*4)
    move.w #(8*RED_SEAL_SPRITE_TILE_SIZE)-1,d0
    move.l #RedSealSprite,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

FontTileLoad:
FONT_TILE_START: equ (RED_SEAL_SPRITE_TILE_START+RED_SEAL_SPRITE_TILE_SIZE)
FONT_TILE_SIZE: equ 40
    move.w #(8*FONT_TILE_SIZE)-1,d0
    move.l #FontTiles,a0
.loop
    move.l (a0)+,vdp_data
    dbra d0,.loop

TitleTileLoad:
TITLE_TILE_START: equ (FONT_TILE_START+FONT_TILE_SIZE)
TITLE_TILE_SIZE: equ (40*17)
    move.w #(8*TITLE_TILE_SIZE)-1,d0
    move.l #TitleTiles,a0
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

TILEMAP_WIDTH: equ (1<<TILEMAP_WIDTH_LOG2)
TILEMAP_SIZE: equ TILEMAP_WIDTH*TILEMAP_HEIGHT

LoadTileMapB:
    move.w #SCROLL_B_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w #(SCROLL_TILE_W*SCROLL_TILE_H)-1,d0
    move.l #TileMap,a0
.loop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.loop

    ; after the tilemap comes the hero start position. this is after 2 layers of width*height words
    ; in the tilemap data.
TILEMAP_HERO_START_DATA: equ TileMap+2*TILEMAP_SIZE*2
    move.w TILEMAP_HERO_START_DATA,CURRENT_X
    move.w (TILEMAP_HERO_START_DATA+2),CURRENT_Y

    ; Enemies are at the end of the tilemap file. They come right after the hero start data above.
TILEMAP_ENEMY_DATA: equ (TILEMAP_HERO_START_DATA+4)
    move.l #TILEMAP_ENEMY_DATA,a0
    jsr UtilLoadEnemies

; start with default/idle animation
    jsr SetLeftIdleAnim

; FM TEST FM TEST FM TEST
    include fm_test.asm

; MAIN PROGRAM
; ------------------------------------------------------------------------------
__main
; PSG test.
    ;jsr @test_psg

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

SLASH_STARTUP_ITERS: equ 20
;SLASH_STARTUP_ITERS: equ 2
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

CURRENT_HSCROLL_A: so.w 1
    move.w #0,CURRENT_HSCROLL_A
CURRENT_HSCROLL_B: so.w 1
    move.w #0,CURRENT_HSCROLL_B
CURRENT_VSCROLL_A: so.w 1
    move.w #0,CURRENT_VSCROLL_A
CURRENT_VSCROLL_B: so.w 1
    move.w #0,CURRENT_VSCROLL_B

; Point to first item of script
CURRENT_SCRIPT_ITEM: so.l 1
    move.l #Script,CURRENT_SCRIPT_ITEM

LAST_SPAWNED_ENTITY: so.l 1
SCRIPT_STORED_ENTITY: so.l 1

SCRIPT_DATA: so.l 1

HERO_FROZEN: so.w 1
    move.w #0,HERO_FROZEN

CAMERA_STATE_FOLLOW_HERO: equ 0
CAMERA_STATE_MANUAL_PAN: equ 1
CURRENT_CAMERA_STATE: so.w 1
    move.w #0,CURRENT_CAMERA_STATE
; only meaningful when MANUAL_PAN
CAMERA_MANUAL_PAN_X: so.b 1
    move.b #0,CAMERA_MANUAL_PAN_X
CAMERA_MANUAL_PAN_Y: so.b 1
    move.b #0,CAMERA_MANUAL_PAN_Y

; Title screen
; Dimensions of title sprite are 320x136 (40x17 tiles)
; So every 40 tiles we will reset the vram addr to the next "row".
; Each full scroll row is 64 tiles. Each tile is actually 1 word of data
ShowTitleImage
    move.w #TITLE_TILE_START,d0 ; tile numbers in ROM
    move.w #SCROLL_A_BASE_ADDR,d3 ; d3 is row start in VRAM
    move.w #(17-1),d2 ; row counter
.RowLoop
    move.w d3,d4
    SetVramAddr d4,d1
    move.w #(40-1),d4 ; cell counter within row
.CellLoop
    move.w d0,vdp_data
    add.w #1,d0
    dbra d4,.CellLoop
    ; End of row
    add.w #(2*SCROLL_TILE_W),d3
    dbra d2,.RowLoop

ShowP1Start
    ; set vram write to start at tile index (32,20)
    move.w #16,d0
    move.w #20,d1
    jsr UtilSetScrollAWriteAt
    bra.s .afterString
.string
    dc.w TEXT_P,TEXT_1,TEXT_SPACE,TEXT_S,TEXT_T,TEXT_A,TEXT_R,TEXT_T,TEXT_TERMINATE
.afterString 
    move.l #.string,a0
    jsr TextWriteString

TitleGameLoop:
    ; H SCROLL
    ; no increment for now
    move.w #H_SCROLL_TABLE_BASE_ADDR,d0  ; horizontal scrolling
    SetVramAddr d0,d1
    move.w CURRENT_HSCROLL_A,d0
    move.w d0,vdp_data
    move.w CURRENT_HSCROLL_B,d0
    move.w d0,vdp_data

    ; V SCROLL. scrolling B only.
    move.w #0,d0  ; vertical scrolling
    SetVsramAddr d0,d1
    move.w CURRENT_VSCROLL_A,d0
    move.w d0,vdp_data
    move.w CURRENT_VSCROLL_B,d0
    move.w d0,vdp_data
    btst.b #0,(FRAME_COUNTER+1)
    beq.s .NoScrollIncrement
    add.w #1,d0
    move.w d0,CURRENT_VSCROLL_B
.NoScrollIncrement
    GetControls d0,d1
    move.b CONTROLLER,d0
    btst.l #START_BIT,d0
    bne.s .TitleEnd

.TitleWaitNewFrame:
    cmp.b #1,NEW_FRAME
    bne.s .TitleWaitNewFrame
    clr.b NEW_FRAME
    add.w #1,FRAME_COUNTER
    jmp TitleGameLoop
.TitleEnd

; Reset HScroll
    move.w #0,CURRENT_HSCROLL_A
    move.w #0,CURRENT_HSCROLL_B
    move.w #H_SCROLL_TABLE_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w CURRENT_HSCROLL_A,d0
    move.w d0,vdp_data
    move.w CURRENT_HSCROLL_B,d0
    move.w d0,vdp_data

; Reset VScroll
    move.w #16,CURRENT_VSCROLL_A
    move.w #16,CURRENT_VSCROLL_B
    move.w #0,d0
    SetVsramAddr d0,d1
    move.w CURRENT_VSCROLL_A,d0
    move.w d0,vdp_data
    move.w CURRENT_VSCROLL_B,d0
    move.w d0,vdp_data

    jsr UtilClearScrollA

    jsr UtilLoadEnemySprites

CAMERA_LEFT_X: so.w 1
    move.w #0,CAMERA_LEFT_X

CAMERA_TOP_Y: so.w 1
    ; set camera pos to center on hero (but clamp to tilemap dimensions)
    move.w CURRENT_Y,d0
    add.w #(HERO_HEIGHT/2-VISIBLE_TILE_H*8/2),d0
    ; if camera is above top of map (into the top 2 rows of padding), clamp.
CAMERA_MIN_Y: equ 2*8
    move.w #CAMERA_MIN_Y,d1
    cmp.w d1,d0
    bge .AfterClampCameraTop
    move.w #CAMERA_MIN_Y,d0
.AfterClampCameraTop
    ; if camera is below bottom of map, clamp.
CAMERA_MAX_Y: equ ((TILEMAP_HEIGHT-28)*8)
    move.w #CAMERA_MAX_Y,d1
    cmp.w d0,d1
    bge .AfterClampCameraBottom
    move.w #CAMERA_MAX_Y,d0
.AfterClampCameraBottom
    move.w d0,CAMERA_TOP_Y

    
; IF I REMEMBER CORRECTLY, these only need to be changed if the tilemap width changes? or maybe the scroll width?
NEXT_DOWN_SCROLL_VRAM_OFFSET: so.w 1
    ;move.w #31*64*2,NEXT_DOWN_SCROLL_VRAM_OFFSET
    move.w #((SCROLL_TILE_H-1)*SCROLL_TILE_W*2),NEXT_DOWN_SCROLL_VRAM_OFFSET
NEXT_UP_SCROLL_VRAM_OFFSET: so.w 1 
    move.w #0,NEXT_UP_SCROLL_VRAM_OFFSET

; get tilemap offset w.r.t. camera_top_y
; gonna get two rows above top_y and two rows below bottom_y
    move.w CAMERA_TOP_Y,d3
    and.l #$0000FFFF,d3
    lsr.w #3,d3 ; camera world row in tiles
    sub.w #2,d3 ; offset to center camera in scroll
    lsl.w #(SCROLL_TILE_W_LOG2+1),d3 ; multiply by SCROLL_TILE_W*2 to get tile offset in bytes

LoadTileMapBAgain:
    move.w #SCROLL_B_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w #(SCROLL_TILE_W*SCROLL_TILE_H)-1,d0
    move.l #TileMap,a0
    add.l d3,a0
.loop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.loop

LoadTileMapA:
    move.w #SCROLL_A_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w #(SCROLL_TILE_W*SCROLL_TILE_H)-1,d0
    move.l #(TileMap+TILEMAP_SIZE*2),a0
    add.l d3,a0
.loop
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    move.w d1,vdp_data
    dbra d0,.loop

MainGameLoop
    ; auto scrolling for testing
    ; h scrolling
    move.w #H_SCROLL_TABLE_BASE_ADDR,d0  ; horizontal scrolling
    SetVramAddr d0,d1
    move.w CURRENT_HSCROLL_A,d0
    move.w d0,vdp_data
    move.w CURRENT_HSCROLL_B,d0
    move.w d0,vdp_data

    tst.w HITSTOP_FRAMES_LEFT
    beq.w .NoHitstop
    sub.w #1,HITSTOP_FRAMES_LEFT
    jsr CheckForDashBuffer
    jmp WaitNewFrame
.NoHitstop
    GetControls d0,d1

    ; Update script
    ; Call the condition function of the current script item. If it returns d0 == 1, then call its
    ; action function and increment current script item ptr.
    move.l CURRENT_SCRIPT_ITEM,a0
    move.l SCRIPT_COND_FN(a0),a0
    jsr (a0) ; call condition function
    tst.b d0
    beq .AfterUpdateScript
    ; condition was fulfilled. perform action.
    move.l CURRENT_SCRIPT_ITEM,a0
    move.l SCRIPT_ACTION_FN(a0),a0
    jsr (a0) ; call action function
    ; point to next script item
    add.l #SCRIPT_ITEM_SIZE,CURRENT_SCRIPT_ITEM
.AfterUpdateScript
    
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
    move.w #0,d1
    jsr ClampMin
    move.w #(TILEMAP_WIDTH*8-HERO_WIDTH),d1
    jsr ClampMax
    move.w d0,d4

    ; clamp sprite y
    move.w d5,d0
    move.w #0,d1
    jsr ClampMin
    move.w #(TILEMAP_HEIGHT*8-HERO_HEIGHT),d1
    jsr ClampMax
    move.w d0,d5

    move.w d4,NEW_X
    move.w d5,NEW_Y

    ; check tile collisions
    move.w d4,d0
    move.w d5,d1
    ; clear out top words of each register, since CheckCollisions assumes we could potentially
    ; use the entire register for a tile index and we're only using words above.
    and.l #$0000FFFF,d0
    and.l #$0000FFFF,d1
    jsr UtilCheckCollisions
    ;clr.b d0 ; disable collision result (debug)
    tst.b d0
    bne.s .skipPositionUpdate

    ; check entity collisions. skip position update if any entity blocks new hero position.
    move.w #MAX_NUM_ENEMIES-1,d2
    move.l #N_ENEMIES,a2
.loop
    move.w N_ENEMY_STATE(a2),d0
    beq.s .continue_loop ; if dead, skip to next enemy
    jsr UtilEnemyBlockHeroVirtual
    bne.s .skipPositionUpdate
.continue_loop
    add.l #N_ENEMY_SIZE,a2
    dbra d2,.loop

    ; update sprite position
    move.w NEW_X,CURRENT_X
    move.w NEW_Y,CURRENT_Y

.skipPositionUpdate

    jsr UtilUpdateCamera

    clr.l d0
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

    ; update alive enemies' behavior
    jsr UtilUpdateEnemies

    ; SPRITE DRAWING!
    move.w #SPRITE_TABLE_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w #0,SPRITE_COUNTER

    ; jsr DrawDashBar

    jsr DrawHero

    ; SLASH
    ; TODO: with our improved link data handling, see if we can just skip all this if no slash
    add.w #1,SPRITE_COUNTER ; whether we slash or not we have a sprite for it
    move.w HERO_STATE,d0
    cmp.w #HERO_STATE_SLASH_ACTIVE,d0
    bne.w .NoSlash
    ; figure out position/orientation/image of slash sprite
    move.w CURRENT_X,d0
    sub.w CAMERA_LEFT_X,d0
    add.w #MIN_DISPLAY_X,d0
    move.w CURRENT_Y,d1
    sub.w CAMERA_TOP_Y,d1
    add.w #MIN_DISPLAY_Y,d1
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

    jsr UtilDrawEnemySlashes

    ; jsr DrawEnemies
    jsr UtilDrawEnemies

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
    jmp     MainGameLoop

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

AllPalettes:
    include art/all_palettes.asm

TileSet:
    include art/tiles/bridge2_tileset.asm

TileCollisions:
    include art/tiles/bridge2_tileset_collisions.asm

; level
    include art/levels/bridge/level.asm
    ;include art/levels/test1/level.asm

TitleTiles:
    include art/title_320_136.asm

FontTiles:
    include art/font.asm

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
OgreSlashRightSprite:
    include art/ogre_slash_sprite.asm
OgreSlashUpSprite:
    include art/ogre_slash_vertical.asm

RedSealSprite:
    include art/red_seal.asm

DashBarSprite:
    include art/ui/dash_bar.asm

SineLookupTable:
    include sine_lookup_table.asm

atan2LookupTable:
    include atan2_lookup_table.asm

__end: