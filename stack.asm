%include "common.inc"
STR sXXY,'@@XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

%macro DBG 0
	push_str sXXY
	callv print_string
%endmacro 

proc createStack,0,1
	new
	store 0
	

	push 0
	load 0 
	store_in Stack.ptr

	push 0
	load 0
	store_in Stack.data

	load 0
	ret
endproc


;0 = stack
;1 = element to push
;2 = temp
proc stackPush,2,1
	load 0
	load_from Stack.ptr
	push 1
	add
	store 2
	
	load 1
	load 2
	load 0
	store_inx
	
	load 2
	load 0
	store_in Stack.ptr
	
	push 0
	ret
endproc

; 0 = stack
; 1 = temp
proc stackPop,1,1
	load 0
	dup
	load_from Stack.ptr
	load_fromx
	store 1
	
	load 0
	dup
	load_from Stack.ptr
	push 1
	sub
	store_in Stack.ptr
	
	load 1
	ret
endproc
	

