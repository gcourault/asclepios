* -------------------------------------------
* ListAct.prg
* Permite listar los afiliados por actividad
* -------------------------------------------
#include "asclepios.ch"
#include "inkey.ch"

function listAct()
set date french
set dele on
set wrap on
set score off
set excl off
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
	set order to tag PRESTADOR
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

cDesde := dtoc( date() - 30  )
cHasta := dtoc( date() )
cPrestador := space( len( FACT->Prestador ) )
cFactura   := space( len( FACT->Factura ) )

cTmp := makebox( 1 , 1 , 10 , 78 )
cColor := setcolor()
set color to I
@ 2,2 say padc( "Listado de las prestaciones a Afiliados en Actividad" , 76 )
setcolor( cColor )
@ 4,2 say padc( "Imprimir Pr cticas y Recetas  - <F2> Buscar" , 76 )
@ 5,10 say "Desde <Enter> = Comienzo     :" get cDesde pict "@D"
@ 6,10 say "Hasta <Enter> = Final        :" get cHasta pict "@D"
@ 7,10 say "Prestador  <Enter> = Todos   :" get cPrestador pict "@!"
@ 8,10 say "De Factura <Enter> = Todas   :" get cFactura pict "@9"

smallkset( K_F2 , "LISTACT" , "CPRESTADOR"  , { || PRLETR + PRCODI + " " + PRNOMB } , "Prestador" , "%IN1PRES%PRNOMB" , 'PRLETR + PRCODI' )
read
smallkclr()
select FACT

cFiltro := space(0)
if !empty( cDesde )
	cFiltro := cFiltro + "FPRES >= ctod( cDesde ) .and. "
endif
if !empty( cHasta )
	cFiltro := cFiltro + "FPRES <= ctod( cHasta ) .and. "
endif
if !empty( cPrestador )
	cFiltro := cFiltro + "cPrestador == PRESTADOR .and. " 
endif
if !empty( cFactura )
	cFiltro := cFiltro + "cFactura == FACTURA .and. "
endif
cFiltro := left( cFiltro , len( cFiltro ) - 7 )
set filter to &cFiltro
go top
set relation to FACT->PRESTADOR into PRES
select CREC
set relation to CREC->AFILIADO into AFIL
select PRAC 
set relation to PRAC->AFILIADO into AFIL

