    ; [todo] separate init, hsync/vsync routines from the effect loop
    ;        in order to have banks containing only loop codes
    ;
    .bss
    ; [todo] do the same thing that's been done for zp (.rsset and all)
csTblLo .ds 256
csTblHi .ds 256

snTblLo .ds 256
snTblHi .ds 256

    .rsset _zp_fx
    ; [todo] reduce/rename
_x             .rs    2
_y             .rs    4
_bat_x         .rs    2
_bat_y         .rs    2
_bat_ptr       .rs    2
_rx            .rs    2
_ry            .rs    2
_addr          .rs    2
_angle         .rs    1
_zoom          .rs    1
_u0            .rs    2
_v0            .rs    2
_sn            .rs    2
_cs            .rs    2
_sx            .rs    2
_sy            .rs    2
_u1	           .rs    2
_v1            .rs    2
_i             .rs    1
_j             .rs    1
_counter       .rs    2
_c             .rs    4

    .code
;----------------------------------------------------------------------
; Unrolled X Bat setup
;----------------------------------------------------------------------   
roto_x_unrolled_1 .macro
	; v0 -= sn;
	sec
	lda    <_v0
	sbc    <_sn
	sta    <_v0
	lda    <_v0+1
	sbc    <_sn+1
	sta    <_v0+1
	 
	; u0 += cs
	clc
	lda    <_u0
	adc    <_cs
	sta    <_u0
	lda    <_u0+1
	adc    <_cs+1
	sta    <_u0+1
	
    ; c0
	clc
	adc    #low(roto_data)
	sta    <__ptr
	lda    <_v0+1
	and    #63
	adc    #high(roto_data)
	sta    <__ptr+1
	lda    [__ptr]
	sta    <_c

	; v1 -= sn;
	sec
	lda    <_v1
	sbc    <_sn
	sta    <_v1
	lda    <_v1+1
	sbc    <_sn+1
	sta    <_v1+1
	
	; u1 += cs
	clc
	lda    <_u1
	adc    <_cs
	sta    <_u1
	lda    <_u1+1
	adc    <_cs+1
	sta    <_u1+1
	
	; c2
	clc
	adc    #low(roto_data)
	sta    <__ptr
	lda    <_v1+1
	and    #63
	adc    #high(roto_data)
	sta    <__ptr+1
	lda    [__ptr]
	sta    <_c+2

	; v0 -= sn;
	sec
	lda    <_v0
	sbc    <_sn
	sta    <_v0
	lda    <_v0+1
	sbc    <_sn+1
	sta    <_v0+1
	    
	; u0 += cs
	clc
	lda    <_u0
	adc    <_cs
	sta    <_u0
	lda    <_u0+1
	adc    <_cs+1
	sta    <_u0+1
	
	; c1
	clc
	adc    #low(roto_data)
	sta    <__ptr
	lda    <_v0+1
	and    #63
  	adc    #high(roto_data)
	sta    <__ptr+1
	lda    [__ptr]
	sta    <_c+1

	; v1 -= sn;
	sec
	lda    <_v1
	sbc    <_sn
	sta    <_v1
	lda    <_v1+1
	sbc    <_sn+1
	sta    <_v1+1
	
	; u1 += cs
	clc
	lda    <_u1
	adc    <_cs
	sta    <_u1
	lda    <_u1+1
	adc    <_cs+1
	sta    <_u1+1

	; c3 (palette number)
	clc
	adc    #low(roto_data)
	sta    <__ptr
	lda    <_v1+1
	and    #63
	adc    #high(roto_data)
	sta    <__ptr+1
	lda    [__ptr]
	sta    <_c+3
  
	; Write to vram
	; Map VRAM data register to port $0002
	vreg   #$02
    clc
    ldx   <_c+1
    lda   index_i1, X
    adc   <_c
    ldx   <_c+2
    adc   index_i2_lo, X
    sta   video_data_l
    
    lda   index_i2_hi, X
    ldx   <_c+3
    adc   pal_i3, X
    sta   video_data_h
    .endm
 
roto_x_unrolled_4 .macro
    roto_x_unrolled_1
    roto_x_unrolled_1
    roto_x_unrolled_1
    roto_x_unrolled_1
    .endm

