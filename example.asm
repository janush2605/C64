!source "loader.asm"
!source "spriteUtils.asm"
!source "vicUtils.asm"

+start_at 32768

SPRITE0X = 53248
SPRITE0Y = 53249
SPRITE1X = 53250
SPRITE1Y = 53251
SPRITE2X = 53252
SPRITE2Y = 53253

SPRITEDATA = 0
SPRITENRTOLOAD = 0

IRQROUT = $EA31
IRQVEC  = $314

NUMBER  = 1 ; EVERY 1/60SECOND

+clearScreen

+showSprite 0
+showSprite 1
+showSprite 2

+setSpriteBlockAddress 2040,255
+setSpriteBlockAddress 2041,254
+setSpriteBlockAddress 2042,253

+loadSpriteData sprite0Block, planeToRight
+loadSpriteData sprite1Block, sprite1
+loadSpriteData sprite2Block, sprite2
+setSpritePosition 0, 140, 140
+setSpritePosition 1, 150, 150
+setSpritePosition 2, 160, 160

;looop inc bgcol
;	  jmp looop

; =======================================================
; USE IRQ TO RENDER SCREEN WITH 60 Hz
; =======================================================
INIT  SEI
      LDA #<BLINK
      LDY #>BLINK
      LDX #0
      STA IRQVEC
      STY IRQVEC+1
      CLI
      RTS
;
BLINK DEC COUNT
      BNE MAINLOOP
      LDA #NUMBER
      STA COUNT ; RESET COUNTER
; ====================================================
; MAIN LOOP WORK HERE
; ====================================================
         INC SPRITE1X ; MOVE SPRITE 0 WITH X                          
         INC SPRITE1Y
         DEC SPRITE2X 
         INC SPRITE2Y

         JSR djrr ; CHECK JOY

         LDX dx
         STX 1024
         LDY dy
         STY 1025
         JMP MOVESPRITEBYJOY
COLISION JMP CHECKCOLISION

MAINLOOP  JMP IRQROUT
EXIT    RTS

; ===============================================
; MOVES SPRITE2 BY JOY
; ===============================================

MOVESPRITEBYJOY CPX #$FF
                BEQ MOVESPRITE2LEFT
JOYRIGHT        CPX #01
                BEQ MOVESPRITE2RIGHT
JOYRUP          CPY #$FF
                BEQ MOVESPRITE2UP
JOYDOWN         CPY #$01
                BEQ MOVESPRITE2DOWN               
                JMP COLISION
                
MOVESPRITE2LEFT         DEC SPRITE0X
						;+loadSpriteData sprite0Block, planeToLeft
                        JMP JOYRIGHT

MOVESPRITE2RIGHT        INC SPRITE0X
                        ;+loadSpriteData sprite0Block, planeToRight
                        JMP JOYRUP

MOVESPRITE2UP           DEC SPRITE0Y
                        JMP JOYDOWN

MOVESPRITE2DOWN         INC SPRITE0Y
                        JMP COLISION

;
COUNT !BYTE 30

; ==================================================
; JOYSTICK CHECKER
; RESULTS: dx AND dy IN RANGE -1, 0, 1
; ==================================================

dx !byte 0
dy !byte 0

djrr    lda $dc00     ; get input from port 2 only
djrrb   ldy #0        ; this routine reads and decodes the
        ldx #0        ; joystick/firebutton input data in
        lsr           ; the accumulator. this least significant
        bcs djr0      ; 5 bits contain the switch closure
        dey           ; information. if a switch is closed then it
djr0    lsr           ; produces a zero bit. if a switch is open then
        bcs djr1      ; it produces a one bit. The joystick dir-
        iny           ; ections are right, left, forward, backward
djr1    lsr           ; bit3=right, bit2=left, bit1=backward,
        bcs djr2      ; bit0=forward and bit4=fire button.
        dex           ; at rts time dx and dy contain 2's compliment
