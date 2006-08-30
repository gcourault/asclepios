#include "inkey.ch"
FUNCTION TODOLIST
local   nOldArea,cOldScreen,cOldColor,lAlldone,cFilter,cTempMemo
local   cTodoFile,cTodoNTX1,cTodoNTX2,cTodoNTX3,nOldCursor,bOldF10
local   oBrowse
local   nLastkey,cLastkey
local   nListOrder
local   cOldQuery  := sls_query()
local   nDispOrder := 1
local   nFilter
local   lAppend,lOktoEdit,lOkToRep
local   mCATEGORY,mITEM,mPRIORITY,mdoby,mdone
local   cHiColor
local   lDeleted := SET(_SET_DELETED,.t.)
memvar getlist
field  CATEGORY,ITEM,PRIORITY,DOBY,DONE,LONG_DESC

lAlldone        := .f.
bOldF10         := setkey(-9)
nOldCursor      := setcursor()
setkey(-9,{||ctrlw()})
dtow(date())
nOldArea        := select()
select 0
cOldScreen      := savescreen(0,0,24,79)
cOldColor       := setcolor()
cTodoFile       := SLSF_TODO()
cTodoNTX1     := SLSF_TDN1()
cTodoNTX2     := SLSF_TDN2()
cTodoNTX3     := SLSF_TDN3()

if !file(cTodoFile+".DBF")
    BLDDBF(cTodoFile,"CATEGORY,C,10:ITEM,C,60:PRIORITY,C,2:DOBY,D:DONE,L:LONG_DESC,C,231")
endif

IF !SNET_USE(cTodoFile,"__TODO",.f.,5,.F.,"No se puede abrir archivo TODO. ¨Reintenta?")
    select (nOldArea)
    setkey(-9,bOldF10)
    setcursor(nOldCursor)
    return ''
ENDIF

IF !file(cTodoNTX1+indexext()) .and. !file(cTodoNTX2+indexext()) .and. !file(cTodoNTX3+indexext())
  index on category+descend(priority) to (cTodoNTX1)
  index on descend(priority) to (cTodoNTX2)
  index on doby to (cTodoNTX3)
endif
set index to (cTodoNTX1), (cTodoNTX2), (cTodoNTX3)
oBrowse := maketb()


clear
SETCOLOR(sls_normcol())
cHiColor := takeout(setcolor(),",",5)
@0,0,15,79 box sls_frame()
@15,0,24,79 box sls_frame()
@23,02 say  "S)alir   E)ditar  A)gregar B)orrar    F)iltrat   M)emo    I)mp     O)rden"
@ 22,1 SAY repl("Ä",78)
@ 22,0 say "ÃÄ"
@ 22,79 say "´"
@0,2 say " Agenda  "
@15,0 say "Ã"
@15,79 say "´"

@ 16,1 SAY "Item........"
@ 17,1 SAY "Categor¡a...              Prioridad.       Fecha..           ¨Hecho?   "

