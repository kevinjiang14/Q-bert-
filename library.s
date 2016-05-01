    AREA    LIBRARY, CODE, READWRITE 
	EXPORT digits_SET		
    EXPORT read_character
    EXPORT output_character
	EXPORT output_string
	; On board displays
    EXPORT display_digit_on_7_seg
    EXPORT read_from_push_btns
	EXPORT illuminateLEDs
	EXPORT illuminate_RGB_LED
	EXPORT illuminate_GREEN
	EXPORT illuminate_RED
	EXPORT illuminate_BLUE
	EXPORT illuminate_PURPLE
	EXPORT RGB_LED_off
	; Initilizations
	EXPORT uart_init
	EXPORT interrupt_init
	EXPORT timer0_init
	EXPORT timer1_init
	; Pin Connect Block Setups
	EXPORT pin_connect_block_setup
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT pin_connect_block_setup_for_timer
	EXPORT gpio_direction_setup
	; Set Match Register values
	EXPORT set_MR1_timer0
	EXPORT set_MR1_timer1
	EXPORT set_MR2_timer1
	EXPORT set_MR3_timer1
	; Random
	EXPORT random_character
	EXPORT random_position
	EXPORT random_direction
	EXPORT random_start
	; Disables
	EXPORT disable_TIMER0
	EXPORT disable_TIMER1
	; Resets
	EXPORT reset_TIMER0
	EXPORT reset_TIMER1

digits_SET    
        DCD 0x00001F80  ; 0
        DCD 0x00000300  ; 1 
        DCD 0x00002D80  ; 2
        DCD 0x00002780  ; 3
        DCD 0x00003300  ; 4
        DCD 0x00003680  ; 5
        DCD 0x00003E80  ; 6
        DCD 0x00000380  ; 7
        DCD 0x00003F80  ; 8
        DCD 0x00003780  ; 9
        DCD 0x00003B80  ; A
        DCD 0x00003E00  ; B
        DCD 0x00001C80  ; C
        DCD 0x00002F00  ; D
        DCD 0x00003C80  ; E
        DCD 0x00003880  ; F

    ALIGN
		
random_direction  ; random direction stored in r1
		STMFD sp!, {r0, r10, lr}

		LDR r0, =0xE0008008
		LDR r1, [r0]
		AND r1, r1, #0x1	; r1 = first two bits of second byte (value can only be 0 to 3 for each direction)

		LDMFD sp!, {r0, r10, lr}
        BX lr

random_start  ; random direction stored in r1
		STMFD sp!, {r0, r10, lr}

		LDR r0, =0xE0008008
		LDR r1, [r0]
		AND r1, r1, #0x1	; r1 = first bits of first byte (value can only be 0 to 1)

		LDMFD sp!, {r0, r10, lr}
        BX lr

random_position	; random position stored r3 = x-position, r4 = y-position
		STMFD sp!, {r0, r1, r10, lr}

		LDR r0, =0xE0008008
		LDR r1, [r0]
		AND r3, r1, #0x1F	; r3 = second byte in TIMER1 (character x position - 0 to 31)
		AND r4, r1, #0xF	; r4 = third byte in TIMER1 (character y position - 0 to 15)
		; Set x-position to range of 3 to 24	
		ADD r3, r3, #0x3
		CMP r3, #24
		BLE YPOS
		SUB r3, r3, #7
		; Set y-position to range of 0 to 10
YPOS	CMP r4, #10
		BLE POSDONE
		SUB r4, r4, #0x5
POSDONE
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

random_character ; random character stored in r2
		STMFD sp!, {r0, r1, r10, lr}

		LDR r0, =0xE0008008
		LDR r1, [r0]
		AND r2, r1, #0x3	; r2 = first two bits in TIMER1 (value can only be 0 to 3 for each character)

		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

set_MR1_timer0	; set match register for timer0 to interrupt every half a second
		STMFD sp!, {r0, r10, lr}
		; Set Match Register to value in r12
		LDR r0, =0xE000401C	   	
		STR r7, [r0]

		LDMFD sp!, {r0, r10, lr}
        BX lr
		
