TITLE Program 5    (program5.asm)

; Author: Alexander Laquitara
; Course / Project ID                 Date: 11/20/2016
; Description:  This program gets a number from the user that determines how many random numbers will fill an array.
				;Program then lists the values in the array in unsorted order, sorts the values in the array, displays the median
				;then displays the sorted list. 


INCLUDE Irvine32.inc
MIN = 10	;min lengthOf array
MAX = 200	;max lengthOf array
LO = 100	;min array val
HI = 999	;max array val

.data
intro_1		BYTE	"Sorting Random numbers    Programmed by Alex Laquitara", 0
intro_2		BYTE	"This program generates random numbers in the range [100 .. 999]", 0
intro_3		BYTE	"displays the original list, sorts the list, and calculates the median value.", 0
intro_4		BYTE	"Finally, it displays the list sorted in descending order", 0
range		BYTE	"Out of range.  Enter a number between 10 and 200", 0
howMany		BYTE	"How many numbers should be generated? [10 .. 200]",0
error1		BYTE	"Invalid input", 0
nums		BYTE	"The unsorted random numbers:", 0
medPrint	BYTE	"The median is ", 0
sortPrint	BYTE	"The sorted list: ",0
spacer		BYTE	"     ", 0			;5 spaces for formatting output
userNum		DWORD	?					;amount of random numbers in the array
ray			DWORD	MAX DUP(?)			;Array to hold random numbers

.code
; Procedure: Main
; like the c++main function, the main procedure calls the program procedures
; receives: none
; returns: none
; preconditions: none
; registers changed: none
main PROC

	call	Randomize	;procedure to seed random numbers
	call	greating
	push	OFFSET usernum

	;get data from user
	call	getData
	push	usernum 
	push	OFFSET ray
	call	rayFill
	push	OFFSET	ray

	;display unsorted array
	push	usernum
	push	OFFSET	nums
	call	loglist
	
	;sort array
	push	OFFSET ray
	push	usernum
	call	sort

	;median 
	push	OFFSET ray
	push	userNum
	call	logMed
	
	;display sorted array
	push	OFFSET ray
	push	usernum
	push	OFFSET	sortPrint
	call	loglist

	exit	; exit to operating system
main ENDP


; Procedure: greating
; Displays a greeting, the program title, author name, and program description
; receives: intro_1,2,3, 4 are global variables
; returns: logs the greeting, program title, author name, and program description to console
; preconditions: none
; Registers Changed:  edx to display intro strings
greating PROC
	mov		edx,  OFFSET intro_1
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET intro_2
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET intro_3
	call	WriteString
	call	CrLF
	mov		edx,	OFFSET intro_4
	call	WriteString
	call	CrLF
	ret
greating ENDP

; Procedure : getData
; Prompts the user for input and validates that input is in range
; receives: usernum by reference
; returns: none
; precontions: none
; registers changed: EDX EAX EBP
getData PROC
	get:
		push	ebp
		mov		ebp, esp			;setup stack frame
		mov		ebx, [ebp+8]		;ebx points to request +4 

		mov		edx,	OFFSET howMany
		call	WriteString
		call	ReadInt

		cmp		eax, MIN			;checks that greater than min global
		jge		over		
		jl		invalid

	over:	;if over
		cmp		eax, MAX
		jg		invalid
		jmp		valid

	invalid:		;if invalid
		mov		edx,	OFFSET	range
		call	WriteString
		call	CrLF
		jmp		get					;start over again
	valid:
		mov		[ebx],	eax			;usernum is stored in ebx
		pop		ebp					;set stack to how it was
		call	CrLF
		ret		4
getData ENDP

; Procedure : rayFill
; stores random integer values from [100...999] in an array
; receives: ray - reference   and usernum - value
; returns: none
; precontions: usernum must be validated and ray defined
; registers changed: EDX EBP ECX EBX ESI
rayFill PROC
		push	ebp	
		mov		ebp, esp				;stack frame sent
		mov		ecx,	[ebp+12]
		mov		esi,	[ebp+8]			;beginning ray address

		;reference lecture 20
		mov		eax,	HI
		sub		eax,	LO
		inc		eax

	fill:
		call	RandomRange				;generate random int in range
		add		eax,	LO				;because the value must be > low
		mov		[esi], eax				;store value
		add		esi,	4				;because Dword is 4 bytes
		loop	fill

		pop		ebp
		ret		8
