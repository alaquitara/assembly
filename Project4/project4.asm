TITLE Project4   (Project4.asm)

; Author: Alexander Laquitara
; Course / Project ID  CS 271 Project4               Date: 11/6/2016
; Description: Program calculates composite numbers up to the value inputed by the user inclusive.
;The valid range for a user to enter is from 1-400.  If out of range a error message will be displayed
;if in range the calculations are printed to the console.

INCLUDE Irvine32.inc

UPPER_LIMIT = 400

.data
intro_1		BYTE	"Sorting Random numbers    Programmed by Alex Laquitara", 0
intro_2		BYTE	"This program generates random numbers in the range [100 .. 999]", 0
intro_3		BYTE	"displays the original list, sorts the list, and calculates the median value.", 0
intro_4		BYTE	"Finally, it displays the list sorted in descending order", 0
howMany		BYTE	"How many numbers should be generates?",0
error1		BYTE	"Invalid input", 0
nums		BYTE	"The unsorted random numbers:", 0
medPrint	BYTE	"The median is ", 0
sortPrint	BYTE	"The sorted list: ",0
goodbye		BYTE	"results certified by Alex Laquitara.  Goodbye"
spacer		BYTE	"     ", 0
userNum		DWORD	?  ;value entered by user for number of composits they wish to see
counter		DWORD   0  ;the quantity of numbers printed
current		DWORD   0  ;the current number being tested for composite
fac			DWORD	0  ;largest factor for tested number
comp		DWORD   0  ;bool used to designate if number is composite.

.code

; Procedure: Main
; like the c++main function, the main procedure calls the program procedures
; receives: none
; returns: none
; preconditions: none
; registers changed: none
main PROC
	call	introProc
	call	getData
	call	calculation
	call	goodbyeMSG

	exit
main ENDP

; Procedure: intro
; Displays a greeting, the program title, author name, and program description
; receives: intro_1,2,3 are global variables
; returns: logs the greeting, program title, author name, and program description to console
; preconditions: none
; Registers Changed:  edx to display intro strings
introProc PROC
	mov		edx,	OFFSET intro_1
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET intro_2
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET intro_3
	call	WriteString
	call	CrLF
	ret
introProc ENDP

; Procedure : getData
; Prompts the user for input and calls the validate function to ensure valid input. Will be called again
; by validate function if input is invalid.
; receives: instructions1 is a global variable
; returns: stores the user input in variable num
; precontions: none
; registers changed: EDX to display instructions.  EAX to store the user number
getData PROC
		mov		edx, OFFSET instructions1    ;display instructions
		call	WriteString
		call	ReadInt
		mov		userNum, eax				;store user chosen number in eax
		call	crLF
		call	validation					;call validation procedure 
		ret
getData ENDP


; Procedure: validation
; Compares input against the max and min accepted, if out of range, the procedure kicks back to getData procedure
; receives: userNum- input from user, UPPER_LIMIT is a global variable
; returns: an error message if invalid
; preconditions:  userNum must get a value from the user
; registers changed:  edx is set to offset of error1
validation PROC

		;if number is less than 1 show error
		cmp		eax, 1
		jl		error

		;if number is greater than the upper limit (400) show eror
		cmp		eax, UPPER_LIMIT
		jg		error
		
		;if valid return out of procedure
		jmp			valid
		

	error: ;displays an error if number is out of range
		mov		edx, OFFSET error1
		call	WriteString
		call	 CrLF
		call	getData
		
	valid:
		ret
validation ENDP
	
; Procedure: calculation
; logs composite numbers to console
; receives: N/A
; returns: prints out composite numbers
; preconditions:  userNum must be a valid number (between 1-400)
; registers changed:  edx is set to offset to space in order to seperate values and eax is changed to current
calculation PROC

	;sets conditions
	mov		counter, 0
	mov		current, 4
	mov		fac, 0

	loop_start:

		;test for composite
		mov		comp, 0
		call	trueComp
		cmp		comp, 1
		;jump if number is not composite
		jne		ending

		;number is composite since program didn't jump
		mov		eax, current
		call	writeDec
		mov		edx, OFFSET spacer  ;prints 5 spaces just for readability
		call	writeString
		inc		counter

		jmp	ending

	ending:
		;check to see if we need to jump back to start
		inc		current
		mov		eax,	userNum
		cmp		counter, eax
		jne		loop_start
		;if done printing then return out of procedure.
		ret
		
calculation ENDP

; Procedure: trueComp
; behaves like a boolean function in order to determine if number is composite
; receives: N/A
; returns: a value of 1 in comp for a true value.
; preconditions:  calculation procedure must be called
; registers changed:  edx, eax, ebx  to perform required arithmetic
trueComp PROC
	mov		ecx, current
	dec		ecx

	loop_start:
		;see if the counter is a factor
		mov		edx, 0
		mov		eax, current
		mov		ebx, ecx
		div		ebx
		cmp		edx, 0
		;if not a factor
		jne		mid_loop
		; if is a factor
		mov		fac, ebx
		jmp		end_loop
		
	;loops back to begining to look for another factor
	mid_loop:
		loop	loop_start

	;if >1 the number is composite
	end_loop:
		cmp		fac, 1
		jle		the_end ; return out of procedure
		mov		comp, 1 ;set the composite bool to true
	
	the_end:
		ret
trueComp ENDP

; Procedure: goodbyeMSG
; logs a goodbye message to the console
; receives: goodbye as a global variable
; returns: contents of goodbye
; preconditions:  none
; registers changed:  edx is offset to goodbye
goodbyeMSG PROC
	call	CrLF
	mov		edx,  OFFSET goodbye
	call	WriteString
	ret
goodByeMSG ENDP

END main
