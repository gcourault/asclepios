#include "inkey.ch"

FUNCTION smalls(expDisplayString,cTitle,expAlias,expReturn,;
                expStartRange,expEndRange,bException,lForceCap)

local nDisplayColumn
local expFirstKey,expLastKey,nNbrRecs
local nTop,nBot,nLeft,nRight,nBoxWidth,lIndexed
local nLastkey,nCurrentRec,cScrollBox,cSearchFor
local bIndexKey,nFirstRec,nLastRec,nStartRec,bDisplayString
local cIndexType  := "U"
local oTbrowse
local lReturn     := .f.
local nCursor     := setcursor(0)
local cOldColor   := Setcolor(sls_popcol())
local lExact      := setexact(.f.)
local lOldSoft    := SET(_SET_SOFTSEEK,.t.)
local lCloseWhenDone := .f.
local nOldArea    := select()
local cDbfName,cIndexName
local lContinue   := .t.
local lFirstDisplay := .t.

lContinue := setupdb(expAlias,nOldArea,@lCloseWhenDone)
lForceCap := iif(lForceCap#nil,lForceCap,.f.)

if lContinue

    lIndexed    := !empty(indexkey(0))
    IF EOF()
      dbgobottom()
    elseif bof()
      dbgotop()
    endif
    nStartRec   := RECNO()

    if !empty(indexkey(0))
       bIndexKey  := &("{||"+indexkey(0)+"}")
       cIndexType := valtype( eval(bIndexKey) )
    endif

    *- check for record limits
    * start of range
    IF expStartRange#nil .AND. lIndexed
      SEEK expStartRange
      expFirstKey   := eval(bIndexKey)
      nFirstRec     := recno()
    elseif lIndexed
      go top
      expFirstKey   := eval(bIndexKey)
      nFirstRec     := recno()
   else
      go top
      nFirstRec     := recno()
    ENDIF

    * end of range
    IF expEndRange#nil  .AND. lIndexed    && a key
      SEEK expEndRange
      IF !EOF()
        skip -1
      ENDIF
      while empty(eval(bIndexKey))
        skip -1
      end
      expLastKey  := eval(bIndexKey)
      nLastRec    := recno()
    elseif lIndexed
      go bottom
      expLastKey  := eval(bIndexKey)
      nLastRec     := recno()
    else
      go bottom
      nLastRec     := recno()
    ENDIF

    go nStartRec
    IF expStartRange#nil .and. expEndRange#nil .AND. lIndexed
      if eval(bIndexKey)>expLastKey .or. eval(bIndexKey)<expFirstKey
        nStartRec := nFirstRec
        go nStartRec
      endif
    endif

    go nFirstRec
    for nNbrRecs = 1 to 10
       if recno() = nLastRec
         exit
       endif
       skip
    next

    *- record starting record
    GO nStartRec

    DO WHILE .T.
      *- was a title passed ?
      IF cTitle==nil
        cTitle = ''
      ENDIF

      *- what is the display string?
      if valtype(expDisplayString)=="B"
        bDisplayString := expDisplayString
      else    // assume character
        bDisplayString := &("{||"+expDisplayString+"}")
      endif

      *- how wide does our window need to be
      nBoxWidth  := LEN(eval(bDisplayString))+1

      *- get longest of display string/title as window width
      nBoxWidth := MAX(nBoxWidth,LEN(cTitle)+2)
      nBoxWidth := min(74,nBoxWidth)

      *- figure window parameters (centered on screen)
      nLeft     :=  INT((78-(nBoxWidth))/2)
      nRight    := nLeft+1+nBoxWidth+1
      nTop      :=7
      nBot      :=min(nNbrRecs+6,16)

      dispbegin()
      *- draw the box and the title
      cScrollBox  := makebox(nTop-1,nLeft-1,nBot+1,nRight+1,sls_popcol())
      @nTop-1,nLeft SAY cTitle

      oTbrowse:= tbrowsedb(nTop,nLeft,nBot,nRight)
      oTbrowse:addcolumn(tbColumnNew(nil,bDisplayString))
      oTbrowse:gobottomblock := {||dbgoto(nLastRec)}
      oTbrowse:gotopblock := {||dbgoto(nFirstRec)}
      oTbrowse:skipblock := {|n|dskip(n,nFirstRec,nLastRec) }

      *- go to start record
      GO nStartRec


      *- main loop
      DO WHILE .T.
        dispbegin()
        while !oTbrowse:stabilize()
        end
        dispend()

        if lFirstDisplay
          lFirstDisplay := .f.
          dispend()
        endif

        nLastkey := INKEY(0)

        *- do action based on keystroke
        DO CASE
        CASE  nLastkey = K_UP
          oTbrowse:up()
        CASE nLastkey = K_DOWN
          oTbrowse:down()
        CASE nLastkey = K_ENTER
          if valtype(expReturn)=="C"
            KEYBOARD &expReturn
          elseif valtype(expReturn)=="B"
            eval(expReturn)
          ENDIF
          lReturn := .t.
          EXIT
        CASE nLastkey = K_PGUP
          oTbrowse:pageup()
        CASE nLastkey = K_PGDN
          oTbrowse:pagedown()
        CASE nLastkey = K_HOME
          oTbrowse:gotop()
        CASE nLastkey = K_END
          oTbrowse:gobottom()
        CASE UPPER(CHR(nLastkey )) $;
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" .AND. lIndexed
            cSearchFor := eval(bIndexKey)
            keyboard chr(nLastkey)
            if lForceCap
              popread(.t.,"B£squeda:",@cSearchFor,"@K!")
            else
              popread(.t.,"B£squeda:",@cSearchFor,"@K")
            endif
            cSearchFor  := iif(valtype(cSearchfor)=="C",trim(cSearchFor),cSearchfor)
            nCurrentRec := RECNO()

            // check that the search string is in range of the expFirstKey and
            // expLastkey
            if ( VALTYPE(cSearchfor)=="C" .and. ;
                  cSearchFor >= left(expFirstKey,len(cSearchfor))  .and. ;
                  cSearchFor <= left(expLastKey,len(cSearchfor)) ) .or. ;
              ( VALTYPE(cSearchfor)#"C" .and. ;
                  cSearchFor >= expFirstKey .and. cSearchFor <= expLastKey )

                SEEK cSearchFor
                IF !FOUND()
                  GO nCurrentRec
                ELSE
                  oTbrowse:rowpos := 1
                  oTbrowse:configure()
                  oTbrowse:refreshall()
                ENDIF
            endif
        CASE nLastkey = K_ESC
             lReturn := .f.
             EXIT
        case bException#nil
             eval(bException,nLastkey)
             reconfig(bIndexKey,expStartRange,expEndRange,lIndexed,;
                      @expFirstKey,@nFirstRec,@expLastKey,@nLastRec)
             oTbrowse:refreshall()
        ENDCASE
      ENDDO
      unbox(cScrollBox)
      EXIT
    ENDDO
endif
SETCURSOR(nCursor)
SET(_SET_SOFTSEEK,lOldSoft)
setcolor(cOldColor)
setexact(lExact)
if lCloseWhenDone
  USE
endif
select (nOldArea)
RETURN lReturn


//=================================================================
static function dskip(n,nFirstRec,nLastRec)
  local skipcount := 0
  do case
  case n > 0
    do while recno()<>nLastRec .and. skipcount < n
      dbskip(1)
      skipcount++
    enddo
  case n < 0
    do while recno()<>nFirstRec .and. skipcount > n
      dbskip(-1)
      skipcount--
    enddo
  endcase
return skipcount

static function setupdb(expAlias,nOldArea,lCloseWhenDone)
local cDbfName,cIndexName
local lContinue := .t.
if expAlias#nil
  if !empty(expAlias)
    do case
    case valtype(expAlias)=="N"
       select (expAlias)
       if !used()
         lContinue := .f.
         select (nOldArea)
       endif
    case valtype(expAlias)=="C"
       if "%"$expAlias
         select 0
         cDbfName   := takeout(expAlias,'%',2)
         cIndexName := takeout(expAlias,'%',3)
         lContinue  := !empty(cDbfName)
         IF !EMPTY(cDbfName)
           if !SNET_USE(cDbfName,cDbfName,.f.,5,.t.,"Network error opening LOOKUP file. Keep trying?")
             select (nOldArea)
             lContinue := .f.
           else
             IF !EMPTY(cIndexName)
               * SET INDEX TO (cIndexName)
               set order to tag (cIndexName)
             ENDIF
             lCloseWhenDone := .t.
           endif
         ENDIF
       else
        if select(expAlias) > 0
          SELECT (select(expAlias))
        endif
      endif
    endcase
  endif
endif
return lContinue


//-----------------------------------------------------------------
static proc reconfig(bIndexKey,expStartRange,expEndRange,lIndexed,;
                   expFirstKey,nFirstRec,expLastKey,nLastRec)
local nStartRec

nStartRec   := RECNO()

*- check for record limits
* start of range
IF expStartRange#nil .AND. lIndexed
  SEEK expStartRange
  expFirstKey   := eval(bIndexKey)
  nFirstRec     := recno()
elseif lIndexed
  go top
  expFirstKey   := eval(bIndexKey)
  nFirstRec     := recno()
else
  go top
  nFirstRec     := recno()
ENDIF

* end of range
IF expEndRange#nil  .AND. lIndexed    && a key
  SEEK expEndRange
  IF !EOF()
    skip -1
  ENDIF
  while empty(eval(bIndexKey))
    skip -1
  end
  expLastKey  := eval(bIndexKey)
  nLastRec    := recno()
elseif lIndexed
  go bottom
  expLastKey  := eval(bIndexKey)
  nLastRec     := recno()
else
  go bottom
  nLastRec     := recno()
ENDIF

go nStartRec
IF expStartRange#nil .and. expEndRange#nil .AND. lIndexed
  if eval(bIndexKey)>expLastKey .or. eval(bIndexKey)<expFirstKey
    nStartRec := nFirstRec
    go nStartRec
  endif
endif

return





