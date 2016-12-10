TITLE Project 3   (project3.asm)

; Author:Alexander Laquitara
; Course / Project ID   271 project3              Date: 10/30/2016
; Description: User provides numbers between -100 and -1 until a number greater than -1 is entered.  The sum and average of numbers from input is reported.

INCLUDE Irvine32.inc
LOWER_LIMIT = -100 ;minimum number allowed in order for it to be valid.

.data

intro_1		BYTE	"Welcome to the Integer Accumulator by Alex Laquitara", 0
intro_2		BYTE	"What's your name? ", 0
hello		BYTE	"Hello, ", 0
instructions	BYTE	"Please enter numbers in [-100, -1]", 0
instructions2	BYTE	"Enter a non-negative number when you are finished to see the results", 0
instructions3	BYTE	": Enter number: ", 0
error1		BYTE	"You entered a number that is less than -100. ", 0
invalid1	BYTE	"You entered ", 0
invalid2	BYTE	" valid numbers.", 0
invalid3	BYTE	"You didn't enter any valid numbers.", 0
printSum	BYTE	"The sum of your valid numbers is ", 0
printAvg	BYTE	"The rounded average is ", 0
goodbye		BYTE	"Thank you for playing Integer Accumulator! It's been a pleasure to mee you, ", 0
nameOf		BYTE	30 DUP(0) ; name of user with 30 possible characters
ec1			BYTE	"**EC: Number the lines during user input", 0
userNum		SDWORD	? ;used to hold input data
sum			SDWORD	0 ;sum of values entered
avg			SDWORD	0 ;average of values entereed
count		DWORD	0 ;number of valid numbers entered
numLines	DWORD	1 ;number lines of input for EC

.code
main PROC

;Introduce programmer and give title of program
	mov		edx,	OFFSET intro_1
	call	WriteString
	call	CrLf
	mov		edx,	OFFSET	ec1 ;Display terms of extra credit
	call	WriteString
	call	CrLF
	call	CrLf

;Get name of user
	mov		edx,	OFFSET intro_2
	call	WriteString
	mov		edx, OFFSET	nameOf
	mov		ecx, 30 ;30 being the max length of user's name
	call	ReadString

;Print Greating
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
	call	CrLF
	
INPUT:
;Get input from user
	mov		eax,	numLines
	call	WriteDec
	mov		edx,	OFFSET instructions3
	call	WriteString
	call	ReadInt	
	mov		userNum,	eax

	;Check to see if number entered is < than -100
	mov		eax, userNum
	cmp		eax, LOWER_LIMIT
	jl		INVALID_NUM

	;Check to see if number entered is > than -1
	mov		eax, userNum
	cmp		eax, -1
	jg		INVALID_END

	;else number is within constraints
	mov		ebx, sum
	add		eax, ebx ;This adds the number the user entered to the sum 
	mov		sum, eax
	add		count, 1 ;Keeps track of every loop iteration- used in average
	add		numLines, 1 ;updates line counter for EC
	jmp		INPUT

INVALID_NUM: ;Displays error message if input is less than -100 and jumps back to input
	mov		edx,	OFFSET error1
	call	WriteString
	mov		edx,	OFFSET	instructions
	call	WriteString
	call	CrLF
	jmp		INPUT
	
INVALID_END: ;gives feedback to the user on the quantity of valid numbers they entered.
	;To avoid crashing if no valid numbers are entered.
	mov		eax, count
	cmp		eax, 0 
	jz		NO_NUMS
	
	;If valid numbers were entered, the quantity is reported.
	mov		edx,	OFFSET invalid1
	call	WriteString  
	mov		eax,	count
	call	WriteDec
	mov		edx,	OFFSET	invalid2
	call	WriteString
	call	CrLF
	jmp		CALCULATE

NO_NUMS: ;Display error messange and jump to the ending.
	mov		edx,	OFFSET invalid3
	call	WriteString
	call	CrLF
	jmp		THEEND


CALCULATE: ;Adds up all valid numbers entered and calculates a rounded average between them.
;sum is reported using the sum variable that has been updating in input
	mov		edx,	OFFSET	printSum
	call	WriteString
	mov		eax,	sum
	call	writeInt
	call	crlf

;average	uses the count from input to divide by total.
	mov		eax, 0
	mov		eax,	sum
	cdq
	mov		ebx,	count
	idiv	ebx
	mov		avg,	eax
	
	mov		edx,	OFFSET	printAVG
	call	WriteString
	mov		eax, avg
	call	WriteInt
	call	CrLF
	jmp		THEEND

THEEND:
;says goodbye to the user
	mov		edx,	OFFSET goodbye
	call	WriteString
	mov		edx,	OFFSET nameOf
	call	WriteString
	call	CrLF
	
	exit	
main ENDP



END main