djr2    lsr           ; direction numbers i.e. $ff=-1, $00=0, $01=1.
        bcs djr3      ; dx=1 (move right), dx=-1 (move left),
        inx           ; dx=0 (no x change). dy=-1 (move up screen),
djr3    lsr           ; dy=0 (move down screen), dy=0 (no y change).
        stx dx        ; the forward joystick position corresponds
        sty dy        ; to move up the screen and the backward
        rts           ; position to move down screen.
                      ;
                      ; at rts time the carry flag contains the fire
                      ; button state. if c=1 then button not pressed.
                      ; if c=0 then pressed.

; ===================================================
; KEYBOARD 
; USE KEYS FOR MOVEMENT  
; P - MOVE UP
; ; - MOVE DOWN
; L - MOVE LEFT
; ' - MOVE RIGHT
; ===================================================
MOVESPRITE2FROMKEYBOARD     LDX 197 ; LOAD KEY FROM KEYBOARD
                            STX 1024 ; DISPLAY IT
                            CPX #50
                            BEQ MOVESPRITE2RIGHTKEY
                            CPX #41
                            BEQ MOVESPRITE2UPKEY               
                            CPX #42
                            BEQ MOVESPRITE2LEFTKEY
                            CPX #45
                            BEQ MOVESPRITE2DOWNKEY
                            JMP MAINLOOP

MOVESPRITE2LEFTKEY      DEC SPRITE2X
                        JMP MAINLOOP

MOVESPRITE2RIGHTKEY     INC SPRITE2X
                        JMP MAINLOOP

MOVESPRITE2UPKEY        DEC SPRITE2Y
                        JMP MAINLOOP

MOVESPRITE2DOWNKEY      INC SPRITE2Y
                        JMP MAINLOOP

; =====================================================
; SPRITES COLISIONS
; =====================================================
CHECKCOLISION   LDA $D01E ;Read hardware sprite/sprite collision
                STA 1026               
                CMP #0 
                BNE HIT
                JMP MAINLOOP
HIT             INC $D020 
                JMP MAINLOOP
                
; sprite repository

planeToRight !byte 0,0,0,0,16,0,0,16
 !byte 0,0,16,0,0,56,0,1
 !byte 125,0,1,255,0,9,255,64
 !byte 11,255,192,15,255,192,143,255
 !byte 226,159,255,242,191,255,250,255
 !byte 255,254,255,255,254,0,16,0
 !byte 0,48,0,0,112,0,0,112
 !byte 0,0,0,0,0,0,0,0
 
planeToLeft !byte 0,0,0,0,8,0,0,8
 !byte 0,0,8,0,0,28,0,0
 !byte 190,128,0,255,128,2,255,144
 !byte 3,255,208,3,255,240,71,255
 !byte 241,79,255,249,95,255,253,127
 !byte 255,255,127,255,255,0,8,0
 !byte 0,12,0,0,14,0,0,14
 !byte 0,0,0,0,0,0,0,0
 
 ; 
sprite1 !BYTE 0,0,0,223,93,118,64,0
 !BYTE 2,80,0,18,11,250,90,72
 !BYTE 0,10,8,53,170,72,64,42
 !BYTE 8,64,42,72,78,42,8,78
 !BYTE 42,72,64,106,72,33,206,72
 !BYTE 58,4,72,0,2,75,101,95
 !BYTE 76,0,2,64,0,2,64,0
 !BYTE 2,109,255,254,0,0,0,0
 
sprite2 !BYTE 3,0,0,15,254,0,56,3
 !BYTE 224,96,0,62,192,0,3,135
 !BYTE 192,1,132,112,1,136,30,1
 !BYTE 136,1,193,144,24,97,176,78
 !BYTE 49,160,66,17,160,82,49,144
 !BYTE 98,33,152,54,33,134,28,97
 !BYTE 129,128,66,128,113,134,64,15
 !BYTE 12,56,0,120,15,247,192,3