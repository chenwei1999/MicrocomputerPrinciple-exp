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
SMALL   DB 50   ;预留键盘输入缓冲区长度为 50 个
        DB 0    ;预留实际键盘输入字符数的个数         
        DB 50 DUP(0)
CAPITAL DB 50 DUP(0)   ;预留大写字母缓冲区长度为 50 个
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
        MOV     DX, OFFSET MES1 ;输岀提示信息MES1
        INT     21H
        CRLF

        MOV     AH, 0AH
        LEA     DX, SMALL;接收小写字符串
        INT 21H
        CRLF                    ;宏调用
        
       
        LEA		BX,	 SMALL+2
        LEA		DI,	 CAPITAL
        MOV		CX,	 20           ;最多20个字符
 LAB:   MOV		AL,  [BX]
        CMP		AL,	 2EH          ;是否遇到句号.
        JE		KE 
        SUB		AL,	 20H          ;转为大写,ASCLL-20H
        MOV		[DI], AL
        INC		BX
        INC		DI
        LOOP	LAB

KE:     MOV     AL, '$'              ;大写字符串后加“$”
        MOV     [DI], AL
        MOV     DX, OFFSET MES2 ; 输岀提示信息MES2
        MOV     AH, 9
        INT     21H
        CRLF

        MOV DX, OFFSET CAPITAL
        MOV AH, 9 ; 输岀大写字符串
        INT 21H
        RET
START ENDP
CODE ENDS
        END START

