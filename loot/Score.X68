*-----------------------------------------------------------
* Title      : LOOT Score
* Written by : Jordan Martin
* Date       : 10/16/2020
* Description: Functions to handle the score
*----------------------------------------------------------- 

; Call this function draw the score text and value inside SCORE var
ScoreUpdate:
; Redraw background
    jsr     RedrawBGScore
; Set color for drawing of Score Text later
    move.l  #ORANGE_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15 
; Load variables to draw score digits   
    move.w  #SCOREDRAW_X,-(sp)
    move.w  #SCOREDRAW_Y,-(sp)
    lea SCORE,a0
    move.w  (a0),-(sp) 
    jsr DrawScore     
    add.l   #DRAW_SCORE_ARGS,sp
    move.l  #DOUBLE_BUFFER_CODE,d0   
    TRAP    #15        
    rts

; Draws the 7 digit LEDs for the value in score
DrawScore:
; Pop off all variables
    add.l   #4,sp
    lea     _SCORE,a0
    move.w  (sp)+,(a0)  
    move.l  #SCORE_DIGITS,d7
    lea     LED_Y,a0
    move.w  (sp)+,(a0)
    lea     LED_X,a0
    move.w  (sp)+,(a0)
    sub.l   #DRAW_SCORE_ARGS,sp
    sub.l   #4,sp
     
DrawScoreLoop:
; Get the score    
    lea     _SCORE,a0
    move.w  (a0),d0
; Get the most significant digit by dividing by 10 and getting remainder
    divs.w  #10,d0
; Save remaining score back to memory
    move.w  d0,(a0)
; Get remainder
    swap.w  d0
; Find sequence of bits for this number in LED table using remainder as offset
    lea     LEDTable,a0
    move.b  (a0,d0),d5
; Draw the LED for that number    
    jsr     DrawLEDNumber
; Decrement counter
    sub.l   #1,d7
    beq     EndOfAllDraws
; Move draw position left for next digit
    lea     LED_X,a0
    sub.w   #SCORE_SPACING+LED_WIDTH,(a0)
    bra     DrawScoreLoop    

; Draw the LED for the current sequence of bits in d5
DrawLEDNumber:
; Setup pen
    move.l  #YELLOW_PEN_COLOR,d1
    move.l  #PEN_COLOR_CODE,d0
    TRAP    #15
    move.l  #LINE_THICKNESS,d1
    move.l  #PEN_THICKNESS_CODE,d0
    TRAP    #15
    
; Setup bit position to test in sequence    
    move.l  #LED_COUNTER,d6

; Setup position    
    lea     LED_X,a0
    move.w  (a0),d1
    move.w  (a0),d3    
    lea     LED_Y,a0
    move.w  (a0),d2
    move.w  (a0),d4
    
DrawA:
;(0,0) -> (1,0)
    btst.l  d6,d5 ; Check bit position for A
    beq     DrawB ; False, skip
    add.w   #LED_WIDTH,d3 ; Do math from origin point to get correct line
    move.l  #DRAW_LINE_CODE,d0 ; Draw line
    TRAP    #15 
    jsr     LoadXYRegisters ; Reset origin point    
DrawB:
;(1,0) -> (1,1)
    sub.l   #1,d6
    btst.l  d6,d5   
    beq     DrawC
    add.w   #LED_WIDTH,d1
    add.w   #LED_WIDTH,d3
    add.w   #LED_HEIGHT,d4    
    move.l  #DRAW_LINE_CODE,d0
    TRAP    #15
    jsr     LoadXYRegisters     
DrawC:
;(1,1) -> (1,2)
    sub.l   #1,d6
    btst.l  d6,d5   
    beq     DrawD
    add.w   #LED_WIDTH,d1
    add.w   #LED_HEIGHT,d2
    add.w   #LED_WIDTH,d3
    add.w   #LED_HEIGHT<<1,d4
    move.l  #DRAW_LINE_CODE,d0  
    TRAP    #15
    jsr     LoadXYRegisters               
