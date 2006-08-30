* ---------------------------------------
* Enviar.prg
* Permite enviar los archivos 
* llamado desde el men£ principal
* ---------------------------------------

function enviar()

cFecha := dtoc( date() )
msg( "Este procedimiento permite enviar",; 
     "los archivos cargados durante el d¡a" ,;
     "Necesita un diskette formateado en A:",;
	  "Uno para cada d¡a de la semana",;
	  "Si hay datos de d¡as anteriores ser n borrados" )
if messyn("¨Comienza con el proceso?")
	popread( .f. , "Dia a enviar:" , @cFecha , "@D" )
	cFiltro := "FECHING == ctod( cFecha )"

	plswait( .t. , "Copiando Pr cticas" )
	use practica
	set filter to &cFiltro
	go top
	copy to a:practica
	use pracreng
	set filter to &cFiltro
	go top
	copy to a:pracreng
	plswait( .f. )
	
	plswait( .t. , "Copiando Recetas" )
	use cabrec
	set filter to &cFiltro
	go top
	copy to a:cabrec
	use renrec
	set filter to &cFiltro
	go top
	copy to a:renrec
	plswait( .f. )

	plswait( .t. , "Copiando D‚bitos" )
	use deb001
	set filter to &cFiltro
	go top
	copy to a:deb001
	use deb002
	set filter to &cFiltro
	go top
	copy to a:deb002
	plswait( .f. )
endif
close all
return
