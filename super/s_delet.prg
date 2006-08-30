FUNCTION delrec
local cMessage,nSelection,lYesOrNo,cUnderScreen,nOldCursor
local nReturn := 0

IF Used()

   *- set cursor off
   nOldCursor      := setcursor(0)

   *-draw the box
   cUnderScreen    :=makebox(12,25,14,55,sls_popcol())

   *- determine the message/prompt and prompt it
   nSelection      := 1
   cMessage        := IIF(DELE(),"Des-Borrar Registro","Borrar Registro")

   @13,27 PROMPT cMessage
   @13,45 PROMPT "No Actuar"
   MENU TO nSelection

   *- figure out what to do, based on the user's request
   lYesOrNo := (nSelection == 1)
   if SREC_LOCK(5,.T.,"Error de Red - No se puede bloquear el registro. ¨Reintenta?")
     IF lYesOrNo
       IF DELE()
         RECALL
         nReturn := -1
       ELSE
         DELETE
         nReturn := 1
       ENDIF
       unlock
       goto recno()
   endif
   ELSE
     nReturn := 0
   ENDIF
   unbox(cUnderScreen)
   *- set cursor to prior
   setcursor(nOldCursor)
endif
RETURN nReturn

