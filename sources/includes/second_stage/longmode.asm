switch_to_long_mode:

     mov eax,10100000b                       ; we will set the 5th bit ,PAE, and 7th bit, PGE,in the cr4 register which is responsible for CPU exensions  
     mov cr4,eax

    mov edi, PAGE_TABLE_EFFECTIVE_ADDRESS    ; we will move the Page table (PML4) addrress into edi
    mov edx, edi                             ; copy value of edi to edx
    mov cr3,edx                              ; copy value in edx to cr3, so now cr3 points at the Page table ,PML4

                                             ; rdmsr and wrmsr are special registers used with the EFER

     mov ecx, 0xC0000080                     ; write to ecx value number corresponding to the register EFER
     rdmsr
     or eax, 0x00000100                      ; or value in eax with eax to set bit 8 and write to the MSR/ EFER and enable the long mode
     wrmsr

                                             ; Enable Paging and Protected mode 

    mov ebx,cr0
    or ebx, 0x80000001
    mov cr0,ebx                              ; by moving value in ebx to cr0 we are setting bit 0 which enables protected mode and bit 31 which enables Paging



    ret 