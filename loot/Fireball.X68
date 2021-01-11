*-----------------------------------------------------------
* Title      : LOOT Fireballs
* Written by : Jordan Martin
* Date       : 10/16/2020
* Description: Functions to handle fireball's movement and collisions
*-----------------------------------------------------------

; All update functions for each fireball
FireballLoop:    
    jsr     DeltaTime
    jsr     RedrawBGFireballsSetup
    jsr     MoveFireballsSetup      
    jsr     DrawFireballsSetup
    move.l  #DOUBLE_BUFFER_CODE,d0
    TRAP    #15    
    rts

; Moves each fireball according to their speed.
; Adds gravity to each fireball.
; Checks collisions with any coins on the map
MoveFireballsSetup:
; Start counter for loop
    lea     NUM_FIREBALLS_COUNTER,a2
    move.l  #NUM_FIREBALLS,(a2)  
    
MoveFireballs:
; Note for table values:
; Registers will get trashed with future subroutines
; Find offset and multiply by 8
; 2 for (x,y) pair and 4 for long word size
; Add offest to table start

; Load the speed of the current fireball
    lea     FireballSpeedTable,a1
    move.l  #5,d0
    sub.l   (a2),d0
    lsl.l   #3,d0
    add.l   d0,a1

; Save off addresses for current Fireball X/Y Speed
    move.l  a1,a3
    add.l   #LONG_WORD,a1
    move.l  a1,a4 

; Load the position of the current fireball
    lea     FireballsTable,a1
    move.l  #5,d0
    sub.l   (a2),d0
    lsl.l   #3,d0
    add.l   d0,a1   

; Add floating point gravity to the Y speed of fireball
    lea     GRAVITY_FP,a6
    move.l  (a6),d0
    lea     DELTA_TIME,a6
    move.l  (a6),d1
    muls    d1,d0
    add.l   d0,(a4)    

; Add the Fireball X speed to Fireball X position
; Note for speed and position addition:
; Speed is in fixed point, position is not
; Do addition in fixed point and move back before storing position    
    lea     DELTA_TIME,a6    
    move.l  (a3),d0
    move.l  (a1),d1        
    move.l  (a6),d2
    ble     DeltaTimeInBoundsX
    move.l  #3,d2
DeltaTimeInBoundsX:    
    muls    d2,d0    
    lsl.l   #FRAC_BITS,d1
    add.l   d0,d1
    lsr.l   #FRAC_BITS,d1    
    move.l  d1,(a1)

; Check if fireball is bouncing into any of the walls
CheckLeftBounce:
; Compare the fireball X position with left wall
    move.l  (a1),d0
    move.l  #WALL_BOUND,d1
    cmp.l   d1,d0
    bge     CheckRightBounce
; Bounce found on left wall
; Sanity check that X speed is negative
    move.l  (a3),d0
    cmp.l   #0,d0
    bge     CheckRightBounce   
; Change X speed to positive
    muls    #-1,d0
    move.l  d0,(a3)
; In case fireball moved past wall before this check
; Reset its position to outside the wall
    move.l  #WALL_BOUND,(a1)

CheckRightBounce:
; Compare the fireball X position with right wall
    move.l  (a1),d0
    move.l  #ROOM_WIDTH-WALL_BOUND-FIREBALL_WIDTH,d1
    cmp.l   d1,d0
    ble     NoXBounce
; Bounce found on right wall
; Sanity check that X speed is positive    
    move.l  (a3),d0
    cmp.l   #0,d0
    ble     NoXBounce
; Change X speed to negative  
    muls    #-1,d0
    move.l  d0,(a3)
; In case fireball moved past wall before this check
; Reset its position to outside the wall    
    move.l  #ROOM_WIDTH-WALL_BOUND-FIREBALL_WIDTH,(a1)

NoXBounce:
; Move onto Y   
    add.l   #LONG_WORD,a1
  
; Add the Fireball Y speed to Fireball Y position
; Note for speed and position addition:
; Speed is in fixed point, position is not
; Do addition in fixed point and move back before storing position    
    lea     DELTA_TIME,a6      
    move.l  (a4),d0
    move.l  (a1),d1
    move.l  (a6),d2
    cmp.l   #3,d2
    ble     DeltaTimeInBoundsY
    move.l  #3,d2
DeltaTimeInBoundsY:    
    muls    d2,d0
    lsl.l   #FRAC_BITS,d1
    add.l   d0,d1
    lsr.l   #FRAC_BITS,d1
    move.l   d1,(a1) 
    
