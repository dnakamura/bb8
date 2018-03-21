; void abort(char*)
STR sAbort,"========= ABORT CALLED ==================="
STR sAbortMsg,"========= ABORT MSG ==================="
proc abort,1,0
	push_str sAbort
	callv print_string
	callv print_stack
	push_str sAbortMsg
	callv print_string
	load 0
	callv print_string
	
	; Force an invalid opcode to kill the interpreter
	BYTECODE(0xff)
endproc
