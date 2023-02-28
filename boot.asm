;; A tiny, working bootloader for x86 PCs. Has a few subroutines
;; so it's slightly less useless than just printing "hello world".
;;
;; writeup here: http://joebergeron.io/posts/post_two.html
;;
;; Joe Bergeron, 2016.
;;
	bits 16             ; This sets the processor into 16-bit mode.                                                                      

	mov ax, 07C0h       
	mov ds, ax          ; This sets the data segment (DS) to the address of the bootloader, which is 0x07C0.
	mov ax, 07E0h	    ; 07E0h = (07C00h+200h)/10h, beginning of stack segment.
	mov ss, ax          ; This sets the stack segment (SS) to the address 0x07E0.
	mov sp, 2000h	    ; This sets the stack pointer (SP) to the address 0x2000, giving us 8k of stack space.

	call clearscreen    ; This calls the subroutine clearscreen, which clears the screen.                                                                               

	push 0000h                                                                                   
	call movecursor                                                                                   
	add sp, 2           ; This sets the cursor to the top-left corner of the screen by calling the subroutine movecursor.                                                                        

	push msg                                                                                   
	call print                                                                                   
	add sp, 2           ; This prints the string "Oh boy do I sure love assembly!" to the screen by calling the subroutine print.                                                                        

	cli                                                                                   
	hlt                 ; These instructions disable interrupts and halt the processor, effectively freezing the computer.                                                                  


; This is the subroutine clearscreen, which clears the screen by using BIOS interrupt 0x10. It saves the previous value of the stack pointer (SP) and the base pointer (BP), sets up a new stack frame, calls the interrupt, and then restores the previous stack frame and returns.

clearscreen:                                                                       
	push bp         ; Save the value of the base pointer (bp) on the stack
	mov bp, sp      ; Set the value of bp equal to the value of the stack pointer (sp)
	pusha           ; Push all the general-purpose registers (ax, bx, cx, dx, bp, si, di, and sp) onto the stack
                                                                       

	mov ah, 07h     ; Set the value of ah to 07h, which tells the BIOS to scroll down the window
	mov al, 00h     ; Set the value of al to 00h, which clears the entire window
	mov bh, 07h     ; Set the value of bh to 07h, which specifies white text on a black background
	mov cx, 00h     ; Set the value of cx to 00h, which specifies the top-left corner of the screen as the starting point
	mov dh, 18h     ; Set the value of dh to 18h, which specifies 24 rows of characters
	mov dl, 4fh     ; Set the value of dl to 4fh, which specifies 79 columns of characters
	int 10h         ; Call BIOS interrupt 10h, which clears the screen
                                                                      

	popa            ; Restore all the general-purpose registers from the stack
	mov sp, bp      ; Set the stack pointer equal to the base pointer, freeing the stack frame
	pop bp          ; Restore the value of the base pointer from the stack
	ret             ; Return from the subroutine
                                                                       


; This is the subroutine movecursor, which moves the cursor to the position specified by the argument passed on the stack. It saves the previous value of the stack pointer (SP) and the base pointer (BP), sets up a new stack frame, gets the argument from the stack, sets the cursor position using BIOS interrupt 0x10, restores the previous stack frame and returns.

movecursor:
	push bp             ; push base pointer onto stack to save its current value
	mov bp, sp          ; set base pointer to current stack pointer value
	pusha               ; push all general-purpose registers onto stack to save their current values

	mov dx, [bp+4] 	    ; get the argument from the stack. |bp| = 2, |arg| = 2
	mov ah, 02h 	    ; set cursor position
	mov bh, 00h	    ; page 0 - doesn't matter, we're not using double-buffering
	int 10h             ; invoke BIOS video interrupt to move cursor to specified position

	popa                ; restore all general-purpose registers from stack
	mov sp, bp          ; restore stack pointer from base pointer
	pop bp              ; restore base pointer from stack
	ret                 ; return from subroutine
                                                                      


; The "print" subroutine takes a pointer to a null-terminated string and prints the string to the screen.

print:
	push bp           ; save the base pointer to the stack
	mov bp, sp        ; set the stack pointer to the base pointer
	pusha             ; push all registers onto the stack
	mov si, [bp+4]	  ; grab the pointer to the data from the argument on the stack
	mov bh, 00h	  ; set the page number to 0 (we're not using double-buffering)
	mov bl, 00h	  ; set the foreground color to 0 (irrelevant in text mode)
	mov ah, 0Eh       ; set the print character function for TTY (teletype)
 .char:
	mov al, [si]      ; get the current character from our pointer position
	add si, 1         ; increment the pointer to point to the next character
	or al, 0          ; set AL to 0 if it's null
	je .return        ; if the string is done, end the subroutine
	int 10h           ; call the video interrupt to print the character
	jmp .char         ; keep looping until we reach the end of the string
 .return:
	popa              ; restore all registers from the stack
	mov sp, bp        ; restore the stack pointer from the base pointer
	pop bp            ; restore the base pointer from the stack
	ret               ; return from the subroutine

msg:                      ; define the null-terminated string to print
	db "Oh boy do I sure love assembly!", 0

	times 510-($-$$) db 0    ; pad the bootloader to 510 bytes with zeros
	dw 0xAA55                ; add the boot sector signature at the end
                                                      
