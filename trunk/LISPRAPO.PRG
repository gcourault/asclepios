* ---------------------------------------------------
* LisPraPo.prg
* Permite listar las Pr cticas y medicamentos
* Consumidos por poblaciones
* ---------------------------------------------------
#include "regional.ch"
#include "inkey.ch"
#include "cmx52.ch"
#include "cm52.ch"
set path to \public\regional\tempo
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
cPoblDesd1 = space( len(afil->bapobl) )
cPoblHast1 = space( len(afil->bapobl) )
cPoblDesd2 = space( len(afil->bapobl) )
cPoblHast2 = space( len(afil->bapobl) )
cPoblDesd3 = space( len(afil->bapobl) )
cPoblHast3 = space( len(afil->bapobl) )
cPoblDesd4 = space( len(afil->bapobl) )
cPoblHast4 = space( len(afil->bapobl) )
cTmp := makebox( 1 , 1 , 20 , 78 )
cColor := setcolor()
set color to I
@ 2,2 say padc( "Listado de las prestaciones a Afiliados" , 76 )
setcolor( cColor )
@ 4,2 say padc( "Pr cticas y Recetas" , 76 )
@ 5,10 say "Desde <Enter> = Comienzo     :" get cDesde pict "@D"
@ 6,10 say "Hasta <Enter> = Final        :" get cHasta pict "@D"
@ 8,10 say "Poblaciones:"
@ 10,10 get cPoblDesd1
@ 10,14 say "a"
@ 10,16 get cPoblHast1
@ 11,10 get cPoblDesd2
@ 11,14 say "a"
@ 11,16 get cPoblHast2
@ 12,10 get cPoblDesd3
@ 12,14 say "a"
@ 12,16 get cPoblHast3
@ 13,10 get cPoblDesd4
@ 13,14 say "a"
@ 13,16 get cPoblHast4

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
cFiltro := left( cFiltro , len( cFiltro ) - 7 )
set filter to &cFiltro
cCondicion = space(0)
if !empty( cPoblDesd1 )
	cCondicion = cCondicion + "( AFIL->BAPOBL >= cPoblDesd1 .and. "
endif

if !empty( cPoblHast1)
	cCondicion = cCondicion + "AFIL->BAPOBL <= cPoblHast1 ) .or.   "
endif

if !empty( cPoblDesd2 )
	cCondicion = cCondicion + "( AFIL->BAPOBL >= cPoblDesd2 .and.  "
endif

if !empty( cPoblHast2)
	cCondicion = cCondicion + "AFIL->BAPOBL <= cPoblHast2 ) .or.  "
endif

if !empty( cPoblDesd3 )
	cCondicion = cCondicion + "( AFIL->BAPOBL >= cPoblDesd3  .and. "
endif

if !empty( cPoblHast3)
	cCondicion = cCondicion + "AFIL->BAPOBL <= cPoblHast3) .or.   "
endif

if !empty( cPoblDesd4 )
	cCondicion = cCondicion + "( AFIL->BAPOBL >= cPoblDesd4 .and. "
endif

if !empty( cPoblHast4 )
	cCondicion = cCondicion + "AFIL->BAPOBL <= cPoblHast4 ) .or.  "
endif

cCondicion = left( cCondicion , len( cCondicion ) - 7 )
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
				if &cCondicion
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
				if &cCondicion
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
