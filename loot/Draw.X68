*-----------------------------------------------------------
* Title      : LOOT Draw
* Written by : Jordan Martin
* Date       : 10/2/2020
* Description: Functions to handle the drawing to the screen
*-----------------------------------------------------------
; Sets up screen size, enables double buffer, draws loading screen and background
DrawSetup:
    move.w  #OUTPUT_WIDTH,d1
    swap.w  d1
    move.w  #OUTPUT_HEIGHT,d1 
    move.b  #SET_OUTPUT_RES_TRAP_CODE,D0 ; Sets window size
    TRAP    #15
 
    move.b  #ENABLE_DOUBLE_BUFFER_CODE,d1
    move.l  #DRAWING_MODE_CODE,d0
    TRAP    #15
    
    jsr     DrawLoadingScreen  
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15
    jsr     DrawBG  
DrawSetupReturn    
    rts

; Draws the background to the screen using bitmap function    
DrawBG: 
    lea     BG_BMP,a0
    move.l  a0,-(sp)
    lea     ROOM_XPIXEL,a0
    move.l  (a0),-(sp)
    lea     ROOM_YPIXEL,a0
    move.l  (a0),-(sp)
    move.l  #ROOM_WIDTH,-(sp)
    move.l  #ROOM_HEIGHT,-(sp)
    move.l  #ROOMDRAW_X,-(sp)
    move.l  #ROOMDRAW_Y,-(sp)
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp  
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15    
    rts
    
; Draws all elements of the loading screen
DrawLoadingScreen:
; Draw logo using bitmap function
    lea     LOADING_BMP,a0
    move.l  a0,-(sp)
    lea     LOAD_XPIXEL,a0
    move.l  (a0),-(sp)
    lea     LOAD_YPIXEL,a0
    move.l  (a0),-(sp)
    move.l  #LOAD_WIDTH,-(sp)
    move.l  #LOAD_HEIGHT,-(sp)
    move.l  #LOADDRAW_X,-(sp)
    move.l  #LOADDRAW_Y,-(sp)
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp

; Draw all text for the loading screen
    move.l  #BLACK_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15 
    
    lea     LOADING_TEXT,a1
    move.l  #LOADING_TEXT_X,d1
    move.l  #LOADING_TEXT_Y,d2    
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15
    
    lea     COIN_TEXT,a1
    move.l  #COIN_TEXT_X,d1
    move.l  #COIN_TEXT_Y,d2    
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15
    
    lea     FIREBALL_TEXT,a1
    move.l  #FIREBALL_TEXT_X,d1
    move.l  #FIREBALL_TEXT_Y,d2    
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15       

; Draw images to accompany instructions
; Use bitmap function for coin
    lea     COIN_BMP,a0
    move.l  a0,-(sp)   
    move.l  #COIN_XPIXEL,-(sp)
    move.l  #COIN_YPIXEL,-(sp)
    move.l  #COIN_WIDTH,-(sp)      
    move.l  #COIN_HEIGHT,-(sp)     
    move.l  #COIN_TEXT_X+75,-(sp)      
    move.l  #COIN_TEXT_Y,-(sp)     
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    
    move.l  #RED_PEN_COLOR,d1
    move.l  #PEN_COLOR_CODE,d0
    TRAP    #15
    move.l  #RED_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15    
    
    move.l  #FIREBALL_TEXT_X+80,d1
    move.l  #FIREBALL_TEXT_Y+6,d2
    move.l  d1,d3
    add.l   #FIREBALL_WIDTH-1,d3
    move.l  d2,d4
    add.l   #FIREBALL_HEIGHT-1,d4   
    
    move.l  #DRAW_ELLIPSE_CODE,d0
    TRAP    #15
    rts

; Draws all elements of the death screen    
DrawDeathScreen:
; Paint the screen black
    move.l  #BLACK_PEN_COLOR,d1
    move.l  #PEN_COLOR_CODE,d0
    TRAP    #15
    move.l  #BLACK_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15 
    
    clr.l   d1
    clr.l   d2
    move.l  #OUTPUT_WIDTH,d3
    move.l  #OUTPUT_HEIGHT,d4

    move.l  #RECTANGLE_CODE,d0
    TRAP    #15

; Draw skull image using bitmap function
    lea     DEATH_BMP,a0
    move.l  a0,-(sp)
    move.l  #DEATH_XPIXEL,-(sp)
    move.l  #DEATH_YPIXEL,-(sp)  
    move.l  #DEATH_WIDTH,-(sp)
    move.l  #DEATH_HEIGHT,-(sp)
    move.l  #DEATHDRAW_X,-(sp) 
    move.l  #DEATHDRAW_Y,-(sp)  
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp

; Draw death text    
    lea     DEATH_TEXT,a1
    move.l  #DEATH_TEXT_X,d1
    move.l  #DEATH_TEXT_Y,d2    
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15
      
    rts

