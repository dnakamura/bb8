%include "common.inc"

extern abort
primitive file_read_byte
primitive  file_read_string
extern file_read_word




; 0 = FILE
; 1 = instruction object
; 2 = imm temp
proc readInstruction,1,2

	new 
	store 1
	
	load 0
	call file_read_byte
	store 2

	load 0 
	call file_read_byte
	push 256
	mul
	load 2
	add
	store 2

	load 0
	call file_read_byte
	push 65536
	mul
	load 2
	add
	load 1
	store_in Instruction.arg
	
	load 0
	call file_read_byte
	load 1
	store_in Instruction.bytecode
	
	
	load 1
	ret
endproc


;read instructions until we hit end of function
;Object readInstructions(FILE *)
;locals:
; 0 = file
; 1 = ctr
; 2 = return object
; 3 = insn temp
proc readInstructions,1,3
	push 0
	store 1
	new 
	store 2

.bcLoop:
	load 0
	call readInstruction
	store 3
	
	
	; save the instruction into the array
	load 3
	load 2
	load 1
	store_inx
	;increment the counter
	load 1
	push 1
	add
	store 1

	;check if we are at end of module
	load 3
	load_from Instruction.bytecode

	push BC_END_SECTION
	jne .bcLoop
	
	load 2
	ret
endproc
	

;Function readFunction(FILE*)
; locals
; 0 = returnObject
proc readFunction,1,1
	new
	store 1
	
	
	;read the argument count
	load 0
	call file_read_word

	load 1
	store_in FunctionDef.argCount
	
	;read the local count
	load 0
	call file_read_word
	load 1
	store_in FunctionDef.localCount
	;read the bytecodes
	load 0
	call readInstructions
	load 1
	store_in FunctionDef.bytecodes
	
	load 1
	ret	
endproc

STR sBadFuncIdx,"Bad function index"

;void readFunctionSection(Module, FILE)
;locals
; 0= module
; 1 = file
; 2 = functioncount
; 3 = counter;
; 4 = function defs
proc loadFunctionSection,2,3
	push 0
	store 3

	new 
	store 4

	load 1
	call file_read_word
	store 2

.loop:

	load 3
	load 2
	jge .done
	
	;Throw away the name
	load 1
	dup
	callv file_read_string
	
	;read function idx
	;load 1
	call file_read_word

	;make sure it is what we expect
	load 3
	jne .idxError
	
	;read the function def
	load 1
	call readFunction
	
	;save it in the table
	load 4
	load 3
	store_inx
	
	;increment the counter
	load 3
	push 1
	add
	store 3
	
	jmp .loop
.done:

	;store the function table into the module
	load 4
	load 0	
	store_in Module.functions
	
	push 0
	ret
	

.idxError:
	push_str sBadFuncIdx
	call abort

endproc

%macro AssertChar 1
	call file_read_byte
	push_int %1
	jne .badHeader
%endmacro 


STR sBadHeader,"Invalid module header"
; OBJECT readStrings(FILE*)
proc readHeader,1,0
	load 0
%rep 7
	dup
%endrep
	AssertChar 'b'
	AssertChar '9'
	AssertChar 'm'
	AssertChar 'o'
	AssertChar 'd'
	AssertChar 'u'
	AssertChar 'l'
	AssertChar 'e'
	push 0
	ret
	
.badHeader:
	push_str sBadHeader
	call abort
	ret
endproc
%unmacro AssertChar 1

; local mapping
; 0 = file
; 1 = stringTable
; 2 = stringCount
; 3 = counter
proc readStringSection,1,4	
	new
	store 1
	
	load 0
	call file_read_word
	store 2

	push 0
	store 3

.loop:
	load 3
	load 2
	jge .done

	;read a string
	load 0
	call file_read_string
	
	;and store it in the string table
	load 1
	load 3
	store_inx
	
	;increment the counter
	load 3
	push 1
	add
	store 3
	
	jmp .loop
	
.done:
	load 1
	ret
endproc

;void loadStringSection(Module, file)
; locals
; 0 = module
; 1 = file
; 2 = strings counter
proc loadStringSection,2,1

	load 1
	call readStringSection
	
	load 0
	store_in Module.strings
	
	push 0
	ret
endproc


; void loadSection(Module, FILE*)
STR sInvalidSection,'Invalid section code'
proc loadSection,2,0
	load 1
	call file_read_word 

	dup ;[section# section#]
	push 1 ;[1 section# section# file]
	jeq .isFunctionSection ;[section# file]
	dup ;[section# section# file]
	push 2 
	jeq .isStringsSection
	
	; bad section code
	call print_number
	drop
	push_str sInvalidSection
	call abort

	
	.isFunctionSection:
		drop ; we have extra section code on stack
		load 0
		load 1
		call loadFunctionSection
		ret
		
	.isStringsSection:
		drop
		load 0
		load 1
		call loadStringSection
		ret
endproc

STR sFpos,"File pos"
; Module loadModule(FILE *f)
; Local mapping
; 0 = File handle
; 1 = module
proc loadModule,1,1
	push 511
	call createModule
	store 1

	load 0
	call readHeader
	drop
	
	
	;;TODO at the moment we only assume 2 sections
	load 1
	load 0
	call loadSection
	drop
	
	load 1
	load 0
	call loadSection
	drop
	
	load 1
	
	ret
endproc

proc newObject,0,1
	new
	store 0
	push 0
	load 0
	store_in 0
	
	load 0
	ret
endproc

STR screate,"CreateModule"
proc createModule,0,3

	push 55
	call newObject
	store 0

	call newObject
	store 1

	call newObject
	store 2
	load 0
	load 2
	store_in 1
	
	load 1
	load 2
	store_in Module.strings

	load 2
	ret
endproc
