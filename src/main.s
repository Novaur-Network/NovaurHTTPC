; novaur patch code version 1


.3ds

.open "code.bin", "build/patched_code.bin", 0x100000

;                                   (r0)              (r1)
; Result get_service_handle(Handle* handle_out, char* service_name)
get_service_handle equ 0x10DB40

replace_hook_addr equ 0x113868
replace_function_addr equ 0x11AA70

.org replace_hook_addr
	replace_hook:
		bl replace_func_jump ; Load our custom code instead of the normal address (0xE04C)
		
.org replace_function_addr
	; moves the char* from r5 into r0, then jumps to the code that replaces stuff in it
	replace_func_jump: ; 0x1aa70
		mov     r0, r5
		b       handle_replacements
		
	.include "src/strfunctions.s"
	
	;                                                         (r0)                     (r1)          (r2)
	; returns modified char* in r0, func variables are (char* stringToReplaceOn, char* target, char* replacement)
	find_and_replace: ; 0x1ac38
		push    {r11, lr}
		add     r11, sp, #4
		sub     sp, sp, #0x20
		str     r0, [r11, #-0x18]
		str     r1, [r11, #-0x1c]
		str     r2, [r11, #-0x20]
		ldr     r1, [r11, #-0x1c]
		ldr     r0, [r11, #-0x18]
		bl      strstr
		str     r0, [r11, #-8]
		ldr     r3, [r11, #-8]
		cmp     r3, #0
		beq     find_and_replace_lab_1
		ldr     r0, [r11, #-0x1c]
		bl      strlen
		mov     r3, r0
		str     r3, [r11, #-0xc]
		ldr     r0, [r11, #-0x20]
		bl      strlen
		mov     r3, r0
		str     r3, [r11, #-0x10]
		ldr     r3, [r11, #-0xc]
		ldr     r2, [r11, #-8]
		add     r3, r2, r3
		mov     r0, r3
		bl      strlen
		mov     r3, r0
		str     r3, [r11, #-0x14]
		ldr     r3, [r11, #-0x10]
		ldr     r2, [r11, #-8]
		add     r0, r2, r3
		ldr     r3, [r11, #-0xc]
		ldr     r2, [r11, #-8]
		add     r1, r2, r3
		ldr     r3, [r11, #-0x14]
		add     r3, r3, #1
		mov     r2, r3
		bl      memcpy
		ldr     r2, [r11, #-0x10]
		ldr     r1, [r11, #-0x20]
		ldr     r0, [r11, #-8]
		bl      memcpy
		b       find_and_replace_lab_2
		
	find_and_replace_lab_1: ; 0x1ace4
		mov     r0, r0
		
	find_and_replace_lab_2: ; 0x1ace8
		sub     sp, r11, #4
		pop     {r11, lr}
		bx      lr
		
	handle_replacements: ; 0x1acf4
		push    {r11, lr}
		add     r11, sp, #4
		sub     sp, sp, #0x28
		str     r0, [r11, #-0x28] ; store r0 (our char* we are replacing string stuff on) into stack -0x28
		bl      get_local_account_id ; get the local account id
		cmp     r0, #2 ; check if r0 is 2
		bne     handle_replacements_aquamarine ; if it isnt, skip to the aquamarine replacements

		; else, run the pretendo replacements
		ldr     r3, =target1
		str     r3, [r11, #-0x8] ; store the just loaded target1 into stack -0x8
		ldr     r3, =target2
		str     r3, [r11, #-0xc] ; store the just loaded target2 into stack -0xc
		ldr     r3, =target3
		str     r3, [r11, #-0x10] ; store the just loaded target3 into stack -0x10
		ldr     r3, =replacementPretendo 
		str     r3, [r11, #-0x14] ; store the just loaded replacementPretendo into stack -0x14
		
		ldr     r2, [r11, #-0x14] ; load replacementPretendo into r2
		ldr     r1, [r11, #-0x8] ; load target1 into r1
		ldr     r0, [r11, #-0x28] ; load our char* back into r0
		bl      find_and_replace
		ldr     r2, [r11, #-0x14] ; load replacementPretendo into r2
		ldr     r1, [r11, #-0xc] ; load target2 into r1
		ldr     r0, [r11, #-0x28] ; load our char* back into r0
		bl      find_and_replace
		ldr     r2, [r11, #-0x14] ; load replacementPretendo into r2
		ldr     r1, [r11, #-0x10] ; load target3 into r1
		ldr     r0, [r11, #-0x28] ; load our char* back into r0
		bl      find_and_replace
		
		b		handle_replacements_end ; skip the aquamarine patches and finish up
		
	handle_replacements_aquamarine:
		ldr     r3, =targetAquamarine
		str     r3, [r11, #-0x8] ; store the just loaded targetAquamarine into stack -0x8
		ldr     r3, =replacementAquamarine 
		str     r3, [r11, #-0xc] ; store the just loaded replacementAquamarine into stack -0xc
		
		ldr     r2, [r11, #-0xc] ; load replacementAquamarine into r2
		ldr     r1, [r11, #-0x8] ; load targetAquamarine into r1
		ldr     r0, [r11, #-0x28] ; load our char* back into r0
		bl      find_and_replace
		
	handle_replacements_end:
		mov     r0, r0
		mov     r0, r3
		sub     sp, r11, #4
		pop     {r11, lr}
		bx      lr
		
	.include "src/frdu.s"

; strings
	.pool
		
	frdu_name:
		.asciiz "frd:u"
		
	target1:
		.asciiz "nintendowifi.net"
	
	target2:
		.asciiz "nintendo.net"
	
	target3:
		.asciiz "pokemon-gl.com"
	
	replacementPretendo:
		.asciiz "ecliipse.app"

	targetAquamarine:
		.asciiz "discovery.olv.nintendo.net"
	
	replacementAquamarine:
		.asciiz "disc.olv.ecliipse.app"
		
.close
