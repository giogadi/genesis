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
; DEBUG
OR_CONTROLLER: so.w 1
    clr.w OR_CONTROLLER
NEW_FRAME: so.w 1

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

CURRENT_X: so.w 1
CURRENT_Y: so.w 1

MIN_DISPLAY_X: equ 128
MAX_DISPLAY_X: equ 447
MIN_DISPLAY_Y: equ 128
MAX_DISPLAY_Y: equ 351

ANIM_START_INDEX: so.w 1
ANIM_LAST_INDEX: so.w 1
ANIM_CURRENT_INDEX: so.w 1
ANIM_STRIDE: so.w 1

    include util.asm

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

; Load in our palette
    clr.w d0
    SetCramAddr d0,d1

    move #15,d0
    move.l #SimplePalette,a0
@palette_loop
    move.w (a0)+,vdp_data
    dbra d0,@palette_loop

; Load in one simple tile at 2nd loc. Need to start writing to VRAM at $0020 = %0000 0000 0010 0000
; NOTE: we don't set the autoincrement to 4 because when 68k does longword writes to VDP, VDP
; interprets as 2 separate word writes, so the increment between each of these should still be 2.
TILE_SIZE: equ $0020
FIRST_TILE_INDEX: equ 1
    move.l #(TILE_SIZE*FIRST_TILE_INDEX),d0
    SetVramAddr d0,d1
    
SAMURAI_SPRITE_TILE_START: equ FIRST_TILE_INDEX
NUM_SAMURAI_TILES: equ (3*2*4)
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
SLASH_SPRITE_TILE_START: equ (TILE_SET_START_INDEX+TILE_SET_SIZE)
SLASH_SPRITE_TILE_SIZE: equ (4*3)
    move.w #(8*SLASH_SPRITE_TILE_SIZE)-1,d0
    move.l #SlashRightSprite,a0
@slash_sprite_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@slash_sprite_load_loop

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
TILEMAP_SIZE: equ 40*28
TILEMAP_RAM: so.w TILEMAP_SIZE
    move.w #TILEMAP_SIZE-1,d0
    move.l #TileMap,a0
    move.l #TILEMAP_RAM,a1
@tilemap_ram_load_loop
    move.w (a0)+,(a1)+
    dbra d0,@tilemap_ram_load_loop

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
    
; So now we load our tilemap into VRAM. We're assuming the tilemap has 40*28 tiles. This is meant to be exactly
; big enough to cover the visible portion of scroll field A. However, this 40x28 area of tiles must be
; placed in a larger area of 64x32 tiles (the entire scroll field). The 40x28 area is located in the
; top-left corner of the scroll field. So we loop over each of the 64x32 tiles and check if we're in
; the 40x28 area; if so, we get the next tile of the tilemap; if not, we just output the 0 tile. We
; have an overall tile counter and separate x and y counters.
    move.w #(64*32)-1,d0
    clr.b d2 ; tile_x
    clr.b d3 ; tile_y
    move.b #40,d4 ; max_x_window
    move.b #28,d5 ; max_y_window
    move.b #64,d6 ; max_x_scroll
    move.l #TileMap,a0
@tilemap_load_loop
    cmp.b d2,d4
    ble.s @outside_window
    cmp.b d3,d5
    ble.s @outside_window
    move.w (a0)+,d1
    add.w #TILE_SET_START_INDEX,d1
    bra.s @move_into_vram
@outside_window
    clr.w d1
@move_into_vram
    move.w d1,vdp_data
    addq #1,d2
    cmp.b d2,d6
    bgt.s @samerow
    addq #1,d3 ; add 1 to y
    moveq #0,d2 ; reset x to 0
@samerow
    dbra d0,@tilemap_load_loop

; start with default/idle animation
    jsr SetLeftIdleAnim

; Now let's add a sprite!!!!!
SAMURAI_SPRITE_ADDR: equ SPRITE_TABLE_BASE_ADDR
    move.w #SAMURAI_SPRITE_ADDR,d0
    SetVramAddr d0,d1
