#define REC_TAGGED 1
#define REC_QUERY  2
#define REC_ALL    3
#define CRLF       CHR(13)+CHR(10)

#DEFINE FORM_SDF     1
#DEFINE FORM_DELIM   2

//-----------------------------------------------------------------------
function sexport(aFieldNames,aFieldDesc,aFieldTypes,aFieldLens,aFieldDeci)
local nRecordSele := 0
local nFormat     := 0
local cCharDelim  := ["]  // double quot
local cFieldDelim := [,]  // comma
local aTagged     := {}
local aFieldsPicked
local aPickedNames := {}
local aPickedBlocks:= {}
local aPickedTypes := {}
local aPickedLens  := {}
local i
local bQuery := {||.t.}
LOCAL nOldCursor     := setcursor(0)
LOCAL cInScreen      := Savescreen(0,0,24,79)
LOCAL cOldColor      := Setcolor(sls_normcol())
local nMenuChoice
local cOutFile       := ""

if valtype(aFieldNames)+valtype(aFieldDesc)+valtype(aFieldtypes)+;
   valtype(aFieldLens)+valtype(aFieldDeci)<>"AAAAA"
  aFieldNames := array(fcount())
  aFieldDesc  := array(fcount())
  aFieldTypes := array(fcount())
  aFieldLens  := array(fcount())
  aFieldDeci  := array(fcount())
  afields(aFieldNames)
  afields(aFieldDesc)
  fillarr(aFieldNames,aFieldTypes,aFieldLens,aFieldDeci)
endif

*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,12,40 BOX sls_frame()
@1,5 SAY '[Exportar a ASCII]'
@18,1,23,78 BOX sls_frame()
@19,2 SAY "Export Type       :"
@20,2 SAY "Filter type       :"
@21,2 SAY "Fields selected   :"

DO WHILE .T.
  @19,25 SAY   padr({"None selected",;
                     "SDF",;
                     "Delimited "}[nFormat+1],40)

  @20,25 SAY   padr({"All Records",;
                     "Tagged Records",;
                     "Records meeting Query"}[nRecordSele+1],40)

  @21,25 say alltrim(str(len(aPickedBlocks)))+" fields selected      "
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Tipo de Exportaci¢n "
  @03,3 PROMPT "Qu‚ Campos          "
  @04,3 PROMPT "Filtro              "
  @05,3 PROMPT "Crear archivo ASCII "
  @06,3 PROMPT "Salir"
  @08,3 PROMPT "Separador de Caracter "+"("+cCharDelim+")"
  @09,3 PROMPT "Delimitador de Campo  "+"("+cFieldDelim+")"
  @10,3 PROMPT "Ver Archivo           "+cOutFile
  MENU TO nMenuChoice
  Setcolor(sls_popcol())

  DO CASE
  CASE nMenuChoice = 0 .or. nMenuChoice = 5
      exit
  CASE nMenuChoice = 1
      nFormat := menu_v("[Formato  a Exportar]",;
                        "SDF",;
                        "Delimitado",;
                        "Salir")
      nFormat := iif(nFormat==3,0,nFormat)
  CASE nMenuChoice = 2
      aPickedBlocks := {}
      aPickedNames := {}
      aPickedTypes := {}
      aPickedLens  := {}
      aFieldsPicked := tagarray(aFieldDesc,"Seleccione los campos")
      if len(aFieldsPicked)>0
       for i = 1 to len(aFieldsPicked)
          if aFieldTypes[aFieldsPicked[i]]<>"M"
            aadd(aPickedNames,aFieldDesc[aFieldsPicked[i]])
            aadd(aPickedTypes,aFieldTypes[aFieldsPicked[i]])
            aadd(aPickedLens ,aFieldLens[aFieldsPicked[i]])
            if aFieldTypes[aFieldsPicked[i]]=="N"
             aadd(aPickedBlocks,&("{||STR("+aFieldNames[aFieldsPicked[i]]+")}") )
            elseif aFieldTypes[aFieldsPicked[i]]=="L"
             aadd(aPickedBlocks,&("{||iif("+aFieldNames[aFieldsPicked[i]]+",'T','F')}") )
            elseif aFieldTypes[aFieldsPicked[i]]=="D"
             aadd(aPickedBlocks,&("{||DTOS("+aFieldNames[aFieldsPicked[i]]+")}") )
            elseif aFieldTypes[aFieldsPicked[i]]=="C"
             aadd(aPickedBlocks,&("{||"+aFieldNames[aFieldsPicked[i]]+"}") )
            endif
          endif
       next
      endif
  CASE nMenuChoice = 3
      nRecordSele := menu_v("[Escribir archivo ASCII desde:]",;
                             "Registros Marcados","Registros con Consulta",;
                             "Todos los Registros","Salir")
      nRecordSel := iif(nRecordSel>2,0,nRecordSel)
      do case
      case nRecordSele = REC_TAGGED
         tagit(aTagged,aFieldNames,aFieldDesc,"Registros a Unir")
         if len(aTagged)>0
           bQuery := {||ascan(aTagged,recno())>0}
         endif
      case nRecordSele = REC_QUERY
         query(aFieldNames,aFieldDesc,aFieldtypes," a Unir",.t.)
         if !empty(sls_query())
           bQuery := sls_bquery()
         endif
      endcase
  CASE nMenuChoice = 4 .and. len(aPickedNames)>0 .and. nFormat >0
    if nFormat == FORM_DELIM
       cOutFile := xdelim(aPickedNames,aPickedTypes,aPickedBlocks,cCharDelim,cFieldDelim,bQuery)
    elseif nFormat == FORM_SDF
       cOutFile := xsdf(aPickedNames,aPickedTypes,aPickedBlocks,aPickedLens,bQuery)
    endif
  CASE (nMenuChoice=6 .or. nMenuChoice=7) .and. ;
     nFormat <> FORM_DELIM
     msg("esta opci¢n es para archivos DELIMITADOS")
  CASE nMenuChoice = 6  // character delimiter
     popread(.f.,'Ingrese el CARACTER delimitador de campo (el default es "):',@cCharDelim,"")
  CASE nMenuChoice = 7  // field delimiter
     popread(.f.,'Ingrese el delimitador de CAMPO ( el default es ,):',@cFieldDelim,"")
  CASE nMenuChoice = 8  // view file
     if !empty(cOutFile)
       fileread(2,2,22,78,cOutFile,cOutfile)
     else
       msg("No se escribi¢ el archivo")
     endif
  ENDCASE
END
Restscreen(0,0,24,79,cInScreen)
Setcolor(cOldColor)
setcursor(nOldCursor)
return nil
//-----------------------------------------------------------------

static func xdelim(aPickedNames,aPickedTypes,aPickedBlocks,;
                   cCharDelim,cFieldDelim,bQuery)
local cOutfile,nOuthandle,i,cBox
local nCopied := 0
local cThisValue
cOutFile := space(12)
popread(.t.,"Nombre del archivo DELIMITADO a crear ",@cOutFile,"")
if empty(cOutFile)
   return ""
endif
nOutHandle := fcreate(cOutFile)
if nOutHandle < 0
   msg("no se puede crear el archivo DELIMITADO")
   return ""
endif
go top
plswait(.t.,"Buscando...")
locate for eval(bQuery)
plswait(.f.)
if !found()
    fclose(nOutHandle)
    msg("No se encuentran registros coincidentes")
    return ""
endif

cBox = MAKEBOX(6,15,14,70,sls_popcol())
@ 9,15 SAY 'Ã'
@ 9,70 SAY '´'
@ 9,16 TO 9,69
@ 7,20 SAY "Copiando Registros"
@ 8,20 SAY "desde "+alias()+" en "+cOutfile
@ 11,20 SAY "0 Registros Copiados"

while found()
   for i = 1 to len(aPickedBlocks)
      cthisValue := alltrim(eval(aPickedBlocks[i]))
      if aPickedTypes[i]=="C"
        cThisValue := cCharDelim+cThisValue+cCharDelim
      endif
      if i < len(aPickedBlocks)
        cThisValue+=cFieldDelim
      endif
      fwrite(nOutHandle,cThisValue)
   next
   fwrite(nOutHandle,CRLF)
   nCopied++
   @ 11,20 SAY alltrim(str(nCopied))
   ??" Registros Copiados"
   continue
end
fwrite(nOutHandle,CHR(26))
fclose(nOutHandle)
@13,20 say "Proceso Completo! Pulse una tecla"
inkey(20)
unbox(cBox)
return cOutFile

//------------------------------------------------------------------------
static func xsdf(aPickedNames,aPickedTypes,aPickedBlocks,aPickedLens,bQuery)
local cOutfile,nOuthandle,i,cBox
local nCopied := 0
local cThisValue
cOutFile := space(12)
popread(.t.,"Nombre del archivo SDF a crear ",@cOutFile,"")
if empty(cOutFile)
   return ""
endif
nOutHandle := fcreate(cOutFile)
if nOutHandle < 0
   msg("No se puede crear archivo SDF")
   return ""
endif
go top
plswait(.t.,"Buscando...")
locate for eval(bQuery)
plswait(.f.)
if !found()
    fclose(nOutHandle)
    msg("No se encontraron registros coincidentes")
    return ""
endif

cBox = MAKEBOX(6,15,14,70,sls_popcol())
@ 9,15 SAY 'Ã'
@ 9,70 SAY '´'
@ 9,16 TO 9,69
@ 7,20 SAY "Copiando registros"
@ 8,20 SAY "desde "+alias()+" en "+cOutfile
@ 11,20 SAY "0 Registros copiados"

while found()
   for i = 1 to len(aPickedBlocks)
      cthisValue := eval(aPickedBlocks[i])
      do case
      case aPickedTypes[i]=="C"
        cThisValue := padr(alltrim(cThisValue),aPickedLens[i])
      case aPickedTypes[i]=="D"
        cThisValue := padr(alltrim(cThisValue),8)
      case aPickedTypes[i]=="N"
        cThisValue := padl(alltrim(cThisValue),aPickedLens[i])
      endcase
      fwrite(nOutHandle,cThisValue)
   next
   fwrite(nOutHandle,CRLF)
   nCopied++
   @ 11,20 SAY alltrim(str(nCopied))
   ??" Registros copiados"
   continue
end
fwrite(nOutHandle,CHR(26))
fclose(nOutHandle)
@13,20 say "Proceso completo! Pulse una tecla"
inkey(20)
unbox(cBox)
return cOutFile

