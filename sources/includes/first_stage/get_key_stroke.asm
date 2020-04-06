;************************************** get_key_stroke.asm **************************************      
        get_key_stroke:		 ; A routine to print a confirmation message and wait for key press to jump to second boot stage
        
	pusha			; store all registers in stack
        mov ah, 0x0		; Function number that waits for user's keyboard input, and will stop everything until done 
        int 0x16		; issue interrupt
        popa			; restore all registers from stack
        ret
