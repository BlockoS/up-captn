    .bank RAMCODE_BANK
    .org (RAMCODE_MPR<<13)
    .code 
;----------------------------------------------------------------------
; Initialize effect
draw_mesh_init:
    ; set vdc control register
	vreg  #5
	; disable bg, sprite, vertical blanking and scanline interrupt
	stz   <vdc_crl
	st1   #$00
    st2   #$00
    
    ; reset scroll coordinates
    st0    #$07
    st1    #$00
    st2    #$00
    
    st1    #$08
    st1    #$00
    st2    #$00
    
    ; setup pattern (vram tiles + BAT)
    stw    #$2000, <_si
    stw    #$0000, <_ax
    lda    #00
    sta    <_cl
    lda    #200
    sta    <_ch
    stz    <_bl
    jsr    draw_cube_pattern
    
    ; precompute scroll coordinates w/r span width
    lda    #00
    sta    <_cl
    lda    #200
    sta    <_ch
    lda    #$ff
    sta    <_al
    sta    <_ah
    lda    #128
    sta    <_bl
    jsr    compute_cube_scroll_coord
  
    ; set palette entry
    lda    #2
    sta    color_reg_l
    lda    #0
    sta    color_reg_h

    lda    #$ff
    sta    color_data_l
    lda    #$01
    sta    color_data_h
    
    ; copy code to VRAM    
    tii    RAMCODE_SRC, RAMCODE_BASE, ramcode_end-ramcode_start

    ; set output
    set_line_output        span_pos
    set_line_color_output  span_col

    stz    angle
    
	; set and enable vdc interrupts;
	set_vec #VSYNC,mesh_vsync_handler
	vec_on  #VSYNC
	set_vec #HSYNC,mesh_hsync_handler
	vec_on  #HSYNC
	
	lda    #$00
	sta    color_ctrl
	
	; set vdc control register
	vreg  #5
	; enable bg, vertical blanking and scanline interrupt and disable sprites
	lda   #%10001100
	sta    <vdc_crl
	sta   video_data_l
	st2   #$00

    cli
    lda    #$00
    jmp    wait_vsync

;;---------------------------------------------------------------------
; name : draw_cube_pattern
; desc : draw horizontal lines for cube pattern
; in   : _si vram address
;        _al X bat coordinate
;        _ah Y bat coordinate
;        _cl min width 
;        _ch max width
;        _bl palette to use
; out  :
;;---------------------------------------------------------------------
draw_cube_pattern:
    ; Adjust _cl to the lowest multiple of 8
    lda    <_cl
    lsr    A
    lsr    A
    lsr    A
    sta    <_cl
    
    ; Adjust _ch to the highest multiple of 8
    lda    <_ch
    clc
    adc    #$07
    lsr    A
    lsr    A
    lsr    A
    sta    <_ch
    
    ; Set vram write pointer
    _set_vram_addr #VDC_WRITE, <_si
    vreg   #$02

    ; We are filling plane #1 (this will be the color at palette index #2)
    st1    #$00

    st2    #$ff
    st2    #$ff
    st2    #$ff
    st2    #$ff
    st2    #$ff
    st2    #$ff
    st2    #$ff
    st2    #$ff

    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    
    st2    #$00
    st2    #$80
    st2    #$C0
    st2    #$E0
    st2    #$F0
    st2    #$F8
    st2    #$FC
    st2    #$FE

    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    
    ; Bat value is (_bl<<12) | (_si>>4)
    lda    <_bl
    lsr    A
    ror    <_si+1
    ror    <_si
    lsr    A
    ror    <_si+1
    ror    <_si
    lsr    A
    ror    <_si+1
    ror    <_si
    lsr    A
    ror    <_si+1
    ror    <_si
    
    lda    <_ah
    ldx    <_al
    ; Compute VRAM address and stores it into _di
	jsr    calc_vram_addr
    
    ; This will setup the BAT.
    ; It will create lines using the 2 tiles previously generated.