if messyn("¨Genera Base de Datos?")
	if file( "AFILACT.DBF" )
		delete file AFILACT.DBF
	endif
	aBase := {}
	aadd( aBase , { "FECHA", "D" , 8 , 0 } )
	aadd( aBase , { "PRESTADOR" , "C" , 7 , 0 } )
	aadd( aBase , { "RAZONSOC" , "C" , 20 , 0  } )
	aadd( aBase , { "FACTURA" , "C" , 8 , 0 } )
	aadd( aBase , { "CONCEPTO" , "C" , 2 , 0 } )
	aadd( aBase , { "AFILIADO" , "C" , 9 , 0 } )
	aadd( aBase , { "POBLACION" , "C" , 2 , 0 } )
	aadd( aBase , { "NOMBRE" , "C" , 20 , 0 } )
	aadd( aBase , { "SERIE" , "C" , 2 , 0 } )
	aadd( aBase , { "NUMERO" , "C" , 6 , 0  } )
	aadd( aBase , { "TOTAL" , "N" , 12 , 2 } )
	aadd( aBase , { "CUENTA" , "N" , 8 , 0 } )
	dbcreate( "AFILACT" , aBase )
	select 0
	if snet_use( "AFILACT" , "ACT" , .T. , 5 , .T. , "No se puede abrir AFILACT - ¨Reintenta?" )
		index on PRESTADOR + FACTURA tag PRESFACT
	else
		msg( "No se pudo abrir AFILACT - Reintente luego" )
		return NIL
	endif
	plswait( .t. , "Generando Base de datos" )
	select FACT
	go top
	while !eof()
		if PRAC->( dbseek( FACT->PRESTADOR + FACT->FACTURA ) )
			cPrestador := PRESTADOR
			cFactura   := FACTURA
			while PRAC->PRESTADOR + PRAC->FACTURA == cPrestador + cFactura
				if  AFIL->BAPOBL = "11" .and. AFIL->BAORDE = "01"
					if ACT->( sadd_rec( 5 , .f. ) )
						if ACT->( srec_lock( 5 , .f. ) )			
							replace ACT->FACTURA   with FACT->FACTURA
							replace ACT->PRESTADOR with FACT->PRESTADOR
							replace ACT->FECHA with FACT->FPRES
							replace ACT->RAZONSOC with PRES->PRNOMB
							replace ACT->AFILIADO with PRAC->AFILIADO
							replace ACT->CONCEPTO with FACT->CONCEPTO
							replace ACT->POBLACION with AFIL->BAPOBL
							replace ACT->NOMBRE with AFIL->BAAPEL
							replace ACT->SERIE with PRAC->SERIE
							replace ACT->NUMERO with PRAC->NUMERO
							replace ACT->TOTAL with PRAC->TOTAPAG
							replace ACT->CUENTA with 1
						endif
					endif
				endif
				PRAC->( dbskip() )
			enddo
		endif
		if CREC->( dbseek( FACT->PRESTADOR + FACT->FACTURA ) )
			cPrestador := PRESTADOR
			cFactura   := FACTURA
			while CREC->PRESTADOR + CREC->FACTURA == cPrestador + cFactura
				if  AFIL->BAPOBL = "11"  .and. AFIL->BAORDE = "01"
					if ACT->( sadd_rec( 5 , .f. ) )
						if ACT->( srec_lock( 5 , .f. ) )			
							replace ACT->FACTURA   with FACT->FACTURA
							replace ACT->PRESTADOR with FACT->PRESTADOR
							replace ACT->FECHA with FACT->FPRES
							replace ACT->RAZONSOC with PRES->PRNOMB
							replace ACT->AFILIADO with CREC->AFILIADO
							replace ACT->CONCEPTO with FACT->CONCEPTO
							replace ACT->POBLACION with AFIL->BAPOBL
							replace ACT->NOMBRE with AFIL->BAAPEL
							replace ACT->SERIE with CREC->SERIE
							replace ACT->NUMERO with CREC->RECETA
							replace ACT->TOTAL with CREC->APAGAR
							replace ACT->CUENTA with 1
						endif
					endif
				endif
				CREC->( dbskip() )
			enddo
		endif
		skip
	enddo
	plswait( .f. )
	select ACT
	editdb( .t. )
	reporter()
	unbox( cTmp )
	return
endif

lPantalla := messyn( "Seleccione Salida" , "Pantalla" , "Impresora" )
if lPantalla
	set printer to LISTACT
endif

select FACT
* ---------------------
* Pr cticas Marina
* ---------------------
n85 := 0
n15 := 0
plswait( .t. , "Imprimiendo Pr cticas Poblaci¢n 11" )
set console off
set printer on
nLineas := 6
lCabecera := .t.
*-----------
while !eof()   // Lazo en Facturas
	select PRAC
	seek FACT->PRESTADOR + FACT->FACTURA
	if found()
		cPrestador := PRESTADOR
		cFactura   := FACTURA
		while PRESTADOR + FACTURA = cPrestador + cFactura
			if  AFIL->BAPOBL == "11" .and. AFIL->BAORDE == "01" .and. !afil->( eof() )
				*-------------------------------------------------------------
				* Imprime la cabecera si encuentra registros y la primera vez
				*--------------------------------------------------------------
				if lCabecera
					cabprac( "11" )
					nLineas := 6
					lCabecera := .f.
				endif
				linprac()
				n85 := n85 + TOTAPAG * 85/100
				n15 := n15 + TOTAPAG * 15/100
				if nLineas++ >= 60
					?? chr(12)
					cabprac( "11" )
					nLineas := 6
				endif
			endif
			skip
		enddo
	endif
	select FACT
	skip
