*-----------------------------------------------------------
* Title      : LOOT Player
* Written by : Jordan Martin
* Date       : 10/16/2020
* Description: Functions to handle the player's movement and collisions
*-----------------------------------------------------------

; All update functions for the player
PlayerLoop:
    jsr     RedrawBGPlayer   
    jsr     PlayerMove
    jsr     CheckCollisionCoin
    jsr     CheckCollisionFB
; Setup arguments for drawing player   
    lea     PLAYER_X_PIXEL,a0
    move.l  (a0),-(sp)
    lea     PLAYER_Y_PIXEL,a0
    move.l  (a0),-(sp)
    lea     PLAYER_DRAW_X,a0
    move.l  (a0),-(sp)
    lea     PLAYER_DRAW_Y,a0
    move.l  (a0),-(sp)
    jsr     DrawPlayer 
    add.l   #DRAW_PLAYER_ARGS,sp
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15      
    rts
    
; Checks input from player and adjust position/animation
PlayerMove:
; Check input from WASD
    move.l  #'A'<<24+'W'<<16+'D'<<8+'S',d1
    move.b  #GET_USER_INPUT_CODE,d0
    TRAP    #15
PlayerLeft:
; Check if A key was pressed
    btst.l  #24,d1
    beq     PlayerUp
; Check if player will move out of bounds
    lea     PLAYER_DRAW_X,a0 
    cmp.l   #WALL_BOUND,(a0)
    ble     PlayerUp
; Move player
    sub.l   #PLAYER_SPEED,(a0)
; Change animation    
    lea     PLAYER_X_PIXEL,a0
    move.l  #PLAYER_LEFT_X_PIXEL,(a0)
    lea     PLAYER_Y_PIXEL,a0
    move.l  #PLAYER_LEFT_Y_PIXEL,(a0)       
PlayerUp:
; Check if W key was pressed
    btst.l  #16,d1
    beq     PlayerRight  
; Check if player will move out of bounds    
    lea     PLAYER_DRAW_Y, a0
    cmp.l   #WALL_BOUND,(a0)
    ble     PlayerRight
; Move player    
    sub.l   #PLAYER_SPEED,(a0)
PlayerRight:
; Check if D key is pressed
    btst.l  #8,d1
    beq     PlayerDown 
; Check if player will move out of bounds      
    lea     PLAYER_DRAW_X, a0
    cmp.l   #OUTPUT_WIDTH-WALL_BOUND-PLAYER_WIDTH,(a0)
    bge     PlayerDown
; Move player
    add.l   #PLAYER_SPEED,(a0)  
; Change animation  
    lea     PLAYER_X_PIXEL,a0
    move.l  #PLAYER_RIGHT_X_PIXEL,(a0)
    lea     PLAYER_Y_PIXEL,a0
    move.l  #PLAYER_RIGHT_Y_PIXEL,(a0)     
PlayerDown:
; Check if S key is pressed
    btst.l  #0,d1
    beq     NoInput
; Check if player will move out of bounds      
    lea     PLAYER_DRAW_Y,a0
    cmp.l   #OUTPUT_HEIGHT-WALL_BOUND-PLAYER_HEIGHT-2,(a0)
    bge     NoInput
; Move player      
    add.l   #PLAYER_SPEED,(a0)    
NoInput    
    rts

; Check if the player collides with any of the coins
CheckCollisionCoin:
; Start counter for loop and load coin table
    lea     NUM_COINS_COUNTER,a2
    move.l  #NUM_COINS,(a2)
    lea     CoinsTable,a1    
CheckCollisionCoinLoop:
; Save off coin for later use    
    move.l  a1,a3
