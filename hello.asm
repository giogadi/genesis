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
NEW_FRAME: equ RAM_BASE_ADDR
; SACBRLDU
CONTROLLER: equ NEW_FRAME+2
CURRENT_X: equ CONTROLLER+2
CURRENT_Y: equ CURRENT_X+2

MIN_DISPLAY_X: equ 128
MAX_DISPLAY_X: equ 447
MIN_DISPLAY_Y: equ 128
MAX_DISPLAY_Y: equ 351

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
    TILE_INDEX: equ 1
    move.l #(TILE_SIZE*TILE_INDEX),d0
    SetVramAddr d0,d1
    
    move #(2*24)-1,d0
    move.l #SamuraiSprite,a0
@samurai_sprite_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@samurai_sprite_load_loop

    move #(8*30)-1,d0
    move.l #TileSet,a0
@tileset_load_loop
    move.l (a0)+,vdp_data
    dbra d0,@tileset_load_loop

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
    
; So now we load our tilemap. We're assuming the tilemap has 40*28 tiles. This is meant to be exactly
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
    add.w #7,d1
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

; Now let's add a sprite!!!!!
    move.w #SPRITE_TABLE_BASE_ADDR,d0
    SetVramAddr d0,d1
; Then we make a sprite attribute entry. It's 8 bytes. Let's set it smack-dab in the middle.
; That means [287,239] or [%100011111,%11101111]
    move.w #%0000000011101111,vdp_data
    move.w #%0000011000000000,vdp_data
    move.w #%0000000000000001,vdp_data
    move.w #%0000000100011111,vdp_data

; FM TEST FM TEST FM TEST
    include fm_test.asm

; MAIN PROGRAM
; ------------------------------------------------------------------------------
__main
    move.w  #0,d0
    move.w #VDPREG_INCR|$02,(vdp_control) ; autoincrement vram by 2 bytes
    move.l  #$C0000003,vdp_control ; Set up VDP to write to CRAM address $0000

; PSG test.
    ;jsr @test_psg

    ; set VRAM increment to 6 to go directly from V to H
    move.w  #VDPREG_INCR|$06,vdp_control 

    move.w #287,CURRENT_X
    move.w #239,CURRENT_Y
loop
    GetControls d7,d3

    clr.w d4 ; dx = 0
    clr.w d5 ; dy = 0
    move.w #2,d3 ; velocity

    move.b CONTROLLER,d7
    moveq #1,d6 ; up mask
    and.b d7,d6 ; is up pressed?
    beq.s .UpNotPressed
    sub.w d3,d5
.UpNotPressed
    lsr.b #1,d7 ; now down is lsb
    moveq #1,d6 ; down mask
    and.b d7,d6 ; is down pressed?
    beq.s .DownNotPressed
    add.w d3,d5
.DownNotPressed
    lsr.b #1,d7 ; now left is lsb
    moveq #1,d6 ; left mask
    and.b d7,d6 ; is left pressed?
    beq.s .LeftNotPressed
    sub.w d3,d4
.LeftNotPressed
    lsr.b #1,d7 ; now right is lsb
    moveq #1,d6 ; right mask
    and.b d7,d6 ; is right pressed?
    beq.s .RightNotPressed
    add.w d3,d4
.RightNotPressed
    add.w d4,CURRENT_X ; update current_x
    add.w d5,CURRENT_Y ; update current_y

    ; clamp sprite x
    move.w CURRENT_X,d0
    move.w #MIN_DISPLAY_X,d1
    move.w #MAX_DISPLAY_X,d2
    jsr Clamp
    move.w d0,CURRENT_X

    ; clamp sprite y
    move.w CURRENT_Y,d0
    move.w #MIN_DISPLAY_Y,d1
    move.w #MAX_DISPLAY_Y,d2
    jsr Clamp
    move.w d0,CURRENT_Y
    
    ; update sprite position
    move.w #SPRITE_TABLE_BASE_ADDR,d0
    SetVramAddr d0,d1
    move.w CURRENT_Y,vdp_data
    move.w CURRENT_X,vdp_data

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

TileMap:
    include art/tilemap.asm

SamuraiSprite:
    include art/samurai_sprite.asm

__end: