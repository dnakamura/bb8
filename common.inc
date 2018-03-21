STRUC Instruction
	.bytecode: resb 1
	.arg: resb 1
ENDSTRUC

STRUC Module
	.functions: resb 1
	.strings: resb 1
ENDSTRUC

STRUC VMState
	.module: resb 1
	.valueStack: resb 1
	.callStack: resb 1
ENDSTRUC

STRUC FunctionDef
	.argCount: resb 1
	.localCount: resb 2
	.bytecodes: resb 3
ENDSTRUC

STRUC Stack
	.ptr: resb 1
	.data: resb 1
ENDSTRUC