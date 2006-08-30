#INCLUDE "inkey.ch"
FUNCTION POPMONTH(nStart)
local aMonths := {"Enero",;
                  "Febrero",;
                  "Marzo",;
                  "Abril",;
                  "Mayo",;
                  "Junio",;
                  "Julio",;
                  "Agosto",;
                  "Septiembre",;
                  "Octubre",;
                  "Noviembre",;
                  "Diciembre"}
return mchoice(aMonths)


FUNCTION POPVDATE(dStart,lWords,cTitle)
local nTop:=0,nLeft:=0,nBottom:=15,nRight:=10
local oTb,cBox
local nElement := 0
local nLastKey
local dReturn

dStart := iif(dStart#nil,dStart,date())
lWords := iif(lWords#nil,lWords,.f.)
cTitle := iif(cTitle#nil,cTitle,"")
nRight := iif(lWords,20,nRight)
nRight := max(nRight,len(cTitle))
sbcenter(@nTop,@nLeft,@nBottom,@nRight)
cBox   := makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
@nTop,nLeft+1 say left(cTitle,sbcols(nLeft,nRight,.f.))
oTb    := tbrowsenew(nTop+1,nLeft+1,nBottom-1,nRight-1)
if lWords
  oTb:addcolumn(tbcolumnNew(nil,{||dtow(dStart+(nElement))}))
else
  oTb:addcolumn(tbcolumnNew(nil,{||dStart+(nElement)}))
endif
oTb:skipblock := {|n|nElement+=n,n}
while .t.
  while !oTb:stabilize()
  end
  nLastKey := inkey(0)
  do case
  case nLastKey == K_DOWN
    oTb:down()
  case nLastKey == K_UP
    oTb:up()
  case nLastKey == K_PGDN
    nElement += 30
    oTb:refreshall()
  case nLastKey == K_PGUP
    nElement -= 30
    oTb:refreshall()
  case nLastKey == K_CTRL_PGDN
    nElement += 365
    oTb:refreshall()
  case nLastKey == K_CTRL_PGUP
    nElement -= 365
    oTb:refreshall()
  case nLastKey == K_HOME
    nElement := 0
    oTb:refreshall()
  case nLastKey == K_ESC
    dReturn := dStart
    exit
  case nLastKey == K_ENTER
    dReturn :=  dStart+(nElement)
    exit
  endcase
end
unbox(cBox)
return dReturn

FUNCTION POPVYEAR(cTitle)
local nTop:=0,nLeft:=0,nBottom:=15,nRight:=7
local oTb,cBox
local nElement := 0
local nLastKey
local nReturn
local nStart

nStart := year(date())
cTitle := iif(cTitle#nil,cTitle,"")
nRight := max(nRight,len(cTitle))
sbcenter(@nTop,@nLeft,@nBottom,@nRight)
cBox   := makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
@nTop,nLeft+1 say left(cTitle,sbcols(nLeft,nRight,.f.))
oTb    := tbrowsenew(nTop+1,nLeft+1,nBottom-1,nRight-1)
oTb:addcolumn(tbcolumnNew(nil,{||trans(nStart+(nElement),"9999")}))
oTb:skipblock := {|n|nElement+=n,n}
while .t.
  while !oTb:stabilize()
  end
  nLastKey := inkey(0)
  do case
  case nLastKey == K_DOWN
    oTb:down()
  case nLastKey == K_UP
    oTb:up()
  case nLastKey == K_PGDN
    oTb:pagedown()
  case nLastKey == K_PGUP
    oTb:pageup()
  case nLastKey == K_HOME
    nElement := 0
    oTb:refreshall()
  case nLastKey == K_ESC
    nReturn := nStart
    exit
  case nLastKey == K_ENTER
    nReturn :=  nStart+(nElement)
    exit
  endcase
end
unbox(cBox)
return nReturn



