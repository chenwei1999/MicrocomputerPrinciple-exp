;-----ADC0809端口地址-----
IOY0 	    EQU 	0E000H
ADCIN0 	    EQU 	IOY0+00H 	;ADC0809端口地址(IN0通道)
ADCIN1 	    EQU 	IOY0+04H 	;ADC0809端口地址(IN1通道)


;-----DAC0832端口地址-----
IOY1 	    EQU 	0E040H
DAC 	    EQU 	IOY1 		;DAC0832端口地址
    

;------8255 端口地址------
IOY2		EQU 	0E080H
PORTA_8255	EQU 	IOY2+20H 	;8255 A口地址
PORTB_8255	EQU 	IOY2+24H 	;8255 B口地址
PORTC_8255	EQU 	IOY2+28H 	;8255 C口地址
CTRL_8255 	EQU 	IOY2+2CH	;8255 控制口地址


;------8259 端口地址------
INTR_IVADD 	EQU 	003CH 		;INTR对应的中断矢量地址
INTR_OCW1 	EQU 	020H 		;INTR对应的PC机内部8259的OCW1地址
INTR_OCW2 	EQU 	021H 		;INTR对应的PC机内部8259的OCW2地址
INTR_IM 	EQU 	07FH 		;修改INTR对应的中断屏蔽字(0FBH = 11111011B)
IOY3 		EQU 	0E0C0H		;8259	端口地址
ICW1_8259 	EQU 	IOY3+00H 	;8259	ICW1端口地址
ICW2_8259 	EQU 	IOY3+04H 	;8259	ICW2端口地址
ICW3_8259 	EQU 	IOY3+04H 	;8259	ICW3端口地址
ICW4_8259 	EQU 	IOY3+04H 	;8259	ICW4端口地址
OCW1_8259 	EQU 	IOY3+04H 	;8259	OCW1端口地址
OCW2_8259 	EQU 	IOY3+00H 	;8259	OCW2端口地址
OCW3_8259 	EQU 	IOY3+00H 	;8259	OCW3端口地址

;-------------------------------------------------
STACK1 	SEGMENT STACK
	DW 256 	DUP(0)
STACK1 	ENDS

DATA SEGMENT
FLAG 		DB 		0 		;标志位
IN0_MEM 	DB 		0 		;用于保存IN0值
IN1_MEM 	DB 		0 		;用于保存IN1值
W_NUM    	DB     	0
W_TIME     	DB     	0

NUM_02 		DB 		02H 	;转换时的除数为2
NUM_80H 	DB 		0			
NUM_51 		DB 		33H 	;存放数字51D
NUM_10 		DB 		0AH 	;存放数字10D
RESULT 		DB 		6 DUP(0) ;存十进制结果(依次为个位|十分位|百分位|千分位|万分位)

MES0 		DB 		'**********************************************',0DH,0AH
			DB 		'*-----------Data Collection System-----------*',0DH,0AH
			DB 		'******   Design by 161710207 zoumengyu  ******',0DH,0AH
			DB 		'******   Design by 161710223 chenwei    ******',0DH,0AH,'$'
MES1 		DB 		'*--------------------------------------------*',0DH,0AH,'$'
MES2 		DB 		' IN0 = $'
MES3 		DB 		' IN1 = $'
MES_VALUE	DB		'Voltage =$'
SEG_LED_TABLE 	DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07H,7Fh,6Fh ;数码管的段码表

CS_BAK 		DW 		0 		;存放原中断处理程序入口段地址
IP_BAK 		DW 		0 		;存放原中断处理程序入口偏移地址
IM_BAK 		DB 		0 		;存放原中断屏蔽字的变量

DATA ENDS

