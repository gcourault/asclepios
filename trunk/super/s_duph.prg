#include "inkey.ch"
#define K_SPACE 32
function DUPHANDLE(aFields,aDesc,aOpenIndexes)

local aCharFields := {}
local aCharDesc   := {}
local aTagged     := {}
local aLogical
local cInscreen := SAVESCREEN(0,0,24,79)
local cOldColor := Setcolor()
local nOldCursor:= setcursor(0)
local bOldf10   := SETKEY(K_F10)
local nFieldCount,nSelection
local cTempNTX,cIndexExpr,bIndexExpr
local aTagAction := {}
local cEmpty,i

IF !USED()
  RETURN ''
ENDIF

aOpenIndexes  := iif(aOpenIndexes#nil,aOpenIndexes,{})
asize(aOpenIndexes,10)
for i = 1 to 10
  if aOpenIndexes[i]==nil
    aOpenIndexes[i] := ""
  endif
next



if aFields==nil .or. aDesc==nil
  aFields := afieldSx()
  aDesc   := aclone(aFields)
endif
for i = 1 to len(aFields)
  if type(aFields[i])=="C"
    aadd(aCharFields,aFields[i])
    aadd(aCharDesc,aDesc[i])
  endif
next

nFieldCount     := len(aCharFields)
aLogical        := array(nFieldCount)
Afill(aLogical,.F.)

Setcolor(sls_normcol())
@0,0,24,79 BOX sls_frame()
*- draw the screen
Setcolor(sls_popcol())
@1,1,9,45 BOX sls_frame()
@21,1,23,78 BOX sls_frame()
@1,2 SAY '[ Administrador de Duplicados ]'

SET PRINTER TO (sls_prn())

*- main loop
DO WHILE .T.
  @22,2 say padc(alltrim(str(len(aTagAction)))+" Registros duplicados marcados",SBCOLS(2,78,.f.))
  GO TOP
  *- do the menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Selecci¢n de Campos Duplicados  "
  ??iif(len(aTagged)>0,"[Terminado]","           ")
  @03,3 PROMPT "Construir Indice de Duplicados  "
  ??iif(!empty(cTempNtx),"[Terminado]","          ")
  @04,3 PROMPT "Guscar/Marcar Campos Duplicados "
  ??iif(len(aTagAction)>0,"[Terminado]","         ")
  @05,3 PROMPT "Procesar los Duplicados Marcados  "
  @06,3 PROMPT "Limpiar los duplicados marcados   "
  @07,3 PROMPT "Salir"
  MENU TO nSelection
  Setcolor(sls_popcol())
  
  
  DO CASE
  CASE nSelection = 1
    set index to
    if !empty(cTempNTX)
       erase (getdfp()+cTempNTX)
    endif
    cTempNtx := ""
    aTagged := tagarray(aCharDesc,nil,nil,aLogical)
    
  CASE nSelection = 2 .AND. len(aTagged) > 0
    
    *- look for duplicates, write them to a file
    
    PROGON("Indexando")

    *- make a temp index
    set index to
    if !empty(cTempNTX)
       erase (getdfp()+cTempNTX)
    endif
    cTempNTX := UNIQFNAME(RIGHT(INDEXEXT(),3),getdfp())
    cIndexExpr := ""
    aeval(aTagged,{|e|cIndexExpr+=[+]+aCharFields[e]})
    cEmpty := repl(chr(254),len(&cIndexExpr) )
    bIndexExpr  := &("{||iif(!empty("+cIndexExpr+"),"+cIndexExpr+",["+cEmpty+"])}" )

    dbcreateindex(cTempNtx,"("+cIndexExpr+")",{||ProgDisp( recno(),recc() ),eval(bIndexExpr) },.f.)
    ProgOff()

    set index to     // this is needed to detach the hairy codeblock above


  CASE nSelection = 3 .and. !empty(cTempNtx)
    set index to (cTempNtx)
    aTagAction := perform(aFields,aDesc,bIndexExpr)
    
  CASE nSelection = 4 .and. len(aTagAction) > 0
    process(aTagaction)

  CASE nSelection = 5
    aTagaction := {}
  CASE nSelection = 6 .OR. nSelection = 0
    set index to
    if !empty(cTempNTX)
       erase (getdfp()+cTempNTX)
    endif
    SET INDEX TO (aOpenIndexes[1]),(aOpenIndexes[2]),(aOpenIndexes[3]),(aOpenIndexes[4]),(aOpenIndexes[5]),(aOpenIndexes[6]),(aOpenIndexes[7]),(aOpenIndexes[8]),(aOpenIndexes[9]),(aOpenIndexes[10])
    RESTSCREEN(0,0,24,79,cInscreen)
    Setcolor(cOldColor)
    setcursor(nOldCursor)
    SETKEY(-9,bOldf10)
    exit
  ENDCASE
ENDDO
return ''


//-------------------------------------------------------------------
static function perform(aFields,aDesc,bIndexExpr)
local nLogBeg := 1
local nLogEnd := 1
local oTb
local i,lEndofFile := .f.
local cBox
local aTagged := {}
local nLastKey,nFoundTagged
local cKeyCurrent

oTb := tbrowsenew(5,5,18,75)
oTb:addcolumn(TBColumnNew('Marcar',{||iif(is_it_tag(recno(),aTagged) ,'û',' ')} ))
for i = 1 to len(aFields)
  oTb:addcolumn(tbColumnNew(aDesc[i],expblock( aFields[i] )))
next
oTb:skipblock     := {|n|dupskip(n,nLogBeg,nLogEnd)}
oTb:gotopblock    := {||dbgoto(nLogBeg)}
oTb:gobottomblock := {||dbgoto(nLogEnd)}
oTb:headsep := "Ä"


oTb:freeze  := 1
cKeyCurrent := ""
cBox := makebox(4,4,21,76)
scroll(5,5,20,75,0)
@5,5 say "Buscando el pr¢ximo conjunto de duplicados..."
DO WHILE !lEndOfFile
  cKeyCurrent := eval(bIndexExpr)
  if chr(254)$cKeyCurrent
     exit
  endif

  *- store the record #
  nLogBeg    := RECNO()
  nLogEnd    := 0

  *- go to next record
  SKIP
  While (!EOF()) .AND. (eval(bIndexExpr) == cKeyCurrent)
      nLogEnd := recno()
      skip
      lEndOfFile := EOF()
  end
  if nLogEnd > 0
     @19,6 to 19,74
     @20,6 SAY padc(CHR(24)+CHR(25)+CHR(26)+CHR(27)+;
         " SPACE=tag  ENTER=next set   F10=done",SBCOLS(6,74,.F.))
     go nLogBeg
     oTb:refreshall()
     oTb:rowpos := 1
     while .t.
       while !oTb:Stabilize()
       end
       nLastkey := inkey(0)
       do case
       case nLastkey == K_F10
         exit
       case nLastKey == K_ENTER
         exit
       case nLastKey == K_UP
         oTb:up()
       case nLastKey == K_DOWN
         oTb:down()
       case nLastKey == K_HOME
         oTb:gotop()
       case nLastKey == K_END
         oTb:gobottom()
       case nLastKey == K_RIGHT
         oTb:right()
       case nLastKey == K_LEFT
         oTb:left()
       case nLastKey == K_SPACE
         *- LOOK FOR RECORD # IN ARRAY
         nFoundTagged = aSCAN(aTagged,recno())
         if nFoundTagged > 0
           aDEL(aTagged,nFoundTagged)
           ASIZE(aTagged,len(aTagged)-1)
         else
           aadd(aTagged,recno())
         endif
         oTb:REFRESHCURRENT()
       endcase
     end
     scroll(5,5,20,75,0)
     if nLastKey==K_F10
       if messyn("End search?")
         exit
       endif
     endif
     @5,5 say "Buscando el Pr¢ximo conjunto de duplicados..."
     go nLogEnd
     skip
     lEndOfFile := EOF()
  endif
ENDDO
unbox(cBox)
return aTagged

//-------------------------------------------------------------------
static func dupskip(n,nLogBeg,nLogEnd)
  local skipcount := 0
  do case
  case n > 0
    do while recno()#nLogEnd .and. skipcount < n
      skip
      skipcount++
    enddo
  case n < 0
    do while recno()#nLogBeg .and. skipcount > n
      skip -1
      skipcount--
    enddo
  endcase
return skipcount

//-------------------------------------------------------------------
static FUNCTION is_it_tag(nRecnum,aTagged)
RETURN (Ascan(aTagged,nRecnum)> 0)




//-------------------------------------------------------------------
static function process(aTagged)
local cBox    := makebox(4,13,17,47)
local nTagged := len(aTagged)
local nChoice,cDbfName
local lContinue := .t.
local nProcessed
@ 6,16 SAY "["+alltrim(str(nTagged))+" Registros marcados]"
do while .t.
     @8,16 PROMPT 'Borrar los registros marcados    '
     @9,16 PROMPT 'Borrar los registros NO marcados '
     @11,16 PROMPT 'Copiar los registros marcados   '
     @12,16 PROMPT 'Copiar los registros NO marcados'
     @14,16 PROMPT 'Salir al Men£ principal         '
     menu to nChoice
     do case
        CASE nChoice = 1
           if messyn("¨Borra todos los registros marcados?")
              lContinue  := .t.
              nProcessed := 0
              PROGON("Borrando los registros marcados")
              set order to 0
              dbgotop()
              DBEVAL({||lContinue := dhdelete()},;
                     {||ascan(aTagged,recno())>0},;
                     {||progdisp(nProcessed++,recc() ),lContinue}  )

              PROGOFF()
              set order to 1
           endif
        CASE nChoice = 2
           if messyn("¨Borra todos los registros NO marcados?")
              lContinue  := .t.
              nProcessed := 0
              PROGON("Borrando los registros NO marcados")
              set order to 0
              dbgotop()
              DBEVAL({||lContinue := dhdelete()},;
                     {||ascan(aTagged,recno())=0},;
                     {||progdisp(nProcessed++,recc() ),lContinue}  )

              PROGOFF()
              set order to 1
           endif
        CASE nChoice = 3
           if messyn("¨Copia todos los registros marcados?")
              cDbfName := getdbfname("")
              IF !EMPTY(cDbfName) .and. messyn("¨Sigue con la copia?")
                dbgotop()
                nProcessed := 0
                ProgOn("Copiando los registros marcados")
                copy to (cDbfNAme) for (ascan(aTagged,recno())>0) ;
                    while ProgDisp(nProcessed++,recc())
                ProgOff()
              ENDIF
           endif
        CASE nChoice = 4
          if messyn("¨Copia los registros NO marcados?")
             cDbfName := getdbfname("")
            IF !EMPTY(cDbfName) .and. messyn("¨Sigue con la copia?")
              dbgotop()
              nProcessed := 0
              ProgOn("Copiando los registros NO marcados")
              copy to (cDbfName) for (ascan(aTagged,recno())=0)  ;
                   while ProgDisp(nProcessed++,recc())
              ProgOff()
            ENDIF
         endif
        CASE nChoice = 5
          exit
     endcase
enddo
unbox(cBox)
return nil



static function dhdelete()
local lReturn := .t.
if rlock()
  dbdelete()
  unlock
else
  IF SREC_LOCK(5,.T.,"No se puede bloquear el registro para borrar. ¨Reintenta?")
    dbdelete()
    unlock
  ELSE
    if !messyn("¨Abandona la operaci¢n?","No","Si")
      lReturn := .f.
    endif
  ENDIF
endif
return lReturn


//-------------------------------------------------------------
static FUNCTION getdbfname(cDbfName)

DO WHILE .T.
  cDbfName = PADR(cDbfName,35)
  popread(.F.,"Nombre del archivo destino : ",@cDbfName,"@!")
  IF EMPTY(cDbfName)
    EXIT
  ENDIF
  cDbfName := Alltrim(cDbfName)
  cDbfName := IIF(.NOT. ".DBF" $ cDbfName, cDbfName+".DBF",cDbfName)
  
  *- if it already exists, don't overwrite it
  *- loop around and get another filespec
  IF FILE(cDbfName)
      MSG("Base de datos "+cDbfName+" ya existe - ","Use otro nombre")
      cDbfName := ''
      LOOP
  ENDIF
  EXIT
ENDDO
return cDbfName

