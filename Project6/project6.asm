TITLE Project 6A     (project6.asm)

; Author:	Alexander Laquitara
; Course / Project ID    CS 271 Project 6A             Date: 12/4/2016
; Description:  Implements and tests  ReadVal and WriteVal procedures for unsigned integers.
;				Implements macros getString and displayString.  
;				Gets 10 valid integers from the user and stores the numeric values in an array.  The program then displays the integers, their sum, and their average.

INCLUDE Irvine32.inc

;MACRO:  getString
;Description:  Display a prompt, then get the user's keyboard input
;and put into a memory location
;receives:  string, length
;returns: none
;preconditions: none
;registers changed: none
getString	MACRO string, leng
	push edx
	push ecx
	mov edx, string
	mov ecx, leng
	call ReadString
	pop ecx
	pop edx
ENDM

; Macro: displayString
; Description: displays the string stored in a specified memory location.
; receives: print variable
; returns: none
; preconditions: none
; registers changed: none
displayString	MACRO print
	push edx
	mov		edx, print
	call WriteString
	pop edx
ENDM

.data

intro		BYTE	"PROGRAMMING ASSIGNMENT 6:  Designing low-level I/O procedures", 0
me			BYTE	"Written by: Alex Laquitara", 0
instruct1	BYTE	"Please provide 10 unsigned decimal integers", 0
instruct2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register." , 0
instruct3	BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",0
instruct4	BYTE	"Please enter an unsigned number: ", 0
error1		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0
again		BYTE	"Please try again: ", 0
nums		BYTE	"You entered the following numbers: ", 0
sumLog		BYTE	"The sum of these numbers is: ", 0
avgLog		BYTE	"The average is: ", 0
thanks		BYTE	"Thanks for playing!", 0
spacer		BYTE	"     ", 0			;formatting for ray output		
sum			DWORD	?				;sum of values
avg			DWORD	?				;average of values
ray			DWORD	10	DUP(0)		;array of values
mikeBuffer	BYTE	200 DUP(0)		;user input
temp		BYTE	32	DUP(0)		

.code

; Procedure: Main
; calls the program procedures
; receives: none
; returns: none
; preconditions: none
; registers changed: ecx, eax, ebx, edx
main PROC
		;Push intro values to stack and call introPro to display introduction
		push	OFFSET intro
		push	OFFSET me
		call	introPro

		;Push instructions onto the stack and call instruct to display program instructions
		push	OFFSET instruct1
		push	OFFSET instruct2
		push	OFFSET instruct3
		call	instruct

		;set conditions for looping
		mov		edi,	OFFSET ray
		mov		ecx,	10

	;get values from user
	getNum:
		displayString	OFFSET instruct4
		push	OFFSET	mikeBuffer		;push by reference
		push	SIZEOF	mikeBuffer		;push by value
		call	readVal
		mov		eax,	DWORD PTR mikeBuffer
		mov		[edi], eax
		add		edi,	4				;go to next array position (DWORD = 4 bytes)
		loop	getNum					;Loops for 10 values
		call	CrLF

		;displays values
		mov		ecx,	10				;10 is the counter
		mov		esi,	OFFSET ray
		mov		ebx,	0				;clear for sum calculations
		displayString	OFFSET nums
		
	L1:
		mov		eax,	[esi]
		add		ebx,	eax				; eax += ebx = sum
		push	eax
		push	OFFSET	temp
		call	writeVal
		add		esi,	4				;go to next array position (DWORD = 4 bytes)
		loop	L1

		;display sum
		mov		eax,	 ebx			;ebx = sum.  Send that to eax
		mov		sum,	eax				
		call	CrLF
		displayString	OFFSET sumLog	;call macro to show sum label
		push	sum
		push	OFFSET temp
		call	WriteVal				;calls writeval with sum and temp as parameters
		call	CrLF

		mov		ebx,	10
		mov		edx,	0				;sets conditions for division 
		div		ebx

		;calculate average
		mov		ecx,	eax
		mov		eax,	edx
		mov		edx,	2
		mul		edx
		cmp		eax,	ebx
		mov		eax,	ecx
		mov		avg,	eax

		displayString	OFFSET avgLog	;macro call to sum label
		push	avg
		push	OFFSET	temp
		call	WriteVal				;Proc takes avg by value and temp by reference
		call	CrLF

		push	OFFSET	thanks			;push thanks by reference to call closing
		call	closing

	exit	; exit to operating system
main ENDP