roto_x_unrolled_32 .macro
    roto_x_unrolled_4
    roto_x_unrolled_4
    roto_x_unrolled_4
    roto_x_unrolled_4
    roto_x_unrolled_4
    roto_x_unrolled_4
    roto_x_unrolled_4
    roto_x_unrolled_4
    .endm
    
;----------------------------------------------------------------------
; Initialize rotozoom effect
;----------------------------------------------------------------------
rotozoom_init:    
    ; set vdc control register
	vreg  #5
	; disable bg, sprite, vertical blanking and scanline interrupt
	stz   <vdc_crl
	st1   #$00
    st2   #$00
    
	; initialize tiles
	lda    #bank(palette)	
	sta    <_bl
	stw    #palette, <_si
	lda    #11
	sta    <_al
	stz    <_dl
	lda    #$20
	sta    <_dh
	lda    #BGMAP_SIZE_64x64
	jsr    setup_tiles12
		
	; initialize base BG coordinates
	lda    #low(128)
	sta    <_bat_x
	lda    #high(256)
	sta    <_bat_x+1

	stz    <_bat_y
	stz    <_bat_y+1
	
	; set scroll
	stz    <_x
	stz    <_x+1
	stz    <_y
	stz    <_y+1
	
	stz    <_angle

	lda    #$08
	sta    <_addr

	; map data
	lda    #ROTOZOOM_DATA_BANK
	tam    #ROTOZOOM_DATA_PAGE
	lda    #(ROTOZOOM_DATA_BANK+1)
	tam    #(ROTOZOOM_DATA_PAGE+1)

	; set countdown
	lda    #low(ROTOZOOM_FRAME_COUNT)
	sta    <_counter
	lda    #high(ROTOZOOM_FRAME_COUNT)
	sta    <_counter+1

    ; Disable interrupts
	vec_off #VSYNC
	vec_off #HSYNC
    
	; set and enable vdc interrupts;
	set_vec #VSYNC,rotoVsyncProc
	vec_on  #VSYNC
	set_vec #HSYNC,rotoHsyncProc
	vec_on  #HSYNC
	
	lda    #$06 ; 10 MHz dot clock. 
	sta    color_ctrl
	
	; set vdc control register
	vreg  #5
	; enable bg, disable sprite, enable vertical blanking and scanline interrupt
	lda   #%10001100
	sta    <vdc_crl
	sta   video_data_l
	st2   #$00

    jmp   rotoGenerateTable
    
;----------------------------------------------------------------------
; Rotozoom update
;----------------------------------------------------------------------
rotozoom_update:	
	ldx    <_angle
 
    lda    csTblLo, X
    sta    <_cs
    lda    csTblHi, X
    sta    <_cs+1
    
    lda    snTblLo, X
    sta    <_sn
    lda    snTblHi, X
	sta    <_sn+1
    
	; Code
	clx
	lda    <_angle
	sta    <_rx 
	stz    <_rx+1
	inc    <_angle
	inc    <_angle
	
	stz    <_ry
	stz    <_ry+1

	; Set BAT address then swap it

	stz    <_bat_ptr
	lda    <_addr
	sta    <_bat_ptr+1
	eor    #$08
	sta    <_addr
 
	lda    #33
	sta    <_j

_roto_y_test:
	vreg   #$00
	clc
	lda    <_bat_ptr
	sta    video_data_l
	adc    #64
	sta    <_bat_ptr
	lda    <_bat_ptr+1
	sta    video_data_h
	adc    #0
	sta    <_bat_ptr+1
    
	dec    <_j
	bne    _roto_y_begin
	jmp    _roto_y_end
_roto_y_begin:

	lda    <_rx
	sta    <_u0   ; u0 = x  (low)
	clc        
	adc    <_sn   ; x += sn (low)
	sta    <_u1   ; u1 = x  (low)
	tax
	
	lda    <_rx+1
	sta    <_u0+1 ; u0 = x  (high)
	adc    <_sn+1 ; x += sn (high)
	sta    <_u1+1 ; u1 = x  (high)
	
	sec
	sax
	adc    <_sn
	sta    <_rx
	sax
	adc    <_sn+1
	sta    <_rx+1 ; x += sn
	
	lda    <_ry
	sta    <_v0   ; v0 = y  (low)
	clc        
	adc    <_cs   ; y += cs (low)
	sta	   <_v1   ; v1 = y  (low)
	tax
	
	lda    <_ry+1
	sta    <_v0+1 ; v0 = y  (high)
	adc    <_cs+1 ; y += cs (high)
	sta    <_v1+1 ; v1 = y  (high)
	
	clc
	sax
	adc    <_cs
	sta    <_ry
	sax
	adc    <_cs+1
	sta    <_ry+1 ; ry += cs

