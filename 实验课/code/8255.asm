IOY0	EQU	0E000H            ;片选IOY0对应的端口始地址
PA55	EQU	IOY0+00H*4        ;8255的A口地址
PB55	EQU	IOY0+01H*4        ;8255的B口地址
PC55	EQU IOY0+02H*4        ;8255的C口地址
PCTL	EQU	IOY0+03H*4        ;8255的控制寄存器地址

DATA	SEGMENT
	BUFF	DB	6 DUP(10H)
	TABLE1	DB	11H,21H,41H,81H,12H,22H,42H,82H         ;取反后的键盘扫描码
			DB	14H,24H,44H,84H,18H,28H,48H,88H         ;数码管的段码表
	
	DCTBL	DB	3FH,06H,5BH,4fh,66h,6dh,7dh,07h,7fh,6fh
			DB	77h, 7ch,39h,5eh,79h,71h,00h
	
	MES		DB	'Press any key on the small keyboard!',0DH,0AH
			DB	'Press key to display on the led!',0dh,0ah,'$'
	MESS	DB	'Press main keyboard any key to exit!', 0dh, 0ah, 0dh, 0ah, '$'
	KEYC	DB	?
	KEY		DB	?
DATA	ENDS

STAC	SEGMENT PARA STACK
		DB	256 DUP(?)
STAC	ENDS

CODE	SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:STAC
START:
	MOV	AX, DATA
	MOV	DS, AX
	MOV DX, OFFSET MES
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET MESS
	MOV AH, 9
	INT 21H

LOP1:
	CALL TESTKEY
	CALL DISP
	MOV DL, 0FFH
	MOV AH, 6
	INT 21H
	JZ LOP1
	
QUIT:
	MOV AX, 4C00H
	INT 21H
	

TESTKEY PROC
KEY0:
	MOV AL, 81H              ;8255控制字PC0-3入,PC4-7出
	MOV DX, PCTL
	OUT DX, AL
	
	MOV AL, 00              ;C口输出0
	MOV DX, PC55
	OUT DX, AL
	IN AL, DX                ;读入行值，屏蔽列值后保存
	AND AL, 0FH
	MOV KEYC,AL
	
KEY1:
	MOV AL, 88H            ;8255控制字PC0-3出,PC4-7入
	MOV DX, PCTL
	OUT DX, AL
	
	MOV AL, 00             ;C口输出0
	MOV DX, PC55
	OUT DX, AL
	IN AL, DX
	AND AL, 0F0H           ;读入列值,屏蔽行值后合并取反
	OR AL, KEYC
	NOT AL
	CMP AL, 0              ;无键按下退出子程序
	JZ KEYEND
		
	
	MOV SI, OFFSET TABLE1      ;查找按键的值
	MOV CX, 16
	MOV DL, 00H

KEY2:
	CMP AL,[SI]
	JZ KEY3
	INC SI
	INC DL
	DEC CX
	JZ KEYEND
	JMP KEY2
	
KEY3:
	MOV KEY, DL
	MOV SI, OFFSET BUFF+1
	MOV DI, OFFSET BUFF
	MOV CX, 5
	
KEY4:                      ;显示缓冲区内容向前移一位
	MOV AL, [SI]
	MOV [DI], AL
	INC SI
	INC DI
	LOOP KEY4
	
	MOV AL, KEY           ;当前键值存入BUF[5]单元
	MOV [DI], AL
	
	MOV AL, 88H           ;8255控制字,PC0-3出 ,PC4-7入
	MOV DX, PCTL
	OUT DX, AL

KEY5:
	MOV AL, 00            ;判断按键是否释放
	MOV DX, PC55
	OUT DX, AL
	IN AL, DX
	AND AL, 0F0H
	CMP AL, 0F0H
	JNZ KEY5

KEYEND:
	RET
TESTKEY ENDP

DISP PROC
	PUSH DS
	PUSH AX
	MOV CL, 1
	MOV SI, OFFSET BUFF
DIS2:
	MOV AL, [SI]             ;输出段码
	LEA BX, DCTBL
	XLAT
	MOV DX, PB55
	OUT DX, AL
	MOV DX, PA55           ;输出位码
	MOV AL, CL 
	NOT AL
	OUT DX, AL
	CALL DELAY
	INC SI                ;段码地址+1
	ROL CL,1              ;位码左移1位
	CMP CL, 40H           ;位码是最后位码？
	JNZ DIS2              ;不是转DIS2
	POP AX                ;是返回
	POP DS
	RET
DISP ENDP

DELAY PROC NEAR
	PUSH CX
	PUSH BX
	MOV BX, 80H

DEL1:
	MOV CX, 0FFFFH
	LOOP $
	
	DEC BX
	JNZ DEL1
	POP BX
	POP CX
	RET

DELAY ENDP
	

CODE	ENDS
	END START
