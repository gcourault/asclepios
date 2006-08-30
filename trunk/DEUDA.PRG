#include "inkey.ch"

set defa to .\datos
set date french
set excl off

* --------------------------------------------------------
* Deuda.prg
* Programa que lista los proveedores a los que se les debe
* --------------------------------------------------------
select 0
if snet_use("FACTU01","FACT", .F. , 5 , .T. , "No se puede abrir la base de datos de las Facturas" )
	set order to tag FAPRENUM
else
	msg( "Otro usuario bloquea el archivo, reintente luego" )
	return
endif

select 0
if snet_use( "CONCEPTO" ,"CONC", .f. , 5 , .t. , "No se puede abrir la base de datos de los Conceptos" )
	set order to tag CONCOD
else
	msg("Otro usuario bloquea el archivo, reintente luego")
	return
endif
select 0
if snet_use( "IN1PRES","PREST",.F.,5,.T.,"No se puede abrir la base de datos de los prestadores" )
	set order to tag PRCOD
else
	msg("Otro usuario bloquea el archivo, reintente luego")
	return
endif

select FACT
set relation to PRESTADOR into PREST, to CONCEPTO into CONC
cDesde := space(10)
cHasta := space(10)
popread( .t. , "Listar Deuda desde:",@cDesde,"@D",;
               "             hasta:",@cHasta,"@D")
plswait(.t. , "Ordenando..." )
index on dtos( FPRES ) + CONCEPTO + PRESTADOR to temfact for FPRES >= ctod( cDesde ) .and. FPRES <= ctod( cHasta ) .and. empty( CHEQUEREG )
plswait( .f. )
set printer on
set console off
nTotal := 0.00
while !eof()
	nMes := month( FPRES )
	?
	? "Mes: " + str( nMes , 3 , 0 )
	nTotMes := 0.00
	while nMes == month( FPRES )
		cConcepto := CONCEPTO
		?
		? "    Concepto: " + CONC->DESCRI
		nTotConcepto := 0.00
		while cConcepto == CONCEPTO
			cPrestador := PRESTADOR
			?
			? "            Prestador: " + PREST->PRNOMB
			nTotFactu := 0.0
			while cPrestador == PRESTADOR
				
				nTotFactu := nTotFactu + TOTFACTU
				nTotConcepto := nTotConcepto + TOTFACTU
				nTotMes := nTotMes + TOTFACTU
				nTotal := nTotal + TOTFACTU
				skip
			end
			? "            Total Prestador: " + str( nTotFactu , 10 , 2 )
		end
		? "    Total Concepto: " + str( nTotConcepto , 10 , 2 )
	end
	? "Total Mes: " + str( nTotMes , 10 , 2 )
end
? "**Total** : " + str( nTotal ,10 , 2 )
set printer off
set console on
return
