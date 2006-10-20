* -------------------------------------------
* ListRein.prg
* Permite listar los afiliados por actividad
* -------------------------------------------
#include "asclepios.ch"
#include "inkey.ch"

function listrein()
set date french
set dele on
set wrap on
set score off
set excl off
* ----------------------------------------------------------------------------
select 0
if snet_use( "MOTIVOS" , "MOT" , .f. , 5 , .t. , "No se puede abrir el archivo de motivos - ¨Reintenta?" )
	set order to tag MOTIVOS
else
	msg( "No se puede abrir MOTIVOS - Reintente luego" )
	close all
	return NIL
endif
* ----------------------------------------------------------------------------
select 0
if snet_use( "baseafil" , "afil" , .f. , 5 , .t. , "No se puede abrir el archivo de afiliados - ¨Reintenta?" )
	set order to tag AFINUM
else
	msg( "No se puede abrir AFILIADOS - Reintente luego" )
	close all
	return NIL
endif
* ----------------------------------------------------------------------------
select 0
if snet_use( "in1pres" , "PRES" , .f. , 5 , .t. , "No se puede abrir Prestador - ¨Reintenta?" ) 
	set order to tag PRCOD
else
	msg( "No se puede abrir PRESTADORES - Reintente luego" )
	close all
	return NIL
endif
* ----------------------------------------------------------------------------
select 0
if snet_use( "factu01" , "FACT" , .f. , 5 , .t. , "No se puede abrir Comprobantes - ¨Reintenta?" ) 
	set order to tag FACTURA
else
	msg( "No se puede abrir FACTU01 - Reintente luego" )
	close all
	return NIL
endif
* ----------------------------------------------------------------------------
select 0
if snet_use( "cabrec" , "CREC" , .f. , 5 , .t. , "No se puede abrir Farmacia - ¨Reintenta?" ) 
	set order to tag CABREC
else
	msg( "No se puede abrir CABREC - Reintente luego" )
	close all
	return NIL
endif
set relation to MOTIVO into MOT
* ----------------------------------------------------------------------------
select 0
if snet_use( "practica" , "PRAC" , .f. , 5 , .t. , "No se puede abrir Pr cticas - ¨Reintenta?" ) 
	set order to tag PRACTICA
else
	msg( "No se puede abrir PRACTICA - Reintente luego" )
	close all
	return NIL
endif
* ----------------------------------------------------------------------------
set relation to MOTIVO into MOT
cDesde := dtoc( date() - 30  )
cHasta := dtoc( date() )

cTmp := makebox( 1 , 1 , 10 , 78 )
@ 2,2 say padc( "Listado de las prestaciones a Afiliados en Actividad" , 75 )
@ 5,10 say "Imprimir Pr cticas y Recetas desde:" get cDesde pict "@D"
@ 6,10 say "                             hasta:" get cHasta pict "@D"
read
select FACT
set filter to FPRES >= ctod( cDesde ) .and. FPRES <= ctod( cHasta ) .and. left( PRESTADOR , 1 ) == "R"
go top
set relation to FACT->PRESTADOR into PRES
select CREC
set relation to CREC->AFILIADO into AFIL
select PRAC 
set relation to PRAC->AFILIADO into AFIL

select FACT
* ---------------------
* Pr cticas 
* ---------------------
nTotal := 0
plswait( .t. , "Imprimiendo Reintegros" )
set console off
set printer on
cabprac( "Reintegros" )
nLineas := 6

*-----------
while !eof()   // Lazo en Facturas
	select PRAC
	seek FACT->PRESTADOR + FACT->FACTURA
	if found()
		cPrestador := PRESTADOR
		cFactura   := FACTURA
		while PRESTADOR + FACTURA = cPrestador + cFactura
			linprac()
			nTotal := nTotal + TOTAPAG 
			if nLineas++ >= 60
				?? chr(12)
				cabprac( "Reintegros" )
				nLineas := 6
			endif
			skip
		enddo
	endif
	select FACT
	skip
end
pieprac()
? chr(12)

* -------------------------------------------------------------------------
* Recetas
* -------------------------------------------------------------------------
select FACT
go top
n := 0
n15 := 0
cabrec( "Reintegros" )
nLineas := 6
*-----------
while !eof()   // Lazo en Facturas
	select CREC
	seek FACT->PRESTADOR + FACT->FACTURA
	if found()
		cPrestador := PRESTADOR
		cFactura   := FACTURA
		while PRESTADOR + FACTURA = cPrestador + cFactura
			linrec()
			nTotal := nTotal + APAGAR
			if nLineas++ >= 60
				?? chr(12)
				cabrec( "Reintegros")
				nLineas := 6
			endif
			skip
		enddo
	endif
	select FACT
	skip
end
pierec()
? chr(12)

set printer off
set console on


plswait( .f. )
unbox( cTmp )
return NIL

static function cabprac( cTexto )
?? chr(15)
? "-------------------------------------------------------------------------------------------------------------------"
? "DIBA " + NOMBRE_REGIONAL + " Reintegros" + cTexto
? "Desde: " + cDesde + " Hasta: " + cHasta
? "-------------------------------------------------------------------------------------------------------------------"
? "N§ Afiliado  Apellido y Nombre Factura  Fecha    Prestador Raz¢n Social        Serie y N§   Reconocido Facturado   "
? "-------------------------------------------------------------------------------------------------------------------"
return NIL

static function linprac()
?  AFIL->BANUME+AFIL->BAORDE + " "
?? left( AFIL->BAAPEL , 20 ) + " "
?? FACT->FACTURA + " "
?? dtoc( FACT->FPRES ) + " "
?? FACT->PRESTADOR + " "
?? left( PRES->PRNOMB ,20 ) + " "
?? PRAC->SERIE + " " + PRAC->NUMERO + "  "
?? transf( PRAC->TOTAPAG , "99999.99" ) + " "
?? transf( PRAC->TOTFACTU , "99999.99" ) + "  "
?? MOT->DESCRIPCI1

static function pieprac()
? "Total: " + transf( nTotal , "999999.99" )
? "-------------------------------------------------------------------------------------------------------------------"

return NIL

static function cabrec( cTexto )
?? chr(15)
? "-------------------------------------------------------------------------------------------------------------------"
? "DIBA " + NOMBRE_REGIONAL + "        Listado de Recetas " + cTexto
? "Desde: " + cDesde + " Hasta: " + cHasta
? "-------------------------------------------------------------------------------------------------------------------"
? "N§ Afiliado  Apellido y Nombre Factura  Fecha    Prestador Raz¢n Social        Serie y N§   Reconocido Facturado   "
? "-------------------------------------------------------------------------------------------------------------------"
return NIL

static function linrec()
?  AFIL->BANUME+AFIL->BAORDE + " "
?? left( AFIL->BAAPEL , 20 ) + " "
?? FACT->FACTURA + " "
?? dtoc( FACT->FPRES ) + " "
?? FACT->PRESTADOR + " "
?? left( PRES->PRNOMB ,20 ) + " "
?? CREC->SERIE + " " + CREC->RECETA + "  "
?? transf( CREC->APAGAR , "99999.99" ) + " "
?? transf( CREC->TOTDIBA, "99999.99" ) + "  "
?? MOT->DESCRIPCI1

static function pierec()
? "Total : " + transf( nTotal , "999999.99" )
? "-------------------------------------------------------------------------------------------------------------------"

return NIL
