;************************************** load_boot_drive_params.asm **************************************
      load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]
                

        pusha                   ; copy all registers in stack
        xor di,di               ;let di==0 and move it to es to avoid a bug that might occur when we call function 0x8 to detect the disk parameters
  
        mov es,di
        mov ah, 0x8             ;move to ah function number that returns disk parameters
        mov dl, [boot_drive]    ; move to dl the id of the disk we want to check
        int 0x13                ; issue an interrypt
        jc .error               ;if carry flag is set    
        inc dh                  ;increment dh by one to have the total number of heads stored in it
    
        mov word[hpc],0x0       ; set hpc to zero
        mov [hpc+1],dh          ; store in second byte of hpc dh

        and cx,0000000000111111b ;and cx with 0000000000111111 to get the 6 right most bits of cx which are the number of sectors per track
        
        mov word[spt],cx       ; then move what's in cx to spt
        .error:
        mov si, fault_msg
        call bios_print
        jmp hang 
        popa                   ; restore all registers stored in stack
        ret
