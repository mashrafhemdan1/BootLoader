 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]

    pusha                   ; store all registers in stack
    xor dx,dx               ; let dx==0
    mov ax,[lba_sector]     ; copy vlue of lba_sector into ax 
    div word[spt]           ;divide ax (lba_sector) by [spt]
    inc dx                  ; increment remainder of division and thus dx will contain the sector value
    mov [Sector],dx         ; store sector value in memory/[Sector]
    xor dx,dx               ;let dx ==0
    div word[hpc]           ;divide ax by [hpc] ==([lba_sector]/[spt])/[hpc])
    mov [Cylinder],ax       ;store quotient which is the cylinder value in memory/[Cylinder]
    mov [Head], dl          ;store remainder in memory /[head]
    
    popa                    ; pop all registers from stack
    ret
