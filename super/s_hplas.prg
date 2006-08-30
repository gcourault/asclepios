/*
   Area Fill ID
   ------------
     Area fill uses a percentage of shading OR a pattern

     The shading percentages are:

           "1 thru 2" = 2% shade
          "3 thru 10" = 10% shade
         "11 thru 20" = 20% shade
         "21 thru 35" = 30% shade
         "36 thru 55" = 45% shade
         "56 thru 80" = 70% shade
         "81 thru 99" = 90% shade
                "100" = 100% shade

     The pattern fills are:

        #"1" = horizontal lines
         "2" = vertical lines
         "3" = diagonal lines top right to bottom left
         "4" = diagonal lines top left to bottom right
         "5" = #1 and # 2 combined
         "6" = #3 and # 4 combined

*/

//±±±±±±±±±±±±±±±±±±±±±
// Job Control
//±±±±±±±±±±±±±±±±±±±±±

//----------------------------------------------------
function SL_Reset
return chr(27)+"E"

//-------------------------------------------------------
function SL_Copies(nCopies)
RETURN ( chr(27)+'&l'+alltrim(str(nCopies))+'X' )

//±±±±±±±±±±±±±±±±±±±±±
// Page Control
//±±±±±±±±±±±±±±±±±±±±±

//----------------------------------------------------
function SL_Lands
return CHR(27) + '&l1O'

//----------------------------------------------------
function SL_Port
return CHR(27) + '&l0O'

//----------------------------------------------------
/*
  1 Executive           (7.25" x 10.5")
  2 Letter              (8.5" x 11")
  3 Legal               (8.5" x 14")
 26 A4                  (210mm x 297mm)
 80 Monarch Envelope    (3 7/8" x 7 1/2")
 90 COM-10 Envelope     (4 1/8" x 8 1/2")
 91 International C5    (162mm  x 229mm)
*/
function SL_Pagesize(nSize)
nSize := iif(ascan({1,2,3,26,80,81,90,91},nSize)>0,nSize,2)
return CHR(27) + "&l"+alltrim(str(nSize))+"A"

//-------------------------------------------------------
function SL_LeftMarg(nColumn)
RETURN ( chr(27)+'&a'+alltrim(str(nColumn))+'L' )

//-------------------------------------------------------
function SL_RightMarg(nColumn)
RETURN ( chr(27)+'&a'+alltrim(str(nColumn))+'M' )

//-------------------------------------------------------
function SL_TopMarg(nLines)
RETURN ( chr(27)+'&l'+alltrim(str(nLines))+'E' )

//----------------------------------------------------
function SL_Setlpi(nLpi)
local cLpi := alltrim(str(nLpi))
cLpi := iif(cLpi$"1;2;3;4;6;8;12;16;24;48",cLpi,"6")
return CHR(27) + "&l"+cLpi+"D"

//-------------------------------------------------------
function SL_Eject
RETURN ( chr(12) )



//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// Cursor control by Row/Column
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//-------------------------------------------------------------
function SL_Goto(nRow,nCol)
return chr(27)+"&a"+alltrim(str(nRow))+"r"+alltrim(str(nCol))+"C"

//-------------------------------------------------------------
function SL_DownRow(nRows)
local cPrefix := iif(nRows>0,"+","")
return chr(27)+"&a"+cPrefix+alltrim(str(nRows))+"R"

//-------------------------------------------------------------
function SL_OverCol(nCols)
local cPrefix := iif(nCols>0,"+","")
return chr(27)+"&a"+cPrefix+alltrim(str(nCols))+"C"

//-------------------------------------------------------------
Function SL_PushCurs
return chr(27)+"&f0S"

//-------------------------------------------------------------
Function SL_PopCurs
return chr(27)+"&f1S"


//±±±±±±±±±±±±±±±±±±±±±
// Font Selection
//±±±±±±±±±±±±±±±±±±±±±

//-------------------------------------------------------------
function SL_Bold
return chr(27)+"(s7B"

//-------------------------------------------------------------
function SL_Normal
return chr(27)+"(s0B"

//-------------------------------------------------------------
function SL_Under
return chr(27)+"&d0D"

//-------------------------------------------------------------
function SL_UnderOff
return chr(27)+"&d@"

//-------------------------------------------------------------
Function SL_Italic
return chr(27)+"(s1S"

//-------------------------------------------------------------
Function SL_ItalicOff
return chr(27)+"(s0S"