CheckTopBounce:
; Compare the fireball Y position with top wall
    move.l  (a1),d0
    move.l  #WALL_BOUND,d1
    cmp.l   d1,d0
    bge     CheckBottomBounce
; Bounce found on top wall
; Sanity check that Y speed is negative     
    move.l  (a4),d0
    cmp.l   #0,d0
    bge     CheckBottomBounce   
; Change Y speed to positive   
    muls    #-1,d0
    move.l  d0,(a4)
; In case fireball moved past wall before this check
; Reset its position to outside the wall    
    move.l  #WALL_BOUND,(a1)

CheckBottomBounce:
; Compare the fireball Y position with bottom wall
    move.l  (a1),d0
    move.l  #ROOM_HEIGHT-WALL_BOUND-FIREBALL_HEIGHT,d1
    cmp.l   d1,d0
    ble     NoYBounce
; Bounce found on bottom wall
; Sanity check that Y speed is positive      
    move.l  (a4),d0
    cmp.l   #0,d0
    ble     NoYBounce  
; Change Y speed to negative  
    muls    #-1,d0
    move.l  d0,(a4)
; In case fireball moved past wall before this check
; Reset its position to outside the wall      
    move.l  #ROOM_HEIGHT-WALL_BOUND-FIREBALL_HEIGHT,(a1)  
    
NoYBounce:
      
; Move onto checking collisions with coin for current fireball
; Load up current fireball position
    lea     FireballsTable,a1
    move.l  #5,d0
    sub.l   (a2),d0
    lsl.l   #3,d0
    add.l   d0,a1
; Pass this into the function to check collision with coins 
    move.l  a1,-(sp)
    jsr     CheckFBCoinCollision
    add.l   #CHECKFBCOIN_COLLISION_ARGS,sp
; Reduce counter 
    lea     NUM_FIREBALLS_COUNTER,a2
    sub.l   #1,(a2)
    beq     MoveFireballsReturn
    bra     MoveFireballs
MoveFireballsReturn:   
    rts

; Given a single fireball position, check if it collides with
; any of the other coins on the map.
CheckFBCoinCollision:
; Put the fireball position in a4
    add.l   #LONG_WORD,sp
    move.l  (sp),a4
    sub.l   #LONG_WORD,sp
; Start counter for loop and load coin table    
    lea     NUM_COINS_COUNTER,a2
    move.l  #NUM_COINS,(a2) 
    lea     CoinsTable,a1  
CheckFBCoinCollisionLoop:  
    move.l  a1,a3 ; Save off Coin position for check later
    move.l  a4,a5 ; Copy Fireball position into new address to avoid being trashed
    
; Load up all variables for the collision function
    move.l  #COIN_HEIGHT,-(sp)
    move.l  #COIN_WIDTH,-(sp)
    move.w  (a1)+,d0 ; Coin X position
    ext.l   d0
    move.l  d0,-(sp)
    move.w  (a1)+,d0 ; Coin Y position
    ext.l   d0
    move.l  d0,-(sp) 
    move.l  #FIREBALL_HEIGHT,-(sp)
    move.l  #FIREBALL_WIDTH,-(sp)
    move.l  (a5)+,d0 ; Fireball X position 
    move.l  (a5),d1 ; Fireball Y position 
    move.l  d1,-(sp) ; Y comes first in collision function   
    move.l  d0,-(sp)
    lea     COLLISION_BOOL,a0
    move.l  (a0),-(sp)
    jsr     Collision
; Save the boolean from collision function    
    lea     COLLISION_BOOL,a0
    move.l  (sp),(a0)
    add.l   #COLLISION_ARGS,sp
; Check boolean and call found function if true      
    cmp.l   #0,(a0)     
    beq     NoFBCoinCollision  
    jsr     CollisionFBCoinFound
; If collision is found at current coin, it is not
; possible to have a collision at another coin. Return.    
    bra     CheckFBCoinCollisionReturn
NoFBCoinCollision:

; Before moving on, check if there was a collision 
; last time for this particular fireball and coin

; Check the fireball to match
    lea     FIREBALL_ADDRESS_HOLDER,a0
    move.l  (a0),d0
    cmp.l   d0,a4
    bne     NoPrevCollision
; Check the coin to match    
    lea     COIN_ADDRESS_HOLDER,a6
    move.l  (a6),d0
    cmp.l   d0,a3
    bne     NoPrevCollision
; If both match, clear the holders and redraw the coin one last time    
    move.l  #0,(a0)
    move.l  #0,(a6)   
    jsr     DrawCoinsSetup
    rts     ; Return as we have drawn all coins for this iteration
