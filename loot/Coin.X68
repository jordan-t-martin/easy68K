*-----------------------------------------------------------
* Title      : LOOT Game
* Written by : Jordan Martin
* Date       : 10/16/2020
* Description: Functions to handle game setup and coin functionality
*-----------------------------------------------------------
; Sets up coin locations and score for the game
GameSetup:
    jsr     SetupCoins
    jsr     ScoreUpdate    

; Setup coin locations using random number generator
SetupCoins:
; Number of coins used as counter for loop
    move.l  #NUM_COINS,d7
; Set the bounds for the random numbers
    move.l  #COIN_BOUND<<1,d1
    move.l  #OUTPUT_WIDTH,d3 
    sub.l   d1,d3
    add.l   #1,d3
    move.l  #OUTPUT_HEIGHT,d4
    sub.l   d1,d4
    add.l   #1,d4    
    lea     CoinsTable,a0
    jsr     seedRandomNumber    
SetupCoinsLoop:
; Get a random word
    clr.l   d6    
    jsr     getRandomWordIntoD6
; Divide by the bounds
    divu    d3,d6
; Get the remainder
    swap    d6
; Add min value
    add.w   #COIN_BOUND,d6
; Save random position in table
    move.w  d6,(a0)+

; Do same for y value
    clr.l   d6     
    jsr     getRandomWordIntoD6   
    divu    d4,d6   
    swap    d6 
    add.w   #COIN_BOUND,d6   
    move.w  d6,(a0)+

; Decrement counter   
    sub.l   #1,d7
    beq     SetupCoinsReturn
    bra     SetupCoinsLoop
SetupCoinsReturn:
    rts

; Creates a new random location for coin and draws it there 
; Uses same behavior as function before this to get random location
; Assumes address of coin to replace is given
ReloadCoin:
; Get the address of coin to replace
    add.l   #4,sp
    lea     SINGLE_COIN_ADDRESS,a5
    move.l  (sp)+,(a5)
    move.l  (a5),a6
    sub.l   #RELOAD_COIN_ARGS,sp
    sub.l   #4,sp

; Draw background over where coin currently is    
    lea     SINGLE_COIN_ADDRESS,a5
    move.l  (a5),-(sp)
    jsr     RedrawBGCoin
    add.l   #REDRAW_BG_COIN_ARGS,sp 
    jsr     DrawPlayer

; Get the random location       
    move.l  #COIN_BOUND<<1,d1
    move.l  #OUTPUT_WIDTH,d3 
    sub.l   d1,d3
    add.l   #1,d3
    move.l  #OUTPUT_HEIGHT,d4
    sub.l   d1,d4
    add.l   #1,d4  
    
    clr.l   d6    
    jsr     getRandomWordIntoD6
    divu    d3,d6
    swap    d6
    add.w   #COIN_BOUND,d6
    move.w  d6,(a6)+

    clr.l   d6     
    jsr     getRandomWordIntoD6    
    divu    d4,d6
    swap    d6
    add.w   #COIN_BOUND ,d6    
    move.w  d6,(a6)+

; Draw the coin at the new random location    
    lea     SINGLE_COIN_ADDRESS,a5
    move.l  (a5),-(sp)
    jsr     DrawSingleCoin
    add.l   #DRAW_SINGLE_COIN_ARGS,sp    
    rts       

NUM_COINS               EQU     5
NUM_COINS_COUNTER       DC.L    0
SINGLE_COIN_ADDRESS     DC.L    0
COIN_BOUND              EQU     100

COIN_XPIXEL             EQU     0
COIN_YPIXEL             EQU     0
COIN_WIDTH              EQU     16
COIN_HEIGHT             EQU     16
COINDRAW_X              EQU     300
COINDRAW_Y              EQU     300

CoinsTable:
Coin1X: DC.W 0
Coin1Y: DC.W 0
Coin2X: DC.W 0
Coin2Y: DC.W 0
Coin3X: DC.W 0
Coin3Y: DC.W 0
Coin4X: DC.W 0
Coin4Y: DC.W 0
Coin5X: DC.W 0
Coin5Y: DC.W 0
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
