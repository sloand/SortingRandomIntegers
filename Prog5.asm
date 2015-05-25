TITLE: Program 5		(Prog5.asm)

; Author: Dennis Sloan
; OSU email address: sloand@onid.oregonstate.edu
; Class Number-Section: CS 271-400
; Assignment Number: 5
; Assignment Due Date: 05/24/2015
; Description: This program will generates random numbers in the range [100...999],
;              displays the original list, sorts the list, and calculates the median
;              value.  Finally, it displays the list sorted in descending order.
; Date Created: 05/18/15
; Last Modification Date: 05/25/2015

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999
MAX_SIZE = 200

.data
request		DWORD	?
range		DWORD	?
array		DWORD	MAX_SIZE	DUP(?)
max_index	DWORD	?
max_value	DWORD	?
start_scan	DWORD	?
index		DWORD	?
median		DWORD	?

title_auth	BYTE	"Sorting Random Integers       Programmed by Dennis Sloan", 0
intro_1		BYTE	"This program generates random numbers int he range [100...999],", 0
intro_2		BYTE	"displays the original list, sorts the list, and calculates the", 0
intro_3		BYTE	"median value.  Finally, it displays the list in descending order.", 0
prompt		BYTE	"How many numbers should be generated? [10...200]: ", 0
error_msg	BYTE	"Invalid input.", 0
unsor_title	BYTE	"The unsorted random numbers:", 0
med_title	BYTE	"The median is: ", 0
sort_title	BYTE	"The sorted list:", 0
spacer		BYTE	"   ", 0

.code
; Call all procedures
main PROC
	call	Randomize					; Set up to get random #'s
	call	intro						; Intro program
	push	OFFSET range
	call	get_range					; Establish random # range
	push	OFFSET request
	call	get_data					; Get # of #'s from user
	push	OFFSET array
	push	request
	push	range
	call	fill_array					; Populate array
	push	OFFSET spacer
	push	OFFSET unsor_title
	push	OFFSET array
	push	request
	call	display_list				; Print unsorted array
	push	OFFSET array
	push	request
	call	sort_list					; Sort array
	push	OFFSET array
	push	OFFSET med_title
    push	request
	call	display_median				; Calculate/print median
	push	OFFSET spacer
	push	OFFSET sort_title
	push	OFFSET array
	push	request
	call	display_list				; display sorted array
  exit	
main ENDP


;******************************************************************
; Procedure to introduce the program and programmer
; Receives: N/A
; Returns: N/A
; Pre-conditions: N/A
; Registers changed: edx
;******************************************************************
intro PROC
	mov		edx, OFFSET title_auth
	call	WriteString
	call	Crlf
	call	Crlf
	mov		edx, OFFSET intro_1
	call	WriteString
    call	Crlf
	mov		edx, OFFSET intro_2
	call	WriteString
	call	Crlf
	mov		edx, OFFSET intro_3
	call	WriteString
	call	Crlf
	call	Crlf
	ret
intro ENDP



;******************************************************************
; Procedure to get range for random number generation
; Receives: Range address
; Returns: Value in range address
; Pre-conditions: N/A
; Registers changed: eax, ebx
;******************************************************************
get_range PROC
    push	ebp
	mov		ebp, esp
	mov		eax, HI			; hi in eax
	sub		eax, LO			; subtract lo from hi
	inc		eax				; add 1 


	mov		ebx, [ebp+8]	; move range @ into ebx
	mov		[ebx], eax		; move result into range
	pop		ebp
	ret		4
get_range ENDP

;******************************************************************
; Procedure to get number of numbers from user
; Receives: request address
; Returns: request value
; Pre-conditions: N/A
; Registers changed: edx, ebx, eax
;******************************************************************
get_data PROC
	push	ebp
	mov		ebp, esp
	validation:
		mov		edx, OFFSET prompt
		call	WriteString
		call	ReadInt
			cmp		eax, MIN
			jge		test_2
			mov		edx, OFFSET error_msg
			call	WriteString
			call	Crlf
			loop	validation
			test_2:
				cmp		eax, MAX
				jle		end_validation
				mov		edx, OFFSET error_msg
				call	WriteString
				call	Crlf
				loop	validation
	end_validation:	
		mov		ebx, [ebp+8]	; move request address to ebx
		mov		[ebx], eax		; move input to request address
		pop		ebp
		ret		4
