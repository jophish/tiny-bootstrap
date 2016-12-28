;; A tiny, working bootloader for x86 PCs. Has a few subroutines
;; so it's slightly less useless than just printing "hello world".
;;
;; writeup here: http://joebergeron.io/posts/post_two.html
;;
;; Joe Bergeron, 2016.
;;
	bits 16

	mov ax, 07C0h
	mov ds, ax
	mov ax, 07E0h		; 07E0h = (07C00h+200h)/10h, beginning of stack segment.
	mov ss, ax
	mov sp, 2000h		; 8k of stack space.

	call clearscreen

	push 0000h
	call movecursor
	add sp, 2

	push msg
	call print
	add sp, 2

	cli
	hlt

clearscreen:
	push bp
	mov bp, sp
	pusha

	mov ah, 07h		; tells BIOS to scroll down window
	mov al, 00h		; clear entire window
    	mov bh, 07h    		; white on black
	mov cx, 00h  		; specifies top left of screen as (0,0)
	mov dh, 18h		; 18h = 24 rows of chars
	mov dl, 4fh		; 4fh = 79 cols of chars
	int 10h			; calls video interrupt

	popa
	mov sp, bp
	pop bp
	ret

movecursor:
	push bp
	mov bp, sp
	pusha

	mov dx, [bp+4] 		; get the argument from the stack. |bp| = 2, |arg| = 2
	mov ah, 02h 		; set cursor position
	mov bh, 00h		; page 0 - doesn't matter, we're not using double-buffering
	int 10h

	popa
	mov sp, bp
	pop bp
	ret

print:
	push bp
	mov bp, sp
	pusha
	mov si, [bp+4]	 	; grab the pointer to the data
	mov bh, 00h	        ; page number, 0 again
	mov bl, 00h		; foreground color, irrelevant - in text mode
	mov ah, 0Eh  		; print character to TTY
 .char:
	mov al, [si]   		; get the current char from our pointer position
	add si, 1		; keep incrementing si until we see a null char
	or al, 0
	je .return        	; end if the string is done
	int 10h         	; print the character if we're not done
	jmp .char	  	; keep looping
 .return:
	popa
	mov sp, bp
	pop bp
	ret


msg:	db "Oh boy do I sure love assembly!", 0

	times 510-($-$$) db 0
	dw 0xAA55

