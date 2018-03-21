%include "common.inc"


;locals
; 0 = Module
; 1 = method index
proc moduleGetMethod
	load 0
	load_from Module.functions
	
	load 1
	load_fromx 
	ret
endproc