.l0:
    _set_vram_addr VDC_WRITE, <_di
    vreg   #$02

    ldx    <_si
    ldy    <_si+1

    lda    <_cl
    beq    .l2
.l1:
        stx    video_data_l ; vram = addr | pal
        sty    video_data_h ; this is the "plain tile"
    dec    A
    bne    .l1              ; while(A != 0)
.l2:
    inx
    stx    video_data_l     ; vram = (addr+1) | pal
    sty    video_data_h     ; this is the tile with the lines of decreasing width
    
    lda    bat_width         ;   jump to next bat line
    clc
    adc    <_di
    sta    <_di
    lda    <_di+1
    adc    #0
    sta    <_di+1

    inc    <_cl
    lda    <_cl
    cmp    <_ch
    bcc    .l0
    beq    .l0              ; while(_cl <= _ch)
    
    rts

;;---------------------------------------------------------------------
; name : compute_cube_scroll_coord
; desc : Compute X and Y scroll coordinate
; in   : _cl min width 
;        _ch max width
;        _al X bat coordinate
;        _ah Y bat coordinate
;        _bl half screen width
; out  :
;;---------------------------------------------------------------------
compute_cube_scroll_coord:  
    lda    <_al
    clc
    adc    <_bl
    sta    <_al
    
    ldy    <_cl
.l0:
    tya
    clc
    adc    <_al
    sta    x_scroll, y

    tya
    asl    A
    clc
    adc    <_ah
    sta    y_scroll, y
    
    iny
    cpy    <_ch
    bcc    .l0
    beq    .l0
    
    rts
    
;----------------------------------------------------------------------
; RAM code start
    .org RAMCODE_BASE
    .code

ramcode_start:
            
;----------------------------------------------------------------------
; Bresenham line drawing
draw_line:
            lda    <_y+1            ; _dy = y1 - y0
            sta    .y_end+1
            sec
            sbc    <_y
            sta    <_dy

            ldx    #INST_INX        ; xdir = +1 (inx)
            lda    <_x+1            ; _dx = x1 - x0
            sta    .x_end+1
            sec
            sbc    <_x
            bcs    .positive
.negative:                          ; if(_dx < 0)
                eor    #$ff         ; {
                adc    #$01         ;     _dx = -_dx
                ldx    #INST_DEX    ;     xdir = -1 (dex)
.positive:                          ; }
            stx    .sx.0            ; store xdir at the appropriate places
            stx    .sx.1
        
            ldx    <_x
            ldy    <_y
        
            cmp    <_dy
            bcc    .steep
.flat:
            sta    .dx.0+1
            lsr    A
            sta    <_err            ; _err = _dx >> 1
            lda    <_dy
            sta    .dy.0+1
.l0:                                ; for(x=x0; x<x1; x++)
                                    ; {
                txa                 ;     setup y scroll position0
.dst.0:         cmp    $3200, Y     ;     if(x < scroll[y]) ignore it
                bcc    .nop.0
.dst.1:         sta    $3200, Y
.col.src.0:     lda    #$00         ;       set color
.col.dst.0:     sta    $3300, Y
.nop.0:        
                lda    <_err        ;     _err -= _dy
                sec
.dy.0:          sbc    #$00
                bcs    .no_yinc     ;     if _err < 0
.dx.0:              adc    #$00     ;         _err += dx
.sy.0:              iny             ;         y += 1
.no_yinc:   
                sta    <_err
.sx.0:          inx                 ;     x += xdir
.x_end:         cpx    #$00
                bne    .l0          ; }
                rts
        
.steep:
            sta    .dx.1+1
            lda    <_dy
            sta    .dy.1+1
            lsr    A
            sta    <_err            ; _err = _dy >> 1
