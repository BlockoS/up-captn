vgm_mpr = 3

    .zp
vgm_ptr    .ds 2
vgm_bank   .ds 1
vgm_status .ds 1

    .code
;;---------------------------------------------------------------------
; name : vgm_next_byte
; desc : Move VGM data offset to next byte and map the next bank if
;        it reaches the end of its current bank.
; in   :
; out  : 
;;---------------------------------------------------------------------    
vgm_next_byte .macro
    inc    <vgm_ptr
    bne    .l_\@
        inc    <vgm_ptr+1
        lda    <vgm_ptr+1
        cmp    #((song_addr>>8) + $20)
        bne    .l_\@
            stw    #song_addr, <vgm_ptr
            ; Map next bank
            inc    <vgm_bank
            lda    <vgm_bank
            tam    #vgm_mpr
.l_\@:
    .endm

;;---------------------------------------------------------------------
; name : vgm_map
; desc : Save mpr value and map VGM data bank
; in   : vgm_bank VGM data bank
; out  : 
;;---------------------------------------------------------------------    
vgm_map .macro
    ; Save previous bank
    tma    #vgm_mpr
    pha
    lda    <vgm_bank
    tam    #vgm_mpr
    .endm
    
;;---------------------------------------------------------------------
; name : vgm_unmap
; desc : Restore mpr used to map VGM data
; in   : 
; out  : 
;;---------------------------------------------------------------------
vgm_unmap .macro
    pla
    tam   #vgm_mpr
    .endm

;;---------------------------------------------------------------------
; name : vgm_init
; desc : Initialize vgm player
; in   :   A VGM data bank
;        _si VGM data pointer
; out  : vgm_ptr  Current VGM data pointer
;        vgm_bank Current VGM data bank
;;---------------------------------------------------------------------
vgm_init:
    sta    <vgm_bank
    stw    <_si, <vgm_ptr
    stz    <vgm_status
    rts
    
;;---------------------------------------------------------------------
; name : vgm_update
; desc : Update vgm player
; in   : vgm_status VGM player status (0 stopped, 1 running)
; out  : 
;;---------------------------------------------------------------------
vgm_update:
    vgm_map

.vgm_loop:
    lda    [vgm_ptr]
    cmp    #$b9
    bne    .vgm_check_end

    vgm_next_byte

    lda    [vgm_ptr]
    tax
   
    vgm_next_byte
   
    lda    [vgm_ptr]
    sta    $0800, X
   
    vgm_next_byte
   
    bra    .vgm_loop
   
.vgm_check_end:
    cmp    #$62
    beq    .vgm_exit
.vgm_stop:
    vgm_unmap
    lda    #song_loop_bank
    sta    <vgm_bank
    stw    #song_loop_offset, <vgm_ptr
    rts
.vgm_exit:
    vgm_next_byte
   
.vgm_end:
    vgm_unmap
    rts