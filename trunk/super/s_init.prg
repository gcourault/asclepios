# include "box.ch"
FUNCTION initsup(lMakePublic)
static lPublicized := .f.
static lDetermineColor := .f.
MEMVAR _reports, _forms, _queries, _help, _lister, _scroller, _colors
MEMVAR _tododbf, _todontx1, _todontx2, _todontx3
MEMVAR c_normcol, c_normmenu, c_popcol, c_popmenu
MEMVAR c_frame, c_shadatt, c_shadpos, c_xplode
MEMVAR _superprn,query_exp, _checkprn,_supiscolor
lMakepublic := iif(lMakePublic#nil,lMakePublic,.t.)

if !lDetermineColor
  if SLS_ISCOLOR()
    SATTCOLOR()
  ELSE
    SATTMONO()
  endif
  lDetermineColor := .t.
endif

if lMakePublic
  if !lPublicized
    PUBLIC _reports, _forms, _queries, _help, _lister, _scroller, _colors
    PUBLIC _tododbf, _todontx1, _todontx2, _todontx3
    PUBLIC c_normcol, c_normmenu, c_popcol, c_popmenu
    PUBLIC c_frame, c_shadatt, c_shadpos, c_xplode
    PUBLIC _superprn,query_exp, _checkprn,_supiscolor
    lPublicized := .t.
  endif
  C_NORMCOL     := sls_normcol()        // Normal colors
  C_NORMMENU    := sls_normmenu()       // Normal colors - menu
  C_POPCOL      := sls_popcol()         // Popup colors
  C_POPMENU     := sls_popmenu()        // Popup colors - menu
  C_FRAME       := sls_frame()          // Popup box frames
  C_SHADATT     := sls_shadatt()        // Shadow attribute
  C_SHADPOS     := sls_shadpos()        // Shadow position
  C_XPLODE      := sls_xplode()         // Popup boxes explode/implode

  QUERY_EXP     := sls_query()          // Last stored query expression
  _SUPERPRN     := sls_prn()            // Default printer
  _CHECKPRN     := sls_prnc()           // Check the printer
  _SUPISCOLOR   := sls_iscolor()        // Is this a color monitor

  _REPORTS      := slsf_report()        // Name/location of REPORTS file
  _FORMS        := slsf_form()          // Name/location of FORMS file
  _QUERIES      := slsf_query()         // Name/location of QUERIES file
  _LISTER       := slsf_list()          // Name/location of LISTS file
  _TODODBF      := slsf_todo()          // Name/location of TODO file
  _TODONTX1     := slsf_tdn1()          // Name/location of TODO index 1
  _TODONTX2     := slsf_tdn2()          // Name/location of TODO index 2
  _TODONTX3     := slsf_tdn3()          // Name/location of TODO index 3
  _HELP         := slsf_help()          // Name/location of HELP file
  _SCROLLER     := slsf_scroll()        // Name/location of SCROLLER file
  _COLORS       := slsf_color()         // Name/location of COLORS file

endif
return nil

