    .include "system.inc"

	.include "equ.inc"
	.include "macro.inc"
	.include "vdc.inc"
	.include "psg.inc"
    .include "ramcpy.inc"
        
	.include "interrupts.asm"
    .include "gfx.asm"
	.include "math.asm"

    .include "gentiles12.asm"
    .include "vgm.asm"

    .include "effect.inc"
    .include "line.inc"

LOOP_FRAME_COUNT=512
TXT_SCROLL_Y=282
BASE_BACKGROUND_COLOR=0
FONT_RCY=178
FONT_COLOR_INDEX=13
BACKGROUND_TILE=$A732
MESH_FRAME_COUNT=10*LOOP_FRAME_COUNT+32
ROTOZOOM_FRAME_COUNT=587
TUNNEL_FRAME_COUNT=546

    .zp
__tmp		.ds 4
__ptr		.ds 4    
tmp         .ds 1
scanline    .ds 2

object_idx  .ds 1

font_x    .ds 2
font_y    .ds 2
font_addr .ds 2
font_char .ds 1
txt_ptr   .ds 2

frame_counter .ds 3

fxloopcnt .ds 2
    .bss
x_scroll   .ds 256
y_scroll   .ds 256

span_col .ds 256
span_pos .ds 256

    .code
;----------------------------------------------------------------------
; Main program
;----------------------------------------------------------------------
main:
    lda    #%11111001
    sta    irq_disable
    stz    irq_status
	
	stz    <irq_m
    
    jsr    math_init
    
    vec_off #VSYNC
    vec_off #HSYNC

    
    stw    #song_addr, <_si
    lda    #song_bank
    jsr    vgm_init

    smb0   <vgm_status

	lda    #3
	ldx    #0
	sta    psgport, X
		
	lda    #%01_000000
	ldx    #4
	sta    psgport, X
	
	lda    #%00_000000
	sta    psgport, X
    
    jsr    vgm_update
    
    ; map rotozoom code
	lda    #EFFECT_CODE_BANK
	tam    #EFFECT_CODE_PAGE
    
main_loop:
;    ; run rotozoom
	jsr    rotozoom_init
    cli
    
    stw    #ROTOZOOM_FRAME_COUNT, <fxloopcnt

.fx0_loop:
;    lda    #0
;    jsr    wait_vsync
    
    jsr    rotozoom_update
    
    dec    <fxloopcnt
    bne    .fx0_loop
    dec    <fxloopcnt+1
    bne    .fx0_loop;

    ; run tunnel
    
    jsr    tunnel_init
    
    cli
    stw    #TUNNEL_FRAME_COUNT, <fxloopcnt
 
.fx1_loop:
    lda    #0
    jsr    wait_vsync
    
    jsr    tunnel_update
        
    dec    <fxloopcnt
    bne    .fx1_loop
    dec    <fxloopcnt+1
    bne    .fx1_loop
 
.next_fx: 
    sei
    ; run raster meshs
    jsr    set_xres256
    lda	   #BGMAP_SIZE_64x64
	jsr	   set_bat_size

    ; clean BAT
    st0    #$00
    st1    #$00
    st2    #$00
    
    st0    #$02
    ldy    bat_height
.bat_clean_y:
    ldx    bat_width
.bat_clean_x:
    stw    #$0260, video_data
    dex
    bne    .bat_clean_x
    dey
    bne    .bat_clean_y
    
    lda    #RAMCODE_BANK
    tam    #RAMCODE_MPR
    jsr    draw_mesh_init
    
    ; Load font data
    lda    #TXT_BANK
    tam    #TXT_MPR
    st0    #$00
    st1    #$00
    st2    #$21
    
    st0    #$02
    tia    font_start, $0002, font_end-font_start

    ; Scroller init
    ldx    #00
    lda    #36
    jsr    calc_vram_addr
    stw    <_di, <font_addr
    
    lda   #low(footer_scroll_hsync)
    sta   mesh_footer.lo
    lda   #high(footer_scroll_hsync)
    sta   mesh_footer.hi
    
    lda    #$ff
    sta    <font_x
    stz    <font_x+1
    
    lda    #low(TXT_SCROLL_Y)
    sta    <font_y
    lda    #high(TXT_SCROLL_Y)
    sta    <font_y+1
    
    stz    <font_char
    
    ; set palette entry
    lda    #low(FONT_COLOR_INDEX)
    sta    color_reg_l
    lda    #high(FONT_COLOR_INDEX)
    sta    color_reg_h

    lda    #$ff
    sta    color_data_l
    lda    #$01
    sta    color_data_h

    stw    #txt_data_start, <txt_ptr
    
    stw    #(LOOP_FRAME_COUNT-1), <frame_counter
    stz    <frame_counter+2
   
    stw    #MESH_FRAME_COUNT, <fxloopcnt
    
    cli
    
