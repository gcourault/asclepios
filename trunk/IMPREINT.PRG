/* -------------------------------------------------------
   ImpReint.prg
	programa que permite capturar los reintegros
	y los reimprime
----------------------------------------------------------*/
#include "inkey.ch"


function impreint()
initsup()
while .t.
	nOpcion := menu_v("Seleccione:","1.Reintegros Farmacia",;
   	                             "2.Reintegros Pr cticas",;
											  "0.Salir" )
	do case
	case nOpcion == 1
		impreifar()
	case nOpcion == 2
		impreipra()
	otherwise
		exit
	endcase
end
close all
return

* ------------------------------------------------------------
* Funci¢n que permite la reimpresi¢n de reintegros de farmacia
* ------------------------------------------------------------
function impreifar()

select 0
if snet_use("MEDI","MEDICAME",.F.,5,.T.,"No se puede abrir archivo de medicamentos - ¨Reintenta?" )
	set order to tag metroq
else
	msg("No se puede abrir el archivo de medicamentos")
endif

select 2
if snet_use("CABREC","CABREC",.F.,5,.T.,"No se puede abrir archivo de CABECERA - ¨Reintenta?")
	set order to tag CABREC
else
	msg("No se puede abrir archivo de recetas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 3
if snet_use("RENREC","RENREC",.F.,5,.T.,"No se puede abrir archivo de recetas - ¨Reintenta?")
	set order to tag RENREC
else
	msg("No se puede abrir archivo de recetas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 5
if snet_use("BASEAFIL","AFILIADO",.F.,5,.T.,"No se puede abrir el archivo de afiliados - ¨Reintenta?")
	set order to tag AFINUM
else
	msg("No se puede abrir archivo de afiliados",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 8
if snet_use("MOTIVOS","MOTIVOS",.F.,5,.T.,"No se puede abrir archivo de MOTIVOS - ¨Reintenta?")
	set index to MOTIVOS
else
	msg("No se puede abrir archivo de MOTIVOS",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select cabrec
set relation to AFILIADO into AFILIADO addi

select renrec
set relation to troquel into MEDICAME

select CABREC
cNumero := space(len( renrec->numero ) )
popread( .t. , "Ingrese el N§ del reintegro" , @cnumero , "@9" )
set filter to serie == "RE" .and. numero == cnumero
go top
if eof()
	msg("No existe ese reintegro")
else
	select RENREC
	set filter to serie = "RE" .and. numero = cnumero
	go top
	mnumero := numero
	mFechaPres := dtoc( CABREC->FECHA )
	mtotal := CABREC->APAGAR
	mafiliado := CABREC->AFILIADO
	mmotivo := CABREC->MOTIVO
	do imprein
endif

close all
return NIL

function impreipra()
* -----------------------------------------------
* Funcion que permite la reimpresi¢n de pr cticas
* ------------------------------------------------
select 6
if snet_use("CONVENIO","CONV", .f. , 5 , .t. , "No se puede abrir archivo de Convenios - ¨Reintenta?")
	set order to tag CODIGO
else
	msg("No se puede abrir archivo de Convenios",;
	    "Un usuario bloquea el archivo",;
		 "Intente m s tarde")
endif

select 16
if snet_use( "UARA" , "UARANC" , .F. , 5 , .T. , "No se puede abrir archivo de Unidades Arancelarias - ¨Reintenta?" )
	set order to tag CODIGO
else
	msg("No se puede abrir archivo de Convenios",;
	    "Un usuario bloquea el archivo",;
		 "Intente m s tarde")
endif


select 6
set relation to UARA into UARANC

select 8
if snet_use("MOTIVOS","MOT",.F.,5,.T.,"No se puede abrir archivo Motivos - ¨Reintenta?")
	set order to tag MOTIVOS
else
	msg("No se puede abrir archivo de Motivos",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif


select 2
if snet_use("PRACTICA","PRACTICA",.F.,5,.T.,"No se puede abrir archivo de CONSULTA - ¨Reintenta?")
	set order to tag PRACTICA
else
	msg("No se puede abrir archivo de consultas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 0
if snet_use("PRACRENG","PRACRENG",.F.,5,.T.,"No se puede abrir archivo de CONSULTA - ¨Reintenta?")
	set order to tag PRACRENG
else
	msg("No se puede abrir archivo de consultas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif


select 0
if snet_use("BASEAFIL","AFILIADO",.F.,5,.T.,"No se puede abrir archivo de afiliados - ¨Reintenta?")
	set order to tag AFINUM
else
	msg("No se puede abrir archivo de AFILIADOS",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

cConvenio := buscConv()
		
if snet_use( cConvenio , "NOMENCLA" , .f. , 5 , .t. , "No se puede abrir archivo Nomenclador - ¨Reintenta?" )				
	set order to tag NOMECODI
else
	msg("No se puede abrir archivo nomenclador",;
  	 "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif	
		
Select 0
if snet_use( (UARANC->ARCHIVO) , "UARA" , .F. , 5 , .T. , "No se puede abrir archivo de Unidades arancelarias ¨Reintenta?")
	set order to tag FECH
else
	msg("No se puede abrir archivo de unidades arancelarias",;
  	 "debe intentar m s tarde: otro usuario est  usando el archivo")

endif

select PRACRENG
set relation to NOMENCLADO into NOMENCLA
select PRACTICA
set relation to AFILIADO into AFILIADO
cnumero := space(len( PRACRENG->numero ) )
popread( .t. , "Ingrese el N§ del reintegro" , @cnumero , "@9" )
set filter to serie == "RE" .and. numero == cnumero
go top
if eof()
	msg("No existe ese reintegro")
else
	select PRACRENG
	set filter to serie = "RE" .and. numero = cnumero
	go top
	mreceta := numero
	mFechaPres := dtoc( PRACTICA->FECHA )
	mtotal := PRACTICA->	TOTAPAG
	mafiliado := PRACTICA->AFILIADO
	mmotivo := PRACTICA->MOTIVO
	do impreinprac
endif

close all

return NIL