DrawD:
;(0,2) -> (1,2)
    sub.l   #1,d6
    btst.l  d6,d5   
    beq     DrawE
    add.w   #LED_HEIGHT<<1,d2
    add.w   #LED_WIDTH,d3
    add.w   #LED_HEIGHT<<1,d4
    move.l  #DRAW_LINE_CODE,d0  
    TRAP    #15 
    jsr     LoadXYRegisters       
DrawE:
;(0,1) -> (0,2)
    sub.l   #1,d6
    btst.l  d6,d5 
    beq     DrawF
    add.w   #LED_HEIGHT,d2
    add.w   #LED_HEIGHT<<1,d4
    move.l  #DRAW_LINE_CODE,d0   
    TRAP    #15   
    jsr     LoadXYRegisters     
DrawF:
;(0,0) -> (0,1)
    sub.l   #1,d6
    btst.l  d6,d5   
    beq     DrawG
    add.w   #LED_HEIGHT,d4
    move.l  #DRAW_LINE_CODE,d0 
    TRAP    #15  
    jsr     LoadXYRegisters        
DrawG:
;(0,1) -> (1,1)
    sub.l   #1,d6
    btst.l  d6,d5   
    beq     EndOfDraw
    add.w   #LED_HEIGHT,d2
    add.w   #LED_WIDTH,d3
    add.w   #LED_HEIGHT,d4
    move.l  #DRAW_LINE_CODE,d0
    TRAP    #15   

EndOfDraw:
    rts
    
EndOfAllDraws:
; Change the pen back 
    move.l  #1,d1
    move.l  #PEN_THICKNESS_CODE,d0
    TRAP    #15
; Draw the accompanying text
    jsr     DrawScoreText
    rts

LoadXYRegisters:
    lea     LED_X,a0
    move.w  (a0),d1
    move.w  (a0),d3    
    lea     LED_Y,a0
    move.w  (a0),d2
    move.w  (a0),d4
    rts

; Gets the position of the LED digits and draws text to the left of it
DrawScoreText:
    clr.l   d1
    clr.l   d2
    lea     LED_X,a1
    move.w  (a1),d1
    sub.l   #SCORE_TEXT_OFFSET_X,d1
    lea     LED_Y,a1
    move.w  (a1),d2
    sub.w   #SCORE_TEXT_OFFSET_Y,d2    
    lea     SCORE_TEXT,a1  
    move.l  #DRAW_TEXT_CODE,d0
    TRAP    #15
    rts  

; Sets up new score location/color for death screen   
DeathScoreUpdate
    move.l  #BLACK_PEN_COLOR,d1
    move.l  #FILL_COLOR_CODE,d0
    TRAP    #15      
    move.w  #DEATH_SCOREDRAW_X,-(sp)
    move.w  #DEATH_SCOREDRAW_Y,-(sp)
    lea SCORE,a0
    move.w  (a0),-(sp) 
    jsr DrawScore     
    add.l   #DRAW_SCORE_ARGS,sp
    move.l  #DOUBLE_BUFFER_CODE,d0   
    TRAP    #15        
    rts 


LED_COUNTER     EQU     6
LED_WIDTH       EQU     5
LED_HEIGHT      EQU     5
LED_X           DS.W    1
LED_Y           DS.W    1


SCORE_DIGITS    EQU 3
SCORE_SPACING   EQU 10
SCORE_WIDTH     EQU 100
SCORE_HEIGHT    EQU 30
SCORE           DC.W    0
_SCORE          DC.W  0 ; A copy of score so that when modding, it doesn't get trashed


SCORE_TEXT          DC.L    'LOOT: ',CR,LF,0
SCORE_TEXT_OFFSET_X EQU   50
SCORE_TEXT_OFFSET_Y EQU   1

; Top right location for in game
SCOREDRAW_X             EQU     580
SCOREDRAW_Y             EQU     5
; Middle location for end screen
DEATH_SCOREDRAW_X            EQU     355
DEATH_SCOREDRAW_Y            EQU     270  


;0abcdefg
LEDTable:
Number0: DC.B $7E    
Number1: DC.B $30
Number2: DC.B $6D
Number3: DC.B $79
Number4: DC.B $33
Number5: DC.B $5B
Number6: DC.B $5F
Number7: DC.B $70
Number8: DC.B $7F
Number9: DC.B $73

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
