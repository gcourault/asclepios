/* 
------------------------------------------
LisDeb.prg
Programa que permite imprimir los d‚bitos
------------------------------------------
*/
#include "inkey.ch"

* -----------------
  function lisdeb()
* -----------------
initsup()
select 15
if snet_use("IN1PRES","PRESTA", .F. , 5 , .T. , "No se puede abrir archivo de PRESTADORES - ¨Reintenta?" )
	set order to tag PRCOD
else
	msg( "No se puede abrir archivo de Prestadores",;
	     "Debe intentar m s tarde: Otro usuario bloquea el archivo" )
	close all
	return
endif

select 14
if snet_use("IN1PRES","IN1PRES", .F. , 5 , .T. , "No se puede abrir archivo de PRESTADORES - ¿Reintenta?" )
	set order to tag PRNOM
else
	msg( "No se puede abrir archivo de Prestadores",;
	     "Debe intentar más tarde: Otro usuario bloquea el archivo" )
	close all
	return
endif

select 1
if snet_use("FACTU01","FACTURA",.F.,5,.T.,"No se puede abrir archivo de FACTURAS - ¨Reintenta?")
	set order to tag faprenum
else
	msg("No se puede abrir archivo de facturas ingresadas",;
		 "debe intentar m s tarde: otro usuario est  usando el archivo")
	close all
	return
endif
set relation to FACTURA->PRESTADOR into PRESTA


while .t.
        * select FACTURA
        select IN1PRES
        mfactura := space( len(FACTURA->FACTURA) )
        mprestador := space( len(FACTURA->PRESTADOR) )
	
	nTop := 0
	nLeft := 0
	nBottom := 7
	nRight  := 40
	sbcenter( @nTop , @nLeft , @nBottom , @nRight )
	smallkset( K_F2 , "LISDEB" , "mprestador" ,;
	          {|| PRLETR + PRCODI + ' ' + PRNOMB},;
				 "Prestadores",;
                                 14,;
				 "PRLETR + PRCODI" )
	smallkset( K_F2 , "LISDEB" , "mfactura" ,;
	           {|| FACTURA + ' ' + PRESTA->PRNOMB},;
	           "Factura  Prestador",;
				  nil,;
				  "FACTURA")
	
	cTmp := makebox( nTop , nLeft , nBottom , nRight , sls_popcol() )
	@ nTop + 5 , nLeft + 2 say "[ F2 Busca ]       [ ESC Cancela ]"
	@ nTop + 1 , nLeft + 2 say "Prestador :"  get mprestador ;
	                       pict "@!" ;
	                       valid isinlook( mprestador , 15 , nil , .f. , "Prestador no v lido" )
        read
        * set scope to { || PRESTA->PRLETR + PRESTA->PRCODI }

        if lastkey() == K_ESC
           unbox( cTmp ) 
           return NIL
        endif
        select FACTURA
        set filter to FACTURA->PRESTADOR = mprestador 
        go top
        
	@ nTop + 2 , nLeft + 2 say "N§ Factura" get mfactura pict "@9"
	
        read
	
	unbox( cTmp )
        * set scope to
	*------------
	seek mprestador + mfactura
   if (!Found())
         msg("Factura err¢nea o A£n no ha sido cargada")
	        if (messyn("Tiene las siguientes opciones:", "Cancelar", ;
               "Reingresar"))
            exit
         endif
      elseif (factura->concepto == "20")
         if (messyn("¨Comienza el proceso de impresi¢n?"))
				plswait( .t. , "Imprimendo Listado de D‚bitos Farmacia" )
            farmdeb(mprestador, mfactura)
				plswait( .f. )
         endif
      elseif Left(factura->concepto, 1) == "3" .or. left(factura->concepto,1) == "4" .or. left(factura->concepto,1)="5"
         if (messyn("¨Comienza el proceso de impresi¢n?"))
            pracdeb(mprestador, mfactura)
         endif
      else
         msg("Concepto " + FACTURA->CONCEPTO + " No admite listado de d‚bitos")
      endif
   enddo
   close databases
   return