.l1:                                ; for(y=y0; y<y1; y++)
                                    ; {
                txa                 ;     setup y scroll position0
.dst.2:         cmp    $3200, Y     ;     if(x < scroll[y]) ignore it
                bcc    .nop.1
.dst.3:         sta    $3200, Y
.col.src.1:     lda    #$00         ;       set color
.col.dst.1:     sta    $3300, Y
.nop.1:            
                lda    <_err        ;     _err -= dx
                sec
.dx.1:          sbc    #$00
                bcs    .no_xinc     ;     if _err < 0
.dy.1:              adc    #$00     ;         _err += dy
.sx.1:              inx             ;         x += 1
.no_xinc:
                sta    <_err
.sy.1:          iny                 ;     y += ydir
.y_end:         cpy    #$00
                bne    .l1          ; }
.end:

line.io.0 = .dst.0+1
line.io.1 = .dst.1+1
line.io.2 = .dst.2+1
line.io.3 = .dst.3+1

line.col.src.0 = .col.src.0+1
line.col.src.1 = .col.src.1+1
line.col.dst.0 = .col.dst.0+1
line.col.dst.1 = .col.dst.1+1

                rts

mulTable_0=mulTable
mulTable_1=mulTable

mulTable_2=mulTabHi0
mulTable_3=mulTabHi0+$100
        
;----------------------------------------------------------------------
; Draw mesh
draw_mesh:
                ; First update vertices
                clx
.update_vertices.0:
                ; y = angle + mesh_angle[current]
.data_angle:    lda    mesh_angle, X
                clc
.angle:         adc    #$00
                tay
                
                ; Store cos and sin for later multiplication.
                lda    cosTable_small, Y
                sta    .cs0+1
                eor    #$ff
                inc    A
                sta    .cs1+1
                
                lda    sinTable_small, Y
                sta    .sn0+1
                eor    #$ff
                inc    A
                sta    .sn1+1
                
                ; y = r * sn
.data_radius:   ldy    mesh_radius, X
                sec
.sn0:           lda    mulTable_0, Y
.sn1:           sbc    mulTable_1, Y
                sta    .y+1
        
                ; z = r * cs
                sec
.cs0:           lda    mulTable_0, Y
.cs1:           sbc    mulTable_1, Y
                tay
                
                ; compute f/z
                lda    divTable, Y
                sta    .x0+1
                sta    .y0+1
                eor    #$ff
                inc    A
                sta    .x1+1
                sta    .y1+1
                
                ; x' = x*A    
.data_x:        ldy    mesh_x, X
                sec
.x0:            lda    mulTable_2, Y
.x1:            sbc    mulTable_3, Y
                sta    <_vx, X
                
                ; y' = y*A
.y:             ldy    #$00
                sec
.y0:            lda    mulTable_0, Y
.y1:            sbc    mulTable_1, Y
                sta    .dy+1
            
.hy:            lda    #110
                sec
.dy:            sbc    #$00
                sta    <_vy, X

                inx
.point_count:   cpx    #12
                bne    .update_vertices.0
                
half_height  = .hy+1
data_angle   = .data_angle+1
data_radius  = .data_radius+1
data_x       = .data_x+1
data_count   = .point_count+1
angle        = .angle+1

            ; Then "fill" quads
.draw_loop:
.index.0:   ldx    #$00
            lda    <_vx, X
            sta    <_x
            lda    <_vy, X
            sta    <_y
            
.angle.0:   lda    mesh_angle, X
            
.index.1:   ldx    #$00
            stx    .index.0+1
            
            clc
.angle.1:   adc    mesh_angle, X
            ror    A
            clc
            adc    angle
            tay
            
            lda    <_vx, X
            sta    <_x+1
            lda    <_vy, X
            sta    <_y+1
            
            inc    .index.1+1

            lda    <_y
            cmp    <_y+1
            bcs    .culling
                lda    cosTable, Y
                ;lsr    A
                lsr    A
                lsr    A
                lsr    A
                
                sta    line.col.src.0
                sta    line.col.src.1
                jsr    draw_line
.culling:

            lda    .index.1+1
.count:     cmp    #$00
            bne    .draw_loop
            
mesh_vertex_index.0 = .index.0+1
mesh_vertex_index.1 = .index.1+1
mesh_vertex_count   = .count+1
mesh_angle_src.0    = .angle.0+1
mesh_angle_src.1    = .angle.1+1

            rts
