DATA  SEGMENT
A     DW    1234H,5678H        ;被加数
B     DW    0FEDCH,123AH       ;加数
C     DW    2   DUP(0)         ;预留和
AD    DW    0FEDCH,0BA98H      ;被减数
BD    DW    1234H,789AH        ;减数
CD    DW    2   DUP(0)         ;预留差
A1    DW    0D678H             ;被乘数
B1    DW    0012H              ;乘数
C1    DW    2   DUP(0)         ;预留积
A2    DW    5678H,0234H        ;被除数
B2    DW    0F234H             ;除数
C2    DW    2   DUP(0)         ;预留商,余数
DATA  ENDS

STACK1  SEGMENT  STACK
      DB   100  DUP(0)
STACK1  ENDS


CODE SEGMENT
     ASSUME  CS:CODE,DS:DATA,SS:STACK1

START PROC  FAR
      PUSH  DS                   ;标准序
      MOV   AX,0
      PUSH  AX
      MOV   AX,DATA
      MOV   DS,AX

      MOV   AX,A                 ;32位加32位
      ADD   AX,B
      MOV   C,AX
      MOV   AX,A+2
      ADC   AX,B+2               ;用ADC考虑到CF
      MOV   C+2,AX
      
      MOV   AX,AD                ;32位减32位
      SUB   AX,BD
      MOV   CD,AX
      MOV   AX,AD+2
      SBB   AX,BD+2              ;用SBB考虑到CF
      MOV   CD+2,AX
      
      MOV   AX,A1
      MUL   B1
      MOV   C1,AX           ;将AX中保存的结果低16位存放到C1中
      MOV   C1+2,DX         ;将DX中保存的结果高16位存放到C1+2中
      
      MOV   DX,A2+2         ;DX存放高16位
      MOV   AX,A2           ;AX存放低16位
      DIV   B2
      MOV   C2,AX           ;保存余数
      MOV   C2+2,DX         ;保存商
      
      RET
START ENDP

CODE  ENDS
      END   START
            