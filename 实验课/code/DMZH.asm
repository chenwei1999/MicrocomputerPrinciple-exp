CRLF MACRO
    MOV  DL, 0DH
    MOV  AH, 02H
    INT  21H
    MOV DL, 0AH 
    MOV AH, 02H
    INT 21H
    ENDM

DATA SEGMENT
MES1    DB 'PLEASE INPUT THE SMALL LETTER,ENDED WITH ".":$'
MES2    DB 'THE CAPTAL LETTER IS:$'
SMALL   DB 50   ;Ԥ���������뻺��������Ϊ 50 ��
        DB 0    ;Ԥ��ʵ�ʼ��������ַ����ĸ���         
        DB 50 DUP(0)
CAPITAL DB 50 DUP(0)   ;Ԥ����д��ĸ����������Ϊ 50 ��
DATA ENDS


STACK1 SEGMENT STACK
        DB 100 DUP (0)
STACK1 ENDS

CODE    SEGMENT
        ASSUME CS:CODE,DS:DATA,SS:STACK1
START   PROC    FAR
        PUSH    DS
        MOV     AX, 0
        PUSH    AX
        MOV     AX, DATA
        MOV     DS, AX
        MOV     AH, 9
        MOV     DX, OFFSET MES1 ;�����ʾ��ϢMES1
        INT     21H
        CRLF

        MOV     AH, 0AH
        LEA     DX, SMALL;����Сд�ַ���
        INT 21H
        CRLF                    ;�����
        
       
        LEA		BX,	 SMALL+2
        LEA		DI,	 CAPITAL
        MOV		CX,	 20           ;���20���ַ�
 LAB:   MOV		AL,  [BX]
        CMP		AL,	 2EH          ;�Ƿ��������.
        JE		KE 
        SUB		AL,	 20H          ;תΪ��д,ASCLL-20H
        MOV		[DI], AL
        INC		BX
        INC		DI
        LOOP	LAB

KE:     MOV     AL, '$'              ;��д�ַ�����ӡ�$��
        MOV     [DI], AL
        MOV     DX, OFFSET MES2 ; �����ʾ��ϢMES2
        MOV     AH, 9
        INT     21H
        CRLF

        MOV DX, OFFSET CAPITAL
        MOV AH, 9 ; ����д�ַ���
        INT 21H
        RET
START ENDP
CODE ENDS
        END START