; Procedure: introPro
; Displays program introduction
; receives: intro and me by reference
; returns: none
; preconditions: intro and me are defined and pushed to stack
; registers changed: none
introPro	PROC
		push	ebp
		mov		ebp, esp

		displayString	[ebp +12]		;The programmer introduction
		call	CrLf
		displayString	[ebp +8]		
		call	CrLf
		call	CrLf

		pop		ebp			;Clean up the stack
		ret		8
introPro	ENDP

; Procedure: instruct
; gives instructions for the program
; receives: instruct1,2,3 by reference
; returns: none
; preconditions: instructions are defined and pushed to stack
; registers changed: ecx, ebx, eax, edx
instruct	PROC
		push	ebp
		mov		ebp, esp

		displayString	 [ebp +16]		;The programmer introduction
		call	CrLf
		displayString	[ebp +12]
		call	CrLf
		displayString	 [ebp +8]		;The instructions
		call	CrLf
		call	CrLf

		pop		ebp			;Clean up the stack
		ret		12
instruct	ENDP

; Procedure: readVal
; invokes getString to received a string of digits
; receives: OFFSET and SIZEOF mikeBuffer
; returns: a string of ints 
; preconditions: valid integers are passed
; registers changed: eax, ebp, edx, ecx, edi 
; referenced lecture 23 for algorithm in load
readVal		PROC
		push	ebp
		mov		ebp,	esp				;setup stack frame
		pushad							;saves the registers


	getNum:
		mov		edx,	[ebp+12]		;mikeBuffer address
		mov		ecx,	[ebp+8]			;size of mikeBuffer in ecx
		getString	edx,	ecx			;get sting of numbers
		
		;start converting to numbers
		mov		esi,	edx
		mov		eax,	0
		mov		ecx,	0
		mov		ebx,	10				;size of array of numbers = 10
	
	;load bytes and start validating
	load:
		lodsb							;load esi into ax
		cmp		ax,		0				;check for end of string
		je		theEnd					;if so then jump
		cmp		ax,		57				;validate whether char is an int  (57 = 9 ASCII)
		ja		wrong					;jump if not
		cmp		ax,		48				;validate whether char is an int  (48 = 0 ASCII)
		jb		wrong					;jump if not
		
		;input is valid
		sub		ax,		48				;subract to get value
		xchg	eax,	ecx				
		mul		ebx						;10 in ebx at the moment.  Mul ebx by that.
		jc		wrong					;if carry flag
		jnc		right					;if !carry flag

	;input is out of range
	wrong:	
		displayString	OFFSET error1
		call	CrLF
		displayString	OFFSET	again
		jmp		getNum

	;valid input
	right:
		add		eax,	ecx				;add value to total
		xchg	eax,	ecx				;set conditions to loop again
		jmp		load					;loop again

	;restore registers and stack then return after saving int value		
	theEnd:
		xchg	ecx,	eax
		mov		DWORD	PTR	mikeBuffer, eax
		popad							
		pop		ebp	
		ret	8
readVal		ENDP

; Procedure: writeVal
; converts numbers into a string of digits via displayString
; receives: integers to be converted into string and a string for ouput
; returns: formatted string
; preconditions: valid integers are passed
; registers changed: eax, ebp, edi 
writeVal	PROC
		push	ebp
		mov		ebp,	esp				;setup stack frame
		pushad							;saves the registers
		mov		eax,	[ebp+12]		;eac to convert ints to string
		mov		edi,	[ebp+8]			;edi stores string address
		mov		ebx,	10				
		push	0						;top of stack

	;start converting digits		
	converse:
		mov		edx,	0				;remainder = 0
		div		ebx						;divide by 10
		add		edx,	48
		push	edx						;digit gets pushed onto the stack
		cmp		eax,	0				;check if done
		jne		converse

	popsicle:
		pop		[edi]
		mov		eax,	[edi]
		inc		edi						;loop counter +=1
		cmp		eax,	0				;check if done
		jne		popsicle				;if not loop some more

		;call macro to display the created string
		mov		edx,	[ebp+8]
		displayString	OFFSET temp
		displayString	OFFSET spacer
		
		;restore register and stack then return
		popad
		pop		ebp
		ret	8
writeVal		ENDP

; Procedure: closing
; displays farewell message
; receives: thanks by reference
; returns: none
; preconditions: variable is pushed onto the stack
; registers changed: none
closing		PROC
		push	ebp	
		mov		ebp,	esp
		call	CrLF
		displayString	[ebp + 8]		;thank the user
		call	CrLF
		call	CrLF
		pop		ebp						
		ret		4
closing		ENDP

END main
