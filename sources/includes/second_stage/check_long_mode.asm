        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack
            pushfd     ;push the value of the eflages register for restoring after the function executino
            pushfd     ;push eflages to be compared with the edited eflages
            pushfd     ;push eflages to be edited and pushed again
            pop eax    ;store the eflages value to the eax
            xor eax, 0x0200000  ; flip the bit number 21 to see the change
            push eax  
            popfd     ;store the changed value to eflages register
            pushfd
            pop eax   ;store the value of eflages to eax 
            pop ecx   ;store the original value to ecx
            
            xor eax, ecx   ;if they are differet (changed) then eax isn't equal to zero
            and eax, 0x0200000  ;zero out all bits expect the 21 bit
            
            cmp eax, 0
            jne .cpuid_supported ;if not equal to zero, then cpuid instruction is supported
            mov si, cpuid_not_supported  ;if equal to zero, then cpuid isn't supported
            call bios_print      ;print message indicating not supporting this
            jmp hang     ;exiting the process

            .cpuid_supported:
                mov si, cpuid_supported  ;
                call bios_print    ;print message indicating cpuid supported
            popfd  ;restoring the original value of eflages
            popa                ; Restore all general purpose registers from the stack
            ret

        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack
            mov eax, 0x80000000                     ; call this cpuid function to determine the largest function number
            cpuid
            cmp eax, 0x80000001                     ; compare the largest function number with the long mode check function
            jl .long_mode_not_supported
            mov eax, 0x80000001
            cpuid                                   ;invoke the check long mode function
            and edx, 0x20000000                     ;zero out all bits in the register except the bit 29
            cmp edx, 0                              ;if the bit is zero, then it's not supported
            je .long_mode_not_supported  
            mov si, long_mode_supported_msg 
            call bios_print                         ;print a message indicating long mode supported
            jmp .exit_check_long_mode_with_cpuid
            
            .long_mode_not_supported:
                mov si, long_mode_not_supported_msg
                call bios_print
                jmp hang
            .exit_check_long_mode_with_cpuid:
                popa                                ; Restore all general purpose registers from the stack
                ret
