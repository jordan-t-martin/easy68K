*-----------------------------------------------------------
* Title      : Bitmap Chunk Main Function
* Written by : Jordan Martin
* Date       : 9/25/2020
* Description: Main function that loads a bitmap into memory,
* creates variables to specify details, and calls a subroutine
* to display a portion of a bitmap image
*-----------------------------------------------------------
    ORG    $1000

START:    

; Load variables onto stack and call subroutine to draw bitmap chunk.
MainFunction:
    sub.l       #16,sp ; Decrement stack to create space
    lea         BITMAP_IMG,a0 ; Load variables onto stack
    move.l      a0,-(sp)
    move.l      #LEFT_X_CHUNK,-(sp)
    move.l      #TOP_Y_CHUNK,-(sp)
    move.l      #WIDTH_CHUNK,-(sp)
    move.l      #HEIGHT_CHUNK,-(sp) 
    move.l      #LEFT_X_LOC,-(sp)
    move.l      #TOP_Y_LOC,-(sp) 
    jsr         DrawBitmap ; Call subroutine
    add.l       #16,sp ; Increment stack to adjust
    bra         EndOfProgram
BitmapSubroutine INCLUDE     "bitmapChunkSubroutine.x68"   
EndOfProgram:   
    SIMHALT            

* Put variables and constants here
BITMAP_IMG      INCBIN  "test-cases\mario-super-big.bmp"
LEFT_X_CHUNK    EQU     0
TOP_Y_CHUNK     EQU     0
WIDTH_CHUNK     EQU     1280
HEIGHT_CHUNK    EQU     720
LEFT_X_LOC      EQU     0
TOP_Y_LOC       EQU     0
  
    END    START

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
