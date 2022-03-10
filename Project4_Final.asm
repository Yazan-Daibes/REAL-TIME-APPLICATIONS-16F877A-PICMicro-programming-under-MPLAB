

	PROCESSOR 16F877	; Define MCU type
	__CONFIG 0x3731		; Set config fuses
	INCLUDE "P16F877A.INC"	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Defined variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
var1 				EQU 20 ; for loop1 in delay
var2 				EQU 21 ; for loop2 in dela 
var3 				EQU 22 ; for loop3 in delay
step 				EQU 23 ; steps to be incremented
pause_time 			EQU 24 ; pause time to be incremented
Temp_s1 			EQU 25 ; for checking steps = 1
Temp_s2             EQU 26 ; for checking steps = 2
Temp_s3             EQU 27 ; for checking steps = 3
Temp_s4             EQU 28 ; for checking steps = 4
Temp_s5             EQU 29 ; for checking steps = 5
Temp_s6             EQU 30 ; for checking steps = 6 (then go back to 1)
compare_var 		EQU 31 ; compare variable used in the steps
temp_pause_delay	EQU 32 ; temp delay variable
temp_pause_time		EQU 33 ; temp delay variable 
PORTB   			EQU 06 ; Port B Data Register        
PORTD   			EQU 08 ; Port D Data Register  
TRISD				EQU	88 ; Port D Direction Register
TMR0				EQU	01 ; Hardware Timer Register
INTCON				EQU	0B ; Interrupt Control Register
OPTREG				EQU	81 ; Option Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of program memory ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
ORG	000		
	NOP			
	GOTO	init		; Jump to main program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Interrupt Service Routine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG	004
RB0Int		btfss INTCON,1			; Check if interrupt on RB0 occurred (INTF)
            goto  RBPort
			
			bcf   INTCON,1			; re-initializing flag INTF to 0
			INCF  pause_time,f
			goto  Cont

RBPort		btfss INTCON,0			; Check if RB Port Change Interrupt occurred (RBIF)			
			goto  Cont
						
			btfsc PORTB,4			; Check if pin RB4 is low
			goto  Clr_RBINTF
			
			INCF step,f

			
			
			
Clr_RBINTF	movf PORTB,1 			; Read PortB (to itself) to end mismatch condition
			bcf INTCON,0			; Clear the RB interrupt flag.				
			goto Cont

Cont			retfie
; 	; BTFSC	INTCON,2
; 	; GOTO ISR_P2
; 	BCF		INTCON,2	; Reset TMR0 interrupt flag	
; 	BTFSC	INTCON,INTF	; Check if has RB0/INT has Occured
; 	GOTO 	ISR_P1	
; 	RETFIE

; ISR_P1 

; 	BCF	 INTCON,INTF   ; Reset RB0/INT interrupt flag
; 	INCF pause_time,f  ; Increment pause time
; 	RETFIE 
; ; ISR_P2
; ; 	BCF		INTCON,2	   ; Reset TMR0 interrupt flag	
; ; 	RETFIE
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initialization & Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
init	
	NOP						; BANKSEL cannot be labelled
	BANKSEL	TRISD			; Select bank 1
    MOVLW   b'00000000' 	; Port D Direction Code is output
    MOVWF	TRISD          	; Load the direction to TRISD
	
	MOVLW	b'11011000'		; TMR0 initialisation code
	MOVWF	OPTREG			; Int clock, no prescale	
	BANKSEL	PORTD			; Select bank 0
	MOVLW	b'10110000'		; INTCON init. code
	MOVWF	INTCON			; Enable TMR0 interrupt and INTE interrupt

	CLRF step				; Clear step variable
	CLRF pause_time			; Clear pause time variable
	CLRF temp_pause_time    ; Clear pause time temp variable
	INCF step,f 			; step = 1 : to start from 1
	INCF pause_time,f 		; pause_time = 1 : to start from 1

reset   CLRF    PORTD  		; Clear Port d Data 

