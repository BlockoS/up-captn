	.zp
__radius_0 .ds 2
__radius_1 .ds 2
__atan2_0  .ds 2
__atan2_1  .ds 2

; TODO : find a better place
_py .ds 1
_u .ds 1
_du	.ds 1

	.code
; TODO add sx and sy => u = radius[pos+sx]+du ; v = atan2[pos+sy]+dv
; TODO radius/atan2 table width (atm 64, make it larger!) 
;----------------------------------------------------------------------
; tunnel (2)
; TODO : atan2Table, radiusTable, du, dv 
;----------------------------------------------------------------------
tunnel_init:
    ; set vdc control register
	vreg  #5
	; disable bg, enable sprite, vertical blanking and scanline interrupt
	stz   <vdc_crl
	st1   #$00
    st2   #$00

	; initialize tiles
	lda    #bank(tunnelPalette)	
	sta    <_bl
	stw    #tunnelPalette, <_si
	lda    #11
	sta    <_al
	stz    <_dl
	lda    #$20
	sta    <_dh
	lda    #BGMAP_SIZE_64x64
	jsr    setup_tiles12
	
    jsr    vgm_update
    
	; map data
	lda    #TUNNEL_DATA_BANK
	tam    #TUNNEL_DATA_PAGE
	lda    #(TUNNEL_DATA_BANK+1)
	tam    #(TUNNEL_DATA_PAGE+1)
	
	jsr set_xres512

	; initialize base BG coordinates
	lda    #low(128)
	sta    <_bat_x
	lda    #high(256)
	sta    <_bat_x+1

	stz    <_bat_y
	stz    <_bat_y+1
	
	lda    #$08
	sta    <_addr
    
	; set scroll
	stz    <_x
	stz    <_x+1
	stz    <_y
	stz    <_y+1
	
    ; set countdown
	lda    #low(TUNNEL_FRAME_COUNT)
	sta    <_counter
	lda    #high(TUNNEL_FRAME_COUNT)
	sta    <_counter+1
    
	; Disable interrupts
	vec_off #VSYNC
	vec_off #HSYNC

	; set and enable vdc interrupts
	set_vec #VSYNC,rotoVsyncProc
	vec_on  #VSYNC
	set_vec #HSYNC,rotoHsyncProc
	vec_on  #HSYNC
	
	lda    #$06 ; 10 MHz dot clock. 
	sta    color_ctrl
	
	; set vdc control register
	vreg  #5
	; enable bg, enable sprite, vertical blanking and scanline interrupt
	lda   #%11001100
	sta    <vdc_crl
	sta   video_data_l
	st2   #$00
    rts
    
tunnel_update:
	; Set BAT address then swap it
	stz    <_bat_ptr
	lda    <_addr
	sta    <_bat_ptr+1
	eor    #$08
	sta    <_addr

	; Same for scrool coordinates
	inc    <_du
	
	lda    #32
	sta    <_py

	stw    #(radiusTable), <__radius_0
    stw    #(radiusTable+128), <__radius_1
    stw    #(atan2Table), <__atan2_0
	stw    #(atan2Table+128), <__atan2_1
	
.tunnel_y:
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

		cly

.tunnel_x:
		; C0
		lda  [__radius_0], Y
		clc
		adc  <_du
		lsr  A
		lsr  A
		and  #$0f
		sta  <_u

		lda  [__atan2_0], Y	
		clc
		adc  <_du
		asl  A
		asl  A
		asl  A
		and  #$f0
		ora  <_u
		tax
		;ora  [__atan2_0], Y
		;tax
		
		lda  tunnelTexture, X
		sta  <_c

		; C2
		lda  [__radius_1], Y
		clc
		adc  <_du
		lsr  A
		lsr  A
		and  #$0f
		sta  <_u

		lda  [__atan2_1], Y
		clc
		adc  <_du
		asl  A
		asl  A
		asl  A
		and  #$f0
		ora  <_u
		tax
		;ora  [__atan2_1], Y
		;tax
		
		lda  tunnelTexture, X
		sta  <_c+2

		iny
		
		; C1
		lda  [__radius_0], Y
		clc
		adc  <_du
		lsr  A
		lsr  A
		and  #$0f
		sta  <_u

		lda  [__atan2_0], Y
		clc
		adc  <_du
		asl  A
		asl  A
		asl  A
		and  #$f0
		ora  <_u
		tax
		;ora  [__atan2_0], Y
		;tax
		
		lda  tunnelTexture, X
		sta  <_c+1
		
		; C3
		lda  [__radius_1], Y
		clc
		adc  <_du
		lsr  A
		lsr  A
		and  #$0f
		sta  <_u

		lda  [__atan2_1], Y
		clc
		adc  <_du
		asl  A
		asl  A
		asl  A
		and  #$f0
		ora  <_u
		tax
;		ora  [__atan2_1], Y
;		tax
		
		lda  tunnelTexture, X
		sta  <_c+3
		
        iny
        
		; [X:A] += _c + (_c[1] * 12) + (_c[2] * 144)
		vreg  #$02
	
		; TODO fix it
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
.loop_end:

		cpy    #64
		beq    .tunnel_next_y
			jmp    .tunnel_x
.tunnel_next_y

	inc    <__radius_0+1
	inc    <__radius_1+1

	inc    <__atan2_0+1
	inc    <__atan2_1+1

	dec    <_py
	beq    .tunnel_loop_end
	jmp    .tunnel_y
.tunnel_loop_end:

    ; go for next "buffer"
	lda    <_bat_y+1
	eor    #1
	sta    <_bat_y+1

	rts
     
tunnelTexture:
    .incbin "data/tunnel.dat"
tunnelPalette:    
    .incbin "data/tunnel.pal"
;	.db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
;	.db 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
;	.db 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2
;	.db 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 2, 2, 2, 2, 2, 2, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 2, 3, 3, 3, 3, 2, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 2, 3, 0, 4, 3, 2, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 2, 3, 4, 0, 3, 2, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 2, 3, 3, 3, 3, 2, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 2, 2, 2, 2, 2, 2, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 4, 3, 2
;	.db 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 3, 2
;	.db 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 2
;	.db 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
;	.db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    
; for history : add 128 to a 16bits word
;	lda    <__atan2_0
;	bpl    .l2
;	inc    <__atan2_0+1
;.l2:
;	eor    #128
;	sta    <__atan2_0
	