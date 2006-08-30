FUNCTION fastform

LOCAL nOldArea,nPageWidth,cScreen,cTempForm,nLeftMargin,cFormFile
LOCAL getlist := {}

*- default of 80 CPI
nPageWidth  := 80
nLeftMargin := 0
cFormFile  := SLSF_FORM()
cScreen     := savescreen(0,0,24,79)

*- check for file
IF !FILE(cFormFile+".dbf")
  RETURN .F.
ENDIF

*- save old selected area
nOldArea := SELECT()

*- select new area and open FORM
SELECT 0
IF !SNET_USE(cFormFile,"__FORMS",.f.,5,.t.,"No se puede abrir archivo de formularios. ¨Reintenta?")
   SELECT (nOldArea)
   RETURN .F.
ENDIF

*- call SMALLS() to select form from DESCRIPT field
smalls("descrip","Seleccione Formulario - o Pulse Escape")

*- if not escaped out of
IF !LASTKEY() = 27
  popread(.f.,"Margen Izquierdo ->",@nLeftMargin,"99")

  *- and printer is ready
  IF p_ready(sls_prn())
    cScreen     := savescreen(0,0,24,79)

    SET PRINT ON
    CLEAR
    cTempForm := __FORMS->memo_orig
    
    *- close the database and go back to prior one
    USE
    SELECT (nOldArea)
    
    *- print the form
    prntfrml(cTempForm,nPageWidth,nLeftMargin)
    EJECT
    SET PRINT OFF
    restscreen(0,0,24,79,cScreen)
  ELSE
    
    *- close the database
    USE
    SELECT (nOldArea)
    
  ENDIF
ELSE
  *- close the database
  USE
  SELECT (nOldArea)
ENDIF
RETURN ''


