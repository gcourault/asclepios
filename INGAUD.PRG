/*----------------------------------------------------------------
IngAud.prg
Programa para ingrsar d‚bitos de auditor¡a
llamado por resumen.prg
------------------------------------------------------------------*/

# include "inkey.ch"

function ingaud()
initsup()
*-
SELECT 1
IF !SNET_USE("FACTU01","FACTURA",.F.,5,.T.,;
             "No se puede acceder al archivo FACTURA - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 042-554785 * 042-553511 / 066")	
	RETURN
ENDIF

SELECT 2
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.F.)
	SET order TO tag PRCOD
ELSE
	MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
	    "T.E. 042-554785")
	RETURN
ENDIF

SELECT 1
SET RELATION TO PRESTADOR INTO PRESTADOR


mfax := CaptFax("Impresi¢n de Cheques")
mensaje1 := "Del FAX N§ " + mfax
MSG("Ha seleccionado Auditar Facturas",mensaje1)
IF MESSYN("¨Correcto?")
	aCampos := {"B->PRNOMB","FACTURA","FPRES","TOTFACTU","TOTDEB"}
	aDescr  := {"N§ Prestador","N§ Factura","Fecha","Monto Factura","D‚bitos"}
	set filter to FAX == mfax
	go top
	editdb( .t. , aCampos , aDescr, .t. )
ENDIF
set filter to
close databases
return
