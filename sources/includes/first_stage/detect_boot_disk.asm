;************************************** detect_boot_disk.asm **************************************      
      detect_boot_disk:     		; A subroutine to detect the the storage device number of the device we have booted from
                            		; After the execution the memory variable [boot_drive] should contain the device number
                            		; Upon booting the bios stores the boot device number into DL
        pusha               		; store all registers in stack
        mov si,fault_msg    		; let si contain the memory address labeled by fault_msg to be used in case of failure
        xor ax, ax          		; let ax ==0 / so we Call function number zero
        int 0x13            		; Issue interrupt to reset the drive whose id is in dl
        jc .exit_with_error 		; if the carry flag is set, an error occured so we'll jump to the label exit_with_error else continue

        mov si, booted_from_msg		; move to si address of booted_from_msg
        call bios_print
        mov [boot_drive],dl     	; move the id value of the device the bios loaded from  in dl and put it in  boot_drive to save it for later use
        
        cmp dl,0            		; compare dl value with zero
        je .floppy          		; if dl ==0, then the boot device is a floppy, thus jump to floppy
        call load_boot_drive_params 	; else call function load_boot_drive_prams to read the disk parameters  
        mov si, drive_boot_msg		;move to si drive_boot_msg, to print the device as drive
        jmp .finish             	; then jump to finish
    .floppy:
        mov si, floppy_boot_msg		 ; move to si floppy_boot_msg to print the device as floppy
        jmp .finish             	; then jump to finish
    .exit_with_error:
        jmp hang            		; if error occured jump to hang
    .finish:
        call bios_print			; when done print message 
        popa				; after that restore all registers in stack
    	ret 
