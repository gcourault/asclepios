/*
ImpChequ.prg
Programa que imprime los cheques a las agrupaciones de prestadores
Llamado por Resumen.prg
*/

EXTERNAL GETDATE

#include "inkey.ch"

function impchequ()

restore from nrocheque addi // trae mcheque variable con la numeraci¢n de 
                            // los cheques

private msecuencia := 1

if !messyn("¨Contin£a?")
	return
endif
select 1
IF !SNET_USE("FACTU01","FACTURA",.F.,5,.T.,;
  	          "No se puede acceder al archivo FACTURA - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 0342-4554785")	
	RETURN
ENDIF
select 4
if snet_use("AliGan","Ali",.f.,5,.t.,"No se puede abrir AliGan - ¨Reintenta?" )
	set order to tag codigo
else
	msg("Alguien m s que Ud. est  usando este archivo",;
	    "Reintente luego")
	return
endif
* --
SELECT 3
IF !SNET_USE("BANCO","BANCO",.F.,5,.T.,"No se puede abrir BANCO.DBF - ¨Reintenta?")
	msg("Alguien m s que Ud. est  usando este archivo",;
	    "Reintente luego")
	return
ENDIF
* --
SELECT 2
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.F.)
	SET ORDER TO TAG PRCOD
ELSE
	MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
	    "T.E. 0342-4554785")
	RETURN
ENDIF

set relation to PRIGAN into Ali
select 1
set relation to prestador into prestador

mfax := CaptFax("Impresi¢n de Cheques")

mensaje1 := "Del FAX N§ " + mfax
MSG("Ha seleccionado generar los Cheques",mensaje1)

IF MESSYN("¨Comienza la Generaci¢n de los Cheques?")
        set filter to FAX == mfax .and. EMPTY(CHEQUEREG)
	go top	
	plswait(.t.,"Calculando Retenciones ...")
	while !eof()
		if srec_lock(5,.t.,"No se puede bloquear registro - ¨Reintenta?")
			replace RETENCION with CalcReten()
			replace ALIRETEN  with ali->alicuota
			replace TOTAPAG with ( TOTFACTU - TOTDEB - RETENCION )
			replace FPAG with date()
			unlock
		endif
		skip
	end
	go top
	plswait(.f.)	
	if m->_cheques = "CONTINUO"	
		MSG("Coloque los formularios de cheques en la impresora")
	endif
	aMarcar := {}
	tagit( aMarcar , {"B->PRNOMB","TOTAPAG"},{"NOMBRE INST.","Monto Cheque"},"MARQUE LOS CHEQUES A PAGAR")
	set filter to ascan( aMarcar , recno() ) > 0 
	go top

	if m->_cheques = "CONTINUO"
                * IF P_READY()
			do cheques with .t.      //Imprime el cheque
			save all like mcheque to nrocheque
                * ENDIF 
	else
		do cheques	with .f.        //No imprime el cheque
		save all like mcheque to nrocheque
	endif

        * if p_ready()
		go top
		do impganan
        * endif

	* --------------------------------------------------------------

	msg("Coloque los formularios de etiquetas autoadhesivas")
	go top
	aCampos := {"B->PRNOMB","B->PRDIRE",;
	"B->PRLOCA","B->PRPCIA",;
	"B->PRCPOS","A->CHEQUEREG",;
	"A->TOTAPAG","A->FACTURA","FECHLETR(DATE())",;
	"A->PRESTADOR"}
	aDescr  := {"Nombre","Direcci¢n",;
	"Ciudad","Provincia",;
	"Cod. Postal",;
	"Cheque N§","Importe",;
	"N§ Factura","Fecha de Hoy","N§ Prestador"}
	aTipo := {"C","C","C","C","C","C","N","C","C","C"}
	clabel(aCampos,aDescr,aTipo)
	MSG("Coloque hojas en blanco para informe de elevaci¢n")
	formletr(aCampos,aDescr,aTipo)
	
	* ---------------------------------------------------------------
