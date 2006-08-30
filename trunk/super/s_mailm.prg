#define REC_TAGGED 1
#define REC_QUERY  2
#define REC_ALL    3

#define FWORDPERFECT42  1
#define FWORDPERFECT50  2
#define FMSWORD         3
#define FMSWORD50       4

//-----------------------------------------------------------------------
function smailmerge(aFieldNames,aFieldDesc,aFieldTypes,aFieldLens,aFieldDeci)
local nRecordSele := 0
local nFormat     := 0
local aTagged     := {}
local aFieldsPicked
local aPickedNames := {}
local aPickedBlocks:= {}
local i
local bQuery := {||.t.}
LOCAL nOldCursor     := setcursor(0)
LOCAL cInScreen      := Savescreen(0,0,24,79)
LOCAL cOldColor      := Setcolor(sls_normcol())
local nMenuChoice

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
@1,1,8,40 BOX sls_frame()
@1,5 SAY '[Fusi¢n de Correspondencia]'
@18,1,23,78 BOX sls_frame()
@19,2 SAY "Crear tipo de fusi¢n :"
@20,2 SAY "Tipo de Filtro       :"
@21,2 SAY "Campos seleccionados :"

DO WHILE .T.
  @19,25 SAY   padr({"",;
                     "Wordperfect 4.2     ",;
                     "Wordperfect 5.0     ",;
                     "Microsoft Word (antes de 5.0)",;
                     "Microsoft Word 5.0" }[nFormat+1],40)
  @20,25 SAY   padr({"Todos los registros",;
                     "Registros Marcados",;
                     "Registros Consultados"}[nRecordSele+1],40)
  @21,25 say alltrim(str(len(aPickedBlocks)))+" campo elegidos      "
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Tipo de Fusi¢n"
  @03,3 PROMPT "Qu‚ Campos"
  @04,3 PROMPT "Filtro"
  @05,3 PROMPT "Crear archivo de Fusi¢n"
  @06,3 PROMPT "Salir"
  MENU TO nMenuChoice
  Setcolor(sls_popcol())

  DO CASE
  CASE nMenuChoice = 1
      nFormat := menu_v("[Formato de Fusi¢n de Correspondencia]",;
                        "A  Wordperfect 4.2                    ",;
                        "B  Wordperfect 5.0                    ",;
                        "C  Microsoft Word (antes de 5.0)      ",;
                        "D  Microsoft Word 5.0                 ",;
                        "Salir")
      nFormat := iif(nFormat==5,0,nFormat)
  CASE nMenuChoice = 2
      aPickedBlocks := {}
      aPickedNames := {}
      aFieldsPicked := tagarray(aFieldDesc,"Elija los campos")
      if len(aFieldsPicked)>0
       for i = 1 to len(aFieldsPicked)
          if aFieldTypes[aFieldsPicked[i]]<>"M"
            if aFieldTypes[aFieldsPicked[i]]=="C" .and. messyn("Trim "+aFieldDesc[aFieldsPicked[i]])
              aadd(aPickedBlocks,&("{||trim("+aFieldNames[aFieldsPicked[i]]+")}") )
              aadd(aPickedNames,aFieldDesc[aFieldsPicked[i]])
            else
              aadd(aPickedBlocks,&("{||trans("+aFieldNames[aFieldsPicked[i]]+",'')}") )
              aadd(aPickedNames,aFieldDesc[aFieldsPicked[i]])
            endif
          endif
       next
      endif
  CASE nMenuChoice = 3
      nRecordSele := menu_v("[Escribir los registros a fusionar:]",;
                             "Registros Marcados","Registros Marcados",;
                             "Todos los registros","Salir")
      nRecordSel := iif(nRecordSel>2,0,nRecordSel)
      do case
      case nRecordSele = REC_TAGGED
         tagit(aTagged,aFieldNames,aFieldDesc,"Registros a Fusi¢n")
         if len(aTagged)>0
           bQuery := {||ascan(aTagged,recno())>0}
         endif
      case nRecordSele = REC_QUERY
         query(aFieldNames,aFieldDesc,aFieldtypes," a Fusi¢n",.t.)
         if !empty(sls_query())
           bQuery := sls_bquery()
         endif
      endcase
  CASE nMenuChoice = 4 .and. len(aPickedNames)>0 .and. nFormat >0
      writemerge(bQuery,nFormat,aPickedNames,aPickedBlocks)
  CASE nMenuChoice = 4 .and. len(aPickedNames)=0
      msg("Primero seleccione los campos")
  CASE nMenuChoice = 4 .and. nFormat =0
      msg("Primero seleccione el formato")
  CASE nMenuChoice = 5
      exit
  ENDCASE
