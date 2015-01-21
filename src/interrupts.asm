;----------------------------------------------------
; interupts.asm : interruption vectors
;
; (c) 2007 Vincent 'MooZ' Cruz
;
; Interruption vectors for each of the pce
; interruptions.
;
; LICENCE: not my fault if anything burns
;

;;---------------------------------------------------------------------
; desc : hardware memory transfer mode
;;---------------------------------------------------------------------
MEMCPY_SRC_ALT_DEST_INC  = $F3
MEMCPY_SRC_INC_DEST_ALT  = $E3
MEMCPY_SRC_INC_DEST_INC  = $73
MEMCPY_SRC_INC_DEST_NONE = $D3
MEMCPY_SRC_DEC_DEST_DEC  = $C3

;;---------------------------------------------------------------------
; desc : hardware memory transfer instruction helper
;;---------------------------------------------------------------------
    .bss
_hrdw_memcpy_mode .ds 1
_hrdw_memcpy_src  .ds 2
_hrdw_memcpy_dst  .ds 2
_hrdw_memcpy_len  .ds 2 
_hrdw_memcpy_rts  .ds 1

hrdw_memcpy = _hrdw_memcpy_mode

;----------------------------------------------------------------------
; name : set_vec
;
; description : Set user interrupt functions
;
; warning : A,X and Y will be overwritten
;		    Interrupts are disabled. You'll need to enable them by hands
;
; in : \1 interrupt to hook
;	   \2 user function to be called when interrupt will be triggered
set_vec .macro
	sei						; disable interrupts
	
	lda		\1
	asl		A				; compute offset in user function table
	tax
	lda		#low(\2)
	sta		user_jmptbl,X	; store low byte
	inx
	lda		#high(\2)
	sta		user_jmptbl,X
		
	.endm

;----------------------------------------------------------------------
; name : vec_on
;
; description : Enable interrupt vector
;
; warning : SOFT_RESET must not be used.
;			Bit 4 of irq_m is used to tell that the user vsync hook
;			must be run.  
;			Bit 5 is for standard vsync hook.
;			Bit 6 and 7 are the same things but for hsync.
;			Standard and user [h|v]sync hooks are not mutually
;			exclusive. If both bits are set, first the standard handler
;			will be called then the user one.
;
; in : \1 Vector to enable
;
vec_on .macro
	.if (\1 = 5)
	smb		#6, <irq_m		; user hsync
	.else
	smb		#\1, <irq_m
	.endif
	.endm

;----------------------------------------------------------------------
; name : vec_off
;
; description : Disable interrupt vector
;
; warning : same as vec_on (for irq_m bit value)
;
; in : \1 Vector to disable
vec_off .macro
	.if (\1 = 5)
	rmb		#6, <irq_m		; user hsync
	.else
	rmb		\1, <irq_m
	.endif
	.endm
	
;----------------------------------------------------------------------
; name : irq1_end
;
; description : End of IRQ1 interrupt
;
; warning : Must be performed at the end of each IRQ1 vector!
;
irq1_end	.macro 
								; restore registers
    lda    <vdc_reg
    sta    video_reg
    
    ply
    plx
    pla

    rti

	.endm

;----------------------------------------------------------------------
; Interrupt vectors names
;----------------------------------------------------------------------
IRQ2            = 0
IRQ1            = 1
TIMER           = 2
NMI             = 3
VSYNC           = 4
HSYNC           = 5
SOFT_RESET      = 6

;----------------------------------------------------------------------
; Vector table
;----------------------------------------------------------------------
	.data
	.bank 0        
        .org $FFF6

        .dw irq_2                    ; irq 2
        .dw irq_1                    ; irq 1
        .dw irq_timer                ; timer
        .dw irq_nmi                  ; nmi
        .dw irq_reset                ; reset

	.code
	.bank 0
		.org $E000

        vdcInitTable:
;       reg  low  hi
    .db $07, $00, $00 ; background x-scroll register
    .db $08, $00, $00 ; background y-scroll register
    .db $09, $10, $00 ; background map size
    .db $0A, $02, $02 ; horizontal period register
    .db $0B, $1F, $04 ; horizontal display register
    .db $0C, $02, $17 ; vertical sync register
    .db $0D, $DF, $00 ; vertical display register
    .db $0E, $0C, $00 ; vertical display position end register

