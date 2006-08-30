/* 
---------------------------------------------
   Programa AudPrac.prg
	Auditor¡a de pr cticas m‚dicas
---------------------------------------------
*/
external cambhono

#include "inkey.ch"
#include "mediator.ch"
* -----------------
 function audprac()
* -----------------
local mtmp,nSelecc,nAccion

set delete on

set decimal to 2
set fixed on

set key K_F5     to CambHono
set key K_F9     to EditDebito
set key K_F11    to ModNomenc

initsup()

select 20
if snet_use("BASEAFIL","AFIL",.f.,5,.t.,"Tabla de afiliados bloqueada - ¨Reintenta?")
  set order to tag AFINOMB
else
     msg("No se pudo abrir Baseafil - Reintente")
     return
endif
select 6
if snet_use("CONVENIO","CONV", .f. , 5 , .t. , "No se puede abrir archivo de Convenios - ¨Reintenta?")
	set order to tag CODIGO
else
	msg("No se puede abrir archivo de Convenios",;
	    "Un usuario bloquea el archivo",;
		 "Intente m s tarde")
endif
select 16
if snet_use( "UARA" , "UARANC" , .F. , 5 , .T. , "No se puede abrir archivo de Unidades Arancelarias - ¨Reintenta?" )
	set order to tag CODIGO
else
	msg("No se puede abrir archivo de Convenios",;
	    "Un usuario bloquea el archivo",;
		 "Intente m s tarde")
endif
select 15
set relation to PRCONV into CONV

select 6
set relation to UARA into UARANC

select 9
if snet_use("AUTORIZ","AUTORIZ", .F. , 5 , .T. , "No se puede abrir archivo de Autorizaciones - ¨Reintenta?" )
	set order to tag AUTORIZ
else
	msg("No se puede abrir archivo de Autorizaciones",;
	    "debe intentar m s tarde - Otro usuario est  usando el archivo")
endif
select 8
if snet_use("ORDAFIL","ORDENES",.F.,5,.T.,"No se puede abrir archivo Ordenes - Afiliados - ¨Reintenta?")
	set order to tag ORDAFIL
