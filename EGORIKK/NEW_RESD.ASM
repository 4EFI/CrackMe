

; mov ax, 0
; mov si, 0117h
; jmp si

CrackPos = 010eh
CrackCode db 0b8h, 00h, 00h, 0beh, 017h, 001h, 0ffh, 0e6h

;------------------------------------------------

New09           proc   

                push ax                            
                in   al, 60h                        ; get scan key   
                cmp  al, 3bh                        ; F1 = print regs  
                je __PrintRegs

                jmp __NoPrintRegs

                __PrintRegs:

                push ds es

                push bx cx dx es
                mov  bx, CrackPos
                mov  cx, offset CrackCode
                mov  dx, cs
                mov  es, dx
                mov  dx, 8d                         ; DX = N
                call MemCpy                         ; Crack

                mov  bx, 0b800h                     ; ES = VIDEO_SEG
                mov  es, bx 
                xor  bx, bx
                mov  byte ptr es:[bx],   3h         ; Out heart
                mov  byte ptr es:[bx+1], 07h 
                pop  es dx cx bx

                in  al, 61h                         ; Signal keyboard
                or  al, 80h
                out 61h, al
                and al, not 80h             
                out 61h, al

                mov al, 20h                         ; End-of-Intr
                out 20h, al

                pop es ds

                pop ax
                iret

                __NoPrintRegs:

                pop ax

                db 0eah                             ; jmp Old_09_Seg:[Old_09_Ofs]
                Old_09_Ofs dw 0
                Old_09_Seg dw 0  

                iret
                endp

;------------------------------------------------