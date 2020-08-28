*-----------------------------------------------------------
* Title      : Hello World
* Written by : Jordan Martin
* Date       : 08/27/2020
* Description: Welcome to this big great world, EASY68K.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    LEA MESSAGE, A1             ; Load MESSAGE int address register A1
    MOVE.B #14, D0              ; Move literal number 14 into data register D0
    TRAP #15                    ; #14 displays NULL terminated string at A1
    
    MOVE.B #9, D0               ; #9 terminates program
    TRAP #15                    ; Halt Simulator

* Put variables and constants here
CR      EQU     $0D             ; ASCII code for Crriage Return
LF      EQU     $0A             ; ASCII code for Crriage Return
MESSAGE DC.B    'HELLO WORLD',CR,LF ; Place ASCII string in memory at MESSAGE
        DC.B    'I AM ALIVE AND WELL',CR,LF
        DC.B    'I am making multiple lines',CR,LF,'in one DC.B statement',CR,LF
        DC.B    'I am adding a new line...',CR,LF,CR,LF
        DC.B    '... and finally ending this message!',CR,LF,0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