set_MR1_timer1	; set match register for timer1 to interrupt every 2 minutes
		STMFD sp!, {r0-r1, r10, lr}
		; Set Match Register value to generate interrupt
		LDR r0, =0xE000801C
		LDR r1, =0x83D60000			; 2min = 0x83D60000
		STR r1, [r0]

		LDMFD sp!, {r0-r1, r10, lr}
        BX lr
		
set_MR2_timer1	; set match register for timer1
		STMFD sp!, {r0, r10, lr}
		; Set Match Register value to generate interrupt
		LDR r0, =0xE0008020
		STR r1, [r0]

		LDMFD sp!, {r0, r10, lr}
        BX lr
		
set_MR3_timer1	; set match register for timer1 
		STMFD sp!, {r0, r10, lr}
		; Set Match Register value to generate interrupt
		LDR r0, =0xE0008024
		STR r1, [r0]

		LDMFD sp!, {r0, r10, lr}
        BX lr

pin_connect_block_setup_for_timer	; sets up the pin connect block for TIMER0 and TIMER1
		STMFD sp!, {r0, r1, r10, lr}
		; Set pins 2 and 3 to TIMER0
		LDR r0, =0xE002C000
		LDR r1, [r0]
		ORR r1, r1, #0xA0			; setting pins 2 and 3 to 10 for TIMER0
		BIC r1, r1, #0x50
		; Set pins 10 and 11 to TIMER1
		ORR r1, r1, #0xA00000		; setting pins 10 and 11 to 10 for TIMER1
		BIC r1, r1, #0x500000
		STR r1, [r0]

		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

timer0_init	; enables the timer counter for TIMER0
		STMFD sp!, {r0, r1, r10, lr}

		; Timer Counter enable for TIMER0
		LDR r0, =0xE0004004
		LDR r1, [r0]
		ORR r1, r1, #0x1
		BIC r1, r1, #0x2
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
timer1_init	; enables the timer counter for TIMER1
		STMFD sp!, {r0, r1, r10, lr}

		; Timer Counter enable for TIMER1
		LDR r0, =0xE0008004
		LDR r1, [r0]
		ORR r1, r1, #0x1
		BIC r1, r1, #0x2
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

disable_TIMER0	; disables TIMER0
		STMFD sp!, {r0, r1, r10, lr}
		
		; Timer Counter disable for TIMER0
		LDR r0, =0xE0004004
		LDR r1, [r0]
		BIC r1, r1, #0x1
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

disable_TIMER1	; disables TIMER1
		STMFD sp!, {r0, r1, r10, lr}
		
		; Timer Counter disable for TIMER1
		LDR r0, =0xE0008004
		LDR r1, [r0]
		BIC r1, r1, #0x1
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
reset_TIMER0	; resets TIMER0
		STMFD sp!, {r0, r1, r10, lr}
		
		; Timer Counter disable for TIMER0
		LDR r0, =0xE0004004
		LDR r1, [r0]
		ORR r1, r1, #0x2
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

reset_TIMER1	; resets TIMER1
		STMFD sp!, {r0, r1, r10, lr}
		
		; Timer Counter disable for TIMER1
		LDR r0, =0xE0008004
		LDR r1, [r0]
		ORR r1, r1, #0x2
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
uart_init	; initialized the UART0 divisor latches
        STMFD sp!, {r0-r3, r10, lr}
        
		LDR r0, =0xE000C00C
        LDR r1, =0xE000C000
        LDR r2, =0xE000C004
		; Enable divisor latch access
        MOV r3, #131
        STR r3, [r0]
		; Set lower divisor latch
		; 9600 baud(set to 120)
		; 115200 baud(set to 10)
        MOV r3, #10
        STR r3, [r1]
		; Set upper divisor latch for 9600baud
        MOV r3, #0
        STR r3, [r2]
		; Disable divisor latch access
        MOV r3, #3
        STR r3, [r0]
		; Disable FIFOs
        LDR r0, =0xE000C008
        MOV r3, #0x0
        STR r3, [r0]
		
        LDMFD sp!, {r0-r3, r10, lr}
        BX lr
		
