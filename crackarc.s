;
; Electronc Arts Archon from original protected disk.
;
;
; Crack by Zibri (2020).
;
				.ORG  $CAFE             ; because coffee :D
start                           ; SYS 51966 to start

        LDA  #8
        TAX
        LDY  #1
        JSR  $FFBA           ; set file parameters ",8,1"
        LDA  #4              ; file lenght
        LDX  #<loader
        LDY  #>loader        ; >> filename 'EA"II'
        JSR  $FFBD           ; set filename parameters
        LDA  #0
        STA  $9D             ; do not show messages (LOADING...)
        JSR  $FFD5           ; load ram from device

; --- Patch original loader and run it

        LDX  #<SAVE
        STX  $C26D
        LDX  #>SAVE
        STX  $C26E

        LDY  #$60         ; RTS
        STY  $C0E7        ; remove delay
        STY  $C0D3        ; don't clear the screen
        
        JMP  $C000        ; jump to loader start :D

; --- We jump back here from original loader

SAVE
        LDA  #$FE
        STA  $D020
        JSR  $C336        ; restore screen color to $fe
        LDY  #0

LOOP
        LDA  MSG, Y
        JSR  $FFD2
        INY
        CPY  #15
        BNE  LOOP         ; print PRESS 8 or 9

        LDY  #0
LOOP2
        LDA  basic, y
        STA  $0801,y
        INY
        CPY  #$30
        BNE  LOOP2        ; fix BASIC line


LOOP3
        LDX  $C5          ; check $C5 for last key pressed
        CPX  #$40         ; if it is 64 then no key was pressed
        BEQ  LOOP3        ; wait for keypress
        CPX  #$1b
        BEQ  EIGHT
        CPX  #$20
        BNE  LOOP3
        INC  EIGHT+1      ; next line becomes LDA #9

EIGHT

        LDA  #8
        STA  $BA

        LDA  #$80
        STA  $9D          ; enable messages (to show "SAVING...")

        LDA  #10
        LDX  #<fname
        LDY  #>fname
        JSR  $FFBD        ; Set filename
        LDX  #1
        STX  $B8
        STX  $B9
        DEC  $1           ; Make RAM at $A000 visible.
        LDA  #$01
        STA  $2B
        LDA  #$08
        STA  $2C
        LDA  #$2B         ; zero-page index to the pointer
        LDX  #$00
        LDY  #$BD         ; Range $0801-$bcff ($ffd8 range excludes the end address)
        JSR  $FFD8
        INC  $1           ;   Make BASIC ROM at $A000 visible instead
        STA  $8004        ;   to be able to reboot...
        JMP  $FCE2


fname   .BYTE 'ARCHON.PRG',0
msg     .BYTE 13,'PRESS 8 OR 9.',13
basic   .BYTE $21, $8, $0 ,$0, $9e, $20, $32, $34, $38, $33, $32, $22, $d, $91, 'ZIBRI/RAMJAM 2020',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
loader  .BYTE 'EA"',$9D
