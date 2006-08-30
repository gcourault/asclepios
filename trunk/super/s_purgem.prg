FUNCTION purgem
local i
local nLenTagged
local aTags := {}

IF !used()
  msg("Se requiere una base de datos")
  RETURN ''
ELSEIF RECCOUNT()=0
  msg("No hay registros en el archivo")
  RETURN ''
ENDIF
tagit(aTags,"","","Marque registros a Borrar")

IF len(aTags) > 0
  nLenTagged = len(aTags)
  IF messyn("¨Borra los registros marcados?")
    GO TOP
    plswait(.t.,"Deleting...")
    for i = 1 to nLenTagged
      go ( aTags[i] )
      if SREC_LOCK(5,.T.,"Error de red - No se puede bloquear el registro. ¨Reintenta?")
         DELETE
         unlock
      endif
    next
    plswait(.f.)
  ENDIF
ELSE
  msg("No hay registros marcados para borrar")
ENDIF
RETURN ''

