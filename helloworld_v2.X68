*-----------------------------------------------------------
* Title      : Hello World v2
* Written by : Jordan Martin
* Date       : 08/28/2020
* Description: Slightly modified from first version
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

*Output code
LOOP:
    LEA MESSAGE, A1             ; Load MESSAGE int address register A1
    MOVE.B #14, D0              ; Move literal number 14 into data register D0
    TRAP #15                    ; #14 displays NULL terminated string at A1
    
*Input code
    MOVE.B #4,D0                ; Trap task 4: 
    TRAP #15                    ; reads number from keyboard into D1.L
    CMP.L #0,D1                 ; Compare D1 to the number 0
    BEQ DONE                    ; Branch to DONE if they are equal
    
    CMP.B #0,D1                 ; Compares D1 to 0
    BLT INVALID                 ; Branches if D1 is less than 0
    CMP.B #9,D1                 ; Compares D1 to 9
    BGT INVALID                 ; Branches if D1 is greater than 9
    
    CMP.B #1,D1                 ; Compare D1 and 1
    BNE TWO                     ; If not equal, move onto label TWO
    LEA DISPONE,A1
    MOVE.B #14,D0
    TRAP #15
    BRA LOOP
    
TWO:
    CMP.B #2,D1                 ; Compare D1 and 2
    BNE THREE                   ; If not equal, move onto label THREE
    LEA DISPTWO,A1
    MOVE.B #14,D0
    TRAP #15
    BRA LOOP
    
THREE:
    CMP.B   #3,D1               ; Compare D1 and 3
    BNE     FOUR                ; If not equal, move onto label FOUR
    LEA     DISPTHR,A1      
    MOVE.B  #14,D0  
    TRAP    #15
    BRA     LOOP

FOUR:
    CMP.B   #4,D1               ; Compare D1 and 4
    BNE     FIVE                ; If not equal, move onto label FIVE
    LEA     DISPFOU,A1      
    MOVE.B  #14,D0  
    TRAP    #15
    BRA     LOOP

FIVE:                           
    CMP.B   #5,D1               ; Compare D1 and 5
    BNE     SIX                 ; If not equal, move onto label SIX  
    LEA     DISPFIV,A1      
    MOVE.B  #14,D0  
    TRAP    #15
    BRA     LOOP

SIX:
    CMP.B   #6,D1               ; Compare D1 and 6
    BNE     SEVEN               ; If not equal, move onto label SEVEN 
    LEA     DISPSIX,A1      
    MOVE.B  #14,D0  
    TRAP    #15
        BRA     LOOP

SEVEN:
    CMP.B   #7,D1               ; Compare D1 and 7
    BNE     EIGHT               ; If not equal, move onto label EIGHT 
    LEA     DISPSEV,A1      
    MOVE.B  #14,D0  
    TRAP    #15
    BRA     LOOP

EIGHT:
    CMP.B   #8,D1               ; Compare D1 and 8
    BNE     NINE                ; If not equal, move onto label NINE 
    LEA     DISPEIG,A1      
    MOVE.B  #14,D0  
    TRAP    #15
    BRA     LOOP

NINE:       
    LEA     DISPNIN,A1          ; Compare D1 and 9 
    MOVE.B  #14,D0  
    TRAP    #15

    BRA LOOP    
    
INVALID:
    LEA INV, A1                 ; Display error message
    MOVE.B #14,D0
    TRAP #15
    BRA LOOP
*End program code
DONE:
    MOVE.B #9,D0               ; #9 terminates program
    TRAP #15                    ; Halt Simulator

* Put variables and constants here
CR      EQU     $0D             ; ASCII code for Crriage Return
LF      EQU     $0A             ; ASCII code for Crriage Return
MESSAGE DC.B    'Enter a number between 0 and 9, Enter 0 to exit: ',0
INV DC.B        'That is not between 1 and 9.',CR,LF,0
DISPONE DC.B    'HELLO MERCURY',CR,LF,0
DISPTWO DC.B    'HELLO VENUS',CR,LF,0
DISPTHR DC.B    'HELLO EARTH',CR,LF,0
DISPFOU DC.B    'HELLO MARS',CR,LF,0
DISPFIV DC.B    'HELLO JUPITER',CR,LF,0
DISPSIX DC.B    'HELLO SATURN',CR,LF,0
DISPSEV DC.B    'HELLO URANUS',CR,LF,0
DISPEIG DC.B    'HELLO NEPTUNE',CR,LF,0
DISPNIN DC.B    'HELLO PLUTO',CR,LF,0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