; Then we make a sprite attribute entry. It's 8 bytes. Let's set it smack-dab in the middle.
; That means [287,239] or [%100011111,%11101111]
    move.w #%0000000011101111,vdp_data
    move.w #%0000011000000000,vdp_data
    move.w ANIM_CURRENT_INDEX,vdp_data
    move.w #%0000000100011111,vdp_data

SLASH_SPRITE_ADDR: equ SAMURAI_SPRITE_ADDR+8

; FM TEST FM TEST FM TEST
    include fm_test.asm

; MAIN PROGRAM
; ------------------------------------------------------------------------------
__main
; PSG test.
    ;jsr @test_psg

    move.w #287,CURRENT_X
    move.w #239,CURRENT_Y

LEFT_IDLE_STATE: equ 0
RIGHT_IDLE_STATE: equ 1
WALK_LEFT_STATE: equ 2
WALK_RIGHT_STATE: equ 3
PREVIOUS_ANIM_STATE: so.w 1
    move.w #LEFT_IDLE_STATE,PREVIOUS_ANIM_STATE

FACING_UP: equ 0
FACING_DOWN: equ 1
FACING_LEFT: equ 2
FACING_RIGHT: equ 3
FACING_DIRECTION: so.w 1
    move.w #FACING_LEFT,FACING_DIRECTION

SLASH_COOLDOWN_ITERS: equ 30
ITERS_TIL_CAN_SLASH: so.w 1
    move.w #0,ITERS_TIL_CAN_SLASH

ITERATIONS_PER_ANIM_FRAME: equ 20
ITERATIONS_UNTIL_NEXT_ANIM_FRAME: so.w 1
    move.w #ITERATIONS_PER_ANIM_FRAME,ITERATIONS_UNTIL_NEXT_ANIM_FRAME

loop
    GetControls d0,d1
    ;DEBUG
    move.w OR_CONTROLLER,d0
    or.w CONTROLLER,d0
    move.w d0,OR_CONTROLLER
    

    clr.w d4 ; dx = 0
    clr.w d5 ; dy = 0
    move.w #1,d3 ; velocity

    ; new anim state. default to anim facing previous direction first.
    move.w PREVIOUS_ANIM_STATE,d1
    move.w #LEFT_IDLE_STATE,d0
    cmp.w d1,d0
    beq.s .LeftIdleDefault
    move.w #WALK_LEFT_STATE,d0
    cmp.w d1,d0
    beq.s .LeftIdleDefault
    bra.s .RightIdleDefault
.LeftIdleDefault
    move.w #LEFT_IDLE_STATE,d2
    beq.s .AfterDefaultIdle
.RightIdleDefault
    move.w #RIGHT_IDLE_STATE,d2
.AfterDefaultIdle

    move.b CONTROLLER,d7
    btst.l #UP_BIT,d7
    beq.s .UpNotPressed
    sub.w d3,d5
    move.w #WALK_RIGHT_STATE,d2
    move.w #FACING_UP,FACING_DIRECTION
.UpNotPressed
    btst.l #DOWN_BIT,d7
    beq.s .DownNotPressed
    add.w d3,d5
    move.w #WALK_LEFT_STATE,d2
    move.w #FACING_DOWN,FACING_DIRECTION
.DownNotPressed
    btst.l #LEFT_BIT,d7
    beq.s .LeftNotPressed
    sub.w d3,d4
    move.w #WALK_LEFT_STATE,d2
    move.w #FACING_LEFT,FACING_DIRECTION
.LeftNotPressed
    btst.l #RIGHT_BIT,d7
    beq.s .RightNotPressed
    add.w d3,d4
    move.w #WALK_RIGHT_STATE,d2
    move.w #FACING_RIGHT,FACING_DIRECTION
.RightNotPressed
    ; TODO: figure out a way to not require d4/d5 to stay set all the way until clamping below.
    add.w CURRENT_X,d4 ; new x in d4
    add.w CURRENT_Y,d5 ; new y in d5

    cmp.w PREVIOUS_ANIM_STATE,d2
    beq.s .AfterAnimStateUpdate
    move.w #ITERATIONS_PER_ANIM_FRAME,ITERATIONS_UNTIL_NEXT_ANIM_FRAME
    move.w d2,PREVIOUS_ANIM_STATE
    cmp.w #LEFT_IDLE_STATE,d2
    bne.s .NotIdleLeft
    jsr SetLeftIdleAnim
