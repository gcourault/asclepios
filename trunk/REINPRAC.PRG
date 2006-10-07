/* 
   ---------------------------------------------
   Programa ReinPrac.prg
	Auditor¡a de pr cticas m‚dicas
   ---------------------------------------------
*/


#include "inkey.ch"
#include "regional.ch"

* --------------------
 function reinprac()
* --------------------
local mtmp,nSelecc,nAccion

set delete on

set decimal to 2
set fixed on

set key K_F2     to scroller
set key K_ALT_F2 to scmod

set key K_F5     to CambHono
set key K_F11    to ModNomenc

initsup()
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


select 6
set relation to UARA into UARANC

select 8
if snet_use("MOTIVOS","MOT",.F.,5,.T.,"No se puede abrir archivo Motivos - ¨Reintenta?")
	set order to tag MOTIVOS
else
	msg("No se puede abrir archivo de Motivos",;
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
	msg("No se puede abrir archivo de consultas",;
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


select 0
if snet_use("BASEAFIL","AFILIADO",.F.,5,.T.,"No se puede abrir archivo de afiliados - ¨Reintenta?")
	set order to tag AFINUM
else
	msg("No se puede abrir archivo de AFILIADOS",;
	    "debe intentar m s tarde: otro usuario est  usando el archivo")
	return
endif

m->mtmp := makebox(0,1,22,76,sls_normcol() )

@ 9,2 to 9,75
@ 18,2 to 18,75
@ 20,2 say " F5 -> Cambia % Honorarios"
		cConvenio := buscConv()
		
		if snet_use( cConvenio , "NOMENCLA" , .f. , 5 , .t. , "No se puede abrir archivo Nomenclador - ¨Reintenta?" )				
			set order to tag NOMECODI
		else
			msg("No se puede abrir archivo nomenclador",;
	   	 "debe intentar m s tarde: otro usuario est  usando el archivo")
			return
		endif	
		
		select 0
		if snet_use( alltrim( (UARANC->ARCHIVO) ) , "UARA" , .F. , 5 , .T. , "No se puede abrir archivo de Unidades arancelarias ¨Reintenta?")
			set order to tag FECH
		else
			msg("No se puede abrir archivo de unidades arancelarias",;
	   	 "debe intentar m s tarde: otro usuario est  usando el archivo")
	
		endif

mmandataria := space( 6 )
mcategoriz := 0.00
marancel   := 0.00
mapagar    := 0.00
mserie     := "RE"
mreceta    := space( 6 )
mtotdiba := 0.00
mtotdeb := 0.00
mmotdeb = space( 3 )
mafiliado := space( 9 )
mmatricula := space( 7 )
mfechapres := space( 8 )
mmotivo    := space( 3 )

mReingresa := .f.

do while .t.
	
	@ 1,2  say "FACTURA: " + FACTURA->FACTURA
	@ 1,32 say "PRESTADOR: " + PRESTA->PRNOMB

	@ 2,32 say "Facturado:"
	@ 2,44 say FACTURA->TOTFACTU pict "99999.99"
	@ 2,57 say "A pagar:"
	@ 2,66 say FACTURA->TOTAPAG pict "999999.99"
	@ 3,2 say "Honorarios:    %            Serie:        N£mero:"
	@ 4,2 say "Gastos    :    %"

*	while .t.
		@ 3,13 get mcategoriz pict "999.99"
		@ 4,13 get marancel   pict "999.99"
		@ 3,52 get mreceta pict "999999" 
	   read
		if abort()
			exit
		endif
		
		@ 5,7 say "Nro. de Afiliado.:                   Fecha Pr ctica.......:"
		@ 7,7 say "Nro. de Matr¡cula:"
	
		@ 5,26 get mafiliado pict "999999999" valid genval("!empty(mafiliado)","Ingrese N§ de afiliado")
		@ 5,67 get MFECHAPRES pict "@D" valid genval("!empty(MFECHAPRES)","Ingrese fecha emisi¢n")
		@ 7,26 get mmatricula pict "@!" valid genval("!empty(mmatricula)","Ingrese la matr¡cula")
		@ 8,7  say "Motivo del Reintegro:" get mmotivo 

		set key K_F2 to scroller
		set key K_ALT_F2 to scmod
		read
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
                                        grabacabrec3()
                                        grabadebito3(mtotdeb)
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
			use (mtmpDBF) exclusive
			mtmpAREA := select()
		else
			select (mtmpAREA)
			mReingresa := .f.
		endif
	
		set relation to NOMENCLADO into NOMENCLA
		aColumnas := {"CANTIDAD","NOMENCLADO","UNITARIO","TOTFACTU"}
		aDescr    := {"Cant.","C¢d.Nom.","P.U.","a Cargo Diba"}
		m->mtmp1 := makebox(9,2,18,74)
		m->mest := makebox(21,2,23,74)
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
                                ApplyKey3( nTecla )               
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
	
	
		sum TOTAL to mTotal1
		mTotal := mTotal1
	
		mDiferencia := 0.00
		mtmp2 := makebox(10,3,14,73,c_popcol)
	
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
			                    "1. Grabar e Imprimir Reintegro",;
									  "2. Debitar el Comprobante     ",;
									  "3. Reingresar los datos       ")
			do case
			case mopciones == 1
				replace all factura with FACTURA->factura
				replace all prestador with mprestador
				replace all mandataria with mmandataria
				replace all afiliado with mafiliado
				replace all serie with 	mserie
				replace all numero with right( "000000" + alltrim(mreceta) , 6 )
				replace all feching with date()
				go top
	
				do while !eof()
					select (mtmpAREA)
					if (DEBITO > 0)
						mmotdeb := MOTIVO
                                                grabadebito3(DEBITO)
					endif
					select (mtmpAREA)
					skip			
				enddo
				if mDiferencia > 0.00
					mmotdeb := "070"
                                        grabadebito3(mDiferencia)
				endif
			
				select (mtmpAREA)
				go top
				sum DEBITO to mtotdeb
				sum TOTAL to mtotdiba
			   mapagar := mtotdiba - mtotdeb - mDiferencia
				* ----------------------------------------
				* Impresi¢n del reintegro de practica
				* ----------------------------------------
				do impreinprac
				if messyn("¨Reimprime el Reintegro?")
					do impreinprac
				endif
				use
			
                                grabacabrec3()
                                grabarenrec3()
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
				replace all numero with right( "000000" + alltrim(mreceta) , 6 )
				replace all feching with date()
				go top

				do while !eof()
					select (mtmpAREA)
					if DEBITO > 0
						mmotdeb := MOTIVO
                                                grabadebito3(DEBITO)
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
                                mmotdeb := debito3()

				if lastkey() == K_ESC .or. mmotdeb = space( 3 )
					loop
				endif
				use
                                grabacabrec3()
                                grabarenrec3()
                                grabadebito3(mtotdeb)
 				if mDiferencia > 0.00
					mmotdeb := "070"
                                        grabadebito3(mDiferencia)
				endif
			
				replace all factura with right( "00000000" + alltrim( str( FACTURA->factura ) ) , 8 )
				replace all prestador with mprestador
				replace all mandataria with mmandataria
				replace all serie with 	mserie
				replace all numero with right( "000000" + alltrim(mreceta) , 6 )
				replace all feching with date()
				go top
				* -------------------
				marchivo := getdfp()+mtmpDBF
				delete file (marchivo)
				exit
		
			case mopciones == 3
				replace all factura with right( "00000000" + alltrim( str( FACTURA->factura ) ) , 8 )
				replace all prestador with mprestador
				replace all serie with 	mserie
				replace all mandataria with mmandataria
				replace all afiliado with mafiliado
				replace all numero with right( "000000" + alltrim(mreceta) , 6 )
				replace all feching with date()
				go top
				mReingresa := .t.
				exit				
			endcase
		enddo
*	enddo
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
static function grabacabrec3
* --------------------------
select PRACTICA
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace SERIE with mserie
		replace numero with right( "000000" + alltrim(mreceta) , 6 )
		replace AFILIADO with mafiliado
		replace FECHA with ctod(MFECHAPRES)
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
		replace MOTIVO with mmotivo
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
static function grabadebito3
* --------------------------
parameters xmdebito
select DEBITOS
if sadd_rec(5,.f.)
	if srec_lock(5,.f.)
		replace REGIONAL with "5000"
		replace SERIE with mserie
		replace RECETA with  mreceta 
		replace FPRES with FACTURA->FPRES
		replace MANDATARIA with mmandataria
		replace FACTURA with FACTURA->FACTURA
		replace PRESTADOR with FACTURA->PRESTADOR
		replace CONCEP with FACTURA->CONCEPTO
		replace IMPDEB with xmdebito
		replace MOTIV with mmotdeb
		replace FECHING with date()
		unlock
	endif
endif
/*--------------------
select FACTURA
if srec_lock(5,.f.)
	replace TOTDEB with TOTDEB + mtotdeb
	unlock
endif
------------------- */
return NIL

*---------------------------
static function grabarenrec3
*---------------------------
select PRACRENG
if sfil_lock(5,.t.,"No se puede bloquear Renglones - ¨Reintenta?")
	append from &mtmpDBF
	unlock
endif
return NIL

*---------------------
static function debito3
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

* --------------------
procedure impreinprac
* --------------------
/*
if p_ready()
        
	set printer on
        ?? chr( 27 ) + "C" + chr( 24 )
   for k = 1 to 3
		? "REGIONAL " + NOMBRE_REGIONAL + " " + DIRECC_REGIONAL
		? "Asistencia Sanitaria"
		? "         REINTEGROS PRACTICAS ASISTENCIALES"
		? "N§: " + alltrim(mreceta) + "     ------   Fecha: " + mfechapres
		? "PRACTICAS"
		? "Afiliado N§ " + mAfiliado + " " + AFILIADO->BAAPEL
		? "C¢digo Postal: " + AFILIADO->BACPOS
		? "Motivo del Reintegro: "	+ busca("8",mmotivo,"descripci1")
	   ? "                PRESTACION SEGUN COMPROBANTES AGREGADOS"
                list cantidad,unitario,total,nomencla->desc
		? "TOTAL:                              " + str(mtotal,10,2)
		? "Lugar y fecha:    "
		? "Firma autorizante:"	
		? "Para llenar por el afiliado:"
		? "Recib¡ por los conceptos indicados la suma de:--------------------------------" 
		set fixed off
		? letter(int(mtotal)) + " con " + right(str(mtotal,10,2),2) + " CENTAVOS /////////"
		set fixed on
		? "Lugar y fecha:                                     Cod.Postal Dependencia/Delegaci¢n"
		? "Firma Afiliado                                     Doc.Identidad (LE, LC, CI ¢ DNI)"
		?
	next k
        ?? chr( 27 ) + "C" + chr( 72 )
	set printer off
        
endif
*/

aStyle := { "Normal" , "Bold" , "Italic" , "BoldItalic" }
aFonts := { { "Times",     .t., .t., .t., .t. },;
            { "Helvetica", .t., .t., .t., .t. },;
            { "Courier",   .t., .t., .t., .t. } }

cOutFileName := uniqfname( "pdf" )
pdfOpen( cOutFileName , 200 , .t. )
pdfBookOpen()
pdfSetFont("Times" , 0 , 14 )
nLinea := 1
nArriba := 6
nMargen = 15
for k = 1 to 3
  
  nMargen := 10
  pdfAtSay( hb_oemtoansi("REGIONAL " + NOMBRE_REGIONAL + " " + DIRECC_REGIONAL) , nArriba + nLinea*4 , nMargen , "M"  ) 
  pdfSetFont("Times" , 0 , 10 )
  nLinea++
  nLinea++
  pdfAtSay( "Asistencia Sanitaria" , nArriba + nLinea*4 , nMargen, "M" )
  nLinea++
  pdfAtSay( "         REINTEGROS PRACTICAS ASISTENCIALES" , nArriba+nLinea*4 , nMargen , "M" )
  nLinea++
  pdfAtSay(hb_oemtoansi(" N§: " + alltrim(mreceta) + "     ------   Fecha: " + mfechapres ), nArriba + nLinea*4 , nMargen, "M" )
  nLinea++
  nLinea++
  pdfAtSay( "PRACTICAS" , nArriba + nLinea*4 , nMargen, "M" )
  nLinea++
  nLinea++
  pdfAtSay( hb_oemtoansi( "Afiliado N§ " + mAfiliado + " " + AFILIADO->BAAPEL ) , nArriba + nLinea*4 , nMargen , "M" )
  nLinea++
  pdfAtSay(hb_oemtoansi( "C¢digo Postal: " + AFILIADO->BACPOS ) , nArriba + nLinea*4 , nMargen , "M" )
  nLinea++
  pdfAtSay(hb_oemtoansi( "Motivo del Reintegro: "	+ busca("8",mmotivo,"descripci1") ) , nArriba + nLinea*4 , nMargen, "M" )
  nLinea++
  nLinea++
  pdfAtSay( "                PRESTACION SEGUN COMPROBANTES AGREGADOS" , nArriba + nLinea*4 , nMargen , "M" )
  nLinea++
  nLinea++
  go top
  pdfAtSay( hb_oemtoansi( "Ctad. P.Unitario  Total Descripci¢n") , nArriba + nLinea*4 , nMargen, "M" )
  while !eof()
     nLinea++
    skip 
  enddo

  pdfSetFont(Courier , 0 , 10 )
   
next k
pdfClose()

return NIL


function BuscConv()
* --------------------------------------------
* Funci¢n que busca en el archivo de convenios
* el archivo de las pr cticas m s adecuado
* --------------------------------------------
local cConvenio, nArea
select CONV
go top
aArchivo := {}
while !eof()
	aadd( aArchivo , DESCRIPCIO )
	skip
end
nRegistro := mchoice( aArchivo , nil , nil , nil , nil , "Convenios" )
go nRegistro
cConvenio := alltrim( ARCHIVO )
select (nArea)
return cConvenio

* ------------------------------------------------------------
  static Function ApplyKey3( nTecla )
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
        edicion3()
	 CASE nTecla == K_INS
			append blank
                        edicion3()
    OTHERWISE
                        edicion3()
    ENDCASE

return NIL

* ------------------------
static function edicion3()
* ------------------------
nCantidad := CANTIDAD
cNomenclado := NOMENCLADO
nPU      := CalcNomen( nomencla->codi )
nTotal   := CANTIDAD * nPU
nDIBA    := nTotal
cArchivo := "%" + alltrim(conv->archivo) + "%NOMEDESC"
smallkset( K_F2 , "EDICION" , "cNomenclado" , 'CODI+" "+DESC',"Pr cticas", cArchivo  , 'CODI' )
cIngreso := makebox( 9, 20 , 16 , 60 )
@ 10,21 say "Cantidad: " get nCantidad pict "99" valid genval( "nCantidad > 0" , "La cantidad debe ser mayor que cero" )
@ 11,21 say "Pr ct   : " get cNomenclado pict "@!" valid CapNomen( cNomenclado )
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
