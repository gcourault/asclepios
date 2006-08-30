
*==== COMMAND DEFINES=============
*===========================================================
#translate MENU INIT ;
              [WINDOW [DIMS <wt>,<wl>,<wb>,<wr>] [FRAME <wf>]] [<nof:NOFRAME>];
              [<ismsg:MESSAGE> [<onbot:ON BOTTOM>] [<mcen:MCENTER>]] ;
              [<istit:TITLE> [TEXT <text>] [<ontop:ON TOP>] ;
              [<tcen:TCENTER>] ] ;
                            => sm_meninit(<wt>,<wl>,<wb>,<wr>,<wf>,<.nof.>,;
                               <.ismsg.>,<.onbot.>,<.mcen.>,<.istit.>,;
                               <text>,<.ontop.>,<.tcen.>)
#translate MENU BARPAD <bp> => sm_barpad(<bp>)

#translate MENU MOUSE EXIT  AT <mr>,<mc> TEXT <mtxt> COLOR <c>;
                            => sm_mousex(<mr>,<mc>,<mtxt>,<c>)
#translate MENU SET MOUSE <onoff> ;
                            => sm_setglob(G_ISMOUSE,<onoff>)
#translate MENU SET MOUSE ROWCOL <row>,<col> ;
                            => sm_setglob(G_MROW,<row>)    ;;
                               sm_setglob(G_MCOLUMN,<col>)

#translate MENU FORCE DROP <onoff> ;
                            => sm_menfd(<onoff>)
#translate MENU BOXES [FRAME <f>] [OVER <o>] [DOWN <d>] ;
              [PADLEFT <pl>] [PADRIGHT <pr>] [CROSSBAR <cl>,<cm>,<cr>];
                            => sm_menbox(<f>,<o>,<d>,<pl>,<pr>,<cl>,<cm>,<cr>)
#translate MENU COLORS [SELECTED <sc>,<st>] [UNSELECTED <uc>,<ut>] ;
              [INACTIVE <ic>] [WINDOW <wc>] [MSG <mc>] ;
              [BOXES <boxc>] [TITLE <tc>];
                            => sm_mencol(<sc>,<st>,<uc>,<ut>,<ic>,;
                               <wc>,<mc>,<boxc>,<tc>)
#translate MENU WRAP        => sm_menwrap()

#translate DROPSTART [DOWN <d>] [OVER <o>] ;
                            => sm_mendrop(.t.,<d>,<o>)
#translate DROPEND          => sm_mendrop(.f.)
#translate BAROPTION <prompt> ID <id> [PADDING <p>] [MESSAGE <m>] [KEY <k>] ;
           [COLUMN <c>]     => sm_menbaro(<prompt>,<id>,<p>,<m>,<k>,<c>)
#translate BOXOPTION <prompt> ID <id> [MESSAGE <msg>] ;
                            => sm_menboxo(<prompt>,<id>,<msg>)
#translate CROSSBAR         => sm_menx()
#translate BOXTEXT   <text> => sm_menboxo(<text>)


#translate MENU SHOW <handle>  => sm_menuon(<handle>)
#translate MENU DO <handle>       => sm_do(<handle>)
#translate MENU HIDE <handle> [<bo:BOXES>]  ;
                                  => sm_menuoff(<handle>,!<.bo.>)
#translate MENU RESET <handle>    => sm_mreset()
#translate MENU ACTION REQUEST    => sm_request()
#translate MENU EXIT REQUEST      => sm_exreq()
#translate MENU ACTION ID         => sm_handle()
#translate MENU EXCEPTION         => sm_kex()
#translate MENU LASTKEY           => sm_lastkey()
#translate MENU MOUSE EXCEPTION   => sm_mex()
#translate MENU MOUSE LASTROW     => sm_mrow()
#translate MENU MOUSE LASTCOL     => sm_mcol()

#translate MENU TEXT SET <id>,<text> ;
                                  => sm_optset(<id>,<text>)
#translate MENU ACTIVE SET <id>,<active> ;
                                  => sm_opaset(<id>,<active>)


