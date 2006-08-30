/*
 ----------------------------------------------------
 Regional.prg
 Menu principal del men£ de la Regional 
 ----------------------------------------------------
 */
#include "inkey.ch"
#include "supmenu.ch"
#include "regional.ch"
#include "mediator.ch"


external var2char
* ---------------
  function main()
* ---------------

local menu
public _cheques

set exclusive off
set century on
set date french
set scoreboard off
setmode(25,80)
* request medntx

* rddsetdefault("medcdx")

request dbfcdx
rddsetdefault( "dbfcdx" )


set defa to .\datos 
set dele on
if snet_use("param" , "param" , .f. , 5 , .t. , "No se puede abrir archivo de par metros - ¨Reintenta?" )
	m->_cheques := param->cheques
endif
use

public usuario  := getenv("USER")

clear
do compro

initsup()
*====== menu globals========*

MENU INIT ;
  WINDOW DIMS 0,0,24,79 FRAME "ÚÄ¿³ÙÄÀ³ ";
  MESSAGE  MCENTER ;
  TITLE TEXT "NETWORK - SISTEMA INTEGRADO DIBA V.1.0 "+ NOMBRE_REGIONAL  TCENTER 
MENU BARPAD 3
MENU MOUSE EXIT AT 0,2 TEXT "[þ]" COLOR "N/W"
MENU FORCE DROP .t.
MENU BOXES FRAME "ÚÄ¿³ÙÄÀ³ " OVER 1 DOWN 1;
  PADLEFT 1 PADRIGHT 1 CROSSBAR "Ã","Ä","´"
if !iscolor()
   MENU COLORS SELECTED "W/N","W+/N" UNSELECTED "N/W","W+/W";
  INACTIVE "N+/W" WINDOW "W/N" MSG "N/W";
  BOXES "N/W" TITLE "W+/N"
else
	MENU COLORS SELECTED "W/N","W+/N" UNSELECTED "N/W","W+/W";
	  INACTIVE "N+/W" WINDOW "W+/B   " MSG "N/G    ";
	  BOXES "N/W" TITLE "W+/G   "
endif


