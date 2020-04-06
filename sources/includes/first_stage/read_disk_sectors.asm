 ;************************************** read_disk_sectors.asm **************************************
      read_disk_sectors: ; This function will read a number of 512-sectors stored in DI 
                         ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
            pusha         			; store all registers in stack
            add di,[lba_sector]			; move to di the last sector to be read from  [lba_sector]
            mov ax,[disk_read_segment]		;move in ax the value stored in disk_read_segment
            mov es,ax       			; copy ax into es, so es has the value [disk_read_segment]
            add bx, [disk_read_offset]		;move into bx [disk_read_offset]/ the loaction within the segment to read to	
            mov dl, [boot_drive]		; move into dl the boot_drive value (id number of boot device)
            .read_sector_loop:			
                call lba_2_chs			;call lba_2_chs to convert the lba sector number into chs values and dtore them in cylinder,head,and sector 
                mov ah,0x2			;move to ah the function number that reads a sector from a disk
                mov al,0x1			;set al to 1, meaning read one sector 
                mov cx,[Cylinder]		;move to cx the cylinder value of the disk
                shl cx,0x8			;shift left value 8 bits 
                or cx,[Sector]			; or cx with Sector to have in cx the cylinder amd sector value
                mov dh,[Head]			; move to dh, head
                int 0x13			; issue an interrupt, to read the current sector 
                jc .read_disk_error		; if carry flag is set jump to read_disk_error
                mov si, dot			; move to si '.', to ensure that the sector was read
                call bios_print			;print whatever is in si
                inc word [lba_sector]		; increment lba_sector to read the next sector
                add bx, 0x200			;increment merory location where the next sector will be read into
                cmp word[lba_sector],di		; compare di with [lba_sector] 
                jl .read_sector_loop		; if the sector we're reading from is less than the last sector continue the loop
                jmp .finish			; jump to finish when all sectors are read
             .read_disk_error:			
                    mov si,disk_error_msg 	; if error occurs move to si the disk_error_msg
                    call bios_print		; call bios_print to print the error message
                    jmp hang			;then jump to hang 
             .finish:
                    popa			; restore all regisers from stack
                     ret 