.fx2_loop:
    ; [todo] footer scroll
    incw   <font_x
        
    lda    <font_x
    and    #$07
    bne    .no_char
        vreg   #VDC_WRITE
        inc    <font_char
        lda    <font_char
        and    #63
        clc
        adc    <font_addr
        sta    video_data_l
        lda    <font_addr+1
        adc    #$00
        sta    video_data_h

        vreg   #$02
        lda    [txt_ptr]
        clc
        adc    #$10
        sta    video_data_l
        st2    #$02
        
        incw   <txt_ptr
        lda    <txt_ptr
        cmp    #low(txt_data_end)
        bne    .no_txt_reset
        lda    <txt_ptr+1
        cmp    #high(txt_data_end)
        bne    .no_txt_reset
            stw    #txt_data_start, <txt_ptr
.no_txt_reset:
.no_char:
    
    incw   <frame_counter
    
    lda    <frame_counter
    cmp    #low(LOOP_FRAME_COUNT)
    bne    .no_mesh_update
    lda    <frame_counter+1
    cmp    #high(LOOP_FRAME_COUNT)
    bne    .no_mesh_update
        stz    <frame_counter
        stz    <frame_counter+1
        
        ldx    <object_idx
        lda    mesh_first, X
        sta    mesh_list_first
        lda    mesh_last, X
        sta    mesh_list_last
        
        lda    <object_idx
        inc    A
        and    #$3
        sta    <object_idx
.no_mesh_update:
     
    jsr    draw_mesh_list

    inc    <frame_counter+2
    ldx    <frame_counter+2
    clc
    lda    #FONT_RCY
    adc    txt_scroll_y, X 
    sta    mesh_footer.rcy
        
    lda    #$00
    jsr    wait_vsync
    
    dec    <fxloopcnt
    bne    .continue
    dec    <fxloopcnt+1
    bne    .continue
.reset:
    jmp   main_loop
.continue:
    jmp    .fx2_loop
    
footer_scroll_hsync:
    lda    <frame_counter+2
    lsr    A
    and    #31
    tax
    stz    color_reg_l
    stz    color_reg_h
    lda    footer_gradient.lo,X
    sta    color_data_l
    lda    footer_gradient.hi,X
    sta    color_data_h

    st0    #7
    lda    <font_x
    sta    video_data_l
    lda    <font_x+1
    sta    video_data_h
    
    st0    #8
    lda    <font_y
    sta    video_data_l
    lda    <font_y+1
    sta    video_data_h
    
    ldy    #(HSYNC << 1)
    lda    #low(last_footer)
    sta    user_jmptbl,Y
    iny
    lda    #high(last_footer)
    sta    user_jmptbl,Y

    st0    #6
    clc
    lda    mesh_scanline.lo
    adc    #20
    sta    video_data_l
    lda    mesh_scanline.hi
    adc    #$00
    sta    video_data_h
    
    stz    irq_status
    irq1_end

last_footer:
    stz    color_reg_l
    stz    color_reg_h
    lda    #low(BASE_BACKGROUND_COLOR)
    sta    color_data_l
    lda    #high(BASE_BACKGROUND_COLOR)
    sta    color_data_h

    stz    irq_status
    irq1_end
  
dummy_gradient.lo:
    .db $ff, $f7, $b7, $6f, $27, $df, $97, $4f, $07, $06, $05, $04, $03, $02, $01, $09
    .db $01, $02, $03, $04, $05, $06, $07, $0f, $4f, $97, $df, $27, $6f, $b7, $f7, $ff
    
dummy_gradient.hi:
    .db $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01

    .include "data/footer_gradient.inc"
    
    align_org 256
    .include "rotxTable.inc"
    
    .include "ramcode/line.asm"
    
    .bank    TXT_BANK
    .org     (TXT_MPR<<13)
    .include "data/txt_datastorm2014.inc"
    .include "data/mesh.inc"
    .include "data/txt_scroll_y.inc"
   
font:
font_start:
    .incbin "data/quick_font_2.pce"
font_end:
    
    .data
    .bank ROTOZOOM_DATA_BANK
    .org  ROTOZOOM_DATA_PAGE<<13
roto_data:
	.incbin "data/uprough.dat"

    .code
    .bank EFFECT_CODE_BANK
    .org  EFFECT_CODE_PAGE<<13
    .include "tunnel.asm"
    .include "rotozoom.asm"
palette:
    .incbin "data/uprough.pal"

	.data
	.bank TUNNEL_DATA_BANK
	.org (TUNNEL_DATA_PAGE<<13)
radiusTable:
	.incbin "data/radiusTbl.bin"
	
	.data
	.bank TUNNEL_DATA_BANK+1
	.org ((TUNNEL_DATA_PAGE+1)<<13)
atan2Table:
	.incbin "data/atan2Tbl.bin"

    .include "data/datastorm2014/song.inc"
    
