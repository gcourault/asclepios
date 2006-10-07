/* -----------------------------------------------------------------
   ImpFACT.prg
   Programa para imprimir las facturas ingresadas
   Llamado por REGIONAL.PRG
   ----------------------------------------------------------------- */
EXTERNAL EVALQ	
EXTERNAL GETDATE

# include "inkey.ch"

function impfact()

initsup()

SELECT 2
IF SNET_USE("IN1PRES","PRESTADOR",.F.,5,.T.,;
            "No se puede acceder al archivo IN1PRES - ¨Reintenta?")
	set order to tag prcod
ELSE
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 0342-4554785")	
	RETURN
ENDIF

SELECT 3
IF !SNET_USE("FACTU01","FACTU01",.F.,5,.T.,;
            "No se puede acceder al archivo FACTU01 - ¨Reintenta?")
	MSG("Se ha producido un error en la red",;
	    "Llamar a Soporte T‚cnico: ",;
		 "T.E. 0342-4554785")	
	RETURN
ENDIF

SET RELATION TO PRESTADOR INTO PRESTADOR

MFECHA1 = ctod( space(10) )
MFECHA2 = ctod( space(10) )
m->marriba = makebox(2,2,5,78,c_normcol)
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
MSG("Ha seleccionado las Facturas Ingresadas",mensaje1,mensaje2)

cConsulta := space(0)

if messyn("¨Genera una Consulta?")
	cConsulta := query()
endif
if messyn( "¨Usa una clasificaci¢n?" )
	aIndices := {}
	pickndx( aIndices )
	openind( aIndices )
endif
IF MESSYN("¨Comienza con el proceso?")
	SELECT 3
	if empty(cConsulta)
                SET FILTER TO FPRES >= MFECHA1 .AND. ;
                              FPRES <= MFECHA2
	else
		SET FILTER TO FPRES >= MFECHA1 .AND. ;
		              FPRES <= MFECHA2 .and. ;
                              EVALQ( sls_query() )
	endif
	GO TOP
	IF EOF()
		msg("No hay Facturas entre estas dos fechas.")
		close databases
		return
	ENDIF	
	IF MESSYN("Seleccione:","Impresora","Pantalla")
		reporterpdf()
*		quikreport( "FACTURA" )
	ELSE
		* --
		private sfr_cont[11]
		private sfr_title[11]
		* --
		sfr_cont[1] = [SECUENCIA]
		sfr_cont[2] = [FPRES]
		sfr_cont[3] = [FAX]
		sfr_cont[4] = [FACTURA]
		sfr_cont[5] = [PRESTADOR]
		sfr_cont[6] = [B->PRNOMB]
		sfr_cont[7] = [FPAG]
		sfr_cont[8] = [TOTFACTU]
		sfr_cont[9] = [CHEQUEREG]
		sfr_cont[10] = [TOTDEB]
		sfr_cont[11]= [TOTAPAG]
		
		sfr_title[1] = [Sec.  ]
		sfr_title[2] = [Fecha Recepci¢n]
		sfr_title[3] = [N§ Fax]
		sfr_title[4] = [N§ FACTURA     ]
		sfr_title[5] = [N§ Prestador]
		sfr_title[6] = [Entidad, Raz¢n social, profesional    ]
		sfr_title[7] = [F.Pag.]
		sfr_title[8] = [Importe $   ]
		sfr_title[9] = [Cheque N§]
		sfr_title[10] = [D‚bitos]
		sfr_title[11] = [Total Pagado]
		editdb(.T.,sfr_cont,sfr_title,.t.)
	ENDIF
ENDIF
CLOSE DATABASES
*
RETURN

