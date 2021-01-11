*-----------------------------------------------------------
* Title      : Bitmap
* Written by : Jordan Martin
* Date       : 9/22/2020
* Description: Contains subroutine that draws a chunk of a bitmap
* at a specified location on the display.
* Variables required in order on the stack:
* Name         | Size  | Stack Position | Description
* ----------------------------------------------------------
* BITMAP_IMG   | Long  | 4(sp)          | Address location of the bitmap image
* LEFT_X_CHUNK | Long  | 8(sp)          | Leftmost X position of the chunk to display
* TOP_Y_CHUNK  | Long  | 12(sp)         | Topmost Y position of the chunk to display
* WIDTH_CHUNK  | Long  | 16(sp)         | Width of the chunk to display
* HEIGHT_CHUNK | Long  | 20(sp)         | Height of the chunk to display 
* LEFT_X_LOC   | Long  | 24(sp)         | Leftmost X position of where to draw the chunk on the display
* TOP_Y_LOC    | Long  | 28(sp)         | Topmost Y position of where to draw the chunk on the display
*-----------------------------------------------------------

; Converts the order of 4 bytes written in little endian to big endian
ByteSwapSetup
        add.l   #4,sp 
        move.l  (sp),d0 ; Pop off parameter
ByteSwapLoop:
        rol.w   #8, d0
        rol.l   #8, d0
        rol.l   #8, d0
        rol.w   #8, d0  
ByteSwapRTS:
        move.l  d0,(sp) ; Save parameter back to stack
        sub.l   #4,sp
        rts 

; Draws a chunk of a bitmap at a specified location
DrawBitmap:

; Pop off variables
        add.l   #4,sp      
        lea     _TOP_Y_LOC,a0
        move.l  (sp)+,(a0)
        lea     _LEFT_X_LOC,a0
        move.l  (sp)+,(a0)
        lea     _CHUNK_HEIGHT,a0
        move.l  (sp)+,(a0)
        lea     _CHUNK_WIDTH,a0
        move.l  (sp)+,(a0)
        lea     _TOP_Y_CHUNK,a0
        move.l  (sp)+,(a0)
        lea     _LEFT_X_CHUNK,a0
        move.l  (sp)+,(a0)
        lea     _BITMAP_IMG,a0
        move.l  (sp)+,(a0)
        sub.l   #_DRAW_BMP_ARGS,sp
        sub.l   #4,sp
        
; Read header information addresses into address registers
        
        lea     _BITMAP_IMG,a0 ; Inside a0, read in location of BitmapImg
        move.l  (a0),a1   
        add.l   #10,a1
        lea     PIXEL_ARRAY_OFFSET,a2
        move.l  (a1),(a2)
        
        move.l  (a0),a1   
        add.l   #18,a1 
        lea     IMG_WIDTH,a2
        move.l  (a1),(a2)
        
        move.l  (a0),a1   
        add.l   #22,a1 
        lea     IMG_HEIGHT,a2
        move.l  (a1),(a2)
        
        move.l  (a0),a1   
        add.l   #28,a1 
        lea     BITS_PER_PIXEL,a2
        move.l  (a1),(a2)                
        
; Call ByteSwap subroutine on saved header information

        ; ByteSwap pixel array offset and calculate pixel array location

        lea     PIXEL_ARRAY_OFFSET,a1        
        move.l  (a1),-(sp) ; Copy pixel array offset as parameter
        jsr     ByteSwapSetup ; Call subroutine and return
        move.l  (sp)+,d0 ; Get byteswapped pixel array offset
        move.l  (a0),a1 ; Get BitmapImg
        add.l   d0,a1 ; Add offset to get pixel array location in a1
        
        ; ByteSwap width of image
        
        lea     IMG_WIDTH,a2
        move.l  (a2),-(sp) ; Copy width as parameter
        jsr     ByteSwapSetup
        move.l  (sp)+,(a2) ; a2 now has width in memory
        
        ; ByteSwap height of image

        lea     IMG_HEIGHT,a3
        move.l  (a3),-(sp) ; Copy height as parameter
        jsr     ByteSwapSetup
        move.l  (sp)+,(a3) ; a3 now has height in memory
        
        ; ByteSwap bits per pixel of image and convert to BYTES per pixel

        lea     BITS_PER_PIXEL,a4
        move.l  (a4),-(sp) ; Copy bits per pixel as parameter
        jsr     ByteSwapSetup
        move.l  (sp)+,d0 ; a4 now has bits per pixel in memory
        divs.w  #8,d0 ; divide by # of bits in byte to get byte per pixel
        move.l  d0,(a4) 

