
;------------------------------------------------
;	GET STR LEN
;------------------------------------------------
; ENTRY:	BX = STR ADDR
; EXIT:		AX = LEN
; EXPECTS:  END SYM = '\0'
; DESTROYS: AX	
;------------------------------------------------

StrLen          proc

                xor ax, ax     	; i = 0

				push cx si		; push (1) (2)

                __Next:			mov  si, bx     ; SI = BX + i	    
							    add  si, ax
								
								inc  ax			; i++	
								mov  cx, [si]	; CX = current symbol

								cmp  ch, 0d 	; if( ch == '\0' )
								je __End	
	
								jmp __Next

				__End:
				pop si cx		; pop  (2) (1)		

                ret 
                endp

;------------------------------------------------
;	GET ADDR OF CHR IN ARR
;	RET NULL IF NOT FOUND
;------------------------------------------------
; ENTRY:	BX = ARR ADDR
;			CL = CHR
;			DX = LEN OF THE COMPARED PART (IN BYTES)
; EXIT:		AX = ADDR OF CHR
; DESTROYS: AX	
;------------------------------------------------

MemChr			proc

				push si			; push (1)

				xor ax, ax		; AX = NULL
				xor si, si		; i  = 0

				cmp dx, 0d		; if( len == 0 )
				je __End

				__Next:			cmp bx[si], cl		; if( Addr[i] == CHR )
								je __Found

								inc si

								cmp si, dx
								je __End

								jmp __Next

				__Found:		mov ax, bx			; AX = ArrAddr + i
								add ax, si

				__End:
				pop si			; pop  (1)

				ret 
				endp

;------------------------------------------------
;	GET ADDR OF CHR IN STR
;	RET NULL IF NOT FOUND
;------------------------------------------------
; ENTRY:	BX = ARR ADDR
;			CL = CHR
; EXIT:		AX = ADDR OF CHR
; EXPECTS:  END SYM = '\0'
; DESTROYS: AX	
;------------------------------------------------

StrChr			proc

				push si			; push (1)

				xor ax, ax		; AX = NULL
				xor si, si		; i  = 0

				__Next:			cmp byte ptr bx[si], cl		; if( Addr[i] == CHR )
								je __Found
								cmp byte ptr bx[si], 0d		; if( Addr[i] == '\0' )
								je __End

								inc si

								jmp __Next

				__Found:		mov ax, bx					; AX = ArrAddr + i 
								add ax, si

				__End:
				pop si			; pop  (1)

				ret 
				endp

;------------------------------------------------
;	THE MEMSET FUNCTION FILLS 
;	THE FIRST N BYTES OF THE MEMORY 
;	LOCATION POINTED TO BY THE 
;	DESTINATION ARGUMENT WITH THE 
;	CHARACTER SPECIFIED BY THE CHR ARGUMENT
;------------------------------------------------
; ENTRY:	BX = DESTINATION 
;			CL = CHR
;			DX = N
; EXIT:		NONE
; DESTROYS: NONE
;------------------------------------------------

MemSet			proc

				push si			; push (1)

				xor si, si		; i = 0

				cmp dx, 0d		; if( N == 0 )
				je __End

				__Next:			mov byte ptr bx[si], cl		; BX[i] = CHR

								inc si						; i++

								cmp si, dx					; if( i == N )
								je __End

								jmp __Next
				__End:
				pop	si			; pop  (1)

				ret
				endp

;------------------------------------------------
;	THE MEMCPY FUNCTION COPIES N BYTES 
;	FROM THE ARRAY (SOURCE) TO THE ARRAY 
;	(DESTINATION). IF THE ARRAYS OVERLAP, 
;	THE RESULT OF THE COPY WILL BE UNDEFINED
;------------------------------------------------
; ENTRY:	BX = DESTINATION
;			CX = SOURCE
;			DX = N
; EXPECTS: 	DS = DESTINATION SEG
; 			ES = SOURCE 	 SEG
; EXIT:		NONE
; DESTROYS: NONE
;------------------------------------------------

MemCpy			proc	

				push si bp		; push (1) (2)

				mov bp, cx		; BP = CX

				xor si, si		; i = 0

				cmp dx, 0		; if( N == 0 )
				je __End

				__Next:			push dx							; push (3)
								mov  dl, es:bp[si]
								mov  byte ptr ds:bx[si], dl 	; DS:BX[i] = ES:CX[i]
								pop  dx							; pop  (3)						

								inc si							; i++

								cmp si, dx						; if( N == i )
								je __End

								jmp __Next

				__End:
				pop bp si		; pop  (2) (1)

				ret 
				endp

;------------------------------------------------
; 	THE STRCPY FUNCTION COPIES THE DATA FROM 
; 	THE SOURCE ARGUMENT TO THE DESTINATION 
;	UNTIL THE END-OF-LINE( NULL ) CHARACTER 
;	IS ENCOUNTERED. 
;	COPYING IS DONE ALONG WITH THE 
;	END-OF-LINE CHARACTER
;------------------------------------------------
; ENTRY:	BX = DESTINATION
;			CX = SOURCE
; EXIT:		NONE
; DESTROYS: NONE
;------------------------------------------------