;----------------------------------------------------------------------
; Draw mesh list
draw_mesh_list:
.first:     lda   #$00
            sta   .idx+1
            
.draw_loop:
.idx:           ldx    #$00
                lda    mesh_point_count, X
                sta    mesh_vertex_count  
                sta    data_count    
                dec    A
                sta    mesh_vertex_index.0
                stz    mesh_vertex_index.1
                
                lda    mesh_angle_ptr.lo, X
                sta    data_angle
                sta    mesh_angle_src.0 
                sta    mesh_angle_src.1         
                lda    mesh_angle_ptr.hi, X
                sta    data_angle+1
                sta    mesh_angle_src.0+1
                sta    mesh_angle_src.1+1         
                
                lda    mesh_radius_ptr.lo, X
                sta    data_radius
                lda    mesh_radius_ptr.hi, X
                sta    data_radius+1
                
                jsr    draw_mesh
            
            inc    .idx+1
            lda    .idx+1
.last:      cmp    #$04
            bne    .draw_loop
            
            inc    angle
            
mesh_list_first = .first+1
mesh_list_last  = .last+1
            
            rts
            
;----------------------------------------------------------------------
; VSYNC handler
mesh_vsync_handler:    	
                lda    <vdc_reg
                sta    video_reg
                
                ldy    #(HSYNC << 1)
                lda    #low(mesh_hsync_handler)
                sta    user_jmptbl,Y
                iny
                lda    #high(mesh_hsync_handler)
                sta    user_jmptbl,Y
                
                stz    color_reg_l
                stz    color_reg_h
                lda    #low(BASE_BACKGROUND_COLOR)
                sta    color_data_l
                lda    #high(BASE_BACKGROUND_COLOR)
                sta    color_data_h

                
                st0    #8
                st1    #$00
                st2    #$01
                
                st0    #6				; restart the scanline counter on the first
                lda    #$40				; line
                sta    video_data_l
                sta    mesh_scanline.lo
                stz    video_data_h
                stz    mesh_scanline.hi
                
                stz    mesh_line_offset

                jsr    vgm_update

                irq1_end

;----------------------------------------------------------------------
; HSYNC handler
mesh_hsync_handler:
                inc    mesh_scanline.lo
                bne    .no_inc
                    inc    mesh_scanline.hi
.no_inc:

.offset:        ldx    #$00
.footer.rcy:    cpx    #180
                bne    .l0
                    ldy    #(HSYNC << 1)
.footer.lo:         lda    #low(.end)
                    sta    user_jmptbl,Y
                    iny
.footer.hi:         lda    #high(.end)
                    sta    user_jmptbl,Y
.l0:
                inc    .offset+1
                lda    span_pos, X
                stz    span_pos, X
                tay
                
                lda    (span_col-1), X      ; [todo] duh! :(
                stz    (span_col-1), X
                tax
                lda    #2 
                sta    color_reg_l
                stz    color_reg_h
                lda    dummy_gradient.lo, X
                sta    color_data_l
                lda    dummy_gradient.hi, X
                sta    color_data_h
                
                st0    #7
                lda    x_scroll, Y
                sta    video_data_l
                st2     #$01
                ;clc
                ;adc    #$ff
                ;sta    video_data_l
                ;cla
                ;adc    #$00
                ;sta    video_data_h
                
                st0    #8
                lda    y_scroll, Y
                sta    video_data_l
                st2    #$00
                                
                st0    #6
.scanline.lo:   lda    #$00
                sta    video_data_l
.scanline.hi:   lda    #$00
                sta    video_data_h

.end:           stz    irq_status
                irq1_end

mesh_line_offset = .offset+1
mesh_scanline.lo = .scanline.lo+1
mesh_scanline.hi = .scanline.hi+1
mesh_footer.rcy  = .footer.rcy+1
mesh_footer.lo   = .footer.lo+1
mesh_footer.hi   = .footer.hi+1

ramcode_end:
