;************************************** first_stage_data.asm **************************************
   

;********************************Memory defnitions*************************************

boot_drive db 0x0		; byte to store in the id of the boot drive
lba_sector dw 0x1		; word to store in the sector number that will be read

spt dw 0x12			; word to store in the number of sectors per track , and we store 12 because that's the default value of a floppy 			
hpc dw 0x2			; word to store in the number of head per cylinder , and we store 2 because that's the default value of a floppy

Cylinder dw 0x0			; memory variable used to store the cylinder number from the lba to chs conversion
Head db 0x0			;  memory variable used to store the head number from the lba to chs conversion
Sector dw 0x0			; memory variable used to store the Sector number from the lba to chs conversion


;****************************string messages for later use***********************************

disk_error_msg	 	db 'Disk Error',13,10,0
fault_msg 	 	db'Unknown Boot Device',13,10,0
booted_from_msg		db 'Booted From',0
floppy_boot_msg		db 'Floppy',13,10,0
drive_boot_msg		db 'Disk',13,10,0
greeting_msg		db '1st Stage Loader', 13,10,0
second_stage_loaded_msg db 13,10,'2nd Stage loaded, press any key to resume!',0
dot 			db '.',0
newline 		db 13,10,0
;*********************************************************************************************
disk_read_segment 	dw 0
disk_read_offset 	dw 0