CODE 	SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STACK1
START:	MOV 	AX,DATA
		MOV 	DS,AX
		MOV 	DX,OFFSET MES0       ;显示提示信息
		MOV 	AH,9
		INT 	21H
		MOV 	DX,OFFSET MES1       ;显示提示信息
		MOV 	AH,9
		INT 	21H
		
		CLI
		MOV 	AX,0000H
		MOV 	ES,AX
		MOV 	DI,INTR_IVADD
		MOV 	AX,ES:[DI]
		MOV 	IP_BAK,AX 			;保存原中断入口偏移地址(放入IP_BAK)
		MOV 	AX,OFFSET MYINT 	;设置新的中断入口偏移地址
		MOV 	ES:[DI],AX
		ADD 	DI,2
		MOV 	AX,ES:[DI]
		MOV 	CS_BAK,AX 			;保存原中断入口段地址(放入CS_BAK)
		MOV 	AX,SEG MYINT 		;设置新的中断入口段地址
		MOV 	ES:[DI],AX
		MOV 	DX,INTR_OCW1	
		IN 		AL,DX				;读取原中断屏蔽字
		MOV 	IM_BAK,AL 			;保存原中断屏蔽字
		AND 	AL,INTR_IM 			;允许PC机内部 8259的 IR7中断
		OUT 	DX,AL
		
		;---------实验系统中8259初始化---------
		MOV 	DX,ICW1_8259 	;ICW1地址
		MOV 	AL,13H	 		;边沿触发,单片,需要ICW4(00010011B = 13H)
		OUT 	DX,AL
		MOV 	DX,ICW2_8259	;ICW2地址
		MOV 	AL,08H			;中断类型码
		OUT 	DX,AL
		MOV 	DX,ICW4_8259	;ICW4地址
		MOV 	AL,01H	        ;普通全嵌套,非缓冲,正常EOI,8086模式(00000001B = 01H)
		OUT 	DX,AL
		MOV 	DX,OCW3_8259	;OCW3地址
		MOV 	AL,0AH			;下一个RD读IRR 
		OUT 	DX,AL
		MOV 	DX,OCW1_8259	;OCW1地址
		MOV 	AL,0FEH 		;打开IR0 (11111110B) 
		OUT 	DX,AL
		STI


MAIN: 	MOV 	DX,ADCIN0 		;启动0809IN0
		OUT 	DX,AL 			;启动转换, AL可为任意值
		MOV 	FLAG,0FFH		;FLAG设置为FFH
		CALL 	TRANS 			;调用TRANS子程序, 执行IN0的量纲转换, 转换为10进制数字并存入RESULT
		CALL 	DISPAY 			;调用数码管显示子程序DISPLAY, 显示IN0的十进制电压值
		
		;-----------屏幕显示IN0的值-----------
		MOV 	DX,OFFSET MES2 	;屏幕显示提示信息MES2
		MOV 	AH,9
		INT 	21H
		MOV 	AL,IN0_MEM 		;从IN0_MEM中读入数值
		MOV 	BL,AL			;暂存在BL中
		AND 	AL,0F0H			;屏蔽低四位, 先处理高四位数字	
		MOV 	CL,4
		ROR 	AL,CL			;将高四位移动到低四位
		CALL 	CRT_DISPLAY		;调用CRT_DISPLAY子程序, 显示其对应的十六进制
		MOV 	AL,BL			
		AND 	AL,0FH			;屏蔽高四位
		CALL 	CRT_DISPLAY		;调用CRT_DISPLAY子程序, 显示其对应的十六进制
		CALL 	DELAY     
		
		;-----------屏幕显示IN1的值-----------  
		
		MOV 	DX,OFFSET MES3 	;显示提示信息
		MOV 	AH,9
		INT 	21H
		MOV 	AL,IN1_MEM 		;从IN1_MEM中读入数值
		MOV 	BL,AL			;暂存在BL中
		AND 	AL,0F0H			;屏蔽低四位, 先处理高四位数字
		MOV 	CL,4
		ROR 	AL,CL			;将高四位移动到低四位
		CALL	CRT_DISPLAY		;调用CRT_DISPLAY子程序, 显示其对应的十六进制
		MOV 	AL,BL
		AND 	AL,0FH			;屏蔽高四位
		CALL	CRT_DISPLAY		;调用CRT_DISPLAY子程序, 显示其对应的十六进制
		MOV 	DL,0DH			;回车
		INT 	21H
		CALL	DELAY
		
	;报警 大于2.5V报警			
		MOV		SI,OFFSET RESULT
		MOV 	AL,[SI];取个位数
		CMP 	AL,02H
		JB 		WARNNING0
		JA      WARNNING
		INC 	SI
		MOV 	AL,[SI]
		CMP 	AL,05H
		JAE 	WARNNING
	WARNNING0:
		MOV 	DX,PORTC_8255
		MOV 	AL,00000000B     ;使PC0、PC7为0
		OUT 	DX,AL
		JMP 	LAB2
	WARNNING:
		MOV     CX,5
		MOV 	DX,PORTC_8255
    BELL:
        MOV 	AL,00000001B    ;PC0连小灯，此时置1，PC7置0
		OUT 	DX,AL
		NOP
		NOP
	    MOV 	AL,10000001B    ;PC0连小灯，此时置1，PC7置1，形成方波，PC7接蜂鸣器
		OUT 	DX,AL
		LOOP    BELL

		;---------屏幕显示十进制电压值(0~5V)------
