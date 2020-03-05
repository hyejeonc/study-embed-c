.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s" // Register-adresser og konstanter for SysTick

.text
	.global Start
	

Minutes:
	LDR R1, =minutes
	LDR R0, [R1]
	LDR R2, =#1
	ADD R0, R2, R0
	STR R0, [R1]
	MOV PC, LR

Seconds:
	LDR R1, =seconds
	LDR R0, [R1]
	CMP R0, #59
	BNE SECONDS_OVERFLOW
	LDR R2, =#0
	STR R2, [R1]
	PUSH {LR}
	BL Minutes
	POP {LR}
	B END_SECONDS

	SECONDS_OVERFLOW:
	LDR R2, =#1
	ADD R0, R2, R0
	STR R0, [R1]

	END_SECONDS:
	PUSH {LR}
	BL LED_Toggle
	POP {LR}
	MOV PC, LR

Tenths:
	LDR R1, =tenths
	LDR R0, [R1]
	CMP R0, #9
	BNE TENTHS_OVERFLOW
	LDR R2, =#0
	STR R2, [R1]
	PUSH {LR}
	BL Seconds
	POP {LR}
	B END_TENTHS

	TENTHS_OVERFLOW:
	LDR R2, =#1
	ADD R0, R2, R0
	STR R0, [R1]

	END_TENTHS:
	MOV PC, LR

LED_Toggle:
	STR R0, [R5]
	LDR R0, =LED_PORT
	LDR R1, =PORT_SIZE
	MUL R0, R0, R1
	LDR R1, =GPIO_BASE
	ADD R0, R1, R0
	LDR R1, =#1
	LSL R1, R1, #LED_PIN
	LDR R2, =seconds
	LDR R2, [R2]
	AND R2, R2, #1
	CMP R2, #0
	BNE LED_ON
	LDR R2, =GPIO_PORT_DOUTCLR
	STR R1, [R0, R2]
	B LED_END

	LED_ON:
	MOV R3, #1
	LDR R2, =GPIO_PORT_DOUTSET
	STR R1, [R0, R2]

	LED_END:
	MOV PC, LR

.global SysTick_Handler
.thumb_func
	SysTick_Handler:
	PUSH {LR}
	BL Tenths
	POP {LR}
	BX LR

.global GPIO_ODD_IRQHandler
.thumb_func

	GPIO_ODD_IRQHandler:
	LDR R0, =SYSTICK_BASE
	LDR R2, [R0]
	AND R2, #1
	CMP R2, #1
	BEQ STOP_CLOCK
	LDR R2, =#0b111
	STR R2, [R0]
	B CLOCK_END

STOP_CLOCK:
	LDR R2, =#0b110
	STR R2, [R0]

CLOCK_END:
	LDR R0, =GPIO_BASE
	LDR R2, =GPIO_IFC
	LDR R0, [R1, R2]
	LDR R3, =#1
	LSL R3, #9
	STR R3, [R1, R2]
	BX LR

Start:
	LDR R0, =SYSTICK_BASE
	LDR R2, =#0b110
	STR R2, [R0]
	LDR R1, =SYSTICK_LOAD
	LDR R2, =FREQUENCY/10
	STR R2, [R0, R1]

	LDR R0, =#0
	LDR R1, =tenths
	STR R0, [R1]

	LDR R0, =GPIO_BASE
	LDR R1, =GPIO_EXTIPSELH
	ADD R0, R1, R0
	LDR R1, =#0b1111
	LSL R1, R1, #4
	MVN R1, R1
	LDR R0, [R0]
	AND R0, R1, R0
	LDR R1, =#0b0001
	LSL R1, #4
	ORR R0, R0, R1
	LDR R1, =GPIO_BASE
	LDR R2, =GPIO_EXTIPSELH
	STR R0, [R1, R2]

	LDR R2, =GPIO_EXTIFALL
	LDR R0, [R1, R2]
	LDR R3, =#1
	LSL R3, #9
	ORR R0, R3, R0
	STR R0, [R1, R2]

	LDR R2, =GPIO_IEN
	LDR R0, [R1, R2]
	ORR R0, R0, R3
	STR R0, [R1, R2]

	LDR R0, =GPIO_BASE
	LDR R2, =GPIO_IFC
	LDR R0, [R1, R2]
	LDR R3, =#1
	LSL R3, #9
	STR R3, [R1, R2]

Loop:
	B Loop

NOP

NOP
