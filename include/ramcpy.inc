;;---------------------------------------------------------------------
; ramcpy.inc : hardware copy utilities.
;
; (c) 2012 Vincent 'MooZ' Cruz
;
; As tia, tii, tin, etc... only takes immediate values as arguments, 
; the tricks is to have the copy instruction in ram and modify the
; arguments. 
;
; LICENCE: [todo]
;;---------------------------------------------------------------------
    .zp
_ram_cpy_proc	.ds	1
_ram_cpy_src	.ds	2
_ram_cpy_dest	.ds	2
_ram_cpy_size	.ds	2
_ram_cpy_rts	.ds	1
    
    .code
;;---------------------------------------------------------------------
; Copy modes
;;---------------------------------------------------------------------
SOURCE_ALT_DEST_INC = $f3 
SOURCE_DEC_DEST_DEC = $c3 
SOURCE_INC_DEST_ALT = $e3 
SOURCE_INC_DEST_NOP = $d3 
SOURCE_INC_DEST_INC = $73 

;;---------------------------------------------------------------------
; name : init_ram_cpy
; desc : Initialize hardware copy code.
;        this basically set _ram_cpy_rts to the RTS opcode value.
; out  :
;;---------------------------------------------------------------------
init_ram_cpy .macro
    lda    #$60             ; RTS opcode value
    sta    <_ram_cpy_rts
    .endm
    
;;---------------------------------------------------------------------
; name : setup_ram_cpy_mode
; desc : Setup ram copy mode.
; in   : \1 Copy mode
; out  :
;;---------------------------------------------------------------------
set_ram_cpy_mode .macro
    lda    #\1
    sta    <_ram_cpy_proc
    .endm
    
;;---------------------------------------------------------------------
; name : setup_ram_cpy_args
; desc : Setup ram copy source, destination and length.
; in   : \1 Source (word)
;        \2 Destination (word)
;        \3 Size (word)
; out  :
;;---------------------------------------------------------------------
set_ram_cpy_args .macro
    stw    \1, <_ram_cpy_src
    stw    \2, <_ram_cpy_dest
    stw    \3, <_ram_cpy_size
    .endm