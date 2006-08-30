//--------------------------------------------------------------------------
FUNCTION fmove2next(nHandle)

local cChunk
local nOldOffset := FSEEK(nHandle,0,1)
local nNewOffset
local nAtChr10
local lSuccess := .f.
DO WHILE .T.

  nNewOffset := FSEEK(nHandle,0,1)
  
  *- read in a cChunk of the file
  cChunk := ''
  cChunk := Freadstr(nHandle,100)
  
  IF LEN(cChunk)=0   // eof()
    lSuccess := .f.
    exit
  ENDIF
  
  *- if we've got a CR , we've read in a line
  *- otherwise we'll loop again and read in another cChunk
  IF (nAtChr10 := AT(CHR(10),cChunk)) > 0
    lSuccess := .t.
    *- go back to beginning of line
    FSEEK(nHandle,nNewOffset)
    FSEEK(nHandle,nAtChr10,1)
    EXIT
  ENDIF
ENDDO
if !lSuccess
  fseek(nHandle,nOldOffset)
endif
RETURN lSuccess

