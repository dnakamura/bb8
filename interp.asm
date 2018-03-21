%include "common.inc"

extern createStack
extern stackPush
extern stackPop
extern abort

STR sXXX,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

%macro DBG 0
	push_str sXXX
	callv print_string
%endmacro 

;locals 
; 0 = Module
; 1 = VMState
proc createVMState,1,1
	new
	store 1

	load 0
	load 1
	store_in VMState.module

	
	call createStack
	load 1
	store_in VMState.valueStack
	
	load 1
	call createStack
	store_in VMState.callStack
	
	load 1

	ret	
endproc

;locals
; 0 = VMState
; 1 = method Index
proc vmGetMethod,2,0

	; Load the module
	load 0
	load_from VMState.module

	; retrieve function def from the module
	load_from Module.functions
	load 1
	load_fromx
	ret
endproc

;locals
; 0 = VMState
; 1 = string index
proc vmGetString,2,0
	; Load the module
	load 0
	load_from VMState.module
	
	; retrieve function def from the module
	load_from Module.strings
	load 1
	load_fromx
	ret
endproc
	
	
STR sBadBytecode,"Invalid bytecode"
;Locals
; 0 = VMState
; 1 = FunctionDef
; 2 = arguments
; 3 = locals
; 4 = bytecodes
; 5 = pc
; 6 = insn temp
; 7 = bc temp
proc runMethod,2,6

	load 1
	load_from FunctionDef.bytecodes
	store 4
	
	push 0
	store 5

	push 1234

.bcloop:
	;get the next instruction
	load 4
	load 5
	load_fromx
	store 6

	
	;get the actual bytecode part
	load 6
	load_from Instruction.bytecode
	store 7

	;dispatch based on bytecode
	load 7
	push BC_STR_PUSH_CONSTANT
	jeq .bc_push_str
	
	load 7
	push BC_PRIMITIVE_CALL
	jeq .bc_call_prim
	
	load 7
	push BC_FUNCTION_RETURN
	jge .bc_ret
	
	.invalidBytecode:
	load 7
	push_str sBadBytecode
	call abort

	
.bc_push_str:
	;fuck it lets just fake it on our own stack
	;load 0 ;load the vm state
	; get the immediate value
	
	load 0
	load 6
	load_from Instruction.arg
	call vmGetString
	
	
	;call doPushString
	
	jmp .endDispatch
	
.bc_call_prim:
	; get the immediate value
	load 6
	load_from Instruction.arg
	callv print_stack
	DBG
	callv doCallPrimitive
	jmp .endDispatch

.bc_ret:
	;TODO we need to actually properly handle this
	ret

.endDispatch:

	load 5
	push 1
	add
	store 5
	jmp .bcloop

endproc


		;PROVIDE(print_string = 0);
		;PROVIDE(print_number = 1);
		;PROVIDE(print_stack = 2);
		;PROVIDE(file_open = 3);
		;PROVIDE(file_read_byte = 4);
		;PROVIDE(file_read_string = 5);
		;PROVIDE(file_tell = 6);
STR sBadPrimitiveId,"Bad primitive id given"
; TODO we are horribly abusing the stack here
proc doCallPrimitive,1,0

	dup
	
	push 0
	jeq .prim_print_string
	jmp .badPrim

.prim_print_string:
	;drop the extra primitive id off the stack
	drop
	call print_string
	ret
	
	
.badPrim
	push_str sBadPrimitiveId
	call abort
endproc