*===========================================================
* OPTION DEFINES
*===========================================================
#define    O_TEXT                    1
#define    O_TRIGPOS                 2
#define    O_TRIGCHAR                3
#define    O_TRIGOFFSET              4
#define    O_DROPDOWN                5
#define    O_ISACTIVE                6
#define    O_MESSAGE                 7
#define    O_HANDLE                  8
#define    O_ROW                     9
#define    O_COLUMN                 10
#define    O_RIGHTCOL               11
#define    O_ISDROP                 12
#define    O_ISTEXT                 13
#define    O_ISACTION               14
#define    O_ISCROSS                15
#define    O_HOTKEY                 16

#define    OPTION_LENGTH            16

#define    B_TOP                     1
#define    B_LEFT                    2
#define    B_BOTTOM                  3
#define    B_RIGHT                   4
#define    B_OPTIONS                 5
#define    B_FRAME                   6
#define    B_CURRENT                 7
#define    B_DEST                    8
#define    B_SAVED                   9
#define    B_WIDTH                  10
#define    B_DEPTH                  11
#define    B_OPWIDTH                12
#define    B_OPCOUNT                13
#define    B_ISON                   14

#define    BOX_LENGTH               14


*===========================================================
* GLOBAL DEFINES
*===========================================================
  * COLORS
#define    G_MSG_COLOR               2
#define    G_BOX_COLOR               3
#define    G_OPUNSEL_COLOR           4
#define    G_OPSEL_COLOR             5
#define    G_OPINACTIVE_COLOR        6
#define    G_TRIGUNSEL_COLOR         7
#define    G_TRIGSEL_COLOR           8
#define    G_TITLE_COLOR             9
#define    G_WINDOWCOLOR            10

* PARTS
#define    G_ISMOUSE                 15
#define    G_MROW                    16
#define    G_MCOLUMN                 17

#define    G_MENUBOX                 20

#define    G_ISMESSAGE               24
#define    G_MSGBOX                  25
#define    G_MSGCENTER               26
#define    G_MSGONBOT                27

#define    G_ISTITLE                 28
#define    G_TITLECENTER             29
#define    G_TITLE_TEXT              30
#define    G_TITLEBOX                31
#define    G_TITLEONTOP              32

#define    G_ISMEXIT                 34
#define    G_MEXITSAY                35
#define    G_MEXITBOX                36
#define    G_MEXITCOLOR              37

* BOXES
#define    G_BOXPADLEFT              40
#define    G_BOXPADRIGHT             41
#define    G_BOXDOWN                 42
#define    G_BOXOVER                 43
#define    G_BARPAD                  44
#define    G_CROSSLEFT               45
#define    G_CROSSMID                46
#define    G_CROSSRIGHT              47
#define    G_BOXFRAMES               48



* TRACKING
#define    G_MOUSE_RECORD            49
#define    G_MOUSE_EXCEPTION         50
#define    G_REFRESHBOX              51
#define    G_EXITBOX                 52
#define    G_DROPDOWN                53
#define    G_REFRESH                 54
#define    G_LEFTARROW               55
#define    G_RIGHTARROW              56
#define    G_LASTKEY                 57
#define    G_LASTEVENT               58
#define    G_LASTMOUSE               59
#define    G_HANDLE                  60
#define    G_ACTION_REQUEST          61
#define    G_KEY_EXCEPTION           62
#define    G_EXIT_REQUEST            63
#define    G_DROPPING                64
#define    G_FORCEDROP               66

#define    G_POINTERS                67
#define    G_DEPTH                   68

  * display blocks
#define    G_ATSAY_BLOCK             69
#define    G_ATBOX_BLOCK             70
  * mouse blocks
#define    G_MEXIST_BLOCK            71
#define    G_MRIGHT_BLOCK            72
#define    G_MLEFT_BLOCK             73
#define    G_MPOSIT_BLOCK            74
#define    G_MON_BLOCK               75
#define    G_MOFF_BLOCK              76
#define    G_MROWL_BLOCK             77
#define    G_MCOLL_BLOCK             78



#define    GLOBAL_LENGTH             78

*===========================================================
* EVENT  DEFINES
*===========================================================
#define E_KEY       450
#define E_MOUSE     451
#define E_TIMEOUT   452






