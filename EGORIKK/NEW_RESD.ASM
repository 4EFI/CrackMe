
;------------------------------------------------

X_Pos = 1           ; Regs X pos    

WidthBox  = 29d
HeightBox = 6d
ColorBox  = 79d     ; White on Red

DrawBuff        dw  WidthBox * HeightBox dup (0)
SaveBuff        dw  WidthBox * HeightBox dup (0)

BoxStrRsd       db  0
BoxDataRsd      db  X_Pos - 1, 0, WidthBox, HeightBox, ColorBox, 1

IsPrintReg      db  0

;------------------------------------------------

New09           proc   

                push ax                            
                in   al, 60h                        ; get scan key   
                cmp  al, 3bh                        ; F1 = print regs  
                je __PrintRegs

                jmp __NoPrintRegs

                __PrintRegs:

                push ds es

                push bx es
                mov  bx, 010eh
                mov  es, bx
                mov  word ptr es:[bx],   0b817h
                mov  word ptr es:[bx+2], 001ffh
                mov  byte ptr es:[bx+4], 0e0h
                pop  es bx

                push cs                             ; DS = CS
                pop  ds

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