GO TOP
lAllDone := .f.
DO WHILE !lAllDone
   while !oBrowse:stabilize()
   end
   setcolor(sls_normcol())
   IF deleted()
     @15,60 say "[BORRADO]"
   else
     @15,60 say "ÄÄÄÄÄÄÄÄÄ"
   ENDIF
   setcolor(cHiColor)
   MEMOEDIT(LONG_DESC,19,1,21,78,.F.,.f.)
   setcolor(sls_normcol())
   @16,13 get __todo->ITEM
   @17,13 get __todo->CATEGORY
   @17,37 get __todo->PRIORITY
   @ 17,51 get __todo->doby
   @ 17,69 get __todo->done pict "Y"
   clear gets
   setcolor(sls_popcol())
   nLastkey := inkey(0)
   cLastkey := upper(chr(nLastkey))

   DO CASE
   CASE nLastkey==K_DOWN
      oBrowse:down()
   CASE nLastkey==K_UP
      oBrowse:up()
   CASE nLastkey==K_LEFT
      oBrowse:left()
   CASE nLastkey==K_RIGHT
      oBrowse:right()
   CASE nLastkey==K_PGDN
      oBrowse:pagedown()
   CASE nLastkey==K_PGUP
      oBrowse:pageup()
   CASE nLastkey==K_HOME
      oBrowse:gotop()
   CASE nLastkey==K_END
      oBrowse:gobottom()

   CASE cLastkey$"Ii"                         // print
      setcolor(sls_normcol())
      nListOrder := menu_v("Order of list: ","Category","Priority","Date")
      if nListOrder > 0
        set order to nListOrder
        sls_query("")
        lister()
        sls_query(cOldQuery)
      endif
      set order to nDispOrder
      setcolor(sls_popcol())
      oBrowse:refreshall()
   CASE cLastKey$"Qq" .or. nLastkey==K_ESC      // q or escape
       lAlldone = .t.
   CASE cLastkey$"Oo"                           // order
      setcolor(sls_normcol())
      nDispOrder := max(menu_v("Viewing Order: ","Category","Priority","Date"),1)
      setcolor(sls_popcol())
      set order to (nDispOrder)
      oBrowse:gotop()
      oBrowse:refreshall()
   CASE cLastkey$"Ff"                           // filter
      setcolor(sls_normcol())
      nFilter := menu_v("Set Filter of ","Category to: "+__todo->category,;
                                        "Date  to: "+dtow(__todo->doby),;
                                        "Priority to:"+__todo->priority,;
                                        "No Filter")
      setcolor(sls_popcol())
      do case
      case nFilter = 1
        cFilter = __todo->category
        set filter to CATEGORY = cFilter
      case nFilter = 2
        cFilter = __todo->doby
        set filter to __todo->DOBY = cFilter
      case nFilter = 3
        cFilter = __todo->priority
        set filter to PRIORITY = cFilter
      OTHERWISE
        set filter to
      endcase
      oBrowse:gotop()
      oBrowse:refreshall()
   CASE cLastkey$"Dd"                           // delete
      delrec()
      skip 1
      skip -1
      oBrowse:refreshall()
   CASE cLastkey$"AaEe" .or. nLastkey==K_ENTER
      if cLastkey$"Aa"                          // add
         lAppend  := .t.
         mCATEGORY := space(10)
         mITEM     := space(60)
         mPRIORITY := space(2)
         mdoby     := date()
         mdone     := .f.
      else                                      // edit
         lAppend   := .f.
         mCATEGORY := __todo->CATEGORY
         mITEM     := __todo->ITEM
         mPRIORITY := __todo->PRIORITY
         mdoby     := __todo->doby
         mdone     := __todo->done
      endif
      if !lAppend .and. oBrowse:colpos > 1
          keyboard repl(chr(13),oBrowse:colpos-1)
      endif
      lOktoEdit := .t.
      if !lAppend
          IF !SREC_LOCK(5,.T.,"Unable to lock record to save. Keep trying?")
             lOktoEdit := .f.
          endif
      endif
      if lOktoEdit
        SET CURSOR ON
        setcolor(sls_normcol())
        scroll(19,1,21,78,0)
        @19,1 say "1.Press F2 for lookups  2. higher number = higher priority"
        setkey(-1,{||pops_do()} )
        @16,13 get mITEM
        @17,13 get mCATEGORY
        @17,37 get mPRIORITY
        @ 17,51 get mdoby
        @ 17,69 get mdone pict "Y"
        read
        @18,1 say "                  "
        setkey(-1)
        set order to 0
        if !nLastKey = 27
          DO WHILE .T.
            if lAppend
               SET(_SET_DELETED,.F.)
               locate for deleted() // attempt to re-use deleted
               SET(_SET_DELETED,.t.)
               if (found() .and. SREC_LOCK(5,.f.)) .or. ;
                 SADD_REC(5,.T.,"Network error adding record. Keep trying?")
                 if found()
                   DBRECALL()
                   replace long_desc with ""
                 endif
               else
                 exit
               endif
            endif
            IF SREC_LOCK(5,.T.,"Unable to lock record to save. Keep trying?")
              replace CATEGORY with mCATEGORY, ITEM with mITEM, ;
                  PRIORITY with trans(val(mPRIORITY),"99"),doby with mdoby, ;
                  done with mdone
              DBRECALL()  // in case we're re-using deleted
            ENDIF
            EXIT
          ENDDO
        endif
        unlock
        goto recno()
        set order to 1
        SET CURSOR OFF
        setcolor(cHiColor)
        MEMOEDIT(LONG_DESC,19,1,21,78,.F.,.f.)
        setcolor(sls_popcol())
      endif
      oBrowse:refreshall()
   case cLAstkey$"Mm"                                   // memo
        IF SREC_LOCK(5,.T.,"Unable to lock record for memo edit. Keep trying?")
            set cursor on
            setcolor(sls_normcol())
            scroll(16,1,21,78,0)
            @16,1 say "Memo editing...Press F10 to save, ESC to abort"
            SETCOLOR(sls_popcol())
            cTempMemo = Memoedit(long_desc,17,1,21,78,.T.)
            REPLACE long_desc WITH cTempMemo
            set cursor off
            setcolor(sls_normcol())
            scroll(16,1,21,78,0)
            @ 16,1 SAY "Item........"
            @ 17,1 SAY "Category....              Priority..       Do By..           Done?..   "
            @18,1 say "                                              "
            setcolor(cHiColor)
            MEMOEDIT(LONG_DESC,19,1,21,78,.F.,.f.)
            @16,13 get __todo->ITEM
            @17,13 get __todo->CATEGORY
            @17,37 get __todo->PRIORITY
            @ 17,51 get __todo->doby
            @ 17,69 get __todo->done pict "Y"
            clear gets
            SETCOLOR(sls_popcol())
            unlock
            goto recno()
            oBrowse:refreshall()
        endif
   ENDCASE
ENDDO
use
SET(_SET_DELETED,lDeleted)
select (nOldArea)
setcolor(cOldColor)
setkey(-9,bOldF10)
setcursor(nOldCursor)
restscreen(0,0,24,79,cOldScreen)
RETURN ''


//--------------------------------------------------
static function pops_do
local nThisRecord,cSmallsDisp,cThisVar
if recc()=0
  return ''
endif
cThisVar    := UPPER(readvar())
nThisRecord := recno()
DO CASE
CASE cThisVar == "MDOBY"
        cSmallsDisp ="dtoc(__todo->doby)"
CASE cThisVar == "MDONE"
        cSmallsDisp ="iif(__todo->done,[Y],[N])"
OTHERWISE
        cSmallsDisp := subst(cThisVar,2)
ENDCASE
smalls(cSmallsDisp)
if !LastKey()=27
  cSmallsDisp = &cSmallsDisp
  keyboard cSmallsDisp
endif
if nThisRecord > 0
  go nThisRecord
endif
return ''

//=============================================
static function maketb
local bTb := tbrowsedb(1,1,14,78)
bTb:headsep := chr(196)
bTb:addcolumn(tbColumnNew("Item",{||left(__todo->item,30)}))
bTb:addcolumn(tbColumnNew("Category",{||__todo->category}))
bTb:addcolumn(tbColumnNew("Priority",{||__todo->priority}))
bTb:addcolumn(tbColumnNew("Do By",{||__todo->doby}))
bTb:addcolumn(tbColumnNew("Done",{||iif(__todo->done,"Yes","No ")} ))
return bTb

