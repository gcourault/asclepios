/* -----------------------------------------------------------------
   ImpFAX.prg
   Programa para imprimir las facturas ingresadas
   Llamado por REGIONAL.PRG
   ----------------------------------------------------------------- */
	
EXTERNAL GETDATE
# include "inkey.ch"
# include "regional.ch"

function impfax()
* initsup()
set date to french


USE NUMERO
numfax := FAX
USE


SELECT 2
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.T.,;
            "No se puede acceder al archivo IN1PRES - ¨Reintenta?")
	set order to tag PRCOD
ELSE
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 0342-4554785")	
	RETURN
ENDIF

SELECT 3
IF !SNET_USE("FACTU01","FACTURA",.F.,5,.T.,;
            "No se puede acceder al archivo FACTU01 - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 0342-4554785")	
	RETURN
ENDIF

SET RELATION TO PRESTADOR INTO PRESTADOR

MFECHA1 = ctod( space(10) )
MFECHA2 = ctod( space(10) )
m->marriba = makebox(2,2,5,78,sls_normcol() )
centro(3,2,78,"CON LA TECLA <F3> SE ACCEDE AL CALENDARIO")

SET KEY K_F3 TO tomafecha
nTop := 0 
nLeft := 0 
nBottom := 6
nRight := 40
sbcenter( @nTop , @nLeft , @nBottom , @nRight )
m->cAbajo := makebox( nTop , nLeft , nBottom , nRight )
* POPREAD(.T.,"Desde Fecha:",@mfecha1,"@d","Hasta Fecha:",@mfecha2,"@d")
@ nTop + 1, nLeft + 2 say "Desde Fecha:" get mfecha1 
@ nTop + 2, nLeft + 2 say "Hasta Fecha:" get mfecha2
read

unbox(m->marriba)
unbox(m->cAbajo)

* --
mensaje1 = "Desde Fecha: " + var2char(mfecha1)
mensaje2 = "Hasta Fecha: " + var2char(mfecha2)
MSG("Ha seleccionado imprimir Facturas Ingresadas",mensaje1,mensaje2)

IF MESSYN("¨Comienza la Impresi¢n?")
	SELECT FACTURA
	SET FILTER TO FPRES >= MFECHA1 .AND. ;
	              FPRES <= MFECHA2 
	IF EOF()
		msg("No hay Facturas entre estas dos fechas.")
		close databases
		return
	ENDIF	
	*-
	mmensaje := "Armando el FAX N§ :" + alltrim(VAR2CHAR(M->numfax))
	msecuencia := 1
	*-
	GO TOP
	msuma := 0.00	
	mdebitado := 0.00
	mapagar   := 0.00

	ProgOn( m->mmensaje )
	while !eof()
		IF SREC_LOCK(5,.T.,"No se puede grabar el N§ de FAX - ¨Reintenta?")
			REPLACE FACTURA->SECUENCIA WITH msecuencia++
			REPLACE FACTURA->FAX WITH padl( M->numfax , 5 , "0" )
			msuma := msuma + FACTURA->TOTFACTU
			mdebitado := mdebitado + FACTURA->TOTDEB
			mapagar := mapagar + FACTURA->TOTAPAG
			UNLOCK
		ENDIF
		SKIP
                progdisp( recno() , reccount() )
	END
	progOff()
	
	SET FILTER TO FAX == padl( M->numfax , 5 , "0" ) .AND. LEFT(PRESTADOR,1) = "S"
	GO TOP
	
	progOn( "Copiando a una base auxiliar" )
        COPY TO TMP for progdisp( recno() , reccount() )
	progOff()
	
	SET FILTER TO FAX == padl( M->numfax , 5 , "0" )
	go top
	
	plswait( .t. , "Sumando..." )
	SUM TOTFACTU TO mtotfactu FOR LEFT(PRESTADOR,1) = "R" .OR. LEFT(PRESTADOR,1) = "P"
	SELECT 3
	IF SNET_USE("TMP","TEMPO",.T.,5,.F.)
		APPEND BLANK
		REPLACE REGIONAL  WITH "5000"
		REPLACE FACTURA   WITH "99999999"
		REPLACE PRESTADOR WITH "9999999"
		REPLACE FPRES     WITH DATE()
		REPLACE TOTFACTU  WITH mtotfactu
		REPLACE FAX       WITH padl( m->numfax , 5 , "0" )
		REPLACE DELEGACION WITH "5001"
	ELSE
		MSG("No se puede imprimir por un error de acceso de red")
	ENDIF
	plswait( .f. )
   SET RELATION TO PRESTADOR INTO PRESTADOR

	IF P_READY()
		DO M_IMPFAX
	ENDIF
