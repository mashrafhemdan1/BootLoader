%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    disable_pic:
        pusha                               ; save the current status on the stack (gp regs)
        mov al,0xFF                         ; We need to load the master and slave ports of pic with 0xFF, so we load it in al first
        out MASTER_PIC_DATA_PORT,al         ; now we copy al into the master pic port
        out SLAVE_PIC_DATA_PORT,al          ; copy al into the slave pic, as well
        nop                                 ; stall the cpu for two cycles to allow the pic to shutdown
        nop                                 ;
;        mov si, pic_disabled_msg            ; 
;        call bios_print                     ;
        popa                                ; restore the status of the cpu from the stack (gp regs)
        ret                                 ; return