*- assumes DBF/Indexes open
*- link with SUPER.LIB and REPORT.LIB
*- call with DO IMPMESA.PRG                                         


EXTERNAL CRUNCH

function impmesa()
INITSUP()


*- headers and footers arrays
*no header array
*- no footer array

*- column description arrays
PRIVATE sfr_cont[ 5]   && column contents
PRIVATE sfr_title[ 5]  && column titles (delimited with ; for multiple)
PRIVATE sfr_width[ 5]  && column widths
PRIVATE sfr_total[ 5]  && column totals Y/N
PRIVATE sfr_picts[ 5]  && column picture


*- private variables
PRIVATE sfp_usetag,sfp_useqbe
PRIVATE sf_ndxkey,sf_majkey,sf_minkey
PRIVATE sf_title,sf_width,sf_length,sf_leftm,sf_topm,sf_space,sf_pause
PRIVATE sf_ejb4,sf_ejaft,sf_ejmajor,sf_ejminor,sf_ejgrand,sf_nhead,sf_nfoot
PRIVATE sf_ntitl,sf_tsep,sf_colsep,sf_csepwid,sf_linesep,sf_ncols,sf_stdhead
PRIVATE sf_majtext,sf_mintext,sf_nplines,sf_untotal,sf_majchr
private sf_minchr,sf_fullsum
PRIVATE sf_prncode,sf_query,sf_aftcode
   
   

*- assignments      
sfp_usetag = .f.
sfp_useqbe = .f.
sf_ndxkey = []
sf_minkey = []
sf_majkey = []
sf_title = [MESA DE ENTRADAS]
sf_tsep = [Í]
sf_colsep = [³]
sf_linesep = [Ä]
sf_majtext = [Grupo Mayor :]
sf_mintext = [Grupo Menor :]
sf_majchr = [Ä]
sf_minchr = [Í]
sf_fullsum = [F]
sf_prncode = [015]
sf_aftcode = [018]
sf_query= []
sf_width  = 132
sf_length =  72
sf_leftm  =  0
sf_topm   =  0
sf_space  = 1
sf_pause  = .f.
sf_ejb4   = .f.
sf_ejaft  = .f.
sf_ejmajor= .f.
sf_ejminor= .f.
sf_ejgrand= .f.
sf_nhead  = 0
sf_nfoot  = 0
sf_ntitl  = 1
sf_csepwid= 1
sf_ncols  =  5
sf_stdhead= .f.
sf_nplines= 4
sf_untotal= .f.
   
*- header array contents   
   
*- footer array contents   
   
*- column array contents   
   
sfr_cont[1] = [ORDEN]
sfr_cont[2] = [INGRESO]
sfr_cont[3] = [NUMERO]
sfr_cont[4] = [DESCRIPCIO]
sfr_cont[5] = [CORRESPOND]

sfr_title[1] = [N§           ]
sfr_title[2] = [F.Ingreso ]
sfr_title[3] = [Comp. N§       ]
sfr_title[4] = [Descripci¢n                                                 ]
sfr_title[5] = [Forma Llegada  ]

sfr_width[1] = [15]
sfr_width[2] = [10]
sfr_width[3] = [15]
sfr_width[4] = [60]
sfr_width[5] = [15]

sfr_total[1] = [N]
sfr_total[2] = [N]
sfr_total[3] = [N]
sfr_total[4] = [N]
sfr_total[5] = [N]

sfr_picts[1] = []
sfr_picts[2] = []
sfr_picts[3] = []
sfr_picts[4] = []
sfr_picts[5] = []

   
   
   
*- call main print routine   
* SFRR_PMAIN()   
