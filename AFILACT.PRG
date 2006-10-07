#include "asclepios.ch"
#include "inkey.ch"

* ------------------------------------------
*  AfilAct.prg
*  lista los afiliados activos de Santa Fe  
* ------------------------------------------
function afilact()
set excl off
set dele on
set wrap on
set date french
set defa to ./datos 
set path to .

select 0
if snet_use("BASEAFIL","AFILIADO",.f.,5,.f.)
	set order to tag AFINUM
else
	msg("Error en la red",;
	    "Regresa al men£ anterior")
   return NIL
endif

select 0
if snet_use( "GEO" , "GEO" , .F. , 5 , .F. )
	set order to tag CODPOSTAL
else
	msg("Error en la red",;
	    "Regresa al men£ anterior")
   return NIL
endif

select AFILIADO
set relation to AFILIADO->BACPOS into GEO
* set filter to ( BAPOBL = "01" .or. BAPOBL = "02" .or. BAPOBL = "51" .or. BAPOBL = "52" ) .and. BAORDE = "01" .and. ( GEO->PROVINCIA = "S" .or. GEO->PROVINCIA = "E" )
set filter to  GEO->PROVINCIA = "S"  
go top
while .t.
	nOpcion := menu_v("[ Opciones ]" ,;
           "1. Listar Afiliados de Regional " + NOMBRE_REGIONAL ,;
			  "2. Sumar Afiliados Regional " + NOMBRE_REGIONAL ,;
			  "3. An lisis de Frecuencia" ,;
			  "4. Estad¡sticas",;
			  "5. Salir" )
	do case
		case nOpcion == 1
		lister()
		case nOpcion == 2
		sum_ave()
		case nOpcion == 3
		freqanal()
		case nOpcion == 4
		supersuper()
		other
		exit
	endcase
end
close all
return NIL
* eof()
