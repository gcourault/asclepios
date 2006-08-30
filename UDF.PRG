* Programa.: UDF.PRG
* Contenido: User defined Functions (Funciones definidas por usuario)
* Autor....: Gustavo A. Courault
 
** FALLO(Texto)          - visualizar mensaje de error
*** CONSULTA(Texto)       - preguntar S/N
*** SKIPOK()              - comprobar EOF/BOF
*** MUESTRA(y,x,Texto)    - muestra el texto letra a letra
*** CENTRO(FILA,EXTR.IZQ,EXTR.DER,TEXTO)
*                         - muestra TEXTO en el centro de EXT.DER, EXT.IZQ
*** BUSCA(AREA,CLAVE,CAMPO)  - busca y muestra lo que encuentra
*
*** CHEQUEA(AREA,CLAVE,CAMPO) - BUSCA, VALIDA Y MUESTRA
*** DBFUNC                - PROGRAMA PARA DBEDIT
*** FECHLETR(FECHA) - TRASFORMA UNA FECHA EN LA FORMA : XX DE <MES> DE XXXX
*** Nro20Car - transforma un nro a un caracter con <n> ceros adelante

*** FALLO() ************************** visualizar mensaje de error
 
* Despu‚s de una simple se¤al acustica se visualiza el texto de la    
* llamada de funci¢n (m x. 65 caracteres), en l¡nea 24.
* El acuse de recibo es a trav‚s de la barra espaciadora.
 
FUNCTION FALLO 
PARAMETER textofallo
 
@ 24,00
?? chr(7)
@ 24,02 SAY textofallo
SET COLOR TO W*+/N,N/W
SET CURSOR OFF
@ 24,66 SAY "Pulsar Espacio"
SET CURSOR ON
DO WHILE INKEY() <> 32  
ENDDO                   
SET COLOR TO
@ 24,00
 
RETURN("")
 
*** Fin  FALLO() ****************************************************
 
*** CONSULTA() ******************************* Consulta (Si o No)
 
* Despu‚s de visualizar el texto se pregunta por "S" o bien "N"
* y se devuelve la letra correspondiente.
 
FUNCTION CONSULTA
PARAMETER textocons  
sn = "S"
 
@ 24,00 
@ 24,02 SAY textocons +" (S/N) ";
        GET sn PICTURE "!" valid(sn $ "SN")
READ
@ 24,02
 
RETURN(sn)
 
*** Fin CONSULTA() **************************************************
*** SKIPOK() ********************************comprobar  EOF/BOF 
 
* Detectado EOF() GO BOTTOM; detectado BOF() GO TOP
FUNCTION SKIPOK
 
IF BOF()
  GO TOP
ENDIF
IF EOF()
  GO BOTTOM
ENDIF
RETURN("")
 
*** Fin SKIPOK() ****************************************************
 
*** MUESTRA(y,x,Texto)**************************muestra texto letra letra
 
 
* Muestra Texto letra a letra comenzando en (y,x)
* Par metros: Texto
*             y: fila de comienzo del Texto
*             x: columna de comienza del Texto
*
* Devuelve  : nada
***********************************************************************
FUNCTION MUESTRA
 
PARAMETERS f,c,texto
 
FOR i = 1 to LEN(texto)
   @ f,(c + i - 1) SAY SUBSTR(texto,i,1)
   ?? chr(7)
   FOR x = 1 to 10
   NEXT x
NEXT i
 
RETURN("")
 
*** Fin MUESTRA() ****************************************************
 
 
function centro
 
parameter row,left,right,text
 
col = right - left
col = int((col - len(text))/2)
 
@ row,col say text
return("")
******** Fin Centro() ************************************************

*********funcion BUSCA()**********************************************
* Objeto : buscar y mostrar un texto de una base de datos
* Parametros: area de trabajo , clave y campo a mostrar
**********************************************************************
FUNCTION BUSCA
 
PARAMETER XAREA,CLAVE,campo

private cadena
marea = SELECT()

select (&xarea)
seek clave

cadena = &campo 

select (marea)

