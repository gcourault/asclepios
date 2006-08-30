FUNCTION HELP(cProc,xGarbage,cVar)

local nCol,nRow,nOldArea,cKey,cHelpFile,cBox

cHelpFile := slsf_help()
nCol      := COL()
nRow      := ROW()

*- figure out the calling PROC-VARIABLE
cProc := cProc+SPACE(10-LEN(cProc))
cVar  := iif("->"$cVar,SUBST(cVar,AT(">",cVar)+1),cVar)
cVar  := cVar+SPACE(10-LEN(cVar))

*- save the area we're in
nOldArea := SELE()
select 0

*- be sure there's a help DBF/DBT/NDX(NTX)
IF FILE(cHelpFile+".DBF") .AND. FILE(cHelpFile+".DBT") .AND.;
        ( FILE(cHelpFile+indexext())  )
  IF !SNET_USE(cHelpFile+".DBF","__HELP",;
     .F.,5,.T.,"Error de red abriendo archivo de AYUDA. ¨Reintenta?")
  else
     set index to (cHelpFile)
  endif
ELSE
  msg("No se encontr¢ ayuda")
ENDIF

IF USED()
    *- see if there's a matching HELP.DBF record
    cKey :=cProc+cVar
    SEEK cKey

    *- if found, display the help, otherwise display a no-help message.
    IF FOUND()
      cBox :=makebox( __HELP->hw_t, __HELP->hw_l, __HELP->hw_b, __HELP->hw_r,;
                      sls_popcol())
      @__HELP->hw_t,__HELP->hw_l+2 SAY "Ayuda:"
      @__HELP->hw_b,__HELP->hw_l+2 SAY "Pulse escape"
      Memoedit(__HELP->h_memo,__HELP->hw_t+1,__HELP->hw_l+1,__HELP->hw_b-1,;
               __HELP->hw_r-1,.F.)
      unbox(cBox)
    ELSE
      msg("No se encontr¢ ayuda")
    ENDIF

    *- USE the help DBF, and put things back as they were
ENDIF
USE
DEVPOS(nRow,nCol)
SELECT (nOldArea)
RETURN ''


