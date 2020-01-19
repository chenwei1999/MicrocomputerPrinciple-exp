;-----ADC0809�˿ڵ�ַ-----
IOY0 	    EQU 	0E000H
ADCIN0 	    EQU 	IOY0+00H 	;ADC0809�˿ڵ�ַ(IN0ͨ��)
ADCIN1 	    EQU 	IOY0+04H 	;ADC0809�˿ڵ�ַ(IN1ͨ��)


;-----DAC0832�˿ڵ�ַ-----
IOY1 	    EQU 	0E040H
DAC 	    EQU 	IOY1 		;DAC0832�˿ڵ�ַ
    

;------8255 �˿ڵ�ַ------
IOY2		EQU 	0E080H
PORTA_8255	EQU 	IOY2+20H 	;8255 A�ڵ�ַ
PORTB_8255	EQU 	IOY2+24H 	;8255 B�ڵ�ַ
PORTC_8255	EQU 	IOY2+28H 	;8255 C�ڵ�ַ
CTRL_8255 	EQU 	IOY2+2CH	;8255 ���ƿڵ�ַ


;------8259 �˿ڵ�ַ------
INTR_IVADD 	EQU 	003CH 		;INTR��Ӧ���ж�ʸ����ַ
INTR_OCW1 	EQU 	020H 		;INTR��Ӧ��PC���ڲ�8259��OCW1��ַ
INTR_OCW2 	EQU 	021H 		;INTR��Ӧ��PC���ڲ�8259��OCW2��ַ
INTR_IM 	EQU 	07FH 		;�޸�INTR��Ӧ���ж�������(0FBH = 11111011B)
IOY3 		EQU 	0E0C0H		;8259	�˿ڵ�ַ
ICW1_8259 	EQU 	IOY3+00H 	;8259	ICW1�˿ڵ�ַ
ICW2_8259 	EQU 	IOY3+04H 	;8259	ICW2�˿ڵ�ַ
ICW3_8259 	EQU 	IOY3+04H 	;8259	ICW3�˿ڵ�ַ
ICW4_8259 	EQU 	IOY3+04H 	;8259	ICW4�˿ڵ�ַ
OCW1_8259 	EQU 	IOY3+04H 	;8259	OCW1�˿ڵ�ַ
OCW2_8259 	EQU 	IOY3+00H 	;8259	OCW2�˿ڵ�ַ
OCW3_8259 	EQU 	IOY3+00H 	;8259	OCW3�˿ڵ�ַ

;-------------------------------------------------
STACK1 	SEGMENT STACK
	DW 256 	DUP(0)
STACK1 	ENDS

DATA SEGMENT
FLAG 		DB 		0 		;��־λ
IN0_MEM 	DB 		0 		;���ڱ���IN0ֵ
IN1_MEM 	DB 		0 		;���ڱ���IN1ֵ
W_NUM    	DB     	0
W_TIME     	DB     	0

NUM_02 		DB 		02H 	;ת��ʱ�ĳ���Ϊ2
NUM_80H 	DB 		0			
NUM_51 		DB 		33H 	;�������51D
NUM_10 		DB 		0AH 	;�������10D
RESULT 		DB 		6 DUP(0) ;��ʮ���ƽ��(����Ϊ��λ|ʮ��λ|�ٷ�λ|ǧ��λ|���λ)

MES0 		DB 		'**********************************************',0DH,0AH
			DB 		'*-----------Data Collection System-----------*',0DH,0AH
			DB 		'******   Design by 161710207 zoumengyu  ******',0DH,0AH
			DB 		'******   Design by 161710223 chenwei    ******',0DH,0AH,'$'
MES1 		DB 		'*--------------------------------------------*',0DH,0AH,'$'
MES2 		DB 		' IN0 = $'
MES3 		DB 		' IN1 = $'
MES_VALUE	DB		'Voltage =$'
SEG_LED_TABLE 	DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07H,7Fh,6Fh ;����ܵĶ����

CS_BAK 		DW 		0 		;���ԭ�жϴ��������ڶε�ַ
IP_BAK 		DW 		0 		;���ԭ�жϴ���������ƫ�Ƶ�ַ
IM_BAK 		DB 		0 		;���ԭ�ж������ֵı���

DATA ENDS

