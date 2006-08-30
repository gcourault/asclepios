*                      calling procedure......... 1  SMODULE     C  10
*                      calling variable.......... 2  SFIELD      C  10
*                      description............... 3  SDESCR      C  25
*                      display string............ 4  SSTRING     C  160
*                      return string............. 5  SRETURN     C  75
*                      dbf file to lookup into... 6  SDBFILE     C  8
*                      index to use with dbf..... 7  SIND        C  8


#define SC_PROCNAME      1
#define SC_VARNAME       2
#define SC_TITLE         3
#define SC_DISPLAY       4
#define SC_RETURN        5
#define SC_DBFNAME       6
#define SC_NTXNAME       7

FUNCTION scmod(cProcName,xGarbage,cVarName)

local cScrollFile := slsf_scroll()
local nOldArea    := select()
local cOldAlias   := alias()
local cOldColor   := setcolor(sls_normcol())
local bOldF10     := setkey(-9)
local nOldCursor  := setcursor(0)
LOCAL aValues     := array(7)
local cDbfParam
local nRow := row()
local nCol := col()

local nAction,lExists

cVarName := iif("->"$cVarName,SUBST(cVarName,AT(">",cVarName)+1),cVarName)

*- open next area
SELECT 0

*- build scroller.dbf if not present
IF !FILE(cScrollFile+".DBF")
   blddbf(cScrollFile,'SMODULE,C,10:SFIELD,C,10:SDESCR,C,25:SSTRING,C,160:SRETURN,C,75:SDBFILE,C,8:SIND,C,8:')
ENDIF

*- use scroller
IF SNET_USE(cScrollFile,"__SCROLLER",.F.,5,.F.,"Unable to open "+cScrollFile+". Keep trying?")
   GO TOP

   *- find module and field passed by set key
   LOCATE FOR __scroller->smodule = cProcName .AND.;
              __scroller->sfield = cVarName .and. !deleted()
   lExists := found()

   DO WHILE .T.
      if lExists
           nAction := menu_v("Lookup definition found",;
                           "Edit it?",;
                           "Back to program",;
                           "Test lookup",;
                           "Delete it")
      else
           nAction := menu_v("Lookup definition not found",;
                           "Add one?",;
                           "Back to program")
      endif

      DO CASE
      CASE nAction = 2 .OR. nAction = 0
         EXIT
      CASE nAction =1  .AND. !lExists    && add
        aValues[SC_PROCNAME] :=  cProcName
        aValues[SC_VARNAME]  :=  cVarName
        aValues[SC_TITLE]    :=  SPACE(25)
        aValues[SC_DISPLAY]  :=  SPACE(160)
        aValues[SC_RETURN]   :=  SPACE(75)
        aValues[SC_DBFNAME]  :=  SPACE(8)
        aValues[SC_NTXNAME]  :=  SPACE(8)
        if scedit(aValues,cProcName,cVarName,cOldAlias)
          if add()
            save(aValues)
            lExists := .t.
          endif
        endif
      CASE nAction = 1 .AND. lExists   && edit
        aValues[SC_PROCNAME] :=   __scroller->smodule
        aValues[SC_VARNAME]  :=   __scroller->sfield
        aValues[SC_TITLE]    :=   __scroller->sdescr
        aValues[SC_DISPLAY]  :=   __scroller->sstring
        aValues[SC_RETURN]   :=   __scroller->sreturn
        aValues[SC_DBFNAME]  :=   __scroller->sdbfile
        aValues[SC_NTXNAME]  :=   __scroller->sind
        if scedit(aValues,cProcName,cVarName,cOldAlias)
          save(aValues)
        endif
      CASE nAction = 3  .and. !empty(aValues[SC_DISPLAY]) && test
         cDbfParam := nil
         IF !empty(aValues[SC_DBFNAME])
           cDbfParam := "%"+trim(aValues[SC_DBFNAME])+"%"
           IF !empty(aValues[SC_NTXNAME])
              cDbfParam += ALLTRIM(aValues[SC_NTXNAME])
           endif
         ENDIF
         select (nOldArea)
         SMALLS(trim(aValues[SC_DISPLAY]),trim(aValues[SC_TITLE]),cDbfParam)
         select __scroller
      CASE nAction = 4   && delete
         if messyn("Are you sure you want to delete it?")
           if SREC_LOCK(5,.T.,"Network error - Unable to lock record. Keep trying?")
             delete
             unlock
           ENDIF
         endif
      ENDCASE
   ENDDO
