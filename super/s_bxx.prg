#define SHADOW_LOWER_LEFT 1
#define SHADOW_LOWER_RIGHT 3
#define SHADOW_UPPER_LEFT  7
#define SHADOW_UPPER_RIGHT 9
#include "box.ch"
function bxx(nTop,nLeft,nBottom,nRight,nAttribute,;
             nShadowPos,nShadowAtt,cFrame)

local cColorString
if valtype(nAttribute)=="C"
   cColorString := nAttribute
elseif valtype(nAttribute)=="N"
   cColorString := at2char(nAttribute)
else
   cColorString := setcolor()
endif

if valtype(cFrame)#"C"
*  cFrame="ÚÄ¿³ÙÄÀ³ "
   cFrame=B_SINGLE 
elseif empty(cFrame)
*  cFrame="ÚÄ¿³ÙÄÀ³ "
  cFrame=B_SINGLE
endif
if valtype(nShadowPos)#"N"
  nShadowPos = 0
endif
if valtype(nShadowAtt)#"N"
  nShadowAtt = 8
endif

dispbox(nTop,nLeft,nBottom,nRight,cFrame,cColorString)

DO CASE
CASE nShadowPos = SHADOW_LOWER_LEFT .and. nBottom <Maxrow() .and. nLeft > 0
   att(nTop+1,nLeft-1,nBottom+1,nLeft-1,nShadowAtt)
   att(nBottom+1,nLeft-1,nBottom+1,nRight-1,nShadowAtt)
CASE nShadowPos = SHADOW_LOWER_RIGHT .and. nBottom <Maxrow() .and. nRight < Maxcol()
   att(nBottom+1,nLeft+1,nBottom+1,nRight+1,nShadowAtt)
   att(nTop+1,nRight+1,nBottom+1,nRight+1,nShadowAtt)
CASE nShadowPos = SHADOW_UPPER_RIGHT .and. nTop > 0 .and. nRight < Maxcol()
   att(nTop-1,nLeft+1,nTop-1,nRight+1,nShadowAtt)
   att(nTop,nRight+1,nBottom-1,nRight+1,nShadowAtt)
CASE nShadowPos = SHADOW_UPPER_LEFT .and. nTop > 0 .and. nLeft > 0
   att(nTop-1,nLeft-1,nTop-1,nRight-1,nShadowAtt)
   att(nTop,nLeft-1,nBottom-1,nLeft-1,nShadowAtt)
ENDCASE
return ''

