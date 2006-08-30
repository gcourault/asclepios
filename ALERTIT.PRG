* ------------------------------------------------
* AlerTit.prg
* Permite alertar si el titular es 01,02,51 ¢ 52
* ------------------------------------------------
function alertit()
if ( AFILIADO->BAPOBL = "01" .or. AFILIADO->BAPOBL = "02" .or. AFILIADO->BAPOBL = "51" .or. AFILIADO->BAPOBL = "52" ) .and. BAORDE = "01"
	tone( 100 , 3 )
	do case
		case AFILIADO->BAPOBL = "01" .or. AFILIADO->BAPOBL = "02"
		msg("Comprobante perteneciente a TITULAR",;
		    "Personal en Actividad ARMADA" )
		case AFILIADO->BAPOBL = "51" .or. AFILIADO->BAPOBL = "52"
		msg("Comprobante perteneciente a TITULAR",;
		    "Personal en Actividad PREFECTURA" )
	endcase
endif
return NIL