END
Restscreen(0,0,24,79,cInScreen)
Setcolor(cOldColor)
setcursor(nOldCursor)
return nil
//-----------------------------------------------------------------

static function writemerge(bQuery,nFormat,aPickedNames,aPickedBlocks)
local cOutfile,nOuthandle,i,cBox
local nCopied := 0

cOutFile := space(12)
popread(.t.,"Nombre del archivo de fusi¢n a crear ",@cOutFile,"")
if empty(cOutFile)
   return .f.
endif
nOutHandle := fcreate(cOutFile)
if nOutHandle < 0
   msg("No se puede crear el archivo de fusi¢n")
   return .f.
endif
go top
plswait(.t.,"Buscando...")
locate for eval(bQuery)
plswait(.f.)
if !found()
    fclose(nOutHandle)
    msg("No se encontraron coincidencias")
    return .f.
endif

cBox = MAKEBOX(6,15,14,70,sls_popcol())
@ 9,15 SAY 'Ã'
@ 9,70 SAY '´'
@ 9,16 TO 9,69
@ 7,20 SAY "Copiando registros"
@ 8,20 SAY "desde "+alias()+" en "

do case
case nFormat = FWORDPERFECT42
        ??"Wordperfect 4.2 archivo fusi¢n"
case nFormat = FWORDPERFECT50
        ??"Wordperfect 5.0 archivo fusi¢n"
case nFormat = FMSWORD
        ??"Microsoft Word archivo fusi¢n < 5.0"
        for i = 1 to len(aPickedNames)-1
                fwrite(nOutHandle,chr(34)+aPickedNames[i]+chr(34)+",")
        next
        fwrite(nOutHandle,chr(34)+atail(aPickedNames)+chr(34)+chr(13)+chr(10))
case nFormat = FMSWORD50
        ??"Microsoft Word archivo fusi¢n 5.0"
        for i = 1 to len(aPickedNames)-1
                fwrite(nOutHandle,aPickedNames[i]+",")
        next
        fwrite(nOutHandle,atail(aPickedNames)+chr(13)+chr(10))
endcase
@ 11,20 SAY "0 Registros copiados"

while found()
   do case
   case nFormat = FWORDPERFECT42
      for i = 1 to len(aPickedBlocks)
              fwrite(nOutHandle,alltrim(eval(aPickedBlocks[i]))+chr(18)+chr(10))
      next
      fwrite(nOutHandle,chr(5)+chr(10))
   case nFormat = FWORDPERFECT50
      for i = 1 to len(aPickedBlocks)
              fwrite(nOutHandle,alltrim(eval(aPickedBlocks[i]))+chr(18)+chr(13))
      next
      fwrite(nOutHandle,chr(5)+chr(12))
   case nFormat = FMSWORD
      for i = 1 to len(aPickedBlocks)-1
              fwrite(nOutHandle,chr(34)+alltrim(eval(aPickedBlocks[i]))+chr(34)+",")
      next
      fwrite(nOutHandle,chr(34)+alltrim(eval(atail(aPickedBlocks)))+chr(34)+chr(13)+chr(10))
   case nFormat = FMSWORD50
      for i = 1 to len(aPickedBlocks)-1
              fwrite(nOutHandle,alltrim(eval(aPickedBlocks[i]))+",")
      next
      fwrite(nOutHandle,alltrim(eval(atail(aPickedBlocks)))+chr(13)+chr(10))
   endcase
   nCopied++
   @ 11,20 SAY alltrim(str(nCopied))
   ??" Registros copiados"
   continue
end
fclose(nOutHandle)
@13,20 say "Proceso completo! Pulse una tecla"
inkey(20)
unbox(cBox)
return .t.

