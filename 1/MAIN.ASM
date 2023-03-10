
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
                mov  cx, BuffSize
                call Input

                mov  bx, offset PasswordBuff
                mov  cx, offset Password
                call strcmp                 ; if( strcmp( Password, Buff ) == 0 )
                cmp  ax, 0
                je __Correct

                jmp __Wrong

                __Correct:

                mov  ah, 12h
                mov  bh, 0
                mov  bl, 23d
                mov  cx, offset Correct
                call PrintStr

                jmp __End

                __Wrong:

                mov  ah, 4eh
                mov  bh, 0
                mov  bl, 23d
                mov  cx, offset Wrong
                call PrintStr

                __End:

                EXIT

;------------------------------------------------

BuffSize = 256d  
PasswordBuff    db BuffSize dup (12, 64, 85, 14)

Correct         db "Correct Password :))", 0
Wrong           db "Wrong Password :(", 0

Password        db "SanyaGey1234567890", 0

include 	    STR_HNDL.ASM 	            ; Str handler

end             Start

;------------------------------------------------
