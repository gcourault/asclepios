FUNCTION writefile(cnFile,caWrite)
local nFileHandle,nIter,nArrayLen


* open file and position pointer at the end of file
IF VALTYPE(cnFile)=="C"
  nFileHandle := FOPEN(cnFile,2)
  *- if not joy opening file, create one
  IF Ferror() <> 0
    nFileHandle := Fcreate(cnFile,0)
  ENDIF
  FSEEK(nFileHandle,0,2)
ELSE
  nFileHandle := cnFile
  FSEEK(nFileHandle,0,2)
ENDIF

IF VALTYPE(caWrite) == "A"
  nArrayLen = aleng(caWrite)
  * if its an array, do a loop to write it out
  FOR nIter = 1 TO nArrayLen
    *- append a CR/LF
    FWRITE(nFileHandle,caWrite[nIter]+CHR(13)+CHR(10) )
  NEXT
ELSE
  * must be a character string - just write it
  FWRITE(nFileHandle,caWrite+CHR(13)+CHR(10) )
ENDIF

* close the file
IF VALTYPE(cnFile)=="C"
  Fclose(nFileHandle)
ENDIF
RETURN .T.

