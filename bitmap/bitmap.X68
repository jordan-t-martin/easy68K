*-----------------------------------------------------------
* Title      : Bitmap
* Written by : Jordan Martin
* Date       : 9/22/2020
* Description: Import any bitmap image file and draw using 68K graphics
*-----------------------------------------------------------

* Put program code here

DrawBitmap:

; Read header information into address registers
        
        move.l  4(sp),a0 ; Read in location of BitmapImg
        move.l  a0, a1
        add.l   #10, a1 ; Move to pixel array offset
        move.l  a0, a2
        add.l   #18, a2 ; Move to width 
        move.l  a0, a3
        add.l   #22, a3 ; Move to height
        move.l  a0, a4  
        add.l   #28, a4 ; Move to bits per pixel
        
; Call ByteSwap subroutine on saved header information

        ; ByteSwap pixel array offset and calculate pixel array location
        
        sub.l   #4, sp ; Setup stack with one 4 byte parameter
        move.l  (a1),(sp) ; Copy parameter
        jsr     ByteSwapSetup ; Call subroutine
        move.l  (sp),d0 ; Gives offset
        add.l   #4, sp ; Fix the stack
        move.l  a0, a1 ; Get BitmapImg
        add.l   d0, a1 ; Add offset to get pixel array location in a1
        
        ; ByteSwap width of image
        
        sub.l   #4, sp 
        move.l  (a2),(sp)
        jsr     ByteSwapSetup
        move.l  (sp),(a2) ; a2 now has width in memory
        add.l   #4, sp
        
        ; ByteSwap height of image

        sub.l   #4, sp
        move.l  (a3),(sp)
        jsr     ByteSwapSetup
        move.l  (sp),(a3) ; a3 now has height in memory
        add.l   #4, sp
        
        ; ByteSwap bytes per pixel of image

        sub.l   #4, sp
        move.l  (a4),(sp)
        jsr     ByteSwapSetup
        move.l  (sp),d0 ; a4 now has bpp in memory
        add.l   #4, sp
        divs.w  #8, d0 ; divide by # of bits in byte to get byte per pixel
        move.l  d0, (a4)

; Extra padding is added to each row so that the # of bytes ends on a multiple of 4

        ; width * bytes per pixel = total bytes in a row
        move.l  (a2),d0 ; Width
        move.l  (a4),d1 ; BPP
        muls.w  d0, d1 ; total bytes in row
        move.l  d1, d6 ; Save off for use later
        
        ; remainder of (total bytes per row / 4) tells us if there is extra bytes over 4 byte boundary 
        divs.w  #4, d1
        swap.w  d1 ; Get remainder portion
        move.w  d1, d1 ; Do a move to set zero bit
        beq     DrawSquare ; Remainder = 0, no problem!
        move.w  #4, d7
        sub.w   d1, d7 ; Subtract remainder from 4 to get amount of padding used
        add.l   d7, d6 ; add padding to bytes per row
        bra     DrawSquare

; Converts the order of 4 bytes written in little endian to big endian
ByteSwapSetup
        move.l  #4, d7 ; Byte swap loop counter
        move.l  4(sp), d0 ; Pop off parameter
ByteSwapLoop:
        move.b  d0, d1 ; Move one byte at a time from d0 to d1
        subi.b  #1, d7 ; Decrement counter
        beq     ByteSwapRTS
        lsr.l   #$08, d0 ; Right shift source
        lsl.l   #$08, d1 ; Left shift destination
        bra     ByteSwapLoop   
ByteSwapRTS:
        move.l  d1, 4(sp) ; Save parameter back to stack
        rts     

; Sets up to draw a square      
DrawSquare:
        move.l  (a2),d1 ; Width
        swap.w  d1
        move.w  (a3),d1 ; Height
        move.b  #SET_OUTPUT_RESOLUTION_TRAP_CODE,D0 ; Sets window size
        TRAP    #15
        clr.l   d1

        move.l  24(sp),d3 ; X position
        move.l  28(sp),d4 ; Y position
        add.l   20(sp),d4
        
        ; Adjust for chunk starting position
        move.l  (a3), d5
        sub.l  20(sp),d5
        sub.l   12(sp),d5
        muls.w  d5, d6 ; Multiply top_y_chunk by bytes per row
        add.l   d6,a1      
        ; Calculate skip amount
        
        ; X on right side
        move.l  (a2), d6
        move.l  8(sp), d5
        add.l   16(sp), d5
        sub.l   d5, d6
        move.l  (a4),d5
        muls.w  d5, d6
        lea     X_RIGHT_SKIP, a5
        move.l  d6, (a5)
        
        ; X on the left side
        move.l  8(sp), d5
        move.l  (a4),d6
        muls.w  d6, d5
        lea     X_LEFT_SKIP, a6
        move.l  d5, (a6)

        add.l   (a6),a1        

continueRow:
; Draw a row of the image
        
    ; Move pixel color bytes into into d1 for pen color
        move.b  (a1)+,d1
        lsl.l   #$08, d1
        move.b  (a1)+,d1
        lsl.l   #$08, d1
        move.b  (a1)+,d1
        
        move.l  #PEN_COLOR_TRAP_CODE, d0 ; Sets pen color
        TRAP    #15
        
        move.l  d3, d1
        move.l  d4, d2
        move.l  #DRAW_PIXEL_TRAP_CODE,d0 ; Draws a pixel at X,Y
        trap    #15
        
        addi.l  #1,d3 ; Move X forward a pixel
        move.l  16(sp),d5
        add.l   24(sp),d5 ; Add chunk_width to LEFT_X to get max X value
        cmp.l   d5,d3 ; Check if current width is equal to max
        bne     continueRow
    ; Start a new row
        move.l  24(sp),d3 ; Reset X to min X value
        subi.l  #1,d4 ; Move Y backward a pixel
        add.l   (a6),a1
        add.l   (a5),a1
        add.l   d7,a1 ; Add padding buffer to pixel array location
        move.l  28(sp),d5 
        cmp.l   d5,d4 ; Check if current height is equal to min
        bne     continueRow
        rts
* Put variables and constants here
LEFT_X  EQU     0
TOP_Y   EQU     0
X_LEFT_SKIP ds.l 1
X_RIGHT_SKIP ds.l 1 
PEN_COLOR_TRAP_CODE     EQU     80
DRAW_PIXEL_TRAP_CODE    EQU     82
SET_OUTPUT_RESOLUTION_TRAP_CODE EQU     33
OUTPUT_WIDTH        EQU     1024
OUTPUT_HEIGHT       EQU     768
;BytesPerColor EQU 3
;BitmapImg   INCBIN "image36.bmp"












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