end
* -----------------------------------------------------------------------
* Si pas¢ por la cabecera, encontr¢ registros, luego debe imprimir el pie
* -----------------------------------------------------------------------
if !lCabecera
	pieprac()
	? chr(12)
endif
* -------------------------------------------------------------------------

* -------------------------------------------------------------------------
* Recetas
* -------------------------------------------------------------------------

select FACT
go top
n60 := 0
n40 := 0
lCabecera := .t.
*-----------
while !eof()   // Lazo en Facturas
	select CREC
	seek FACT->PRESTADOR + FACT->FACTURA
	if found()
		
		cPrestador := PRESTADOR
		cFactura   := FACTURA
		while PRESTADOR + FACTURA = cPrestador + cFactura
			if  AFIL->BAPOBL == "11" .and. AFIL->BAORDE == "01" .and. !afil->( eof() )
				if lCabecera
					cabrec( "11" )
					nLineas := 6
					lCabecera := .f.
				endif
				linrec()
				n60 := n60 + APAGAR * 60/100
				n40 := n40 + APAGAR * 40/100
				if nLineas++ >= 60
					?? chr(12)
					cabrec( "11")
					nLineas := 6
				endif
			endif
			skip
		enddo
	endif
	select FACT
	skip
end
if !lCabecera
	pierec()
	? chr(12)
endif


set printer off
set console on

plswait( .f. )
unbox( cTmp )
if lPantalla
	set printer to
	fileread( 0,0,24,79,"LISTACT.PRN","Listado de Prestaciones a Personal en Actividad" )
endif
close all
return NIL

static function cabprac( cTexto )
?? chr(15)
? "-------------------------------------------------------------------------------------------------------------------"
? "DIBA " + NOMBRE_REGIONAL + "        Listado de Pr cticas de Afiliados Poblaci¢n " + cTexto
? "Desde: " + cDesde + " Hasta: " + cHasta + " * Prestador:" + cPrestador + " Factura: " + cFactura
? "-------------------------------------------------------------------------------------------------------------------"
? "N§ Afiliado  Apellido y Nombre Factura  Fecha    Prestador Raz¢n Social        Serie y N§   Total" //      85%      15%"
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
* ?? transf( PRAC->TOTAPAG * 85 / 100 , "99999.99" ) + "  "
* ?? transf( PRAC->TOTAPAG * 15 / 100 , "99999.99" ) 

static function pieprac()
? "Total : " + transf( n85 + n15, "999999.99" )
* ? "Total 15% : " + transf( n15 , "999999.99" )
? "-------------------------------------------------------------------------------------------------------------------"

return NIL

static function cabrec( cTexto )
?? chr(15)
? "-------------------------------------------------------------------------------------------------------------------"
? "DIBA " + NOMBRE_REGIONAL + "        Listado de Recetas de Afiliados Poblaci¢n " + cTexto
? "Desde: " + cDesde + " Hasta: " + cHasta + " * Prestador:" + cPrestador + " Factura: " + cFactura
? "-------------------------------------------------------------------------------------------------------------------"
? "N§ Afiliado  Apellido y Nombre Factura  Fecha    Prestador Raz¢n Social        Serie y N§   Total" //      60%      40%"
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
* ?? transf( CREC->APAGAR * 60 / 100 , "99999.99" ) + "  "
* ?? transf( CREC->APAGAR * 40 / 100 , "99999.99" ) 

static function pierec()
? "Total : " + transf( n60 + n40 , "999999.99" )
* ? "Total 40% : " + transf( n40 , "999999.99" )
? "-------------------------------------------------------------------------------------------------------------------"

return NIL
