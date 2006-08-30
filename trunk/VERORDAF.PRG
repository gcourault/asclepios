* -----------------------------
* VerOrdAfil.prg
* -----------------------------
function verordaf()

select 1
if snet_use("OrdAfil","ORDENES",.f.,5,.t.,"No se puede abrir el archivo de Ordenes de los Afiliados - ¨Reintenta?")
	set order to tag ORDAFIL
else
	msg("Un usuario ha bloqueado el archivo",;
	    "O se ha producido un fallo en la red",;
		 "Reintente luego")
  return
endif

editdb(.t.,;
       {"DELEGACION",;
		 "TIPO",;
		 "SERIE",;
		 "RECETA",;
		 "AFILIADO",;
		 "FECHACOMP",;
		 "CODPOSTAL",;
		 "DOMICILIO",;
		 "LOCALIDAD",;
		 "POBLACION"},;
		 {"Delegaci¢n",;
		 "Tipo",;
		 "Serie",;
		 "Receta",;
		 "Afiliado",;
		 "Fecha",;
		 "C.Postal",;
		 "Domicilio",;
		 "Localidad",;
		 "Cod.Poblaci¢n"},.t.)
use
return
*--