CODE 	SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STACK1
START:	MOV 	AX,DATA
		MOV 	DS,AX
		MOV 	DX,OFFSET MES0       ;��ʾ��ʾ��Ϣ
		MOV 	AH,9
		INT 	21H
		MOV 	DX,OFFSET MES1       ;��ʾ��ʾ��Ϣ
		MOV 	AH,9
		INT 	21H
		
		CLI
		MOV 	AX,0000H
		MOV 	ES,AX
		MOV 	DI,INTR_IVADD
		MOV 	AX,ES:[DI]
		MOV 	IP_BAK,AX 			;����ԭ�ж����ƫ�Ƶ�ַ(����IP_BAK)
		MOV 	AX,OFFSET MYINT 	;�����µ��ж����ƫ�Ƶ�ַ
		MOV 	ES:[DI],AX
		ADD 	DI,2
		MOV 	AX,ES:[DI]
		MOV 	CS_BAK,AX 			;����ԭ�ж���ڶε�ַ(����CS_BAK)
		MOV 	AX,SEG MYINT 		;�����µ��ж���ڶε�ַ
		MOV 	ES:[DI],AX
		MOV 	DX,INTR_OCW1	
		IN 		AL,DX				;��ȡԭ�ж�������
		MOV 	IM_BAK,AL 			;����ԭ�ж�������
		AND 	AL,INTR_IM 			;����PC���ڲ� 8259�� IR7�ж�
		OUT 	DX,AL
		
		;---------ʵ��ϵͳ��8259��ʼ��---------
		MOV 	DX,ICW1_8259 	;ICW1��ַ
		MOV 	AL,13H	 		;���ش���,��Ƭ,��ҪICW4(00010011B = 13H)
		OUT 	DX,AL
		MOV 	DX,ICW2_8259	;ICW2��ַ
		MOV 	AL,08H			;�ж�������
		OUT 	DX,AL
		MOV 	DX,ICW4_8259	;ICW4��ַ
		MOV 	AL,01H	        ;��ͨȫǶ��,�ǻ���,����EOI,8086ģʽ(00000001B = 01H)
		OUT 	DX,AL
		MOV 	DX,OCW3_8259	;OCW3��ַ
		MOV 	AL,0AH			;��һ��RD��IRR 
		OUT 	DX,AL
		MOV 	DX,OCW1_8259	;OCW1��ַ
		MOV 	AL,0FEH 		;��IR0 (11111110B) 
		OUT 	DX,AL
		STI


MAIN: 	MOV 	DX,ADCIN0 		;����0809IN0
		OUT 	DX,AL 			;����ת��, AL��Ϊ����ֵ
		MOV 	FLAG,0FFH		;FLAG����ΪFFH
		CALL 	TRANS 			;����TRANS�ӳ���, ִ��IN0������ת��, ת��Ϊ10�������ֲ�����RESULT
		CALL 	DISPAY 			;�����������ʾ�ӳ���DISPLAY, ��ʾIN0��ʮ���Ƶ�ѹֵ
		
		;-----------��Ļ��ʾIN0��ֵ-----------
		MOV 	DX,OFFSET MES2 	;��Ļ��ʾ��ʾ��ϢMES2
		MOV 	AH,9
		INT 	21H
		MOV 	AL,IN0_MEM 		;��IN0_MEM�ж�����ֵ
		MOV 	BL,AL			;�ݴ���BL��
		AND 	AL,0F0H			;���ε���λ, �ȴ������λ����	
		MOV 	CL,4
		ROR 	AL,CL			;������λ�ƶ�������λ
		CALL 	CRT_DISPLAY		;����CRT_DISPLAY�ӳ���, ��ʾ���Ӧ��ʮ������
		MOV 	AL,BL			
		AND 	AL,0FH			;���θ���λ
		CALL 	CRT_DISPLAY		;����CRT_DISPLAY�ӳ���, ��ʾ���Ӧ��ʮ������
		CALL 	DELAY     
		
		;-----------��Ļ��ʾIN1��ֵ-----------  
		
		MOV 	DX,OFFSET MES3 	;��ʾ��ʾ��Ϣ
		MOV 	AH,9
		INT 	21H
		MOV 	AL,IN1_MEM 		;��IN1_MEM�ж�����ֵ
		MOV 	BL,AL			;�ݴ���BL��
		AND 	AL,0F0H			;���ε���λ, �ȴ������λ����
		MOV 	CL,4
		ROR 	AL,CL			;������λ�ƶ�������λ
		CALL	CRT_DISPLAY		;����CRT_DISPLAY�ӳ���, ��ʾ���Ӧ��ʮ������
		MOV 	AL,BL
		AND 	AL,0FH			;���θ���λ
		CALL	CRT_DISPLAY		;����CRT_DISPLAY�ӳ���, ��ʾ���Ӧ��ʮ������
		MOV 	DL,0DH			;�س�
		INT 	21H
		CALL	DELAY
		
	;���� ����2.5V����			
		MOV		SI,OFFSET RESULT
		MOV 	AL,[SI];ȡ��λ��
		CMP 	AL,02H
		JB 		WARNNING0
		JA      WARNNING
		INC 	SI
		MOV 	AL,[SI]
		CMP 	AL,05H
		JAE 	WARNNING
	WARNNING0:
		MOV 	DX,PORTC_8255
		MOV 	AL,00000000B     ;ʹPC0��PC7Ϊ0
		OUT 	DX,AL
		JMP 	LAB2
	WARNNING:
		MOV     CX,5
		MOV 	DX,PORTC_8255
    BELL:
        MOV 	AL,00000001B    ;PC0��С�ƣ���ʱ��1��PC7��0
		OUT 	DX,AL
		NOP
		NOP
	    MOV 	AL,10000001B    ;PC0��С�ƣ���ʱ��1��PC7��1���γɷ�����PC7�ӷ�����
		OUT 	DX,AL
		LOOP    BELL

		;---------��Ļ��ʾʮ���Ƶ�ѹֵ(0~5V)------
