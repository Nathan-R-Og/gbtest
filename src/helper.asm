SECTION "Helper Routines",ROM0

DEF _VRAM_BLOCK0 EQU $8000
DEF _VRAM_BLOCK1 EQU $8800
DEF _VRAM_BLOCK2 EQU $9000
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; a - byte to fill with
; bc - size of area to fill
; hl - destination address
fill::
    inc	b
    inc	c
    jr	.skip
    .fill
    ld	[hl+],a
    .skip
    dec	c
    jr	nz,.fill
    dec	b
    jr	nz,.fill
    ret

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; bc - size
; de - destination
; hl - source address
copy::
    inc	b
    inc	c
    jr	.skip
.copy:
    ld	a,[hl+]
    ld	[de],a
    inc	de
.skip:
    dec	c
    jr	nz,.copy
    dec	b
    jr	nz,.copy
    ret

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; bc - size
; de - destination
; hl - source address
copy_offsettiles::
    push af
    inc	b
    inc	c
    jr	.skip
.copy:
    ld	a,[hl+]
    add $80
    ld	[de],a
    inc	de
.skip:
    dec	c
    jr	nz,.copy
    dec	b
    jr	nz,.copy
    ret

;-----------------
;-----------------
;sets last_input and current_input appropriately
Check_Pad:
    ;read p15 (a, b, select, start)
    ld a, P1F_GET_DPAD
    ldh [rP1], a
    ;?
    ldh a, [rP1]
    ldh a, [rP1]
    ;invert
    cpl
    ;get lower half
    and %00001111
    ;shift
    swap a
    ld b, a

    ;read p14 (up, down, left, right)
    ld a, P1F_GET_BTN
    ldh [rP1], a
    ;?
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ;invert
    cpl
    ;get lower half
    and %00001111
    ;combine with buttons
    or b
    ;store to c
    ld c, a

    ldh a, [last_input]
    ;check against current
    xor c
    and c
    ldh [current_input], a
    ;set previous to current
    ld a, c
    ldh [last_input], a

    ;reset
    ld a, P1F_GET_NONE
    ldh [rP1], a
    ret

SECTION "DMA Subroutine on ROM", ROM0

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;hard coded subroutine that can live in RAM.
;$C000 is set as space for Shadow OAM
dma_sub_start::
    ld	a, HIGH(SHADOW_OAM)
    ldh	[rDMA],a
    ; delay = 160 cycles
    ld	a,40
    .copy
    dec	a
    jr	nz,.copy
    ret
dma_sub_end::

SECTION "DMA Subroutine HRAM Space",HRAM
DMA_TRANSFER_ROUTINE: ds 10

SECTION "Shadow OAM Area", WRAM0
SHADOW_OAM: ds 40*4