ENDIF
CLOSE DATABASES
RETURN

* ---

PROCEDURE CHEQUES 
parameters lImprime

if lImprime
        setprc(0,0)                                  // poner en cero prow(),pcol()
*        PrintCodes( chr(27) + chr(48) )              // 8 l¡neas por pulgada
        PrintCodes( CHR(27) + "C" + chr(18)  )          // longitud de pagina 18 LINEAS
        printcodes( chr(27) + "!" + chr(8) )          // enfatizado

	POPREAD(.T.,"Ingrese N§ Primer Cheque",@mcheque,"99999999" )

*            "Ingrese N§ de Secuencia", @msecuencia,"@9" )

	plswait( .t. , "Imprimendo Cheques - <ESC> Cancela" )
	set device to printer
endif
while !EOF() .and. lastkey() != K_ESC
/* ----------------------------------------------------------------
	                          Imprimir monto en numeros 
	-------------------------------------------------------------------*/
	if lImprime
		nRenglon := 0
                

                @ prow()+1,60 SAY TOTAPAG PICT "*******9.99"

		/* ---------------------------------------------------------------
	                          Imprime la fecha 
                   Posicionar a pata para la fecha 3 RENGLONES
		------------------------------------------------------------------*/
	
                @ prow() + 3,25 say alltrim(str(day(date()),2)) + ;
                                  "  " + cmes(MONTH(date()))
                @ prow()  , 40 say right(alltrim(str(year(date()))),4)
	
                nRenglon := nRenglon + 4
		/*
		                   Imprimir el nombre
		*/

                @ prow() + 2,28 SAY ALLTRIM(B->PRBEN1) + ALLTRIM(B->PRBEN2)
		nRenglon := nRenglon + 2
		/* -------------------------------------------------------------
		                   Imprimir el monto en letras
		----------------------------------------------------------------*/

		m->long := len(LETTER(int(TOTAPAG)))
		do case
		case m->long <= 29
		
                        @ prow() + 2,32 say LETTER(int(TOTAPAG)) +;
		   " con "+RIGHT(str((TOTAPAG),10,2),2) + ;
	   	" CENTAVOS" + "///////////"
			nRenglon := nRenglon + 2
		case m->long > 29  .and. m->long <= 80
	
                        @ prow() + 1, 35 say left(letter(int(TOTAPAG)),29 ) + "-"
                        @ prow() + 1, 13 say right(letter(int(TOTAPAG)),m->long - 29) +;
			 " con "+RIGHT(str((TOTAPAG),10,2),2) + ;
		  " CENTAVOS" + "///////////"
			nRenglon := nRenglon + 2
		other
                        @ prow() + 1, 32 say left(letter(int(TOTAPAG)),29) + "-"
                        @ prow() + 1, 13 say substr(letter(int(TOTAPAG)),30,80)+"-"
                        @ prow() + 1, 13 say right(letter(int(TOTAPAG)),m->long - 80) + ;
			 " con " + RIGHT(str(TOTAPAG,10,2),2) + " CENTAVOS ///////////"
			nRenglon := nRenglon + 3
		endcase
	else
		
		while .t.
			cSioNo = space(1)
			POPREAD(.T.,"Ingrese N§ Cheque para " + B->PRNOMB ,@mcheque,"99999999",;
			            "¨Correcto? (S/N)" , @cSioNo , "@!"  )
			if cSioNo = "S"
				exit
			endif
		enddo
	endif
	
	if srec_lock(5,.t.,"No se puede bloquear el registro para grabar el N§ de Cheque - ¨Reintenta?")
		replace FACTURA->CHEQUEREG with alltrim( str(m->mcheque) )
		unlock
	else
		tone(300,1)
		tone(100,1)
		tone(300,1)
		tone(100,1)
		msg("No se grab¢ el N§ de cheque en Planilla Rendici¢n")
	endif
	
	select 3
	if sadd_rec(5,.t.,"No se puede agregar registro - ¨Reintenta?")
		if srec_lock(5,.t.,"No se puede bloquear registro para grabar N§ cheque - ¨Reintenta?")
			replace FECHA    with date()
			replace NUMERO   with FACTURA->CHEQUEREG
			replace ALAORDEN with PRESTADOR->PRBEN1
			replace MONTO    with -(FACTURA->TOTAPAG)
			replace ESTADO     with "1"
			unlock
		else
			msg("No se grab¢ en el libro de Banco el £ltimo cheque")
		endif
	else
		msg("No se pudo agregar registro en blanco")
	endif
	select 1
	skip
	mcheque := mcheque + 1
	if lImprime	
	*	if msecuencia == 4
	*		msecuencia := 0
	*		 nSalto := 30 - nRenglon
	*	else
                        nSalto := 18 - nRenglon
	*	endif
	endif
	*--
	* msecuencia := msecuencia + 1
	*--
        
	if lImprime
		for k = 1 to nSalto
			@ prow() + 1, 1 say ""
		next k
	endif
        
