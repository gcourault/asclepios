/*
RENDIC.PRG
Programa que permite rendir los cheques pagados
llamado por Resumen.prg
*/
# include "inkey.ch"

function rendtodo()
IF !MESSYN("¨Contin£a?")
	RETURN
ELSE
	SELECT 1
	IF !SNET_USE("FACTU01","TEMPO",.F.,5,.F.)
		MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
		    "T.E. 042-554785")
		RETURN
	ELSE
		set order to tag fpres
	ENDIF
	SELECT 2
	IF SNET_USE("IN1PRES","PRESTADO",.F.,5,.F.)
		SET order TO tag PRCOD
	ELSE
		MSG("Error en la Red - Llamar a Soporte T‚cnico:",;
		    "T.E. 042-554785")
		RETURN
	ENDIF
	SELECT 1
	SET RELATION TO PRESTADOR INTO PRESTADO
ENDIF

if messyn("¨Genera una consulta?")
	cConsulta := query()
	set filter to &cConsulta
endif

IF MESSYN("¨Comienza la Impresi¢n?")
		quikreport("RENDICION")
ENDIF
RETURN

