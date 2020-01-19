;Led-HZ.asm,32位LED点阵汉字显示实验
INCLUDE NUAA.inc
.386P
IOY0         EQU   0E000H          ;片选IOY0对应的端口始地址
STACK1 SEGMENT STACK 
        DW 256 DUP(?)
STACK1 ENDS
DATA   SEGMENT  USE16 	
ADDR    DW   ?
DATA   ENDS
CODE SEGMENT  USE16
        ASSUME CS:CODE,DS:DATA
START: MOV  AX,DATA
       MOV  DS,AX
A2:    MOV  ADDR,OFFSET HZDOT    ;取汉字数组始地址     
       MOV  SI,ADDR         
A1:    MOV  CX,20H               ;控制1屏显示时间
LOOP2: CALL DISPHZ
       SUB  SI,32
       LOOP LOOP2       
KEY:   MOV  AH,1                 ;判断是否有按键按下？
       INT  16H
       JNZ  QUIT
       ADD  SI,2  
       MOV  AX,SI       
       SUB  AX,ADDR
       CMP  AX,288               ;比较文字是否显示完毕
       JNB  A2                   
       JMP  A1
QUIT:  MOV  EAX,0                ;灭灯
       MOV  DX,IOY0
       OUT  DX,EAX
       MOV  AX,4C00H             ;结束程序退出
       INT  21H
DISPHZ PROC NEAR                 ;显示1屏汉字子程序
       PUSH CX
       MOV  CX,16
       MOV  BX,0FFFEH
LOOP1: MOV  AL,BYTE PTR[SI]
       MOV  AH,BYTE PTR[SI+1]
       ROL  EAX,16 
       MOV  AX,BX             
       ADD  SI,2
       ROL  BX,1 
      
       NOT  EAX
       MOV  DX,IOY0
       OUT  DX,EAX
       CALL DALLY
       LOOP LOOP1
       POP  CX
       RET
DISPHZ ENDP
DALLY  PROC NEAR                  ;软件延时子程序
       MOV  AX,0FFFFH
D1:    DEC  AX
       JNZ  D1
       RET
DALLY  ENDP
CODE ENDS
     END START
