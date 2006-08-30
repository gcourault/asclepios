#include "inkey.ch"
Function popcolsel(cInColor)

  local aFore := {"N","B","G","BG","R","BR","GR","W",;
                    "N+","B+","G+","BG+","R+","BR+","GR+","W+"}
  local aBack := {"N","B","G","BG","R","BR","GR","W",;
                    "N*","B*","G*","BG*","R*","BR*","GR*","W*"}

  local nTop := 0,nLeft:= 0,nBottom,nRight := 19
  local nAtFg,nAtBg,cFg,cBg
  local nLastKey,cBox
  local lSetBlink,nColorRows
  local cPriorColor := takeout(iif(cInColor#nil,cInColor,setcolor()),",",1)
  local cNewColor   := cPriorColor

  cFg := UPPER(left(alltrim(cPriorColor),at("/",cPriorColor)-1))
  if left(cFg,1)$"+*"
    cFg := subst(cFg,2)+"+"
  endif

  cBg := UPPER(subst(alltrim(cPriorColor),at("/",cPriorColor)+1))
  if left(cBg,1)$"*"
    cBg := subst(cBg,2)+"*"
  endif

  lSetBlink   := setblink()
  nColorRows  := iif(lSetBlink,8,16)
  nBottom     := nColorRows+5
  sbcenter(@nTop,@nLeft,@nBottom,@nRight)

  dispbegin()
  cBox := makebox(nTop,nLeft,nBottom,nRight,"N/W")
  @ nTop,nLeft+1 say " Color Selector "
  @ nBottom-3,nLeft+2 SAY padc(chr(24)+chr(25)+chr(26)+chr(27),16)
  @ nBottom-2,nLeft+2 SAY padc("ENTER to accept",16)
  @ nBottom-1,nLeft+2 SAY padc("ESC to cancel",16)

  FOR nAtBg = 1 TO nColorRows
     FOR nAtFg = 1 TO 16
        @ nTop+nAtBg,nLeft+1+nAtFg SAY "*" color (aFore[nAtFg]+"/"+aBack[nAtBg])
     NEXT
  NEXT
  dispend()

  nAtFg := ascan(aFore,{|el|el==cFg})
  nAtBg := ascan(aBack,{|el|el==cBg})
  do while .t.
      @ nTop+nAtBg,nLeft+1+nAtFg SAY "X" color (aFore[nAtFg]+"/"+aBack[nAtBg])
      nLastKey := inkey(0)
      @ nTop+nAtBg,nLeft+1+nAtFg SAY "*" color (aFore[nAtFg]+"/"+aBack[nAtBg])
      do case
      case nLastKey = K_UP
        nAtBg := iif(nAtBg=1,nColorRows,nAtBg-1)
      case nLastKey = K_DOWN
        nAtBg := iif(nAtBg=nColorRows,1,nAtBg+1)
      case nLastKey = K_LEFT
        nAtFg := iif(nAtFg=1,16,nAtFg-1)
      case nLastKey = K_RIGHT
        nAtFg := iif(nAtFg=16,1,nAtFg+1)
      case nLastKey = K_ESC
        exit
      case nLastKey = K_ENTER
        cNewColor := padr(left( aFore[nAtFg]+"/"+aBack[nAtBg]+space(7),7),10)
        EXIT
      endcase
  enddo
  unbox(cBox)
return cNewColor