ENDIF
CLOSE DATABASES
*
USE NUMERO
IF SREC_LOCK(5,.T.,"No se puede bloquear registro - ¨Reintenta?")
	replace FAX with M->numfax + 1
ENDIF
USE

* --
USE FAX
set order to tag fax
IF SADD_REC(5,.T.,"No se puede grabar el registro del FAX - ¨Reintenta?")
	IF SREC_LOCK(5,.T.,"No se puede bloquear el registro - ¨Reintenta?")
		replace FAX with padl( M->numfax , 5 , "0" )
		replace DESDE with CTOD(var2char(M->mfecha1))
		replace HASTA with CTOD(var2char(M->mfecha2))
		replace FACTURADO with M->msuma
		replace DEBITADO with M->mdebitado
		replace PAGADO   with M->mapagar
	ENDIF
	UNLOCK
ENDIF
USE
* --

RETURN

* ------------
proc tomafecha
* ------------
para p1,p2,p3
private mfecha

mfecha := getdate()

if p3 = "M->V1"
	mfecha1 := mfecha
else
	mfecha2 := mfecha
endif
return

procedure m_impfax

//---- here we write the declares 
#DEFINE M_DBF           1      // dbf name                                      
#DEFINE M_TITLE         2      // report title (name)                           
#DEFINE M_NDXKEY        3      // index key                                     
#DEFINE M_MAJKEY        4      // major group portion of index key              
#DEFINE M_MINKEY        5      // minor group portion of index key              
#DEFINE M_MAJTEXT       6      // major group header text                       
#DEFINE M_MINTEXT       7      // minor group header text                       
#DEFINE M_WIDTH         8      // page width in characters                      
#DEFINE M_LENGTH        9      // page length in lines                          
#DEFINE M_LEFTM        10      // left margin in columns (#blank columns)       
#DEFINE M_TOPM         11      // top margin in rows (#blank rows)              
#DEFINE M_SPACE        12      // line spacing 0 = single, 1 = double           
#DEFINE M_PAUSE        13      // pause between pages ? Y/N                     
#DEFINE M_NPLINES      14      // page eject if (n) lines left on group change  
#DEFINE M_EJB4         15      // page eject before report                      
#DEFINE M_EJAFT        16      // page eject after report                       
#DEFINE M_EJMAJOR      17      // page eject on new major group                 
#DEFINE M_EJMINOR      18      // page eject on new minor group                 
#DEFINE M_EJGRAND      19      // page eject before grand totals page           
#DEFINE M_UNTOTAL      20      // underline totals ? Y/N                        
#DEFINE M_MAJCHR       21      // major totals underline character              
#DEFINE M_MINCHR       22      // minor totals underline character              
#DEFINE M_NHEAD        23      // number of header lines (1-9)                  
#DEFINE M_NFOOT        24      // number of footer lines (1-9)                  
#DEFINE M_NTITL        25      // number of title lines (1 or 2)                
#DEFINE M_TSEP         26      // character for title seperator line            
#DEFINE M_COLSEP       27      // character for column seperator line           
#DEFINE M_CSEPWID      28      // width of column seperator                     
#DEFINE M_LINESEP      29      // detail line seperator character               
#DEFINE M_NCOLS        30      // number of report columns defined              
#DEFINE M_STDHEAD      33      // use standard 2 line header (page#, date, time)
#DEFINE M_QUERY        35      // last used query filter                        
#DEFINE M_FULLSUM      36      // full or sumary only report                    
#DEFINE M_PRNCODE      37      // printer code for before report                
#DEFINE M_AFTCODE      38      // printer code for after report                 

//-------------------------------------------------------------------
EXTERNAL Stuff, Ljust, Rjust, allbut, subplus, startsw, Stod, crunch, strtran
EXTERNAL centr, proper, doyear, womonth, woyear, trueval, dtow
EXTERNAL endswith, dtdiff, daysin, datecalc, begend, nozdiv, stretch, arrange
//-------------------------------------------------------------------

