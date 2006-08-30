 /* 
   ----------------------------------------------------------------
   Mesa.prg
	Objeto : Funciones de ingreso de datos a la mesa de entradas
   
	Lista de funciones:
	IngComp() -> ingresa y selecciona el tipo de comprobante
	             el tipo de comprobante es: 1 = Facturas Prestadores
					                            2 = Facturas Proveedores
														 3 = Documentaci¢n Interna
	SigNumero() -> calcula y devuelve el siguiente numero de lo que 
	               se le dice : ENTRADA, SALIDA, FAX
   ------------------------------------------------------------------
*/

#include "supmenu.ch"
#include "inkey.ch"

/* --------------------------------------- */
   Function IngComp()
/* --------------------------------------- */
set key K_F2     to scroller
set key K_ALT_F2 to scmod
set key K_F10    to nuepres

select 1
if snet_use("ENTRADA.DBF","ENT",.f.,5,.t.,"No se puede abrir ENTRADA.DBF - ¨Reintenta?")
	set order to tag mesa
else
	msg("No se puede abrir ENTRADA.DBF",;
	    "El programa cancela")
	cancel
endif

*--

select 2
if snet_use("FACTU01.DBF","F01",.F.,5,.T.,"No se puede abrir FACTU01.DBF - ¨Reintenta?")
	set order to tag FAPRENUM
else
	msg("No se puede abrir FACTU01","El programa cancela")
	quit
endif

select 3
if snet_use("IN1PRES","PRES",.F.,5,.T.,"No se puede abrir IN1PRES - ¨Reintenta?")
	set order to tag PRCOD
else
	msg("No se puede abrir IN1PRES","El programa cancela")
	quit
endif

select 4
if snet_use("CONCEPTO","CONC",.F.,5,.T.,"No se puede abrir CONCEPTO - ¨Reintenta?")
	set order to tag CONCOD
else
	msg("No se puede abrir CONCEPTO","El programa cancela")
endif

initsup()
marriba := makebox(1,1,3,78,sls_popcol())
@ 2,1 say centr("Mesa de Entrada - Ingreso de Comprobantes",77)

*-- 
* Variables de memoria
*--
select ENT


mtmp := makebox(4,1,23,78,sls_normcol())
while .t.
	select ENT
	m->mingreso    := dtoc(date())
	m->mnumero     := space(len(NUMERO))
	m->mtipo       := space(len(TIPO))
	m->mdescripcio := space(len(DESCRIPCIO))
	m->mcorrespond := space(len(CORRESPOND))
	m->morden := SigNumero("ENTRADA")
	
	@ 6,3 say "Fecha de Ingreso:" get mingreso pict "@D"
	@ 7,3 say "Orden de Ingreso:" get morden   pict "@9" valid ;
	      genval("isnotdup(morden)","Ese N§ de Orden ya existe")
	@ 8,3 say "N§ Comprobante  :" get mnumero
	@ 9,3 say "Descripci¢n     :" get mdescripcio pict "@S50"
	@10,3 say "Forma Llegada   :" get mcorrespond
	read
	aTipo := {"FACTURA PRESTADOR",;
	          "FACTURA PROVEEDOR",;
				 "OTROS            "}
	if abort()
		exit
	endif
	
	maTipo := mchoice(aTipo,12,3,16,22,"TIPO DE COMPROBANTE")
	
	if abort()
		exit
	endif
	mtipo := padl( m->maTipo , 2 ,"0" )
	@ 11,3 say "Tipo Comprobante: " + aTipo[m->maTipo]
	if messyn("¨Los datos son correctos?",18,3)
		GrabaNumero("ENTRADA",m->morden)
		do case
			case mtipo == "01"
			grabamesa()
			FactPrest()
			case mtipo == "02"
			grabamesa()
			FactProv()
			case mtipo == "03"
			grabamesa()
		endcase
	endif
	
	
	if !messyn("¨Ingresa otro Comprobante?",18,3)
		exit
	endif
	m->morden := SigNumero("ENTRADA")
end
unbox(mtmp)
unbox(marriba)
return NIL  	

/* ---------------------------------- */
   Function SigNumero
/* ---------------------------------- */
parameter tipo
private NumCaracter,NumNumero,campo,marea
marea := select()

