;Function: map_virtual_adr
;the function assumes the PML4 is already set and its address is stored in CR3 register

;INPUT: rax ---> virtual address
;OUTPUT: rdi---> physical address

map_virtual_adr:
    ;save all registers
    push r8
    push r9
    push r10
    push r11
    push rax

    ;LEVEL-BASED SEARCH -----------------
    mov r11, 1              ;counter to loop over page levels
    mov r9, cr3             ;load the address of the level one page table

    .level_search:
    ;r9: will contain the address of the current table to search inside
    ;r11: will contain the page level number

    ;specifying shift amount
    push rax 
    mov rax, 9
    mult r11
    add rax, 16
    mov r10, 64
    sub r10, rax            ;r10: contains the shift amount for the index extraction stage
    pop rax

    ;extract first 9 bits  (store in r8)
    mov r8, rax             ;r8 contains the virtual address
    shr r8, r10             ;shift the address until make the 9 bits in the lowest significant positions
    and r8, 0x0111111111b   ;extract the first 9 bits of those
    ;get the address of the corresponding entry (store in r8)
    shl r8, 3               ;multiply the index by 8 to get the offset address
    add r8, r9              ;get the absolute address of the entry

    ;check the present bit
    mov r10, [r8]
    and r10, 0x1b           ;to get the 0 bit (present bit)
    cmp r10, 0
    je handle_page_fault    ;if zero, go to this function to build the table or find an available physical frame

    ;get the address of the next page table or the physical frame (depends on the level)
    mov r10, [r8]           ;get entry information in r10
    shr r10, 12             ;so that the base address in the lowest significant 40 bits
    and r10, 0xFFFFFFFFF    ;get the first 36 bits of the base address 
    shl r10, 12             ;shift left by 12 bits. first 12 bits are zeros because any page table is 4K aligned (occupying a physical frame)
    mov r9, r10             ;then r9 has the address of the next page table
    
    ;if we are searching in level 4, then jump to calculate the address
    cmp r11, 4
    jle .calculate_address 

    add r11, 1              ;update the page table number before jumping to the next level search
    jmp level_search        ;again to search in the next page table

    .calculate_address:
    ;Input: rax --> virtual address
    ;       r9  --> physical address (no offset is applied)
    mov r8, rax 
    and r8, 0xFFF           ;extract the first 12 bits which are the offset
    shl r9, 12              ;shift the base address 12 bits to avail a space for the offset
    add r9, r8              ;concatenating the address with the offset
    mov rdi, r9             ;this move just to make the returned value in rdi
    mov r8, cr3
    mov cr3, r8             ;just for the CPU to be aware of recent updates
    

   .Mem_Test:
	mov [rdi],1
	mov si, [rdi]
	call bios_print



    ;restore all registers
    pop rax
    pop r11
    pop r10
    pop r9
    pop r8

    ret


    ;internal label: handle_page_fault
    ;the function assumes the PML4 is already set and its address is stored in CR3 register

    ;INPUT: r8 ---> address of the empty entry
    ;       r11 ---> page table level number
    ;OUTPUT: r9---> physical address (in case there is no avaliable physical memory, rdi = 0)

    .handle_page_fault:
        ;find an available physical frame (either for building page table, or mapped physical frame)
        call get_avPhy_frame

        cmp r11, 4
        je .find_avPhy_frame ;if this table is the forth page table, then jmp forward to find available physical frame

        ;create a page table
        call find_avPhy_frame


    .find_avPhy_frame:







;ASSUMPTIONS:
;BIT MAP FUNCTION: 
(1) get_avPhy_frame:   
INPUT: (rbx) bit map address 
Output: (rdi) physical frame (zero if not found)
(2) build_bit_map:
INPUT: (rbx) bit map address



