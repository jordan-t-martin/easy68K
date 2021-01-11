; Trap codes
TIME_CODE                   EQU     8  
DRAW_ELLIPSE_CODE           EQU     88
PEN_COLOR_CODE              EQU     80
FILL_COLOR_CODE             EQU     81
DRAW_LINE_CODE              EQU     84
PEN_THICKNESS_CODE          EQU     93
ENABLE_DOUBLE_BUFFER_CODE   EQU     17
DRAWING_MODE_CODE           EQU     92
DOUBLE_BUFFER_CODE          EQU     94   
RECTANGLE_CODE              EQU     87
DRAW_TEXT_CODE              EQU     95

; Other useful equates
CR      EQU     $0D             ; ASCII code for Crriage Return
LF      EQU     $0A             ; ASCII code for Crriage Return
LONG_WORD       EQU     4

; Arguments offset for subroutines
DRAW_BMP_ARGS               EQU     28
REDRAW_BG_FIREBALL_ARGS     EQU     4
DRAW_PLAYER_ARGS            EQU     16
DRAW_SCORE_ARGS             EQU     6
RELOAD_COIN_ARGS            EQU     4
REDRAW_BG_COIN_ARGS         EQU     4
COLLISION_ARGS              EQU     36
CHECKFBCOIN_COLLISION_ARGS  EQU     4
DRAW_SINGLE_COIN_ARGS       EQU     4
DRAW_SCORE_ARGS             EQU     6

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
