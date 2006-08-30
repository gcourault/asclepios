#INCLUDE "inkey.ch"
FUNCTION helpmod(cCallProc,xGarbage,cCallVar)

*- privates
local cOldProc,cOldVar,cOldColor,cScreen
local cKey,nTop,nLeft,nBott,nRight,cMemo,cFound
local nAction,cScreen2,nRow,nColumn,nOldArea,cHelpFile
local nOldCursor,bOldF10,lUsedOk
local cActionBox
local aActions :=  {;
                     "Edit Current Help Record",;
                     "Add New Help Record ",;
                     "Quit";
                   }

nRow            := ROW()
nColumn         := COL()
cScreen         := SAVESCREEN(0,0,24,79)
cOldColor       := Setcolor(sls_popcol())
nOldArea        := SELE()
nOldCursor      := setcursor(1)
bOldF10         := setkey(K_F10)
cHelpFile       := slsf_help()
lUsedOk         := .f.

*- make F10 be ctrl-w
SETKEY(K_F10,{||ctrlw()} )


*- figure out what PROC and VAR we're calling this from
cCallProc       := cCallProc+SPACE(10-LEN(cCallProc))
cCallVar        := iif("->"$cCallVar,SUBST(cCallVar,AT(">",cCallVar)+1),cCallVar)
cCallVar        := cCallVar+SPACE(10-LEN(cCallVar))

*- save them to holding variables
cOldPRoc        := cCallProc
cOldVar         := cCallVar

IF ISCOLOR()
  *- dim the background screen
  att(0,0,24,79,8)
ENDIF

sele 0
lUsedOk := opendbf(cHelpFile)

if lUsedOk
   *- look for a record matching the current PROC+VAR
   cKey := cCallProc+cCallVar
   SEEK cKey

   *- set cFound to the value of found()
   cFound := IIF(FOUND(),"FOUND","NOT FOUND")

   *- draw the screen
   Scroll(23,0,24,79,0)

   *- note calling PROC and VAR; and results of SEEK
   @23,0 SAY padc("* Help called from Module->"+RTRIM(cCallProc)+" , Variable->"+RTRIM(cCallVar),79)
   @24,0 SAY padc("* Help database matching record was: "+cFound,79)

endif

DO WHILE lUsedOk
  
  *- assign values in dbf to memvars
  cCallProc := __HELP->h_mod
  cCallVar  := __HELP->h_var
  nTop      := __HELP->hw_t
  nLeft     := __HELP->hw_l
  nBott     := __HELP->hw_b
  nRight    := __HELP->hw_r
  cMemo     := __HELP->h_memo
  
  *- draw the menu screen
  cActionBox :=makebox(5,25,17,55,sls_popcol())
  
  *- note what help record we are sitting on top of
  @6,26 SAY "Current HELP record:"
  if recc() > 0
    @7,26 SAY "[Module  :"+RTRIM(__HELP->h_mod)+"]"
    @8,26 SAY "[Variable:"+RTRIM(__HELP->h_var)+"]"
  else
    @7,26 SAY "[Module  : None]"
    @8,26 SAY "[Variable: None]"
  endif
  
  *- achoice menu
  nAction := SACHOICE(11,26,16,53,aActions)

  unbox(cActionBox)
  
  
  *- do actions based on the choice
  DO CASE
  CASE nAction = 1 .AND. !EOF()
    *- edit help screen
    IF messyn("Edit "+RTRIM(__HELP->h_mod)+' '+RTRIM(__HELP->h_var))
      cScreen2 := savescreen(0,0,24,79)
      winloop(1,@cMemo,@nTop,@nLeft,@nBott,@nRight,cCallProc,cCallVar)
      RESTSCREEN(0,0,24,79,cScreen2)
    ENDIF
  CASE nAction = 2
    *- add a new help screen
    IF messyn("Add HELP record for "+RTRIM(cOldPRoc)+' '+RTRIM(cOldVar))
      
      *- default values
      cCallProc := cOldPRoc
      cCallVar  := cOldVar
      nTop      := 10
      nLeft     := 10
      nBott     := 15
      nRight    := 40
      cMemo     := ''

      cScreen2  := savescreen(0,0,24,79)
      winloop(0,@cMemo,@nTop,@nLeft,@nBott,@nRight,cCallProc,cCallVar)
      RESTSCREEN(0,0,24,79,cScreen2)

    ENDIF
  CASE nAction == 3
    EXIT
  ENDCASE
ENDDO
USE
SELECT (nOldArea)
SETKEY(-9,bOldF10)
Setcolor(cOldColor)
RESTSCREEN(0,0,24,79,cScreen)
DEVPOS(nRow,nColumn)
SETCURSOR(nOldCursor)
RETURN ''

//=====================================================
STATIC FUNCTION winloop(nAddEdit,cMemo,nTop,nLeft,nBott,nRight,cCallProc,cCallVar)

local cScreen3,nLastKey

*- draw the elements of this screen
Setcolor(sls_popcol())
Scroll(23,0,24,79,0)
@23,0 TO 23,79
@24,0 say '(C)hange size or position         (E)dit window contents          (Q)uit'

*- and then save this screen
cScreen3 := savescreen(0,0,24,79)

