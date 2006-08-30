FUNCTION nkey(cIndexName)
local nFileHandle,cNextByte
local cIndexKey := ''

* adjust for no path specified
if !("\"$cIndexName .or. ":"$cIndexName)
   cIndexName := getdfp()+cIndexName
endif
IF FILE(cIndexName)
  
  *- open the file in shared mode
  nFileHandle = FOPEN(cIndexName,64)
  IF Ferror() = 0
    
    *- what kind of index ? (key description starts at different bytes)
    IF UPPER(RIGHT(cIndexName,2)) = "DX"
      FSEEK(nFileHandle,24)
    ELSE
      FSEEK(nFileHandle,22)
    ENDIF
    
    *- get the next byte
    cNextByte := Freadstr(nFileHandle,1)
    cIndexKey := ''
    
    *- keep doing until chr(0) reached
    DO WHILE !ASC(cNextByte)=0
      *- add value to cIndexKey
      cIndexKey += cNextByte
      *- get the next byte
      cNextByte := Freadstr(nFileHandle,1)
    ENDDO
    
  ENDIF
  Fclose(nFileHandle)
ENDIF
RETURN cIndexKey


