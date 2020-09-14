*-----------------------------------------------------------
* Program Number: #1
* Written by    : Jordan Martin
* Date Created  : 9/11/2020
* Description   : BubbleSort
*
*-----------------------------------------------------------

START   ORG     $1000

; Copies values from DataToSort to SortedData
CopyData:
        move.l  #(EndOfDataToSort - DataToSort)/2, d1
        beq.l   EndOfProgram    ; Error Handling, if size = 0
        lea     DataToSort, a1
        lea     SortedData, a2
CopyDataLoop:
        move.w  (a1)+, (a2)+
        subi.l  #1, d1
        beq.l   BubbleSortSetup
        bra     CopyDataLoop  

BubbleSortSetup:
        move.l  #(EndOfSortedData - SortedData)/2, d0 ; # of word sized elements in data
        beq.l   EndOfProgram    ; Error Handling, if size = 0
        
BubbleSortLoop:
        ; Load first two addresses and size of data
        lea     SortedData, a0
        lea     SortedData+2, a1
        move.l  #(EndOfSortedData - SortedData)/2, d1 
        
        ; Subtract the amount of outer loop iterations from the amount of inner loop iterations
        move.l  d1, d7 
        sub.l   d0, d7
        sub.l   d7, d1
        
        ; Start pass
        bra     BubbleSortPass
        
BubbleSortLoopReturn:
        ; Return from pass and check iterations of loop
        subi.l  #1, d0
        beq.l   EndOfProgram
        bra     BubbleSortLoop

BubbleSortPass:
        ; Check iterations of loop before logic in order to skip the comparison of last element
        subi.l  #1, d1
        beq.l   BubbleSortLoopReturn
        
        ; Compare and swap if greater   
        move.w  (a0), d2
        move.w  (a1), d3
        cmp.w   d3, d2 
        bgt.w   Swap
        move.w  (a0), (a0)+
        move.w  (a1), (a1)+
        bra     BubbleSortPass

; Swaps the data in two word sized addresses
; Uses d2 from earlier comparison as temp variable
Swap:
        move.w  (a1), (a0)+
        move.w  d2, (a1)+
        bra     BubbleSortPass                        

*...by here, SortedData area of memory should contain
*...the data from DataToSort, sorted smallest to largest
EndOfProgram:
        move.w  #9,d0
        TRAP    #15
        
        STOP    #$2000

DataToSort      INCBIN "asmdata.bin"
EndOfDataToSort:
SortedData      ds.w  (SortedData-DataToSort)/2
EndOfSortedData
 
        END     START












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
