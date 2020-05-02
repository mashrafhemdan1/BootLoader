;************************************** bios_print.asm **************************************      
      bios_print:           ; A subroutine to print a string on the screen using the bios int 0x10.
                            ; Expects si to have the address of the string to be printed.
            pusha                ; Will loop on the string characters, printing one by one. 
                            ; Will Stop when encountering character 0.
           .print_loop:
            xor ax, ax      ; let ax ==0
            lodsb           ; move from memory address pointed to by si a byte and copy it to al
            or al,al        ; Check if al contains zero/null character
            jz .done        ; if the zero flag is set to zero jump to done else continue       
            mov ah,0x0E     ; Function number to print a character    
            int 0x10        ; issue an interrupt 
            jmp .print_loop ; loop to continue printing
            
            .done :
            popa
                ret
