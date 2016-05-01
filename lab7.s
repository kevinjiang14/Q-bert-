    AREA timers, CODE, READWRITE
	EXPORT lab7
	EXPORT FIQ_Handler
	IMPORT read_character
	IMPORT output_string
	IMPORT output_character
	IMPORT display_digit_on_7_seg
	IMPORT illuminateLEDs
	IMPORT illuminate_RGB_LED
	IMPORT illuminate_GREEN
	IMPORT illuminate_RED
	IMPORT illuminate_BLUE
	IMPORT illuminate_PURPLE
	IMPORT RGB_LED_off
	IMPORT timer0_init
	IMPORT timer1_init
	IMPORT set_MR1_timer0
	IMPORT set_MR1_timer1
	IMPORT set_MR2_timer1
	IMPORT set_MR3_timer1
	IMPORT disable_TIMER0
	IMPORT disable_TIMER1
	IMPORT reset_TIMER0
	IMPORT reset_TIMER1
	IMPORT random_start

prompt = 0xC,"Welcome to Q'bert!",0
prompt1 = 0xA,0xD,"You have 2 minutes to get Q'bert to step on all the spots on the board by jumping onto it.Use W for up, S for down, A for left and D for right. Good Luck!",0
prompt2 = 0xA,0xD,"Enemies will randomly appear from the second row from the top don't let them step on you, you have four lives and don't jump off the board.",0		
prompt3 = 0xA,0xD,"Press g to begin.",0
board = 0xC,	  "            _____",0
board1 = 0xA,0xD, "           / *Q /|",0
board2 = 0xA,0xD, "          /____/ |____",0
board3 = 0xA,0xD, "          |    |/ *  /|",0
board4 = 0xA,0xD, "          |____|____/ |____",0
board5 = 0xA,0xD, "         / *  /|    |/ *  /|",0
board6 = 0xA,0xD, "        /____/ |____|____/ |____",0
board7 = 0xA,0xD, "        |    |/ *  /|    |/ *  /|",0
board8 = 0xA,0xD, "        |____|____/ |____|____/ |____",0
board9 = 0xA,0xD, "       / *  /|    |/ *  /|    |/ *  /|",0
board10 = 0xA,0xD,"      /____/ |____|____/ |____|____/ |____",0
board11 = 0xA,0xD,"      |    |/ *  /|    |/ *  /|    |/ *  /|",0
board12 = 0xA,0xD,"      |____|____/ |____|____/ |____|____/ |",0
board13 = 0xA,0xD,"     / *  /|    |/ *  /|    |/ *  /|    | /",0
board14 = 0xA,0xD,"    /____/ |____|____/ |____|____/ |____|/",0
board15 = 0xA,0xD,"    |    |/ *  /|    |/ *  /|    | /",0
board16 = 0xA,0xD,"    |____|____/ |____|____/ |____|/",0
board17 = 0xA,0xD,"   / *  /|    |/ *  /|    | /",0
board18 = 0xA,0xD,"  /____/ |____|____/ |____|/",0
board19 = 0xA,0xD,"  |    |/ *  /|    | /",0
board20 = 0xA,0xD,"  |____|____/ |____|/",0
board21 = 0xA,0xD," / *  /|    | /",0
board22 = 0xA,0xD,"/____/ |____|/",0
board23 = 0xA,0xD,"|    | /",0
board24 = 0xA,0xD,"|____|/",0xA,0xD,0
paused = 0xA,0xD,"PAUSED",0
restart = 0xA,0xD,"Press g to play again",0
gameover = 0xC,"GAME OVER",0xA,0xD,0
scoreprompt = "SCORE:",0
score = "0000",0
; GAMESTATES: 0 = main menu/gameover, 1 = in-progress, 2 = paused
gamestate = "0"
; x = column, y = row
playerposition = "0215"
enemystartposition0 = "0420"
enemystartposition1 = "0613"
enemyposition = "0000"
enemybounds = "00"
movementdelay = "0"
snakeposition = "0000"
snakebounds = "00"
smovementdelay = "0"
; 0 = egg, 1 = snake
snakestate = "0"
movement = "0"
direction = "0"
level = "0"
bounds = "11"
newstate = "11111111111-1111--111---11----1-"
squarestate = "11111111111-1111--111---11----1-"
visitedsquares = "00"
character = "0"
life = "4"
spawn = "0"
spawnegg = "0"
	ALIGN
			
lab7
      	STMFD sp!, {lr}

		LDR r0, =prompt
		BL output_string

		LDR r0, =prompt1             ;load prompt memory address into r2
		BL output_string

		LDR r0, =prompt2             ;load prompt memory address into r2
		BL output_string

		LDR r0, =prompt3             ;load prompt memory address into r2
		BL output_string
		
		MOV r0, #0x0
		BL display_digit_on_7_seg

		BL illuminateLEDs
		BL illuminate_RGB_LED

		LDR r7, =0x8CA000
		
		LDMFD sp!,{lr}
		BX lr	

FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Save registers 

EINT1	; Check for EINT1 interrupt
		LDR r0, =0xE01FC140
		LDR r1, [r0]
		TST r1, #2
		BEQ UART0
			
		; Push button EINT1 Handling Code
		STMFD SP!, {r0-r12, lr}		; Save registers 
		
		; Pause game if game is in progress (gamestate = 1)
		LDR r0, =gamestate
		LDRB r1, [r0]
		CMP r1, #0x31
		BNE RESUME
		BL illuminate_BLUE
		; Changing gamestate to paused (gamestate = 2)
		LDR r0, =gamestate
		MOV r1, #0x32
		STRB r1, [r0]
		; Pauses TIMERs
		BL disable_TIMER0
		BL disable_TIMER1
		; Prints PAUSED string
		BL load_cursor
		LDR r0, =paused
		BL output_string
		B EINTEND
		
		; Checking for paused game state (gamestate = 2)
RESUME	LDR r0, =gamestate
		LDRB r1, [r0]
		CMP r1, #0x32
		BNE EINTEND
		; Setting RGB LED to green
		BL illuminate_GREEN
		; Changing gamestate to in progress (gamestate = 1)
		LDR r0, =gamestate
		MOV r1, #0x31
		STRB r1, [r0]
		; Resumes TIMERs
		BL timer0_init
		BL timer1_init
		; Deletes PAUSED string
		MOV r0, #0xD
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x20
		BL output_character


		B EINTEND

