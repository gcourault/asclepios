#include "inkey.ch"

function sgetmany(aGets,aDesc,nTop,nLeft,nBottom,nRight,cTitle,cFoot,nPadding)
local cScreen,oGet
local nElement := 1
local nLastKey
local oThisGet,nRow,nCol
local cRightFrame := subst(sls_frame(),4,1)
local lReadExit := readexit(.t.)
local bF10
local nWidth1,nWidth2
local aBlocks := {}
local lSave   := .t.
nPadding := iif(nPadding#nil,nPadding,0)

if (nBottom-nTop-1-nPadding) > 0
    bF10 := setkey(K_F10,{||CTRLW()})
    cScreen := makebox(ntop,nLeft,nbottom,nright,sls_popcol())
    cFoot  := iif(cFoot #nil,cFoot ,"")
    cTitle := iif(cTitle#nil,cTitle,"")
    @nTop,nLeft+1    say cTitle
    @nBottom,nLeft+1 say cFoot
    oGet := tbrowseNew(nTop+1+nPadding,nLeft+1+nPadding,nBottom-1-nPadding,nRight-1-nPadding)
    oGet:addcolumn(tbcolumnNew(nil,{||aDesc[nElement]} ))
    oGet:addcolumn(tbcolumnNew(nil,{||aGets[nElement]:varget()} ))
    oGet:SKIPBLOCK :={|n|aaskip(n,@nElement,LEN(aGets))}
    oGet:gobottomblock := {||nElement := len(aGets)}
    oGet:gotopblock  := {||nElement := 1}
    oGet:getcolumn(1):width := (nWidth1 := bigelem(aDesc))
    oGet:getcolumn(2):width := (nWidth2 := (nRight-nLeft-4)-nWidth1-(nPadding*2))
    oGet:colorspec := left(setcolor(),at(",",setcolor())-1)+","+;
                      left(setcolor(),at(",",setcolor())-1)
    oGet:configure()
    oGet:freeze := 1
    oGet:colpos := 2

    aeval(aGets,{|g|g:picture := makepicture(g:picture,nWidth2)} )

    DO WHILE .T.
       dispbegin()
        oGet:refreshall()
        WHILE !oGet:STABILIZE()
        END
        nRow := row()
        nCol := col()
        devpos(nTop+1,nRight)
        devout(iif(nElement>1,chr(30),cRightFrame) )
        devpos(nbottom-1,nRight)
        devout(iif(nElement<LEN(aGets),chr(31),cRightFrame ))
        setpos(nRow,nCol)
       dispend()
       oThisGet := aGets[nElement]
       oThisGet:row := nRow
       oThisGet:col := nCol

       readmodal({oThisGet})
       nLastKey := lastkey()

       do case
       CASE nLastKey = K_PGUP        && UP ONE PAGE
         oGet:PAGEUP()
       CASE nLastKey = K_UP
         oGet:UP()
       CASE nLastKey = K_DOWN  .or. nLastKey = K_ENTER
         oGet:DOWN()
       CASE nLastKey = K_PGDN        && DOWN ONE PAGE
         oGet:PAGEdOWN()
       case nLastKey = K_F10 .OR. nLastkey = K_CTRL_W
         EXIT
       case nLastKey = K_ESC
         lSave := .f.
         EXIT
       endcase
    ENDDO
    unbox(cScreen)
    setkey(K_F10,bF10)
endif
aSize(aGets,0)
readexit(lReadExit)
return lSave

//------------------------------------------------------------

//------------------------------------------------------------

static function makepicture(cPicture,nWidth)
local cNewPict
IF empty(cPicture)
  cNewPict := "@S"+alltrim(str(nWidth))
ELSEIF "@"$cPicture
  cNewPict := "@S"+alltrim(str(nWidth))+subst(cPicture,2)
ELSE
  cNewPict := "@S"+alltrim(str(nWidth))+" "+ALLTRIM(cPicture)
ENDIF
return cNewPict



