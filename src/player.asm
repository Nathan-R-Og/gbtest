SECTION "Player Input", HRAM
current_input:: ds 1 ;as of this frame
last_input:: ds 1 ;as of whenever

SECTION "Player Variables", WRAM0
PlayerX:: ds 1
PlayerX_sub:: ds 1
PlayerY:: ds 1
PlayerY_sub:: ds 1
Player_camX:: ds 1
Player_camY:: ds 1

Player_bitfield1:: ds 1
def Player_bf1_direction EQU 0
def Player_bf1_paused EQU 1

SECTION "Player", ROM0

def PlayerX_speed equ 90
def PlayerY_speed equ 90


Player::
.process:

    call Check_Pad

    ;get
    ldh a, [last_input]
    ld b, a

    bit PADB_SELECT, b
    jp nz, .while_select
    ;for dirchanges
    ld hl, Player_bitfield1
    bit PADB_LEFT, b
    call nz, .pad_left
    bit PADB_RIGHT, b
    call nz, .pad_right
    bit PADB_UP, b
    call nz, .pad_up
    bit PADB_DOWN, b
    call nz, .pad_down

    ;when not controlling camera, snap to player
    ld a, [PlayerX]
    sub (20*4)-8
    ld [Player_camX], a

    ld a, [PlayerY]
    sub (20*4)-8
    ld [Player_camY], a

    jp .end_select
    .while_select:
    bit PADB_LEFT, b
    call nz, .pad_left_select
    bit PADB_RIGHT, b
    call nz, .pad_right_select
    bit PADB_UP, b
    call nz, .pad_up_select
    bit PADB_DOWN, b
    call nz, .pad_down_select
    .end_select:

    ldh a, [current_input]
    bit PADB_START, a
    call nz, .pad_start

    ld a, [Player_camX]
    ldh [rSCX], a
    ld a, [Player_camY]
    ldh [rSCY], a

    call .sprUpdate

    ret

.pad_left_select:
    ld a, [Player_camX]
    dec a
    ld [Player_camX], a
    ret
.pad_right_select:
    ld a, [Player_camX]
    inc a
    ld [Player_camX], a
    ret
.pad_up_select:
    ld a, [Player_camY]
    dec a
    ld [Player_camY], a
    ret
.pad_down_select:
    ld a, [Player_camY]
    inc a
    ld [Player_camY], a
    ret


.pad_start:
    ;reset important registers
	xor	a
	ld	[rIF],a
	ld	[rLCDC],a


    ld hl, Player_bitfield1
    bit Player_bf1_paused, [hl]
    jp nz, .is_paused
    set Player_bf1_paused, [hl]

    ; Copy the tile data
	ld de, _VRAM_BLOCK2
	ld hl, BG_GFX2
	ld bc, BG_GFX2End - BG_GFX2
    call copy

	; Copy the tilemap
	ld de, _SCRN0
	ld hl, BG_Tiles2
	ld bc, BG_Tiles2End - BG_Tiles2
    call copy

    jp .back_to_main
    .is_paused:
    res Player_bf1_paused, [hl]

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
    .back_to_main:

    ;enable vblank (in FFFF interrupt Enable memory)
    ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_ON
	ld [rLCDC], a

    ret

.pad_left:
    ;i was originally doing dec loops for catching but
    ;apparently sub and add set h and c for this exact purpose??? awesome sauce

    ;set the direction var
    set Player_bf1_direction, [hl]

    ;calc
    ld a, [PlayerX_sub]
    sub a, PlayerX_speed
    ld [PlayerX_sub], a
    ;check if byte looped
    jr nc, .notop_l
    ;do byte 2
    ld a, [PlayerX]
    dec a
    ld [PlayerX], a
    .notop_l:
    ret
.pad_right:
    res Player_bf1_direction, [hl]
    ld a, [PlayerX_sub]
    add a, PlayerX_speed
    ld [PlayerX_sub], a
    jr nc, .notop_r
    ;if greater than $FF
    ld a, [PlayerX]
    inc a
    ld [PlayerX], a
    .notop_r:
    ret
.pad_up:
    ld a, [PlayerY_sub]
    sub a, PlayerY_speed
    ld [PlayerY_sub], a
    jr nc, .notop_u
    ;if less than 0
    ld a, [PlayerY]
    dec a
    ld [PlayerY], a
    .notop_u:
    ret
.pad_down:
    ld a, [PlayerY_sub]
    add a, PlayerY_speed
    ld [PlayerY_sub], a
    jr nc, .notop_d
    ;if greater than $FF
    ld a, [PlayerY]
    inc a
    ld [PlayerY], a
    .notop_d:
    ret

.sprUpdate
    ;TODO: clean this up. BAD
    ;a == whatever
    ;b == bitfield1
    ;c == flipper
    ;de == current xy
    ;hl == current oam
    ld a, [Player_bitfield1]
    ld b, a

    ld hl, SHADOW_OAM
    ;init y
    ld e, 2
    .sprUpdate_loop_y
    ;init x
    ld d, 2
    ld c, 1
    .sprUpdate_loop_x
    push de

    ;use e as an offset
    ld a,[PlayerY]
    ;offset bycamy
    push hl
    ld hl, Player_camY
    sub [hl]
    pop hl

    rlc e
    rlc e
    rlc e
    add a, e
    ld [hl+],a ; y attr

    ;use d as an offset
    ld a,[PlayerX]
    ;offset bycamx
    push hl
    ld hl, Player_camX
    sub [hl]
    pop hl

    rlc d
    rlc d
    rlc d
    add a, d
    ld [hl+],a ; x attr

    ;restore
    pop de
    push de

    bit Player_bf1_direction, b

    ;use d and e as a tileid
    ld a, d
    jp z, .set_tid
    ;left offset
    sub a, c
    dec c
    dec c
    .set_tid:
    rlc e
    add a, e
    sub a, 3
    ld [hl+],a;t

    ld a, [Player_bitfield1]
    and a, %00000001
    rrc a
    rrc a
    rrc a
    ld [hl+],a;f

    ;restore
    pop de

    ;-=1, loop if > 0
    dec d
    jp nz, .sprUpdate_loop_x

    ;-=1, loop if > 0
    dec e
    jp nz, .sprUpdate_loop_y


    ;bye bye
    ret