*====== menu structure======*

   BAROPTION "Archivos" ID "archivos" KEY 286 COLUMN 2;
      MESSAGE "Manejo de los archivos que conforman el Sistema"
     DROPSTART DOWN 1 OVER 0
     BOXOPTION "Afiliados       " ID "afiliados";
        MESSAGE "Acceso al archivo de afiliados"
     BOXOPTION "Medicamentos    " ID "medicamentos";
        MESSAGE "Acceso al archivo de Medicamentos"
     BOXOPTION "Prestadores     " ID "prestadores";
        MESSAGE "Acceso al archivo de Prestadores"
	  BOXOPTION "M~Edicos" ID "medicos";
	     MESSAGE "Acceso al archivo de m‚dicos"
	  BOXOPTION "Generar y Asignar Convenios" ID "convenios";
	     MESSAGE "Generar y Asignar Convenios a los Prestadores"
	  BOXOPTION "Traer Datos Delegaci¢n" ID "traer";
	     MESSAGE "Traer informaci¢n desde diskette desde las delegaciones"
	  BOXOPTION "Enviar Datos a la Regional" ID "enviar";
	  	  MESSAGE "Enviar los datos ingresados a la Regional"
	  BOXOPTION "Cambiar Impresi¢n C~heques" ID "confcheq";
	     MESSAGE "Cambiar Impresi¢n Cheques Manual ¢ Formulario Cont¡nuo"
	  BOXOPTION "Salir al Sistema Operativo" ID "salir";
	     MESSAGE "Regresar al sistema operativo"
     DROPEND
   BAROPTION "Mesa de Entradas" ID "mesa" KEY 306 COLUMN 13;
      MESSAGE "Acceso a la mesa de entradas"
     DROPSTART DOWN 1 OVER 1
     BOXOPTION "Ingreso de Comprobantes  " ID "ingcomprob";
        MESSAGE "Ingreso de Comprobates: Facturas"
     BOXOPTION "Libro de Entradas        " ID "libro";
        MESSAGE "Impresi¢n del Libro de Entradas"
     CROSSBAR
     BOXOPTION "Salida de Comprobantes   " ID "comprosalida";
        MESSAGE "Ingreso de documentaci¢n de salida"
     BOXOPTION "Libro de ~Salida          " ID "librosalida";
        MESSAGE "Impresi¢n del libro de Salida"
     BOXOPTION "Consulta de Documentaci¢n" ID "consuldoc";
        MESSAGE "Consulta del estado de la documentaci¢n"
     DROPEND
   BAROPTION "A~Uditor¡a" ID "auditoria" KEY 278 COLUMN 32;
      MESSAGE "Acceso a las operaciones de Auditor¡a"
     DROPSTART DOWN 1 OVER 1
     BOXOPTION "Facturas Prestadores" ID "auditfacturas";
        MESSAGE "Auditor¡a Facturas Prestadores ingresadas"
     BOXOPTION "Listados de D‚bitos " ID "lisdebitos";
        MESSAGE "Listado de D‚bitos por Prestador y Factura"
	  BOXOPTION "Set de Informaci¢n a DIBA" ID "set";
	     MESSAGE "Informaci¢n a DIBA Central reducido"
	  BOXOPTION "An lisis Frecuencial Pr cticas" ID "frec";
	  	  MESSAGE "Frecuencia en base a las Facturas"		  
	  BOXOPTION "An lisis Frecuencial Medicamentos" ID "frecmed";
	  	  MESSAGE "Frecuencia en base a las Facturas"		  
	  
	  BOXOPTION "Estad¡sticas Varias" ID "estad";
	  		MESSAGE "Estad¡sticas no previstas"
     DROPEND
   BAROPTION "Tesorer¡a" ID "tesoreria" KEY 276 COLUMN 44;
      MESSAGE "Acceso al Men£ de Tesorer¡a"
     DROPSTART DOWN 1 OVER 1
	  BOXOPTION "Consulta ~Facturas Ingresadas" ID "viejo";
	     MESSAGE "Ver por Pantalla o Imprimir Facturas entre dos fechas" 
     BOXOPTION "Pedido de Dinero     " ID "pedidodinero";
        MESSAGE "Pedido de Dinero a DIBA central"
     BOXOPTION "Planilla ~Auditor¡a   " ID "planillauditoria";
        MESSAGE "Impresi¢n Planilla Auditor¡a para manejo manual"
	  BOXOPTION "Ingreso ~Manual de D‚bitos" ID "manualdeb";
	     MESSAGE " Ingreso de d‚bitos manuales en auditor¡a"
     BOXOPTION "Generaci¢n de Cheques" ID "gencheques";
        MESSAGE "Impresi¢n de cheques automatizada"
     BOXOPTION "Correspondencia      " ID "correspondencia";
        MESSAGE "Acceso a las funciones de Correspondencia"
     BOXOPTION "Etiquetas            " ID "etiquetas";
        MESSAGE "Acceso a las funciones de Emisi¢n de Etiquetas"
     BOXOPTION "Rendici¢n de Fondos  " ID "rendicion";
        MESSAGE "Emisi¢n planilla rendici¢n de Fondos"
	  BOXOPTION "Rendiciones por Mes" ID "rendtotal";
	     MESSAGE "Impresi¢n de las planillas de rendiciones por mes"
	  
     DROPEND
   BAROPTION "Banco" ID "banco" KEY 304 COLUMN 56;
      MESSAGE "Manejo del Libro Banco"
     DROPSTART DOWN 1 OVER -3
     BOXOPTION "Ingreso Saldo Inicial  " ID "saldo";
        MESSAGE "Ingreso del Saldo inicial de la cuenta bancaria"
     BOXOPTION "Gastos Cuenta Corriente" ID "gastos";
        MESSAGE "Ingreso de los gastos de Cuenta Corriente"
     BOXOPTION "Conciliaci¢n           " ID "conciliacion";
        MESSAGE "Ingreso Cheques cobrados - Lista y suma cheques no cobrados"
     BOXOPTION "Ingreso Che~que         " ID "ingcheque";
        MESSAGE "Ingreso de un cheque manual"
     BOXOPTION "Dep¢sito               " ID "deposito";
        MESSAGE "Ingreso de un dep¢sito a la cuenta corriente"
     BOXOPTION "C~uenta Corriente       " ID "ctacte";
        MESSAGE "Ver la cuenta corriente"
     BOXOPTION "Lista Libro Banco      " ID "librobanco";
        MESSAGE "Impresi¢n del Libro Banco"
     BOXOPTION "Anulaci¢n de un cheque " ID "anulacion";
        MESSAGE "Anulaci¢n de un cheque"
     DROPEND
	BAROPTION "Informes" ID "informes" column 65 message "Informes varios"
	  dropstart down 1 over -13
	  boxoption "Listado de Prestaciones" id "listact";
	      message "Prestaciones a Personal en actividad (Titulares)"
	  boxoption "Listado Poblaci¢n ~11" id "listac11";
	      message "Prestaciones Personal poblaci¢n 11" 
	  boxoption "Listado de Reintegros" id "listrein";
	      message "Listado de reintegros entre dos fechas"
		boxoption "Informe de Prestaciones"  id "inf01";
			message "Imprime los totales de Pr cticas y Medicamentos de ARA y PFA"
	  dropend
	  
