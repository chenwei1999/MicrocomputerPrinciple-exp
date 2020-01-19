INTR_IVADD	EQU 003CH  ;INTR��Ӧ���ж�ʸ����ַ
INTR_OCW1	EQU	021H   ;INTR��ӦPC���ڲ�8259��OCW1��ַ
INTR_OCW2	EQU	020H   ;INTR��ӦPC���ڲ�8259��OCW2��ַ
INTR_IM		EQU	07FH   ;INTR��Ӧ���ж�������
IOY0		EQU	0E000H ;ƬѡIOY0��Ӧ�Ķ˿�ʼ��ַ

MY8259_ICW1	EQU	IOY0+00H     ;ʵ��ϵͳ��8259��ICW1�˿ڵ�ַ
MY8259_ICW2	EQU	IOY0+04H     ;ʵ��ϵͳ��8259��ICW2�˿ڵ�ַ
MY8259_ICW3	EQU	IOY0+04H     ;ʵ��ϵͳ��8259��ICW3�˿ڵ�ַ
MY8259_ICW4	EQU	IOY0+04H     ;ʵ��ϵͳ��8259��ICW4�˿ڵ�ַ
MY8259_OCW1	EQU	IOY0+04H     ;ʵ��ϵͳ��8259��OCW1�˿ڵ�ַ
MY8259_OCW2	EQU	IOY0+00H     ;ʵ��ϵͳ��8259��OCW2�˿ڵ�ַ
MY8259_OCW3	EQU	IOY0+00H     ;ʵ��ϵͳ��8259��OCW3�˿ڵ�ַ

STACK1		SEGMENT	STACK
			DW	256	DUP(?)
STACK1		ENDS

DATA		SEGMENT
		MES		DB		'Press any key to exit!',0AH,0DH,0AH,0DH,'$'
		CS_BAK	DW	?          ;����INTRԭ�жϴ��������ڶε�ַ�ı���
		IP_BAK	DW	?          ;����INTRԭ�жϴ���������ƫ�Ƶ�ַ�ı���
		IM_BAK	DB	?          ;����INTRԭ�ж������ֵı���
DATA		ENDS

CODE		SEGMENT
		ASSUME CS:CODE, DS:DATA, SS:STACK1

START:
	MOV	AX, DATA
	MOV	DS, AX
	MOV	DX, OFFSET MES      ;��ʾ�˳���ʾ
	MOV	AH, 09H
	INT	21H
	
	CLI	
	MOV	AX, 0000H           ;�滻INTR���ж�ʸ��
	MOV ES, AX
	MOV	DI, INTR_IVADD      ;����INTRԭ�жϴ���������ƫ�Ƶ�ַ
	MOV AX, ES:[DI]         
	MOV	IP_BAK, AX
	MOV AX, OFFSET MYISR    ;���õ�ǰ�жϴ���������ƫ�Ƶ�ַ
	MOV ES:[DI], AX
	
	ADD DI, 2               ;����INTRԭ�жϴ��������ڶε�ַ
	MOV AX, ES:[DI]
	MOV CS_BAK, AX
	MOV AX, SEG MYISR       ;���õ�ǰ�жϴ��������ڶε�ַ
	MOV ES:[DI], AX
	
	MOV DX, INTR_OCW1      ;�����ж����μĴ�������INTR������λ
	IN	AL, DX             ;����INTRԭ�ж�������
	MOV	IM_BAK, AL
	
	AND AL, INTR_IM        ;����PC���ڲ�8259�� IR7 �ж�
	OUT DX, AL
	
	MOV DX, MY8259_ICW1   ;��ʼ��ʵ��ϵͳ��8259��ICW1
	MOV AL, 13H           ;���ش�������Ƭ8259 ����ҪICW4
	OUT DX, AL
	
	MOV DX, MY8259_ICW2   ;��ʼ��ʵ��ϵͳ��8259��ICW2
	MOV AL, 08H
	OUT DX, AL
	
	MOV DX, MY8259_ICW4   ;��ʼ��ʵ��ϵͳ��8259��ICW4
	MOV AL, 01H           ;���Զ�����EOI
	OUT DX, AL
	
	MOV DX, MY8259_OCW3   ;��8259��OCW3���Ͷ�ȡIRR����
	MOV AL, 0AH
	OUT DX, AL
	
	MOV DX, MY8259_OCW1   ;��ʼ��ʵ��ϵͳ��8259��OCW1
	MOV AL, 0FCH          ;��IR0��IR1������λ
	OUT DX, AL
	STI
	
WAIT1:
	MOV AH, 1             ;�ж��Ƿ��а�������
	INT 16H               ;�ް��������ؼ����ȴ��������˳�
	JZ	WAIT1
	
QUIT:
	CLI
	MOV AX, 0000H         ;�ָ�INTRԭ�ж�ʸ��
	MOV ES, AX
	MOV DI, INTR_IVADD    ;�ָ�INTRԭ�жϴ���������ƫ�Ƶ�ַ
	MOV AX, IP_BAK
	MOV ES:[DI], AX
	
	ADD DI,2
	MOV AX, CS_BAK     ;�ָ�INTRԭ�жϴ��������ڶε�ַ
	MOV ES:[DI], AX
	MOV DX, INTR_OCW1
	MOV AL, IM_BAK    ;�ָ�INTRԭ�ж����μĴ�����������
	OUT DX, AL
	STI
	MOV AX, 4C00H     ;���ص� DOS
	INT 21H

MYISR PROC NEAR         ;�жϴ������MYISR
	PUSH AX
QUERY:                  ;��8259��OCW3���Ͷ�ȡIRR ����
	MOV DX, MY8259_OCW3
	IN	AL, DX          ;����IRR�Ĵ���ֵ
	
	AND AL, 03H
	CMP AL, 01H
	JE	IR0ISR        ;��ΪIR0��������IR0�������
	JNE IR1ISR        ;��ΪIR1��������IR1�������
	JMP OVER

IR0ISR:               ;IR0������ʾ�ַ���STR0
	MOV AL, 30H
	MOV AH, 0EH
	INT 10H
	MOV AL, 20H
	INT 10H
	JMP OVER

IR1ISR:            ;IR1������ʾ�ַ���STR1
	MOV AL, 31H
	MOV AH, 0EH
	INT 10H
	MOV AL, 20H
	INT 10H
	JMP OVER
	
OVER:
	MOV DX, INTR_OCW2    ;��PC���ڲ�8259�����жϽ�������
	MOV AL, 20H
	OUT DX, AL
	MOV AL, 20H
	OUT 20H, AL
	POP AX
	
	IRET

MYISR ENDP

CODE		ENDS
END START 

 
