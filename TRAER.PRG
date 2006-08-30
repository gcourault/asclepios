/*
traer.prg
permite copiar archivos desde las delegaciones
*/

function traer()
close all
if messyn("¨Comienza con el proceso?")
	msg("Inserte el diskette correspondiente en A:")
	use practica
	append from a:practica
	use pracreng 
	append from a:pracreng
	use deb001 
	append from a:deb001	
	use deb002 
	append from a:deb002
	use cabrec
	append from a:cabrec
	use renrec
	append from renrec
endif
close all
