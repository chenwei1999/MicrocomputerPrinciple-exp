IOY0	EQU	0E000H
TIMER0	EQU	IOY0+00H*4   ;8254计数器0端口地址
TIMER1	EQU	IOY0+01H*4   ;8254计数器1端口地址
TIMER2	EQU	IOY0+02H*4   ;8254计数器2端口地址
TCTL	EQU IOY0+03H*4   ;8254控制寄存器端口地址

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
		
		MOV	DX, TCTL               ;控制字，选用计数器0，写16位值,方式3,二进制计数
		MOV	AL, 00110110B
		OUT	DX, AL
		
		MOV	DX, TIMER0             ;写入4800H
		MOV	AL, 00H
		OUT	DX, AL
		MOV	AL, 48H
		OUT	DX, AL
		
		MOV	DX, TCTL               ;控制字，选用计数器1，写低字节,方式2,二进制计数
		MOV	AL, 01010100B
		OUT	DX, AL
		
		MOV	DX, TIMER1             ;写入04H
		MOV	AL, 04H
		OUT	DX, AL
		
		MOV	DX, TCTL              ;控制字，选用计数器2，写低字节,方式0,二进制计数
		MOV	AL, 10010000B
		OUT	DX, AL
		
		MOV	DX, TIMER2
		MOV	AL, 0FH
		OUT	DX, AL


L1:		MOV	DX, TIMER2            ;读入计数器2值保存
		IN	AL, DX
		MOV	NUM, AL
		CALL	DISP
		
		MOV	AL, NUM
		CMP	AL, 0
		JZ QUIT                   ;计数至0时退出
		
		MOV	DL, 0FFH              ;判主键盘有无键按下
		MOV	AH, 6
		INT	21H
		JZ	L1                    ;无键按下跳转

QUIT:	MOV	AX, 4C00H             ;结束程序退出
		INT 21H

DISP	PROC                      ;显示子程序
		MOV	DX, OFFSET MES0       ;显示MES0
		MOV	AH, 9
		INT	21H
		
		MOV	AL, NUM
		CMP	AL, 9                ;判断是否<=9
		JLE	L2                   ;若是则为'0'-'9',ASCII码加30H
		ADD	AL, 7                ;否则为' A'-'F',ASCII码加37H

L2:		ADD	AL, 30H              ;在显示器上显示按压开关的次数
		MOV	DL, AL
		MOV	AH, 2
		INT	21H
		MOV	DL, 0DH
		INT	21H
		
		RET

DISP	ENDP		
		
CODE	ENDS
		END		START