enddo
if lImprime
	set device to screen
	plswait( .f. )
	PrintCodes( CHR(27) + CHR(50) )              // 6 l¡meas / pulgada
	PrintCodes(CHR(27) + "C" + CHR(72))          // longitud de pagina 72
	printcodes( chr(27) + "@" )
endif
RETURN

* ---
Function cartas
* ---
select 1
IF !SNET_USE("FACTU01","FACTURA",.F.,5,.T.,;
  	          "No se puede acceder al archivo FACTURA - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 042-554785")	
	RETURN
ENDIF
* --

SELECT 2
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.F.)
	 set order  TO tag PRCOD
ELSE
	MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
            "T.E. 0342-4554785")
	RETURN
ENDIF
SELECT 1
SET RELATION TO PRESTADOR INTO PRESTADOR

* --
mselecc := menu_v("Seleccione Por Favor:           ",;
                  "Cartas correspondientes a un FAX",;
						"Otras Cartas                    ")
do case
	case mselecc == 1
		mfax := CaptFax("Impresi¢n de Cartas")
		set filter to (FAX == mfax .and. !empty(CHEQUEREG))
		go top
	
		aCampos := {"B->PRNOMB","B->PRDIRE",;
		"B->PRLOCA","B->PRPCIA",;
		"B->PRCPOS","A->CHEQUEREG",;
		"A->TOTAPAG","A->FACTURA","FECHLETR(DATE())",;
		"A->PRESTADOR"}
		aDescr  := {"Nombre","Direcci¢n",;
		"Ciudad","Provincia",;
		"Cod. Postal",;
		"Cheque N§","Importe",;
		"N§ Factura","Fecha de Hoy","N§ Prestador"}
		aTipo := {"C","C","C","C","C","C","N","C","C","C"}
		formletr(aCampos,aDescr,aTipo)
	case mselecc == 2
		aCampos := {"B->PRNOMB","B->PRDIRE",;
		"B->PRLOCA","B->PRPCIA",;
		"B->PRCPOS","A->CHEQUEREG",;
		"A->TOTAPAG","A->FACTURA","FECHLETR(DATE())",;
		"A->PRESTADOR"}
		aDescr  := {"Nombre","Direcci¢n",;
		"Ciudad","Provincia",;
		"Cod. Postal",;
		"Cheque N§","Importe",;
		"N§ Factura","Fecha de Hoy","N§ Prestador"}
		aTipo := {"C","C","C","C","C","C","N","C","C","C"}
		formletr(aCampos,aDescr,aTipo)
	otherwise
		close all
		return NIL
endcase
return NIL

* ---
Function etiqueta
* ---
select 1
IF !SNET_USE("FACTU01","FACTURA",.F.,5,.T.,;
  	          "No se puede acceder al archivo FACTURA - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 042-554785")	
	RETURN
ENDIF
* --

SELECT 2
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.F.)
	 set order TO tag PRCOD
ELSE
	MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
	    "T.E. 042-554785")
	RETURN
ENDIF
SELECT 1
SET RELATION TO PRESTADOR INTO PRESTADOR
* --
mselecc := menu_v("Seleccione Por Favor:           ",;
                  "Etiquetas correspondientes a un FAX",;
						"Otras Etiquetas                    ")
do case
	case mselecc == 1
		mfax := CaptFax("Impresi¢n de Etiquetas")
		set filter to (FAX == mfax .and. !empty(CHEQUEREG))
		go top
	
		aCampos := {"B->PRNOMB","B->PRDIRE",;
		"B->PRLOCA","B->PRPCIA",;
		"B->PRCPOS","A->CHEQUEREG",;
		"A->TOTAPAG","A->FACTURA","FECHLETR(DATE())",;
		"A->PRESTADOR"}
		aDescr  := {"Nombre","Direcci¢n",;
		"Ciudad","Provincia",;
		"Cod. Postal",;
		"Cheque N§","Importe",;
		"N§ Factura","Fecha de Hoy","N§ Prestador"}
		aTipo := {"C","C","C","C","C","C","N","C","C","C"}
		clabel(aCampos,aDescr,aTipo)
	case mselecc == 2
		aCampos := {"B->PRNOMB","B->PRDIRE",;
		"B->PRLOCA","B->PRPCIA",;
		"B->PRCPOS","A->CHEQUEREG",;
		"A->TOTAPAG","A->FACTURA","FECHLETR(DATE())",;
		"A->PRESTADOR"}
		aDescr  := {"Nombre","Direcci¢n",;
		"Ciudad","Provincia",;
		"Cod. Postal",;
		"Cheque N§","Importe",;
		"N§ Factura","Fecha de Hoy","N§ Prestador"}
		aTipo := {"C","C","C","C","C","C","N","C","C","C"}
		clabel(aCampos,aDescr,aTipo)
	otherwise
		close all
		return NIL
endcase
return NIL

Function CalcReten()
nImponible := TOTFACTU - TOTDEB - ali->maximo

if nImponible > 0
	nRetencion := nImponible * ali->alicuota / 100 
	return if( nRetencion > 3.75 , nRetencion , 0 )
else
	return 0
endif

* ----------------
procedure impganan
* ----------------
select 1
msg( "Cambie el formulario de cheques",;
     "Por formulario cont¡nuo")
eject
set printer on
set console off
nFormulario := 0
while !eof()
	if RETENCION > 0
		?		
		?
		? "                      DIRECCION BIENESAR DE LA ARMADA"
		? "                           CUIT N§ 30-54660501-6"
		? "              CERTIFICADO DE RETENCION IMPUESTO A LAS GANANCIAS"
		? "              -------------------------------------------------"
		? "----------------CERTIFICO haberse retenido a " + PRESTADOR->PRNOMB
		? "CUIT N§ " + PRESTADOR->PRCUIT + " " + alltrim( ALI->DESCRIPCIO ) + " en la DGI"
		? "la cantidad de Pesos " + LETTER(int(RETENCION)) + " con "+RIGHT(str((RETENCION),10,2),2) + " CENTAVOS" + "///////////"
		? "($ " + str(RETENCION,9,2) + ") correspondiente a la 	FACTURA/RECIBO N§ " + FACTURA
		? "por un importe de $ " + str( TOTFACTU,9,2) + " y al¡cuota de %"+str( ALI->ALICUOTA , 5,2)
		? "por pago efectuado en el MES/A¥O: " + right( dtoc(date()) , 5 )
		?
		?
		?
		?
		?
		?
		?
		?
		?
		?
		? "---------------------------------------------------------------------------"
		nFormulario++
		if nFormulario >= 3
			nFormulario := 0
			eject
		endif
	endif
	skip
end
set printer off
set console on
