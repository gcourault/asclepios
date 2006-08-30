
FUNCTION abort(cBoxColor,nTop,nLeft,nBottom,nRight)
LOCAL nSelection,cUnderScreen
local nPcount := pcount()
IF !LASTKEY() = 27
  RETURN .F.
ENDIF

*- do a menu while last key is escape
IF nPcount< 5
  cUnderScreen:=makebox(9,28,13,53,IIF(nPcount> 0,cBoxColor,sls_popmenu()))
ELSE
  cUnderScreen:=makebox(nTop,nLeft,nBottom,nRight,IIF(nPcount> 0,cBoxColor,;
                        sls_popmenu()))
ENDIF

DO WHILE LASTKEY() = 27
  IF nPcount < 5
    @11,30 PROMPT "Cancelar"
    @11,41 PROMPT "No Cancelar"
  ELSE
    @nTop+1,nLeft+2 PROMPT  "Cancelar"
    @ROW(),COL()+2 PROMPT "No Cancelar"
  ENDIF
  MENU TO nSelection
ENDDO
unbox(cUnderScreen)

RETURN (nSelection= 1)