endif
*- close scroller.dbf
USE
SELECT (nOldArea)
setkey(-9,bOldF10)
SETCURSOR(nOldcursor)
SETCURSOR(cOldColor)
devpos(nRow,nCol)
return ''
//----------------------------------------------------------
//-------------------------------------------------------------------------
STATIC function scedit(aValues,cProcName,cVarName,cAlias)
local cPopBox := makebox(3,0,23,79)
local nSelect
local aFieldList,aFieldtypes
local cTempFile,cTempString
local getlist := {}
@ 3,2 SAY "[Lookup table definition for :PROC "+cProcname+"  VAR "+cVarName+"]"
@ 7,0 SAY 'Ã'
@ 7,79 SAY '´'
@ 10,0 SAY 'Ã'
@ 10,79 SAY '´'
@ 13,0 SAY 'Ã'
@ 13,79 SAY '´'
@ 17,0 SAY 'Ã'
@ 17,79 SAY '´'
@ 6,2 SAY "(The Lookup DBF - leave blank for currently open dbf)"
@ 7,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 9,2 SAY "(The Lookup NTX - leave blank for currently open index)"
@ 10,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 12,2 SAY "(The display string - must evaluate to type Character)"
@ 13,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 15,2 SAY "(The return string - this is what will be stuffed in the keyboard - leave"
@ 16,3 SAY "blank for nothing)"
@ 17,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 19,2 SAY "(The title string - leave blank for no title)"
do while .t.
     @5,23 get aValues[SC_DBFNAME]
     @8,23 get aValues[SC_NTXNAME]
     @11,23 get aValues[SC_DISPLAY] picture "@S35"
     @14,23 get aValues[SC_RETURN]  picture "@S35"
     @18,23 get aValues[SC_TITLE]
     clear gets

     @5,2 PROMPT 'DBF File           '
     @8,2 PROMPT 'NTX File           '
     @11,2 PROMPT 'Display String     '
     @14,2 PROMPT 'Return String      '
     @18,2 PROMPT 'TitleString        '
     @22,2 PROMPT 'Quit               '
     menu to nSelect
     do case
        CASE nSelect = 1
           cTempFile := popex("*.DBF","Select DBF")
           if !empty(cTempFile)
             cTempfile := left(cTempfile,at(".",cTempFile)-1)
             if cTempFile==cAlias
               aValues[SC_DBFNAME] := space(10)
               aValues[SC_NTXNAME] := space(8)
               aValues[SC_DISPLAY] := space(160)
               aValues[SC_RETURN]  := space(25)
               msg("Using current datafile == leave blank")
             else
               aValues[SC_DBFNAME] := cTempFile
               aValues[SC_NTXNAME] := space(8)
               aValues[SC_DISPLAY] := space(160)
               aValues[SC_RETURN]  := space(25)
             endif
           endif
        CASE nSelect = 2 .and. !empty(aValues[SC_DBFNAME])
           cTempFile := popex('*'+INDEXEXT() ,"Select Index")
           if !empty(cTempFile)
             aValues[SC_NTXNAME] := cTempFile
           endif
        CASE nSelect = 2
           msg("You must be opening a new DBf in order to select an index")
        CASE nSelect = 3
           cTempString := aValues[SC_DISPLAY]
           if empty(aValues[SC_DBFNAME])
              getstring(@cTempString,cAlias)
           else
              getstring(@cTempString,aValues[SC_DBFNAME])
           endif
           aValues[SC_DISPLAY] := cTempString
        CASE nSelect = 4
           cTempString := ""
           if empty(aValues[SC_DBFNAME])
              getstring(@cTempString,cAlias)
           else
              getstring(@cTempString,aValues[SC_DBFNAME])
           endif
           aValues[SC_RETURN] := cTempString
        CASE nSelect = 5
           @18,23 get aValues[SC_TITLE]
           read
        CASE nSelect = 6
          exit
     endcase
enddo
unbox(cPopBox)
return messyn("Save?")

//----------------------------------------------------------------
STATIC function getstring(cString,cAlias)
local cNewField
local lOpenNew := .f.
select 0

if select(cAlias) > 0
  select (select(cAlias) )
elseif SNET_USE(cAlias,"",.F.,5,.F.,"Unable to open. Keep trying?")
  lOpenNew := .t.
endif

cNewfield := mfields(" Field List",7,30,17,50)
IF !EMPTY(cNewfield)
  DO CASE
  CASE TYPE(cNewfield)=="N"
     cNewfield = "STR("+cNewfield+")"
  CASE TYPE(cNewfield)=="D"
     cNewfield = "DTOC("+cNewfield+")"
  CASE TYPE(cNewfield)=="L"
     cNewfield = "IIF("+cNewfield+",'True ','False')"
  CASE TYPE(cNewfield)=="M"
     cNewfield := ""
  ENDCASE
endif
IF !EMPTY(cNewfield)
   IF !empty(cString)
     cString+="+' '+"+cNewfield
   else
     cString := cNewfield
   endif
ENDIF
if lOpenNew
  use
endif
select __scroller
return nil
//----------------------------------------------------
static function add
local lAdded := .f.
locate for deleted()
if (found() .and. srec_lock(5,.f.)) .or. ;
   SADD_REC(5,.T.,"Network error adding record. Keep trying?")
  lAdded := .t.
endif
return lAdded
//----------------------------------------------------
static function save(aValues)
if SREC_LOCK(5,.T.,"Network error - Unable to lock record. Keep trying?")
   __scroller->smodule :=     aValues[SC_PROCNAME]
   __scroller->sfield  :=     aValues[SC_VARNAME]
   __scroller->sdescr  :=     aValues[SC_TITLE]
   __scroller->sstring :=     aValues[SC_DISPLAY]
   __scroller->sreturn :=     aValues[SC_RETURN]
   __scroller->sdbfile :=     aValues[SC_DBFNAME]
   __scroller->sind    :=     aValues[SC_NTXNAME]
   unlock
endif
return nil

