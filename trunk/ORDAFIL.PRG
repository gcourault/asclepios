/* -------------------------------------------------
   Programa : OrdAfil.prg
	Carga de las ordenes compradas por los afiliados
----------------------------------------------------*/
#include "inkey.ch"

function ordafil()
local cPantalla,cArriba
* --
set key K_F2 to scroller
set key K_ALT_F2 to scmod
set key K_F10 to VerOrdenes

initsup()
* --
select 2
if snet_use("BASEAFIL","AFILIADO",.F.,5,.T.,"No se puede abrir archivo de afiliados - ¨Reintenta?")
	set order to tag AFINUM
else
	msg("Un usuario ha bloqueado el archivo",;
	    "O se ha producido un fallo en la red",;
		 "Reintente luego")
  return
		
endif

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

cDelegacion := DELEGACION
cTipo       := TIPO
cSerie      := SERIE
nRecetaDesde:= RECETA
nRecetaHasta:= RECETA
cAfiliado   := AFILIADO
dFechaComp  := FECHACOMP
cCodPostal  := CODPOSTAL
cDomicilio  := DOMICILIO
cLocalidad  := LOCALIDAD
cPoblacion  := POBLACION
m->cArriba   := makebox(1,2,4,78,c_popcol)
@ 2,3 say centr("CARGA DE ORDENES AFILIADOS",74)
@ 3,3 say centr("<F2> Busca Afiliado - <ESC> Cancela - <F10> Ver Ordenes",74)
m->cPantalla := makebox(6,2,20,78,c_normcol)
while .t.
	@ 7,4 say "Delegaci¢n :" get cDelegacion pict ed_g_pic("DELEGACION")
	@ 8,4 say "Tipo       :" get cTipo       pict ed_g_pic("TIPO")
	@ 9,4 say "Serie      :" get cSerie      pict ed_g_pic("SERIE")
	@ 11,4 say  "Primer Receta :" get nRecetaDesde pict ed_g_pic("RECETA")
	@ 11,40 say "Ultima Receta :" get nRecetaHasta pict ed_g_pic("RECETA")
	@ 13,4 say "Afiliado   :" get cAfiliado pict ed_g_pic("AFILIADO") ;
	                             valid genval("chequea('2',cAfiliado,'BAAPEL')","Afiliado inexistente")
   @14,4 say "Domicilio    :" get cDomicilio pict ed_g_pic("DOMICILIO")	
	@15,4 say "Localidad    :" get cLocalidad pict ed_g_pic("LOCALIDAD")
	@16,4 say "Fecha        :" get dFechaComp pict "@D"
	@17,4 say "C¢digo Postal:" get cCodPostal pict ed_g_pic("CODPOSTAL")
	@18,4 say "Poblaci¢n    :" get cPoblacion pict ed_g_pic("POBLACION")
	read
	if abort()
		exit
	endif
	if messyn("¨Graba los datos ingresados?")
		for k = 1 to ( val( nRecetaHasta ) - val( nRecetaDesde) ) + 1
			if sadd_rec(5,.t.,"No se puede agregar registro - ¨Reintenta?")
				if srec_lock(5,.t.,"No se puede grabar el registro - ¨Reintenta?")
					ORDENES->DELEGACION := cDelegacion
					ORDENES->TIPO       := cTipo
					ORDENES->SERIE      := cSerie
					ORDENES->RECETA     := padl( alltrim( str( (val( nRecetaDesde ) - 1) + m->k ) ) , 6 , "0" )
					ORDENES->AFILIADO   := cAfiliado 
					ORDENES->FECHACOMP  := dFechaComp
					ORDENES->CODPOSTAL  := cCodPostal
					ORDENES->DOMICILIO  := cDomicilio
					ORDENES->LOCALIDAD  := cLocalidad
					ORDENES->POBLACION  := cPoblacion
					unlock
				endif
			endif
		next k
	endif
	
	nRecetaDesde := 0
	nRecetaHasta := 0
end
unbox(m->cPantalla)
unbox(m->cArriba)
close databases
return

*---------------------------------
 proc VerOrdenes
*---------------------------------
parameters p1,p2,p3

editdb(.t.,10,;
       {"DELEGACION",;
		 "TIPO",;
		 "SERIE",;
		 "RECETA",;
		 "AFILIADO",;
		 "FECHACOMP",;
		 "CODPOSTAL",;
		 "DOMICILIO",;
		 "LOCALIDAD",;
		 "POBLACION"},;
		 {"Delegaci¢n",;
		 "Tipo",;
		 "Serie",;
		 "Receta",;
		 "Afiliado",;
		 "Fecha",;
		 "C.Postal",;
		 "Domicilio",;
		 "Localidad",;
		 "Cod.Poblaci¢n"},.t.)
return
*--

