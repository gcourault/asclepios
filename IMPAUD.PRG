/*
IMPAUD.PRG
PROGRAMA QUE IMPRIME PLANILLA DE AUDITORIA
*/

# include "inkey.ch"

function impaud()

initsup()
SELECT 1
IF SNET_USE("FAX","FAX1",.F.,5,.T.,;
            "No se puede acceder al archivo de Fax - ¨Reintenta?")
	SET ORDER TO TAG FAX
ELSE
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 042-554785")	
	RETURN
ENDIF
SELECT 3
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.T.,;
            "No se puede acceder al archivo IN1PRES - ¨Reintenta?")
	SET ORDER TO TAG PRCOD
ELSE
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 042-554785")	
	RETURN
ENDIF

SELECT 2
IF !SNET_USE("FACTU01","FACTU01",.F.,5,.T.,;
             "No se puede acceder al archivo FACTURA - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 042-554785")	
	RETURN
ENDIF
* --
SET RELATION TO PRESTADOR INTO PRESTADOR
* --
mfax := CaptFax("Impresi¢n de Planilla de Auditor¡a")

* --
IF MESSYN("¨Comienza la Impresi¢n")
	SET FILTER TO FAX == mfax
	QUIKREPORT("AUDITORIA")
ENDIF
RETURN


/* ----------------------------- */
  function CaptFax
/* ----------------------------- */
parameters cMensaje
private mfax,marriba
m->mfax = space( len( FAX ) )
m->marriba = makebox(5,2,8,78,sls_popcol())
centro( 6 , 2 , 78 , cMensaje )
while .t.
	@ 7,4 say "Ingrese el N§ de FAX:" get mfax pict "99999"
	set key K_F2 to scroller
	set key K_ALT_F2 to scmod
	read
	set key K_F2 to 
	set key K_ALT_F2 to 
	if abort()
		mfax := 0
		unbox(m->marriba)
		return mfax
	endif
	if messyn("¨Correcto?")
		exit
	endif
end
unbox(m->marriba)
return mfax