NoPrevCollision:
; Reduce counter and loop again  
    sub.l   #1,(a2)
    beq     CheckFBCoinCollisionReturn
    bra     CheckFBCoinCollisionLoop
CheckFBCoinCollisionReturn:
    rts    

; Called if collision found between fireball and coin
CollisionFBCoinFound:
; Set the address holders to indicate there was 
; a collision between this coin and fireball
    lea     COIN_ADDRESS_HOLDER,a0
    move.l  a3,(a0)
    lea     FIREBALL_ADDRESS_HOLDER,a0
    move.l  a4,(a0)
; Redraw the coin since the fireball is passing through
    move.l  a3,-(sp)
    jsr     DrawSingleCoin
    add.l   #DRAW_SINGLE_COIN_ARGS,sp
    rts

; Iterates through all fireballs and redraws BG for each one
RedrawBGFireballsSetup:
; Setup counter
    lea     NUM_FIREBALLS_COUNTER,a2
    move.l  #NUM_FIREBALLS,(a2)
RedrawBGFireballs:
; Find fireball
    lea     FireballsTable,a1
    move.l  #5,d0
    sub.l   (a2),d0
    lsl.l   #3,d0
    add.l   d0,a1
;Redraw BG for fireball    
    move.l  a1,-(sp)
    jsr     RedrawBGFireball
    add.l   #REDRAW_BG_FIREBALL_ARGS,sp
; Decrement counter    
    lea     NUM_FIREBALLS_COUNTER,a2
    sub.l   #1,(a2)
    beq     RedrawBGFireballsReturn
    bra     RedrawBGFireballs    
RedrawBGFireballsReturn:
    rts

; Once game is restarted, reset the fireballs to their original positions/speeds
ResetFireballsSetup:
    lea     FireballsTable,a1
    move.l  #NUM_FIREBALLS,d0
ResetFireballs:  
    move.l  #FIREBALL_DRAW_X,(a1)+
    move.l  #FIREBALL_DRAW_Y,(a1)+
    sub.l   #1,d0
    beq     ResetFireballsSpeed
    bra     ResetFireballs
ResetFireballsSpeed:   
; Speeds are all individual, so loop is not used here
    lea     FireballSpeedTable,a1
    move.l  #128,(a1)+
    move.l  #0,(a1)+
    move.l  #-128,(a1)+
    move.l  #0,(a1)+
    move.l  #256,(a1)+
    move.l  #0,(a1)+
    move.l  #-256,(a1)+
    move.l  #0,(a1)+
    move.l  #512,(a1)+
    move.l  #0,(a1)+    
    rts

SetTime:
    move.l  #TIME_CODE,d0
    TRAP    #15
    lea     PREV_TIME,a0
    move.l  d1,(a0)
    rts

DeltaTime:
    lea     PREV_TIME,a0
    lea     NEW_TIME,a1
    lea     DELTA_TIME,a2
    move.l  #TIME_CODE,d0
    TRAP    #15
    move.l  d1,(a1)
    sub.l   (a0),d1
    move.l  d1,(a2)
    move.l  (a1),(a0)    
    rts
    

PREV_TIME   DC.L    0
DELTA_TIME  DC.L    0
NEW_TIME    DC.L    0

NUM_FIREBALLS           EQU     5
NUM_FIREBALLS_COUNTER   DC.L    0

FIREBALL_WIDTH          EQU     5
FIREBALL_HEIGHT         EQU     5
FIREBALL_DRAW_X         EQU     300
FIREBALL_DRAW_Y         EQU     420
GRAVITY_FP              DC.L    2

COIN_ADDRESS_HOLDER             DC.L    0
FIREBALL_ADDRESS_HOLDER         DC.L    0

FireballsTable:
FB1X: DC.L 300
FB1Y: DC.L 420
FB2X: DC.L 300
FB2Y: DC.L 420
FB3X: DC.L 300
FB3Y: DC.L 420
FB4X: DC.L 300
FB4Y: DC.L 420
FB5X: DC.L 300
FB5Y: DC.L 420

FireballSpeedTable:
FB1SPEEDX: DC.L 128
FB1SPEEDY: DC.L 0
FB2SPEEDX: DC.L -128
FB2SPEEDY: DC.L 0
FB3SPEEDX: DC.L 256
FB3SPEEDY: DC.L 0
FB4SPEEDX: DC.L -256
FB4SPEEDY: DC.L 0
FB5SPEEDX: DC.L 0
FB5SPEEDY: DC.L 0













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
