/* -----------------
 Frecmedi.prg
--------------------*/
#include "cmx52.ch"
#include "cm52.ch"

close all
set defa to \public\regional\tempo
set path to .
select 0
use factu01 excl
set order to tag FAPRENUM
aEstruc1 := dbstruct()
for k = 1 to fcount()
	aEstruc1[k,1] := alias() +"->"+ aEstruc1[k,1]
next k

select 0
use cabrec excl
set order to tag cabrec
aEstruc4 := dbStruct()
for k = 1 to fcount()
	aEstruc4[k,1] := alias() +"->"+ aEstruc4[k,1]
next k

select 0
use mandan excl
set order to tag presman
aEstruc2 := dbStruct()
for k = 1 to fcount()
	aEstruc2[k,1] := alias() +"->"+ aEstruc2[k,1]
next k


select 0
use renrec excl
set order to tag renrec
aEstruc3 := dbStruct()
for k = 1 to fcount()
	aEstruc3[k,1] := alias() +"->"+ aEstruc3[k,1]
next k


select CABREC
set relation to prestador+factura into factu01 ,to PRESTADOR+MANDATARIA into mandan

select RENREC
set relation to prestador+factura+serie+receta into CABREC, to prestador+factura into FACTU01 

aEstruc := aEstruc1
for k = 1 to len( aEstruc2 )
	aadd( aEstruc , { aEstruc2[k,1] , aEstruc2[k,2] , aEstruc2[k,3] , aEstruc2[k,4] } )
next k
for k = 1 to len( aEstruc4 )
	aadd( aEstruc , { aEstruc4[k,1] , aEstruc4[k,2] , aEstruc4[k,3] , aEstruc4[k,4] } )
next k
for k = 1 to len( aEstruc3 )
	aadd( aEstruc , { aEstruc3[k,1] , aEstruc3[k,2] , aEstruc3[k,3] , aEstruc3[k,4] } )
next k

aCampos := a2tosing( aEstruc , 1 )
aTipos  := a2tosing( aEstruc , 2 )
aLargo  := a2tosing( aEstruc , 3 )
aDec    := a2tosing( aEstruc , 4 )
while .t.
	select factu01
	cConsulta := query( aCampos , aCampos , aTipos )
	select renrec
	cmfilter( cConsulta )
	go top
	plswait( .t. , "Creando Base de datos auxiliar" )
	copy to rengtmp
	plswait( .f. )
	use rengtmp
	freqanal()
	use
	delete file rengtmp
	if !messyn("¨Contin£a con la consulta?")
		exit
	endif
end
close all
return
