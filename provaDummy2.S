.org $8000


 
; INPUT KEYS
.define UpKey $01
.define DownKey $02
.define RightKey $08
.define LeftKey $04
.define EnterKey $10

; COLORS
.define BgColor $0E
.define EnemyCol $01
.define PlayerCol $02

; SCORE
.define MaxScore $20


menuStart:
    JMP renderMenu

renderMenu:
    LDA $4000
    CMP #EnterKey
    BEQ renderBackGround
    JMP renderMenu

renderBackGround:
    LDA #BgColor                        ;color for background
    STA $0200, X                        ;load the A val into the page 2 at X position, at start is 0
    INX                                 ;increment X by 1
    CPX #$00                            ;compare X to the first cell, when we got the screen all rendered we'll jump to the gameLoop
    BEQ renderTopEnemies         
    JMP renderBackGround                ;loop

renderWinningBackGround:
    LDA #03                             ;color for background
    STA $0200, X                        ;load the A val into the page 2 at X position, at start is 0
    INX                                 ;increment X by 1
    CPX #$00                            ;compare X to the first cell, when we got the screen all rendered we'll jump to the gameLoop
    BEQ menuStart         
    JMP renderWinningBackGround         ;loop

renderTopEnemies:
    LDA #EnemyCol                       ;load color red into the A register
    STA $0200, X                        ;load the A val into the page 2 at X position
    INX                                 ;increment X by 1
    STA $0200, X                        ;load the A val into the page 2 at X position
    INX                                 ; ""
    STA $0200, X                        ; ""
    TXA                                 ;copy X into A
    ADC #$0E                            ;add $0E to go to the head position
    TAX                                 ;copy A into X
    LDA #EnemyCol                       ;restore red color into A
    STA $0200, X                        ;load the A val into the page 2 at X position
    CPX #$1D                            ;compare X val with the cell of the last top enemy's head position
    BEQ bottomEnemiesPos                ;if equal jump to bottomEnemiesPos function
    TXA                                 ;copy X into A
    SBC #$0C                            ;subctract $0C to go to the body position
    TAX                                 ;copy A into X
    JMP renderTopEnemies                ;loop

bottomEnemiesPos:                       ;define the start position of the bottom enemies
    LDX #$E1
    JMP renderBottomEnemiesV2

renderBottomEnemies:                    ;it doesn't work even if it should, the SBC line subctract $12 instead of $11 since the second loop.
    LDA #$01                            
    STA $0200, X
    INX
    STA $0200, X
    INX
    STA $0200, X
    TXA                     
    SBC #$11               
    TAX
    LDA #$01  
    STA $0200, X
    CPX #$ED
    BEQ playerBodyStart
    TXA
    ADC #$13
    TAX
    JMP renderBottomEnemies

renderBottomEnemiesV2:                  ;this works well, but i had to change the logic and make it going backwards
    LDA #EnemyCol                       ;load the red color into the A registe
    STA $0200, X                        ;load the A val into the page 2 at X position
    TXA                                 ;copy X into A
    ADC #$0E                            ;add $0E to go into the body position
    TAX                                 ;copy A into X
    LDA #EnemyCol                      ;restore red color into A
    STA $0200, X                        ;load the a val into the page 2 at X position
    INX                                 ;increment X by 1
    STA $0200, X                        ; "
    INX                                 ; "
    STA $0200, X                        ; "
    CPX #$FE                            ;compare X val with the last cell of the last body part of the last enemy
    BEQ playerBodyStart                 ;if equal go to playerBodyStart function
    TXA                                 ;copy X into A
    SBC #$0C                            ;subctract $0C to go into the head position
    TAX                                 ;copy A into X
    JMP renderBottomEnemiesV2           ;loop
    


playerBodyStart:                        ;player's starting position
    LDX #$70


gameLoop:
    JMP getInputs


getInputs:
    JMP rightDirection
    JMP bulletsLogic

rightDirection:
    LDA $4000                               ;input page
    AND #RightKey                           ;check if the key pressed is "right"
    BEQ leftDirection                       ;if not go to leftDirection
    LDA #BgColor                            ;load 00 to set up a black pixel to cancel the last position
    STA $0200, X                            ;load the A val into the page 2 at X postion
    STA $4000                               ;reset the keyboard input to none
    INX                                     ;increment the X val to move the pixel in the "display" function
    JMP checkWinningCondition               ;jump to display function

leftDirection: 
    LDA $4000
    AND #LeftKey
    BEQ downDirection
    LDA #BgColor
    STA $0200, X
    STA $4000
    DEX
    JMP checkWinningCondition

downDirection: 
    LDA $4000
    AND #DownKey
    BEQ upDirection
    LDA #BgColor
    STA $0200, X
    STA $4000
    TXA                                 ;copy the X val to A register cause we can't use ADC on X register
    ADC #$10                            ;add $10 to A
    TAX                                 ;copy the A val to X register
    JMP checkWinningCondition

upDirection: 
    LDA $4000
    AND #UpKey
    BEQ display
    LDA #BgColor
    STA $0200, X
    STA $4000
    TXA
    SBC #$0F                            ;I don't know why i have to subctract 0F instead of 10 to make it works, with 10 it goes up and left
    TAX
    JMP checkWinningCondition

bulletsLogic:


checkWinningCondition:      
    LDA #EnemyCol                       ;load enemy color into the A register
    CMP $0200, X                        ;compare the color of the player position with the enemy color
    BEQ updateScore                     ;if equal (the player steps on enemy), go to updateScore function
    JMP display                         ;jump to display

updateScore:
    INY                                 ;increment Y val, we use it as score
    CPY #MaxScore                       ;compare the score with the maximum score val
    BEQ gameWon                         ;if equal go to gameWon function
    JMP display                         ;jump to display
    
    

display:
    CLC                                 ;I had to clear the carry flag cause it gave me problems with up and down movements
    
    LDA #$02                            ;load the color we want into A
    STA $0200, X                        ;load the A val into the page 2 at X position (which can be incremented or decremented with inputs)
    JMP gameLoop

gameWon:
    LDX #$00                                ;reset X val to $00 for the winningBackground's rendering
    JMP renderWinningBackGround              

JMP gameLoop

.goto $FFFC
.dw $8000
.dw $0000