INST_INX = $e8
INST_DEX = $ca

;----------------------------------------------------------------------
    .rsset _zp_fx
_x       .rs 4
;_y       .rs 4
_err     .rs 1
_dy      .rs 1

_current .rs 1
_vx      .rs 24
_vy      .rs 24

;----------------------------------------------------------------------
set_line_output .macro
    lda    #low(\1)
    sta    line.io.0
    sta    line.io.1
    sta    line.io.2
    sta    line.io.3
    lda    #high(\1)
    sta    line.io.0+1
    sta    line.io.1+1
    sta    line.io.2+1
    sta    line.io.3+1
    .endm

set_line_color_output .macro    
    lda    #low(\1)
    sta    line.col.dst.0
    sta    line.col.dst.1
    lda    #high(\1)
    sta    line.col.dst.0+1
    sta    line.col.dst.1+1
    .endm

set_line_color_source .macro
    lda    \1
    sta    line.col.src.0
    sta    line.col.src.1
    .endm
    
; [todo] Init
;   half_height 
;   data_angle  
;   data_radius 
;   data_x      
;   data_count  
;   angle       