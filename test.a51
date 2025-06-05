            ORG 0000H

            RS BIT 0x96     ; P2.6
            EN BIT 0x97     ; P2.7
            RW BIT 0x94     ; P2.4

IPMSG:      DB "Select 5 DIGITS", 0
TEXT_S:     DB "DOOR OPENED", 0
TEXT_F:     DB "WRONG PASSWORD", 0
PASSW:      DB "12345", 0     ; ���T�K�X
USERIN:     DS 5              ; �Ψ��x�s��J�r���]30H~34H�^

START:      
            ACALL LCD_INIT 
            MOV DPTR, #IPMSG
            ACALL LCD_PRINT_LINE1   ; ��ܴ��ܤ�r

MAIN_LOOP:
            MOV R0, #00H        ; ��J���ƭp�ƾ�
            MOV R1, #'0'        ; �`���r���q '0' �}�l

INPUT_LOOP:
            ; ��ܥثe�`���r���b LCD �ĤG��
            ACALL SET_CURSOR_LINE2

            ; ��X�w��J���r�� (USERIN �Ϭq 30h �}�l)
            MOV R0, #30h        ; R0 ���V USERIN[0]
DisplayLoop:
            MOV A, @R0          ; �N USERIN[R0-30h] ����Ū�J�֥[��
            JZ DoneDisplay      ; �Y�ӳB�L�r�š]0�^�A�h������ܤw��J�r��
            ACALL LDAT      ; ��X�֥[�������r�Ũ� LCD
            INC R0
            SJMP DisplayLoop
DoneDisplay:
            ; ��X�@�ӪŮ��A�A��X��e���`���r�� R1
            MOV A, #' '        ; �Ů�r��
            ACALL LDAT
            MOV A, R1          ; ��e�Կ�r��
            ACALL LDAT

            ACALL DELAY_2S      ; �� 0.5 ��

            ; �ˬd�O�_���U P3.2
            JB P3.2, NEXT_CHAR

            ; �Y���U�A�x�s�ثe�r��
            MOV A, R0
            ADD A, #30H
            MOV R1, A           ; �p���x�s�a�}
            MOV A, R1
            MOV @R1, A

            INC R0              ; �W�[��J�r���p��
            CJNE R0, #5, NEXT_CHAR

            ; �w��J 5 �r���A�i������
            ACALL CHECK_PASSWORD

NEXT_CHAR:
            ACALL NEXT_CHAR_ROUTINE
            SJMP INPUT_LOOP

; -------------------------------
; �K�X���
; -------------------------------
CHECK_PASSWORD:
    MOV R0, #0              ; ���� i = 0
    MOV DPTR, #PASSW        ; ���V�K�X�`��

CHK_LOOP:
    ; A = 30H + R0�]���� USERIN[i]�^
    MOV A, R0
    ADD A, #30H
    MOV R1, A
    MOV A, @R1              ; ���X�ϥΪ̿�J USERIN[i]
    MOV 40H, A              ; �s�� RAM 40H �Ȧs

    ; ���X�����K�X PASSW[i]
    MOV A, R0
    MOVC A, @A+DPTR         ; �� ROM ���K�X
    CJNE A, 40H, WRONG      ; �M�ϥΪ̿�J���

    INC R0
    CJNE R0, #5, CHK_LOOP

    SJMP CORRECT

CORRECT:
            ACALL LCD_CLR
            MOV DPTR, #TEXT_S
            ACALL LCD_PRINT_LINE1
            SJMP $

WRONG:
            ACALL LCD_CLR
            MOV DPTR, #TEXT_F
            ACALL LCD_PRINT_LINE1
            ACALL DELAY_2S
            AJMP START

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
            INC R1
            CJNE R1, #'9'+1, AF_CHECK  ; ���� AF_CHECK �ˬd�O�_�W�L 'F'
            MOV R1, #'A'
            SJMP DONE_NEXT

AF_CHECK:
            CJNE R1, #'F'+1, DONE_NEXT ; �ˬd�O�_�W�L 'F'
            MOV R1, #'0'              ; �Y�W�L�A�^�� '0'

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

            END