#include "inkey.ch"
external isnotdup
/* 
 -----------------------------------------------
archivos.prg
programas de acceso a los archivos del sistema
preparado para red
----------------------------------------------- 
Funciones:

afiliado() -> acceso al programa de afiliados
medicame() -> acceso al programa de medicamentos
prestado() -> acceso al programa de prestadores
agentes() ->  acceso al programa de agentes
medicos() -> acceso al programa de medicos
*/
external lister
/* ------------------------------------------------ */
   function afiliado()
/* acceso al archivo de afiliados                   */
/* ------------------------------------------------ */

set delete on

if snet_use("BASEAFIL","AFILIADO",.f.,5,.f.)
	set order to tag AFINUM
else
	msg("Error en la red",;
	    "Regresa al men£ anterior")
   return NIL
endif
viewport()
return NIL

/* ----------------------------------------- */
   function medicame()
/* acceso al archivo de medicamentos         */
/* ----------------------------------------- */

set delete off
if snet_use("medi","MEDICAME",.f.,5,.f.)
	set order to tag METROQ
else
	msg("Error en la red",;
	    "Regresa al men£ anterior")
   return NIL
endif

aOtros := {"1. Buscar por Troquel;BuscTroq()",;
           "2. Buscar por Nombre Medicamento;BuscMedi()",;
			  "3. Crear Vademecum;PrecVad()",;
			  "4. Generador de Listados;lister()"}
private aCampos[fcount()]
private aDescr[fcount()]
private aValid[fcount()]
afields(aCampos)
afields(aDescr)
afill(aValid,"")

aValid[1] := "isnotdup(@@ , nil , nil , .f. , recno() , nil );Troquel duplicado"

viewport(.t.,aCampos,aDescr,.f.,aValid,.f.,aOtros)
return NIL

/* --------------------------------------------- */
   function prestado()
/* acceso al archivo de prestadores              */
/* --------------------------------------------- */
set delete on
if snet_use("in1pres","PRESTADO",.f.,5,.f.)
	set order to tag PRNOMB
else
	msg("Error en la red",;
	    "Regresa al men£ anterior")
   return NIL
endif
viewport()
return NIL

/* -------------------------------------------- */
   function agentes()
/* acceso al archivo de agentes de la regional
------------------------------------------------*/
set delete on

/*if !snet_use("f:\gustavo\premio","AGENTES",.f.,5,.f.)
	msg("Error en la red",;
	    "Regresa al men£ anterior")
   return NIL
endif
viewport()
*/return NIL

*-------------------------------
function BuscTroq()
*-------------------------------
local mtmp
local GetList := {}
set cursor on
mtmp := makebox(10,10,14,70)
set order to 1

while .t.
	mtroquel := space(len(troquel))
	@ 12,12 say "Ingrese N§ de Troquel:" get mtroquel pict "9999999"
	read
	seek mtroquel
	if found()
		vertview()
		exit
	else
		if !messyn("Troquel no encontrado - ¨Reintenta?")
			exit
		else
			loop
		endif
	endif
enddo
unbox(mtmp)
return NIL

*-------------------------------
function BuscMedi()
*-------------------------------
local mtmp
local GetList := {}
set cursor on
mtmp := makebox(10,10,14,70)
set order to 2

while .t.
	mnombre := space(len(NOMBRE))
	@ 12,12 say "Ingrese Nombre de Medicamento" get mnombre pict "@!"
	read
	seek alltrim(mnombre)
	if found()
		vertview()
		exit
	else
		if !messyn("Medicamento no encontrado - ¨Reintenta?")
			exit
		else
			loop
		endif
	endif
enddo
unbox(mtmp)
set order to 1
return NIL

* ---------------------
  function precvad
* ---------------------
local GetList := {}
local mtmp
set cursor on
mtroquel := space(len(TROQUEL))
mprecio := 0.00
mtmp := makebox(10,10,16,70,c_normcol)
while .t.
	@ 11,11 say "Ingrese Troquel:" get mtroquel pict "9999999" valid(genval("valtroquel(mtroquel)","Medicamento Inexistente"))
	@ 12,11 say "Precio Venta   :" get mprecio pict "999999.99" 
	set key K_F2 to scroller
	set key K_ALT_F2 to scmod
	read
	if abort()
		exit
	endif
	set key K_F2 to
	set key K_ALT_F2 to
	mopcion := menu_v("Sus opciones son:     ",;
	                  "1. Grabar Nuevo Precio",;
	                  "2. Reingresar Datos   ",;
							"3. Salir sin Grabar   ")
	do case
		case mopcion == 1
		if srec_lock(5,.f.)
			replace VTAPUB with mprecio*100
			unlock
		endif
		case mopcion == 2
		loop
		case mopcion == 3
		exit
	endcase
end
unbox(mtmp)
return NIL

* -----------------
function valtroquel
* -----------------
parameters mtroquel
seek mtroquel
mprecio := VTAPUB/100.00
return found()

*------------------
function medicos
*------------------
if snet_use("MEDICOS","MEDICOS",.F.,5,.T.,"No se puede acceder al archivo de M‚dicos - ¨Reintenta?")
	set order to tag medmat
	viewport()
endif
return NIL