; Start main loop ...........................................
start  

	;Check if step is 1
	MOVF    step,W
	MOVWF	Temp_s1
	MOVLW 	d'1'
	SUBWF   Temp_s1,W 		; (step=temp_s1) - 1 
	BTFSC   STATUS,Z
	GOTO    step_one  		; if zero flag = 1 then go to step one

	;Check if step is 2
	MOVF 	step,W
	MOVWF 	Temp_s2
	MOVLW 	d'2'
	SUBWF 	Temp_s2,W 		;(step=temp_s2) - 2
	BTFSC 	STATUS,Z
	GOTO 	step_two		; if zero flag = 1 then go to step two
	
	;Check if step is 3
	MOVF 	step,W
	MOVWF 	Temp_s3
	MOVLW 	d'3'
	SUBWF 	Temp_s3,W  		;(step=temp_s3) - 3
	BTFSC 	STATUS,Z
	GOTO 	step_three 		; if zero flag = 1 then go to step three

	;Check if step is 4
	MOVF 	step,W
	MOVWF 	Temp_s4
	MOVLW 	d'4'
	SUBWF 	Temp_s4,W 		;(step=temp_s4) - 4
	BTFSC 	STATUS,Z 
	GOTO 	step_four 		; if zero flag = 1 then go to step four

	;Check if step is 5
	MOVF 	step,W
	MOVWF 	Temp_s5
	MOVLW 	d'5'
	SUBWF 	Temp_s5,W 		;(step=temp_s5) - 5
	BTFSC 	STATUS,Z
	GOTO 	step_five 		; if zero flag = 1 then go to step five

	;Check if step is 6 then put step back to 1
	MOVF 	step,W
	MOVWF 	Temp_s6
	MOVLW 	d'6'
	SUBWF 	Temp_s6,W 		 ;(step=temp_s6) - 5
	BTFSC 	STATUS,Z
	GOTO 	step_start_over  ; if zero flag = 1 then start over

; ; Pull up loop on RB4 ...........................................
; check_step_btn
; 	BTFSC  	PORTB,4  	; Test step button
; 	GOTO  	start        ; and repeat if not pressed
; 	CLRF	TMR0		; Reset timer
; wait	
; 	BTFSS	INTCON,2	; Check for time out
; 	GOTO	wait		; Wait if not
; stepin	
; 	BTFSS	PORTB,4		; Check step button
; 	GOTO	stepin		; and wait until released
;     INCF 	step,f      ; Increment step 
;     GOTO   	start       ; Repeat main loop always

; delay .......................................................
delay
	; check the pause 
	MOVLW   d'6'  				 ;pause = 6 then reset to 1
	MOVWF   temp_pause_delay    
	MOVF    pause_time,W
	SUBWF   temp_pause_delay, W  ; 6 - pause time
	BTFSC 	STATUS,Z
	GOTO 	reached_max_time
	BTFSS 	STATUS,C
	GOTO 	reached_max_time

	MOVF	pause_time,W		; moved pause time to a temp variable b/c I don't want the aoriginal pause time to be changed
	MOVWF	temp_pause_time
loop4 							; loop4 is outer loop that loops based on the value of pause time
    movlw d'4' ; 4
	movwf var3
loop3							 ; loop3, loop2 and loop1 are for doing 1 sec (1 Million instruction)
	movlw d'200' ;200
	movwf var2
loop2
	movlw d'250' ; 250
	movwf var1
loop1
    NOP
    NOP
	decfsz var1,f
	GOTO loop1
	decfsz var2,f
	GOTO loop2
	decfsz var3,f
 	GOTO loop3

    ; loop # of time the pause button is pressed (to have one second or more delays-up to 5-)
	decfsz	temp_pause_time,f     ; decrement temp_time in order not to mess with the actual pasue_time (the actual should remain the same)
	GOTO	loop4

GOTO   	check_step_btn  		  ; after the delay we check if the button on RB4 is pressed (RB4)