; Draws the player at his current position/animation          
DrawPlayer:
    lea     KNIGHT_BMP,a0
    move.l  a0,-(sp)
    lea     PLAYER_X_PIXEL,a0
    move.l  (a0),-(sp)
    lea     PLAYER_Y_PIXEL,a0
    move.l  (a0),-(sp)
    move.l  #PLAYER_WIDTH,-(sp)
    move.l  #PLAYER_HEIGHT,-(sp)
    lea     PLAYER_DRAW_X,a0
    move.l  (a0),-(sp)
    lea     PLAYER_DRAW_Y,a0
    move.l  (a0),-(sp)
    jsr     DrawBitmap   
    add.l   #DRAW_BMP_ARGS,sp  
    rts

; Loops through all the fireballs and draws using primitive graphics
DrawFireballsSetup:
    lea     NUM_FIREBALLS_COUNTER,a2
    move.l  #NUM_FIREBALLS,(a2)  
DrawFireballs:
    lea     FireballsTable,a1
    move.l  #5,d0
    sub.l   (a2),d0
    lsl.l   #3,d0
    add.l   d0,a1
     
    
    move.l  #RED_PEN_COLOR,d1
    move.l  #PEN_COLOR_CODE,d0
    TRAP    #15
    move.l  #RED_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15    
    
    move.l  (a1)+,d1
    move.l  (a1),d2
    move.l  d1,d3
    add.l   #FIREBALL_WIDTH-1,d3
    move.l  d2,d4
    add.l   #FIREBALL_HEIGHT-1,d4   
    
    move.l  #DRAW_ELLIPSE_CODE,d0
    TRAP    #15
      
    lea     NUM_FIREBALLS_COUNTER,a2
    sub.l   #1,(a2)
    beq     DrawFireballsReturn
    bra     DrawFireballs
DrawFireballsReturn:   
    rts

; Loops through all the coins and draws using bitmap function
DrawCoinsSetup:
    lea     NUM_COINS_COUNTER,a2
    move.l  #NUM_COINS,(a2)  
DrawCoins:
    lea     CoinsTable,a1
    move.l  #5,d0
    sub.l   (a2),d0
    lsl.l   #2,d0
    add.l   d0,a1  

    lea     COIN_BMP,a0
    move.l  a0,-(sp)
    move.l  #COIN_XPIXEL,-(sp)
    move.l  #COIN_YPIXEL,-(sp)  
    move.l  #COIN_WIDTH,-(sp)
    move.l  #COIN_HEIGHT,-(sp)
    
    move.w  (a1)+,d0
    ext.l   d0
    move.l  d0,-(sp)  
    
    move.w  (a1),d0
    ext.l   d0
    move.l  d0,-(sp)   
    
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp    
    
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15      
    lea     NUM_COINS_COUNTER,a2
    sub.l   #1,(a2)
    beq     DrawCoinsReturn
    bra     DrawCoins
DrawCoinsReturn:   
    rts

; Redraws the background for the player  
RedrawBGPlayer:
    lea     BG_BMP,a0
    move.l  a0,-(sp)
    lea     PLAYER_DRAW_X,a0
    move.l  (a0),-(sp)    
    lea     PLAYER_DRAW_Y,a0
    move.l  (a0),-(sp)
    move.l  #PLAYER_WIDTH,-(sp)
    move.l  #PLAYER_HEIGHT,-(sp)
    lea     PLAYER_DRAW_X,a0
    move.l  (a0),-(sp)
    lea     PLAYER_DRAW_Y,a0
    move.l  (a0),-(sp)
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    rts
    
; Redraws the background for the score 
RedrawBGScore:
    lea     BG_BMP,a0
    move.l  a0,-(sp)
    move.l  #SCOREDRAW_X+30,d0 ; Adjust for width of score 
    sub.l   #SCORE_WIDTH,d0  
    move.l  d0,-(sp)
    move.l  #SCOREDRAW_Y-3,d1  ; Adjust for pen thickness
    move.l  d1,-(sp)  
    move.l  #SCORE_WIDTH,-(sp)
    move.l  #SCORE_HEIGHT,-(sp)
    move.l  d0,-(sp)  
    move.l  d1,-(sp)  
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    rts   

; Redraws the background for the start text
RedrawBGStartText: 
    lea     BG_BMP,a0
    move.l  a0,-(sp)
    move.l  #START_TEXT_X,-(sp)
    move.l  #START_TEXT_Y,-(sp)  
    move.l  #START_TEXT_WIDTH,-(sp)
    move.l  #START_TEXT_HEIGHT,-(sp)
    move.l  #START_TEXT_X,-(sp)  
    move.l  #START_TEXT_Y,-(sp)  
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    rts 
    
