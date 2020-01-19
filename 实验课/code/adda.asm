CRLF MACRO                    ;宏定义了回车
	MOV DL, 0DH
	MOV AH, 02H
	INT 21H
	MOV DL, 0AH
	INT 21H
	ENDM
	
IOY0 EQU 0E000H         ;片选 IOY0 对应的端口始地址
IOY1 EQU 0E040H         ;片选 IOY1 对应的端口始地址
ADCS EQU IOY0           ;AD0809 的端口地址
DACS EQU IOY1           ;DAC0832 的端口地址

STAC SEGMENT PARA STACK
	DW 256 DUP(?)
STAC ENDS

DATA SEGMENT
	MES0 DB 'PRESS 1 TO INPUT DATA!', 0DH, 0AH
		 DB 'PRESS 2 TO QUIT!', 0DH, 0AH, 0DH, 0AH, '$'
	MES1 DB '******PLEASE INPUT DATA OF HEX!****', 0DH, 0AH, '$'
	MES2 DB '0832 OUTPUT DATA  =  $'
	MES3 DB '0809 INPUT DATA =  $'
	BUF DB 2 DUP(?)
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:STAC
	
START:
	MOV AX, DATA
	MOV DS, AX
	
	LEA DX, MES0
	MOV AH, 9
	INT 21H
	
LOP1:
	MOV DL, 0FFH           ;检测键盘输入
	MOV AH, 6
	INT 21H
	JZ LOP1
	
	CMP AL, '1'
	JZ DA
	CMP AL, '2'
	JZ EXIT0
	JMP START

EXIT0: JMP EXIT
DA: LEA DX, MES1          ;显示MES1
	MOV AH, 9
	INT 21H
	
	LEA DX, MES2          ;显示MES2
	MOV AH, 9
	INT 21H
	                      ;十六进制值存入BUF和BUF[1]
	MOV AH, 1
	INT 21H
	MOV BUF, AL
	INT 21H
	MOV BUF[1], AL
	MOV AH, 2
	CRLF
                         ;十六进制转换十进制
DA0:
	MOV AL, BUF
	SUB AL, 30H
	CMP AL, 9
	JBE A0
	SUB AL, 7

A0:                     ;十六进制转换十进制
	MOV BL, AL
	MOV AL, BUF[1]
	SUB AL, 30H
	CMP AL, 9
	JBE B0
	SUB AL, 7
	
B0:
	MOV CL, 4
	ROL BL, CL
	XOR AL, BL
	MOV DX, DACS         ;启动0832
	OUT DX, AL
	
AD:                     ;启动0809 INO
	MOV DX, ADCS
	OUT DX, AL
	CALL DELAY
	LEA DX, MES3        ;显示MES3
	MOV AH, 9
	INT 21H
	
	MOV DX, ADCS        ;读入0809 INO值
	IN AL, DX
	MOV BL, AL
	AND AL, 0F0H       ;显示高位
	
	MOV CL, 4
	ROL AL, CL
	CALL CRT1
	MOV AL, BL         ;显示低位
	AND AL, 0FH
	CALL CRT1
	CRLF
	INT 21H
	JMP START

EXIT:
	MOV AX, 4C00H
	INT 21H
	
CRT1 PROC              ;在屏幕上显示一位16进制字符
	ADD AL, 30H
	CMP AL, 39H
	JBE D0
	ADD AL, 7

D0: MOV DL, AL
	MOV AH, 2
	INT 21H
	RET
CRT1 ENDP

DELAY PROC NEAR
	PUSH CX
	MOV CX , 0FFFFH
	LOOP $
	POP CX
	RET
DELAY ENDP
	
CODE ENDS
	END START