********************************
function FARMDEB(Arg1, Arg2)
	select 14
	if snet_use("medi","medicame" , .f. , 5 , .t. ,;
	        "No se puede abrir MEDI.DBF - ¨Reintenta?" )
	   set order to tag metroq
	else
		msg("Alquien bloquea el archivo MEDI.DBF",;
		    "Reintente luego")
		close all 
		return
	endif
   select 2
   if (snet_use("cabrec", "cabrec", .F., 5, .T., ;
         "No se puede abrir CABREC - ¨Reintenta?"))
      set order to tag CABREC
   else
      msg("Se verific¢ un error en la red", "El sistema cancela")
      quit
   endif
   select 5
   if (snet_use("BASEAFIL", "AFILIADO", .F., 5, .T., ;
         "No se puede abrir el archivo de afiliados - ¨Reintenta?"))
      set order to tag AFINUM
   else
      msg("No se puede abrir archivo de afiliados", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select 6
   if (snet_use("IN1PRES", "PRESTADOR", .F., 5, .T., ;
         "No se puede abrir archivo de PRETADORES - ¨Reintenta?"))
      set order to tag PRCOD
   else
      msg("No se puede abrir archivo de prestadores", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select 7
   if (snet_use("DEB001", "DEBITOS", .F., 5, .T., ;
         "No se puede abrir archivo de d‚bitos - ¨Reintenta?"))
      set order to tag DEB001
   else
      msg("No se puede abrir archivo de debitos", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select 8
   if (snet_use("DEBERR", "DEBERR", .F., 5, .T., ;
         "No se puede abrir archivo de motivos de d‚bitos - ¨Reintenta?"))
      set order to tag DEBERR
   else
      msg("No se puede abrir archivo de motivo de d‚bitos", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select CABREC
   set relation to AFILIADO into ;
      AFILIADO
   select DEBITOS
   set relation to MOTIV into DEBERR, to PRESTADOR into PRESTADOR,;
	             to TROQUEL into MEDICAME
   select FACTURA
   seek Arg1 + mfactura
   ntotfactu:= totfactu
   select CABREC
   seek Arg1 + mfactura
   for k:= 1 to 3
      proclfar(@Arg1, @Arg2)
      eject
   next
   return Nil

********************************
procedure DEB_LOOP

   @ PRow() + 1, margin + 0 say receta
   @ PRow(), margin + 11 say serie
   mafiliado:= busca("2", prestador +  FACTURA + serie + RECETA, "AFILIADO")
   @ PRow(), margin + 17 say mafiliado
   @ PRow(), margin + 28 say Left(busca("5", right("000000000" + ;
      mafiliado, 9), "BAAPEL"), 32)
   @ PRow(), margin + 62 say deberr->descripcio
   @ PRow(), margin + 88 say impdeb picture "99999.99"
   majtot_6:= majtot_6 + impdeb
	@ prow(), margin + 99 say TROQUEL
	@ prow(), margin + 107 say left(MEDICAME->NOMBRE,15) + " " + left( MEDICAME->PRESENTAC , 8 )
   line_ct:= line_ct + 1
   return

********************************
procedure PROCLFAR

   parameters cprestador, nfactura
   select DEBITOS
   set exact off
   set filter to PRESTADOR == cPrestador .AND. FACTURA == mFactura
   goto top
   page_ct:= 0
   line_ct:= 0
   max_lines:= 66
   margin:= 0
   header0:= ;
      "Asclepios - " + NOMBRE_REGIONAL
   header1:= "VERSION 1.0 á"
   header2:= "LISTADO DE DEBITOS PRESTADOR: " + prestador->prnomb + ;
      " FACTURA: " + mfactura
   header3:= Replicate("Í", 130)
   set printer on
   set console off
   ?? chr(15)
   set console on
   set printer off
   set device to printer
   maj_hold:= mandataria
   deb_head()
   tot_6:= 0
   majtot_6:= 0
   do while prestador + FACTURA = cprestador + Factura
      if (maj_hold != mandataria)
         deb_majb()
      endif
      if (line_ct > max_lines)
         eject
         deb_head()
      endif
      deb_loop()
      skip 
   enddo
   deb_grnd()
   @ PRow() + 1,  0 say "" + chr(18)
   set device to screen
   return

********************************
procedure DEB_GRND

   deb_majb()
   line_ct:= line_ct + 1
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "TOTAL FACTURADO"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say factura->totfactu picture "99999.99"
   line_ct:= line_ct + 1
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "Total DEBITOS"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say tot_6 picture "99999.99"
   line_ct:= line_ct + 1
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "DIFERENCIA DE SUMA TOTAL"
	nDiferencia := factura->TOTFACTU - factura->TOTAPAG - factura->TOTDEB
   line_ct:= line_ct + 1
	@ PRow() + 1, margin + 88 say nDiferencia picture "99999.99"
   line_ct:= line_ct + 1
   
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "Total A PAGAR"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say factura->totfactu - tot_6 - nDiferencia picture ;
      "99999.99"
   return

********************************
procedure DEB_HEAD

   page_ct:= page_ct + 1
   @ PRow() + 1, margin say "P g N§:" + Transform(page_ct, "999999")
   @ PRow(), 116 say "Fecha: " + DToC(Date())
   @ PRow() + 1, 116 say "Hora: " + Time()
   @ PRow() + 1, Round((132 - Len(header0)) / 2, 0) say header0
   @ PRow() + 1, Round((132 - Len(header1)) / 2, 0) say header1
   @ PRow() + 1, Round((132 - Len(header2)) / 2, 0) say header2
   @ PRow() + 1, Round((132 - Len(header3)) / 2, 0) say header3
   line_ct:= 8
   @ PRow() + 1,  0 say ""
   @ PRow() + 1, margin say ;
      "RECETA     SERIE N§ AFILIAD NOMBRE AFILIADO                   MOTIVO DEL DEBITO          IMPORTE  TROQUEL MEDICAMENTO"
   @ PRow() + 1, margin say ;
      "                                                                                          DEBITO"
   @ PRow() + 1, margin say Replicate("Ä", 130)
   @ PRow() + 1,  0 say ""
   line_ct:= line_ct + 3
   @ PRow() + 2, iif(margin > 0, margin - 1, margin) say "** "
   @ PRow(), PCol() + margin say "MANDATARIA: "
   @ PRow(), PCol() say mandataria
   line_ct:= line_ct + 2
   return

********************************
procedure DEB_MAJB

   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "** Subtotal **"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say majtot_6 picture "99999.99"
   maj_hold:= mandataria
   tot_6:= tot_6 + majtot_6
   majtot_6:= 0
   line_ct:= line_ct + 3
   if (!EOF() .AND. line_ct < max_lines)
      @ PRow() + 2, iif(margin > 0, margin - 1, margin) say "** "
      @ PRow(), PCol() say "MANDATARIA: "
      @ PRow(), PCol() say mandataria
   endif
   return

********************************
procedure PRACDEB(Arg1, Arg2)

   select 2
   if (snet_use("PRACTICA", "PRACTICA", .F., 5, .T., ;
         "No se puede abrir PRACTICA - ¨Reintenta?"))
      set order to tag PRACTICA
   else
      msg("Se verific¢ un error en la red", "El sistema cancela")
      quit
   endif
   select 5
   if (snet_use("BASEAFIL", "AFILIADO", .F., 5, .T., ;
         "No se puede abrir el archivo de afiliados - ¨Reintenta?"))
      set order to tag AFINUM
   else
      msg("No se puede abrir archivo de afiliados", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select 6
   if (snet_use("IN1PRES", "PRESTADOR", .F., 5, .T., ;
         "No se puede abrir archivo de PRETADORES - ¨Reintenta?"))
      set order to tag prcod
   else
      msg("No se puede abrir archivo de prestadores", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select 7
   if (snet_use("DEB002", "DEBITOS", .F., 5, .T., ;
         "No se puede abrir archivo de d‚bitos - ¨Reintenta?"))
      set order to tag DEB002
   else
      msg("No se puede abrir archivo de debitos", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
   select 8
   if (snet_use("DEBERR", "DEBERR", .F., 5, .T., ;
         "No se puede abrir archivo de motivos de d‚bitos - ¨Reintenta?"))
      set order to tag DEBERR
   else
      msg("No se puede abrir archivo de motivo de d‚bitos", ;
         "debe intentar m s tarde: otro usuario est  usando el archivo")
      return
   endif
	
	select 0
	if snet_use("R_NOME","NOMENCLADO",.F.,5,.T.,;
	    "No se puede abrir archivo de Pr cticas M‚dicas - ¨Reintenta?" )
		set order to tag NOMECODI
	else
		msg("No se puede abrir archivo de Pr cticas",;
		    "Otro usuario bloquea el archivo")
		return
	endif
	
   select PRACTICA
   set relation to afiliado into AFILIADO
   select DEBITOS
   set relation to MOTIV into DEBERR, to PRESTADOR into PRESTADOR, to PRACTICA into NOMENCLADO
   select FACTURA
   seek Arg1 + mFactura
   ntotfactu:= totfactu
   ntotdiba:= 0.00
   proclprac(@Arg1, @Arg2)
   return

********************************
procedure DEB_LOOP2

   @ PRow() + 1, margin + 0 say receta
   @ PRow(), margin + 11 say serie
   mafiliado:= busca( "2", prestador + factura + serie + receta , "AFILIADO")
   @ PRow(), margin + 17 say mafiliado
   @ PRow(), margin + 28 say Left(busca("5", mafiliado, "BAAPEL"), 32)
   @ PRow(), margin + 62 say deberr->descripcio
   @ PRow(), margin + 88 say impdeb picture "99999.99"
	@ PRow(), margin + 100 say PRACTICA
	@ PRow(), margin + 110 say left( NOMENCLADO->DESC , 20 )
   majtot_6:= majtot_6 + impdeb
   line_ct:= line_ct + 1
   return

********************************
procedure PROCLPRAC

   parameters cprestador, nfactura
   select DEBITOS
   set filter to factura = nFactura .AND. prestador = cPrestador
   goto top
   page_ct:= 0
   line_ct:= 0
   max_lines:= 66
   nfacturado:= factura->totfactu
   margin:= 0
   header0:= ;
      "Asclepios - " + "NOMBRE_REGIONAL
   header1:= "VERSION 1.2"
   header2:= "LISTADO DE DEBITOS PRESTADOR: " + prestador->prnomb + ;
      " FACTURA: " + factura->factura
   header3:= Replicate("Í", 130)
   set printer on
   set console off
   ?? chr(15)
   set printer off
   set console on
   
   set device to printer
   maj_hold:= mandataria
   deb_head2()
   tot_6:= 0
   majtot_6:= 0
   do while (!EOF())
      if (maj_hold != mandataria)
         deb_majb2()
      endif
      if (line_ct > max_lines)
         eject
         deb_head2()
      endif
      deb_loop2()
      skip 
   enddo
   deb_grnd2()
   @ PRow() + 1,  0 say "" + chr(18)
   set device to screen
   return

********************************
procedure DEB_GRND2

   deb_majb2()
   line_ct:= line_ct + 1
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "Total DEBITOS"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say tot_6 picture "99999.99"
   line_ct:= line_ct + 1
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "Total FACTURADO"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say nfacturado picture "99999.99"
   line_ct:= line_ct + 1
   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "DIFERENCIA SUMA COMPROBANTES"
   line_ct:= line_ct + 1
	nDiferencia := nFacturado - factura->totapag
   @ PRow() + 1, margin + 88 say nfacturado - factura->totapag picture "99999.99"
   line_ct:= line_ct + 1



   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "Total A PAGAR"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say nfacturado - tot_6 - nDiferencia picture "99999.99"
   if (!Empty(factura->debitos))
      nlineas:= mlcount(factura->debitos)
      for k:= 1 to nlineas
         @ PRow() + 1,  2 say memoline(factura->debitos, 79, k)
      next
   endif
   return


********************************
procedure DEB_HEAD2

   page_ct:= page_ct + 1
   @ PRow() + 1, margin say "P g N§:" + Transform(page_ct, "999999")
   @ PRow(), 116 say "Fecha: " + DToC(Date())
   @ PRow() + 1, 116 say "Hora: " + Time()
   @ PRow() + 1, Round((132 - Len(header0)) / 2, 0) say header0
   @ PRow() + 1, Round((132 - Len(header1)) / 2, 0) say header1
   @ PRow() + 1, Round((132 - Len(header2)) / 2, 0) say header2
   @ PRow() + 1, Round((132 - Len(header3)) / 2, 0) say header3
   line_ct:= 8
   @ PRow() + 1,  0 say ""
   @ PRow() + 1, margin say ;
      "COMPROB    SERIE N§ AFILIAD NOMBRE AFILIADO                   MOTIVO DEL DEBITO          IMPORTE  PRACT.  DESC."
   @ PRow() + 1, margin say ;
      "                                                                                          DEBITO"
   @ PRow() + 1, margin say Replicate("Ä", 130)
   @ PRow() + 1,  0 say ""
   line_ct:= line_ct + 3
   @ PRow() + 2, iif(margin > 0, margin - 1, margin) say "** "
   @ PRow(), PCol() + margin say "MANDATARIA: "
   @ PRow(), PCol() say mandataria
   line_ct:= line_ct + 2
   return

********************************
procedure DEB_MAJB2

   @ PRow() + 1, iif(margin > 0, margin - 1, margin) say ;
      "** Subtotal **"
   line_ct:= line_ct + 1
   @ PRow() + 1, margin + 88 say majtot_6 picture "99999.99"
   maj_hold:= mandataria
   tot_6:= tot_6 + majtot_6
   majtot_6:= 0
   line_ct:= line_ct + 3
   if (!EOF() .AND. line_ct < max_lines)
      @ PRow() + 2, iif(margin > 0, margin - 1, margin) say "** "
      @ PRow(), PCol() say "MANDATARIA: "
      @ PRow(), PCol() say mandataria
   endif
   return

* EOF
static function fc( f, c , b , l )

if f=b
	if c >= l .and. c <= l + 11
		keyboard chr( K_CTRL_RET )
	elseif c >= l + 18 .and. c <= l + 36
		keyboard chr( K_ESC )
	endif
endif

return NIL
