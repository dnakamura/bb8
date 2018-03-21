STR sHelloWorld,"Hello World"

proc b9main,0,0
	push_str sHelloWorld
	call print_string
	ret
endproc
