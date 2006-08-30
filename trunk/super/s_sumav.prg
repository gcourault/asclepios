FUNCTION sum_ave(cSumOrAve)
LOCAL aStructure := dbstruct()
LOCAL aNumfields := {}
LOCAL aNumPosit  := {},nPosition
LOCAL bQuery
local cFieldName,nSelected,I,cMsg,lSummary,nCursor
local nResult := 0, nCount := 0

cSumOrAve := iif(cSumOrAve==nil,"SUM",cSumOrAve )

*- test for dbf open
IF !used()
  msg("Se requiere base de datos")
  RETURN ''
ENDIF


*- save cursor status,set cursor off
nCursor  := setcursor(0)
lSummary := (UPPER(cSumOrAve) = "SUM")

*- assign the appropriate message
IF lSummary
  cMsg := "Sumar el campo  :"
ELSE
  cMsg := "Media del campo :"
ENDIF

*- find the aNumfields and copy them to aNumfields[]
plswait(.T.,"Buscando campos num‚ricos...")
FOR i = 1 TO Fcount()
  IF aStructure[i,2] == "N"
    aadd(aNumfields,aStructure[i,1])
    aadd(aNumPosit,i)
  ENDIF
NEXT
plswait(.F.)

IF len(aNumFields)==0
  msg("No hay campos num‚ricos")
  SETCURSOR(nCursor)
  RETURN ''
ENDIF

*- ask for the numeric field to sum/average
nSelected  := mchoice(aNumfields,06,27,16,53,cMsg)

*- if a field was selected
DO WHILE .T.
  IF nSelected > 0
    nPosition  := aNumPosit[nSelected]
    cFieldName := aNumfields[nSelected]
    
    *- ask for OK to do sum/average
    IF messyn(cMsg+cFieldName)

      if messyn("¨Modifica o hace la consulta?")
        IF !EMPTY(sls_query()) .and. messyn("La consulta ya existe - ¨ La usa ?")
            bQuery := sls_bquery()
        ELSE
            QUERY()
            bQuery := sls_bquery()
        ENDIF
      endif
      
      GO TOP
      IF lSummary
        plswait(.T.,"Sumando....")
        DBEval({||nResult+=fieldget(nPosition)},bQuery, {||inkey()#27} )

      ELSE
        plswait(.T.,"Promediando..")
        DBEval({||nCount++,nResult+=fieldget(nPosition)},bQuery,{||inkey()#27})
        nResult := nResult/nCount
      ENDIF
      plswait(.F.)
      
      *- display the nResult
      IF lSummary
        msg("Suma del campo "+cFieldName+" = "+STR(nResult)+'  ' )
      ELSE
        msg("Media del campo "+cFieldName+" = "+STR(nResult)+'  ' )
      ENDIF
    ENDIF
  ENDIF
  EXIT
ENDDO
SETCURSOR(nCursor)
CLEAR TYPEAHEAD
RETURN nResult

