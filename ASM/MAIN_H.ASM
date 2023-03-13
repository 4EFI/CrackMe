
.286
.model tiny
.code 
org 100h

locals __

;------------------------------------------------

include 	    TOOLS.ASM 				    ; Exit

Start:          mov bx, 0b800h              ; ES = VideoSeg
                mov es, bx

                mov  bx, offset PasswordBuff
                call Input

                mov  bx, offset PasswordBuff
                call CountHash              

                cmp ax, Hash
                je __Correct

                jmp __Wrong

                __Correct:

                mov  dx, offset Correct
                call PrintStrCmd

                jmp __End

                __Wrong:

                mov  dx, offset Wrong
                call PrintStrCmd

                __End:

                EXIT

;------------------------------------------------

BuffSize = 16d 
PasswordBuff    db BuffSize dup (12, 64, 85, 14) , 0

Correct         db "Correct Password :))$"
Wrong           db "Wrong Password :($"

Hash = 231d

include 	    STR_HNDL.ASM 	            ; Str handler
include 	    SCR_HNDL.ASM 	            ; Scr handler

;------------------------------------------------
;   PRINT STR TO CMD LINE
;------------------------------------------------
; ENTRY:    DX = STR
; EXPECTS:  END SYM = "$"
; DESTROYS: NONE
;------------------------------------------------

PrintStrCmd     proc
                push ax

                mov ah, 09h
                int 21h

                pop ax
                ret
                endp

;------------------------------------------------
;   CREATE HASH
;------------------------------------------------
; ENTRY:    BX = STR
; EXIT:     AX = HASH
; EXPECTS:  END SYM = "\0"
; DESTROYS: AX
;------------------------------------------------

CountHash       proc

                push bx dx

                xor ax, ax      ; AX = 0
              
                __Next:         cmp byte ptr [bx], 0
                                je __End         
                                    
                                xor dx, dx
                                mov dl, [bx]

                                add ax, dx

                                inc bx 

                                jmp __Next
                __End:

                pop dx bx

                ret
                endp

;------------------------------------------------

end             Start

;------------------------------------------------
