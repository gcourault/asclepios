/* ----------------------------------------------------
   audfarm.prg
	programa que audita farmacias (c¢digo 20)
---------------------------------------------------- */
#include "inkey.ch"
#define MAXREM 3

* ------------------
  function audfarm()
* ------------------
local mtmp
initsup()
set delete on

select 7
if snet_use("DEB001","DEBITOS",.F.,5,.T.,"No se puede abrir archivo de d‚bitos - ¨Reintenta?")
	set order to tag DEB001
else
	msg("No se puede abrir archivo de debitos",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 6
if snet_use("IN1PRES","PRESTADOR",.F.,5,.T.,"No se puede abrir archivo de PRESTADORES - ¨Reintenta?")
	set order to tag PRCOD
else
	msg("No se puede abrir archivo de prestadores",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 2
if snet_use("CABREC","CABREC",.F.,5,.T.,"No se puede abrir archivo de CABECERA - ¨Reintenta?")
	set order to tag CABREC
else
	msg("No se puede abrir archivo de recetas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 3
if snet_use("RENREC","RENREC",.F.,5,.T.,"No se puede abrir archivo de recetas - ¨Reintenta?")
	set order to tag RENREC
else
	msg("No se puede abrir archivo de recetas",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 4
if snet_use("MEDI","MEDICAME",.F.,5,.T.,"No se puede abrir el archivo de medicamentos - ¨Reintenta?")
	set order to tag metroq
else
	msg("No se puede abrir archivo de medicamentos",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif


select 5
if snet_use("BASEAFIL","AFILIADO",.F.,5,.T.,"No se puede abrir el archivo de afiliados - ¨Reintenta?")
	set order to tag AFINUM
else
	msg("No se puede abrir archivo de afiliados",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

select 8
if snet_use("ORDAFIL","ORDENES",.F.,5,.T.,"No se puede abrir archivo de Ordenes-Afiliados ¨Reintenta?")
	set order to tag ORDAFIL
else
	msg("No se puede abrir archivo de Ordenes",;
	    "Reintente luego")
	return
endif

m->mtmp := makebox(0,1,22,76,c_normcol)
@ 4,2 to 4,75
@ 9,2 to 9,75
@ 18,2 to 18,75
@ 0, 7 say "* <ESC> Cancela    -    <F2> Buscar Afiliado *"

mmandataria := space( 5 )
mmotivo    := space( 3 )
mdescuento := 60
mapagar    := 0.00
mserie     := space(2)
mreceta    := space(6)
mtotdiba := 0.00
mtotdeb := 0.00
mmotdeb = space(3)
mafiliado := space(9)
mfechaemi := space(10)
mmatricula := space(7)
mfechapres := space(10)
mReingresa := .f.

do while .t.
	@ 1,2  say "FACTURA:" + FACTURA->FACTURA
	@ 1,32 say "PRESTADOR:" + busca("6",FACTURA->PRESTADOR,"PRNOMB")
	
	@ 2,2 say "Mandataria:" get mmandataria pict "99999" valid genval( "!empty(mmandataria)" , "Ingrese N§ de mandataria" )
	@ 2,32 say "Facturado:"
	@ 2,44 say FACTURA->TOTFACTU pict "99999.99"
	@ 2,57 say "A pagar:"
	@ 2,66 say FACTURA->TOTAPAG pict "999999.99"

	if FACTURA->TOTAPAG >= FACTURA->TOTFACTU
		msg( "El monto a Pagar es mayor que el facturado" )
	endif

	@ 3,2 say "Descuento:     %            Serie:        N£mero:"
	@ 3,13 get mdescuento pict "999.99"
	@ 3,36 get mserie pict "!!" valid genval("!empty(mserie)","Ingrese la Serie")
	@ 3,52 get mreceta pict "999999" valid ;
		       dup_chk(FACTURA->PRESTADOR+FACTURA->FACTURA+mserie+mreceta,2)
   read
	smallkset( K_F2 , "AUDFARM" , "mafiliado" ,;
	                  "BANUME + BAORDE + ' ' + BAAPEL",;
							"Afiliados",;
							"%BASEAFIL%AFINOMB",;
							"BANUME+BAORDE")	
							
	
	@ 5,7 say "Nro. de Afiliado.:                   Fecha de Emisi¢n.....:"
	@ 7,7 say "Nro. de Matr¡cula:                   Fecha de Presentaci¢n:"
	
	@ 5,26 get mafiliado pict "999999999" valid genval("!empty(mafiliado)","Ingrese N§ de afiliado")
	@ 5,67 get mfechaemi pict "@D" valid genval("!empty(mfechaemi)","Ingrese fecha emisi¢n")
	@ 7,26 get mmatricula pict "@!" valid genval("!empty(mmatricula)","Ingrese la matr¡cula")
	@ 7,67 get mfechapres pict "@D" valid genval("!empty(mfechapres)","Ingrese fecha de presentaci¢n")
	set key K_F2 to scroller
	set key K_ALT_F2 to scmod
	read
	if abort()
		if messyn("ATENCION: ESTO CANCELARA EL INGRESO DE LA RECETA","Si Cancela","No Cancela")
			exit
		endif
	endif	

	*--
	* Control de la Fecha
	*--
	
	if (ctod(mfechapres) - ctod(mfechaemi)) > 15
		msg("La fecha de Presentaci¢n excede m s de 15 d¡as",;
		    "de la emisi¢n")
	   mopciones := menu_v("EXCEDIDA LA FECHA DE PRESENTACION",;
		                    "1. Debita y Graba la Receta      ",;
								  "2. Sigue sin debitar             ",;
								  "3. Reingresa Datos               ")
		do case
		case mopciones == 1
			mtotdeb := 0.00
			mmotdeb := "007"
			popread(.f.,"Ingrese Monto a debitar",@mtotdeb,"999999.99")				
			mensaje := "Debitar  $ " + alltrim(str(mtotdeb,10,2))
			if messyn(mensaje,"Graba Factura y D‚bito","No graba")
				grabacabrec()
				grabadebito( mtotdeb )
				mafiliado := space(9)
				mfechaemi := space(10)
				mmatricula := space(7)
				mfechapres := space(10)
				mdescuento := 60
				mapagar    := 0.00
				mserie     := space(2)
				mreceta    := 0
				mmandataria := space( 5 )
				mtotdiba := 0.00
				mtotdeb := 0.00
				mmotdeb = space(3)
				loop
			else
				mafiliado := space(9)
				mfechaemi := space(10)
				mmatricula := space(7)
				mfechapres := space(10)
				mdescuento := 60
				mapagar    := 0.00
				mserie     := space(2)	
				mreceta    := 0
				mmandataria := space( 5 )
				mtotdiba := 0.00
				mtotdeb := 0.00
				mmotdeb = space(3)
				loop
			endif
			case mopciones == 2
			/* nada */
			case mopciones == 3
			loop
		endcase
	endif
   *--
	* Control del afiliado
	*--
	select 5
	seek mafiliado
	if .not. found()
		mopciones := menu_v("ERROR EN EL N§ DEL AFILIADO  ",;
		                    "1. Graba y Debita Receta     ",;
								  "2. Sigue sin grabar d‚bito   ",;
								  "3. Reingresa Datos           ")
		do case
		case mopciones == 1
			mtotdeb := 0.00
			mmotdeb := "002"
			popread(.f.,"Ingrese Monto a debitar",@mtotdeb,"999999.99")				
			mensaje := "Debitar  $" + alltrim(str(mtotdeb,10,2))
			if messyn(mensaje,"Graba Factura y D‚bito","No graba")
				grabacabrec()
				grabadebito(mtotdeb)
			endif
			mafiliado := space(9)
			mfechaemi := space(10)
			mmatricula := space(7)
			mfechapres := space(10)
			mdescuento := 60
			mapagar    := 0.00
			mserie     := space(2)
			mreceta    := 0
			mmandataria := space( 5 )
			mtotdiba := 0.00
			mtotdeb := 0.00
			mmotdeb = space(3)
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

	select RENREC
	/* -----------------------------------
	   ingreso de renglones
		----------------------------------- */
	if !mReingresa	
		mtmpDBF := uniqfname("DBF","")
		copy stru to (mtmpDBF)
		marea := select()
		select 0
		use (mtmpDBF) exclusive alias tempo
		mtmpAREA := select()
	else
		select (mtmpAREA)
		mReingresa := .f.
	endif
	
	set relation to tempo->TROQUEL into MEDICAME

	m->mtmp1 := makebox(9,2,18,74)
	m->mest := makebox(21,2,23,74)
	@ 22,28 say "<INS> Agrega ³ <DEL> Borra ³ <ENTER> Modifica"

	* ------------------------------------------------------------------
	oTBRenglon := TBrowseDB( 10 , 3 , 17 , 73 )
	oTBRenglon:headSep := "ÍÑÍ"
	oTBRenglon:colSep  := " ³ "
	oTBRenglon:addColumn( TBColumnNew( "Cant." , { || CANTIDAD } ) )
	oTBRenglon:addColumn( TBColumnNew( "N§ Troquel" , { || TROQUEL } ) )
	oTBRenglon:addColumn( TBColumnNew( "Medicamento" , { || MEDICAME->NOMBRE } ) )
	oTBRenglon:addColumn( TBColumnNew( "Presentaci¢n" , { || MEDICAME->PRESENTAC } ) )
	oTBRenglon:addColumn( TBColumnNew( "P.U." , { || UNITARIO } ) )
	oTBRenglon:addColumn( TBColumnNew( "Total" , { || TOTAL } ) )
	oTBRenglon:addColumn( TBColumnNew( "D‚bito" , {|| DEBITO } ) )
	oTBRenglon:addColumn( TBColumnNew( "A Cargo DIBA" , { || DIBA } ) )
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
			ApplyKey( nTecla )			
		endif
		nReg := recno()
		sum DIBA to mTotDIBA
		@ 22, 4 say "Total: "
		@ 22,13 say mTotDIBA		
		go nReg
		oTBRenglon:ForceStable()
	end
	* ------------------------------------------------------------------
	
	unbox(m->mtmp1)
	unbox(m->mest)
	sum DIBA,DEBITO to mTotal1, mDebito
	mTotal := mTotal1 + mDebito
	mTotal1 := mTotal
	mDiferencia := 0.00
	mtmp2 := makebox( 10,3,14,73,sls_popcol() )
	while .t.
		@ 12,4 say "Ingrese Total de la Receta" ;
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
			mmensaje := "¨Le debita a esta receta $"+alltrim(str(mDiferencia,8,2))
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
		                    "1. Grabar Receta              ",;
								  "2. Debitar la Receta          ",;
								  "3. Reingresar los datos       ")
		do case
		case mopciones == 1
			replace all factura with FACTURA->factura
			replace all prestador with mprestador
			replace all afiliado with mafiliado
			replace all serie with 	mserie
			replace all receta with padl( alltrim(mreceta) , 6 , "0" )
			replace all feching with date()
			go top
			do while !eof()
				select (mtmpAREA)
				if (DEBITO > 0)
					mmotdeb := MOTIVO
					grabadebito( DEBITO , TROQUEL )
				endif
				select (mtmpAREA)
				skip			
			enddo
			if mDiferencia > 0.00
				mmotdeb := "070"
				grabadebito( mDiferencia )
			endif
			
			select (mtmpAREA)
			go top
			sum DEBITO to mtotdeb
			sum DIBA to mtotdiba
		   mapagar := mtotdiba - mtotdeb - mDiferencia
			use
			grabacabrec()
			grabarenrec()
			grabaFactur( mapagar , mtotdeb + mDiferencia )
			* -----------------
			mdescuento := 60
			mapagar    := 0.00
			mserie     := space(2)
			mreceta    := space(6)
			mtotdiba := 0.00
			mtotdeb := 0.00
			mmotdeb = space(3)	
			mafiliado := space(9)
			mfechaemi := space(10)
			mmatricula := space(7)
			mfechapres := space(10)
			marchivo := getdfp()+mtmpDBF
			delete file &marchivo
			exit
	
		case mopciones == 2
			replace all factura with FACTURA->factura
			replace all prestador with mprestador
			replace all afiliado with mafiliado
			replace all serie with 	mserie
			replace all receta with mreceta
			replace all feching with date()
			go top
			do while !eof()
				select (mtmpAREA)
				if DEBITO > 0
					mmotdeb := MOTIVO
					grabadebito(DEBITO)
				endif
				select (mtmpAREA)
				skip			
			enddo
			select (mtmpAREA)
			go top
			sum DEBITO to mtotdeb
			sum DIBA to mtotdiba
		   mapagar := mtotdiba - mtotdeb - mDiferencia
			mtotdeb := mapagar
			popread(.f.,"Ingrese monto a debitar: ",@mtotdeb,"99999.99")

			if lastkey() == K_ESC
				loop
			endif
		   mapagar := mtotdiba - mtotdeb - mDiferencia
			mmotdeb := debito()

			if lastkey() == K_ESC
				loop
			endif
			use
			grabacabrec()
			grabarenrec()
			grabadebito( mtotdeb )
			grabaFactur( mapagar , mtotdeb + mDiferencia )
			
			if mDiferencia > 0.00
				mmotdeb := "070"
				grabadebito(mDiferencia)
			endif
			
			mdescuento := 60
			mapagar    := 0.00
			mserie     := space(2)
			mreceta    := 0
			mtotdiba := 0.00
			mtotdeb := 0.00
			mmotdeb = space(3)
			mafiliado := space(9)
			mfechaemi := space(10)
			mmatricula := space(7)
			mfechapres := space(10)
			* -------------------
			marchivo := getdfp()+mtmpDBF
			delete file &marchivo
			exit
		
		case mopciones == 3
			replace all factura with FACTURA->factura
			replace all prestador with mprestador
			replace all afiliado with mafiliado
			replace all serie with 	mserie
			replace all receta with mreceta
			replace all feching with date()
			mReingresa := .t.
			exit				
		endcase
	enddo
enddo
if type("mtmpDBF") != "U"
	marchivo := getdfp()+mtmpDBF
	if file(marchivo)
		select (mtmpAREA)
		if used()
			use
		endif
		delete file &marchivo
	endif
endif
unbox(m->mtmp)
return

* ------------------
function grabacabrec
* ------------------
select CABREC
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace REGIONAL with "5000"
		replace MOTIVO with mmotivo
		replace SERIE with mserie
		replace RECETA with pad( alltrim(mreceta) , 6 , "0" )
		replace AFILIADO with mafiliado
		replace FECHAEMI with ctod(mfechaemi)
		replace FECHARECE with ctod(mfechapres)
		replace TOTDIBA with mtotdiba
		replace MATRICULA with mmatricula
		replace FECHACARGA with date()
		replace MANDATARIA with mmandataria
		replace FACTURA with FACTURA->FACTURA
		replace PRESTADOR with FACTURA->PRESTADOR
		replace PORCIENTO with mdescuento
		replace TOTDIBA with mtotdiba
		replace TOTDEB with mtotdeb
		replace APAGAR with mapagar
		replace FECHING with date()
		unlock
	endif
endif
return NIL

* ------------------
function grabadebito
* ------------------
parameters xmdebito,cTroquel
select DEBITOS
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace REGIONAL with "5000"
		replace SERIE with mserie
		replace RECETA with mreceta
		replace TROQUEL with iif( type("cTroquel") == "U" , space(7) , cTroquel )
		replace FPRES with FACTURA->FPRES
		replace MANDATARIA with mmandataria
		replace FACTURA with FACTURA->FACTURA
		replace PRESTADOR with FACTURA->PRESTADOR
		replace CONCEP with FACTURA->CONCEPTO
		replace DESC with mdescuento
		replace IMPDEB with xmdebito
		replace MOTIV with mmotdeb
		replace FECHING with date()
		unlock
	endif
endif

* -----------------------------------------
  function GrabaFactur( xAPagar , xTotDeb )
* -----------------------------------------
select FACTURA
if srec_lock( 5 , .f. )
	replace TOTDEB with TOTDEB + xTotDeb
	replace TOTAPAG with TOTAPAG + xAPagar
	replace BOLAPAG with BOLAPAG + 1
	unlock
endif
return NIL

*-------------------
function grabarenrec
*-------------------
select RENREC
if sfil_lock(5,.t.,"No se puede bloquear Renglones - ¨Reintenta?")
	append from &mtmpDBF
	unlock
endif
return NIL

*---------------------
function debito
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
@ 19,26 prompt  " A.TROQUEL FUERA VADEM.    "
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

* ----------------------------------------
  function buscaenorden( cClave )
* ----------------------------------------
// funcion que permite buscar a los afiliados en las ordenes
// si existe

local nArea
nArea := select()
select ORDENES
seek cClave
if found()
	select ( nArea )
	@ 6,7 say busca('select("AFILIADO")',ORDENES->AFILIADO,"BAAPEL")
	return ORDENES->AFILIADO
else
	select ( nArea )
	return SPACE(9)
endif

* ------------------------------------------------------------
  static Function ApplyKey( nTecla )
* ------------------------------------------------------------
    DO CASE
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
        edicion()
	 CASE nTecla == K_INS
			append blank
			edicion()
    OTHERWISE
			edicion()
    ENDCASE

return NIL

static function edicion()
nCantidad := CANTIDAD
cTroquel := TROQUEL
nPU      := UNITARIO
nTotal   := CANTIDAD * nPU

smallkset( K_F2 , "EDICION" , "cTroquel" , 'TROQUEL+" "+NOMBRE+" "+PRESENTAC',"Medicamentos", "%MEDI%MENOMBRE" , 'TROQUEL' )
cIngreso := makebox( 9, 20 , 16 , 60 )
@ 10,21 say "Cantidad:" get nCantidad pict "9" valid genval( "nCantidad > 0" , "La cantidad debe ser mayor que cero" )
@ 11,21 say "Troquel: " get cTroquel pict "@9" valid CaptTroquel( cTroquel )
@ 11,44 say "<F2> Buscar"
read

nPU := nPUReal := MEDICAME->VTAPUB/100
nTotal := nTotalReal := nPU * nCantidad
nDIBA  := nDIBAReal := nTotal * mdescuento /100

@ 13,21 say "P.U. :" get nPU pict "9999.99"
@ 14,21 say "Total:" get nTotal pict "99999.99"
@ 15,21 say "a Cargo DIBA:" get nDIBA pict "99999.99"
read

nDebRen := 0
if nDIBA > nDIBAReal
	nDebRen := nDIBA - nDIBAReal 
	msg("Graba un d‚bito de $" + trim(str( nDebRen )))
	replace DEBITO with nDebRen
	replace MOTIVO with "043"
endif

if nDebRen == 0
	replace DEBITO with nDebRen
	replace MOTIVO with space(3)
endif

replace TROQUEL with cTroquel
replace CANTIDAD with nCantidad
replace UNITARIO with nPU
replace TOTAL    with nTotal
replace DIBA     with min( nDIBAReal, nDIBA )
smallkclr()

unbox( cIngreso )
return NIL

* ---------------------------------------------------------------
function CaptTroquel

   local Local1
   parameters mtroquel
   Local1:= {}
   private marea, mdebito, mmotdeb, mtmp
   initsup()
   marea:= Select()
   select MEDICAME
   seek mtroquel
   if Found()
      select (marea)
		return .T.
   else
      msg("El troquel no ha sido encontrado")
      if (messyn("Tiene dos opciones:", "Debita el Troquel", ;
            "Vuelve a Ingresarlo"))
         mdebito:= 0.00
         mtmp:= makebox(15, 10, 19, 48, c_popcol)
         @ 17, 11 say "Ingrese Monto a Debitar"
         SetPos(Row(), Col() + 1)
         AAdd(Local1, __Get(Nil, "mdebito", "999999.99", Nil, Nil))
         ReadModal(Local1)
         Local1:= {}
         unbox(mtmp)
         mmotdeb:= "042"
         select (marea)
         replace debito with mdebito
         replace motivo with mmotdeb
			set order to tag MENOMBRE
         return .T.
      else
         select (marea)
         return .F.
      endif
   endif
********************************
