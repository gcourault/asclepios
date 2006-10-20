* -------------------------------------------------------------------
* Inf01.prg
* Informe 01: Genera Base de datos para ver los consumos en salud
* de las distintas poblaciones
* -------------------------------------------------------------------
#include "asclepios.ch"
#include "inkey.ch"
function inf01()

select 0
if snet_use( "medi" , "med" , .f. , 5 , .t. , "No se puede abrir el archivo de Poblaciones - ¨Reintenta?" )
	set order to tag METROQ
else
	msg( "No se puede abrir Medicamentos - Reintente luego" )
	close all
	return NIL
endif

select 0
if snet_use( "r_nome" , "nom" , .f. , 5 , .t. , "No se puede abrir el archivo de Poblaciones - ¨Reintenta?" )
	set order to tag NOMECODI
else
	msg( "No se puede abrir Poblaciones - Reintente luego" )
	close all
	return NIL
endif

select 0
if snet_use( "poblacio" , "pobl" , .f. , 5 , .t. , "No se puede abrir el archivo de Poblaciones - ¨Reintenta?" )
	set order to tag CODIGO
else
	msg( "No se puede abrir Poblaciones - Reintente luego" )
	close all
	return NIL
endif

select 0
if snet_use( "baseafil" , "afil" , .f. , 5 , .t. , "No se puede abrir el archivo de afiliados - ¨Reintenta?" )
	set order to tag AFINUM
else
	msg( "No se puede abrir AFILIADOS - Reintente luego" )
	close all
	return NIL
endif
set relation to afil->bapobl into pobl
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
if snet_use( "renrec" , "RREC" , .f. , 5 , .t. , "No se puede abrir Renglones Farmacia - ¨Reintenta?" ) 
	set order to tag RENREC
else
	msg( "No se puede abrir RENREC - Reintente luego" )
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
select 0
if snet_use( "pracreng" , "PRENG" , .f. , 5 , .t. , "No se puede abrir Renglones Pr cticas - ¨Reintenta?" ) 
	set order to tag rengpfsn
else
	msg( "No se puede abrir RENGLONES PRACTICA - Reintente luego" )
	close all
	return NIL
endif

* ----------------------------------------------------------------------------
cDesde := dtoc( date() - 30  )
cHasta := dtoc( date() )
cPoblacion := space( len( AFIL->BAPOBL ) )
cTitulares := "S"
cTmp := makebox( 1 , 1 , 20 , 78 )
cColor := setcolor()
set color to I
@ 2,2 say padc( "Listado de las prestaciones a Afiliados - Titulares o Grupos Familiares" , 76 )
@ 3,2 say padc( "Pr cticas y Recetas" , 76 )
setcolor( cColor )
while .t.
	@ 5,10 say  "Desde <Enter> = Comienzo     :" get cDesde pict "@D"
	@ 6,10 say  "Hasta <Enter> = Final        :" get cHasta pict "@D"
	@ 8,10 say  "Poblaci¢n <F2> = Busca       :" get cPoblacion pict "99"
	@ 10,10 say "Titulares (S/N)              :" get cTitulares valid cTitulares $ "SN"
	smallkset( K_F2 , "INF01" , "CPOBLACION" ,  { || codigo + ' ' + descripcio } , "Poblaciones" , "%poblacio%codigo" , "CODIGO" )
	read
	if lastkey() == K_ESC
		unbox( cTmp )
		return
	endif
	if messyn("¨Correcto?")
		exit
	endif
end
select FACT

cFiltro := space(0)
if !empty( cDesde )
	cFiltro := cFiltro + "FPRES >= ctod( cDesde ) .and. "
endif
if !empty( cHasta )
	cFiltro := cFiltro + "FPRES <= ctod( cHasta ) .and. "
endif
cFiltro := left( cFiltro , len( cFiltro ) - 7 )
set filter to &cFiltro
go top

cCondicion = space(0)
if !empty( cPoblacion )
	cCondicion = cCondicion + "AFIL->BAPOBL = cPoblacion .and. "
endif
if cTitulares = "S"
	cCondicion := cCondicion + "AFIL->BAORDE = '01' .and. "
else
	cCondicion := cCondicion + "AFIL->BAORDE != '01' .and. "