*====== menu handling=====*


menu := MENU WRAP
MENU SHOW menu
DO WHILE .T.
  MENU DO menu 
  do case   
  case MENU EXIT REQUEST
  	exit
  case MENU EXCEPTION
    if lastkey() == K_ESC
	 	exit
	  endif
  case MENU ACTION REQUEST
    do case   
	 case MENU ACTION ID == "listact" && prestaciones a afiliados en actividad
	 	menu hide menu boxes
		listact()
		menu show menu
	 case MENU ACTION ID == "listac11" && prestaciones poblaci¢n 11
	 	menu hide menu boxes
                * listac11()
		menu show menu
	 case MENU ACTION ID == "listrein" &&listado de reintegros
	   menu hide menu boxes
		listrein()
		menu show menu
	 case MENU ACTION ID == "inf01" && Informe 01
	 	menu hide menu boxes
		do inf01
		menu show menu
    case MENU ACTION ID == "afiliados" && Afiliados
	   afiliado()
    case MENU ACTION ID == "medicamentos" && Medicamentos    
	   medicame()
    case MENU ACTION ID == "prestadores" && Prestadores     
	   prestado()
	 case MENU ACTION ID == "medicos"
	 	medicos()
	 case MENU ACTION ID == "convenios"
	 	convenio()
	 case MENU ACTION ID == "traer"
	 	do traer
    case MENU ACTION ID == "ingcomprob" && Ingreso de Comprobantes  
	   MENU HIDE menu
	   IngComp()
		MENU SHOW menu
    case MENU ACTION ID == "libro" && Libro de Entradas
	 	MENU HIDE menu
		LibroEnt()
		MENU SHOW menu 
    case MENU ACTION ID == "comprosalida" && Salida de Comprobantes   
    case MENU ACTION ID == "librosalida" && Libro de Salida          
    case MENU ACTION ID == "consuldoc" && Consulta de Documentaci¢n
	 case MENU ACTION ID == "set"
	 	menu hide menu boxes
		do set_eli
		menu show menu
	 case MENU ACTION ID == "frec"
	 	menu hide menu boxes
		do frec
		menu show menu
	 case MENU ACTION ID == "frecmed"
	 	menu hide menu boxes
                * do frecmed
		menu show menu

	 case MENU ACTION ID == "estad"
	 	menu hide menu
		supersuper()
		menu show menu
    case MENU ACTION ID == "auditfacturas" && Facturas Prestadores
	 	menu hide menu boxes
		do audit
		menu show menu
    case MENU ACTION ID == "lisdebitos" && Listados de D‚bitos 
	 	menu hide menu boxes
		do lisdeb
		menu show menu
	 case MENU ACTION ID == "ordenesafil"
	 	menu hide menu
		do ordafil
		menu show menu
	 case MENU ACTION ID == "BorraComp"
	 	menu hide menu boxes
                * do borra
		menu show menu
	 case MENU ACTION ID == "VerOrdAfil"
	   menu hide menu boxes
		do VerOrdAf
		menu show menu
	 case MENU ACTION ID == "BorraOrdAf"
	   menu hide menu boxes
		do BorraOrd
		menu show menu
	 case MENU ACTION ID == "autorizaciones"
	   menu hide menu boxes
		do cargaut
		menu show menu
	 case MENU ACTION ID == "ImpReintegro"
	 	menu hide menu boxes
		do ImpReint
		menu show menu
	 case MENU ACTION ID == "viejo"
	 	menu hide menu boxes
		do impfact
		menu show menu
    case MENU ACTION ID == "pedidodinero" && Pedido de Dinero     
	 	menu hide menu boxes
	 	do impfax
		menu show menu
    case MENU ACTION ID == "planillauditoria" && Planilla Auditor¡a   
	 	menu hide menu boxes
		do impaud
		menu show menu
	 case MENU ACTION ID == "manualdeb"
	 	menu hide menu boxes
		do ingaud
		menu show menu
    case MENU ACTION ID == "gencheques" && Generaci¢n de Cheques
	 	menu hide menu boxes
		do impchequ
		menu show menu
    case MENU ACTION ID == "correspondencia" && Correspondencia      
	 	menu hide menu boxes
		cartas()
		menu show menu
    case MENU ACTION ID == "etiquetas" && Etiquetas
	 	menu hide menu boxes
		etiqueta()
		menu show menu
    case MENU ACTION ID == "rendicion" && Rendici¢n de Fondos  
	 	menu hide menu boxes
		do rendic
		menu show menu
	 case MENU ACTIO ID == "rendtotal"
	 	menu hide menu boxes
		do rendtodo
		menu show menu
    case MENU ACTION ID == "saldo" && Ingreso Saldo Inicial
	 	MENU HIDE MENU BOXES
		INGSALDO()
		MENU SHOW MENU
    case MENU ACTION ID == "gastos" && Gastos Cuenta Corriente
	 	MENU HIDE MENU BOXES
		gastos()
		menu show menu
    case MENU ACTION ID == "conciliacion" && Conciliaci¢n
	 	MENU HIDE MENU BOXES
		anexoa()
		concilia()
		menu show menu
    case MENU ACTION ID == "ingcheque" && Ingreso Cheque
	 	menu hide menu boxes
	 	ingcheque()
		menu show menu
    case MENU ACTION ID == "deposito" && Dep¢sito               
	 	menu hide menu boxes
		deposito()
		menu show menu
    case MENU ACTION ID == "ctacte" && Cuenta Corriente 
	   menu hide menu boxes
		ccte()
		menu show menu
    case MENU ACTION ID == "librobanco" && Lista Libro Banco
	   menu hide menu boxes
		librobco()
		menu show menu
    case MENU ACTION ID == "anulacion" && Anulaci¢n de un cheque 
	   MENU HIDE MENU BOXES
		BORRACHEQ()
		MENU SHOW MENU
	 case MENU ACTION ID == "enviar"
	   menu hide menu boxes
		enviar()
		menu show menu
	 case MENU ACTION ID = "confcheq"
	 	menu hide menu boxes
		do confcheq
		menu show menu
	 case MENU ACTIO ID == "salir"
	 	exit
    endcase   
  endcase   
ENDDO       
MENU HIDE  menu

function editar()
return NIL