select 0
while !snet_use("NUMERO.DBF","NUMERO",.T.,5,.F.)
	msg("Otro usuario usa el n£mero","Por favor espere un momento")
	if abort()
		exit
	endif
end
m->campo := m->tipo
m->NumNumero := val(&campo) + 1
NumCaracter := padl(m->NumNumero,len(&campo),"0")
use
select (marea)
return NumCaracter

/* -------------------------------------- */
   Function grabamesa
/* -------------------------------------- */
select ENT
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace ingreso    with ctod(mingreso)
		replace orden      with morden
		replace numero     with mnumero
		replace tipo       with mtipo
		replace correspond with mcorrespond
		replace descripcio with mdescripcio
		unlock
	else
		msg("No se grabaron los datos")
	endif
else
	msg("No se grabaron los datos")	
endif
return NIL

/* -------------------------------------- */
   Function FactPrest
/* -------------------------------------- */
select F01
mprestador := space(len(F01->PRESTADOR))
mtotalfactu := 0.00
mbolepres := 0
mporcentaje := 0.00
mcategoriza := 0.00
mconcepto   := space(len(CONCEPTO))
mdelegacion := "5000"

mpant := makebox(9,1,22,78)
while .t.
	@ 11,2 SAY "N§ FACTURA:......." + mnumero
	@ 10,2 SAY "PRESTADOR:........" get mprestador valid ;
	  genval("chequea('3',mprestador,'PRNOMB')","El prestador ingresado no est  en el archivo")
	@ 12,2 SAY "TOTAL FACTURADO:.." get mtotalfactu pict "999,999.99"
	@ 11,50 SAY "SELLO DE INGRESO:" + mingreso                    //FPRES
	@ 15, 2 SAY "CONCEPTO:........" get mconcepto   pict "!!" ;
	  valid genval("CHEQUEA('4',mconcepto,'descri')","El concepto ingresado no est  en el archivo")

	read

	if abort()
		return NIL
	endif
	
	seek mprestador + mnumero
	if found()
		msg( "Factura ya ingresada" )
		return NIL
	endif
	if messyn("¨Los datos ingresados son los correctos?",18,2)
		if sadd_rec(5,.f.)
			if srec_lock(5,.f.)
				replace F01->REGIONAL   with "5000"
				replace F01->FACTURA 	with padl( alltrim( MEMVAR->mnumero ) , len( F01->FACTURA ) , "0" )
				replace F01->PRESTADOR 	with MEMVAR->mprestador
				replace F01->TOTFACTU 	with MEMVAR->mtotalfactu
				replace F01->FPRES	 	with ctod( MEMVAR->mingreso )
				replace F01->CONCEPTO   with MEMVAR->mconcepto
				replace F01->CODPOSTAL  with C->PRCPOS
			else
				msg("Error de red - Los datos no fueron grabados")
			endif
		else
			msg("Error de red - Los datos no fueron grabados")
		endif
		exit
	endif
enddo

unbox(m->mpant)

return NIL

/* -------------------------------------- */
   Function FactProv
/* -------------------------------------- */
return NIL

/* -------------------------------------- */
   Function GrabaNumero()
/* -------------------------------------- */
parameters tipo,mOrden
select 0
m->campo := m->tipo
if snet_use("NUMERO.DBF","NUMERO",.T.,5,.F.)
	replace &campo with mOrden
	use
else
	msg("No se pudo bloquear el registro")
endif

return NIL

/* ------------------------------------------- */
   Function LibroEnt
/* ------------------------------------------- */

local menuentr
*====== menu globals========*

MENU INIT ;
  WINDOW DIMS 10,21,24,66 FRAME "ÚÄ¿³ÙÄÀ³ ";
  MESSAGE  MCENTER ;
  TITLE TEXT "Men£ de Libro de Entradas"  TCENTER 
MENU BARPAD 2
MENU MOUSE EXIT AT 10,23 TEXT "[þ]" COLOR "N/W"
MENU FORCE DROP .t.
MENU BOXES FRAME "ÚÄ¿³ÙÄÀ³ " OVER 1 DOWN 1;
  PADLEFT 1 PADRIGHT 1 CROSSBAR "Ã","Ä","´"
MENU COLORS SELECTED "W/N","W+/N" UNSELECTED "N/W","W+/W";
  INACTIVE "N+/W" WINDOW "W/N" MSG "N/W";
  BOXES "N/W" TITLE "W+/N"


