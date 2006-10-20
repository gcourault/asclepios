#include "asclepios.ch"
#include "inkey.ch"
* -------------------------------
* Set_Eli.prg
* Programa de estad¡sticas
* -------------------------------

function set_eli()
select 0
if snet_use("FACTU01","FACT", .F. , 5 , .T. , "No se puede abrir el archivo de Facturas - ¨Reintenta?")
	set order to tag FAPRENUM
else
	msg("No se puede abrir el archivo de facturas",;
	    "Reintente luego")
	return
endif

select 0
if snet_use("PRACTICA" , "PRAC" , .F. , 5 , .T. , "No se puede abrir archivo de Pr cticas - Reintenta")
	set order to tag PRACTICA
else
	msg("No se puede abrir archivo de pr cticas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif
select 0

if snet_use("PRACRENG","PRACRENG",.F.,5,.T.,"No se puede abrir archivo de CONSULTA - ¨Reintenta?")
	set order to tag RENGPF
else
	msg("No se puede abrir archivo de consultas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select prac
set relation to prac->prestador + prac->factura into FACT 
select pracreng
set relation to pracreng->prestador + pracreng->factura into FACT
select 0
if snet_use("CABREC","CABREC",.F.,5,.T.,"No se puede abrir archivo Farmacias - Reintenta?")	
	set order to tag cabrec
else
	msg("Imposible hacer farmacias")
	return
endif
set relation to cabrec->prestador + cabrec->factura into FACT 

select fact
while .t.
	cFax := space( len(fact->fax) )
	cDesde := space( 8 )
	cHasta := space( 8 )
	popread( .t. , "N§ de Fax" , @cFax , "@9" ,;
	               "Desde Fecha" , @cDesde , "@D" ,;
						"Hasta Fecha" , @cHasta , "@D" )
	cFiltro := space(0)
	
	if !empty( cFax )
		cFiltro := cFiltro + "FACT->FAX == cFax .and. "
	endif
	if !empty( cDesde ) 
		cFiltro := cFiltro + "FACT->FPRES >= ctod( cDesde ) .and. "
	endif
	if !empty( cHasta )
		cFiltro := cFiltro + "FACT->FPRES <= ctod( cHasta ) .and. "
	endif
	if lastkey() == K_ESC
		exit
	endif
	if !empty( cFiltro )
		cFiltro := left( cFiltro , len( cFiltro ) - 7 )
                set filter to &cFiltro 
	endif
	go top
	plswait( .t. , "Imprimiendo..." )
	set printer on
	set console off
	? "****************************************************************"
	? "Regional DIBA " + NOMBRE_REGIONAL + " - Desde: " + cDesde + " Hasta: " + cHasta
	? "Fax: " + cFax
	? "****************************************************************"
	* -------------
	* Internaciones
	* -------------
	select PRAC
        set filter to  cFiltro + " .and. TIPOPRACT == 'I'" 
	go top
	count to nInterna
	go top
	sum totfactu,debito,totapag to nTotFactu , nDebito , nTotApag
	? "Tipo            Cant.     Facturado   D‚bitos"   
	? "----------------------------------------------------------------"
	? "Internaciones: "
	?? space( 2 )
	?? str( nInterna , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	? "----------------------------------------------------------------"
	? "Consultas:     "
	select pracreng
        set filter to cFiltro + " .and. ( right(alltrim(NOMENCLADO),6) = '420101' .or. right(alltrim(NOMENCLADO),6)  = '420103' .or. right(alltrim(NOMENCLADO),6) = '420201' .OR. right(alltrim(NOMENCLADO),6) = '420203' )" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	? "----------------------------------------------------------------"
	? "Bioqu¡micas:   "
        set filter to  cFiltro + " .and.  len(alltrim(NOMENCLADO)) = 4" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	? "----------------------------------------------------------------"
	? "Im genes       "
        set filter to cFiltro + " .and. ( (NOMENCLADO >= 'M180101' .and. NOMENCLADO  <= 'M180121') .OR. (NOMENCLADO >= 'M340101' .AND. NOMENCLADO <= 'M34090') .OR. NOMENCLADO = 'M500003' .OR. NOMENCLADO = 'M500005' .OR. NOMENCLADO = 'M5000010' )" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	? "----------------------------------------------------------------"
	? "Tomograf¡as    "
        set filter to cFiltro + " .and.  (NOMENCLADO >= 'M341001' .and. NOMENCLADO  <= 'M341013')" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	? "----------------------------------------------------------------"
	? "Resonancia     "
        set filter to  cFiltro + " .and.  NOMENCLADO = 'M500002'" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	? "----------------------------------------------------------------"
	? "Especializadas:"
        set filter to cFiltro + " .and. ((NOMENCLADO >= 'M260501' .and. NOMENCLADO <= 'M270103') .or. NOMENCLADO = 'M350102' .or. NOMENCLADO = 'M265001' .or. NOMENCLADO = 'M500013' .or. NOMENCLADO = 'M500006' .or. NOMENCLADO = 'M500008' )" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	select prac
/*	? "----------------------------------------------------------------"
	? "Reintegros" 
	? "Programados:   "
        set filter to cFiltro + " .and. ( left(PRESTADOR,1) = 'R' .and. MOTIVO = '001' .or. (MOTIVO >= '005' .and. MOTIVO <= '007' ) )" 
	go top
	count to nInterna
	go top
	sum totfactu,debito,totapag to nTotFactu , nDebito , nTotApag
	?? space(2)
	?? str( nInterna , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
*/	? "----------------------------------------------------------------"
	? "Reintegros"
        set filter to cFiltro + " .and.  left(PRESTADOR,1) = 'R'" 
	go top
	count to nInterna
	go top
	sum totfactu,debito,totapag to nTotFactu , nDebito , nTotApag
	select CABREC
        set filter to  cFiltro + " .and. left(PRESTADOR,1) = 'R'" 
	go top
	count to nInterna1
	go top
	sum totdiba,totdeb to nTotFactu1 , nDebito1 
	
	?? space(2)
	?? str( nInterna + nInterna1 , 10 )
	?? str( nTotFactu + nTotFactu1 , 10 , 2 )
	?? space( 3 )
	?? str( nDebito + nDebito1 , 10 , 2 )
	
	select PRACRENG
/*	? "----------------------------------------------------------------"
	? "Traslados      "
        set filter to  cFiltro + " .and. ( left(PRESTADOR,1) = 'R' .and. MOTIVO = '008' )" 
	go top
	count to nInterna
	go top
	sum totfactu,debito,totapag to nTotFactu , nDebito , nTotApag
	?? space(2)
	?? str( nInterna , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	select pracreng
*/	? "----------------------------------------------------------------"
	? "Odontolog¡a    "
        set filter to cFiltro + " .and. NOMENCLADO = 'O'" 
	go top
	sum CANTIDAD,TOTFACTU,DEBITO to nConsulta, nTotFactu, nDebito
	?? space(2)
	?? str( nConsulta , 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	select CABREC
        set filter to  &cFiltro 
	go top
	count to nRecetas
	go top
	sum TOTDIBA,TOTDEB to nTotFactu,nDebito
	? "----------------------------------------------------------------"
	? "Farmacias"
	? "Particulares:  "
	?? space( 2 )
	?? str( nRecetas, 10 )
	?? str( nTotFactu , 10 , 2 )
	?? space( 3 )
	?? str( nDebito , 10 , 2 )
	use	
	set printer off
	set console on
	plswait( .f. )
enddo
close all
return
