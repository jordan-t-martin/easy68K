*-----------------------------------------------------------
* Title      : LOOT Main
* Written by : Jordan Martin
* Date       : 10/16/2020
* Description: Interactive Game Assignment
*-----------------------------------------------------------
    ORG    $1000
Start: 
; Setup the screen and game components
    jsr     DrawSetup   
    jsr     GameSetup
    
; Have player press space to begin
    jsr     WaitForSpace
    jsr     SetTime    
    
; Draw the coins once at start of game to avoid slowness
    jsr     DrawCoinsSetup
   
GameLoop:
    jsr     PlayerLoop
    jsr     FireballLoop       
    bra     GameLoop
Quit:
    jmp     SimHalt

PlayerFile      INCLUDE   "Player.x68"
FireballFile    INCLUDE   "Fireball.x68"
CoinFile        INCLUDE   "Coin.x68"
DrawFile        INCLUDE   "Draw.x68"
CollisionFile   INCLUDE   "Collision.x68"
BitmapFile      INCLUDE   "Bitmap.x68"
TrapCodesFile   INCLUDE   "TrapCodes.x68"
RandomNumFile   INCLUDE   "RandomNumbers.x68"
ScoreFile       INCLUDE   "Score.x68"

SimHalt         SIMHALT

FRAC_BITS       EQU     8
START_FLAG      DC.L    0
  
    END    Start




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
