_tiles_bitmask_00:
	db %0000_0000 ; 0000
	db %0000_1111 ; 0001
	db %0000_0000 ; 0010
	db %0000_1111 ; 0011
	db %0000_0000 ; 0100
	db %0000_1111 ; 0101
	db %0000_0000 ; 0110
	db %0000_1111 ; 0111
	db %0000_0000 ; 1000
	db %0000_1111 ; 1001
	db %0000_0000 ; 1010
	db %0000_1111 ; 1011

_tiles_bitmask_01:
	db %0000_0000 ; 0000
	db %0000_0000 ; 0001
	db %0000_1111 ; 0010
	db %0000_1111 ; 0011
	db %0000_0000 ; 0100
	db %0000_0000 ; 0101
	db %0000_1111 ; 0110
	db %0000_1111 ; 0111
	db %0000_0000 ; 1000
	db %0000_0000 ; 1001
	db %0000_1111 ; 1010
	db %0000_1111 ; 1011

_tiles_bitmask_02:
	db %0000_0000 ; 0000
	db %0000_0000 ; 0001
	db %0000_0000 ; 0010
	db %0000_0000 ; 0011
	db %0000_1111 ; 0100
	db %0000_1111 ; 0101
	db %0000_1111 ; 0110
	db %0000_1111 ; 0111
	db %0000_0000 ; 1000
	db %0000_0000 ; 1001
	db %0000_0000 ; 1010
	db %0000_0000 ; 1011

_tiles_bitmask_03:
	db %0000_0000 ; 0000
	db %0000_0000 ; 0001
	db %0000_0000 ; 0010
	db %0000_0000 ; 0011
	db %0000_0000 ; 0100
	db %0000_0000 ; 0101
	db %0000_0000 ; 0110
	db %0000_0000 ; 0111
	db %0000_1111 ; 1000
	db %0000_1111 ; 1001
	db %0000_1111 ; 1010
	db %0000_1111 ; 1011

_tiles_bitmask_10:
	db %0000_0000 ; 0000 
	db %1111_0000 ; 0001
	db %0000_0000 ; 0010
	db %1111_0000 ; 0011
	db %0000_0000 ; 0100
	db %1111_0000 ; 0101
	db %0000_0000 ; 0110
	db %1111_0000 ; 0111
	db %0000_0000 ; 1000
	db %1111_0000 ; 1001
	db %0000_0000 ; 1010
	db %1111_0000 ; 1011

_tiles_bitmask_11:
	db %0000_0000 ; 0000
	db %0000_0000 ; 0001
	db %1111_0000 ; 0010
	db %1111_0000 ; 0011
	db %0000_0000 ; 0100
	db %0000_0000 ; 0101
	db %1111_0000 ; 0110
	db %1111_0000 ; 0111
	db %0000_0000 ; 1000
	db %0000_0000 ; 1001
	db %1111_0000 ; 1010
	db %1111_0000 ; 1011
	
_tiles_bitmask_12:
	db %0000_0000 ; 0000
	db %0000_0000 ; 0001
	db %0000_0000 ; 0010
	db %0000_0000 ; 0011
	db %1111_0000 ; 0100
	db %1111_0000 ; 0101
	db %1111_0000 ; 0110
	db %1111_0000 ; 0111
	db %0000_0000 ; 1000
	db %0000_0000 ; 1001
	db %0000_0000 ; 1010
	db %0000_0000 ; 1011

_tiles_bitmask_13:
	db %0000_0000 ; 0000
	db %0000_0000 ; 0001
	db %0000_0000 ; 0010
	db %0000_0000 ; 0011
	db %0000_0000 ; 0100
	db %0000_0000 ; 0101
	db %0000_0000 ; 0110
	db %0000_0000 ; 0111
	db %1111_0000 ; 1000
	db %1111_0000 ; 1001
	db %1111_0000 ; 1010
	db %1111_0000 ; 1011
	
gen_4x4x12_tiles:
	; Generate tiles
	; 1. The Control register ($05)
	;    will be accessible via port $0002
	st0  #$05
	; 2. Disable background and sprite 
	;    (bit 6 & 7 = 0) and set read/write
	;    address auto-increment to 00 (bit 11-12)
	st1  #$00
	st2  #$00
	; 3. The memory address write register ($00)
    ;    will be accessible via port $0002
    st0  #$00
    ; 4. Set vram address where data will be written
    ;    BAT is at vram address $2000
	lda  <_dl
    sta  video_data_l
	lda  <_dh
    sta  video_data_h
	; 6. Map VRAM data register to port $0002
    st0  #$02
	
_tile_gen_i2:
	stz  <__tmp+2

_tile_gen_i1:

	ldx   <__tmp+2
	lda   _tiles_bitmask_10, X
	sta   <__tmp+7
	lda   _tiles_bitmask_11, X
	sta   <__tmp+8
	lda   _tiles_bitmask_12, X
	sta   <__tmp+9
	lda   _tiles_bitmask_13, X
	sta   <__tmp+10

	stz   <__tmp+1