rayFIll	ENDP

; Procedure : logList
; Prints the contents of an array of integers to console
; receives: ray-reference and request-value
; returns: none
; precontions: ray and usernum must hold values
; registers changed: EDX EAX ESI EBX EBP
logList PROC
		;refereneced DEMO5.ASM
		push ebp						;push old ebp, +4
		mov ebp, esp					;set stack frame pointer
		mov esi, [ebp+16]				;address of array in esi
									;since we push 3 parameters, this is now +16 instead of +12
		mov ecx, [ebp+12]				;number of elements in ecx (counter)
		mov ebx, 0						;count per line

	;Title Display
		call CrLf
		mov edx, [ebp + 8]			;since this was last pushed on stack
		call WriteString
		call CrLf

	cur:
		cmp ebx, MIN				;must be at beginning so value outside of range is not displayed
		je next					;if 10 values have been displayed, jump to next row

		mov eax, [esi]				;current element in eax
		call WriteDec

		add esi, 4					;go to next element
		mov edx, OFFSET spacer		;print spacing between values
		call WriteString
		inc ebx
		loop cur				;loop again
		jmp ending				;once ecx = 0, no more loop, skip over to finished

	next:
		call CrLf
		mov ebx, 0
		jmp cur

	ending:
		pop ebp						;restore stack
		ret 12						;return bytes pushed before the call

logList ENDP


; Procedure : sort
; Sorts an array of integers.
; receives: ray and usernum 
; returns: none
; precontions: ray and usernum must hold values
; registers changed: EDX EAX ESI EBX EBP
sort PROC
	
	;Page 352 Irvine's bubble sort
		push	ebp
		mov		ebp,	esp
		mov		ecx,	[ebp+8]
		dec		ecx				;Dec count by 1

	L1:
		push	ecx					;outer loop count saved
		mov		esi,	 [ebp+12]	;point to first value

	L2:
		mov		eax,	[esi]
		cmp		[esi+4],	eax		;comparing current element to the n+1
		jl		L3
		xchg	eax,	[esi+4]    ;reference for swap http://www.c-jump.com/CIS77/ASM/DataTypes/T77_0200_exchanging_integers.htm
		mov		[esi],	eax

	L3:
		add		esi,	4			;point to next element and repeat the loops
		loop	L2
		pop		ecx					;retrieves out loop content
		loop	L1					

	pop		ebp
	ret		8

sort ENDP


; Procedure : logMed
; Logs the median number in an arry.  Median number is the middle value if usernum is odd, average of middle two if usernum is even
; receives: ray and usernum 
; returns: Median value of array
; precontions: ray must be sorted 
; registers changed: EDX EAX ESI EBX EBP
logMed	PROC
		push	ebp
		mov		ebp,	esp
		mov		esi,	[ebp +12]
		mov		ecx,	[ebp+8]
		mov		edx,	0		;clear for division


		mov		eax, ecx		;elements sent to eax
		mov		ecx,	2
		div		ecx
		cmp		edx,	0		;If remaineder is 1 its odd, even is 0
		ja		odds
		je		evens
	
	odds:						;finds middle number in array
		mov		ebx,	4
		mul		ebx
		mov		ebx,	[esi+eax]
		mov		eax,	ebx
		jmp		endMed

	evens:						;finds average of middle two numbers in array
		mov		ebx,	4
		mul		ebx
		mov		ebx,	[esi+eax]

		sub		eax,	4
		mov		eax,	[esi+eax]
		add		eax,	ebx
		mov		ebx,	2
		div		ebx
		jmp		endMed
	
	endMed:						;Once median is found it is logged and stack is set
		mov		edx,	OFFSET medPrint
		call	CrLf
		call	CrLf
		call	WriteString
		call	WriteDec
		call	CrLF
		pop		ebp
		ret		8
logMed ENDP

END main
