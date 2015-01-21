;----------------------------------------------------------------------
; Effects bank
;----------------------------------------------------------------------
EFFECT_CODE_BANK = 1
EFFECT_CODE_PAGE = 2

ROTOZOOM_DATA_BANK = 3
ROTOZOOM_DATA_PAGE = 5

TUNNEL_DATA_BANK     = 7
TUNNEL_DATA_PAGE     = 5

TXT_BANK = 6
TXT_MPR  = 5

;----------------------------------------------------------------------
;
;----------------------------------------------------------------------
RAMCODE_BANK = 5
RAMCODE_BASE = $3000
RAMCODE_MPR  = 6
RAMCODE_SRC  = (RAMCODE_MPR << 13) + (RAMCODE_BASE - $2000)

;----------------------------------------------------------------------
; ZP variables declaration
;----------------------------------------------------------------------
_zp_fx = $2060

;----------------------------------------------------------------------
; name : checker_load_pal
;
; description : load the corresponding palette 
;
; in :	X	palette to load
;
;;;;checker_load_pal .macro
;;;;	; Set data pointer
;;;;	lda    checker_pal_ptr,X
;;;;	sta    <__ptr
;;;;	inx
;;;;	lda    checker_pal_ptr,X
;;;;	sta    <__ptr+1
;;;;	
;;;;	; Initialize palete
;;;;	; 1. Set color index register
;;;;	stz    color_reg_l
;;;;	stz    color_reg_h
;;;;	
;;;;	; 2. Copy colors
;;;;	cly
;;;;.l\@:
		;;;;lda    [__ptr],Y
		;;;;sta    color_data_l
		;;;;iny
		;;;;lda    [__ptr],Y
		;;;;sta    color_data_h
		;;;;iny
;;;;		
		;;;;cpy    #$10
	;;;;bne    .l\@
;;;;	
;;;;	.endm
;;;;

;----------------------------------------------------------------------
brutal_clean_8 .macro
    stz    \1
    stz    \1+1
    stz    \1+2
    stz    \1+3
    stz    \1+4
    stz    \1+5
    stz    \1+6
    stz    \1+7
    .endm
    
brutal_clean_64 .macro
    brutal_clean_8 \1
    brutal_clean_8 \1+8
    brutal_clean_8 \1+16
    brutal_clean_8 \1+24
    brutal_clean_8 \1+32
    brutal_clean_8 \1+40
    brutal_clean_8 \1+48
    brutal_clean_8 \1+56
    .endm

brutal_clean_256 .macro
    brutal_clean_64 \1
    brutal_clean_64 \1+64
    brutal_clean_64 \1+128
    brutal_clean_64 \1+192
    .endm