.NotIdleLeft
    cmp.w #RIGHT_IDLE_STATE,d2
    bne.s .NotIdleRight
    jsr SetRightIdleAnim
.NotIdleRight
    cmp.w #WALK_LEFT_STATE,d2
    bne.s .NotWalkLeft
    jsr SetWalkLeftAnim
.NotWalkLeft
    cmp.w #WALK_RIGHT_STATE,d2
    bne.s .AfterAnimStateUpdate ; shouldn't happen
    jsr SetWalkRightAnim
.AfterAnimStateUpdate

    ; clamp sprite x
    move.w d4,d0
    move.w #MIN_DISPLAY_X,d1
    jsr ClampMin
    move.w #MAX_DISPLAY_X,d1
    jsr ClampMax
    move.w d0,d4

    ; clamp sprite y
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

.skipPositionUpdate

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

    ; update sprite
    move.w #SAMURAI_SPRITE_ADDR,d0
    SetVramAddr d0,d1
    move.w CURRENT_Y,vdp_data
    ; 2x3 sprite, AND with a link to the next sprite. Not sure yet how link data works,
    ; but without the 1 at the end there we won't see the next sprite.
    move.w #%0000011000000001,vdp_data
    move.w ANIM_CURRENT_INDEX,vdp_data
    move.w CURRENT_X,vdp_data

    ; SLASH
    ; move.w #SLASH_SPRITE_ADDR,d0
    ; SetVramAddr d0,d1
    move ITERS_TIL_CAN_SLASH,d0
    beq.s .AfterSlashCounter
    sub.w #1,d0
    move.w d0,ITERS_TIL_CAN_SLASH
.AfterSlashCounter
    bne.w .NoSlash ; is slash counter 0?
    move.b CONTROLLER,d0
    btst.l #A_BIT,d0
    beq.s .NoSlash
    move.w #SLASH_COOLDOWN_ITERS,ITERS_TIL_CAN_SLASH ; reset slash cooldown
    ; figure out position of slash sprite
    move.w CURRENT_X,d0
    move.w CURRENT_Y,d1
    clr.w d2 ; used for reversing sprite direction
    move.l #.SlashDirectionJumpTable,a0
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
    bra.s .AfterSlashDirection
.SlashDown
    add.w #24,d1
    bra.s .AfterSlashDirection
.SlashLeft
    sub.w #32,d0
    or.w #$0800,d2
    bra.s .AfterSlashDirection
.SlashRight
    add.w #16,d0
.AfterSlashDirection
    move.w d1,vdp_data
    move.w #%1000111000000000,vdp_data ; 4x3
    move.w #SLASH_SPRITE_TILE_START,d3
    or.w d2,d3
    move.w d3,vdp_data
    move.w d0,vdp_data
    bra.s .AfterSlash
.NoSlash
    ; clear slash sprite from VRAM
    move.w #0,vdp_data
    move.w #0,vdp_data
    move.w #0,vdp_data
    move.w #0,vdp_data
.AfterSlash


.waitNewFrame
    cmp.b #1,NEW_FRAME
    bne.s .waitNewFrame
    clr.b NEW_FRAME
    jmp     loop

; EXCEPTION AND INTERRUPT HANDLERS
; ----------------------------------------------------------------------------
    align 2 ; word-align code

ignore_handler
    rte ; return from exception (seems to restore PC)

v_interrupt_handler:
    move.b #1,NEW_FRAME
    rte

; DATA
; ----------------------------------------------------------------------------

SimplePalette:
    include art/simple_palette.asm

TileSet:
    include art/tileset.asm

TileCollisions:
    include art/tile_collisions.asm

TileMap:
    include art/tilemap.asm

SamuraiSprite:
    include art/samurai_sprite.asm

SamuraiLeft1Sprite:
    include art/samurai/left1.asm

SamuraiLeft2Sprite:
    include art/samurai/left2.asm

SamuraiRight1Sprite:
    include art/samurai/right1.asm

SamuraiRight2Sprite:
    include art/samurai/right2.asm

SlashRightSprite:
    include art/slash_sprite.asm

__end: