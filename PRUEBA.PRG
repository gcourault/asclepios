* -
* Prueba.prg
* A ver si anda el programa freqanal()
* -
#include "cmx52.ch"
#include "cm52.ch"
set defa to \public\regional\tempo

select 0
use factu01 
set order to tag FAPRENUM
aEstruc1 := dbstruct()
for k = 1 to fcount()
	aEstruc1[k,1] := alias() +"->"+ aEstruc1[k,1]
next k

select 0
use practica 
set order to tag PRACTICA
aEstruc2 := dbStruct()
for k = 1 to fcount()
	aEstruc2[k,1] := alias() +"->"+ aEstruc2[k,1]
next k

select 0
use pracreng 
set order to tag RENGPFSN
aEstruc3 := dbStruct()
for k = 1 to fcount()
	aEstruc3[k,1] := alias() +"->"+ aEstruc3[k,1]
next k

select PRACTICA
set relation to practica->prestador+practica->factura into factu01

select PRACRENG
set relation to prestador+factura+serie+numero into PRACTICA, to prestador+factura into FACTU01

aEstruc := aEstruc1
for k = 1 to len( aEstruc2 )
	aadd( aEstruc , { aEstruc2[k,1] , aEstruc2[k,2] , aEstruc2[k,3] , aEstruc2[k,4] } )
next k
for k = 1 to len( aEstruc3 )
	aadd( aEstruc , { aEstruc3[k,1] , aEstruc3[k,2] , aEstruc3[k,3] , aEstruc3[k,4] } )
next k

aCampos := a2tosing( aEstruc , 1 )
aTipos  := a2tosing( aEstruc , 2 )
aLargo  := a2tosing( aEstruc , 3 )
aDec    := a2tosing( aEstruc , 4 )
select factu01
cConsulta := query( aCampos , aCampos , aTipos )
select pracreng
cmfilter( cConsulta )
go top
copy to practmp
use practmp
freqanal()
use
delete file practmp
return