LAB2:	MOV		DX , OFFSET MES_VALUE	;显示提示信息
		MOV		AH , 9
		INT		21H
		MOV		SI , OFFSET RESULT
		MOV		CX , 5			;从个位到十万分位, 需要循环显示5次
		MOV		AL , [SI]		;显示个位数字
        
LN5:    CALL	CRT_DISPLAY
		MOV		DL , '.'		;显示小数点
		MOV		AH , 2
		INT		21H
		
DIS_LP:	INC		SI				;循环四次, 显示从十分位到万分位的四个数字
		MOV		AL , [SI]
		CALL	CRT_DISPLAY
		LOOP	DIS_LP
		MOV		DL , 'V'		;显示单位(V)
		MOV		AH , 2
		INT		21H
		MOV		DL , ' '		;显示空格
		MOV		AH , 2
		INT		21H
		
		MOV 	DL,0FFH 		;判断是否有键按下
		MOV 	AH,6
		INT 	21H
		JZ 		L2020			;循环,回到MAIN继续执行
		JMP 	QUIT
L2020:	JMP 	MAIN
	
	
QUIT: 	CLI						;退出程序
		MOV 	AX,0000H
		MOV 	ES,AX
		MOV 	DI,INTR_IVADD
		MOV 	AX,IP_BAK
		MOV 	ES:[DI],AX		;恢复原先的IP
		ADD 	DI,2
		MOV 	AX,CS_BAK		;恢复原先的CS
		MOV 	ES:[DI],AX
		MOV 	DX,INTR_OCW1
		MOV 	AL,IM_BAK		;恢复原先的中断屏蔽字
		OUT 	DX,AL
		STI	
		MOV 	AX,4C00H 		;返回 DOS
		INT 	21H

MYINT 	PROC 	NEAR 			;中断服务程序
		PUSH 	AX				;保护断点
		PUSH 	CX
		PUSH 	DX
		CLI
		MOV 	AL,FLAG
		CMP 	AL,0FFH			
		JE 		BRANCH_1		;FLAG == FFH 时, 跳转至BRANCH_1

		MOV 	AL,00H			;FLAG != FFH 时, 读取IN1并保存
		MOV 	DX,ADCIN1 		;读 IN1 的值
		IN 		AL,DX
		MOV 	IN1_MEM,AL 		;保存 IN1 , 存放在IN1_MEM
		JMP 	INT_END			;跳转至中断服务程序的末尾

BRANCH_1: 	
		MOV 	DX,ADCIN0 		
		IN 		AL,DX			;读 IN0 的值
		MOV 	IN0_MEM,AL		;保存 IN0 , 存放在IN0_MEM
		
			;-----------线性转换-----------------   ;y=-128/255x+128
		AND 	AX,00FFH		;屏蔽高四位
		DIV 	NUM_02 			;除以2
		MOV 	NUM_80H,80H
		SUB 	NUM_80H,AL		;用80H减去AL, 进行线性转换
		MOV 	AL,NUM_80H	
		MOV 	DX,DAC 			;送往0832输出
		OUT 	DX,AL
		MOV 	DX,ADCIN1 		;启动0809的IN1进行下一次转换
		OUT 	DX,AL
		MOV 	FLAG,0			;FLGA置为0

