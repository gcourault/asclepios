/* 
-------------------------------------------------------
   CargAut.prg
	programa de carga de autorizaciones
	Trae los datos desde las delegaciones
-------------------------------------------------------
*/
function cargaut()
msg("Para realizar este proceso se necesita",;
    "que nadie est‚ trabajando en REGIONAL")
if messyn("¨Comienza con el proceso?")
	if snet_use("AUTORIZ","AUTORIZ",.T.,5,.T.,"No se puede usar el archivo de autorizaciones - ¨Reintenta?" )
		set order to tag AUTORIZ	
	else
		msg("Haga salir a todos del programa REGIONAL y reintente")
	endif
	msg("Coloque el diskette en A:")
	plswait(.t.)
	append from a:autoriz
	plswait(.f.)
endif
close all
return