; Calculate padding to add to each row (# of bytes must end on a multiple of 4)

        ; Width * Bytes per pixel = total bytes in a row (pre-padding)
        move.l  (a2),d0 ; Width
        move.l  (a4),d1 ; BPP
        muls.w  d0,d1 ; total bytes in row
        move.l  d1,d6 ; Save off total bytes in a row (pre-padding) for use later
        
        ; Remainder of (total bytes per row / 4) tells us if there is extra bytes over 4 byte boundary 
        divs.w  #4,d1
        swap.w  d1 ; Get remainder portion
        move.w  d1,d1 ; Do a move to set zero bit
        beq     DrawChunkSetup ; Remainder = 0, no problem!
        move.w  #4,d7 ; Otherwise, subtract remainder from 4 to get amount of padding used
        sub.w   d1,d7
        add.l   d7,d6 ; Add the calculated padding to bytes per row
        bra     DrawChunkSetup  
  
DrawChunkSetup:
; Set the starting position on the display
; Bitmap images are read bottom up, from left to right
; Therefore, start in bottom left corner and move up

        lea     _LEFT_X_LOC,a5
        move.l  (a5),d3 ; Move X location in d3
        lea     _TOP_Y_LOC,a5
        move.l  (a5),d4 ; Move Y location in d4
        lea     _CHUNK_HEIGHT,a5
        add.l   (a5),d4 ; Add the chunk height to Y position to get to bottom
        sub.l   #1,d4 ; Adjust for range. Range is from 0 to (Height - 1)
        
; Calculated amount of pixels to skip due to chunk size
; Need this for Y bottom, Y top, X left, and X right

        ; Y skip from bottom
        ; = (IMG_HEIGHT - (TOP_Y_CHUNK + CHUNK_HEIGHT)) * (Total bytes in a row)
        move.l  (a3),d5 ; Get image height
        lea     _CHUNK_HEIGHT,a5
        sub.l   (a5),d5 ; Subtract chunk height
        lea     _TOP_Y_CHUNK,a5
        sub.l   (a5),d5 ; Subtract top Y position of chunk
        ; d5 now contains total rows from bottom that need to be skipped
        muls.w  d5,d6 ; Multiply this by bytes per row (calculated earlier)
        add.l   d6,a1 ; Skip these pixels in the image      
        
        ; Y skip on top is not calculated as we can quit once we are done drawing.
        
        ; X on right side
        ; = (IMG_WIDTH - (LEFT_X_CHUNK + CHUNK_WIDTH)) * (Bytes in a pixel)
        move.l  (a2),d6 ; Get image width
        lea     _LEFT_X_CHUNK,a5
        move.l  (a5),d5 ; Get leftmost X position for chunk
        lea     _CHUNK_WIDTH,a5
        add.l   (a5),d5 ; Add chunk width
        sub.l   d5, d6 ; Subtract this sum from total image width
        move.l  (a4),d5 ; Get bytes per pixel
        muls.w  d5,d6 ; Multiply to get total pixel bytes to skip
        lea     X_RIGHT_SKIP,a5 ; Save off to variable as we will use this more than once
        move.l  d6,(a5)
        
        ; X on the left side
        ; = LEFT_X_CHUNK * (Bytes in a pixel)
        lea     _LEFT_X_CHUNK,a5
        move.l  (a5),d5 ; Get leftmost X position for chunk
        move.l  (a4),d6 ; Get bytes per pixel
        muls.w  d6,d5 ; Multiply to get total pixel bytes to skip
        lea     X_LEFT_SKIP,a5 ; Save off to variable as we will use this more than once
        move.l  d5,(a5)

        add.l   (a5),a1 ; Initial Left X Skip       

DrawChunkRow:
; Draw a row of the chunk
        
; Move pixel color bytes into into d1 for pen color
        clr.l   d1
        move.l  (a4),d5 ; Get bytes per pixel    
        cmp.l   #3,d5 ; Check for 24 bit color depth
        beq     LoadColorByte24
        cmp.l   #4,d5 ; Check for 32 bit color depth
        beq     LoadColorByte32
        
; Load each byte of the color into d1
LoadColorByte24:
        lsl.l   #$08,d1
        move.b  (a1)+,d1
        sub.l   #1,d5
        bne     LoadColorByte24
        bra     DrawPixel

; For 32 bit, an extra 00 is placed at end and needs to be rotated to beginning        
LoadColorByte32:
        lsl.l   #8,d1
        move.b  (a1)+,d1
        sub.l   #1,d5
        bne     LoadColorByte32 
        ror.l   #8,d1       

; Set the trap codes and draw a pixel from color read at (x,y) location
DrawPixel:
        cmp.l   #TRANSPARENT_COLOR,d1
        beq     SkipDraw        
        move.l  #PEN_COLOR_TRAP_CODE,d0 ; Sets pen color
        TRAP    #15
        
        move.l  d3,d1
        move.l  d4,d2 
        move.l  #DRAW_PIXEL_TRAP_CODE,d0 ; Draws a pixel at X,Y
        trap    #15
SkipDraw:
; Adjust (x,y) positions
        
        addi.l  #1,d3 ; Move X forward a pixel
        lea     _CHUNK_WIDTH, a5
        move.l  (a5),d5 ; Get chunk width
        lea     _LEFT_X_LOC,a5
        add.l   (a5),d5 ; Add chunk width to leftmost X location to get the max X value
        cmp.l   d5,d3 ; Check if current X is equal to max
        bne     DrawChunkRow
        
; If we have reached the max X value, see if we should start a new row

        lea     _LEFT_X_LOC,a5
        move.l  (a5),d3 ; Reset X to leftmost X location
        subi.l  #1,d4 ; Move Y upward a pixel
        lea     X_RIGHT_SKIP,a5
        add.l   (a5),a1 ; Add X_RIGHT_SKIP to pixel array
        add.l   d7,a1 ; Add padding buffer to pixel array location
        lea     X_LEFT_SKIP,a5        
        add.l   (a5),a1 ; Add X_LEFT_SKIP to pixel array
        lea     _TOP_Y_LOC,a5
        move.l  (a5),d5 ; Get topmost Y location to get min Y value
        cmp.l   d5,d4 ; Check if current height is greater than or equal to min Y value
        bge     DrawChunkRow ; If so, start a new row
        rts

_BITMAP_IMG              DS.L    1
_LEFT_X_CHUNK            DS.L    1
_TOP_Y_CHUNK             DS.L    1
_CHUNK_WIDTH             DS.L    1
_CHUNK_HEIGHT            DS.L    1
_LEFT_X_LOC              DS.L    1
_TOP_Y_LOC               DS.L    1     
  
;LEFT_X                   EQU     0
;TOP_Y                    EQU     0
PIXEL_ARRAY_OFFSET      ds.l    1
IMG_WIDTH               ds.l    1
IMG_HEIGHT              ds.l    1
BITS_PER_PIXEL          ds.l    1            
X_LEFT_SKIP              ds.l    1
X_RIGHT_SKIP             ds.l    1 
PEN_COLOR_TRAP_CODE      EQU     80
DRAW_PIXEL_TRAP_CODE     EQU     82
SET_OUTPUT_RES_TRAP_CODE EQU     33
_DRAW_BMP_ARGS           EQU     28 
TRANSPARENT_COLOR        EQU     $000BE935




























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