pin_connect_block_setup_for_uart0	; sets up the pin connect block for UART0
		STMFD sp!, {r0, r1, r10, lr}
		
		LDR r0, =0xE002C000  ; PINSEL0
		LDR r1, [r0]
		ORR r1, r1, #5
		BIC r1, r1, #0xA
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
		BX lr
    
pin_connect_block_setup ; sets up the pin connect block for 7 segment display and UART0
        STMFD sp!, {r0, r1, r10, lr} 
		; 7 segment display and UART0
        LDR r0, =0xE002C000         ; r0 = PINSEL0 address 
        LDR r1, [r0]
        AND r1, r1, #0xF0FFFFFF     ; setting pins 12 and 13 to 00 for GPIO
        AND r1, r1, #0xFF0FFFFF     ; setting pins 10 and 11 to 00 for GPIO
        AND r1, r1, #0xFFF0FFFF     ; setting pins 8 and 9 to 00 for GPIO
        AND r1, r1, #0xFFFF3FFF     ; setting pin 7 to 00 for GPIO
        AND r1, r1, #0xFFFFFFF0     ; setting pins 0 and 1 to 00
        ORR r1, r1, #0x5            ; setting pins 0 and 1 to 01 for UART0
		STR r1, [r0]
		
		; RGB LED	(4 LED does not need to be set up)
		LDR r0, =0xE002C004
		LDR r1, [r0]
		AND r1, r1, #0xFFFFFFF3		; setting pin 17 to 00 for GPIO
		AND r1, r1, #0xFFFFFFCF		; setting pin 18 to 00 for GPIO
		AND r1, r1, #0xFFFFF3FF		; setting pin 21 to 00 for GPIO
        STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

gpio_direction_setup	; sets up the GPIO direction for 7 segment display
        STMFD sp!, {r0, r1, r10, lr}
		
		; RGB LED and 7 segment display direction set up
        LDR r0, =0xE0028008         ; r0 = IO0DIR address
        LDR r1, [r0]
		; RGB LED
		ORR r1, r1, #0x200000		; setting pin 21 to output
		ORR r1, r1, #0x60000		; setting pin 17 and 18 to output
		; 7 segment display
		ORR r1, r1, #0x3000         ; setting pins 12 and 13 to output
        ORR r1, r1, #0xF00          ; setting pins 8-11 to output
        ORR r1, r1, #0x80           ; setting pin 7 to output
        STR r1, [r0]
		
		; 4 LED direction set up
		LDR r0, =0xE0028018			; r0 = IO1DIR address
		LDR r1, [r0]
		ORR r1, r1, #0xF0000		; setting pins 16-19 to output
		STR r1, [r0]		

		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

