;;---------------------------------------------------------------------
; PSG informations
PSG_CHAN_COUNT  .equ $06 ; channel count

;;---------------------------------------------------------------------
; PSG control register bit masks
PSG_CTRL_CHAN_ON        .equ %1000_0000 ; channel on (1), off(0)
PSG_CTRL_WRITE_RESET    .equ %0100_0000 ; reset waveform write index to 0
PSG_CTRL_DDA_ON         .equ %1100_0000 ; dda output on(1), off(0)
PSG_CTRL_VOL_MASK       .equ %0001_1111 ; channel volume
PSG_CTRL_FULL_VOLUME    .equ %0011_1111 ; channel maximum volume (bit 5 is unused)

;;---------------------------------------------------------------------
; name : set_channel
; desc : set psg channel
; in   : \1 channel
;;---------------------------------------------------------------------
    .macro set_channel 
    lda    \1
    sta    psg_ch
	.endm

;;---------------------------------------------------------------------
; name : set_global_volume
; desc : set global volume
; in   : \1 volume
;;---------------------------------------------------------------------
    .macro set_global_volume
    lda    \1
    sta    psg_mainvol
	.endm
    
;;---------------------------------------------------------------------
; name : set_channel_volume
; desc : set channel volume and activate it
; in   : \1 channel
;        \2 volume
;;---------------------------------------------------------------------
    .macro set_channel_volume
    lda    \1
    sta    psg_ctrl
.if (\?1 = ARG_IMMED)
    lda    #(PSG_CTRL_CHAN_ON | \2)
.else
    lda    \2
    ora    #PSG_CTRL_CHAN_ON
.endif
    sta    psg_ch
    .endm

;;---------------------------------------------------------------------
; name : disable_channel
; desc : disable channel, dda out and set volume to 0
;;---------------------------------------------------------------------
    .macro disable_channel
    stz    psg_ctrl
    .endm