StrCpy			proc	

				push dx	si bp	; push (1) (2) (3)

				mov bp, cx		; BP = CX

				xor si, si		; i = 0

				__Next:			mov dl, bp[si]
								mov byte ptr bx[si], dl 	; BX[i] = CX[i]

								cmp byte ptr bp[si], 0d		; if( CX[i] == 0 )
								je __End

								inc si						; i++

								jmp __Next

				__End:
				pop bp si dx	; pop  (3) (2) (1)

				ret 
				endp

;------------------------------------------------
; 	THE MEMCMP FUNCTION COMPARES, BYTE BY BYTE, 
;	THE TWO ARRAYS ARR_1 AND ARR_2. 
;	THE COMPARISON CONTINUES UNTIL N BYTES 
;	HAVE BEEN CHECKED OR UNTIL DIFFERENT 
;	BYTES ARE ENCOUNTERED.
;------------------------------------------------
; ENTRY:	BX = ARR_1
;			CX = ARR_2
;			DX = N
; EXIT:		AX = 0 ( ARR_1[i] == ARR_2[i] : FOR i in [0; N-1] )
;			AX > 0 ( ARR_1[i] >  ARR_2[i] )
;			AX < 0 ( ARR_1[i] <  ARR_2[i] )
; DESTROYS: AX
;------------------------------------------------

MemCmp			proc

				push si bp		; push (1) (2)

				mov bp, cx		; BP = CX

				xor si, si		; i  = 0

				cmp dx, 0d		; if( N == 0 )
				je __End

				__Next:			xor  ax, ax					; AX  = 0
								mov  al, bx[si] 			; AL  = BX[i]
								push dx						; push (3) 
								xor  dx, dx					; DX = 0
								mov  dl, bp[si]				
								sub  ax, dx					; AX -= CX[i] 
								pop  dx						; pop  (3)

								cmp ax, 0d			; if( AX != 0 )
								jne __End

								inc si

								cmp si, dx			; if( i == N )
								je __End

								jmp __Next	
				__End:
				pop bp si 		; pop  (2) (1)

				ret 
				endp

;------------------------------------------------
; 	THE MEMCMP FUNCTION COMPARES, BYTE BY BYTE, 
;	THE TWO STRINGS STR_1 AND STR_2. 
;	THE COMPARISON CONTINUES UNTIL THE 
;	END-OF-LINE( NULL ) OR UNTIL DIFFERENT 
;	BYTES ARE ENCOUNTERED.
;------------------------------------------------
; ENTRY:	BX = STR_1
;			CX = STR_2
; EXIT:		AX = 0 ( STR_1[i] == STR_2[i] : FOR ALL i )
;			AX > 0 ( STR_1[i] >  STR_2[i] )
;			AX < 0 ( STR_1[i] <  STR_2[i] )
; DESTROYS: AX
;------------------------------------------------

StrCmp			proc

				push si bp		; push (1) (2)

				mov bp, cx		; BP = CX

				xor si, si		; i  = 0

				__Next:			xor  ax, ax					; AX  = 0
								mov  al, bx[si] 			; AL  = BX[i]
								push dx						; push (3) 
								xor  dx, dx					; DX = 0
								mov  dl, bp[si]				
								sub  ax, dx					; AX -= CX[i] 
								pop  dx						; pop  (3)

								cmp ax, 0d					; if( AX != 0 )
								jne __End

								cmp byte ptr bx[si], 0d		; if( BX[i] == 0 )
								je __End
								
								inc si

								jmp __Next	
				__End:
				pop bp si 		; pop  (2) (1)

				ret 
				endp

;------------------------------------------------
;	TRANSLATE STR TO NUMBER
;------------------------------------------------
; ENTRY:	BX = STR ADDR
; EXIT:		AX = NUM
; EXPECTS:	CX = STR LEN
; DESTROYS:	AX
;------------------------------------------------

Atoi			proc	

				xor ax, ax		; AX = 0

				push dx	si		; push (1) (2)

				xor dx, dx		; i = 0

				__Next:			mov si, bx		; SI = BX + STR_LEN - i
								add si, cx
								sub si, dx
								sub si, 1

								push cx			; push (3)

								push ax			; push (4) 
								xor  ax, ax    	; AX = 0
								mov  al, [si]	; AX = [SI] - '0'
								sub  al, 48d

								push dx			; push (5)
								mov  cx, dx		; AX = AX * 10^DX 
								mov  si, 10d
								jcxz __NoMul

								__Mul:			mul si
								
												dec cx
												cmp cx, 0
												jne __Mul
								
								__NoMul:
								pop  dx			; pop  (5)
								mov  cx, ax	 

								pop ax			; pop  (4)
								add ax, cx
								pop cx			; pop  (3)

								inc dx			; i++

								cmp dx, cx		; if( i == CX )
								jne __Next	

				pop si dx		; pop  (2) (1)	

				ret	
				endp

;------------------------------------------------