endif
cCondicion = left( cCondicion , len( cCondicion ) - 7 )
go top
set relation to FACT->PRESTADOR into PRES
select CREC
set relation to CREC->AFILIADO into AFIL
select PRAC 
set relation to PRAC->AFILIADO into AFIL

if messyn("¨Borra Base de Datos INF01?")
	if file( "inf01.DBF" )
		delete file inf01.DBF
	endif
	aBase := {}
	aadd( aBase , { "FECHA", "D" , 8 , 0 } )
	aadd( aBase , { "PRESTADOR" , "C" , 7 , 0 } )
	aadd( aBase , { "RAZONSOC" , "C" , 20 , 0  } )
	aadd( aBase , { "FACTURA" , "C" , 8 , 0 } )
	aadd( aBase , { "CONCEPTO" , "C" , 2 , 0 } )
	aadd( aBase , { "AFILIADO" , "C" , 9 , 0 } )
	aadd( aBase , { "POBLACION" , "C" , 2 , 0 } )
	aadd( aBase , { "DESCRIPCIO" , "C" , 40 , 0 } )
	aadd( aBase , { "MAR_PRE" , "C" , 1 , 0  } )
	aadd( aBase , { "TIPO" , "C" , 1 , 0  } )
	aadd( aBase , { "NOMBRE" , "C" , 20 , 0 } )
	aadd( aBase , { "SERIE" , "C" , 2 , 0 } )
	aadd( aBase , { "NUMERO" , "C" , 6 , 0  } )
        aadd( aBase , { "DESCRIPCIO" , "C" , 80 , 0 } )
	aadd( aBase , { "TOTAL" , "N" , 12 , 2 } )
	aadd( aBase , { "CUENTA" , "N" , 8 , 0 } )
	dbcreate( "INF01" , aBase )
else
	select 0
	if snet_use( "INF01" , "INF" , .T. , 5 , .T. , "No se puede abrir AFILACT - ¨Reintenta?" )
		index on PRESTADOR + FACTURA tag PRESFACT
	else
		msg( "No se pudo abrir INF01 - Reintente luego" )
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
				
				if &cCondicion
					if INF->( sadd_rec( 5 , .f. ) )
						if INF->( srec_lock( 5 , .f. ) )			
							replace INF->FACTURA   with FACT->FACTURA
							replace INF->PRESTADOR with FACT->PRESTADOR
							replace INF->FECHA with FACT->FPRES
							replace INF->RAZONSOC with PRES->PRNOMB
							replace INF->AFILIADO with PRAC->AFILIADO
							replace INF->CONCEPTO with FACT->CONCEPTO
							replace INF->POBLACION with AFIL->BAPOBL
							replace INF->DESCRIPCIO with POBL->DESCRIPCIO
							replace INF->MAR_PRE with POBL->MAR_PRE
							replace INF->TIPO with POBL->TIPO
							replace INF->NOMBRE with AFIL->BAAPEL
							replace INF->SERIE with PRAC->SERIE
							replace INF->NUMERO with PRAC->NUMERO
							replace INF->TOTAL with PRAC->TOTAPAG
							replace INF->CUENTA with 1
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
				if &cCondicion
					if INF->( sadd_rec( 5 , .f. ) )
						if INF->( srec_lock( 5 , .f. ) )			
							replace INF->FACTURA   with FACT->FACTURA
							replace INF->PRESTADOR with FACT->PRESTADOR
							replace INF->FECHA with FACT->FPRES
							replace INF->RAZONSOC with PRES->PRNOMB
							replace INF->AFILIADO with CREC->AFILIADO
							replace INF->CONCEPTO with FACT->CONCEPTO
							replace INF->POBLACION with AFIL->BAPOBL
							replace INF->DESCRIPCIO with POBL->DESCRIPCIO
							replace INF->MAR_PRE with POBL->MAR_PRE
							replace INF->TIPO with POBL->TIPO
							replace INF->NOMBRE with AFIL->BAAPEL
							replace INF->SERIE with CREC->SERIE
							replace INF->NUMERO with CREC->RECETA
							replace INF->TOTAL with CREC->APAGAR
							replace INF->CUENTA with 1
						endif
					endif
				endif
				CREC->( dbskip() )
			enddo
		endif
		skip
	enddo
	plswait( .f. )
	select INF
	editdb( .t. )
	if messyn("¨Genera el Informe")
		do impinf01
	endif
