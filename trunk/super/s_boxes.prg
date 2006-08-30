
//----------------------------------------------------------------
function sbCenter(nTop,nLeft,nBottom,nRight)
local nRows,nCols
nRows := sbRows(nTop,nBottom)
nCols := sbCols(nLeft,nRight)
nTop  := int( (maxrow()-nRows)/2)
nBottom  := nTop+nRows-1
nLeft := int( (maxcol()-nCols)/2)
nRight := nLeft+nCols-1
return nil

//----------------------------------------------------------------
function sbRows(nTop,nBottom,lFrame)
lFrame := iif(lFrame#nil,lFrame,.t.)
return nBottom-nTop+iif(lFrame,1,-1)

//----------------------------------------------------------------
function sbCols(nLeft,nRight,lFrame)
lFrame := iif(lFrame#nil,lFrame,.t.)
return nRight-nLeft+iif(lFrame,1,-1)

//----------------------------------------------------------------
#define SHADOW_LOWER_LEFT 1
#define SHADOW_LOWER_RIGHT 3
#define SHADOW_UPPER_LEFT  7
#define SHADOW_UPPER_RIGHT 9

function sbshadow(nTop,nLeft,nBottom,nRight,nShadowPos,nShadowAtt)
local aSaved := array(2)
nShadowAtt := iif(nShadowAtt#nil,nShadowAtt,8)
nShadowPos := iif(nShadowPos#nil,nShadowPos,1)
DO CASE
CASE nShadowPos = SHADOW_LOWER_LEFT .and. nBottom <Maxrow() .and. nLeft > 0
   aSaved[1] := {nTop+1,nLeft-1,nBottom+1,nLeft-1,;
       att(nTop+1,nLeft-1,nBottom+1,nLeft-1,nShadowAtt)}
   aSaved[2] := {nBottom+1,nLeft,nBottom+1,nRight-1,;
       att(nBottom+1,nLeft,nBottom+1,nRight-1,nShadowAtt)}
CASE nShadowPos = SHADOW_LOWER_RIGHT .and. nBottom <Maxrow() .and. nRight < Maxcol()
   aSaved[1] := {nBottom+1,nLeft+1,nBottom+1,nRight+1,;
       att(nBottom+1,nLeft+1,nBottom+1,nRight+1,nShadowAtt)}
   aSaved[2] := {nTop+1,nRight+1,nBottom,nRight+1,;
       att(nTop+1,nRight+1,nBottom,nRight+1,nShadowAtt)}
CASE nShadowPos = SHADOW_UPPER_RIGHT .and. nTop > 0 .and. nRight < Maxcol()
   aSaved[1] := {nTop-1,nLeft+1,nTop-1,nRight+1,;
       att(nTop-1,nLeft+1,nTop-1,nRight+1,nShadowAtt)}
   aSaved[2] := {nTop,nRight+1,nBottom-1,nRight+1,;
       att(nTop,nRight+1,nBottom-1,nRight+1,nShadowAtt)}
CASE nShadowPos = SHADOW_UPPER_LEFT .and. nTop > 0 .and. nLeft > 0
   aSaved[1] := {nTop-1,nLeft-1,nTop-1,nRight-1,;
       att(nTop-1,nLeft-1,nTop-1,nRight-1,nShadowAtt)}
   aSaved[2] := {nTop,nLeft-1,nBottom-1,nLeft-1,;
       att(nTop,nLeft-1,nBottom-1,nLeft-1,nShadowAtt)}
otherwise
   aSaved := nil
ENDCASE
return aSaved

//----------------------------------------------------------------------
function sbunshadow(aSaved)
if aSaved#nil
  restscreen(aSaved[1,1],aSaved[1,2],aSaved[1,3],aSaved[1,4],aSaved[1,5])
  restscreen(aSaved[2,1],aSaved[2,2],aSaved[2,3],aSaved[2,4],aSaved[2,5])
endif
return nil

