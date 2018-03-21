extern loadModule

primitive file_open
primitive file_read_byte
primitive file_read_string

extern createVMState
extern vmGetString
extern vmGetMethod
extern runMethod

;Locals 
; 0 = VMState
proc b9main,0,1

	push_str sFilename
	call_prim file_open
	call loadModule
	
	call createVMState
	store 0
	
	load 0
	
	load 0
	push 0
	call vmGetMethod
	
	call runMethod

	ret
endproc

STR sFilename,'HelloWorld.bin'