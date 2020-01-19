INTR_IVADD	EQU 003CH  ;INTR对应的中断矢量地址
INTR_OCW1	EQU	021H   ;INTR对应PC机内部8259的OCW1地址
INTR_OCW2	EQU	020H   ;INTR对应PC机内部8259的OCW2地址
INTR_IM		EQU	07FH   ;INTR对应的中断屏蔽字
IOY0		EQU	0E000H ;片选IOY0对应的端口始地址

MY8259_ICW1	EQU	IOY0+00H     ;实验系统中8259的ICW1端口地址
MY8259_ICW2	EQU	IOY0+04H     ;实验系统中8259的ICW2端口地址
MY8259_ICW3	EQU	IOY0+04H     ;实验系统中8259的ICW3端口地址
MY8259_ICW4	EQU	IOY0+04H     ;实验系统中8259的ICW4端口地址
MY8259_OCW1	EQU	IOY0+04H     ;实验系统中8259的OCW1端口地址
MY8259_OCW2	EQU	IOY0+00H     ;实验系统中8259的OCW2端口地址
MY8259_OCW3	EQU	IOY0+00H     ;实验系统中8259的OCW3端口地址

STACK1		SEGMENT	STACK
			DW	256	DUP(?)
STACK1		ENDS

DATA		SEGMENT
		MES		DB		'Press any key to exit!',0AH,0DH,0AH,0DH,'$'
		CS_BAK	DW	?          ;保存INTR原中断处理程序入口段地址的变量
		IP_BAK	DW	?          ;保存INTR原中断处理程序入口偏移地址的变量
		IM_BAK	DB	?          ;保存INTR原中断屏蔽字的变量
DATA		ENDS

CODE		SEGMENT
		ASSUME CS:CODE, DS:DATA, SS:STACK1

START:
	MOV	AX, DATA
	MOV	DS, AX
	MOV	DX, OFFSET MES      ;显示退出提示
	MOV	AH, 09H
	INT	21H
	
	CLI	
	MOV	AX, 0000H           ;替换INTR的中断矢量
	MOV ES, AX
	MOV	DI, INTR_IVADD      ;保存INTR原中断处理程序入口偏移地址
	MOV AX, ES:[DI]         
	MOV	IP_BAK, AX
	MOV AX, OFFSET MYISR    ;设置当前中断处理程序入口偏移地址
	MOV ES:[DI], AX
	
	ADD DI, 2               ;保存INTR原中断处理程序入口段地址
	MOV AX, ES:[DI]
	MOV CS_BAK, AX
	MOV AX, SEG MYISR       ;设置当前中断处理程序入口段地址
	MOV ES:[DI], AX
	
	MOV DX, INTR_OCW1      ;设置中断屏蔽寄存器，打开INTR的屏蔽位
	IN	AL, DX             ;保存INTR原中断屏蔽字
	MOV	IM_BAK, AL
	
	AND AL, INTR_IM        ;允许PC机内部8259的 IR7 中断
	OUT DX, AL
	
	MOV DX, MY8259_ICW1   ;初始化实验系统中8259的ICW1
	MOV AL, 13H           ;边沿触发、单片8259 、需要ICW4
	OUT DX, AL
	
	MOV DX, MY8259_ICW2   ;初始化实验系统中8259的ICW2
	MOV AL, 08H
	OUT DX, AL
	
	MOV DX, MY8259_ICW4   ;初始化实验系统中8259的ICW4
	MOV AL, 01H           ;非自动结束EOI
	OUT DX, AL
	
	MOV DX, MY8259_OCW3   ;向8259的OCW3发送读取IRR命令
	MOV AL, 0AH
	OUT DX, AL
	
	MOV DX, MY8259_OCW1   ;初始化实验系统中8259的OCW1
	MOV AL, 0FCH          ;打开IR0和IR1的屏蔽位
	OUT DX, AL
	STI
	
WAIT1:
	MOV AH, 1             ;判断是否有按键按下
	INT 16H               ;无按键则跳回继续等待，有则退出
	JZ	WAIT1
	
QUIT:
	CLI
	MOV AX, 0000H         ;恢复INTR原中断矢量
	MOV ES, AX
	MOV DI, INTR_IVADD    ;恢复INTR原中断处理程序入口偏移地址
	MOV AX, IP_BAK
	MOV ES:[DI], AX
	
	ADD DI,2
	MOV AX, CS_BAK     ;恢复INTR原中断处理程序入口段地址
	MOV ES:[DI], AX
	MOV DX, INTR_OCW1
	MOV AL, IM_BAK    ;恢复INTR原中断屏蔽寄存器的屏蔽字
	OUT DX, AL
	STI
	MOV AX, 4C00H     ;返回到 DOS
	INT 21H

MYISR PROC NEAR         ;中断处理程序MYISR
	PUSH AX
QUERY:                  ;向8259的OCW3发送读取IRR 命令
	MOV DX, MY8259_OCW3
	IN	AL, DX          ;读出IRR寄存器值
	
	AND AL, 03H
	CMP AL, 01H
	JE	IR0ISR        ;若为IR0请求，跳到IR0处理程序
	JNE IR1ISR        ;若为IR1请求，跳到IR1处理程序
	JMP OVER

IR0ISR:               ;IR0处理，显示字符串STR0
	MOV AL, 30H
	MOV AH, 0EH
	INT 10H
	MOV AL, 20H
	INT 10H
	JMP OVER

IR1ISR:            ;IR1处理，显示字符串STR1
	MOV AL, 31H
	MOV AH, 0EH
	INT 10H
	MOV AL, 20H
	INT 10H
	JMP OVER
	
OVER:
	MOV DX, INTR_OCW2    ;向PC机内部8259发送中断结束命令
	MOV AL, 20H
	OUT DX, AL
	MOV AL, 20H
	OUT 20H, AL
	POP AX
	
	IRET

MYISR ENDP

CODE		ENDS
END START 

 
