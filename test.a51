            ORG 0000H
            RS BIT 0x96     ; P2.6
            EN BIT 0x97     ; P2.7
            RW BIT 0x94     ; P2.4
   SETB P3.2
   SETB IT0
   SETB EX0
   SETB EA

IPMSG:      DB "Select 5 DIGITS", 0
TEXT_S:     DB "DOOR OPENED", 0
TEXT_F:     DB "WRONG PASSWORD", 0
PASSW:      DB "12345", 0     ; ���T�K�X
USERIN:     DS 5              ; �Ψ��x�s��J�r���]30H~34H�^

START:      
            SJMP MAIN_LOOP

MAIN_LOOP:
            ACALL LCD_INIT
            MOV DPTR, #IPMSG
            ACALL LCD_PRINT_LINE1   ; ��ܴ��ܤ�r
            MOV R0, #30H        ; ��J���ƭp�ƾ�
            MOV R2, #'0'        ; �`���r���q '0' �}�l
   SJMP INPUT_LOOP

INPUT_LOOP:
    ACALL SET_CURSOR_LINE2
    MOV A, R2
    ACALL LDAT
    ACALL DELAY_2S
    ACALL NEXT_CHAR_ROUTINE
    MOV A, 25H
    JZ INPUT_LOOP

    CLR 25H
	SETB IT0
    ACALL CHECK_PASSWORD
	
    SJMP MAIN_LOOP

; -------------------------------
; �K�X���
; -------------------------------
CHECK_PASSWORD:
    MOV R3, #0              ; ���� i = 0
    MOV DPTR, #PASSW        ; ���V�K�X�`��

CHK_LOOP:
    MOV A, R3
    ADD A, #30H
    MOV R0, A
    MOV A, @R0              ; ���X�ϥΪ̿�J USERIN[i]
    MOV 40H, A              ; �s�� RAM 40H �Ȧs

    ; ���X�����K�X PASSW[i]
    MOV A, R3
    MOVC A, @A+DPTR         ; �� ROM ���K�X
    CJNE A, 40H, WRONG      ; �M�ϥΪ̿�J���

    INC R3
    CJNE R3, #5, CHK_LOOP

    SJMP CORRECT

CORRECT:
            ACALL LCD_CLR
            MOV DPTR, #TEXT_S
            ACALL LCD_PRINT_LINE1
   ACALL DELAY_2S
            SJMP MAIN_LOOP

WRONG:
            ACALL LCD_CLR
            MOV DPTR, #TEXT_F
            ACALL LCD_PRINT_LINE1
            ACALL DELAY_2S
            SJMP MAIN_LOOP

; -------------------------------
; LCD ��l�P����
; -------------------------------
LCD_INIT:
            MOV A, #38H
            ACALL LCMD
            MOV A, #0CH
            ACALL LCMD
            MOV A, #06H
            ACALL LCMD
            MOV A, #01H
            ACALL LCMD
            MOV A, #02H
            ACALL LCMD
            RET

LCD_CLR:
            MOV A, #01H
            ACALL LCMD
            RET

LCD_PRINT_LINE1:
            ACALL SET_CURSOR_LINE1
LCD_PRINT:
            CLR A
            MOVC A, @A+DPTR
            JZ DONE_PRINT
            ACALL LDAT
            INC DPTR
            SJMP LCD_PRINT
DONE_PRINT:
            RET

SET_CURSOR_LINE1:
            MOV A, #80H
            ACALL LCMD
            RET

SET_CURSOR_LINE2:
            MOV A, #0C0H
            ACALL LCMD
            RET

LDAT:
            MOV P0, A
            SETB RS
            CLR RW
            SETB EN
            ACALL DELAY
            CLR EN
            RET

LCMD:
            MOV P0, A
            CLR RS
            CLR RW
            SETB EN
            ACALL DELAY
            CLR EN
            RET

; -------------------------------
; �U�@�Ӧr�� '0'~'9','A'~'F' �`��
; -------------------------------
NEXT_CHAR_ROUTINE:
            INC R2
            CJNE R2, #'9'+1, AF_CHECK  ; ���� AF_CHECK �ˬd�O�_�W�L 'F'
            MOV R2, #'A'
            SJMP DONE_NEXT

AF_CHECK:
            CJNE R2, #'F'+1, DONE_NEXT ; �ˬd�O�_�W�L 'F'
            MOV R2, #'0'              ; �Y�W�L�A�^�� '0'

DONE_NEXT:
            RET

; -------------------------------
; ����Ƶ{��
; -------------------------------
DELAY_2S:
            ACALL DELAY
            ACALL DELAY
            ACALL DELAY
            ACALL DELAY
            RET

DELAY:
            MOV R7, #255
D1:         MOV R6, #255
D2:         DJNZ R6, D2
            DJNZ R7, D1
            RET

INT0_ISR:
            SETB 25H 
            AJMP INPUT_LOOP
   END