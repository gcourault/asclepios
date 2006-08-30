*                      SMODULE C   8   proc_nam from SET KEY
*                      SFIELD  C  10   Variable name from SET KEY
*                      SDESCR  C  25   Description field used as title
*                      SSTRING C 160   Say string - what is displayed
*                                      in the lookup box
*                      SRETURN C  75   Return string - what is sent to
*                                      the keyboard via KEYBOARD
*                      SDBFILE C   8   Lookup DBF file name
*                      SIND    C   8   Lookup Index file name

FUNCTION scroller(cProcName,xGarbage,cProcVar)
local cDisplay   := ""
local cReturn    := ""
local cDbfName   := ""
local cTitle     := ""
local nRecNumber := recno()
local nOldArea   := select()

cProcVar := iif("->"$cProcVar,SUBST(cProcVar,AT(">",cProcVar)+1),cProcVar)

IF !FILE(slsf_scroll()+".DBF")
   msg("No existe archivo de definici¢n de b£squedas - "+slsf_scroll())
   RETURN ''
ENDIF

DO WHILE .T.
    *- FIND THE APPROPRIATE RECORD IN SCROLLER.DBF
    SELECT 0
    IF SNET_USE(slsf_scroll(),"__SCROLL",.F.,5,.F.,"No se puede abrie "+;
                 slsf_scroll()+". ¨Reintenta?")
       LOCATE FOR __scroll->smodule=cProcName .AND. ;
                  __scroll->sfield=cProcVar .and. !deleted()
       IF .NOT. FOUND()
          msg("No se encontr¢ tabla de b£squeda.")
          USE
          EXIT
       ENDI

       cDisplay := "IF(DELE(),'ð',' ')+"+RTRIM(__SCROLL->sstring)
       cTitle   := RTRIM(__SCROLL->sdescr)
       IF EMPTY(TRIM(cTitle))
          cTitle := ""
       ENDIF
       cDbfName := UPPER(Alltrim(__SCROLL->sdbfile))
       if !empty(cDbfName)
         cDbfName := "%"+cDbfName+"%"
         if !empty(__SCROLL->sind)
            cDbfName := cDbfName+ALLTRIM(__SCROLL->sind)
         endif
       else
         cDbfName := nil
       endif
       cReturn := __SCROLL->sreturn
       USE

       select (nOldArea)
       IF nRecNumber > 0
         go (nRecNumber)
       ENDIF

       * CALL SMALLS
       if !empty(cReturn)
         SMALLS(cDisplay,cTitle,cDbfName,cReturn)
       else
         SMALLS(cDisplay,cTitle,cDbfName)
       endif
    endif
    EXIT
ENDDO
SELECT (nOldArea)
RETURN 0


