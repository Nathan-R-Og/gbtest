/*
Simple Sprite and background display
DMA Shadow OAM routine
*/

SECTION "Game",ROM0[$150]


WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
    ret

main:
    di
    ld sp, $E000

    call WaitVBlank

    ;reset important registers
	xor	a
	ld	[rIF],a
    ;these get set later
	ld	[rIE],a
    ld  [rSTAT], a
	ld	[rLYC],a
	ld	[rLCDC],a
	ld	[rSCX],a
	ld	[rSCY],a

    ; clear ram (fill with a which is 0 here)
	ld	hl,_RAM
    ; watch out for stack ;)
	ld	bc,$2000-2
	call fill

    ; clear hram
    ; a = 0, b = 0 here, so let's save a byte and 4 cycles (ld c,$80 - 2/8 vs ld bc,$80 - 3/12)
	ld	hl,_HRAM
	ld	c, l
	call	fill

    ; clear vram
	ld	hl,_VRAM
    ; c should be already 00
	ld	b,$18
	call	fill

    ;copy the DMA routine to HRAM
    ld de, DMA_TRANSFER_ROUTINE
    ld hl, dma_sub_start
    ld bc, dma_sub_end-dma_sub_start
    call copy

    ;palette
    ld	a, %11100100
	ld	[rBGP],a
	ld	[rOBP0],a
	ld	[rOBP1],a

    ;Background
    ; Copy the tile data
	ld de, _VRAM_BLOCK2
	ld hl, BG_GFX
	ld bc, BG_GFXEnd - BG_GFX
    call copy

	; Copy the tilemap
	ld de, _SCRN0
	ld hl, BG_Tiles
	ld bc, BG_TilesEnd - BG_Tiles
    call copy

    ;Window
    ; Copy the tile data
	ld de, _VRAM_BLOCK1
	ld hl, Hud_GFX
	ld bc, Hud_GFXEnd - Hud_GFX
    call copy

	; Copy the tilemap
	ld de, _SCRN1
	ld hl, Hud_Tiles
	ld bc, Hud_TilesEnd - Hud_Tiles
    call copy_offsettiles

    ;Objects
    ; Copy sprite data
    ld de, _VRAM_BLOCK0
    ld hl, Sprite_GFX
    ld bc, Sprite_GFXEnd-Sprite_GFX
    call copy

    ;enable vblank interrupts
    ;enable stat interrupts
	ld a, IEF_VBLANK | IEF_STAT
	ld [rIE], a

    ; Tile IDs for...           Block 0     Block 1     Block 2
    ;                           $8000–87FF  $8800–8FFF  $9000–97FF
    ;Objects                    0–127       128–255     —
    ;BG/Win, if  LCDCF_BLK21    0–127       128–255     —
    ;BG/Win, if !LCDCF_BLK21    —           128–255     0–127
    ;LCDCF_BLK21 only actually dictates where the FIRST set of id's are.
    ;the second set will, no matter what, always be block 1

    ;enable vblank (in FFFF interrupt Enable memory)
    ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_ON
	ld [rLCDC], a

    ;enable ly interrupting
    ld a, STATF_LYC
    ld [rSTAT], a

    ;move rwx properly lol
    ;TODO: why is there a line
    ld a, 7
    ld [rWX], a

    ;initial
    ei


gameloop:
    ;turn on the window layer to draw the main part
    ld hl, rLCDC
    set LCDCB_WINON, [hl]

    ;yeah
    call WaitVBlank

    ;awesome
    call Player.process

    ;cool
    call DMA_TRANSFER_ROUTINE
    jp gameloop

;TODO: find out how this gets ran exactly
;i know it gets ran every lyc but there is a lot more going on
;NOTE: reti NEEDED!!! if not at least some kind of ret
;i think my game crashed because it was jumping too much LOL do not jump out
stat:
    ;schedule another one
    ld  a, 16
	ld	[rLYC],a

    ;turn off the window layer now that the essentials are drawn
    ld hl, rLCDC
    res LCDCB_WINON, [hl]

;default reti
timer:
serial:
joypad:
draw:
    ;ei isnt technically needed but its good practice
    ei
    reti

Sprite_GFX: INCBIN "build_artifacts/sprite.2bpp"
Sprite_GFXEnd:

BG_GFX: INCBIN "build_artifacts/bg.2bpp"
BG_GFXEnd:

BG_Tiles: INCBIN "gfx/bg_tiles.bin"
BG_TilesEnd:

BG_GFX2: INCBIN "build_artifacts/bg2.2bpp"
BG_GFX2End:

BG_Tiles2: INCBIN "gfx/bg2_tiles.bin"
BG_Tiles2End:

Hud_GFX: INCBIN "build_artifacts/hud.2bpp"
Hud_GFXEnd:

Hud_Tiles: INCBIN "gfx/hud_tiles.bin"
Hud_TilesEnd: