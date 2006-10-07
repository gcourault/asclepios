/*
RENDIC.PRG
Programa que permite rendir los cheques pagados
llamado por Resumen.prg
*/
external getdate

# include "inkey.ch"
function rendic()

IF !MESSYN("¨Contin£a?")
	RETURN
ELSE
	SELECT 1
	IF !SNET_USE("FACTU01","FACTURA",.F.,5,.F.)
		MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
		    "T.E. 042-554785")
		RETURN
	ENDIF
	SELECT 2
	IF SNET_USE("IN1PRES","PRESTADO",.F.,5,.F.)
		SET order TO tag PRCOD
	ELSE
		MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
		    "T.E. 0342-4554785")
		RETURN
	ENDIF
	SELECT 1
	SET RELATION TO PRESTADOR INTO PRESTADO
ENDIF

/*  --
m->mfax := CaptFax("Impresi¢n de Fax de Rendici¢n")
 --
if m->mfax == 0
	return
endif
*/
cFechadesd := space( 8 )
cFechahast := space( 8 )

popread( .t. , "Imprimir desde Fecha: " , @cFechadesd , "@D" ,;
               "         hasta Fecha: " , @cFechahast  , "@D" )
mensaje1 := "Desde fecha " + cFechadesd
mensaje2 := "Hasta fecha " + cFechahast
MSG("Ha seleccionado imprimir rendici¢n de las Facturas",mensaje1,mensaje2)
IF MESSYN("¨Comienza la Impresi¢n")
	SET FILTER TO FPRES >= ctod(cFechadesd) .and. FPRES <= ctod(cFechahast) .and. PRESTADOR = "S"
	GO TOP
	quikreportpdf( "RENDICION" )
ENDIF
RETURN