endif
unbox( cTmp )
return

proc impinf01
* ------------------------------------------
* procedimiento para imprimir el informe
* que me pidio Eli
* ------------------------------------------
plswait( .t. , "Haciendo los c lculos" )
select INF

* Armada en Actividad Titulares
sum total to nArAct for MAR_PRE = "M" .and. TIPO = "A" .and. right( afiliado , 2 ) = "01"
count to nNroArAct for MAR_PRE = "M" .and. TIPO = "A" .and. right( afiliado , 2 ) = "01" .and. total > 0

* Armada retirados titulares
sum total to nArRet for MAR_PRE = "M" .and. TIPO = "R" .and. right( afiliado , 2 ) = "01"
count to nNroArRet for MAR_PRE = "M" .and. TIPO = "R" .and. right( afiliado , 2 ) = "01" .and. total > 0

* Armada pensionados titulares
sum total to nArPen for MAR_PRE = "M" .and. TIPO = "P" .and. right( afiliado , 2 ) = "01"
count to nNroArPen for MAR_PRE = "M" .and. TIPO = "P" .and. right( afiliado , 2 ) = "01" .and. total > 0

* Prefectura en Actividad Titulares
sum total to nPrAct for MAR_PRE = "P" .and. TIPO = "A" .and. right( afiliado , 2 ) = "01"
count to nNroPenAct for MAR_PRE = "P" .and. TIPO = "A" .and. right( afiliado , 2 ) = "01" .and. total > 0

* Prefectura retirados titulares
sum total to nPrRet for MAR_PRE = "P" .and. TIPO = "R" .and. right( afiliado , 2 ) = "01"
count to nNroArRet for MAR_PRE = "P" .and. TIPO = "R" .and. right( afiliado , 2 ) = "01" .and. total > 0

* Prefectura pensionados titulares
sum total to nPrPen for MAR_PRE = "P" .and. TIPO = "P" .and. right( afiliado , 2 ) = "01"
count to nNroArPen for MAR_PRE = "P" .and. TIPO = "P" .and. right( afiliado , 2 ) = "01" .and. total > 0

* Grupos Familiares Armada
sum total to nGFAr for MAR_PRE = "A" .and. right( afiliado , 2 ) != "01"
count to nNroGFAr for MAR_PRE = "A" .and. right( afiliado , 2 ) != "01" .and. total > 0

* Grupos Familiares Prefectura
sum total to nGFPr for MAR_PRE = "P" .and. right( afiliado , 2 ) != "01"
count to nNroGFPr for MAR_PRE = "P" .and. right( afiliado , 2 ) != "01" .and. total > 0

plswait( .f. )
set printer on
set console off
? "-----------------------------------------------------------------------------"
? "                               Gastos Sanitarios"
? "-----------------------------------------------------------------------------"
? " Delegaci¢n DIBA: " + NOMBRE_REGIONAL
? "-----------------------------------------------------------------------------"
? "Mes/A¤o " + str( month( ctod( cDesde ) ) , 2 , 0 ) + "/" + str( year( ctod( cDesde ) ) , 4 , 0 ) 
? "-----------------------------------------------------------------------------"
? "                                 ARMADA ARGENTINA"
? "-----------------------------------------------------------------------------"
? "Titulares          Total         ($)"
?
? "1. En Actividad" , nArAct, nNroArAct
? "2. Retirados   " , nArRet, nNroArRet
? "3. Pensionados " , nArPen, nNroArPen
? "-----------------------------------------------------------------------------"
? "Grupos Familiares"
? 
? "En Actividad,  "
? "retirados y    "
? "pensionistas   ",nGFAr , nNroGFAr
?
?
? "-----------------------------------------------------------------------------"
? "                              PREFECTURA NAVAL ARGENTINA"
? "-----------------------------------------------------------------------------"
? "Titulares          Total         ($)"
?
? "1. En Actividad" , nPrAct, nNroPrAct
? "2. Retirados   " , nPrRet, nNroPrRet
? "3. Pensionados " , nPrPen, nNroPrPen
? "-----------------------------------------------------------------------------"
? "Grupos Familiares"
? 
? "En Actividad,  "
? "retirados y    "
? "pensionistas   ",nGFPr , nNroGFPr
?
? "-----------------------------------------------------------------------------"

set printer off
set console on
return

