;************************************** bios_cls.asm **************************************      
      bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen
            pusha           ; pushes all registers in stack to save them 
            mov ah, 0x0     ; set function number  that sets Video Mode 
            mov al, 0x3     ; Video mode 80x25 16 color text 
            int 0x10        ; issue an interrupt 
            popa            ; pop all registers from stack that were saved
            ret