return(cadena)
*******************fin busca()***********************************
*******************funcion chequea()*****************************
* Parametros: area,clave,campo
* objeto: validar una entrada
*
function chequea
 
PARAMETER XAREA,CLAVE,campo
private  marea

m->marea = SELECT()
select (&xarea)

seek clave
if found()
        ?? " " + &campo
        select (m->marea)
        return(.t.)
else
        select(m->marea)
        return(.f.)
endif
**********************************fin chequea()***********************
 
* The following are user-defined functions that
* demonstrate various user-interface applications.
 
FUNCTION Dup_Chk
* Syntax ...: logical = Dup_Chk(<variable>, <work area>)
* Author ...: Ray Love
* Date .....: June 1, 1986 modified September 1, 1987
*
PARAMETERS dup_no, workarea
 
* An empty value is acceptable.
IF EMPTY(dup_no)
        RETURN .T.
ENDIF
 
* Integrity check.
*IF LEN(TRIM(dup_no)) < LEN(dup_no)
*        fallo("El campo debe completarse")
*        RETURN .F.
*ENDIF
 
* Duplicate check.
lastarea = SELECT()
SELECT (workarea)
SEEK dup_no
IF FOUND()
        msg("Ya est  en el archivo")
        validation = .F.
ELSE
        validation = .T.
ENDIF
SELECT (lastarea)
RETURN validation
 
FUNCTION Err_msg
PARAMETERS msg
SAVE SCREEN
row = 24
msg = msg + ", presione una tecla."
col = INT((80 - LEN(msg))/2) - 2
@ row, col CLEAR TO row + 2, col + LEN(msg) + 4
@ row, col TO row + 2, col + LEN(msg) + 4 DOUBLE
@ row + 1, col + 2 SAY msg
INKEY(0)
RESTORE SCREEN
RETURN ""
 