_roto_x_begin:
    roto_x_unrolled_32
_roto_x_end:

	jmp    _roto_y_test
_roto_y_end:

	; go for next "buffer"
	lda    <_bat_y+1
	eor    #1
	sta    <_bat_y+1
	
    rts

;----------------------------------------------------------------------
; Generate trajectory
;----------------------------------------------------------------------
rotoGenerateTable:
    stz   <_angle
.l0:
    ; zoom = 16 + ((128 + cos[angle]) >> 1)
	clc
	ldx    <_angle
	lda    cosTable,X
	tay
	adc    #128
	lsr    A
	clc
	adc    #16
	sta    <_zoom
	
	; cs = (zoom * cos[angle]) >> 4    
	jsr    fastmul
	cpy    #$80
	bcc    .r0
		sec
		sbc    <_zoom
.r0:
	stx    <_cs
    
	lsr    A
	ror    <_cs
	lsr    A
	ror    <_cs
	lsr    A
	ror    <_cs
	lsr    A
	ror    <_cs
	cpy    #$80
	bcc    .r1
	ora    #$f0
.r1:
	sta    <_cs+1

    ldy    <_angle
    sta    csTblHi, Y    
    lda    <_cs
    sta    csTblLo, Y    
    
	; sn = (zoom * sin[angle]) >> 4
	ldx    <_angle
	ldy    sinTable,X

	lda    <_zoom
	jsr    fastmul
	cpy    #$80
	bcc    .r2
		sec
		sbc    <_zoom
.r2:
	stx    <_sn

	lsr    A
	ror    <_sn
	lsr    A
	ror    <_sn
	lsr    A
	ror    <_sn
	lsr    A
	ror    <_sn
	cpy    #$80
	bcc    .r3
	ora    #$f0
.r3:
	sta    <_sn+1
    
    ldy    <_angle
    sta    snTblHi, Y 
    lda    <_sn
    sta    snTblLo, Y    
    
    inc    <_angle
    bne    .l0
    
    rts
    
;----------------------------------------------------------------------
; HSYNC (rotozoom)
rotoHsyncProc:
	
	lda <scanline+1
	bne .l0
	lda <scanline
	cmp #(118+64);(190)
	bne .l0
		lda    #low(-4)
		sta    <_y+2
		lda    #high(-4)
		sta    <_y+3
;		stz    <_y+2
;		stz    <_y+3
.l0:

	; set x scroll
	st0    #7
	lda    <_x
	sta    video_data_l
	lda    <_x+1
	sta    video_data_h

	; set y scroll
	st0   #8
	; y_scroll += 2
	clc
	lda    <_y
	adc    <_y+2
	sta    video_data_l
	sta    <_y
	lda    <_y+1
	adc    <_y+3
	sta    <_y+1
	sta    video_data_h
		
	; jump to next 2 scanline
	st0    #6
	clc
	lda    <scanline
	adc    #$02
	sta    video_data_l
	sta    <scanline
	lda    <scanline+1
	adc    #$00
	sta    video_data_h
	sta    <scanline+1

    stz    irq_status
	irq1_end
    
;----------------------------------------------------------------------
; VSYNC (rotozoom)
rotoVsyncProc:
		
	st0    #6				; restart the scanline counter on the first
	lda    #$40				; line
	sta    video_data_l
	sta    <scanline
	stz    video_data_h
	stz    <scanline+1

	; set x scroll
	st0    #7
	lda    <_bat_x
	sta    <_x
	sta    video_data_l
	lda    <_bat_x+1
	sta    <_x+1
	sta    video_data_h
	
	st0    #8
	lda    <_bat_y
	sta    <_y
	sta    video_data_l
	lda    <_bat_y+1
	sta    <_y+1
	sta    video_data_h
	
	lda    #low(4)
	sta    <_y+2
	stz    <_y+3
	
    jsr    vgm_update
    
	irq1_end
    
;----------------------------------------------------------------------
; Data:
;----------------------------------------------------------------------