step_one

	; compare and jump when PORTD > 31
	MOVLW 	d'31' 		  ; W = 31 
	MOVWF   compare_var   ; compare_var = W = 32
	MOVF    PORTD,W 	  ; W = PORTD
	SUBWF   compare_var,W ; 31 - compare_var
	BTFSC 	STATUS,Z
	GOTO 	reached_max_steps
	BTFSS 	STATUS,C
	GOTO 	reached_max_steps
	; turn ON the LEDs after checking in order to avoid turning ON the unused pins
	MOVLW 	d'1'
	ADDWF 	PORTD,f 	; PORTD+= W
	
	GOTO   delay
step_two
    
	; compare and jump when PORTD > 31
	MOVLW 	d'30' 		  ; W = 30.....  30 + 2 will give 32 (max + 1 > 31 = max) so start_over
	MOVWF   compare_var   ; compare_var = W = 30
	MOVF    PORTD,W 	  ; W = PORTD
	SUBWF   compare_var,W ; 32 - compare_var
	BTFSC 	STATUS,Z
	GOTO 	reached_max_steps
	BTFSS 	STATUS,C
	GOTO 	reached_max_steps
	; turn ON the LEDs after checking in order to avoid turning ON the unused Pins
	MOVLW 	d'2'
	ADDWF 	PORTD,f ; PORTD+= W
	GOTO   	delay

step_three
	; compare and jump when PORTD > 31
	MOVLW 	d'29' 		  ; W = 29.....  29 + 3 will give 32 (max + 1 > 31 = max) so start_over
	MOVWF   compare_var   ; compare_var = W = 29
	MOVF    PORTD,W 	  ; W = PORTD
	SUBWF   compare_var,W ; 33 - compare_var
	BTFSC 	STATUS,Z
	GOTO 	reached_max_steps
	BTFSS 	STATUS,C
	GOTO 	reached_max_steps
	; turn ON the LEDs after checking in order to avoid turning ON the unused Pins
	MOVLW 	d'3'
	ADDWF 	PORTD,f
	GOTO   	delay 
	step_four
	
	; compare and jump when PORTD > 31
	MOVLW 	d'28' 		  ; W = 28.....  28 + 4 will give 32 (max + 1 > 31 = max) so start_over
	MOVWF   compare_var   ; compare_var = W = 28
	MOVF    PORTD,W 	  ; W = PORTD
	SUBWF   compare_var,W ; 32 - compare_var
	BTFSC 	STATUS,Z
	GOTO 	reached_max_steps
	BTFSS 	STATUS,C
	GOTO 	reached_max_steps
	; turn ON the LEDs after checking in order to avoid turning ON the unused Pins
	MOVLW 	d'4'
	ADDWF 	PORTD,f
	GOTO   	delay
	step_five

	; compare and jump when PORTD > 31
	MOVLW 	d'27' 		  ; W = 27.....  27 + 5 will give 32 (max + 1 > 31 = max) so start_over
	MOVWF   compare_var   ; compare_var = W = 27
	MOVF    PORTD,W 	  ; W = PORTD
	SUBWF   compare_var,W ; 35 - compare_var
	BTFSC 	STATUS,Z
	GOTO 	reached_max_steps
	BTFSS 	STATUS,C
	GOTO 	reached_max_steps
	; turn ON the LEDs after checking in order to avoid turning ON the unused Pins
	MOVLW 	d'5'
	ADDWF 	PORTD,f
	GOTO   	delay

step_start_over	
	; clear the step and set it to 1 to go back to step_one
	CLRF step	    ; clear the step because it exceeded 5
	INCF step,f		; Increment step by one to start from 1
	GOTO start		; Go to start

; steps = 6 then start over by clearing PORTD .................
reached_max_steps
	CLRF PORTD 
	GOTO start

; pause time = 6 then start over by clearing pause time variable .................
reached_max_time
	CLRF pause_time	  ; clear the pause time because it exceeded 5
	INCF pause_time,f ; Increment pause time by one to start from 1 sec
	GOTO start		  ; Go to start

END