*====== menu structure======*

   BAROPTION "Libro de Entradas" ID "entradas" KEY 274 COLUMN 23;
      MESSAGE "Acceso al Libro de Entradas"
     DROPSTART DOWN 1 OVER 0
     BOXOPTION "Ver Libro Entradas     " ID "VerLibro";
        MESSAGE "Permite ver el libro de entradas"
     BOXOPTION "Imprimir Libro Entradas" ID "ImpLibro";
        MESSAGE "Permite Imprimir el Libro de Entradas"
     BOXOPTION "Salir                  " ID "salirmesa";
        MESSAGE "Salir al men£ anterior"
     DROPEND

*====== menu handling=====*

* (Note: menuentr should be renamed and declared LOCAL)

menuentr := MENU WRAP
MENU SHOW menuentr
DO WHILE .T.
  MENU DO menuentr 
  do case   
  case MENU EXIT REQUEST
  		exit
  case MENU EXCEPTION
  		if lastkey() == K_ESC
			exit
		endif
  case MENU ACTION REQUEST
    do case   
    case MENU ACTION ID == "VerLibro" && Ver Libro Entradas     
	 	if snet_use("ENTRADA","ENTRADA",.F.,5,.T.,"No se puede abrir MESA.DBF - ¨Reintenta?")
			set order to tag mesa
		else
			msg("El archivo est  siendo usado por otro","Reintente luego")
			exit
		endif
		aCampos := {"ORDEN","INGRESO","NUMERO","TIPO","DESCRIPCIO","CORRESPOND"}
		aDescr := {"N§","Fecha Ingreso","N§","Tipo","Descripci¢n","Forma de Llegada"}
		editdb(.t.,aCampos,aDescr,.T.,.t.)
    case MENU ACTION ID == "ImpLibro" && Imprimir Libro Entradas
	 	menu hide menuentr
	 	if snet_use("ENTRADA","ENTRADA",.F.,5,.T.,"No se puede abrir MESA.DBF - ¨Reintenta?")
			set order to tag mesa
		else
			msg("El archivo est  siendo usado por otro","Reintente luego")
			exit
		endif
		@ 0,0 say replicate(chr(176),25*80)
		mfecha1 := space(10)
		mfecha2 := space(10)
		popread(.f.,"Desde Fecha",@mfecha1,"@d",;
		            "Hasta Fecha",@mfecha2,"@d")
		set filter to INGRESO >= ctod(var2char(mfecha1)) .and.;
		              INGRESO <= ctod(var2char(mfecha2))
		plswait(.t.)
		go top
		plswait(.f.)
		
		quikreport( "MESA DE ENTRADAS" )
		@ 0,0 say replicate(space(1),25*80)
		menu show menuentr
    case MENU ACTION ID == "salirmesa" && Salir
	 	exit
    endcase   
  endcase   
ENDDO       
MENU HIDE  menuentr

* ------------------------------
  function nuepres
* ------------------------------
local getlist := {}, mtmp
set cursor on
nArea := select()

select C
go lastrec() + 1

cLetra   := PRLETR
cCodigo  := PRCODI
cNombre  := PRNOMB
cCPos    := PRCPOS
* cEspe    := PRESPE
cPcia    := PRPCIA

mtmp := makebox(3,3,20,77)
while .t.
	@ 5,5 say "Letra     "  get cLetra pict "!"
	@ 6,5 say "C¢digo    " get cCodigo PICT "@9" valid genval( "dup_chk(cLetra + cCodigo , 3 )" , "Prestador duplicado" )
	@ 7,5 say "Nombre    " get cNombre
	@ 8,5 say "Cod Postal" get cCpos pict "9999"
	@ 9,5 say "Provincia " get cPcia pict "!"
	read
	if abort()
		exit
	endif
	if messyn("¨Graba los datos?")
		if sadd_rec(5,.f.)
			if srec_lock(5,.f.)
					replace  PRLETR with cLetra
					replace  PRCODI with cCodigo
					replace  PRNOMB with cNombre 
					replace  PRCPOS with cCPos 
*					replace  PRESPE with cEspe
					replace  PRPCIA with cPcia
					unlock				
					commit
			endif
		endif
	endif
end
unbox(mtmp)
select (nArea)
return NIL
