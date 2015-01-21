; [todo] review code
; [todo] load_vram_1bpp set plane 2 to 1?

;----------------------------------------------------
; gfx.asm : graphic routines
;
; (c) 2007 Vincent 'MooZ' Cruz
;
; This is a set of function to manipulate
; palettes, sprites, and background.
;
; LICENCE: [todo]
;
	.bss
; BAT informations
bat_width  .ds 2
bat_height .ds 1
bat_hmask  .ds 1
bat_vmask  .ds 1

; Map coords
mapbat_bottom   .ds 1
mapbat_top      .ds 1
mapbat_top_base .ds 2

; Screen dimension
scr_width  .ds 1
scr_height .ds 1

VDC_WRITE .equ 0
VDC_READ  .equ 1

        .code
;----------------------------------------------------------------------
; name : map_data
;
; description : Map the pointer passed as argument
;               to banks 3-4 ($6000-$9FFF) and save
;               previous bank values to _bx (_bl,_bh).
;
; Warning: Don't forget to call unmapData when you
;          are done or else the old bank values will
;          be lost.
;
; in:  _BL = data bank
;      _SI = data address
;
; out: _BX = old banks
;      _SI = remapped data address
;
map_data:
  ldx    _bl
  ; Save current map banking
  tma    #3
  sta    <_bl
  tma    #4
  sta    <_bh
  ; Map new banks
  txa
  tam   #3
  inc   A
  tam   #4
  ; Remap data address to page 3
  lda   <_si+1
  and   #$1f
  ora   #$60
  sta   <_si+1
  rts

;----------------------------------------------------------------------
; name : unmap_data
;
; description : Restored previously saved bank mapping
;               to banks 3-4 ($6000-$9FFF).
;
; in:  _BX = saved data banks
;
unmap_data:
  lda    <_bl
  tam    #3
  lda    <_bh
  tam    #4
  rts

;----------------------------------------------------------------------
; name :  remap_data
;
; description : Check if the banks needs to be set to
;               the next 8kb
;
; in: _si = Current address to be remapped if nedded
;     _bp = Bank
remap_data:
  lda    <_bp
  bne    .l1
  ; The pointer crossed the 8kb boundary?
  lda    <_si+1
  bpl    .l1
  ; So _si is using mpr #5, move it back to mpr #4
  sub    #$20
  sta    <_si+1
  ; mpr #3 = mpr #4
  tma    #4
  tam    #3
  ; Set mpr #4 to the next 8kb
  inc    A
  tam    #4
.l1:
  rts

;----------------------------------------------------------------------
; name : _set_vram_addr
;
; description : Define a scroll window
;
; in :	\1    mode (VDC_READ, VDC_WRITE)
;       \2    vram address
;
_set_vram_addr .macro
  vreg   \1
  .if (\?2 = ARG_IMMED)
  st1    #low(\2)
  st2    #high(\2)
  .else
  lda    LOW_BYTE \2
  sta    video_data_l
  lda    HIGH_BYTE \2
  sta    video_data_h
  .endif
  .endm
  
;----------------------------------------------------------------------
; name : set_write
;
; description: set the VDC VRAM write pointer
;
; in :  _DI = VRAM location
;
set_write:
  _set_vram_addr VDC_WRITE, <_di
  vreg   #$02
  rts

;----------------------------------------------------------------------
; name : calc_vram_addr
;
; description : calculate VRAM address
;
; in :    X = x coordinates
;         A = y     "
;
; out:  _DI = VRAM location
;
calc_vram_addr:
	phx
	and   bat_vmask
	stz   <_di
	ldx   bat_width
	cpx   #64
	beq   .s64
	cpx   #128
	beq   .s128
	; --
.s32:	lsr   A
	ror   <_di
	; --
.s64:	lsr   A
	ror   <_di
	; --
.s128:	lsr   A
	ror   <_di
	sta   <_di+1
	; --
	pla
	and   bat_hmask
	ora   <_di
	sta   <_di
	rts

;----------------------------------------------------------------------
; name : load_palette, load_palette_ex
;
; description : Initialize a palette in VCE with the
;               data passed as argument.
;               load_palette_ex maps data.
;
; in: _AL = index of the first sub-palette (0-31)
;     _SI = address of data
;     _CL = number of sub-palette to copy
;     _BL = data bank (load_palette_ex only)
load_palette_ex:
  ; Map data
  jsr    map_data
load_palette:
  ; Multiply sub-palette index by 16 to point to the
  ; correct VCE index
  lda    <_al
  stz    <_ah
  asl    A
  asl    A
  asl    A
  asl    A
  rol    <_ah
  ; Set VCE index
  sta    color_reg_l
  lda    <_ah
  sta    color_reg_h

  ; Use TIA, but BLiT 16 words at a time (32 bytes)
  ; Because interrupt must not be deferred too much
  set_ram_cpy_mode SOURCE_INC_DEST_ALT
  stw    #32, <_ram_cpy_size
  stw    #color_data, <_ram_cpy_dest
