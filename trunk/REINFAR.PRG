/* 
----------------------------------------------------
   reinfarm.prg
	programa que hace reintegros (c¢digo 20)
----------------------------------------------------
*/
function reinfar()
#include "inkey.ch"
#define MAXREM 5
#include "regional.ch"
local mtmp
initsup()
set delete on
set key K_F2 to scroller
set key K_ALT_F2 to scmod

select 8
if snet_use("MOTIVOS","MOTIVOS",.F.,5,.T.,"No se puede abrir archivo de MOTIVOS - ¨Reintenta?")
	set index to MOTIVOS
else
	msg("No se puede abrir archivo de MOTIVOS",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

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
	msg("No se puede abrir archivo de proveedores",;
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
	msg("No se puede abrir archivo de recetas",;
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


m->mtmp := makebox(0,1,22,76,sls_normcol() )
@ 4,2 to 4,75
@ 9,2 to 9,75
@ 18,2 to 18,75
@ 0, 7 say "* <ESC> Cancela    -    <F2> Buscar Afiliado *"

mmandataria := space(5)
mdescuento := 60.00
mapagar    := 0.00
mserie     := "RE"
mreceta    := space(6)
mtotdiba := 0.00
mtotdeb := 0.00
mmotdeb = space(3)
mafiliado := space(9)
mfechaemi := space(10)
mmatricula := space(7)
mfechapres := space(10)
mReingresa := .f.
mmotivo = space( 3 )

do while .t.
	@ 1,2  say "FACTURA: " + FACTURA->FACTURA
	@ 1,32 say "PRESTADOR: " + busca("6",FACTURA->PRESTADOR,"PRNOMB")
	
	@ 2,32 say "Facturado:"
	@ 2,44 say FACTURA->TOTFACTU pict "99999.99"
	@ 2,57 say "A pagar:"
	@ 2,66 say FACTURA->TOTAPAG pict "999999.99"
	@ 3,2 say "Descuento:     %                          N£mero:"
	@ 3,13 get mdescuento pict "999.99"
	@ 3,52 get mreceta pict "999999" valid ;
		       dup_chk(FACTURA->PRESTADOR+FACTURA->FACTURA+mserie+mreceta,2)
   read
	
	
	@ 5,7 say "Nro. de Afiliado.:                   N§ Motivo:"
	@ 7,7 say "Nro. de Matr¡cula:                   Fecha de Presentaci¢n:"
	
	@ 5,26 get mafiliado pict "999999999" valid genval("!empty(mafiliado)","Ingrese N§ de afiliado")
	@ 5,60 get mmotivo
	@ 7,26 get mmatricula pict "@!" valid genval("!empty(mmatricula)","Ingrese la matr¡cula")
	@ 7,67 get mfechapres pict "@D" valid genval("!empty(mfechapres)","Ingrese fecha de presentaci¢n")
	read
	smallkset( K_F2 , "AUDFARM" , "mafiliado" ,;
	                  "BANUME + BAORDE + ' ' + BAAPEL",;
							"Afiliados",;
							"%BASEAFIL%AFINOMB",;
							"BANUME+BAORDE")	
	if abort()
		if messyn("ATENCION: ESTO CANCELARA EL INGRESO DEL REINTEGRO","Si Cancela","No Cancela")
			exit
		endif
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
			mserie     := "RE"
			mreceta    := space(6)
			mmandataria := space(5)
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
		use (mtmpDBF) exclusive
		mtmpAREA := select()
	else
		select (mtmpAREA)
		mReingresa := .f.
	endif
	
	set relation to TROQUEL into MEDICAME
	aColumnas := {"CANTIDAD","TROQUEL","NOMBRE+' '+PRESENTAC","UNITARIO","TOTAL","DIBA"}
	aDescr    := {"Cant.","N§ Troquel","Medicamento","P.U.","Total","a Cargo Diba"}
	m->mtmp1 := makebox(9,2,18,74)
	m->mest := makebox(21,2,23,74)
	@ 22,28 say "<INS> Agrega ³ <DEL> Borra ³ <ENTER> Modifica"
	m->ifestado := .T.

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
                        AplicaTecla( nTecla )               
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
	
	mDiferencia := 0.00
	mtmp2 := makebox(10,3,14,73,sls_popcol() )
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
		                    "1. Grabar e Imprimir Receta   ",;
								  "2. Reingresar los datos       ")
		do case
		case mopciones == 1
			replace all factura with FACTURA->factura
			replace all prestador with mprestador
			replace all afiliado with mafiliado
			replace all serie with 	mserie
			replace all receta with mreceta
			replace all feching with date()
			go top
			do while !eof()
				select (mtmpAREA)
				if (DEBITO > 0)
					mmotdeb := MOTIVO
					grabadebito(DEBITO , TROQUEL )
				endif
				select (mtmpAREA)
				skip			
			enddo
			if mDiferencia > 0.00
				mmotdeb := "070"
				grabadebito(mDiferencia)
			endif
			
			select (mtmpAREA)
			go top
			sum DEBITO to mtotdeb
			sum DIBA to mtotdiba
		   mapagar := mtotdiba - mtotdeb - mDiferencia
			* -----------------------------------
			* Impresi¢n del reintegro de farmacia
			* -----------------------------------
			do imprein
			if messyn("¨Reimprime el reintegro?")
				do imprein
			endif
			
			use
			grabacabrec()
			grabarenrec()
			grabaFactur( mapagar , mtotdeb + mDiferencia )

			* -----------------
			mdescuento := 60
			mapagar    := 0.00
			mserie     := "RE"
			mreceta    := space(6)
			mtotdiba := 0.00
			mtotdeb := 0.00
			mmotdeb = space(3)	
			mafiliado := space(9)
			mfechaemi := space(10)
			mmatricula := space(7)
			mfechapres := space(10)
			marchivo := getdfp()+mtmpDBF
			delete file (marchivo)
			exit

		case mopciones == 2
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
	exit
enddo
if type("mtmpDBF") != "U"
	marchivo := getdfp()+mtmpDBF
	if file(marchivo)
		select (mtmpAREA)
		if used()
			use
		endif
		delete file (marchivo)
	endif
endif
unbox(m->mtmp)
return

* ------------------------------------
proc imprein
* ------------------------------------
if p_ready()
	printcodes( chr( 27 ) + "C" + chr( 24 ) )
	set printer on
   for k = 1 to 3
		? "REGIONAL DIBA " + NOMBRE_REGIONAL + " " + DIRECC_REGIONAL
		? "Asistencia Sanitaria"
		? "         REINTEGROS POR SERVICIOS MEDICOS ASISTENCIALES"
		? "N§: " + mreceta + "     ------   Fecha: " + mfechapres
		? "MEDICAMENTOS"
		? "Afiliado N§ " + mAfiliado + " " + busca("5",mafiliado,"BAAPEL")
		? "C¢digo Postal: " + busca("5",mafiliado,"BACPOS")
		? "Motivo del Reintegro: "	+ busca("8",mmotivo,"descripci1")
	   ? "                PRESTACION SEGUN COMPROBANTES AGREGADOS"
                list cantidad,unitario,troquel,total,diba,medicame->nombre,medicame->presentac
		? "TOTAL:                              " + str(mtotal,10,2)
		? "Lugar y fecha:    "
		? "Firma autorizante:"	
		? "Para llenar por el afiliado:"
		? "Recib¡ por los conceptos indicados la suma de:--------------------------------" 
		? letter(int(mtotal)) + " con " + right(str(mtotal,10,2),2) + " CENTAVOS /////////"
		? "Lugar y fecha:                                     Cod.Postal Dependencia/Delegaci¢n"
		? "Firma Afiliado                                     Doc.Identidad (LE, LC, CI ¢ DNI)"
		?
	next k
	set printer off
	printcodes( chr( 27 ) + "C" + chr( 72 ) )
endif

* ------------------------------------------------------------
  static Function AplicaTecla( nTecla )
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
        editareing()
	 CASE nTecla == K_INS
			append blank
                        editareing()
    OTHERWISE
                        editareing()
    ENDCASE

return NIL

static function editareing()
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
replace DIBA     with nDIBAReal
smallkclr()

unbox( cIngreso )
return NIL

* ---------------------------------------------------------------
