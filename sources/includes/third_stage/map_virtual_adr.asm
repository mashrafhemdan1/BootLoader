;Function: map_all_memory
;the function assumes the PML4 is already set and its address is stored in CR3 register

%define PTR_MEM_REGIONS_COUNT      0x20000
%define PTR_MEM_REGIONS_TABLE      0x20018

map_all_memory:
;INPUT: ()
;save registers
mov cr3, 0x100000   ;make the cr3 point to the second mega byte so that our PML4 starts from this address
xor rax, rax ;just to start from the first virtual page

.map_loop:
call map_virtual_adr  ;map this virtual page to an available physical frame

cmp rdi, 0            ;if the output is zero, this means no physical frames are available
je .map_exit          ;exit the loop and return 

add rax, 0x1000       ;add 4K to the address to move to the next virtual page
jmp .map_loop         ;loop again to map the next virtual page

.map_exit:
ret



;Function: map_virtual_adr
;the function assumes the PML4 is already set and its address is stored in CR3 register

;INPUT: rax ---> virtual address
;OUTPUT: rdi---> physical address

%define BIT_MAP_ADDRESS 0xXXXXXX
%define BAGE_PRESENT_WRITE 0x3 011b

map_virtual_adr:
    ;save all registers
    push r8
    push r9
    push r10
    push r11
    push rax

    ;LEVEL-BASED SEARCH -----------------
    mov r11, 1              ;counter to loop over page levels (start with level 1)
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
    and r8, 0111111111b   ;extract the first 9 bits of those
    ;get the address of the corresponding entry (store in r8)
    shl r8, 3               ;multiply the index by 8 to get the offset address
    add r8, r9              ;get the absolute address of the entry

    ;check the present bit
    mov r10, [r8]
    and r10, 1b           ;to get the 0 bit (present bit)
    cmp r10, 0
    je .handle_page_fault    ;if zero, go to this function to build the table or find an available physical frame

    ;get the address of the next page table or the physical frame (depends on the level)
    mov r10, [r8]           ;get entry information in r10
    shr r10, 12             ;so that the base address in the lowest significant 40 bits
    and r10, 0xFFFFFFFFF    ;get the first 36 bits of the base address 
    shl r10, 12             ;shift left by 12 bits. first 12 bits are zeros because any page table is 4K aligned (occupying a physical frame)
    mov r9, r10             ;then r9 has the address of the next page table or the mapped physical frame
    
    ;if we are searching in level 4, then jump to calculate the address
    cmp r11, 4
    je .calculate_address 

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
	mov [rdi],1             ;
	mov rsi, [rdi]
	call video_print

    .exit:
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
    ;       r11 ---> page table level number in which this entry exists
    ;OUTPUT: r9---> physical address (in case there is no avaliable physical memory, rdi = 0)

    .handle_page_fault:
    mov rbx, BIT_MAP_ADDRESS    ;passing paramter to the function 
    call get_avPhy_frame

    cmp rdi, 0                  ;if zero, this means memory type 1 is fully occupied
    je .exit                    ;exit the function with an error
    
    mov r10, rdi                ;r10 now contains the address of the new physical frame/page table (36_bit base address + 12-bit zeros because it's 4k aligned)
    or r10, BAGE_PRESENT_WRITE  ;set the attributes (present bit) (36_bit base address + 12-bit attributes) (we don't do any shift as the base address is already in its position)
    mov [r8], r10               ;change the information inside this entry (address+attributes)

    mov r9, rdi                 ;move into r9 the address of the physical frame/next page table 
    cmp r11, 4                  ;if this entry is in the forth table, then this virtual page is mapped to this physical frame
    je .calculate_address       ;jump to concatenate the offset

    add r11, 1                  ;move to the next page table
    mov r8, rdi                 ;update the input to the internal function, r8 should contain the entry that needs mapping, (in this case, it's the first one in the table)
    jmp .handle_page_fault       ;do these steps again








;ASSUMPTIONS:
;BIT MAP FUNCTION: 
(1) get_avPhy_frame:   
INPUT: (rbx) bit map address 
Output: (rdi) physical frame (zero if not found)
(2) build_bit_map:
INPUT: (rbx) bit map address