LAB2:	MOV		DX , OFFSET MES_VALUE	;��ʾ��ʾ��Ϣ
		MOV		AH , 9
		INT		21H
		MOV		SI , OFFSET RESULT
		MOV		CX , 5			;�Ӹ�λ��ʮ���λ, ��Ҫѭ����ʾ5��
		MOV		AL , [SI]		;��ʾ��λ����
        
LN5:    CALL	CRT_DISPLAY
		MOV		DL , '.'		;��ʾС����
		MOV		AH , 2
		INT		21H
		
DIS_LP:	INC		SI				;ѭ���Ĵ�, ��ʾ��ʮ��λ�����λ���ĸ�����
		MOV		AL , [SI]
		CALL	CRT_DISPLAY
		LOOP	DIS_LP
		MOV		DL , 'V'		;��ʾ��λ(V)
		MOV		AH , 2
		INT		21H
		MOV		DL , ' '		;��ʾ�ո�
		MOV		AH , 2
		INT		21H
		
		MOV 	DL,0FFH 		;�ж��Ƿ��м�����
		MOV 	AH,6
		INT 	21H
		JZ 		L2020			;ѭ��,�ص�MAIN����ִ��
		JMP 	QUIT
L2020:	JMP 	MAIN
	
	
QUIT: 	CLI						;�˳�����
		MOV 	AX,0000H
		MOV 	ES,AX
		MOV 	DI,INTR_IVADD
		MOV 	AX,IP_BAK
		MOV 	ES:[DI],AX		;�ָ�ԭ�ȵ�IP
		ADD 	DI,2
		MOV 	AX,CS_BAK		;�ָ�ԭ�ȵ�CS
		MOV 	ES:[DI],AX
		MOV 	DX,INTR_OCW1
		MOV 	AL,IM_BAK		;�ָ�ԭ�ȵ��ж�������
		OUT 	DX,AL
		STI	
		MOV 	AX,4C00H 		;���� DOS
		INT 	21H

MYINT 	PROC 	NEAR 			;�жϷ������
		PUSH 	AX				;�����ϵ�
		PUSH 	CX
		PUSH 	DX
		CLI
		MOV 	AL,FLAG
		CMP 	AL,0FFH			
		JE 		BRANCH_1		;FLAG == FFH ʱ, ��ת��BRANCH_1

		MOV 	AL,00H			;FLAG != FFH ʱ, ��ȡIN1������
		MOV 	DX,ADCIN1 		;�� IN1 ��ֵ
		IN 		AL,DX
		MOV 	IN1_MEM,AL 		;���� IN1 , �����IN1_MEM
		JMP 	INT_END			;��ת���жϷ�������ĩβ

BRANCH_1: 	
		MOV 	DX,ADCIN0 		
		IN 		AL,DX			;�� IN0 ��ֵ
		MOV 	IN0_MEM,AL		;���� IN0 , �����IN0_MEM
		
			;-----------����ת��-----------------   ;y=-128/255x+128
		AND 	AX,00FFH		;���θ���λ
		DIV 	NUM_02 			;����2
		MOV 	NUM_80H,80H
		SUB 	NUM_80H,AL		;��80H��ȥAL, ��������ת��
		MOV 	AL,NUM_80H	
		MOV 	DX,DAC 			;����0832���
		OUT 	DX,AL
		MOV 	DX,ADCIN1 		;����0809��IN1������һ��ת��
		OUT 	DX,AL
		MOV 	FLAG,0			;FLGA��Ϊ0