//----------------------------------------------------
function SL_Setcpi(nCpi)
local cCpi := alltrim(str( iif(nCpi#nil,Round(nCpi,2),10) ))
return CHR(27) + "(s"+cCpi+"H"



//±±±±±±±±±±±±±±±±±±±±±±±
// Drawing by Row/Column
//±±±±±±±±±±±±±±±±±±±±±±±

//----------------------------------------------------
Function SL_Fill(nTop,nLeft,nBottom,nRight,cShade,cFill,nCpi,nLpi)
local cReturn := ""
local nRows := nBottom-nTop+1
local nCols := nRight-nLeft+1
local cDotsV,cDotsH
local cFilltype := iif(cShade#nil,"2","3")
cFill  := iif(cFill#nil,cFill,"6")
cShade := iif(cShade#nil,cShade,"20")
nCpi := iif(nCpi==nil,10,nCpi)
nLpi := iif(nLpi==nil,6,nLpi)
cReturn += SL_Goto(nTop,nLeft)
cReturn += chr(27)+"*c"  // area fill
cDotsH  := alltrim(str(SL_InchtoDot(nCols/nCpi)))
cDotsV  := alltrim(str(SL_InchtoDot(nRows/nLpi)))
cReturn += alltrim(cDotsH)+"a"+alltrim(cDotsV)+"b"
if cFillType=="2" //shade
  cReturn += cShade+"g2P"
else
  cReturn += cFill+"g3P"
endif
return cReturn

//-------------------------------------------------------
Function SL_Hline(nTop,nLeft,nBottom,nRight,cShade,nDPIThick,nCpi)
local cReturn := ""
local nCols := nRight-nLeft+1
local cDotsH
cShade := iif(cShade#nil,cShade,"100")
nCpi := iif(nCpi==nil,10,nCpi)
nDPIThick := iif(nDPIThick==nil,2,nDPIThick)
cReturn += SL_Goto(nTop,nLeft)
cReturn += chr(27)+"*c"  // area fill
cDotsH  := alltrim(str(SL_InchtoDot(nCols/nCpi)))
cReturn += alltrim(cDotsH)+"a"+alltrim(str(nDPIThick))+"b"
cReturn += cShade+"g2P"
return cReturn

//-------------------------------------------------------
Function SL_Vline(nTop,nLeft,nBottom,nRight,cShade,nDPIThick,nLpi)
local cReturn := ""
local nRows := nBottom-ntop+1
local cDotsV
cShade := iif(cShade#nil,cShade,"100")
nLpi := iif(nLpi==nil,6,nLpi)
nDPIThick := iif(nDPIThick==nil,2,nDPIThick)
cReturn += SL_Goto(nTop,nLeft)
cReturn += chr(27)+"*c"  // area fill
cDotsV  := alltrim(str(SL_InchtoDot(nRows/nLpi)))
cReturn += alltrim(str(nDPIThick))+"a"+alltrim(cDotsV)+"b"
cReturn += cShade+"g2P"
return cReturn


//-------------------------------------------------------
Function SL_Box(nTop,nLeft,nBottom,nRight,cShade,nDPIThick,nCpi,nLpi)
local cReturn := ""
local nCols := nRight-nLeft+1
local nRows := nBottom-ntop+1
local cDotsH,nDotsH
local cDotsV,nDotsV
local cDPI,cbottomDots
local cLowerRight
cShade := iif(cShade#nil,cShade,"100")
nCpi := iif(nCpi==nil,10,nCpi)
nLpi := iif(nLpi==nil,6,nLpi)

nDotsH  := SL_InchtoDot(nCols/nCpi)
nDotsV  := SL_InchtoDot(nRows/nLpi)
cDotsH  := alltrim(str(nDotsH))
cDotsV  := alltrim(str(nDotsV))
nDPIThick := iif(nDPIThick==nil,2,nDPIThick)
cDPI  := alltrim(str(nDPIThick))
cBottomDots := alltrim(str(nDotsH+nDPIThick))
//--- top
cReturn += SL_Goto(nTop,nLeft)
cReturn += chr(27)+"*c"  // area fill
cReturn += cDotsH+"a"+cDPI+"b"
cReturn += cShade+"g2P"
//-- left
cReturn += chr(27)+"*c"  // area fill
cReturn += cDPI+"a"+cDotsV+"b"
cReturn += cShade+"g2P"
//--- right
cReturn += SL_MoveH(nDotsH)
cReturn += chr(27)+"*c"  // area fill
cReturn += cDPI+"a"+cDotsV+"b"
cReturn += cShade+"g2P"
//--- bottom
cReturn += SL_MoveH(-nDotsH)
cReturn += SL_MoveV(nDotsV)
cReturn += chr(27)+"*c"  // area fill
cReturn += cBottomDots+"a"+cDPI+"b"
*cReturn += cDotsH+"a"+cDPI+"b"
cReturn += cShade+"g2P"
return cReturn


//-------------------------------------------------------
function SL_Wrap(lWrap)
IF lWrap
  RETURN ( chr(27)+'&s0C' )
ENDIF
RETURN ( chr(27)+'&s1C' )

//±±±±±±±±±±±±±±±±±±±±±
// Internal
//±±±±±±±±±±±±±±±±±±±±±
//----------------------------------------------------
static function SL_Inchtodot(nInches)  // presuming 300 DPI
return 300 * nInches

//----------------------------------------------------
static function SL_MoveH(nDots)
local cPrefix := iif(nDots>0,"+","")
return chr(27)+"*p"+cPrefix+alltrim(str(nDots))+"X"

//----------------------------------------------------
static function SL_MoveV(nDots)
local cPrefix := iif(nDots>0,"+","")
return chr(27)+"*p"+cPrefix+alltrim(str(nDots))+"Y"

