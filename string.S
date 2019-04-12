		;		ARM Programming Assignment #2: Writing C-strings
		;
		;		Write a program that assembles the values in chars*
		;		into a C-style string. A C-style string is an array
		;		of byte-size characters, terminated by a NULL (0x0).
		;		Write the C-string to the FILL memory at 'string'.
		;		Note: It's up to you to declare the correct number
		;		of bytes to hold the result.
		
		;		Your code here
		
chars0	DCD		'T', 'h', 'e', ' ', '2', '0', '1', '8', ' ', 'T', 'u'
chars1	DCD		'r', 'i', 'n', 'g', ' ', 'A', 'w', 'a', 'r', 'd', ' '
chars2	DCD		'w', 'a', 's', ' ', 'a', 'w', 'a', 'r', 'd', 'e', 'd'
chars3	DCD		' ', 't', 'o', ' ', 'B', 'e', 'n', 'g', 'i', 'o',  44
chars4	DCD		' ', 'H', 'i', 'n', 't', 'o', 'n',  44, ' ', 'a', 'n'
chars5	DCD		'd', ' ', 'L', 'e', 'C', 'u', 'n', 'n', ' ', 'f', 'o'
chars6	DCD		'r', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'w', 'o', 'r'
chars7	DCD		'k', ' ', 'o', 'n', ' ', 'n', 'e', 'u', 'r', 'a', 'l'
chars8	DCD		'n', 'e', 't', 'w', 'o', 'r', 'k', 's', '.'
count	DCD		97
string	FILL		100
		
		ADR		r0, chars0	;loads the pointer to chars0 into r0
		ADR		r1, string	;loads the pointer to string into r1
		ADR		r2, count		;loads the pointer to count into r3
		LDR		r2, [r2]		;loads the count into r2
loop
		LDR		r3, [r0], #4	;loads the character into r1
		STR		r3, [r1], #4	;stores the character in its respective position in memory
		SUB		r2, r2, #1	;updates count
		CMP		r2, #0
		BGT		loop
		
		MOV		r3, #0		;loads null terminator into r3
		STR		r3, [r0]		;stores null terminator at the end of the string
		END