INT_END: 
        MOV 	DX,INTR_OCW2 	;��PC���ڲ�8259�����жϽ�������
		MOV 	AL,20H
		OUT 	DX,AL
		MOV 	AL,20H
		OUT 	20H,AL
		POP 	DX				;�ָ��ϵ�
		POP 	CX
		POP 	AX
		STI	
		IRET
MYINT ENDP


DISPAY PROC 		;�������ʾ����
		PUSH 	AX
		MOV 	BX,00H
		MOV 	AL,80H 	;8255��ʽѡ�������(10000000B), �˿�ABC��Ϊ���, ��ʽ0
		MOV 	DX,CTRL_8255
		OUT 	DX,AL
		MOV 	CL,00000001B
		MOV 	SI,OFFSET RESULT
DIS:	
		MOV 	BX,[SI] 		;ȡ�ø�λ��
		AND 	BX,000FH		;��λ���ֵ�ȡֵ��ΧΪ0~9, ������θ�4λ
		MOV 	AL,SEG_LED_TABLE[BX] ;�Ӷ�������ҵ����ֶ�Ӧ�Ķ���
		CMP 	CL,1
		JNE 	POINT		
		ADD 	AL,80H 			;AL����80H, ������ʾ��λС����
POINT:	MOV 	DX,PORTB_8255 	;8255�Ķ˿�B,������ʾ����
		OUT 	DX,AL 			;������ֶ�Ӧ�Ķ���
		MOV 	DX,PORTA_8255 	;8255�Ķ˿�A,����λѡ
		MOV 	AL,CL
		NOT 	AL
		OUT 	DX,AL
		INC 	SI
		ROL 	CL,1			;��̬ˢ��,λѡ�ź�����һλ
		CALL 	DELAY
		CALL 	DELAY
		CMP 	CL,40H			;��ʾ��������, �������ѭ��
		JNE 	DIS
				
		POP 	AX
		RET
	
CRT_DISPLAY PROC 				;����Ļ����ʾһλ16�����ַ�
		ADD 	AL,30H			;���ּ�30H, ת��ΪASCII��
		CMP 	AL,39H			;����39Hʱ, ��Ҫ�ڴ˻������ټ�7, ���ܵõ�ASCII��
		JBE 	ADD_7
		ADD 	AL,7
ADD_7: 	MOV 	DL,AL			;����INT21H, ����Ļ����ʾ
		MOV 	AH,2
		INT 	21H
		RET
CRT_DISPLAY ENDP



TRANS 		PROC 		;����ת��
		PUSH 	AX
		PUSH 	DX
		MOV 	SI,OFFSET RESULT
		MOV 	AL,IN0_MEM 		;������ģ���ѹ(��������0~255)
		AND 	AX,00FFH 		;��չ��16λ
		DIV 	NUM_51 			;����51
		MOV 	[SI],AL 		;�õ���λ���ֲ�����RESULT[0] 
		MOV 	AL,AH   		;��������AL
		AND 	AX,00FFH		;��չ��16λ
		MUL 	NUM_10 			;����*10����AX
		DIV 	NUM_51 			;AX����51, �õ�ʮ��λ
		INC 	SI 
		MOV 	[SI],AL 		;ʮ��λ���ַ���RESULT[1]
		;------------�������----------------
		MOV 	AL,AH           
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		MOV 	[SI],AL 		;�ٷ�λ���ַ���RESULT[2] 
		
		MOV 	AL,AH            
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		MOV 	[SI],AL 		;ǧ��λ���ַ���RESULT[3]
		
		MOV 	AL,AH           
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		MOV 	[SI],AL          ;���λ���ַ���RESULT[4] 

		MOV 	AL,AH
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		CMP 	DL,25 			;����DX��25�Ƚ�(51��50%)
		JB 		ADD_1			;С����ִ�м�һ, �����һ(��������)
		ADD 	AL,1 
ADD_1: 	MOV 	[SI],AL 		;ʮ���λ���ַ���RESULT[5]

		POP     DX
		POP     AX
		RET
TRANS ENDP


DELAY 	PROC 	NEAR 		    ;��ʱ�ӳ���
		PUSH 	CX
		MOV 	CX,0FFFFH
        LOOP 	$
		POP 	CX
		RET
		DELAY ENDP
		
CODE ENDS
END START
