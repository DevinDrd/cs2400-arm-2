		;		ARM Programming Assignment #2: 64 bit signed integer multiplier
		;
		;		Write a 64-bit SIGNED multiplier. It should take only a small modification to your
		;		unsigned version. Remember (-6)*(-6) = 36, (-6)*6 = -36.
		;		Use the standard shift-and-add operation.
		;		Use the two numbers as an example but write it so it works for any two 16-bit numbers.
		;		Note that in VisUAL you cannot store 64-bit values (double words) directly. The upper
		;		and lower words are your higher 32 bits and lower 32 bits of the two numbers,
		;		respectively.
		;		Write the result in the provided "fill" word.
		;		Indicate if there was a high-bit carry using the provided "fill" word.
		
		;		Your code here
		
upper	DCD		0xA0BCFF0D, 0xFFF0ADEA
lower	DCD		0xFFF1AD2A, 0xA0ACEF0D
result	FILL		16
carry	FILL		4
partial	FILL		32
link		FILL		4
		
		MOV		r12, #0			;initialize negative counter
		
		;loads	top a and top b
		ADR		r0, upper
		LDR		r3, [r0]			;loads top a
		ADR		r0, lower
		LDR		r5, [r0]			;loads top b
		MOVS		r0, r3, LSR #31	;get sign bit
		MVNNE	r3, r3			;if negative convert to positive
		ADDNE	r3, r3, #1		;if negative convert to positive
		ADDNE	r12, r12, #1		;if negative add 1 to negative counter
		MOVS		r0, r5, LSR #31	;get sign bit
		MVNNE	r5, r5			;if negative convert to positive
		ADDNE	r5, r5, #1		;if negative convert to positive
		ADDNE	r12, r12, #1		;if negative add 1 to negative counter
		;multiply	(top a) with (top b)
		BL		mul32			;(top a) * (top b)
		ADR		r0, partial
		STR		r1, [r0], #4		;stores top half of  top a * top b
		STR		r3, [r0]			;stores bottom half of top a * top b
		
		;loads	top a and bottom b
		ADR		r0, upper
		LDR		r3, [r0]			;loads top a
		ADR		r0, lower
		LDR		r5, [r0, #4]		;loads bottom b
		MOVS		r0, r3, LSR #31	;get sign bit
		MVNNE	r3, r3			;if negative convert to positive
		ADDNE	r3, r3, #1		;if negative convert to positive
		;multiply	(top a) with (bottom b)
		BL		mul32			;(top a) * (bottom b)
		ADR		r0, partial
		STR		r1, [r0, #8]!		;stores top half of  top a * bottom b
		STR		r3, [r0, #4]		;stores bottom half of top a * bottom b
		
		;loads	bottom a and top b
		ADR		r0, upper
		LDR		r3, [r0, #4]		;loads bottom a
		ADR		r0, lower
		LDR		r5, [r0]			;loads top b
		MOVS		r0, r5, LSR #31	;get sign bit
		MVNNE	r5, r5			;if negative convert to positive
		ADDNE	r5, r5, #1		;if negative convert to positive
		;multiply	(bottom a) with (top b)
		BL		mul32			;(bottom a) * (top b)
		ADR		r0, partial
		STR		r1, [r0, #16]!		;stores top half of  bottom a * top b
		STR		r3, [r0, #4]		;stores bottom half of bottom a * top b
		
		;loads	bottom a and bottom b
		ADR		r0, upper
		LDR		r3, [r0, #4]		;loads bottom a
		ADR		r0, lower
		LDR		r5, [r0, #4]		;loads bottom b
		;multiply	(bottom a) with (bottom b)
		BL		mul32			;(bottom a) * (bottom b)
		ADR		r0, partial
		STR		r1, [r0, #24]!		;stores top half of  bottom a * bottom b
		STR		r3, [r0, #4]		;stores bottom half of bottom a * bottom b
		
		ADR		r0, partial
		LDR		r1, [r0], #4		;loads top of top a * top b
		LDR		r2, [r0], #4		;loads bottom of top a * top b
		LDR		r3, [r0], #4		;loads top of top a * bottom b
		LDR		r4, [r0], #4		;loads bottom of top a * bottom b
		LDR		r5, [r0], #4		;loads top of bottom a * top b
		LDR		r6, [r0], #4		;loads bottom of bottom a * top b
		LDR		r7, [r0], #4		;loads top of bottom a * bottom b
		LDR		r8, [r0], #4		;loads bottom of bottom a * bottom b
		
		ADDS		r2, r2, r4		;add middle parts
		ADDCS	r1, r1, #0x10000	;add in carry from above
		ADDS		r3, r3, r2, LSL #16	;LSB 32 bits
		ADC		r1, r1, r2, LSR #16	;MSB 32 bits
		CMP		r12, #1			;check if there was only 1 negative
		MVNEQ	r1, r1			;flip bits to make it two's compliment if negative
		MVNEQ	r3, r3			;flip bits to make it two's compliment if negative
		ADDEQ	r3, r3, #1
		STR		r3, [r0], #4		;store LSB
		STR		r1, [r0]			;store MSB
		ADR		r0, carry
		MOVCC	r2, #0
		MOVCS	r2, #1
		STR		r2, [r0]
		END
		
mul32	;Multiply	uses	r3 for operand 1, r5 for operand 2, r1 for MSB, r3 for LSB
		ADR		r0, link			;gets pointer to link
		STR		lr, [r0]			;saves link in memory
		MOV		r6, #0			;initialize negative counter
		
		MOVS		r1, r3, LSR #31	;get sign bit
		MVNNE	r3, r3			;if negative convert to positive
		ADDNE	r3, r3, #1		;if negative convert to positive
		ADDNE	r6, r6, #1		;if negative add 1 to negative counter
		
		MOVS		r1, r5, LSR #31	;get sign bit
		MVNNE	r5, r5			;if negative convert to positive
		ADDNE	r5, r5, #1		;if negative convert to positive
		ADDNE	r6, r6, #1		;if negative add 1 to negative counter
		
		;extract	top a and bottom a to r2 and r3 respectively
		MOV		r2, r3, LSR #16	;puts top half of r2 (a) in r1 | (top a)
		BIC		r3, r3, r2, LSL #16 ;puts bottom half of r2 (a) in r2 | (bottom a)
		;extract	top b and bottom b to r4 and r5 respective
		MOV		r4, r5, LSR #16	;puts top half of r4 (b) in r3 | (top b)
		BIC		r5, r5, r4, LSL #16	;puts bottom half of r4 (b) in r4 | (bottom b)
		
		;multiply	(top a) with (top b)
		MOV		r8, r2			;moves (top a) into r8
		MOV		r9, r4			;moves (top b) into r9
		BL		mul				;(top a) * (top b)
		MOV		r1, r10			;moves result (partial sum) to r1
		;multiply	(top a) with (bottom b)
		MOV		r8, r2			;moves (top a) into r8
		MOV		r9, r5			;moves (bottom b) into r9
		BL		mul				;(top a) * (bottom b)
		MOV		r2, r10			;moves result (partial sum) to r2
		;multiply	(bottom a) with (top b)
		MOV		r8, r3			;moves (bottom a) into r8
		MOV		r9, r4			;moves (top b) into r9
		BL		mul				;(bottom a) * (top b)
		MOV		r4, r10			;moves result (partial sum) to r4
		;multiply	(bottom a) with (bottom b)
		MOV		r8, r3			;moves (bottom a) into r8
		MOV		r9, r5			;moves (bottom b) into r9
		BL		mul				;(bottom a) * (bottom b)
		MOV		r3, r10			;moves result (partial sum) to r3
		
		ADDS		r2, r2, r4		;add middle parts
		ADDCS	r1, r1, #0x10000	;add in carry from above
		ADDS		r3, r3, r2, LSL #16	;LSB 32 bits
		ADC		r1, r1, r2, LSR #16	;MSB 32 bits
		CMP		r6, #1			;check if there was only 1 negative
		MVNEQ	r1, r1			;flip bits to make it two's compliment if negative
		MVNEQ	r3, r3			;flip bits to make it two's compliment if negative
		ADDEQ	r3, r3, #1
		LDR		lr, [r0]
		MOV		pc, lr		;returns
		
		;Multiply	uses	r8 for operand 1, r9 for operand 2, r10 for result
mul		MOV		r10, #0		;initialize result register
		
loop		MOVS		r9, r9, lsr #1	;shifts r9 (b) right 1, writes that back to r9, and sets the status flags
		ADDCS	r10, r10, r8	;if the carry bit is set, add r8 to r10
		MOV		r8, r8, lsl #1	;update r8 (a) by shifting it left 1
		CMP		r9, #1
		BGT		loop			;branch back to loop if r9 is not 0
		
		MOVS		r9, r9, lsr #1	;shifts r9 (b) right 1, writes that back to r9 (b), and sets the status flags for the last time
		ADDCS	r10, r10, r8	;if the carry bit is set, add r8 (a) to r10 for the last time
		MOV		pc, lr		;returns
