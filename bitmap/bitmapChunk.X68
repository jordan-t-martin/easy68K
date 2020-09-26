*-----------------------------------------------------------
* Title      : Bitmap Chunk
* Written by : Jordan Martin
* Date       : 9/25/2020
* Description: Display a portion of a bitmap image
*-----------------------------------------------------------
    ORG    $1000

START:                  ; first instruction of program
    

DrawChunk:

    sub.l       #16, sp
    lea         BitmapImg, a0
    move.l      a0, (sp)
    move.l      #LEFT_X_CHUNK, 4(sp)
    move.l      #TOP_Y_CHUNK, 8(sp)
    move.l      #WIDTH_CHUNK, 12(sp)
    move.l      #HEIGHT_CHUNK, 16(sp) 
    move.l      #LEFT_X_LOC, 20(sp)
    move.l      #TOP_Y_LOC, 24(sp) 
    jsr         DrawBitmap
    add.l       #16, sp
    bra         EndOfProgram
DrawBitmap INCLUDE     "bitmap.x68"   
EndOfProgram:   
    SIMHALT             ; halt simulator

* Put variables and constants here

BitmapImg   INCBIN "image32.bmp"
LEFT_X_CHUNK  EQU     16
TOP_Y_CHUNK   EQU     16
WIDTH_CHUNK   EQU     16
HEIGHT_CHUNK  EQU     16
LEFT_X_LOC EQU     32
TOP_Y_LOC  EQU     32
  
    END    START        ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