; Load up variables to use collision function
    move.l  #COIN_HEIGHT,-(sp)
    move.l  #COIN_WIDTH,-(sp)
    move.w  (a1)+,d0 ; Coin X    
    ext.l   d0
    move.l  d0,-(sp)
    move.w  (a1)+,d0 ; Coin Y
    ext.l   d0
    move.l  d0,-(sp) 
    move.l  #PLAYER_HEIGHT,-(sp)
    move.l  #PLAYER_WIDTH,-(sp)
    lea     PLAYER_DRAW_Y,a0
    move.l  (a0),-(sp)    
    lea     PLAYER_DRAW_X,a0
    move.l  (a0),-(sp)
    lea     COLLISION_BOOL,a0
    move.l  (a0),-(sp)
    jsr     Collision
; Save the boolean from collision function
    lea     COLLISION_BOOL,a0
    move.l  (sp),(a0)
    add.l   #COLLISION_ARGS,sp
; Check boolean and call found function if true   
    cmp.l   #0,(a0)     
    beq     NoCollisionCoin  
    jsr     CollisionCoinFound
; If collision is found at current coin, it is not
; possible to have a collision at another coin. Return.
    bra     CheckCollisionCoinReturn
NoCollisionCoin:
; Reduce counter, loop again    
    sub.l   #1,(a2)
    beq     CheckCollisionCoinReturn
    bra     CheckCollisionCoinLoop
CheckCollisionCoinReturn:
    rts    

; Called if collision found between player and coin
CollisionCoinFound:
; Call function on coin to "respawn"
    move.l  a3,-(sp)
    jsr     ReloadCoin
    add.l   #RELOAD_COIN_ARGS,sp  
; Add 1 point to the score and redraw 
    lea     SCORE,a0
    add.w   #1,(a0)
    jsr     ScoreUpdate
    rts

; Check if the player collides with any of the fireballs
CheckCollisionFB:
; Start counter for loop and load fireball table
    lea     NUM_FIREBALLS_COUNTER,a2
    move.l  #NUM_FIREBALLS,(a2)
    lea     FireballsTable,a1    
CheckCollisionFBLoop:
; Load up variables for use in collision function
    move.l  #FIREBALL_HEIGHT,-(sp)
    move.l  #FIREBALL_WIDTH,-(sp)
    move.l  (a1)+,-(sp) ; Fireball X
    move.l  (a1)+,-(sp) ; Fireball Y
    move.l  #PLAYER_HEIGHT,-(sp)
    move.l  #PLAYER_WIDTH,-(sp)
    lea     PLAYER_DRAW_Y,a0
    move.l  (a0),-(sp)    
    lea     PLAYER_DRAW_X,a0
    move.l  (a0),-(sp)
    lea     COLLISION_BOOL,a0
    move.l  (a0),-(sp)
    jsr     Collision
; Save the boolean from collision function    
    lea     COLLISION_BOOL,a0
    move.l  (sp),(a0)
    add.l   #COLLISION_ARGS,sp
; Check boolean and call found function if true    
    cmp.l   #0,(a0)     
    beq     NoCollisionFB  
    jsr     CollisionFoundFB
; If collision is found at current fireball, it is not
; possible to have a collision at another fireball. Return.    
    bra     CheckCollisionFBReturn
NoCollisionFB:  
; Reduce counter, loop again    
    sub.l   #1,(a2)
    beq     CheckCollisionFBReturn
    bra     CheckCollisionFBLoop
CheckCollisionFBReturn:
    rts    

; Called if collision is found between player and fireball
; The game is over if this collision is found
CollisionFoundFB:
; Change animation
    jsr     PlayerDeathAnim
; Change flag to indicate we are restarting
    lea     START_FLAG,a0
    move.l  #1,(a0)
; Draw the death screen and final score
    jsr     DrawDeathScreen
    jsr     DeathScoreUpdate
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15
; Wait for player to continue
    jsr     WaitForSpace
; Reset position and speed of fireballs    
    jsr     ResetFireballsSetup
; Reset position of player
    lea     PLAYER_DRAW_X,a0
    move.l  #START_POS,(a0)
    lea     PLAYER_DRAW_Y,a0
    move.l  #START_POS,(a0)
; Reset score value
    lea     SCORE,a0
    move.w  #0,(a0)
; Restart the game     
    jsr     Start
    rts