EINTEND
		LDMFD SP!, {r0-r12, lr}		; Restore registers
		B EINT1_LAST

UART0	; Check for UART0 interrupt
		LDR r0, =0xE000C008
		LDR r1, [r0]
		AND r1, r1, #0x1
		CMP r1, #0x1
		BEQ TIMER0
		
		; UART0 Handling Code
		STMFD SP!, {r0-r12, lr}		; Save registers
		
		BL read_character
		
		; Checking input for 'g'
		CMP r0, #0x67
		BNE PMOVE
		; Only have the game start if we were on the start screen (gamestate = 0)
		LDR r1, =gamestate
		LDRB r2, [r1]
		CMP r2, #0x30
		BNE PMOVE
		; Game Start
		BL print_board
		BL set_MR1_timer0
		BL set_MR1_timer1
		LDR r1, =0x2328000
		BL set_MR2_timer1
		LDR r1, =0xAFC8000
		BL set_MR3_timer1
		BL timer0_init
		BL timer1_init
		BL illuminateLEDs
		; Setting level to 1
		LDR r1, =level
		LDRB r0, [r1]
		ADD r0, r0, #0x1
		STRB r0, [r1]
		SUB r0, r0, #0x30
		BL display_digit_on_7_seg
		BL illuminate_GREEN
		; Set number of life to 4
		LDR r0, =life
		MOV r1, #0x34
		STRB r1, [r0]
		; Changing game state to 1 for game is in progress
		LDR r0, =gamestate
		MOV r1, #0x31
		STRB r1, [r0]
		B UARTEND

PMOVE	; Player movement
		LDR r1, =gamestate
		LDRB r2, [r1]
		CMP r2, #0x31
		BNE UARTEND
		; Checking for Up movement
		CMP r0, #0x77
		BNE LEFT
		; Set direction to 0 for up
		LDR r1, =direction
		MOV r0, #0x0
		STRB r0, [r1]
		; Set movement to 1 for true
		LDR r1, =movement
		MOV r0, #0x1
		STRB r0, [r1]
		; Checking for Left movement
LEFT	CMP r0, #0x61
		BNE DOWN
		; Set direction to 1 for left
		LDR r1, =direction
		MOV r0, #0x1
		STRB r0, [r1]
		; Set movement to 1 for true
		LDR r1, =movement
		MOV r0, #0x1
		STRB r0, [r1]
		; Checking for Down movement
DOWN	CMP r0, #0x73
		BNE RIGHT
		; Set direction to 2 for down
		LDR r1, =direction
		MOV r0, #0x2
		STRB r0, [r1]
		; Set movement to 1 for true
		LDR r1, =movement
		MOV r0, #0x1
		STRB r0, [r1]
		; Checking for Right movement
RIGHT	CMP r0, #0x64
		BNE UARTEND
		; Set direction to 3 for right
		LDR r1, =direction
		MOV r0, #0x3
		STRB r0, [r1]
		; Set movement to 1 for true
		LDR r1, =movement
		MOV r0, #0x1
		STRB r0, [r1]
		
UARTEND		
		LDMFD SP!, {r0-r12, lr}		; Restore registers
		B UART0_LAST
		LTORG
		
TIMER0	; Check for TIMER0 interrupt (board refresh rate)
		LDR r0, =0xE0004000
		LDR r1, [r0]
		AND r1, r1, #0x2
		MOV r1, r1, LSR #0x1
		CMP r1, #0x1
		BNE TIMER1_MR1
		
		; TIMER0 Handling Code
		STMFD SP!, {r0-r12, lr}		; Save registers
		
		; Check if we can start spawning enemy
		LDR r1, =spawn
		LDRB r2, [r1]
		CMP r2, #0x30
		BEQ SCHECK
		; Check if ball is still on board
		LDR r1, =enemybounds
		LDRB r2, [r1]
		CMP r2, #0x30
		BNE SCHECK
		BL spawn_enemy
		; Check if we can start spawning egg
SCHECK	LDR r1, =spawnegg
		LDRB r2, [r1]
		CMP r2, #0x30
		BEQ MCHECK
		; Check if egg/snake is on board
		LDR r1, =snakebounds
		LDRB r2, [r1]
		CMP r2, #0x30
		BNE MCHECK
		BL spawn_egg

		; Check if movement was instructed 
MCHECK	LDR r1, =movement
		LDRB r0, [r1]
		CMP r0, #0x1
		BNE CHECK
		; Move player if movement key was pressed
		LDR r1, =direction
		LDRB r0, [r1]
		; Check if player movement was up
		CMP r0, #0x0
		BNE LEFT1
		; Check bounds
		LDR r1, =bounds
		LDRB r0, [r1]
		CMP r0, #0x31
		BEQ RESET
		BL move_up_player
		BL visit_square
		B CLEAR
RESET	BL reset_player
		BL lose_life
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		B CLEAR
		; Check if player movement was left