else
	msg("No se puede abrir archivo de Ordenes - Afiliados",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif


select 7
if snet_use("DEB002","DEBITOS",.F.,5,.T.,"No se puede abrir archivo de d‚bitos - ¨Reintenta?")
	set order to tag DEB002
else
	msg("No se puede abrir archivo de debitos",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 2
if snet_use("PRACTICA","PRACTICA",.F.,5,.T.,"No se puede abrir archivo de CONSULTA - ¨Reintenta?")
	set order to tag PRACTICA
else
	msg("No se puede abrir archivo de pr cticas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 0
if snet_use("PRACRENG","PRACRENG",.F.,5,.T.,"No se puede abrir archivo de CONSULTA - ¨Reintenta?")
	set order to tag PRACRENG
else
	msg("No se puede abrir archivo de consultas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

if medistable(  alltrim( conv->archivo) )
        cNomenclador := alltrim( conv->archivo)
	select 0
        if snet_use( alltrim( (CONV->ARCHIVO) ),"NOMENCLA",.F.,5,.T.,"No se puede abrir archivo nomenclador - ¨Reintenta?")
		set order to tag NOMECODI
	else
		msg("No se puede abrir archivo nomenclador",;
	   	 "debe intentar m s tarde: otro usuario est  usando el archivo")
		return
	endif
else
	msg("Prestador sin Convenio","No se lo puede auditar")
	return
endif

select 0
if snet_use( UARANC->ARCHIVO , "UARA" , .F. , 5 , .T. , "No se puede abrir archivo de Unidades arancelarias ¨Reintenta?")
	set order to tag FECH
else
        msg("No se puede abrir archivo de unidades arancelarias",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	
endif
select 0
if snet_use("BASEAFIL","AFILIADO",.F.,5,.T.,"No se puede abrir archivo de afiliados - ¨Reintenta?")
	set order to tag AFINUM
else
	msg("No se puede abrir archivo de AFILIADOS",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

m->mtmp := makebox(0,1,22,76,sls_normcol())

@ 9,2 to 9,75
@ 18,2 to 18,75
@ 20,2 say " F5 -> Cambia % Honorarios            -            F9 -> Ventana D‚bitos"  

mtipopract := space( 1 )
mserieint := space( 2 )
mnumeroint := space( 6 )
cComienzo := space( 10 )
cFinal := space( 10 )
nEdad := 0
cDiagnostic := space( 7 )
cComplicaci  := space( 30 )
cComplejo   := space( 1 )
mmandataria := space( 5 )
mcategoriz := 0.00
marancel   := 0.00
mapagar    := 0.00
mserie     := space( 2 )
mreceta    := space( 6 )
mtotdiba := 0.00
mtotdeb := 0.00
mmotdeb = space( 3 )
mafiliado := space( 9 )
mmatricula := space( 7 )
mfechapres := space( 10 )

mReingresa := .f.

do while .t.
	@ 1,2  say "FACTURA: " + FACTURA->FACTURA
	@ 1,32 say "PRESTADOR: " + PRESTA->PRNOMB
	@ 2,2 say "Mandataria:" get mmandataria pict "99999" valid genval("!empty(mmandataria)","Ingrese N§ de mandataria")
	read
	if lastkey() == K_ESC
		exit
	endif
	while .t.
		nTipo := menu_v("Tipo de Pr ctica:",;
  			             "1. Ambulatoria",;
							 "2. Internacion" )
		@ 21,2 say "TIPO DE PRACTICA: " + iif( nTipo == 2 , "INTERNACION" , "AMBULATORIO" )
		mtipopract := iif( nTipo == 2 , "I" , "A" )
		if mtipopract == "I"
			mInterna := makebox( 3 , 2 , 12 , 78 , sls_normcol() )
			@ 4, 3 say "Serie Bono Internaci¢n:" get mserieint 
			@ 5, 3 say "N§ Bono Internaci¢n   :" get mnumeroint
			@ 4 ,40 say "Fecha Inicio     :" get cComienzo pict "@D"
			@ 5 ,40 say "Fecha Final      :" get cFinal pict "@D"
			@ 7 , 3 say "Diagn¢stico          :" get cDiagnostic 
			@ 7 ,40 say "Complejidad(S/N) :" get cComplejo pict "!" valid cComplejo $ "SN" 
			@ 8 , 3 say "Complicaci¢n         :" get cComplicaci
			read	
			unbox( mInterna )
		endif
		if messyn( "¨Correcto?" )
			exit
		endif
	end
	

	@ 2,32 say "Facturado:"
	@ 2,44 say FACTURA->TOTFACTU pict "99999.99"
	@ 2,57 say "A pagar:"
	@ 2,66 say FACTURA->TOTAPAG pict "999999.99"
	@ 3,2 say "Honorarios:    %            Serie:        N£mero:"
	@ 4,2 say "Gastos    :    %"

	while .t.
		@ 3,13 get mcategoriz pict "999.99"
		@ 4,13 get marancel   pict "999.99"
		@ 3,36 get mserie pict "!!" valid genval("!empty(mserie)","Ingrese la Serie")
		@ 3,52 get mreceta pict "999999" valid ;
		       dup_chk( FACTURA->PRESTADOR+ FACTURA->FACTURA + mserie + mreceta , 2 )
	   read
		if abort()
			exit
		endif
		
		select AUTORIZ
		seek mserie + right( "000000" + alltrim(mreceta) , 6 )
		if found()
			mafiliado := AFILIADO
	      mfechapres := FECHA
			mmatricula := MATRICULA		
		endif

		@ 5,7 say "Nro. de Afiliado.:                   Fecha Pr ctica.......:"
		@ 7,7 say "Nro. de Matr¡cula:"
	
                @ 5,26 get mafiliado pict "999999999" valid genval("!empty(mafiliado)","Ingrese N§ de afiliado") .and. verape( mafiliado )
		@ 5,67 get MFECHAPRES pict "@D" valid genval("!empty(MFECHAPRES)","Ingrese fecha emisi¢n")
		@ 7,26 get mmatricula pict "@!" valid genval("!empty(mmatricula)","Ingrese la matr¡cula")

                * set key K_F2 to scroller
                * set key K_ALT_F2 to scmod
                smallkset( K_F2 , "AUDPRAC" , "mafiliado" , {|| banume+baorde + " " + baapel} ,"Afiliados", 20  , 'BANUME+BAORDE' )

		read
                smallkclr()
		if abort()
			exit
		endif	

	   *--
		* Control del afiliado
		*--
		select AFILIADO
		seek mafiliado
		if .not. found()
			mopciones := menu_v("ERROR EN EL N§ DEL AFILIADO  ",;
			                    "1. Graba y Debita Comprobante",;
									  "2. Sigue sin grabar d‚bito   ",;
									  "3. Reingresa Datos           ")
			do case
			case mopciones == 1
				mtotdeb := 0.00
				mmotdeb := "002"
				popread(.f.,"Ingrese Monto a debitar",@mtotdeb,"999999.99")				
				mensaje := "Debitar  $" + alltrim(str(mtotdeb,10,2))
				if messyn(mensaje,"Graba Factura y D‚bito","No graba")
                                        grabacabrec2()
                                        grabadebito2(mtotdeb)
				endif
				InitVarCom()
				loop
				case mopciones == 2
				/* nada */
				case mopciones == 3
				loop
			endcase
		else
			alertit()
			if messyn("REVISE BIEN LOS DATOS INGRESADOS","CONTINUAR","REINGRESAR")
				/* nada */
			else
				loop
			endif
		endif	                                        

		select PRACRENG
		/* -----------------------------------
		   ingreso de renglones
			----------------------------------- */
		if !mReingresa	
			mtmpDBF := uniqfname("DBF","")
			copy stru to (mtmpDBF)
			marea := select()
			select 0
			use (mtmpDBF) exclusive alias TEMPO
			mtmpAREA := select()

			select AUTORIZ
			seek  mserie + mreceta
			if found()
				while mserie + mreceta == SERIE + NUMERO
					tempo->( DBAPPEND() )
					replace tempo->NOMENCLADO with NOMENCLADO
					replace tempo->CANTIDAD   with CANTIDAD
					skip
				end
			endif
			select (mtmpArea)
			go top
		else
			select (mtmpAREA)
			mReingresa := .f.
		endif
			
		set relation to NOMENCLADO into NOMENCLA
		aColumnas := {"CANTIDAD","NOMENCLADO","UNITARIO","TOTFACTU"}
		aDescr    := {"Cant.","C¢d.Nom.","P.U.","a Cargo Diba"}
		m->mtmp1 := makebox(9,2,18,74)
		m->mest := makebox(21,2,23,74)
		@ 22,28 say "<INS> Agrega ³ <DEL> Borra ³ <ENTER> Modifica"
		oTBRenglon := TBrowseDB( 10 , 3 , 17 , 73 )
		oTBRenglon:headSep := "ÍÑÍ"
		oTBRenglon:colSep  := " ³ "
		oTBRenglon:addColumn( TBColumnNew( "Cant." , { || CANTIDAD } ) )
		oTBRenglon:addColumn( TBColumnNew( "Cod.Pract." , { || NOMENCLADO } ) )
		oTBRenglon:addColumn( TBColumnNew( "Pr ctica" , { || NOMENCLA->DESC } ) )
		oTBRenglon:addColumn( TBColumnNew( "P.U." , { || UNITARIO } ) )
		oTBRenglon:addColumn( TBColumnNew( "Total" , { || TOTAL } ) )
		oTBRenglon:addColumn( TBColumnNew( "D‚bito" , {|| DEBITO } ) )
		oTBRenglon:addColumn( TBColumnNew( "A Cargo DIBA" , { || TOTAPAG } ) )
		while .t.
			nTecla := 0
			while nTecla == 0 .and. !oTBRenglon:stable
				oTBRenglon:stabilize()
				nKey := inkey()
			end
			if oTBRenglon:stable
				if oTBRenglon:hitTop .OR. oTBRenglon:hitBottom
					tone( 125 , 0 )
				endif
				oTBRenglon:refreshCurrent()
				oTBRenglon:ForceStable()
				if reccount() = 0
					keyboard chr( K_INS )
				endif
				nTecla := inkey(0)
			endif
			if nTecla == K_ESC
				exit
			else
                                AplicaTeclaPractica( nTecla )               
			endif
			nReg := recno()
			sum TotFactu to mTotDIBA
			@ 22, 4 say "Total: "
			@ 22,13 say mTotDIBA		
			go nReg
			oTBRenglon:ForceStable()
		end
		* ------------------------------------------------------------------
			
		unbox(m->mtmp1)
		unbox(m->mest)
	
	
		sum TOTFACTU to mTotal1
		mTotal := mTotal1
	
		mDiferencia := 0.00
		mtmp2 := makebox(10,3,14,73,sls_popcol() )
	
		while .t.
			@ 12,4 say "Ingrese Total del Comprobante" ;
		   	   get mTotal pict "99999.99" ;
					valid genval("mTotal > 0","El Monto debe ser mayor que cero")
			read
			if lastkey() == K_ESC
				if messyn("Tiene las siguientes opciones:","Reingresar TOTAL","Continuar con esta Receta",18,3)
					loop
				else
					exit
				endif
			endif
			if mTotal > mTotal1
				mDiferencia := mTotal - mTotal1
				popread( .f. , "Monto a Debitar" , @mDiferencia , "999999.99" ) 
				mmensaje := "¨Le debita a este comprobante $"+alltrim(str(mDiferencia,8,2))
				if messyn(mmensaje)
					exit
				else
					mDiferencia := 0.00
				  exit
				endif
			else
				exit
			endif
		end
		unbox(mtmp2)
   
		do while .t.
			mopciones := menu_v("Tiene las siguientes Opciones:",;
			                    "1. Grabar Comprobante         ",;
									  "2. Debitar el Comprobante     ",;
									  "3. Reingresar los datos       ")
			do case
			case mopciones == 1
				replace all factura with FACTURA->factura 
				replace all prestador with mprestador
				replace all mandataria with mmandataria
				replace all afiliado with mafiliado
				replace all serie with 	mserie
				replace all numero with mreceta
				replace all feching with date()
				go top
	
				do while !eof()
					select (mtmpAREA)
					if (DEBITO > 0)
						mmotdeb := MOTDEB
                                                grabadebito2(DEBITO , NOMENCLADO )
					endif
					select (mtmpAREA)
					skip			
				enddo
				if mDiferencia > 0.00
					mmotdeb := "070"
                                        grabadebito2(mDiferencia)
				endif
			
				select (mtmpAREA)
				go top
				sum DEBITO to mtotdeb
				sum TOTAL to mtotdiba
			   mapagar := mtotdiba - mtotdeb - mDiferencia
				use
			
                                grabacabrec2()
                                grabarenrec2()
				InitVarCom()
				marchivo := getdfp()+mtmpDBF
				delete file (marchivo)
				exit
				
			case mopciones == 2
				replace all factura with FACTURA->factura 
				replace all prestador with mprestador
				replace all mandataria with mmandataria
				replace all afiliado with mafiliado
				replace all serie with 	mserie
				replace all numero with mreceta
				go top

				do while !eof()
					select (mtmpAREA)
					if DEBITO > 0
						mmotdeb := MOTDEB
                                                grabadebito2(DEBITO)
					endif
					select (mtmpAREA)
					skip			
				enddo
				select (mtmpAREA)
				go top
				sum DEBITO to mtotdeb
				sum TOTAL to mtotdiba
			   mapagar := mtotdiba - mtotdeb - mDiferencia
				mtotdeb := mapagar
				popread(.f.,"Ingrese monto a debitar: ",@mtotdeb,"99999.99")

				if lastkey() == K_ESC
					loop
				endif
			   mapagar := mtotdiba - mtotdeb - mDiferencia
                                mmotdeb := debito2()

				if lastkey() == K_ESC .or. mmotdeb = space( 3 )
					loop
				endif
				use
                                grabacabrec2()
                                grabarenrec2()
                                grabadebito2(mtotdeb)

 				if mDiferencia > 0.00
					mmotdeb := "070"
                                        grabadebito2(mDiferencia)
				endif
			
				replace all factura with FACTURA->factura 
				replace all prestador with mprestador
				replace all mandataria with mmandataria
				replace all serie with 	mserie
				replace all numero with mreceta
				go top
				* -------------------
				marchivo := getdfp()+mtmpDBF
				delete file (marchivo)
				exit
		
			case mopciones == 3
				replace all factura with FACTURA->factura 
				replace all prestador with mprestador
				replace all serie with 	mserie
				replace all mandataria with mmandataria
				replace all afiliado with mafiliado
				replace all numero with mreceta
				go top
				mReingresa := .t.
				exit				
			endcase
		enddo
	enddo
   GrabaMandataria()
enddo
if type("mtmpDBF") != "U"
	marchivo := getdfp() + mtmpDBF
	if file(marchivo)
		select (mtmpAREA)
		if used()
			use
		endif
		delete file (marchivo)
	endif
endif
unbox(m->mtmp)
set decimal to
set fixed off

return

* --------------------------
static function grabacabrec2
* --------------------------
select PRACTICA
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace TIPOPRACT with mtipopract
		replace SERIEINT with mserieint
		replace NUMEROINT with mnumeroint
		replace COMIENZO with ctod( cComienzo )
		replace FINAL    with ctod( cFinal ) 
		replace SERIE with mserie
		replace numero with mreceta
		replace AFILIADO with mafiliado
		replace EDAD with int(  ( date() - ctod( stretch( AFILIADO->BAFNAC , "/" , 2 ) ) ) / 365.25 )
		replace DIAGNOSTIC with cDiagnostic
		replace COMPLICACI with cComplicaci
		replace COMPLEJO with cComplejo
		replace FECHA with ctod( var2char( MFECHAPRES ) )
		replace TOTDIBA with mtotdiba
		replace MATRICULA with mmatricula
		replace MANDATARIA with mmandataria
		replace FACTURA with FACTURA->factura 
		replace PRESTADOR with FACTURA->PRESTADOR
		replace CONCEPTO  with FACTURA->CONCEPTO
		replace CODPOSTAL with FACTURA->CODPOSTAL
		replace PROVINCIA with PRESTA->PRPCIA
		replace CATEGORIZ with mcategoriz
		replace ARANCEL   with marancel
		replace TOTFACTU  with mtotal
		replace DEBITO with mtotdeb
		replace TOTAPAG with mapagar
		replace MOTIVO with if( type("mmotivo") = "U" , space(3) , mmotivo )
		replace FECHING with date()
		unlock
	endif
endif
select FACTURA
if srec_lock( 5 , .f. )
	replace TOTAPAG with TOTAPAG + mapagar
	replace TOTDEB with TOTDEB + mtotdeb
	unlock
endif
return NIL

* --------------------------
static function grabadebito2
* --------------------------
parameters xmdebito,cNomenclado
select DEBITOS
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace REGIONAL with "5000"
		replace SERIE with mserie
		replace RECETA with mreceta
		replace FPRES with FACTURA->FPRES
		replace MANDATARIA with mmandataria
		replace FACTURA with FACTURA->FACTURA
		replace PRESTADOR with FACTURA->PRESTADOR
		replace CONCEP with FACTURA->CONCEPTO
		replace IMPDEB with xmdebito
		replace MOTIV with mmotdeb
		replace PRACTICA with if( type("cNomenclado") = "U" , space( len(PRACTICA) ) , cNomenclado ) 
		replace FECHING with date()
		unlock
	endif
endif

return NIL

*---------------------------
static function grabarenrec2
*---------------------------
select PRACRENG
if sfil_lock(5,.t.,"No se puede bloquear Renglones - ¨Reintenta?")
	append from &mtmpDBF
	unlock
endif
return NIL

*---------------------
static function debito2
*---------------------
private mpandeb,mtipo,mop
m->mpandeb := makebox(09,23,23,55,c_popcol)
@ 10,36 say " DEBITOS "
@ 11,26 prompt  " 1.FALTA FIRMA PROFESIONAL "
@ 12,26 prompt  " 2.FALTA FIRMA AFILIADO    "
@ 13,26 prompt  " 3.FALTA DE FECHAS         "
@ 14,26 prompt  " 4.SELLO FALTA/ILEGIBLE    "
@ 15,26 prompt  " 5.TEXTO INCOMP/ILEGIBLE   "
@ 16,26 prompt  " 6.COMPROBANTE NO OFICIAL  "
@ 17,26 prompt  " 7.DIFER. DE LETRA O TINTA "
@ 18,26 prompt  " 8.CANT. ENVASES INCORRECTA"
@ 19,26 prompt  " 9.DATOS ADULTERADOS       "
@ 19,26 prompt  " A.PRACTICA FUERA NOMENC.  "
@ 20,26 prompt  " B.FALTA DE TROQUEL        "
@ 21,26 prompt  " C.FECHA VENCIDA > 15 DIAS "
@ 22,26 prompt  " Esc.SALIR                 "

menu to mop
unbox(mpandeb)
if lastkey() == K_ESC
    return NIL
endif
            
mtipo := right( "000" + alltrim( str( 7 + mop ) ) , 3)
return mtipo

* ------------------
  procedure CambHono
* ------------------
parameters p1 , p2 , p3
local GetList := {}
set cursor on

@ 3,13 get mcategoriz pict "999.99"
@ 4,13 get marancel   pict "999.99"
read
return

* ---------------------
  procedure EditDebito
* ---------------------
parameters p1 , p2 , p3
local GetList := {}
set cursor on
mtotdeb = 0.00
nArea := select()
select FACTURA
msg( "Ingrese el motivo del d‚bito",;
     "Luego el monto a debitar",;
	  "ATENCION: Esta funci¢n se puede hacer una sola vez",;
	  "          por boleta" )
if messyn("¨Contin£a con el d‚bito?")

	editmemo( "DEBITOS" )
	cTmp := makebox( 10 , 4 , 14 , 40 )
	@ 12 , 6 say "Ingrese monto a debitar:" get mtotdeb pict "99999.99" 
	read
	unbox( cTmp )
	if messyn( "¨Graba el d‚bito?" )
		mmotdeb := "999"
                grabadebito2( mtotdeb )
	endif
endif

select (nArea)
return NIL

* --------------------------
	function InitVarCom()
* --------------------------

mapagar    := 0.00
mserie     := space( 2 )
mreceta    := space( 6 )
mtotdiba := 0.00
mtotdeb := 0.00
mmotdeb = space( 3 )
mafiliado := space( 9 )
if len( mmatricula ) < 7 
	mmatricula := space(7)
endif

return NIL


* ----------------------------
function InitVarMan()
* ----------------------------

mmandataria := space( 6 )
mcategoriz := 0.00
marancel   := 0.00
mapagar    := 0.00
mserie     := space( 2 )
mreceta    := space( 6 )
mtotdiba := 0.00
mtotdeb := 0.00
mmotdeb = space( 3 )
mafiliado := space( 9 )
if len(mmatricula) < 7
	mmatricula := space( 7 )
endif
mfechapres := space( 8 )

return NIL

* ------------------------------------
function GrabaMandataria()
* ------------------------------------
* Grabaci¢n del total de la mandataria
* ------------------------------------
nArea := select()
nDebito := 0
set exact off
select PRACTICA
set order to tag PRACMAND
skip 0
* set filter to FACTURA->PRESTADOR + mmandataria +  FACTURA->factura = (PRESTADOR + MANDATARIA + FACTURA)
seek FACTURA->PRESTADOR + mmandataria +  FACTURA->factura
nTotMand := 0.00
nTotFactu := 0.00
while FACTURA->PRESTADOR + mmandataria + FACTURA->factura = PRESTADOR + MANDATARIA + FACTURA
	* sum TOTDIBA, TOTFACTU to nTotMand, nTotFactu
	nTotMand := nTotMand + TOTDIBA
	nTotFactu := nTotFactu + TOTFACTU
	skip
end
set order to tag PRACTICA
nTotMand1 := nTotFactu

popread( .f. , "Total Facturado Mandataria:" , @nTotFactu , "999999.99")

		
if nTotFactu > nTotMand1
	nDebito := nTotFactu - nTotMand1
	while .t.
		popread( .t. , "D‚bito a la mandataria:" , @nDebito , "999999.99" )
		if messyn("¨Correcto?")
			exit
		endif
	end
endif

if nDebito > 0
	mmotdeb := "090"
        grabadebito2( nDebito )
endif
select( nArea )
InitVarMan()
set filter to

return NIL

* --------------------------
procedure ModNomenc
* --------------------------
parameters p1 , p2 , p3
local getlist := {} , nOpcion , nArea , cPantalla
nArea := select()
select NOMENCLA
cCodi := CODI
cDesc := DESC
nHono := HONO
nGast := GAST
nNpor := NPOR
cCOBE := COBE
cLETR := LETR

nOpcion := menu_V("NOMENCLADOR:","1. Agregar  ",;
                                "2. Modificar",;
										  "0. Salir    " )
										  
cPantalla := makebox(10,4,30,40)
@ 11,6 say " *NOMENCLADOR* "
do case
	case nOpcion == 1
	CaptNomenc()
	if messyn("¨Graba?")
		if sadd_rec( 5 , .f. )
			if srec_lock( 5 , .f. )
				GrabaNomenc()
			endif
		endif
	endif
	case nOpcion == 2
	CaptNomenc()
	if messyn("¨Graba?")
		if srec_lock( 5, .f. )
			GrabaNomenc()
		endif
	endif
	case nOpcion == 0
endcase
unbox( cPantalla )
select ( nArea )
return NIL

* ---------------------------------
function GrabaNomenc()
* ---------------------------------
replace CODI with cCodi
replace DESC with cDESC
replace HONO with nHono
replace GAST with nGast
replace NPOR with nnPor
replace COBE with cCobe
replace LETR with cLetr
return NIL

* -----------------------------------
function CaptNomenc()
* -----------------------------------
local getlist := {}

@ 13,6 say "C¢digo:     " get cCodi
@ 14,6 say "Descripci¢n:" get cDesc pict "@S20"
@ 15,6 say "Honorarios :" get nHono pict "99999.99"
@ 16,6 say "Gastos     :" get nGast pict "99999.99"
@ 17,6 say "Letra      :" get cLetr pict "!"
read

return NIL

* ------------------------------------------------------------
  static Function AplicaTeclaPractica( nTecla )
* ------------------------------------------------------------
    DO CASE
	 CASE nTecla == K_F5
	 	do CambHono
	 CASE nTecla == K_F9
	 	do EditDebito 
	 CASE nTecla == K_F11
	 	do ModNomenc
    CASE nTecla == K_DOWN
        oTBRenglon:down()

    CASE nTecla == K_PGDN
        oTBRenglon:pageDown()

    CASE nTecla == K_CTRL_PGDN
        oTBRenglon:goBottom()

    CASE nTecla == K_UP
        oTBRenglon:up()

    CASE nTecla == K_PGUP
        oTBRenglon:pageUp()

    CASE nTecla == K_CTRL_PGUP
        oTBRenglon:goTop()

    CASE nTecla == K_RIGHT
        oTBRenglon:right()

    CASE nTecla == K_LEFT
        oTBRenglon:left()

    CASE nTecla == K_HOME
        oTBRenglon:home()

    CASE nTecla == K_END
        oTBRenglon:end()

    CASE nTecla == K_CTRL_LEFT
        oTBRenglon:panLeft()

    CASE nTecla == K_CTRL_RIGHT
        oTBRenglon:panRight()

    CASE nTecla == K_CTRL_HOME
        oTBRenglon:panHome()

    CASE nTecla == K_CTRL_END
        oTBRenglon:panEnd()
	 CASE nTecla == K_DEL
	 	  delete
		  pack
		  oTBRenglon:ForceStable()

    CASE nTecla == K_RETURN
        editaPractica()
	 CASE nTecla == K_INS
			append blank
                        editaPractica()
    OTHERWISE
                        editaPractica()
    ENDCASE

return NIL

* ------------------------
static function editaPractica()
* ------------------------
nCantidad := CANTIDAD
cNomenclado := NOMENCLADO

nPU      := CalcNomen( nomencla->codi )
nTotal   := CANTIDAD * nPU
nDIBA    := nTotal

nArea := select()
select 27
if snet_use( cNomenclador , "NOMPRAC", .f. , 5 , .F. )
   set order to tag NOMEDESC
else
   msg("No se puede abrir el nomenclador para buscar con F2")
endif
select (nArea)

cArchivo := "%" + cNomenclador + "%NOMEDESC"
smallkset( K_F2 , "EDITAPRACTICA" , "CNOMENCLADO" , 'CODI+" "+DESC',"Pr cticas", 27  , 'CODI' )
cIngreso := makebox( 9, 20 , 16 , 60 )
@ 10,21 say "Cantidad: " get nCantidad pict "99" valid genval( "nCantidad > 0" , "La cantidad debe ser mayor que cero" )
@ 11,21 say "Pr ct   : " get cNomenclado pict "!999999" valid CapNomen( cNomenclado )
@ 11,44 say "<F2> Buscar"
read
nPU      := CalcNomen( nomencla->codi )
nTotal := nPU * nCantidad
nDIBA  := nTotal 

@ 13,21 say "P.U.           :" get nPU pict "9999.99"
@ 14,21 say "Total Facturado:" get nTotal pict "99999.99"
read
nDebRen := 0
if nTotal > nDIBA 
	nDebRen := nTotal - nDIBA
	msg("Graba un d‚bito de $" + ltrim(str( nDebRen ) ) )
	replace DEBITO with nDebRen
	replace MOTDEB with "091"
	nDiba := nTotal - nDebRen
endif

replace NOMENCLADO with cNomenclado
replace CANTIDAD with nCantidad
replace UNITARIO with nPU
replace TOTAL    with cantidad * unitario
replace totfactu with nTotal
replace TOTAPAG     with nDIBA

if nDebRen == 0
	replace DEBITO with 0.00
	replace MOTDEB with space(3)
endif

smallkclr()

unbox( cIngreso )
return NIL

********************************
function CAPNOMEN

   local Local1
   parameters mnomen
   Local1:= {}
   private marea, mdebito, mmotdeb, mtmp
   initsup()
   marea:= Select()
   select NOMENCLA
   seek mnomen
   if (Found())
      select (marea)
      return .T.
   else
      msg("El c¢digo de nomenclador no ha sido encontrado")
      if (messyn("Tiene dos opciones:", "Debita el c¢digo", ;
            "Vuelve a Ingresarlo"))
         mdebito:= 0.00
         mtmp:= makebox(15, 10, 19, 48, sls_popcol() )
         @ 17, 11 say "Ingrese Monto a Debitar"
         SetPos(Row(), Col() + 1)
         AAdd(Local1, __Get(Nil, "mdebito", "999999.99", Nil, Nil))
         ReadModal(Local1)
         Local1:= {}
         unbox(mtmp)
         mmotdeb:= "081"
         select (marea)
         replace debito with mdebito
         replace motdeb with mmotdeb
         return .T.
      else
         select (marea)
         return .F.
      endif
   endif

********************************
function CALCNOMEN(Arg1)

   local Local1
   narea:= Select()
   select UARA
   goto bottom
   Local1:= 0
   do case
   case nomencla->letr = "A" .OR. nomencla->letr = "B"
      Local1:= qgale * nomencla->hono * mcategoriz / 100 + sagq * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "C"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + saog * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "D"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + gara * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "E"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + sagc * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "F"
      Local1:= gale * nomencla->hono * mcategoriz / 100
   case nomencla->letr = "G"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + sagp * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "H"
      Local1:= hobi * nomencla->hono * mcategoriz / 100 + gabi * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "I"
      Local1:= sagc * nomencla->gast * marancel / 100
   case nomencla->letr = "J"
      Local1:= hodo * nomencla->hono * mcategoriz / 100
   case nomencla->letr = "K"
      Local1:= hodo * nomencla->hono * mcategoriz / 100 + gaop * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "L"
      Local1:= hodo * nomencla->hono * mcategoriz / 100 + sagc * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "M"
      Local1:= hodo * nomencla->hono * mcategoriz / 100 + gara * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "N"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + gabi * ;
         nomencla->gast * marancel / 100
   endcase
   select (narea)
   return Local1

********************************