************************FUNCTION DBFUNC()************************
function dbfunc
parameter modo,campo
     private salida,tecla
      
     if type("yahayalta") = "U"
             public yahayalta
             yahayalta = .f.
     endif
      
     if type("ifestado") = "U"
             private ifestado
             ifestado = .f.
     endif
      
     if type("ifalta") = "U"
             private ifalta
             ifalta = .t.
     endif
      
     if type("ifmodif") = "U"
             private ifmodif
             ifmodif = .t.
     endif
      
     if type("ifbaja") = "U"
             private ifbaja
             ifbaja = .t.
     endif
      
     salida = 1
      
     tecla = lastkey()
     do case
             case (modo = 0 .or. modo = 1) .and. tecla = 5;
             .and. eof() .and. lastrec()#0
                     salida = 2
                     yahayalta = .f.
             case ((modo = 2 .and. tecla = 24) .or. modo =3);
                     .and. ifalta
                     salida = iif(yahayalta,2,3)
                     yahayalta = !yahayalta
             case modo = 4
                     do case
                     case tecla = 27
                             salida = 0
                     case tecla = 10
                             keyboard chr(30)
                             pack
                             salida = 2
                             
                     case tecla = 7 .and. !eof() .and. ifbaja
                     
                             if deleted()
                                     recall
                             else
                                     delete
                             endif
                     case (tecla = 13 .or. (tecla > 31 .and. tecla <176).or.tecla = -1);
                             .and. (ifmodif .or. eof())
                             
                             private nregis,expind,valind
                             nregis = lastrec()
                             expind = indexkey(0)
                             valind = expind
                             
                             keyboard chr(iif(tecla#13,tecla,0))
                             set cursor on
									  if tecla = -1
									  		keyboard chr(255)
										endif
                             do editar
                             set cursor off
									  if campo = 1
										  keyboard chr(4)+chr(4)+chr(5)
   	                          *keyboard chr(24)
      							  else
									  	  keyboard chr(19)+chr(19)+chr(24)
									endif
		                       yahayalta = .f.
                             if (lastrec() = nregis .and. valind # expind);
                                     .and. !empty(expind)
                                     salida = 2
                             endif
                     endcase
             endcase
             
             if ifestado
                     private cad,color
                     color = setcolor()
                     set color to i
                     cad = ' '+iif(eof(),'<Nuevo>',ltrim(str(recno())) + '/' +;
                             ltrim(str(lastrec())))+' '+iif(deleted(),'<Borrado>','')
                     @ 22, 1 say cad + space(78 - len(cad))
                     set color to &color
             endif
             
             return salida
             ***********************************fin dbfunc()********************

function Espia
parameter cadena, argu
private panta, reng, colu

m->reng= row()
m->colu= col()
save scree to m->panta

do case
case type("argu") = "N"
? "******" + "[" + cadena + "]" + str(argu)  + "******"
case type("argu") = "C"
? "******" + "[" + cadena + "]" + argu  + "******"
otherwise
? "*******No se de que se trata el argumento de Espia******"
endcase

inkey(0)

restore scree from m->panta
@ m->reng, m->colu say ""

return 0

* -----------------------------
FUNCTION FECHLETR
PARAMETER xfecha
* -----------------------------
local dia, mes, anio, frase
m->dia = alltrim(str(day(m->xfecha)))
m->mes = cmes(month(m->xfecha))
m->anio = alltrim(str(year(m->xfecha)))
return (m->dia + " de " + m->mes + " de " + m->anio)

* -----------------------------
function cmes
parameter pointer
* -----------------------------
private aMes[12]

if pointer > 12 .or. pointer < 1
	return "*********"
endif

aMes[1] = "Enero"
aMes[2] = "Febrero"
aMes[3] = "Marzo"
aMes[4] = "Abril"
aMes[5] = "Mayo"
aMes[6] = "Junio"
aMes[7] = "Julio"
aMes[8] = "Agosto"
aMes[9] = "Setiembre"
aMes[10] = "Octubre"
aMes[11] = "Noviembre"
aMes[12] = "Diciembre"

return aMes[pointer]

/* ---------------------------------------- */
   Function nro20car
/* ---------------------------------------- */
parameters numero,largo
return right(replicate("0",m->largo)+alltrim(str(m->numero)),m->largo)

**************************************************************************
*
* Function : CRYPTHDR()
* Date     : 10/11/90
* Author   : Lothar Bongartz / Michael Peters
* Return   : LOGICAL, .T. when successful, otherwise .F.
* Usage    : With this function, the header of a DBF file can be
*            encrypted. Only programs with this function and the
*            correct password have a data access.
*            The first function call with a password is coding the
*            header, the next call with the same password is
*            decoding .. and so on ...
* Notes    : The header will be encrypted from byte 10. So, the
*            length entry in byte 8/9 can not be lost. However,
*            all field specifications will be encrypted.
*            At an attempt to open the database under dBASE,
*            the message 'Database encrypted' will be returned.
*
* Example  : CRYPTHDR("STOCK.DBF", "LBONGARTZ")
*
**************************************************************************
FUNCTION CRYPTHDR(cFileName, cPassWord)
LOCAL nRetcode := .F., nSize, cDBFHeader, lWritten

 IF FILE(cFileName)
  * 2 Byte (size) read from header
   nSize := BIN2I(FILESTR(cFileName, 2, 8)) -10

  * read the complete header with the computed size
   cDBFHeader := FILESTR(cFileName, nSize, 10)
   cDBFHeader := CRYPT( cDBFHeader, cPassWord)     
	
   * overwrite the file with the coded/decoded header
   *-----------------------------------------------------
	* Modificacion
	* Hecha el 1/11/94 porque no anda el modulo strfile
   * lWritten := STRFILE(cDBFHeader, cFileName, .T., 10)
	*-----------------------------------------------------
	
	nHandle := fopen( cFileName , 2 )  //apertura del archivo I/O
	fseek( nHandle , 10 )              //correrse 10 bytes
	lWritten := fwrite( nHandle , cDBFHeader ) //grabar la cabecera
	fclose( nHandle )                          //cerrar el archivo
   nRetcode := (lWritten > 0)        // additional check
	
 ENDIF
RETURN(nRetcode)

function printcodes( cCaracter )

set printer on
set console off
?? cCaracter
set printer off
set console on
return NIL

function altd()
return NIL

function cdir()
return NIL