; Redraws the background for a fireball 
; Assumes address of fireball position is passed in  
RedrawBGFireball:
    add.l   #LONG_WORD,sp
    move.l  (sp),a1
    move.l  (sp),a2
    sub.l   #LONG_WORD,sp

    lea     BG_BMP,a0
    move.l  a0,-(sp)
    move.l  (a1)+,-(sp)
    move.l  (a1)+,-(sp)  
    move.l  #FIREBALL_WIDTH,-(sp)
    move.l  #FIREBALL_HEIGHT,-(sp)
    move.l  (a2)+,-(sp)  
    move.l  (a2)+,-(sp)  
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    rts 

; Redraws the background for a coin
; Assumes address of coin position is passed in
RedrawBGCoin:
    add.l   #LONG_WORD,sp
    move.l  (sp),a1
    move.l  (sp),a2
    sub.l   #LONG_WORD,sp

    lea     BG_BMP,a0
    move.l  a0,-(sp)
    move.w  (a1)+,d0
    ext.l   d0
    move.l  d0,-(sp) 
    move.w  (a1)+,d0
    ext.l   d0
    move.l  d0,-(sp)   
    move.l  #COIN_WIDTH,-(sp)
    move.l  #COIN_HEIGHT,-(sp)
    move.w  (a2)+,d0
    ext.l   d0
    move.l  d0,-(sp)  
    move.w  (a2)+,d0
    ext.l   d0
    move.l  d0,-(sp) 
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    rts   

; Draws a single coin using bitmap function
; Assumes address of coin position is passed in 
DrawSingleCoin:
    add.l   #LONG_WORD,sp
    move.l  (sp),a6
    sub.l   #LONG_WORD,sp

    lea     COIN_BMP,a0
    move.l  a0,-(sp)    
    move.l  #COIN_XPIXEL,-(sp) 
    move.l  #COIN_YPIXEL,-(sp)   
    move.l  #COIN_WIDTH,-(sp)
    move.l  #COIN_HEIGHT,-(sp)
    move.w  (a6)+,d0
    ext.l   d0
    move.l  d0,-(sp)  
    move.w  (a6)+,d0
    ext.l   d0
    move.l  d0,-(sp) 
    jsr     DrawBitmap
    add.l   #DRAW_BMP_ARGS,sp
    rts        

BG_BMP          INCBIN      "img\room.bmp"
LOADING_BMP     INCBIN      "img\loading.bmp"
KNIGHT_BMP      INCBIN      "img\knight.bmp"
DEATH_BMP       INCBIN      "img\death.bmp"
COIN_BMP        INCBIN      "img\coin.bmp"
FIREBALL_BMP    INCBIN      "img\fireball.bmp"

PURPLE_PEN_COLOR    EQU     $00654F5B
BLACK_PEN_COLOR     EQU     $00000000
YELLOW_PEN_COLOR    EQU     $000ADAFA
RED_PEN_COLOR       EQU     $000000FF
ORANGE_PEN_COLOR    EQU     $004174C9
LINE_THICKNESS      EQU     3

LOAD_XPIXEL     DC.L    0
LOAD_YPIXEL     DC.L    0
LOAD_WIDTH      EQU     149
LOAD_HEIGHT     EQU     39
LOADDRAW_X      EQU     245
LOADDRAW_Y      EQU     200

DEATH_XPIXEL     EQU    0
DEATH_YPIXEL     EQU    0
DEATH_WIDTH      EQU    32
DEATH_HEIGHT     EQU    32
DEATHDRAW_X      EQU    304
DEATHDRAW_Y      EQU    175

ROOM_XPIXEL     DC.L    0
ROOM_YPIXEL     DC.L    0
ROOM_WIDTH      EQU     640
ROOM_HEIGHT     EQU     480
ROOMDRAW_X      EQU     0
ROOMDRAW_Y      EQU     0
WALL_BOUND      EQU     20

OUTPUT_WIDTH    EQU     640
OUTPUT_HEIGHT   EQU     480

DEATH_TEXT      DC.L    'YOU BURNT TO A CRISP.',CR,LF,0
DEATH_TEXT_X    EQU    240
DEATH_TEXT_Y    EQU    230

CONTINUE_TEXT   DC.L    'PRESS SPACE TO CONTINUE',CR,LF,0
CONTINUE_TEXT_X EQU    230
CONTINUE_TEXT_Y EQU    310

START_TEXT          DC.L    'PRESS SPACE TO START',CR,LF,0
START_TEXT_X        EQU    240
START_TEXT_Y        EQU    230
START_TEXT_WIDTH    EQU     200
START_TEXT_HEIGHT   EQU     50

LOADING_TEXT    DC.L    'LOADING...',CR,LF,0
LOADING_TEXT_X  EQU    280
LOADING_TEXT_Y  EQU    250

COIN_TEXT       DC.L    'COLLECT:',CR,LF,0
COIN_TEXT_X     EQU    275
COIN_TEXT_Y     EQU    320

FIREBALL_TEXT   DC.L    'RUN FROM:',CR,LF,0
FIREBALL_TEXT_X EQU    275
FIREBALL_TEXT_Y EQU    340



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