LEFT1	CMP r0, #0x1
		BNE DOWN1
		; Check bounds
		LDR r1, =bounds
		LDRB r0, [r1, #0x1]
		CMP r0, #0x31
		BEQ RESET1
		BL move_left_player
		BL visit_square
		B CLEAR
RESET1	BL reset_player
		BL lose_life
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		B CLEAR
		; Check if player movement was down
DOWN1	CMP r0, #0x2
		BNE RIGHT1
		; Check bounds
		LDR r1, =bounds
		LDRB r0, [r1]
		LDRB r2, [r1, #0x1]
		ADD r0, r0, r2
		SUB r0, r0, #0x30
		CMP r0, #0x37
		BEQ RESET2
		BL move_down_player
		BL visit_square
		B CLEAR
RESET2	BL reset_player
		BL lose_life
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		B CLEAR
		; Check if player movement was right
RIGHT1	CMP r0, #0x3
		BNE CLEAR
		; Check bounds
		LDR r1, =bounds
		LDRB r0, [r1]
		LDRB r2, [r1, #0x1]
		ADD r0, r0, r2
		SUB r0, r0, #0x30
		CMP r0, #0x37
		BEQ RESET3
		BL move_right_player
		BL visit_square
		B CLEAR
RESET3	BL reset_player
		BL lose_life
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		B CLEAR
		; Clear movement instruction
CLEAR	LDR r1, =movement
		MOV r0, #0x0
		STRB r0, [r1]
		
		
CHECK	; Check if enemy is at edge of the board
		; Ball
		LDR r1, =enemybounds
		LDRB r2, [r1]
		LDRB r3, [r1, #0x1]
		ADD r2, r2, r3
		SUB r2, r2, #0x30		
		CMP r2, #0x37
		BLT CHECK10
		BL clear_enemy
		BL reset_enemy
		; Egg/Snake
CHECK10	LDR r1, =snakestate
		LDRB r0, [r1]
		CMP r0, #0x31
		BEQ EMOVE
		LDR r1, =snakebounds
		LDRB r2, [r1]
		LDRB r3, [r1, #0x1]
		ADD r2, r2, r3
		SUB r2, r2, #0x30		
		CMP r2, #0x37
		BNE EMOVE
		LDR r1, =snakestate
		MOV r0, #0x31
		STRB r0, [r1]


		; Move enemy if it's on the board
EMOVE	; Ball movement
		LDR r0, =enemybounds
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ GMOVE
		LDR r0, =movementdelay
		LDRB r1, [r0]
		CMP r1, #0x33
		BLT GMOVE
		MOV r1, #0x30
		STRB r1, [r0]
		BL random_start
		CMP r1, #0x0
		BNE ERIGHT
		LDR r1, =character
		MOV r2, #0x6F
		STRB r2, [r1]
		LDR r1, =enemyposition
		LDR r2, =enemybounds
		BL move_down_enemy
		B GMOVE
ERIGHT	LDR r1, =character
		MOV r2, #0x6F
		STRB r2, [r1]
		LDR r1, =enemyposition
		LDR r2, =enemybounds
		BL move_right_enemy
GMOVE	; Check snakestate
		LDR r0, =snakestate
		LDRB r1, [r0]
		CMP r1, #0x31
		BEQ SMOVE
		; Egg movement
		LDR r0, =snakebounds
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ COLL
		LDR r0, =smovementdelay
		LDRB r1, [r0]
		CMP r1, #0x33
		BNE COLL
		MOV r1, #0x30
		STRB r1, [r0]
		BL random_start
		CMP r1, #0x0
		BNE ERIGHT1
		LDR r1, =character
		MOV r2, #0x6C
		STRB r2, [r1]
		LDR r1, =snakeposition
		LDR r2, =snakebounds
		BL move_down_enemy
		B COLL
ERIGHT1	LDR r1, =character
		MOV r2, #0x6C
		STRB r2, [r1]
		LDR r1, =snakeposition
		LDR r2, =snakebounds
		BL move_right_enemy
		B COLL
SMOVE	; Snake movement
		LDR r0, =smovementdelay
		LDRB r1, [r0]
		CMP r1, #0x33
		BNE COLL
		MOV r1, #0x30
		STRB r1, [r0]
		LDR r0, =snakebounds
		LDR r1, =bounds
		LDRB r2, [r0]
		LDRB r3, [r1]
		CMP r2, r3
		BLE NUP
		CMP r2, #0x31
		BEQ NUP
		LDR r1, =character
		MOV r2, #0x53
		STRB r2, [r1]
		LDR r1, =snakeposition
		LDR r2, =snakebounds
		BL move_up_enemy
		B COLL
NUP		LDRB r2, [r0]
		LDRB r3, [r1]
		CMP r2, r3
		BEQ NDOWN
		LDRB r4, [r0, #0x1]
		ADD r4, r4, r2
		SUB r4, r4, #0x30
		CMP r4, #0x37
		BEQ NDOWN
		LDR r1, =character
		MOV r2, #0x53
		STRB r2, [r1]
		LDR r1, =snakeposition
		LDR r2, =snakebounds
		BL move_down_enemy
		B COLL
NDOWN	LDR r0, =snakebounds
		LDR r1, =bounds
		LDRB r2, [r0, #0x1]
		LDRB r3, [r1, #0x1]
		CMP r2, r3
		BLT NLEFT
		CMP r2, #0x31
		BEQ NLEFT
		LDR r1, =character
		MOV r2, #0x53
		STRB r2, [r1]
		LDR r1, =snakeposition
		LDR r2, =snakebounds
		BL move_left_enemy
		B COLL
NLEFT	CMP r2, r3
		BEQ COLL
		LDR r1, =character
		MOV r2, #0x53
		STRB r2, [r1]
		LDR r1, =snakeposition
		LDR r2, =snakebounds
		BL move_right_enemy
		
		; Check if player collided with enemy
COLL	LDR r0, =movementdelay
		LDRB r1, [r0]
		ADD r1, r1, #0x1
		STRB r1, [r0]
		LDR r0, =snakebounds
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ SMOVESKIP
		LDR r0, =smovementdelay
		LDRB r1, [r0]
		ADD r1, r1, #0x1
		STRB r1, [r0]
SMOVESKIP
		LDR r0, =bounds
		LDR r1, =enemybounds
		LDR r5, =snakebounds
		LDRB r2, [r0]
		LDRB r3, [r1]
		CMP r2, r3
		BNE SCOLL
		LDRB r2, [r0, #0x1]
		LDRB r3, [r1, #0x1]
		CMP r2, r3
		BNE SCOLL
		BL lose_life
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		; Check for collision with egg/snake
SCOLL	LDRB r2, [r0]
		LDRB r3, [r5]
		CMP r2, r3
		BNE PRINT
		LDRB r2, [r0, #0x1]
		LDRB r3, [r5, #0x1]
		CMP r2, r3
		BNE PRINT
		BL lose_life
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		
PRINT	LDR r1, =character
		MOV r2, #0x51
		STRB r2, [r1]
		LDR r1, =character
		MOV r2, #0x51
		STRB r2, [r1]
		LDR r1, =playerposition
		BL place_character

		; Check if player visited all the squares
VISIT	LDR r1, =visitedsquares
		LDRB r0, [r1]
		CMP r0, #0x32
		BNE TIME0END
		LDRB r0, [r1, #0x1]
		CMP r0, #0x31
		BNE TIME0END
		BL next_level
TIME0END
		LDR r0, =life
		LDRB r1, [r0]
		CMP r1, #0x30
		BEQ TIMER0END
		BL update_score
TIMER0END
		LDR r1, =movement
		MOV r0, #0x0
		STRB r0, [r1]
		LDMFD SP!, {r0-r12, lr}		; Restore registers
		B TIMER0_LAST
		
TIMER1_MR1	; Check for TIMER1 interrupt (2minutes game time)
		LDR r0, =0xE0008000
		LDR r1, [r0]
		AND r1, r1, #0x2
		MOV r1, r1, LSR #0x1
		CMP r1, #0x1
		BNE TIMER1_MR2
		
		; TIMER1_MR1 Handling Code
		STMFD SP!, {r0-r12, lr}		; Save registers 
		
		BL game_over

		LDMFD SP!, {r0-r12, lr}		; Restore registers
		B TIMER1_MR1_LAST
		
TIMER1_MR2
		LDR r0, =0xE0008000
		LDR r1, [r0]
		AND r1, r1, #0x4
		MOV r1, r1, LSR #0x2
		CMP r1, #0x1
		BNE TIMER1_MR3
		
		; TIMER1_MR1 Handling Code
		STMFD SP!, {r0-r12, lr}		; Save registers 
		
		BL spawn_enemy
		BL start_spawn

		LDMFD SP!, {r0-r12, lr}		; Restore registers
		B TIMER1_MR2_LAST
		
TIMER1_MR3
		LDR r0, =0xE0008000
		LDR r1, [r0]
		AND r1, r1, #0x8
		MOV r1, r1, LSR #0x3
		CMP r1, #0x1
		BNE FIQ_Exit
		
		; TIMER1_MR1 Handling Code
		STMFD SP!, {r0-r12, lr}		; Save registers 
		
		BL spawn_egg
		BL start_spawn_egg

		LDMFD SP!, {r0-r12, lr}		; Restore registers
		B TIMER1_MR3_LAST

EINT1_LAST
		; Clear EINT1 Interrupt
		ORR r1, r1, #2
		LDR r0, =0xE01FC140
		STR r1, [r0]
UART0_LAST		
		B FIQ_Exit

TIMER0_LAST
		; Clear TIMER0 Interrupt
		LDR r0, =0xE0004000
		MOV r1, #0x2
		STR r1, [r0]
		B FIQ_Exit
		
TIMER1_MR1_LAST
		; Clear TIMER1_MR1 Interrupt
		LDR r0, =0xE0008000
		MOV r1, #0x2
		STR r1, [r0]
		B FIQ_Exit
		
TIMER1_MR2_LAST
		; Clear TIMER1_MR2 Interrupt
		LDR r0, =0xE0008000
		MOV r1, #0x4
		STR r1, [r0]
		B FIQ_Exit

TIMER1_MR3_LAST
		; Clear TIMER1_MR3 Interrupt
		LDR r0, =0xE0008000
		MOV r1, #0x8
		STR r1, [r0]
		
FIQ_Exit
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4

print_board		; Prints new board + score
		STMFD SP!, {r0, r10, lr}   ; Save registers
		
		LDR r0, =board
		BL output_string
		LDR r0, =board1
		BL output_string
		LDR r0, =board2
		BL output_string
		LDR r0, =board3
		BL output_string
		LDR r0, =board4
		BL output_string
		LDR r0, =board5
		BL output_string
		LDR r0, =board6
		BL output_string
		LDR r0, =board7
		BL output_string
		LDR r0, =board8
		BL output_string
		LDR r0, =board9
		BL output_string
		LDR r0, =board10
		BL output_string
		LDR r0, =board11
		BL output_string
		LDR r0, =board12
		BL output_string
		LDR r0, =board13
		BL output_string
		LDR r0, =board14
		BL output_string
		LDR r0, =board15
		BL output_string
		LDR r0, =board16
		BL output_string
		LDR r0, =board17
		BL output_string
		LDR r0, =board18
		BL output_string
		LDR r0, =board19
		BL output_string
		LDR r0, =board20
		BL output_string
		LDR r0, =board21
		BL output_string
		LDR r0, =board22
		BL output_string
		LDR r0, =board23
		BL output_string
		LDR r0, =board24
		BL output_string
		
		BL print_score
		
		BL save_cursor
		
		LDMFD SP!, {r0, r10, lr}		; Restore registers
		BX lr

reset_player	; Resets the player to the top square
		STMFD SP!, {r0, r1, r10, lr}
		
		LDR r1, =playerposition
		; Remove player from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x48
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		MOV r0, #0x30
		STRB r0, [r1]
		MOV r0, #0x32
		STRB r0, [r1, #0x1]
		MOV r0, #0x31
		STRB r0, [r1, #0x2]
		MOV r0, #0x35
		STRB r0, [r1, #0x3]
		
		; Place player at start position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x48
		BL output_character
		MOV r0, #0x51
		BL output_character
		
		LDR r1, =bounds
		MOV r0, #0x31
		STRB r0, [r1]
		STRB r0, [r1, #0x1]
		
		LDMFD SP!, {r0, r1, r10, lr}
		BX lr

reset_enemy
		STMFD SP!, {r0, r1, r10, lr}
		
		; Reset enemybounds
		LDR r0, =enemybounds
		MOV r1, #0x30
		STRB r1, [r0]
		STRB r1, [r0, #0x1]

		; Reset enemy position
		LDR r0, =enemyposition
		MOV r1, #0x30
		STRB r1, [r0]
		STRB r1, [r0, #0x1]
		STRB r1, [r0, #0x2]
		STRB r1, [r0, #0x3]
		
		LDMFD SP!, {r0, r1, r10, lr}
		BX lr

reset_snake
		STMFD SP!, {r0, r1, r10, lr}

		; Reset snakebounds
		LDR r0, =snakebounds
		MOV r1, #0x30
		STRB r1, [r0]
		STRB r1, [r0, #0x1]

		; Reset snake position
		LDR r0, =snakeposition
		MOV r1, #0x30
		STRB r1, [r0]
		STRB r1, [r0, #0x1]
		STRB r1, [r0, #0x2]
		STRB r1, [r0, #0x3]
		
		; Reset snakestate
		LDR r0, =snakestate
		MOV r1, #0x30
		STRB r1, [r0]

		LDMFD SP!, {r0, r1, r10, lr}
		BX lr
		
clear_enemy
		STMFD SP!, {r0, r1, r10, lr}
		
		LDR r1, =enemyposition
		; Remove player from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x48
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		LDMFD SP!, {r0, r1, r10, lr}
		BX lr

clear_snake
		STMFD SP!, {r0, r1, r10, lr}
		
		LDR r1, =snakeposition
		; Remove egg/snake from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x48
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		LDMFD SP!, {r0, r1, r10, lr}
		BX lr
		
move_up_player		; Moves the player up 
		STMFD SP!, {r0-r2, r10, lr}
		
		LDR r1, =playerposition
		; Remove player from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update player's position to new position
		BL increment_ypos
		BL decrement_xpos
		BL decrement_xpos
		BL decrement_xpos
		BL decrement_xpos
		
		; Place player on new position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x51
		BL output_character

		BL increment_ypos
		
		LDR r2, =bounds
		LDRB r0, [r2]
		SUB r0, r0, #0x1
		STRB r0, [r2]
		
		LDMFD SP!, {r0-r2, r10, lr}
		BX lr
		
move_left_player	; Moves the player to the left
		STMFD SP!, {r0-r2, r10, lr}
		
		LDR r1, =playerposition
		; Remove player from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update player's position to new position
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_xpos
		BL decrement_xpos
		
		; Place player on new position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x51
		BL output_character
		
		BL increment_ypos
		
		LDR r2, =bounds
		LDRB r0, [r2, #0x1]
		SUB r0, r0, #0x1
		STRB r0, [r2, #0x1]
		
		LDMFD SP!, {r0-r2, r10, lr}
		BX lr
		
move_down_player	; Moves the player down
		STMFD SP!, {r0-r2, r10, lr}
		
		LDR r1, =playerposition
		; Remove player from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update player's position to new position
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL increment_xpos
		BL increment_xpos
		BL increment_xpos
		BL increment_xpos
		
		; Place player on new position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x51
		BL output_character

		BL increment_ypos
		
		LDR r2, =bounds
		LDRB r0, [r2]
		ADD r0, r0, #0x1
		STRB r0, [r2]
		
		LDMFD SP!, {r0-r2, r10, lr}
		BX lr
		
move_right_player	; Moves the player to the right
		STMFD SP!, {r0-r2, r10, lr}
		
		LDR r1, =playerposition
		; Remove player from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update player's position to new position
		BL increment_ypos
		BL increment_ypos
		BL increment_ypos
		BL increment_ypos
		BL increment_xpos
		BL increment_xpos
		
		; Place player on new position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		MOV r0, #0x51
		BL output_character

		BL increment_ypos
		
		LDR r2, =bounds
		LDRB r0, [r2, #0x1]
		ADD r0, r0, #0x1
		STRB r0, [r2, #0x1]
		
		LDMFD SP!, {r0-r2, r10, lr}
		BX lr
		
increment_xpos		; Increase r1's x-position
		STMFD SP!, {r0, r10, lr}
		
		LDRB r0, [r1, #0x1]
		CMP r0, #0x39
		BNE INC1
		SUB r0, r0, #0x9
		STRB r0, [r1, #0x1]
		LDRB r0, [r1]
		ADD r0, r0, #0x1
		STRB r0, [r1]
		B XINCDONE
INC1	ADD r0, r0, #0x1
		STRB r0, [r1, #0x1]
XINCDONE
		LDMFD SP!, {r0, r10, lr}
		BX lr

decrement_xpos		; Decrease player x-position
		STMFD SP!, {r0, r10, lr}
		
		LDRB r0, [r1, #0x1]
		CMP r0, #0x30
		BNE DEC1
		ADD r0, r0, #0x9
		STRB r0, [r1, #0x1]
		LDRB r0, [r1]
		SUB r0, r0, #0x1
		STRB r0, [r1]
		B XDECDONE
DEC1	SUB r0, r0, #0x1
		STRB r0, [r1, #0x1]
XDECDONE
		LDMFD SP!, {r0, r10, lr}
		BX lr

increment_ypos		; Increase player y-position
		STMFD SP!, {r0, r10, lr}
		
		LDRB r0, [r1, #0x3]
		CMP r0, #0x39
		BNE INC
		SUB r0, r0, #0x9
		STRB r0, [r1, #0x3]
		LDRB r0, [r1, #0x2]
		ADD r0, r0, #0x1
		STRB r0, [r1, #0x2]
		B YINCDONE
INC		ADD r0, r0, #0x1
		STRB r0, [r1, #0x3]
YINCDONE
		LDMFD SP!, {r0, r10, lr}
		BX lr

decrement_ypos		; Decrease player y-position
		STMFD SP!, {r0, r10, lr}
		
		LDRB r0, [r1, #0x3]
		CMP r0, #0x30
		BNE DEC
		ADD r0, r0, #0x9
		STRB r0, [r1, #0x3]
		LDRB r0, [r1, #0x2]
		SUB r0, r0, #0x1
		STRB r0, [r1, #0x2]
		B YDECDONE
DEC		SUB r0, r0, #0x1
		STRB r0, [r1, #0x3]
YDECDONE
		LDMFD SP!, {r0, r10, lr}
		BX lr

visit_square	; Checks the square state based on bound and saves either a 1 or 0 in r1 
		STMFD sp!, {r1-r4, r10, lr}
		
		; Equation to determine square bit
		LDR r1, =bounds
		LDRB r2, [r1]
		LDRB r3, [r1, #0x1]
		SUB r2, r2, #0x31
		SUB r3, r3, #0x31
		MOV r4, r2, LSL #0x2
		ADD r4, r2, r4
		ADD r4, r2, r4
		ADD r2, r4, r3
		
		; Get the bit of squarestate
		LDR r1, =squarestate
		LDRB r0, [r1, r2]
		
		; Set square to visited
		MOV r3, #0x30
		STRB r3, [r1, r2]
		
		CMP r0, #0x31
		BNE FIN1
		BL increment_score_ten
		LDR r1, =visitedsquares
		LDRB r0, [r1, #0x1]
		CMP r0, #0x39
		BNE INC2
		SUB r0, r0, #0x9
		STRB r0, [r1, #0x1]
		LDRB r2, [r1]
		ADD r2, r2, #0x1
		STRB r2, [r1]
		B FIN1
INC2	ADD r0, r0, #0x1
		STRB r0, [r1, #0x1]		
FIN1
		LDMFD sp!, {r1-r4, r10, lr}
		BX lr
		
lose_life	; Turns off a LED each time a life is lost
		STMFD sp!, {r0, r1, r10, lr}
		
		LDR r0, =life
		LDRB r1, [r0]
		SUB r1, r1, #0x1
		STRB r1, [r0]
		
		; Remove enemies and stop them from spawning
		BL clear_enemy
		BL reset_enemy
		BL stop_spawn
		BL clear_snake
		BL reset_snake
		BL stop_spawn_egg
		
		BL illuminate_RED
		MOV r0, #0x160000
DELAY	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY
		
		BL RGB_LED_off
		MOV r0, #0x160000
DELAY1	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY1
		
		BL illuminate_RED
		MOV r0, #0x160000
DELAY2	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY2
		
		BL RGB_LED_off
		MOV r0, #0x160000
DELAY3	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY3
		
		BL illuminate_RED
		MOV r0, #0x160000
DELAY4	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY4
		
		BL RGB_LED_off
		MOV r0, #0x160000
DELAY5	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY5
		
		BL illuminate_RED
		MOV r0, #0x160000
DELAY6	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY6
		
		BL RGB_LED_off
		MOV r0, #0x160000
DELAY7	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY7
		
		BL illuminate_RED
		MOV r0, #0x160000
DELAY8	SUB r0, r0, #0x1
		CMP r0, #0x0
		BNE DELAY8
		
		LDR r1, =0xE0028010
		LDR r0, [r1]
		ORR r0, r0, #0x00100000
		MOV r0, r0, ROR #0x1
		BIC r0, r0, #0xFFF0FFFF
		LDR r1, =0xE0028014	
		STR r0, [r1]
		
		CMP r0, #0xF0000
		BEQ OVER
		BL illuminate_GREEN
		; Setting up MR2 to spawn enemy after 2 seconds of losing a life
		LDR r0, =0xE0008008
		LDR r1, [r0]
		ADD r1, r1, #0x2000000
		ADD r1, r1, #0x0300000
		ADD r1, r1, #0x0020000
		ADD r1, r1, #0x0008000
		BL set_MR2_timer1
		; Setting up MR3 to spawn egg after 10 seconds of losing a life
		LDR r0, =0xE0008008
		LDR r1, [r0]
		ADD r1, r1, #0xA000000
		ADD r1, r1, #0x0F00000
		ADD r1, r1, #0x00C0000
		ADD r1, r1, #0x0008000
		BL set_MR3_timer1
		B FIN2
OVER	BL game_over
FIN2		
		LDMFD sp!, {r0, r1, r10, lr}
		BX lr
		LTORG
		
game_over	; Turns off TIMERS and prints the game-over prompts
		STMFD sp!, {r0-r3, r10, lr}		
		
		BL illuminate_PURPLE
		
		BL reset_TIMER0
		BL reset_TIMER1
		BL disable_TIMER0
		BL disable_TIMER1
		
		; Adding points for each life
		LDR r1, =0xE0028010
		LDR r0, [r1]
		ORR r0, r0, #0x00100000
LIFE	MOV r2, r0, LSR #0x10
		AND r2, r2, #0x1
		CMP r2, #0x1  
		BNE	INCSCORE
		B GAMEOV

INCSCORE
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_one
		BL increment_score_one
		BL increment_score_one
		BL increment_score_one
		BL increment_score_one
		MOV r0, r0, LSR #0x1
		B LIFE

GAMEOV	LDR r0, =gameover
		BL output_string
		
		BL print_score
		
		LDR r0, =restart
		BL output_string
		
		; Reset gamestate to main menu/gameover
		LDR r0, =gamestate
		MOV r1, #0x30
		STRB r1, [r0]
		
		; Reset player position
		LDR r1, =playerposition
		MOV r0, #0x30
		STRB r0, [r1]
		MOV r0, #0x32
		STRB r0, [r1, #0x1]
		MOV r0, #0x31
		STRB r0, [r1, #0x2]
		MOV r0, #0x35
		STRB r0, [r1, #0x3]
		
		; Reset player coordinates
		LDR r1, =bounds
		MOV r0, #0x31
		STRB r0, [r1]
		STRB r0, [r1, #0x1]
		
		; Reset visited squares
		LDR r1, =visitedsquares
		MOV r0, #0x30
		STRB r0, [r1]
		STRB r0, [r1, #0x1]
		
		; Reset score
		LDR r1, =score
		STRB r0, [r1]
		STRB r0, [r1, #0x1]
		STRB r0, [r1, #0x2]
		STRB r0, [r1, #0x3]
		
		; Remove enemies and stop them from spawning
		BL reset_enemy
		BL stop_spawn
		BL reset_snake
		BL stop_spawn_egg

		; Reset level
		LDR r1, =level
		STRB r0, [r1]

		; Reset TIMER0 to update every half a second
		LDR r7, =0x8CA000
		
		; Reset board state
		LDR r0, =newstate
		LDR r1, =squarestate
		MOV r2, #0x0
LOOP	LDRB r3, [r0]
		STRB r3, [r1, r2]
		ADD r2, r2, #0x1
		CMP r2, #0x1F
		BLT LOOP		
		
		LDMFD sp!, {r0-r3, r10, lr}
		BX lr

increment_score_one		; Increment score by 1 (used for leftover lives)
		STMFD sp!, {r0-r4, r10, lr}

		LDR r0, =score
		LDRB r1, [r0, #0x3]
		CMP r1, #0x39
		BLT INC10
		SUB r1, r1, #0xA
		LDRB r2, [r0, #0x2]
		CMP r2, #0x39
		BLT INC11
		SUB r2, r2, #0xA
		LDRB r3, [r0, #0x1]
		CMP r3, #0x39
		BLT INC12
		SUB r3, r3, #0xA
		LDRB r4, [r0]
		ADD r4, r4, #0x1
		STRB r4, [r0]
		
INC12	ADD r3, r3, #0x1
		STRB r3, [r0, #0x1]		

INC11	ADD r2, r2, #0x1
		STRB r2, [r0, #0x2]
		
INC10	ADD r1, r1, #0x1
		STRB r1, [r0, #0x3]		
		
		LDMFD sp!,{r0-r4, r10, lr}
		BX lr
		
increment_score_ten	; Increment score by 10 (used for each time a square is visited for the first time)
		STMFD sp!, {r0-r3, r10, lr}

		LDR r0, =score
		LDRB r1, [r0, #0x2]
		CMP r1, #0x39
		BLT INC20
		SUB r1, r1, #0xA
		LDRB r2, [r0, #0x1]
		CMP r2, #0x39
		BLT INC21
		SUB r2, r2, #0xA
		LDRB r3, [r0]
		ADD r3, r3, #0x1
		STRB r3, [r0]
		
INC21	ADD r2, r2, #0x1
		STRB r2, [r0, #0x1]
		
INC20	ADD r1, r1, #0x1
		STRB r1, [r0, #0x2]
		
		LDMFD sp!,{r0-r3, r10, lr}
		BX lr

next_level		; Performs necessary actions when a new level is loaded
		STMFD sp!, {r0-r3, r10, lr}
		
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		BL increment_score_ten
		
		BL print_board		

		LDR r1, =level
		LDRB r0, [r1]
		ADD r0, r0, #0x1
		STRB r0, [r1]
		SUB r0, r0, #0x30
		BL display_digit_on_7_seg

		; Reset player position
		LDR r1, =playerposition
		MOV r0, #0x30
		STRB r0, [r1]
		MOV r0, #0x32
		STRB r0, [r1, #0x1]
		MOV r0, #0x31
		STRB r0, [r1, #0x2]
		MOV r0, #0x35
		STRB r0, [r1, #0x3]
		
		; Reset player coordinates
		LDR r1, =bounds
		MOV r0, #0x31
		STRB r0, [r1]
		STRB r0, [r1, #0x1]
		
		; Reset visited squares
		LDR r1, =visitedsquares
		MOV r0, #0x30
		STRB r0, [r1]
		STRB r0, [r1, #0x1]
		
		; Reset board state
		LDR r0, =newstate
		LDR r1, =squarestate
		MOV r2, #0x0
LOOP1	LDRB r3, [r0]
		STRB r3, [r1, r2]
		ADD r2, r2, #0x1
		CMP r2, #0x1F
		BLT LOOP1
		
		; Update new TIMER0 interrupt
		SUB r7, r7, #0x100000
		SUB r7, r7, #0xC0000
		SUB r7, r7, #0x2000
		BL set_MR1_timer0
		
		; Setting up MR2 to spawn enemy after 2 seconds of starting a new level
		LDR r0, =0xE0008008
		LDR r1, [r0]
		ADD r1, r1, #0x2000000
		ADD r1, r1, #0x0300000
		ADD r1, r1, #0x0020000
		ADD r1, r1, #0x0008000
		BL set_MR2_timer1
		
		; Setting up MR3 to spawn enemy after 10 seconds of starting a new level
		LDR r0, =0xE0008008
		LDR r1, [r0]
		ADD r1, r1, #0xA000000
		ADD r1, r1, #0x0F00000
		ADD r1, r1, #0x00C0000
		ADD r1, r1, #0x0008000
		BL set_MR3_timer1
		
		; Reset enemy
		BL reset_enemy
		BL reset_snake

		; Stop enemy spawn
		BL stop_spawn
		BL stop_spawn_egg

		; Reset movementdelay
		LDR r0, =movementdelay
		MOV r1, #0x30
		STRB r1, [r0]

		LDMFD sp!,{r0-r3, r10, lr}
		BX lr

save_cursor		; Saves the current cursor position
		STMFD sp!, {r0, lr}
		
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		MOV r0, #0x73
		BL output_character
		
		LDMFD sp!,{r0, lr}
		BX lr
		
load_cursor		; Load the saved cursor position
		STMFD sp!, {r0, lr}
		
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		MOV r0, #0x75
		BL output_character
		
		LDMFD sp!,{r0, lr}
		BX lr
		
update_score	; Updates the score 
		STMFD sp!, {r0, lr}
		
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		MOV r0, #0x32
		BL output_character
		MOV r0, #0x36
		BL output_character
		MOV r0, #0x3B
		BL output_character
		MOV r0, #0x30
		BL output_character
		MOV r0, #0x37
		BL output_character
		MOV r0, #0x66
		BL output_character
		
		LDR r0, =score
		BL output_string
		
		LDMFD sp!,{r0, lr}
		BX lr
		
place_character		; Places either the player or enemy character from position stored in r1
		STMFD sp!, {r0, lr}
		
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		
		LDR r1, =character
		LDRB r0, [r1]
		BL output_character
		
		
		LDMFD sp!,{r0, lr}
		BX lr
		
spawn_enemy		; Sets up the first enemy and places it on the board
		STMFD sp!, {r0-r3, lr}
		
		BL random_start
		CMP r1, #0x0
		BNE START
		; Setting enemybounds
		LDR r0, =enemybounds
		MOV r1, #0x31
		STRB r1, [r0]
		MOV r1, #0x32
		STRB r1, [r0, #0x1]
		; Setting enemy position
		LDR r0, =enemyposition
		LDR r1, =enemystartposition0
		MOV r3, #0x0
LOOP2	LDRB r2, [r1, r3]
		STRB r2, [r0, r3]
		ADD r3, r3, #0x1
		CMP r3, #0x4
		BNE LOOP2
		B NEXT
		; Setting enemybounds
START	LDR r0, =enemybounds
		MOV r1, #0x31
		STRB r1, [r0, #0x1]
		MOV r1, #0x32
		STRB r1, [r0]
		; Setting enemy position
		LDR r0, =enemyposition
		LDR r1, =enemystartposition1
		MOV r3, #0x0
LOOP3	LDRB r2, [r1, r3]
		STRB r2, [r0, r3]
		ADD r3, r3, #0x1
		CMP r3, #0x4
		BNE LOOP3

NEXT	LDR r1, =character
		MOV r2, #0x6F
		STRB r2, [r1]
		LDR r1, =enemyposition
		BL place_character

		LDMFD sp!,{r0-r3, lr}
		BX lr
		
print_score		; Prints score
		STMFD sp!, {r0, lr}		
		
		; Prints score
		LDR r0, =scoreprompt
		BL output_string
		LDR r0, =score
		BL output_string
		
		LDMFD sp!,{r0, lr}
		BX lr

move_up_enemy	; read enemyposition from r1 and enemybounds from r2
		STMFD SP!, {r0, r10, lr}
		
		; Remove enemy from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update enemy's position to new position
		BL increment_ypos
		BL increment_ypos
		BL decrement_xpos
		BL decrement_xpos
		BL decrement_xpos
		BL decrement_xpos
		
		; Place enemy on new position
		BL place_character
		
		LDRB r0, [r2]
		SUB r0, r0, #0x1
		STRB r0, [r2]
		
		LDMFD SP!, {r0, r10, lr}
		BX lr
		
move_left_enemy	; read enemyposition from r1 and enemybounds from r2
		STMFD SP!, {r0, r10, lr}
		
		; Remove enemy from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update enemy's position to new position
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_ypos
		BL decrement_xpos
		BL decrement_xpos
		
		; Place enemy on new position
		BL place_character
		
		LDRB r0, [r2, #0x1]
		SUB r0, r0, #0x1
		STRB r0, [r2, #0x1]
		
		LDMFD SP!, {r0, r10, lr}
		BX lr
		
move_down_enemy	; read enemyposition from r1 and enemybounds from r2
		STMFD SP!, {r0, r10, lr}
		
		; Remove enemy from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update enemy's position to new position
		BL decrement_ypos
		BL decrement_ypos
		BL increment_xpos
		BL increment_xpos
		BL increment_xpos
		BL increment_xpos
		
		; Place enemy on new position
		BL place_character
		
		LDRB r0, [r2]
		ADD r0, r0, #0x1
		STRB r0, [r2]
		
		LDMFD SP!, {r0, r10, lr}
		BX lr
		
move_right_enemy	; read enemyposition from r1 and enemybounds from r2
		STMFD SP!, {r0, r10, lr}
		
		; Remove enemy from current position
		MOV r0, #0x1B
		BL output_character
		MOV r0, #0x5B
		BL output_character
		LDRB r0, [r1]
		BL output_character
		LDRB r0, [r1, #0x1]
		BL output_character
		MOV r0, #0x3B
		BL output_character
		LDRB r0, [r1, #0x2]
		BL output_character
		LDRB r0, [r1, #0x3]
		BL output_character
		MOV r0, #0x66
		BL output_character
		MOV r0, #0x20
		BL output_character
		
		; Update enemy's position to new position
		BL increment_ypos
		BL increment_ypos
		BL increment_ypos
		BL increment_ypos
		BL increment_ypos
		BL increment_xpos
		BL increment_xpos
		
		; Place enemy on new position
		BL place_character
		
		LDRB r0, [r2, #0x1]
		ADD r0, r0, #0x1
		STRB r0, [r2, #0x1]
		
		LDMFD SP!, {r0, r10, lr}
		BX lr

start_spawn
		STMFD SP!, {r0, r1, r10, lr}

		LDR r0, =spawn
		MOV r1, #0x31
		STRB r1, [r0]

		LDMFD SP!, {r0, r1, r10, lr}
		BX lr

stop_spawn
		STMFD SP!, {r0, r1, r10, lr}

		LDR r0, =spawn
		MOV r1, #0x30
		STRB r1, [r0]

		LDMFD SP!, {r0, r1, r10, lr}
		BX lr
		
start_spawn_egg
		STMFD SP!, {r0, r1, r10, lr}

		LDR r0, =spawnegg
		MOV r1, #0x31
		STRB r1, [r0]

		LDMFD SP!, {r0, r1, r10, lr}
		BX lr

stop_spawn_egg
		STMFD SP!, {r0, r1, r10, lr}

		LDR r0, =spawnegg
		MOV r1, #0x30
		STRB r1, [r0]

		LDMFD SP!, {r0, r1, r10, lr}
		BX lr
		
spawn_egg		; Sets up the first enemy and places it on the board
		STMFD sp!, {r0-r3, lr}
		
		BL random_start
		CMP r1, #0x0
		BNE START10
		; Setting snakebounds
		LDR r0, =snakebounds
		MOV r1, #0x31
		STRB r1, [r0]
		MOV r1, #0x32
		STRB r1, [r0, #0x1]
		; Setting snake position
		LDR r0, =snakeposition
		LDR r1, =enemystartposition0
		MOV r3, #0x0
LOOP12	LDRB r2, [r1, r3]
		STRB r2, [r0, r3]
		ADD r3, r3, #0x1
		CMP r3, #0x4
		BNE LOOP12
		B NEXT10
		; Setting snakebounds
START10	LDR r0, =snakebounds
		MOV r1, #0x31
		STRB r1, [r0, #0x1]
		MOV r1, #0x32
		STRB r1, [r0]
		; Setting snake position
		LDR r0, =snakeposition
		LDR r1, =enemystartposition1
		MOV r3, #0x0
LOOP13	LDRB r2, [r1, r3]
		STRB r2, [r0, r3]
		ADD r3, r3, #0x1
		CMP r3, #0x4
		BNE LOOP13

NEXT10	LDR r1, =character
		MOV r2, #0x6C
		STRB r2, [r1]
		LDR r1, =snakeposition
		BL place_character

		LDR r0, =spawnegg
		MOV r1, #0x31
		STRB r1, [r0]

		LDMFD sp!,{r0-r3, lr}
		BX lr

        END