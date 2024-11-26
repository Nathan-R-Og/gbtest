SECTION "Header",ROM0[0]
; $0000 - $003F: RST handlers.
; $0000
ret
nop
nop
nop
nop
nop
nop
nop
; $0008
ret
nop
nop
nop
nop
nop
nop
nop
; $0010
ret
nop
nop
nop
nop
nop
nop
nop
; $0018
ret
nop
nop
nop
nop
nop
nop
nop
; $0020
ret
nop
nop
nop
nop
nop
nop
nop
; $0028
ret
nop
nop
nop
nop
nop
nop
nop
; $0030
ret
nop
nop
nop
nop
nop
nop
nop
; $0038
ret
nop
nop
nop
nop
nop
nop
nop

; $0040 - $0067: Interrupt handlers.
jp draw
nop
nop
nop
nop
nop
; $0048
jp stat
nop
nop
nop
nop
nop
; $0050
jp timer
nop
nop
nop
nop
nop
; $0058
jp serial
nop
nop
nop
nop
nop
; $0060
jp joypad
nop
nop
nop
nop
nop

ds $98

; $0100 - $0103: Startup handler.
nop
jp main

; $0104 - $0133: The Nintendo Logo.
    NINTENDO_LOGO

; $0134 - $013E: The title, in upper-case letters, followed by zeroes.
db "LOOK AT HIM"
ds 0 ; padding

; $013F - $0142: The manufacturer code.
ds 4

; $0143: Gameboy Color compatibility flag.
db CART_COMPATIBLE_DMG

; $0144 - $0145: "New" Licensee Code, a two character name.
db "OK"

; $0146: Super Gameboy compatibility flag.
db CART_INDICATOR_GB

; $0147: Cartridge type. Either no ROM or MBC5 is recommended.
db CART_ROM

; $0148: Rom size.
db CART_ROM_32KB

; $0149: SRam size.
db CART_SRAM_NONE

; $014A: Destination code.
db CART_DEST_NON_JAPANESE

; $014B: Old licensee code.
; $33 indicates new license code will be used.
; $33 must be used for SGB games.
db $33
; $014C: ROM version number
db $00
; $014D: Header checksum.
; Assembler needs to patch this.
db 0
; $014E- $014F: Global checksum.
; Assembler needs to patch this.
dw 0