interrupt_init	; sets up the interrupt for EINT1, UART0, and TIMER0     
		STMFD SP!, {r0-r1, r10, lr}   	; Save registers 
		
		; Push button setup		 
		LDR r0, =0xE002C000
		LDR r1, [r0]
		ORR r1, r1, #0x20000000
		BIC r1, r1, #0x10000000
		STR r1, [r0]  				; PINSEL0 bits 29:28 = 10
		
		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC]
		ORR r1, r1, #0x8000 		; External Interrupt 1
		ORR r1, r1, #0x0040			; UART0 Interrupt
		ORR r1, r1, #0x0010 		; TIMER0 Interrupt
		ORR r1, r1, #0x0020			; TIMER1 Interrupt
		STR r1, [r0, #0xC]

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] 
		ORR r1, r1, #0x8000 		; External Interrupt 1
		ORR r1, r1, #0x0040			; UART0 Interrupt
		ORR r1, r1, #0x0010			; TIMER0 Interrupt
		ORR r1, r1, #0x0020			; TIMER1 Interrupt		
		STR r1, [r0, #0x10]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2				; EINT1 = Edge Sensitive
		STR r1, [r0]

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0
		
		; Setting DLAB for UART0 to 0
		LDR r0, =0xE000C00C
		LDR r1, [r0]
		AND r1, r1, #0xFFFFFF8F
		STR r1, [r0]

		; Setup for UART0 interrupt
		LDR r0, =0xE000C004
		LDR r1, [r0]
		ORR r1, r1, #0x1
		STR r1, [r0]
		
		; Match Control Register 1 for TIMER0 setup
		LDR r0, =0xE0004014
		LDR r1, [r0]
		ORR r1, r1, #0x08			; Enable MR1 Interrupt
		ORR r1, r1, #0x10			; Enable MR1 Reset
		STR r1, [r0]

		; Match Control Register 1 for TIMER1 setup
		LDR r0, =0xE0008014
		LDR r1, [r0]
		ORR r1, r1, #0x08			; Enable MR1 Interrupt
		ORR r1, r1, #0x10			; Enable MR1 Reset
		STR r1, [r0]
		
		; Match Control Register 2 for TIMER1 setup
		LDR r0, =0xE0008014
		LDR r1, [r0]
		ORR r1, r1, #0x40			; Enable MR2 Interrupt
		STR r1, [r0]
		
		; Match Control Register 3 for TIMER1 setup
		LDR r0, =0xE0008014
		LDR r1, [r0]
		ORR r1, r1, #0x200			; Enable MR3 Interrupt
		STR r1, [r0]

		LDMFD SP!, {r0-r1, r10, lr}		; Restore registers
		BX lr

read_character		; stores character into r0
        STMFD sp!, {r1, r2, r10, lr}
		
        LDR r1, =0xE000C014         ; r1 = status register address
REPEAT  LDR r2, [r1]
        AND r2, r2, #0x1            ; clearing all bytes except the one that tells us if RDR is 1
        CMP r2, #0x1                ; checking if a byte was received
        BNE REPEAT                    
        LDR r1, =0xE000C000         ; r1 = receive buffer register
        LDR r0, [r1]                ; r0 = byte received 
		
DONE    LDMFD sp!, {r1, r2, r10, lr}
        BX lr
        
output_character	; outputs character stored in r0
        STMFD sp!, {r1, r2, r10, lr}
		
        LDR r1, =0xE000C014         ; r1 = status register address
START1  LDRB r2, [r1]                
        BIC r2, r2, #0xFFFFFFDF     ; clearing all bytes except the one that tells us if THRE is 1
        LSR r2, #5                  ; shifting the THRE value to LSB position
        CMP r2, #0x1                ; checking if the THRE is empty
        BNE START1
        LDR r1, =0xE000C000         ; r1 = transmit buffer address
        STR r0, [r1]     			; output r0
		
        LDMFD sp!, {r1, r2, r10, lr}
        BX lr
		
output_string	; outputs from memory address stored in r0
		STMFD sp!, {r1-r3, r10, lr}
		
LOOP	LDRB r1, [r0], #0x1
		CMP r1, #0x0
		BEQ	FIN
		LDR r2, =0xE000C014
START	LDRB r3, [r2]
		BIC r3, r3, #0xFFFFFFDF
		MOV r3, r3, LSR #5
		CMP r3, #0x1
		BNE START
		LDR r2, =0xE000C000
		STR r1, [r2]
		B LOOP
		
FIN		LDMFD sp!, {r1-r3, r10, lr}
        BX lr
        
display_digit_on_7_seg	; displays the value stored in r0 on 7 segment display (value stored in r0 is in ASCII)               
        STMFD sp!, {r1-r3, r10, lr}
		
		LDR r1, =0xE002800C			; r1 = port 0 clear
        MOV r2, #0x3000				; clear pins 12 and 13
        ORR r2, r2, #0xF00			; clear pins 8 to 11
        ORR r2, r2, #0x80			; clear pin 7
        STR r2,[r1]

        LDR r1, =0xE0028000			; r1 = port 0 pin value register
        LDR r3, =digits_SET
        MOV r0, r0, LSL #2			; Each stored value is 32 bits
        LDR r2, [r3, r0]			; Load IOSET pattern for digit in r0
        STR r2, [r1, #4]			; Display (0x4 = offset to IOSET)
        
		LDMFD sp!, {r1-r3, r10, lr}
        BX lr
        
read_from_push_btns                ; PORT 1 pin 16-19 LED, pin 20-23 BUTTON 
        STMFD sp!, {r1, r2, r10, lr}  
		
NEXT    LDR r1, =0xE0028010			; r1 = pin value address
        LDR r0, [r1]				; r0 = pin value
        BL illuminateLEDs			; turn on LEDs corresponding to buttons pushed
        MOV r2, r0, LSL #20			; r3 = the four bytes that tells us which of the four buttons are pressed
        CMP r2, #0xA				; if value is less than 10 branch to PRINT
        BLT    PRINT
        SUB r2, r2, #0xA			; else subtract 10
        MOV r0, #0x31				; prints a one for tens place
        BL output_character
PRINT   ADD r0, r2, #0x30			; prints value less than 10
        BL output_character
        
		LDMFD sp!, {r1, r2, r10, lr}
        BX lr
        
illuminateLEDs ; illuminates the 4 LED (IO1SET turns off and IO1CLR turns on)
        STMFD sp!, {r0, r1, r10, lr}
		; turns off 4 LEDs
		LDR r1, =0xE0028014	  		; r1 = IO1SET
		MOV r0, #0xF0000
		STR r0,[r1]
		; turns on 4 LEDs
        LDR r1, =0xE002801C			; r1 = IO1CLR 
        MOV r0, #0xF0000		; setting pins 16-19 to 1 to turn on LED
        STR r0, [r1]
        
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
        
illuminate_RGB_LED ; illuminate RGB LED to white (IO1SET turns off and IO1CLR turns on)
        STMFD sp!, {r0, r1, r10, lr}
		
		; turns off RGB LED
		LDR r0, =0xE0028004
		MOV r1, #0x260000
		STR r1, [r0]

		; turns on RGB LED to white
		LDR r0, =0xE0028000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFF
		ORR r1, r1, #0x200000
		ORR r1, r1, #0x60000
        LDR r0, =0xE002800C			; r0 = IO0CLR
		STR r1, [r0] 

        
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
illuminate_GREEN
		STMFD sp!, {r0, r1, r10, lr}
		
		; turns off RGB LED
		LDR r0, =0xE0028004
		MOV r1, #0x260000
		STR r1, [r0]

		; turns on RGB LED to green
		LDR r0, =0xE0028000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFF
		ORR r1, r1, #0x200000
        LDR r0, =0xE002800C			; r0 = IO0CLR
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
illuminate_RED
		STMFD sp!, {r0, r1, r10, lr}
		
		; turns off RGB LED
		LDR r0, =0xE0028004
		MOV r1, #0x260000
		STR r1, [r0]

		; turns on RGB LED to red
		LDR r0, =0xE0028000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFF
		ORR r1, r1, #0x20000
        LDR r0, =0xE002800C			; r0 = IO0CLR
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
illuminate_BLUE
		STMFD sp!, {r0, r1, r10, lr}
		
		; turns off RGB LED
		LDR r0, =0xE0028004
		MOV r1, #0x260000
		STR r1, [r0]

		; turns on RGB LED to blue
		LDR r0, =0xE0028000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFF
		ORR r1, r1, #0x40000
        LDR r0, =0xE002800C			; r0 = IO0CLR
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr

illuminate_PURPLE
		STMFD sp!, {r0, r1, r10, lr}
		
		; turns off RGB LED
		LDR r0, =0xE0028004
		MOV r1, #0x260000
		STR r1, [r0]

		; turns on RGB LED to purple
		LDR r0, =0xE0028000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFF
		ORR r1, r1, #0x60000
        LDR r0, =0xE002800C			; r0 = IO0CLR
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
		
RGB_LED_off
		STMFD sp!, {r0, r1, r10, lr}
		
		; turns off RGB LED
		LDR r0, =0xE0028004
		MOV r1, #0x260000
		STR r1, [r0]
		
		LDMFD sp!, {r0, r1, r10, lr}
        BX lr
	END