local cBuffer,i
LOCAL aValues[38]

LOCAL aHeader := array(4)
LOCAL aFooter := array(0)

*- column descriptions
LOCAL aColumns := array( 8)
LOCAL aTitles  := array( 8)
LOCAL aWidths  := array( 8)
LOCAL aTotalYN := array( 8)
LOCAL aPictures := array( 8)

//---- here we write the inits
// Here are the report layout and other values-----------------------

aValues[M_TITLE]    := [FAX                                ]
aValues[M_NDXKEY]   := []
aValues[M_MAJKEY]   := []
aValues[M_MINKEY]   := []
aValues[M_WIDTH]    := 132
aValues[M_LENGTH]   :=  72
aValues[M_LEFTM]    :=  0
aValues[M_TOPM]     :=  0
aValues[M_SPACE]    := 1
aValues[M_PAUSE]    := .f.
aValues[M_EJB4]     := .f.
aValues[M_EJAFT]    := .t.
aValues[M_EJMAJOR]  := .f.
aValues[M_EJMINOR]  := .f.
aValues[M_EJGRAND]  := .f.
aValues[M_NHEAD]    := 4
aValues[M_NFOOT]    := 0
aValues[M_NTITL]    := 1
aValues[M_TSEP]     := [Í]
aValues[M_COLSEP]   := [³]
aValues[M_CSEPWID]  := 1
aValues[M_LINESEP]  := [Ä]
aValues[M_NCOLS]    :=  8
aValues[M_STDHEAD]  := .f.
aValues[M_MAJTEXT]  := [Major Group :            ]
aValues[M_MINTEXT]  := [Minor Group :            ]
aValues[M_NPLINES]  := 4
aValues[M_UNTOTAL]  := .f.
aValues[M_MAJCHR]   := [-]
aValues[M_MINCHR]   := [=]
aValues[M_FULLSUM]  := [F]
aValues[M_PRNCODE]  := [015                                               ]
aValues[M_AFTCODE]  := [018                                               ]
aValues[M_QUERY]    := [                                                                                                    ]

//---- here we write the header inits
aHeader[1] := [FAX N§: ] + padl( m->numfax , 5 , "0" ) + [ OBJETO: REQURIMIENTO ANTICIPO DE FONDOS A RENDIR                                                                      ]
aHeader[2] := [REGIONAL DIBA: ] + NOMBRE_REGIONAL + [ - CODIGO:                                                                                              ]
aHeader[3] := [FECHA: ] + dtoc( date() )
aHeader[4] := [MONTO TOTAL SOLICITADO:                                                                                                             ]

//---- here we write the footer inits

//---- here we write the column inits
aColumns[1] := [SECUENCIA]
aTitles[1] := [N§  ]
aWidths[1] := [ 4]
aTotalYN[1] := [N]
aPictures[1] := [9999]
aColumns[2] := [FPRES]
aTitles[2] := [Fecha Recepci¢n]
aWidths[2] := [15]
aTotalYN[2] := [N]
aPictures[2] := []
aColumns[3] := [TOTFACTU]
aTitles[3] := [Importe $   ]
aWidths[3] := [12]
aTotalYN[3] := [Y]
aPictures[3] := [9999999.99]
aColumns[4] := [FACTURA]
aTitles[4] := [N§ Factura]
aWidths[4] := [10]
aTotalYN[4] := [N]
aPictures[4] := []
aColumns[5] := [PRESTADOR]
aTitles[5] := [N§ Prestador]
aWidths[5] := [12]
aTotalYN[5] := [N]
aPictures[5] := []
aColumns[6] := [B->PRNOMB]
aTitles[6] := [Entidad, Raz¢n Social, Profesional        ]
aWidths[6] := [39]
aTotalYN[6] := [N]
aPictures[6] := []
aColumns[7] := [DELEGACION]
aTitles[7] := [DELEG]
aWidths[7] := [ 5]
aTotalYN[7] := [N]
aPictures[7] := []
aColumns[8] := [DATECALC(FPAG,35,1)]
aTitles[8] := [Venc.   ]
aWidths[8] := [19]
aTotalYN[8] := [N]
aPictures[8] := []


//---and finally, a call to the print engine...
rPrintRepPDF({aValues,aHeader,aFooter,aColumns,aTitles,aWidths,aTotalYN,aPictures},.f.)

//---end---