.loop_a:
      stw    <_si, <_ram_cpy_src
      jsr    _ram_cpy_proc
      addw   #32, <_si
      dec    <_cl
      bne    .loop_a

  ; Copy data
  ; Restore bank mapping
  jsr unmap_data
  rts

;----------------------------------------------------------------------
; name : set_bat_size
;
; description : set bg map virtual size
;
; in : A = new size (0-7)
;
set_bat_size:
  and   #$07
  pha
  ; Memory Access Width Register (vreg #9)
  vreg  #9
  pla
  tax
  ; BG map size is store in bits 4 to 6 in vreg #9
  asl   A
  asl   A
  asl   A
  asl   A
  sta   video_data_l
  ; Convert to "real" screen size and mask
  ; -- width : 32,64,128
  lda  .width,X
  sta   bat_width
  stz   bat_width+1
  dec   A
  sta   bat_hmask
  ; -- height : 32,64
  lda  .height,X
  sta   bat_height
  ; -- bat coords
  sta   mapbat_bottom
  stz   mapbat_top
  stz   mapbat_top_base
  stz   mapbat_top_base+1
  dec   A
  sta   bat_vmask

  rts

.width:	 .db $20,$40,$80,$80,$20,$40,$80,$80
.height: .db $20,$20,$20,$20,$40,$40,$40,$40


;----------------------------------------------------------------------
; name : load_bat
;
; description : Transfer BAT data from ROM/RAM to VRAM
;
; in :  _DI = VRAM base address
;       _BL = BAT bank
;       _SI = BAT memory location
;       _CL = nb of column to copy
;       _CH = nb of row
;
loab_bat:
  cly
  ; Map data
  jsr    map_data

.l1:  ; Set VRAM pointer
      jsr    set_write

      ldx    <_cl
.l2:      ; Copy line
          lda    [_si],Y
          sta    video_data_l
          iny

          lda    [_si],Y
          sta    video_data_h
          iny

          ; if y=0, this means that we copied
          ; 256 bytes and can't further use
          ; lda [zp],Y. That's why we make _si
          ; jump to 256 bytes.
          bne    .l3
              inc    <_si+1
.l3:      dex
          bne    .l2

      ; Jump to next line
      jsr    remap_data
      addw   bat_width, <_di
      dec    <_ch
      bne    .l1

  ; Unmap data
  jsr   unmap_data

  rts

;----------------------------------------------------------------------
; name : set_xres
;
; description : Set horizontal screen resolution
;
; in :  _AH = Horizontal screen resoultion
;       _CL = 'blur'
;
        .bss
hsw       .ds 1		; temporary parameters for calculating video registers
hds       .ds 1
hdw       .ds 1
hde       .ds 1
	.code

_vce_tab:	.db	 0, 1, 2
_hsw_tab:	.db	 2, 3, 5
_hds_tab:	.db	18,25,42
_hde_tab:	.db	38,51,82

set_xres:
  ; TODO disable vsync
  lda	<_ah
  sta	<_bh
  lda	<_al
  sta	<_bl		; bx now has x-res

  lsr	<_bh
  ror	<_bl
  lsr	<_bh
  ror	<_bl
  lsr	<_bl		; bl now has x/8

  cly			; offset into numeric tables
  			; 0=low-res, 1=mid-res, 2=high-res

  lda	<_ah
  beq    .xres_calc	; < 256
  cmp	#3
  bhs   .xres_calc

  cmpw	#$10C,<_ax
  blo    .xres_calc	; < 268

  iny
  cmpw	#$164,<_ax
  blo    .xres_calc	; < 356

  iny			; 356 < x < 512

.xres_calc:
  lda	_vce_tab,Y
  ora	<_cl
  sta	color_ctrl	; dot-clock (x-resolution)

  lda	_hsw_tab,Y	; example calc's (using "low-res" numbers)
  sta	hsw		; hsw = $2
  lda	<_bl
  sta	hds		; hds = (x/8) temporarily
  dec	A
  sta	hdw		; hdw = (x/8)-1
  lsr	hds		; hds = (x/16) temporarily

  lda	_hds_tab,Y
  sub	hds
  sta	hds		; hds = 18 - (x/16)

  lda	_hde_tab,Y
  sub	hds
  sub	<_bl		; hde = (38 - ( (18-(x/16)) + (x/8) ))
  sta	hde

.xres_putit:
  vreg	#$0a
  lda	hsw
  sta	video_data_l
  lda	hds
  sta	video_data_h

  vreg	#$0b
  lda	hdw
  sta	video_data_l
  lda	hde
  sta	video_data_h

.xres_err:

  ; TODO enable vsync
  rts

;----------------------------------------------------------------------
; name : set_xres256
;
; description : Set horizontal screen resolution to 256
;
; in :  _CL = 'blur'
;
set_xres256:
    cla
    ora     <_cl
    sta     color_ctrl

    st0     #$0a
    st1     #$02
    st2     #$02

    st0     #$0b
    st1     #$1f
    st2     #$04

    rts

;----------------------------------------------------------------------
; name : set_xres320
;
; description : Set horizontal screen resolution to 320
;
; in :  _CL = 'blur'
;
set_xres320:
    lda     #$01
    ora     <_cl
    sta     color_ctrl

    st0     #$0a
    st1     #$02
    st2     #$04

    st0     #$0b
    st1     #$2a
    st2     #$04

    rts

;----------------------------------------------------------------------
; name : set_xres512
;
; description : Set horizontal screen resolution to 512
;
; in :  _CL = 'blur'
;
set_xres512:
    lda     #$02
    ora     <_cl
    sta     color_ctrl

    st0     #$0a
    st1     #$02
    st2     #$0b

    st0     #$0b
    st1     #$3f
    st2     #$04

    rts

;----------------------------------------------------------------------
; name : load_vram
;
; description : copy a block of memory to VRAM
;
; in :  _di VRAM location
;       _bl data bank
;       _si data memory location
;       _cx number of bytes to copy
;
load_vram:
	; We will only use bank 3
	; Save current bank mapping
	tma		#3
	sta		<_bh

	; Remap pointer
	lda		<_bl
	tam		#3

	lda		<_si+1
	and		#$1f
	sta		<_dh
	ora		#$60
	sta		<_si+1

	; Set vram write pointer
	vreg	#$00
	lda		<_di
	sta		video_data_l
	lda		<_di+1
	sta		video_data_h

    ; Use the vram data register
    vreg	#$02

    ; Use source increment, alternate destination for RAM to VRAM transfer
    set_ram_cpy_mode SOURCE_INC_DEST_ALT
	; Set tia destination to vram data register
	stw		#video_data, <_ram_cpy_dest
	
	; As the address is modulo 8192, all we have to do is to check 
	; if it is not null
	lda		<_si
	bne		.load_vram_prefix_0
	lda		<_dh
	beq		.load_vram_8k
	
.load_vram_prefix_0:
	; dx = 8192 - (_si & 0x1FFF)
	sec
	lda		#low(8192)
	sbc		<_si
	sta		<_dl
	lda		#high(8192)
	sbc		<_dh
	sta		<_dh
		
	; We will copy 32 bytes each time so that the interrupts aren't
	; delayed to much
	lda		#32
	sta		<_ram_cpy_size
	stz		<_ram_cpy_size+1
	
	; Set source
	lda		<_si
	sta		<_ram_cpy_src
	lda		<_si+1
	sta		<_ram_cpy_src+1
	
	; _cx -= _dx
	subw	<_dx, <_cx

.load_vram_prefix:

		sec
		lda		<_dl
		sbc		#32
		bcs		.load_vram_prefix_1
		dec		<_dh
		bmi		.load_vram_prefix_end
		
.load_vram_prefix_1:
		; A should contain the result of dl - 32
		sta		<_dl

		; Transfer data
		jsr		_ram_cpy_proc
	
		; Move source pointer to the next 32 bytes
		addw	#32, <_ram_cpy_src
		
		bra		.load_vram_prefix

.load_vram_prefix_end:
		
		; Copy remaining data
		lda		<_dl
		beq		.load_vram_prefix_3
			sta     <_ram_cpy_size
			jsr		_ram_cpy_proc
			
.load_vram_prefix_3:

	; Map next rom bank
	inc		<_bl
	lda		<_bl
	tam		#3

	; Clean up source address
	lda		<_si+1
	and		#%1110_0000
	sta		<_si+1

.load_vram_8k:

	; So here we will copy 8k each time
	lda		#32
	sta		<_ram_cpy_size
	stz		<_ram_cpy_size+1

.load_vram_8k_begin:
	; we are finished if ch < high(8192)
	lda		<_si+1
	sta		<_ram_cpy_src+1
	stz		<_ram_cpy_src

	lda		<_ch
	cmp		#32
	bcc		.load_vram_8k_end

	; We are about to copy 8192 bytes (ie) 256*32
    clx
.load_vram_8k_1:
		; Transfer data
		jsr		_ram_cpy_proc
	
		; Move source pointer to the next 32 bytes
		addw	#32, <_ram_cpy_src
		
		; (++x) and check if it didn't overflow
		inx
        bne		.load_vram_8k_1

		; cx -= 8192
		sec
		lda		<_ch
		sbc		#32
		sta		<_ch

		; Jump to next bank
		inc		<_bx		
		lda		<_bx
		tam		#3
	
	bra		.load_vram_8k_begin
	
.load_vram_8k_end:

	lda		<_ch
	bne		.load_vram_remaining
	lda		<_cl
	beq		.load_vram_end
	
.load_vram_remaining:

	lda		#32
	sta		<_ram_cpy_size
	stz		<_ram_cpy_size+1

.load_vram_remaining_0:

		; _cx -= 32
		sec
		lda		<_cl
		sbc		#32
		bcs		.load_vram_remaining_1
		dec		<_ch
		bmi		.load_vram_remaining_2
		
.load_vram_remaining_1:
		; A should contain the result of _cl - 32
		sta		<_cl

		; Transfer data
		jsr		_ram_cpy_proc
	
		; Move source pointer to the next 32 bytes
		addw	#32, <_ram_cpy_src
		
		bra		.load_vram_remaining_0

.load_vram_remaining_2:
		lda		<_cl
		beq		.load_vram_end
		
		sta     <_ram_cpy_size
		jsr		_ram_cpy_proc

.load_vram_end:
	
	; Restore bank mapping
	lda		<_bh
	tam		#3

	rts

;;---------------------------------------------------------------------
; name : load_vram_1bpp
;
; description : Load 8x8 1bpp tiles to vram.
;
; in : _di = VRAM address
;      _bl data bank
;      _si data memory location
;      _cx number of bytes to copy
;      A   byte value for plane #1
;      X   byte value for plane #2
;      Y   byte value for plane #3
;;---------------------------------------------------------------------
load_vram_1bpp:
    ; Save registers
    stx    <_al
    sty    <_ah
    pha
    
	; Set control register
	st0		#$05
	st1		#%0000_0000 ; hsync/vsync and bg/sprite display off
	st2		#%0000_0000 ; 1 byte increment
    
    ; Remap pointer to mprs 3/4
    jsr    map_data
	; Set vram write register
    jsr    set_write

    plx
    
.load_vram_1bpp_main:
    ; We only need to set the first plane.
    ; Let's unroll the loop!
_load_vram_1bpp_write .macro
    lda    [_si],Y
	sta    video_data_l
	stx    video_data_h
	iny
    .endm
    
    cly
    _load_vram_1bpp_write
    _load_vram_1bpp_write
    _load_vram_1bpp_write
    _load_vram_1bpp_write
    _load_vram_1bpp_write
    _load_vram_1bpp_write
    _load_vram_1bpp_write
    _load_vram_1bpp_write
       
    ; Planes 2 and 3 are not used as this is 1 bpp data.
    lda    <_al
    ldy    <_ah
    sta    video_data_l
    sty    video_data_h
    sty    video_data_h
    sty    video_data_h
    sty    video_data_h
    sty    video_data_h
    sty    video_data_h
    sty    video_data_h
    sty    video_data_h
    
    ; Next char.
    addw   #08, <_si
    
    ; Decrement our counter.
    decw   <_cx
    ; Check if we are done.
    lda    <_cl
    ora    <_ch
    beq    .load_vram_1bpp_end
        jmp    .load_vram_1bpp_main
.load_vram_1bpp_end:
    
    ; Restore mprs 3 and 4
    jsr    unmap_data
    
    ; Restore vdc control register
	st0    #$05
	lda    <vdc_crl
	sta    video_data_l	
	st2    #$00
    
    rts

;----------------------------------------------------------------------
; name : wait_vsync
;
; description : wait the next vsync
;
; in  :  A = number of frames to be sync'ed on
;
; out :  A = number of elapsed frames since last call
;
wait_vsync:
.wait_vsync1:	
	sei						; disable interrupts
	cmp		irq_cnt			; calculate how many frames to wait
	beq		.wait_vsync2
	bhs		.wait_vsync3
	lda		irq_cnt
.wait_vsync2:
	inc		A
.wait_vsync3:
	sub		irq_cnt
	sta		vsync_cnt
	cli						; re-enable interrupts

.wait_vsync4:
	lda		irq_cnt			; wait loop
.wait_vsync5:
	cmp		irq_cnt
	beq		.wait_vsync5
	dec		vsync_cnt
	bne		.wait_vsync4

	stz		irq_cnt			; reset system interrupt counter
	inc		A				; return number of elapsed frames

	rts

;;---------------------------------------------------------------------
; name : disable display
; desc : disable interupts and sprite/bg display
; in   :
; out  :
;;---------------------------------------------------------------------
disable_display:
    ; Disable sprite and bg display
	vreg   #$05
	st1    #$00
	st2    #$00
	; Disable interrupts
	vec_off #VSYNC
	vec_off #HSYNC
    rts