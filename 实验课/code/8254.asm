IOY0	EQU	0E000H
TIMER0	EQU	IOY0+00H*4   ;8254������0�˿ڵ�ַ
TIMER1	EQU	IOY0+01H*4   ;8254������1�˿ڵ�ַ
TIMER2	EQU	IOY0+02H*4   ;8254������2�˿ڵ�ַ
TCTL	EQU IOY0+03H*4   ;8254���ƼĴ����˿ڵ�ַ

STACK1	SEGMENT STACK
		DW	256 DUP(?)
STACK1	ENDS

DATA	SEGMENT
		MES0	DB	'Pressed: $'
		MES1	DB	'Press any key to exit!', 0DH, 0AH, '$'
		NUM		DB	?
DATA	ENDS

CODE	SEGMENT
		ASSUME	CS:CODE, DS:DATA, SS:STACK1
START:	MOV	AX, DATA
		MOV	DS, AX
		
		MOV	DX, OFFSET MES1
		MOV	AH, 9
		INT	21H
		
		MOV	DX, TCTL               ;�����֣�ѡ�ü�����0��д16λֵ,��ʽ3,�����Ƽ���
		MOV	AL, 00110110B
		OUT	DX, AL
		
		MOV	DX, TIMER0             ;д��4800H
		MOV	AL, 00H
		OUT	DX, AL
		MOV	AL, 48H
		OUT	DX, AL
		
		MOV	DX, TCTL               ;�����֣�ѡ�ü�����1��д���ֽ�,��ʽ2,�����Ƽ���
		MOV	AL, 01010100B
		OUT	DX, AL
		
		MOV	DX, TIMER1             ;д��04H
		MOV	AL, 04H
		OUT	DX, AL
		
		MOV	DX, TCTL              ;�����֣�ѡ�ü�����2��д���ֽ�,��ʽ0,�����Ƽ���
		MOV	AL, 10010000B
		OUT	DX, AL
		
		MOV	DX, TIMER2
		MOV	AL, 0FH
		OUT	DX, AL


L1:		MOV	DX, TIMER2            ;���������2ֵ����
		IN	AL, DX
		MOV	NUM, AL
		CALL	DISP
		
		MOV	AL, NUM
		CMP	AL, 0
		JZ QUIT                   ;������0ʱ�˳�
		
		MOV	DL, 0FFH              ;�����������޼�����
		MOV	AH, 6
		INT	21H
		JZ	L1                    ;�޼�������ת

QUIT:	MOV	AX, 4C00H             ;���������˳�
		INT 21H

DISP	PROC                      ;��ʾ�ӳ���
		MOV	DX, OFFSET MES0       ;��ʾMES0
		MOV	AH, 9
		INT	21H
		
		MOV	AL, NUM
		CMP	AL, 9                ;�ж��Ƿ�<=9
		JLE	L2                   ;������Ϊ'0'-'9',ASCII���30H
		ADD	AL, 7                ;����Ϊ' A'-'F',ASCII���37H

L2:		ADD	AL, 30H              ;����ʾ������ʾ��ѹ���صĴ���
		MOV	DL, AL
		MOV	AH, 2
		INT	21H
		MOV	DL, 0DH
		INT	21H
		
		RET

DISP	ENDP		
		
CODE	ENDS
		END		START