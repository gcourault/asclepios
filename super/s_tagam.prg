
#include "inkey.ch"

#define GOINGDOWN 1
#define GOINGUP   2

#ifndef K_SPACE
#define K_SPACE 32
#endif
#define KEY_TAG         1     // K_SPACE
#define KEY_DONE        2     // K_F10
#define KEY_ABORT       3     // K_ESC
#define KEY_TAG_ALL     4     // K_ALT_A
#define KEY_UNTAG_ALL   5     // K_ALT_U
#define KEY_SWAP_TAGS   6     // K_ALT_S

#define KEY_ALEN        6     // number of *magic* keys



static nElement := 1

FUNCTION TagMArray(aArray,cTitle,cMark,aTags,aHeads)
  local cScreen1, nSaveCursor
  local aRet, oTB, oTBC
  local nTop, nLeft, nBottom, nRight
  local nKeyLast, nKeyPos
  local i, aColInfo, nNoCols, nNoRows, lHeaders
  local nDirection  := GOINGDOWN
  local lExit := .f.
  local aData
  local aKeys,cKeyMsg

  if (aArray == NIL)
    retu (NIL)
  else
    aData     := aArray
    nElement  := 1
    nNoRows   := len(aArray)
    nNoCols   := len(aArray[1])
  endif

  nSaveCursor := setcursor(0)

  if (aTags == NIL)
    aTags := array(nNoRows)
    afill(aTags,.f.)
  else
    if (len(aTags) != nNoRows)
      asize(aTags,len(aArray))
      afillnil(aTags,.f.)
    endif
  endif

  if (aHeads == NIL)
    aHeads    := array(nNoCols)
    lHeaders  := .f.
  else
    lHeaders := .t.
    if (len(aHeads) < nNoCols)
      aHeads := asize(aHeads,nNoCols)
    endif
  endif

  aColInfo := CalcMaxColLen(aArray,nNoRows,nNoCols)


  aKeys    := {K_SPACE,K_F10,K_ESC,K_ALT_A,K_ALT_U,K_ALT_S}
  cMark    := IIF(cMark != NIL,cMark,"û")
  cKeyMsg  := "ESPACIO=marca  F10=Graba  ESC=cancela  ALT-A=Marca Todo  ALT-U=DesMarca  ALT-S=Cambia"

  nTop    := 0
  nLeft   := 0
  nBottom := 15
  nRight  := len(cKeyMsg)+2
  sbCenter(@nTop,@nLeft,@nBottom,@nRight)

  *- DRAW THE BOX
  dispbegin()
  cScreen1 := MAKEBOX(nTop,nLeft,nBottom,nRight,SLS_POPCOL())
  if (cTitle != NIL)
    @ nTop+1,nLeft+1 say left(cTitle,(nRight-(nLeft+2)))
    if (lHeaders)
      @ nTop+2,nLeft say "Æ"
      @ nTop+2,nRight say "µ"
      @ nTop+2,nLeft+1 to nTop+2,nRight-1 double
    endif
    @ nTop+iif(lHeaders,4,2),nLeft say "ÃÄ"
    @ nTop+iif(lHeaders,4,2),nRight-1 say "Ä´"
    @ nTop+iif(lHeaders,4,2),nLeft+1 to nTop+iif(lHeaders,4,2),nRight-1
  else
    if (lHeaders)
      @ nTop+2,nLeft say "ÃÄ"
      @ nTop+2,nRight-1 say "Ä´"
      @ nTop+2,nLeft+1 to nTop+2,nRight-1
    endif
  endif
  @ nBottom-2,nLeft say "ÃÄ"
  @ nBottom-2,nRight-1 say "Ä´"
  @ nBottom-2,nLeft+1 to nBottom-2,nRight-1
  @ nBottom-1,nLeft+2 say padc(cKeyMsg,(nRight-(nLeft+2)))
  dispend()

  *- BUILD THE TBROWSE OBJECT
  oTB := TBrowseNew( ;
    nTop+iif(cTitle != NIL,2,0)+iif(lHeaders,1,0), ;
    nLeft+2,nBottom-2,nRight-2)
  oTB:headSep := "ÄÂÄ"
  oTB:colSep  := " ³ "
  oTB:footSep := "ÄÁÄ"

  *- ADD THE TBCOLUMNS
  oTB:addColumn(tbColumnNew( NIL, ;
    {||iif(aTags[nElement],cMark,space(len(cMark)))} ))
  for i := 1 to nNoCols
    oTBC := TBColumnNew( aHeads[i],GenBlock(i,aData))
    if (aColInfo[i] > 0)
      oTBC:width := iif(lHeaders, ;
        max(aColInfo[i],len(aHeads[i])), ;
        aColInfo[i])
    endif
    oTB:addColumn(oTBC)
  next
  oTB:skipBlock     := {|n|aaskip(n,@nElement,nNoRows)}
  oTB:goBottomBlock := {|| nElement := nNoRows}
  oTB:goTopBlock    := {|| nElement := 1}


  oTB:freeze := 1
  oTB:colPos := 2

  while (!lExit)
    dispbegin()
    WHILE (!oTB:stabilize())
      if (nextkey() > 0)
        exit
      endif
    END
    dispend()
    nKeyLast := INKEY(0)

    if ((nKeyPos  := ascan(aKeys,nKeyLast)) > 0)
      do case
      case nKeyPos == KEY_TAG
        aTags[nElement] := (!aTags[nElement])
        oTB:refreshCurrent()
        if (nDirection == GOINGUP)
          oTB:up()
        else
          oTB:down()
        endif
      case nKeyPos == KEY_DONE
        lExit := .t.
      case nKeyPos == KEY_ABORT
        aTags := NIL
        lExit := .t.
      case nKeyPos ==  KEY_TAG_ALL
        afill(aTags,.t.)
        oTB:refreshAll()
      case nKeyPos == KEY_UNTAG_ALL
        afill(aTags,.f.)
        oTB:refreshAll()
      case nKeyPos == KEY_SWAP_TAGS
        for i := 1 to len(aTags)
          aTags[i] := (!aTags[i])
        next
        oTB:refreshAll()
      endcase
    else
      do case
      case nKeyLast == K_LEFT     // allow movement (left), not tag column
        if (oTB:colPos > 2)
          oTB:left()
        endif
      case nKeyLast == K_RIGHT    // allow movement (right)
        oTB:right()

      CASE nKeyLast = K_UP          && UP ONE ROW
        oTB:up()
        nDirection := GOINGUP

      CASE nKeyLast = K_PGUP        && UP ONE PAGE
        oTB:pageUp()
        nDirection := GOINGUP


      CASE nKeyLast = K_DOWN        && DOWN ONE ROW
        oTB:down()
        nDirection := GOINGDOWN

      CASE nKeyLast = K_PGDN        && DOWN ONE PAGE
        oTB:pageDown()
        nDirection := GOINGDOWN

      case nKeyLast == K_HOME
        oTB:goTop()
        nDirection := GOINGDOWN

      case nKeyLast == K_END
        oTB:goBottom()
        nDirection := GOINGUP
      endcase
    endif
  ENDDO
  aRet := {}
  if (aTags != NIL)
    for i := 1 to len(aTags)
      if (aTags[i])
        aadd(aRet,i)
      endif
    next
  endif
  unbox(cScreen1)
  setcursor(nSaveCursor)
  nElement := nil
return (aRet)

static function genBlock(nCol,aData)
return({||aData[nElement][nCol]})


static function CalcMaxColLen(a,nRows,nCols)
  local i, j
  local aRet := array(nCols)
  afill(aRet,0)
  for i := 1 to nRows
    for j := 1 to nCols
      if (valtype(a[i][j]) == 'C')
        if (len(a[i][j]) > aRet[j])
          aRet[j] := len(a[i][j])
        endif
      endif
    next
  next
return(aRet)


static function afillnil(aIn,expFill)
local i
for i = 1 to len(aIn)
  if aIn[i]==nil
    aIn[i] := expFill
  endif
next
return nil

