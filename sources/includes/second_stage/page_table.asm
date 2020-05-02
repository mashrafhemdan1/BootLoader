%define PAGE_TABLE_BASE_ADDRESS 0x0000
%define PAGE_TABLE_BASE_OFFSET 0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000
%define PAGE_PRESENT_WRITE 0x3  ; 011b
%define MEM_PAGE_4K         0x1000

build_page_table:

    pusha                               ; Save all general purpose registers on the stack

        ; Store the address (address:offset) where the PT should be stored into es:edi
        mov ax, PAGE_TABLE_BASE_ADDRESS
        mov es, ax        
        mov edi, PAGE_TABLE_BASE_OFFSET

        ; Create 4 memory virtual pages and initialize them with zeros
        xor eax, eax                    ; Store zero in eax 
        mov ecx, 0x1000                 ; This is the counter we will use
        cld                             ; Reset the flag of direction
        rep stosd                       ; Store the value in eax (4 bytes) into es:edi then advance edi by 4
                                        ; And repeat the process for 0x1000 times (4096 times)
                                        ; That's total of 4096*4 = 16 KB (4 memory virtual pages)

        mov edi, PAGE_TABLE_BASE_OFFSET ; edi was modified by the previous process, so we need to re-initialize it

        ; Now, we have initialized the space for 4 memory virtual pages, and we need to implement 4-level PT upon them
        ; Top level PML4 is at 0x1000, we will fill the first entry in it with the address of the second level PDP
        lea eax, [es:di + MEM_PAGE_4K]  ; Load effective address of PDP into eax
        or eax, PAGE_PRESENT_WRITE      ; Set the present and write bits, which are bits #0 and #1 / 
        ; Since we are sure that the next 3 hexa digits after the first one indicating the base address, we can use them to store the flags
        mov [es:di], eax                ; Now, the address PDP is stored in the first entry in PML4 
        ; Repeat the previous process for the next level PD
        
        push esi
        mov si, pml4_page_table_msg
        call bios_print
        pop esi

        add di, MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K]
        or eax, PAGE_PRESENT_WRITE
        mov [es:di], eax

        ; And Pt
        add di, MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K]
        or eax, PAGE_PRESENT_WRITE
        mov [es:di], eax

        ; Now, we need to fill the 512 entries of PT / Map 2 MB
        add di, MEM_PAGE_4K
        mov eax, PAGE_PRESENT_WRITE     ; Store the flags in eax, will be used shortly
    .pte_loop:
        mov [es:di], eax                ; Set the flags for the entry
        add eax, MEM_PAGE_4K            ; Store in eax the address of the next physical page
        add di, 0x8                     ; Advance di by 0x8 to point to the next entry
        cmp eax, 0x200000               ; Check if we reached 2 MB
        jl .pte_loop                    ; Loop again if we still did not reach 2 MB
        
    push esi
    mov si, page_table_2mb_msg
    call bios_print
    pop esi

    popa                                ; Restore all general purpose registers from the stack
    ret