get_data ENDP


;******************************************************************
; Procedure to put random numbers in array*
;     *modified from Irvine pp. 297-298
; Receives: address of array, value of request, value of range
; Returns: requested number of values in array
; Pre-conditions: request and range need values, randomizer must
;     be called
; Registers changed: ecx, eax, esi
;******************************************************************
fill_array PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+16]		; move offest of array to esi
	mov		ecx, [ebp+12]		; use request as counter
	cmp		ecx, 0
	je		end_fill_loop
	; Generates psuedorandom number, puts array
	fill_loop:
		mov		eax, [ebp+8]	; move range into eax for RandomRange
		call	RandomRange
		add		eax, LO
		mov		[esi], eax		; move random value from eax to array
		add		esi, 4			; increase array address for next index
		loop	fill_loop
	end_fill_loop:
		pop ebp
		ret	12
fill_array ENDP


;******************************************************************
; Procedure to sort array values into descending order*
;     *based on Irvine's bubble sort (p. 375)
; Receives: address of array, value of request
; Returns: sorted values of array
; Pre-conditions: array must have values
; Registers changed: ecx, esi, eax
;******************************************************************
sort_list PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]			; use request as counter
	dec		ecx
	L1:								; outer loop
		push	ecx
		mov		esi, [ebp+12]		; move array address to esi
	L2:
		mov		eax, [esi]			; move arry contents to eax
		cmp		[esi+4], eax		; compare eax to next array value
		jl		L3					
		xchg	eax, [esi+4]		; exchange eax & next array value
		mov		[esi], eax			; move eax value to current array index
	L3: 
		add		esi, 4				; increase array index
		loop	L2

		pop		ecx
		loop	L1

		pop		ebp
		ret 8
sort_list ENDP


;******************************************************************
; Procedure to print median value from sorted array
; Receives: Addresses of array and med_title, value of request
; Returns: N/A
; Pre-conditions: array must contain sorted values
; Registers changed: esi, eax, ebx, edx
;******************************************************************
display_median PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+16]	; move array addrss to esi
	mov		eax, [ebp+8]	; move request to eax
	cdq
	mov		ebx, 2
	div		ebx				; divide request by 2
	cmp		edx, 0
	je		if_even
	mov		ebx, 4
	mul		ebx				; calc dist for needed array address
	add		esi, eax		; add eax to current address
	mov		eax, [esi]		; move eax to new array address
	jmp		print
	if_even:
		dec		eax
		mov		ebx, 4
		mul		ebx
		add		esi, eax
		mov		eax, [esi]		; move array value to eax
		mov		edx, [esi+4]	; move next array value to edx
		add		eax, edx		; add values
		cdq
		mov		ebx, 2
		div		ebx				; divide by two for average
	print:
		mov		edx, [ebp+12]	; move median title to edx
		call	WriteString
		call	WriteDec
		call	Crlf
		call	Crlf
		pop		ebp
		ret	12
display_median ENDP


;******************************************************************
; Procedure to print array contents*
;     *modified from CS 271 Lecture 20
; Receives: Addresses of spacer, unsor_title, array
;           Value of request 
; Returns: N/A
; Pre-conditions: array must be filled
; Registers changed: edx, esi, ebx, eax
;******************************************************************
display_list PROC
	push	ebp
	mov		ebp, esp
	call	Crlf
	mov		edx, [ebp+16]		; move array title to edx
	call	WriteString
	call	Crlf
	mov		esi, [ebp+12]		; move array address to esi
	mov		ecx, [ebp+8]		; use request as counter
	mov		ebx, 0
	print_loop:
		mov		eax, [esi]		; move array value to esi
		call	WriteDec
		mov		edx, [ebp+20]	; move spacer to edx
		call	WriteString
		add		esi, 4
		inc		ebx
		cmp		ebx, 10
		jne		end_loop
		call	Crlf
		mov		ebx, 0
		end_loop:
			loop	print_loop
	call	Crlf
	call	Crlf
	pop		ebp
	ret 16
display_list ENDP

END main