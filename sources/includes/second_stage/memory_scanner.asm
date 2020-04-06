%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x0000
%define PTR_MEM_REGIONS_TABLE       0x0018
%define MEM_MAGIC_NUMBER            0x0534D4150  
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack
            
            mov ax,MEM_REGIONS_SEGMENT    ; setting the segment pointer (es) to 0x2000  (the memory after third boot loader region)           
            mov es,ax                     
            xor ebx,ebx                   ; Set region number (index) EBX to zero           
            mov [es:PTR_MEM_REGIONS_COUNT],word 0x0     ; store the number of regions detected in this address 0x1000 of this segment           
            mov di, PTR_MEM_REGIONS_TABLE   ; set the DI to point to the address of the memory regions table               
            .memory_scanner_loop:                    ; Loop over all the memory regions until finish                
                mov edx,MEM_MAGIC_NUMBER         ; Set DX to magic number which is equal to 0x0534D4150, equivalent to 'SMAP'                 
                mov word [es:di+20], 0x1                ; This is needed by function 0xe820 int 0x15                
                mov eax, 0xE820                         ; Set the memory scanner function number                
                mov ecx,0x18                            ; Set size of the information of the region which will be stored in the table               
                int 0x15                                                
                
                jc .memory_scan_failed                  ; If there is a carry indicating a failure, then jmp to memory_scan_failed                
                cmp eax,MEM_MAGIC_NUMBER          ; If eax is equal to the magic  number then continue the code normally                
                jnz .memory_scan_failed                 ; Else that means, there is an error, them jump to exit with error message                
                add di,0x18                             ; moving the pointer to the next entry in the table by increasing the di by 24                
                inc word [es:PTR_MEM_REGIONS_COUNT] ; increase the memory regions counter by one               
                cmp ebx,0x0                             ; If ebx is set to zero, that means we reached the end of memory regions                
                jne .memory_scanner_loop                ; If no, the loop again to fetch new information about the next memory region                
            
            jmp .finish_memory_scan                 ; If we finish scanning memory regions, that means skip outputing error         
            
            .memory_scan_failed:
                mov si, memory_scan_failed_msg 
                call bios_print                     ;print a message indicating a failure 
                jmp hang
                                    
            .finish_memory_scan:            
            popa                                        ; Restore all general purpose registers from the stack
            ret

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax                                   
            xor edi,edi                                 ; set the counter to zero -------------------------------
            mov di,word [es:PTR_MEM_REGIONS_COUNT]      ; store the number of regions in di as a parameter to the bios_print_hexa
            call bios_print_hexa                        ; print the number of regions in hexadecimal representation
            mov si,newline                              ; print a new line
            call bios_print                           
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]          ; store the number of regions in ecx
            mov si,0x0018                               ; set SI to the begining of the table
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]                 ; print the information inside those enteries
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix


                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret