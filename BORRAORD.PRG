/* -------------------------------------------------
   Programa : borraord.prg
	borra las ordenes compradas por los afiliados
----------------------------------------------------*/
#include "inkey.ch"
function borraord()
local cPantalla,cArriba
* --
set key K_F2 to scroller
set key K_ALT_F2 to scmod
set key K_F10 to VerOrdenes

initsup()
* --

select 1
if snet_use("OrdAfil","ORDENES",.f.,5,.t.,"No se puede abrir el archivo de Ordenes de los Afiliados - ¨Reintenta?")
	set order to tag ORDAFIL
else
	msg("Un usuario ha bloqueado el archivo",;
	    "O se ha producido un fallo en la red",;
		 "Reintente luego")
  return
endif

go lastrec() + 1             // REGISTRO FANTASMA

nDelegacion := DELEGACION
cTipo       := TIPO
cSerie      := SERIE
nRecetaDesde:= RECETA
nRecetaHasta:= RECETA
nAfiliado   := AFILIADO
dFechaComp  := FECHACOMP
cCodPostal  := CODPOSTAL
cDomicilio  := DOMICILIO
cLocalidad  := LOCALIDAD
cPoblacion  := POBLACION
m->cArriba   := makebox(1,2,4,78,c_popcol)
@ 2,3 say centr("BORRADO DE ORDENES AFILIADOS",74)
@ 3,3 say centr("<F2> Busca Afiliado - <ESC> Cancela - <F10> Ver Ordenes",74)
m->cPantalla := makebox(6,2,20,78,c_normcol)
while .t.
	@ 8,4 say "Tipo       :" get cTipo       pict ed_g_pic("TIPO")
	@ 9,4 say "Serie      :" get cSerie      pict ed_g_pic("SERIE")
	@ 11,4 say  "Primer Receta :" get nRecetaDesde pict ed_g_pic("RECETA")
	@ 11,40 say "Ultima Receta :" get nRecetaHasta pict ed_g_pic("RECETA")
	read
	if abort()
		exit
	endif
	if messyn("¨Borra las recetas indicadas?")
		seek 	cTipo + cSerie + var2char( "nRecetaDesde" )
		if found()
			plswait( .t. , "Borrando" )
			while RECETA >= nRecetaDesde .and. RECETA <= nRecetaHasta
				if srec_lock( 5 , .f. )
					delete
					unlock
				else
					msg( "Error al borrar la receta - Reintente luego" )
				endif
				skip
			end
			plswait( .f. )
		else
			msg( "Recetas no encontradas" )
		endif
	endif
	
	nRecetaDesde := 0
	nRecetaHasta := 0
end
unbox(m->cPantalla)
unbox(m->cArriba)
close databases
return