INT_END: 
        MOV 	DX,INTR_OCW2 	;向PC机内部8259发送中断结束命令
		MOV 	AL,20H
		OUT 	DX,AL
		MOV 	AL,20H
		OUT 	20H,AL
		POP 	DX				;恢复断点
		POP 	CX
		POP 	AX
		STI	
		IRET
MYINT ENDP


DISPAY PROC 		;数码管显示程序
		PUSH 	AX
		MOV 	BX,00H
		MOV 	AL,80H 	;8255方式选择控制字(10000000B), 端口ABC均为输出, 方式0
		MOV 	DX,CTRL_8255
		OUT 	DX,AL
		MOV 	CL,00000001B
		MOV 	SI,OFFSET RESULT
DIS:	
		MOV 	BX,[SI] 		;取得个位数
		AND 	BX,000FH		;个位数字的取值范围为0~9, 因此屏蔽高4位
		MOV 	AL,SEG_LED_TABLE[BX] ;从段码表中找到数字对应的段码
		CMP 	CL,1
		JNE 	POINT		
		ADD 	AL,80H 			;AL加上80H, 用于显示个位小数点
POINT:	MOV 	DX,PORTB_8255 	;8255的端口B,用于显示数据
		OUT 	DX,AL 			;输出数字对应的段码
		MOV 	DX,PORTA_8255 	;8255的端口A,用于位选
		MOV 	AL,CL
		NOT 	AL
		OUT 	DX,AL
		INC 	SI
		ROL 	CL,1			;动态刷新,位选信号左移一位
		CALL 	DELAY
		CALL 	DELAY
		CMP 	CL,40H			;显示完成则结束, 否则继续循环
		JNE 	DIS
				
		POP 	AX
		RET
	
CRT_DISPLAY PROC 				;在屏幕上显示一位16进制字符
		ADD 	AL,30H			;数字加30H, 转换为ASCII码
		CMP 	AL,39H			;大于39H时, 需要在此基础上再加7, 才能得到ASCII码
		JBE 	ADD_7
		ADD 	AL,7
ADD_7: 	MOV 	DL,AL			;调用INT21H, 在屏幕上显示
		MOV 	AH,2
		INT 	21H
		RET
CRT_DISPLAY ENDP



TRANS 		PROC 		;量纲转化
		PUSH 	AX
		PUSH 	DX
		MOV 	SI,OFFSET RESULT
		MOV 	AL,IN0_MEM 		;读到的模拟电压(二进制数0~255)
		AND 	AX,00FFH 		;扩展到16位
		DIV 	NUM_51 			;除以51
		MOV 	[SI],AL 		;得到个位数字并放入RESULT[0] 
		MOV 	AL,AH   		;余数放入AL
		AND 	AX,00FFH		;扩展到16位
		MUL 	NUM_10 			;余数*10放入AX
		DIV 	NUM_51 			;AX除以51, 得到十分位
		INC 	SI 
		MOV 	[SI],AL 		;十分位数字放入RESULT[1]
		;------------精度提高----------------
		MOV 	AL,AH           
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		MOV 	[SI],AL 		;百分位数字放入RESULT[2] 
		
		MOV 	AL,AH            
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		MOV 	[SI],AL 		;千分位数字放入RESULT[3]
		
		MOV 	AL,AH           
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		MOV 	[SI],AL          ;万分位数字放入RESULT[4] 

		MOV 	AL,AH
		AND 	AX,00FFH
		MUL 	NUM_10
		DIV 	NUM_51
		INC 	SI
		CMP 	DL,25 			;余数DX和25比较(51的50%)
		JB 		ADD_1			;小于则不执行加一, 否则加一(四舍五入)
		ADD 	AL,1 
ADD_1: 	MOV 	[SI],AL 		;十万分位数字放入RESULT[5]

		POP     DX
		POP     AX
		RET
TRANS ENDP


DELAY 	PROC 	NEAR 		    ;延时子程序
		PUSH 	CX
		MOV 	CX,0FFFFH
        LOOP 	$
		POP 	CX
		RET
		DELAY ENDP
		
CODE ENDS
END START