_tile_gen_i0:

	ldx   <__tmp+1
	lda   _tiles_bitmask_00, X
	sta   <__tmp+3
	lda   _tiles_bitmask_01, X
	sta   <__tmp+4
	lda   _tiles_bitmask_02, X
	sta   <__tmp+5
	lda   _tiles_bitmask_03, X
	sta   <__tmp+6
	
	cly
	
_tile_gen_begin:
	
	lda   _tiles_bitmask_10, Y
	ora   <__tmp+3
	sta   video_data_l
	
	lda   _tiles_bitmask_11, Y
	ora   <__tmp+4
	sta   video_data_h
    sta   video_data_h
    sta   video_data_h
    sta   video_data_h
	
	lda   #%0000_1111
	ora   <__tmp+7
	sta   video_data_l
	
	lda   #%0000_1111
	ora   <__tmp+8
    sta   video_data_h
	sta   video_data_h
	sta   video_data_h
	sta   video_data_h
	
	lda   _tiles_bitmask_12, Y
	ora   <__tmp+5
	sta   video_data_l
	
	lda   _tiles_bitmask_13, Y
	ora   <__tmp+6
	sta   video_data_h
    sta   video_data_h
    sta   video_data_h
    sta   video_data_h
	
	lda   #%0000_1111
	ora   <__tmp+9
	sta   video_data_l
	
	lda   #%0000_1111
	ora   <__tmp+10
    sta   video_data_h
	sta   video_data_h
	sta   video_data_h
	sta   video_data_h
	
	iny
	cpy  <_al
	bne  _tile_gen_begin

_tile_gen_end:
	inc  <__tmp+1
	lda  <__tmp+1
	cmp  <_al
	beq  _tile_gen_i1_end
	jmp  _tile_gen_i0

_tile_gen_i1_end:
	inc  <__tmp+2
	lda  <__tmp+2
	cmp  <_al
	beq  _tile_gen_i2_end
	jmp  _tile_gen_i1

_tile_gen_i2_end:

	rts

;----------------------------------------------------------------------
; name : setup_tiles12
;
; description : 
;
; in :    A = BAT size
;		_bl = palette bank
;		_si = palette pointer
;		_al = number of colors
;		_dx = vram destination
;
setup_tiles12:
	; disable bg display
	st0    #$05
	st1    #$00
	st2    #$00
	
	; set bat size (for ""double"" buffering)
	jsr    set_bat_size
	
	; set horizontal resolution to 512
	jsr set_xres512

	; load palette
	; Generate palettes
	; Color #$FF is reserved and used for bloc D
	; 1. Map data
	jsr    map_data
	
	; 2. Set color index register
	stz    color_reg_l
	stz    color_reg_h

	; 3. Copy 15 colors and then manually set the
	;    last one to be equal to the first one
    set_ram_cpy_mode SOURCE_INC_DEST_ALT
	set_ram_cpy_args <_si, #color_data, #30
    
	cly
.palette_init:
	jsr    _ram_cpy_proc

	lda    [_si],Y
	iny
	sta    color_data_l
	lda    [_si],Y
	iny
	sta    color_data_h
    
   	cpy    #24
	bne    .palette_init	
	
	; Generate tiles
	jsr    gen_4x4x12_tiles

	; Set vram address where BAT will be written
	; 1. The memory address write register ($00)
	;    will be accessible via port $0002
	st0    #$00
	; 2. Set vram address where data will be written
	;    BAT is at vram address $0000
	st1    #$00
	st2    #$00
	
	; Initialize BAT
	; 1. Map VRAM data register to port $0002
	st0    #$02
	; 2. BAT entry is made as follows:
	;	CCCCVVVVVVVVVVVV
	;	C: palette entry
	;	V: VRAM address divided by #16
	;    Starting VRAM address is #$2000.
	;    We'll write 128*64 (ie) 8192 entries
	stz    <__tmp
	stz    <__tmp+1

	lda    <_dh
	lsr    A
	lsr    A
	lsr    A
	lsr    A
	tax
.bat_init:
	;    Write BAT entry
	;st1    #$00
	;stx    video_data_h
	st1     #low(BACKGROUND_TILE)
    st2     #high(BACKGROUND_TILE)
    
	inc   <__tmp
	bne   .bat_init
		inc    <__tmp+1
		lda    <__tmp+1
		cmp    <_dh
		bne    .bat_init
.bat_stop:

	rts

index_i1:
	db  0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121 

index_i2_lo:
	db low(   0), low( 121), low( 242), low( 363)
	db low( 484), low( 605), low( 726), low( 847)
	db low( 968), low(1089), low(1210), low(1331)

index_i2_hi:
	db high(   0), high( 121), high( 242), high( 363)
	db high( 484), high( 605), high( 726), high( 847)
	db high( 968), high(1089), high(1210), high(1331)

pal_i3:
	db $02, $12, $22, $32, $42, $52, $62, $72, $82, $92, $a2, $b2
    