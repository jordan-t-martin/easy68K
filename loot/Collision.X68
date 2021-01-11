*-----------------------------------------------------------
* Title      : LOOT Collision
* Written by : Jordan Martin
* Date       : 10/16/2020
* Description: Collision function that checks using bounding 
; box methodology on two game objects (A and B). Returns a boolean
; with the result of the collision check.
*-----------------------------------------------------------

Collision:
; Pop off all variables
    add.l   #LONG_WORD,sp
    add.l   #COLLISION_BOOL_SIZE,sp   
    lea     A_X,a0
    move.l  (sp)+,(a0)
    lea     A_Y,a0
    move.l  (sp)+,(a0)
    lea     A_WIDTH,a0    
    move.l  (sp)+,(a0)
    lea     A_HEIGHT,a0    
    move.l  (sp)+,(a0)
    lea     B_Y,a0
    move.l  (sp)+,(a0)
    lea     B_X,a0
    move.l  (sp)+,(a0)    
    lea     B_WIDTH,a0    
    move.l  (sp)+,(a0)
    lea     B_HEIGHT,a0    
    move.l  (sp)+,(a0)   
    sub.l   #COLLISION_ARGS,sp
    sub.l   #LONG_WORD,sp

; Right side of A is greater than or equal to left side of B
Condition1:    
    lea     A_X,a0
    move.l  (a0),d0
    lea     A_WIDTH,a0
    add.l   (a0),d0
    lea     B_X,a0
    move.l  (a0),d1
    cmp.l   d1,d0
    bge     Condition2
    bra     False
; Left side of A is less than or equal to right side of B
Condition2:
    lea     A_X,a0
    move.l  (a0),d0
    lea     B_X,a0
    move.l  (a0),d1
    lea     B_WIDTH,a0
    add.l   (a0),d1
    cmp.l   d1,d0
    ble     Condition3
    bra     False
; Bottom side of A is greater than or equal to top side of B
Condition3:
    lea     A_Y,a0
    move.l  (a0),d0
    lea     A_HEIGHT,a0
    add.l   (a0),d0
    lea     B_Y,a0
    move.l  (a0),d1
    cmp.l   d1,d0
    bge     Condition4
    bra     False
; Top side of A is less than or equal to bottom side of B
Condition4:
    lea     A_Y,a0
    move.l  (a0),d0
    lea     B_Y,a0
    move.l  (a0),d1
    lea     B_HEIGHT,a0
    add.l   (a0),d1
    cmp.l   d1,d0
    ble     True
    bra     False

; Set the boolean
True:
    add.l   #LONG_WORD,sp
    move.l  #1,(sp)
    sub.l   #LONG_WORD,sp
    rts
False:
    add.l   #LONG_WORD,sp
    move.l  #0,(sp)
    sub.l   #LONG_WORD,sp
    rts

A_X         DC.L 0
A_Y         DC.L 0
A_WIDTH     DC.L 0
A_HEIGHT    DC.L 0
B_X         DC.L 0
B_Y         DC.L 0
B_WIDTH     DC.L 0
B_HEIGHT    DC.L 0
COLLISION_BOOL_SIZE EQU 4








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
