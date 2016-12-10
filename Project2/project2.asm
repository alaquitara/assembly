TITLE Fibonacci numbers    (project2.asm)

; Author: Alexander Laquitara
; Course / Project ID      CS 271 Fibonacci numbers           Date: 10/16/2016
; Description: Calculates and prints out the value of n sequences of Fibonacci numbers.  n is assigned by the user

INCLUDE Irvine32.inc

UPPER_LIMIT = 46

.data

intro_1		BYTE	"Fibonacci Numbers    Programmed by Alex Laquitara", 0
intro_2		BYTE	"What's your name? ", 0
hello		BYTE	"Hello, ", 0
instructions	BYTE	"Enter the number of Fibonacci terms to be displayed", 0
instructions2	BYTE	"Give the number as an integer in the range [1 .. 46].", 0
fib1		BYTE	"How many Fibonacci terms do you want? ", 0
fibRange	BYTE	"Out of range.  Enter a number in [1 .. 46]", 0
spacer		BYTE	"     ", 0
certified	BYTE	"Results certified by Alexander Laquitara." , 0
goodbye		BYTE	"Goodbye, ",0
nameOf		BYTE	30 DUP(0) ; name of user with 30 possible characters
ec			BYTE	"**EC: Display the numbers in alligned columns"
fibIn		DWORD	? ; number of terms to run the fibonacci sequence
a			DWORD	? ; starting point of fibonacci sequence
b			DWORD	? ; a - 1
counter		DWORD   ? ; counter for the Fibonacci sequence loop

.code
main PROC
;Introduce programmer
	mov		edx,	OFFSET intro_1
	call	WriteString
	call	CrLf
	call	CrLf

;Get name of user
	mov		edx,	OFFSET intro_2
	call	WriteString
	mov		edx, OFFSET	nameOf
	mov		ecx, 32
	call	ReadString

;Print greating
	mov		edx, OFFSET hello
	call	WriteString
	mov		edx,	OFFSET nameOf
	call	WriteString
	call	CrLF

;Give instructions
	mov		edx,	OFFSET instructions
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET instructions2
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET ec
	call	WriteString
	call	CrLF
	call	CrLF

INPUT:
;Get Fibonacci terms
	mov		edx,	OFFSET fib1
	call	WriteString
	call	ReadInt	
	mov		fibIn,	eax

;Ensure number of Fibonacci terms is > 0
	mov     eax, fibIn
	cmp     eax, 1
	jl		invalidNum

;Ensure number of Fibonacci terms < 46
	mov     eax, fibIn
	cmp     eax, UPPER_LIMIT
	jg		InvalidNum

;Number is is range
	jmp		Fibonacci

InvalidNum:
;Displays error message if input is out of range
	mov		edx,	OFFSET fibRange
	call	WriteString  
	call	CrLF
	jmp		INPUT

;Referenced http://stackoverflow.com/questions/9607217/non-recursive-fibonacci-sequence-in-assembly 
Fibonacci:		;sets the initial conditions for the Fibonacci sequence
	mov		 ecx, fibIn	 ;Sets loop counter equal to number of sequences requested by user
	mov		eax, a		
	mov		counter, 1  ;Sets counter for formatting
	mov		eax, 1		;First value = 1 = a
	mov		a, eax
	call	WriteDec	;writes the first term since there is nothing to be calculated
	mov		edx,	OFFSET Spacer	;5 blank spaces used to separate values
	call	WriteString
	cmp		ecx, 2
	jb		Ending		;If user enter number is below 2 then jump to the end
	loop	FibLoop

FibLoop:		;Lopps through the sequence
	add		eax, b  ;adds a to b 
	call	WriteDec	;Displays the value of the fibonacci number at this point in the loop
	mov		edx,	OFFSET spacer  ;5 blank spaces used to separate values
	call	WriteString

;Updates the values before looping back through and adding them again.
	mov		edx, a
	mov		b, edx
	mov		a, eax
	inc		counter ; increments the loop counter

;Formatting columns for extra credit checks to ensure there are 5 numbers in a row
	mov		eax, counter
	cdq
	mov		ebx, 5   
	div		ebx		
	mov		eax, a
	cmp		edx,0	;If counter is evenly divisible by 5
	je		NewLine  ;Jump to NewLine

;Loops back to fibloop until the correct amount of sequences has been calculated
	loop	FibLoop
	jmp		Ending

NewLine:	;Calls the newline function for column formatting then loops back through the fibonacci sequence
	call	CrLF
	loop	fibLoop

Ending: ;Certifies results and says goodbye to the user
	call	CrLF
	call	CrLF
	mov		edx,	OFFSET certified
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET goodbye
	call	WriteString
	mov		edx,	OFFSET nameOf
	call	WriteString
	call	CrLF

	exit	; exit to operating system
main ENDP


END main