*- main loop
DO WHILE .T.
  
  *- disp_mem is a function below - displays the memo
  disp_mem(@cMemo,nTop,nLeft,nBott,nRight)
  
  *- wait for a keystroke
  INKEY(0)
  nLastKey := LASTKEY()
  
  
  DO CASE
  CASE nLastKey = 67 .OR. nLastKey = 99
    *- change the window size/position
    RESTORE SCREEN FROM cScreen3
    *- movewin is a function below
    movewin(cMemo,@nTop,@nLeft,@nBott,@nRight)
  CASE nLastKey = 101 .OR. nLastKey = 69
    *- edit the help cMemo
    @23,0 CLEAR
    @23,0 TO 23,79
    @24,0 SAY '        press F10 to save                 ESCAPE to abort '
    cMemo = Memoedit(cMemo,nTop+1,nLeft+1,nBott-1,nRight-1)
  CASE nLastKey = 81 .OR. nLastKey = 113
    *- quit
    *- h_yn is a function below
    IF messyn("Save this record ?")
      IF nAddEdit = 0
        *- if add
        IF !SADD_REC(5,.T.,"Unable to lock record to save. Keep trying?")
           EXIT
        ENDIF
      ENDIF
      *- place the memvars into the fields
      IF SREC_LOCK(5,.T.,"Unable to lock record for REPLACE. Keep trying?")
        REPLACE  __HELP->h_memo WITH cMemo,__HELP->hw_t WITH nTop,__HELP->hw_l WITH nLeft,;
          __HELP->hw_b WITH nBott,__HELP->hw_r WITH nRight,__HELP->h_mod WITH cCallProc,;
          __HELP->h_var WITH cCallVar
      endif
      unlock
    ENDIF
    EXIT
  ENDCASE
  RESTSCREEN(0,0,24,79,cScreen3)
ENDDO
RETURN ''


STATIC FUNCTION movewin(cMemo,nTop,nLeft,nBott,nRight)  // dims by reference

local nLastKey,cMoveWinScreen

*- put new instructions at the bottom
@23,0 CLEAR
@23,0 TO 23,79
@24,0  say ' To Move use ['+CHR(24)+CHR(25)+CHR(26)+CHR(27)+'] , To resize use [PGUP PGDN HOME END].      ESC when done'

nLastKey := 0

*- save the underlying screen
cMoveWinScreen := savescreen(0,0,24,79)


DO WHILE .T.
  dispbegin()

  *- each time through, restore the underlying screen
  restscreen(0,0,24,79,cMoveWinScreen)
  
  *- if the next keystroke is not an arrow, display the help window at
  *- its new coordinates
  *- (arrows() determines if nextkey() is an arrow key)
  IF !arrows()
    disp_mem(cMemo,nTop,nLeft,nBott,nRight)
  ENDIF

  dispend()
  
  *- wait for another key
  nLastKey := INKEY(0)
  
  DO CASE
  CASE nLastKey = K_ESC
    EXIT
  CASE nLastKey = K_RIGHT
    IF ! nRight > 78
      nRight++
      nLeft++
    ENDIF
  CASE nLastKey = K_UP
    IF ! nTop < 2
      nTop--
      nBott--
    ENDIF
  CASE nLastKey = K_LEFT
    IF ! nLeft < 2
      nLeft--
      nRight--
    ENDIF
  CASE nLastKey = K_DOWN
    IF ! nBott > 22
      nBott++
      nTop++
    ENDIF
  CASE nLastKey = K_PGUP
    IF ! (nTop+3) > nBott
      nBott--
    ENDIF
  CASE nLastKey = K_PGDN
    IF ! nBott > 22
      nBott++
    ENDIF
  CASE nLastKey = K_HOME
    IF nRight >  (nLeft+30)
      nRight--
    ENDIF
  CASE nLastKey = K_END
    IF ! nRight > 78
      nRight++
    ENDIF
  ENDCASE
ENDDO
return nil

///===================================================================
static PROC disp_mem(cMemo,nTop,nLeft,nBott,nRight)
dispbegin()
dispbox(nTop,nLeft,nBott,nRight)
Memoedit(cMemo,nTop+1,nLeft+1,nBott-1,nRight-1,.F.,.F.)
dispend()
RETURN

///===================================================================
STATIC FUNCTION arrows
local nNextKey := nextkey()
RETURN ( (nNextKey = K_LEFT).OR.(nNextKey = K_RIGHT).OR.;
         (nNextKey = K_UP).OR.(nNextKey = K_DOWN) )

///===================================================================
STATIC FUNCTION opendbf(cHelpFile)
IF !( FILE(cHelpFile+".DBF") .AND. FILE(cHelpFile+".DBT") )
  blddbf(cHelpFile,"h_mod,C,10:h_var,C,10:h_memo,M,10:hw_t,N,2:hw_l,N,2:hw_b,N,2:hw_r,N,2:")
ENDIF

IF ( FILE(cHelpFile+".DBF") .AND. FILE(cHelpFile+".DBT") )
  IF SNET_USE(cHelpFile,"__HELP",.F.,5,.T.,"Network error opening HELP file. Keep trying?")
    if !FILE( cHelpFile+INDEXEXT() )
      INDEX ON __HELP->h_mod+__HELP->h_var TO (cHelpFile)
    ENDIF
    SET INDEX TO (cHelpFile)
  endif
ENDIF
RETURN ( USED() )