; Pauses game until player presses space
WaitForSpace:
; Check if state is Start or Restart
    lea     START_FLAG,a0
    cmp.l   #0,(a0)
    bne     WFSRestart
WFSStart:
; Draw start message
    move.l  #PURPLE_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15 
    lea     START_TEXT,a1
    move.l  #START_TEXT_X,d1
    move.l  #START_TEXT_Y,d2    
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15
    bra     WFSInput
WFSRestart:
; Draw restart message
    move.l  #BLACK_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15 
    lea     CONTINUE_TEXT,a1
    move.l  #CONTINUE_TEXT_X,d1
    move.l  #CONTINUE_TEXT_Y,d2    
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15
WFSInput
; Show text
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15
; Check input for space
    clr.l   d1
    move.l  #' '<<24,d1
    move.b  #GET_USER_INPUT_CODE,d0
    TRAP    #15
    btst.l  #24,d1
; If not found, loop again
    beq     WFSInput
; If start text was drawn, redraw BG before starting game
    cmp.l   #0,(a0) 
    bne     WFSReturn 
    jsr     RedrawBGStartText
WFSReturn:
; Reset start flag
    lea     START_FLAG,a0
    move.l  #0,(a0)    
    rts

; Changes animation of player when dying
PlayerDeathAnim
; Change position on bitmap
    lea     PLAYER_X_PIXEL,a0
    move.l  #PLAYER_DEATH_X_PIXEL,(a0)
    lea     PLAYER_Y_PIXEL,a0
    move.l  #PLAYER_DEATH_Y_PIXEL,(a0)
; Redraw player    
    jsr     RedrawBGPlayer
    lea     PLAYER_X_PIXEL, a0
    move.l  (a0),-(sp)
    lea     PLAYER_Y_PIXEL, a0
    move.l  (a0),-(sp)
    lea     PLAYER_DRAW_X, a0
    move.l  (a0),-(sp)
    lea     PLAYER_DRAW_Y, a0
    move.l  (a0),-(sp)        
    jsr     DrawPlayer
    add.l   #DRAW_PLAYER_ARGS,sp
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15
; Wait 2 seconds so user can see new animation
; Get original time
    move.l  #TIME_CODE,d0
    TRAP    #15
    move.l  d1,d2
HoldDeathAnim:
; Get new time and check if 2 seconds went by, otherwise loop
    move.l  #TIME_CODE,d0
    TRAP    #15
    sub.l   d2,d1
    cmp.l   #200,d1
    bne     HoldDeathAnim
; Set the animation back to normal for next game
    lea     PLAYER_X_PIXEL,a0
    move.l  #PLAYER_RIGHT_X_PIXEL,(a0)
    lea     PLAYER_Y_PIXEL,a0
    move.l  #PLAYER_RIGHT_Y_PIXEL,(a0)    
    rts

; Game vars    
COLLISION_BOOL          DC.L    0
START_POS               EQU     20
PLAYER_SPEED            EQU     3

; Input vars
KEY_LEFT_INPUT          EQU     25
KEY_UP_INPUT            EQU     26
KEY_RIGHT_INPUT         EQU     27
KEY_DOWN_INPUT          EQU     28
GET_USER_INPUT_CODE     EQU     19

; Animation vars 
PLAYER_LEFT_X_PIXEL     EQU     16  
PLAYER_LEFT_Y_PIXEL     EQU     0
PLAYER_DEATH_X_PIXEL    EQU     32  
PLAYER_DEATH_Y_PIXEL    EQU     0
PLAYER_RIGHT_X_PIXEL    EQU     0  
PLAYER_RIGHT_Y_PIXEL    EQU     0

; Draw vars
PLAYER_X_PIXEL          DC.L    0
PLAYER_Y_PIXEL          DC.L    0
PLAYER_WIDTH            EQU     15
PLAYER_HEIGHT           EQU     19
PLAYER_DRAW_X           DC.L    20
PLAYER_DRAW_Y           DC.L    20
































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
