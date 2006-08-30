
FUNCTION p_ready(cCheckPort,lAllowIgnore,lAllowChange)
local nPort,nAction,lReturn,lDoCheck,nDelaySec,nStartSec
lReturn := .t.
lDoCheck := sls_prnc()
nDelaySec := P_RDYDELAY()  // get delay factor in seconds
lAllowIgnore := iif(lAllowIgnore#nil,lAllowIgnore,.t.)
lAllowChange := iif(lAllowChange#nil,lAllowChange,.t.)
if valtype(cCheckPort)<>"C"
        cCheckPort = "LPT1"
else
        cCheckPort = upper(cCheckPort)
endif
while lDoCheck
   do case
   case cCheckPort == "LPT1"
     nPort := 0
   case cCheckPort == "LPT2"
     nPort := 1
   case cCheckPort == "LPT3"
     nPort := 2
   case "COM"$upper(cCheckPort)
     lReturn := .t.
     lDoCheck := .f.
   otherwise
     lReturn := .f.
     lDoCheck := .f.
   endcase

   * IS THE PRINTER READY
   nStartSec := seconds()
   IF lDoCheck.and. Isprn(nPort)
     lReturn := .t.
     exit
   else
     while (seconds()-nStartSec) < nDelaySec
        if Isprn(nPort)
          lReturn  := .t.
          lDoCheck := .f.
        endif
     end
   ENDIF

   *- loop until printer ready or user presses escape
   WHILE lDoCheck .and. !(Isprn(nPort))
     do case
     case lAllowIgnore .and. lAllowChange
       nAction := menu_v("La Impresora ("+cCheckPort+") aparentemente no est  lista",;
                         "Reintentar","Cancelar","Ignorar","Cambiar Impresora ")
     case lAllowIgnore
       nAction := menu_v("La Impresora ("+cCheckPort+") aparentemente no est  lista",;
                         "Reintentar","Cancelar","Ignorar")
     case lAllowChange
       nAction := menu_v("La Impresora ("+cCheckPort+") aparentemente no est  lista",;
                         "Reintentar","Cancelar","Cambiar Impresora")
     case !lAllowChange.and.!lAllowIgnore
       nAction := menu_v("La Impresora ("+cCheckPort+") aparentemente no est  lista",;
                         "Reintentar","Cancelar")
     endcase
     IF nAction == 3 .and. lAllowIgnore //Ignore
       lReturn := .t.
       lDoCheck := .f.
     ELSEIF nAction == 0 .OR. nAction == 2  // abort or escape
       lReturn := .f.
       lDoCheck := .f.
     ELSEIF nAction == 4  .or. (nAction == 3 .and. lAllowChange) //change port
       cCheckPort = prnport()
       if left(cCheckPort,3)=="COM" && no way to check, take users
                                      && word for it!
         lReturn := .t.
         lDoCheck := .f.
       else  // have to check the new port
         do case
         case cCheckPort == "LPT1"
           nPort := 0
         case cCheckPort == "LPT2"
           nPort := 1
         case cCheckPort == "LPT3"
           nPort := 2
         endcase
       endif
     ENDI
   ENDDO
   exit
enddo
RETURN lReturn

FUNCTION P_RDYDELAY(nDelaySec)
static nDelay := 5
nDelay := iif(nDelaySec#nil,nDelaySec,nDelay)
return nDelay

FUNCTION ISPRN(nPort)
return .t.
*: EOF: S_PREAD.PRG

