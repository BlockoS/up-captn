		.bss
		
		; we don't need to have be compatible with system card memory layout
        ; .org $2200
user_jmptbl:		; user interrupt vectors
irq2_jmp:	.ds 2	; IRQ2 (BRK instruction and external IRQ)
irq1_jmp:	.ds 2	; IRQ1 (VDC interrupt)
timer_jmp:	.ds 2	; TIMER
nmi_jmp:	.ds 2	; NMI (unused)
vsync_hook:	.ds 2	; VDC vertical sync routine
hsync_hook:	.ds 2	; VDC horizontal sync rountine

bg_x1:		.ds 2
bg_x2:		.ds 2
bg_y1:		.ds 2
bg_y2:		.ds 2

		; we don't need to have be compatible with system card memory layout
        ; .org	$2227
joyena:		.ds 1	; soft reset enable (bit 0/pad 1, bit 1/pad2, etc.)
joy:		.ds 5	; 'current' pad values (pad #1-5)
joytrg:		.ds 5	; 'delta' pad values (new keys hit)
joyold:		.ds 5	; 'previous' pad values
		
        ; we don't need to have be compatible with system card memory layout
        ; .org	$2241
irq_cnt:	.ds 1	; VDC interrupt counter; increased 60 times per second
					; reset to zero when vsync() function called
vdc_mwr:	.ds 1
vdc_dcr:	.ds 1
		
        ; we don't need to have be compatible with system card memory layout
        ; .org	$2244
scr_mode:	.ds 1	; screen mode and dimensions - set by <ex_scrmod>
scr_w:		.ds 1
scr_h:		.ds 1
		
        ; we don't need to have be compatible with system card memory layout
        ; .org	$2680
vsync_cnt:	.ds 1	; counter for 'wait_vsync' routine

joybuf:		.ds 5	; 'delta' pad values collector

disp_cr:	.ds 1   ; display control (1 = on, 0 = off)
clock_hh	.ds 1	; system clock, hours since startup (0-255)
clock_mm	.ds 1	; system clock, minutes since startup (0-59)
clock_ss	.ds 1	; system clock, seconds since startup (0-59)
clock_tt	.ds 1	; system clock, ticks (1/60th sec) since startup (0-59)

joy6:		.ds 5	; second byte for 6-button joysticks
joytrg6:	.ds 5
joyold6:	.ds 5
joybuf6:	.ds 5

joytmp:		.ds 5
joytmp6:	.ds 5