;----------------------------------------------------------------------
; name : irq_reset
;
; description : Code called on reset. This is the
;               BOOT code (what's first called when
;               you switched the pcengine on for
;               example).
irq_reset:
 	sei							; disable interrupts
    csh							; select the 7.16 MHz clock
    cld 						; clear the decimal flag
    ldx    #$FF					; initialize the stack pointer
    txs
    lda    #$FF					; map the I/O bank in the first page
    tam    #0
    lda    #$F8					; and the RAM bank in the second page
    tam    #1
    stz    $2000				; clear all the RAM
    tii    $2000,$2001,$1FFF

    lda    #%11111101
    sta    irq_disable
    stz    irq_status

    init_ram_cpy                ; setup hardware copy ram function
    set_ram_cpy_mode SOURCE_INC_DEST_ALT
    
    lda    #1
    sta    timer_ctrl			; disable timer

    st0    #$05					; set vdc control register
    st1    #$00					; disable vdc interupts
    st2    #$00					; sprite and bg are disabled

    							; initialize vdc
    lda    #low(vdcInitTable)
    sta    <_si
    lda    #high(vdcInitTable)
    sta    <_si+1

    lda    #$60
    sta    _hrdw_memcpy_rts

    cly
.l0:
        lda    [_si],Y
        sta    videoport
        iny
        lda    [_si],Y
        sta    video_data_l
        iny
        lda    [_si],Y
        sta    video_data_h
        iny
        cpy    #24
        bne    .l0

    							; disable sound
    lda    #$06					; pcengine has 6 channels
.l1
		dec    A				; chose channel
        sta    psg_ch
        stz    psg_ctrl			; disable channel
        bne    .l1

	; Initialize user interrupt vectors with default values
	lda		#low(_vsync_handler)
	sta		vsync_hook
	sta		hsync_hook
		
	lda		#high(_vsync_handler)
	sta		vsync_hook+1
	sta		hsync_hook+1
	
	lda		#low(_rti)
	sta		irq1_jmp
	sta		irq2_jmp
	sta		timer_jmp	
	sta		nmi_jmp
	lda		#high(_rti)
	sta		irq1_jmp+1
	sta		irq2_jmp+1
	sta		timer_jmp+1	
	sta		nmi_jmp+1

	lda   #$1F					; init joypad
	sta   joyena

	jsr    main					; jump to main entry point


; this will be used as default user interrupt vectors
_rti:
	rti

_rts:
	rts
	
;----------------------------------------------------------------------
; name : irq_timer
;
; description : CPU timer interrupt handler
;
irq_timer:
	pha
	phx
	phy

    bbs2	<irq_m, _user_timer

    stz $1403

	ply
	plx
	pla
	rti

_user_timer:
	jmp		[timer_jmp]

;----------------------------------------------------------------------
; name : irq_nmi
;
; description :
;
irq_nmi:
	bbr3	<irq_m, _user_nmi
	rti
_user_nmi:
	jmp   [nmi_jmp]

;----------------------------------------------------------------------
; name : irq_1
;
; description : VDC interrupt handler
;
irq_1:

    pha							; save registers
    phx
    phy

    lda   video_reg				; get VDC status register
    sta  <vdc_sr
    							; vsync and hsync are mixed
    							; the only way to separate them is to
    							; check the value of the vdc status
    							; register

.vsync:                         ; vsync interrupt
    							; if bit 5 is set we are on vsync
    bbr5   <vdc_sr,.hsync

	inc   irq_cnt				; update irq counter (for wait_vsync)

    st0    #5					; update display control (bg/sp)
    lda    <vdc_crl				; vdc control register
    sta    video_data_l
    stz    video_data_h

    jmp    [vsync_hook]

.hsync
    bbr2    <vdc_sr, .exit	    ; check if hsync bit is set in vdc 

    jmp    [hsync_hook]

.exit:

								; restore registers
    lda    <vdc_reg
    sta    video_reg
    
    ply
    plx
    pla

    rti

;----------------------------------------------------------------------
; name : irq_2
;
; description :
;
irq_2:
	bbs0	<irq_m, _usr_irq2
    rti
_usr_irq2:
	jmp		[irq2_jmp]
	
;----------------------------------------------------------------------
; name : _hsync_handler
;        _vsync_handler
;
; description : default irq vector for hsync and vsync
;
_hsync_handler:
_vsync_handler:

	irq1_end
