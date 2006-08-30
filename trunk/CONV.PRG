/* 
------------------------------------------------
   Conv.prg
	Programa que permite asignar a cada prestador
	un convenio y unidades arancelarias
-------------------------------------------------
*/
# include "inkey.ch"

function convenio()

* -----------------------------------------------------------
* Funcion que permite generar, borrar y modificar un convenio
* -----------------------------------------------------------
select 1
if snet_use("IN1PRES","PRESTADO", .f. , 5 , .t. , "No se puede abrir archivo Prestadores - ¨Reintenta?" )
	set order to tag PRCOD
endif
smallkset( K_F2 , "CONVENIO" , "CPRESTADOR" , {|| PRNOMB } , "Prestadores" , "%IN1PRES%PRNOM" , "PRLETR + PRCODI" )
smallkset( K_F2 , "ALTACONV" , "CCONVENIO" , {|| CODIGO + ' ' + DESCRIPCIO} , "Convenios" , "%CONVENIO%CODIGO" , "CODIGO" )
smallkset( K_F2 , "COPIACONVENIO" , "COTROCONV" , {|| CODIGO + ' ' + DESCRIPCIO} , "Convenios" , "%CONVENIO%CODIGO" , "CODIGO" )
cPantalla := makebox( 1 , 1 , 23 , 78 )
@ 4,2 to 4,77
@ 2,40 say "<F2> Busca Prestadores y Convenios"
while .t.
	select PRESTADO
	cPrestador := space( len( PRLETR + PRCODI ) )
	@ 2,2 say "Prestador:" get cPrestador valid isinlook( cPrestador , 1 , nil , .f. , "Prestador incorrecto" )
	read
	if lastkey() == K_ESC
		exit
	endif
	@ 3,2 say PRNOMB
	while .t. 
		nOpcion := menu_v("Opciones:",;
		                  "1. Generar/Modificar Convenio",;
								"2. Ver/Modificar Convenio",;
								"0. Salir")
		do case
			case nOpcion == 1
			AltaConv( cPrestador )
			case nOpcion == 2
			EditaConv( PRESTADO->PRCONV )
			otherwise
			exit
		endcase
	end
end
unbox( cPantalla) 
smallkclr()
close all
return

* -----------------------------------------
* Funcion de Alta del Convenio
* -----------------------------------------
function AltaConv( cPrestador )
private cConvenio,cOtroConv
cConvenio := PRESTADO->PRCONV
cOtroConv := space( len( PRESTADO->PRCONV ) )
select 2
if snet_use("CONVENIO","CONV",.F.,5,.T.,"No se puede abrir Convenio.dbf ¨Reintenta?")
	set order to tag CODIGO
else
	msg( "No se puede abrir Convenio - Reintente luego" )
	close all
	return nil
endif
@ 5,2 say "Ingrese C¢digo Convenio:" get cConvenio 
read
if srec_lock( 5 , .f. )
	replace PRESTADO->PRCONV with cConvenio
	unlock
endif
seek PRESTADO->PRCONV 
if !found()
	msg("No existe Convenio - Lo crear ")
	if srec_lock( 5 , .f. )
		replace CODIGO with cConvenio
	endif
	if messyn("¨Es similar a otro convenio (Ej: Nomenclador Nacional)?")
		CopiaConvenio( cConvenio )	
	else
		select 3
		use r_nome shared
		copy stru to (CONV->ARCHIVO)
		select 3
		use (CONV->ARCHIVO) alias NOMEN exclusive
		index on CODI tag NOMECODI
	endif
else
	select 3
	use (CONV->ARCHIVO) alias NOMEN shared
	set order to tag NOMECODI
endif
editdb( .t. )
return NIL

function CopiaConvenio( cConvenio )
@ 6,2 say "Ingrese C¢digo Convenio a Copiar:" get cOtroConv
read
seek cOtroConv
if found()
	cOtroArch := CONV->ARCHIVO
	seek cConvenio
	cArchivo := CONV->ARCHIVO
	select 3
	use (cOtroArch) alias NOMEN shared
	copy to (cArchivo)	
	select 3
	use (cArchivo) alias NOMEN exclusive
	index on CODI tag NOMECODI
else
	msg("Convenio no encontrado - ser  creado vac¡o")
	select 3
	use r_nome shared
	copy stru to (CONV->ARCHIVO)
	select 3
	use (CONV->ARCHIVO) alias NOMEN exclusive
	index on CODI tag NOMECODI
endif
return NIL

* -----------------------------------------
* Funcion que permite editar el convenio
* -----------------------------------------
Function EditaConv( cConvenio )
select 2
if snet_use("CONVENIO","CONV",.F.,5,.T.,"No se puede abrir Convenio.dbf ¨Reintenta?")
	set order to tag CODIGO
else
	msg( "No se puede abrir Convenio - Reintente luego" )
	close all
	return nil
endif
seek cConvenio
if found()
	gened( .f. , NIL , NIL , { "DESCRIPCIO" , "ARCHIVO" , "UARA" } , { "Descripci¢n","Archivo","C¢d.U.Aranc."} )
else
	msg("No se encuentra el convenio pedido - Crearlo Primero")	
endif
return NIL
