check_a20_gate:
	pusha                    	 ; Save all general purpose registers on the stack
	mov ax,0x2402			 ; mov to ax the function number to check if a20 gate is disacled or not
	int 0x15			 ; isuue an interrupt
	jc .error			 ; if carry flag is set, then an error ocurred so jump to error
	cmp al,0x0			 ; check the value in al returned by the function call
	je .enable_a20			 ; if al ==0 , then the a20 gate is disabled and we need to set it so we jump to enable_20
	.finish:
	popa                             ; Restore all general purpose registers from the stack
	ret
	
	.enable_a20:
	mov ax,0x2401			; function number used to enable the gate
	int 0x15			; issue an interrupt
	jc .error			; if carry flag set, an error ocurred so jump to error
	jmp .finish
	.error:
	jmp hang			; in case of error jump to hang to halt execution
