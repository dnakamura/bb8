extern abort

; Read one byte given a file handle
primitive file_read_byte
; This needs to be defined as a primitive for now 
primitive file_read_string

STR sIntOutOfRange,"Integer out of range inside readWord"

;int readWord(FILE *)
proc file_read_word,1,1
	push 0
	store 1

	load 0
	call file_read_byte
	store 1
	
	load 0
	call file_read_byte
	push 256
	mul
	load 1
	add
	store 1
	
	load 0
	call file_read_byte
	push 65536
	mul
	load 1
	add
	store 1
	
	load 0
	call file_read_byte
	push 0
	jne .errorCase
	load 1
	ret
	
.errorCase:
	push_str sIntOutOfRange
	call abort
	; Should be unreachable
	ret
endproc
