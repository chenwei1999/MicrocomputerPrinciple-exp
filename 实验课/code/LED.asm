;Led-HZ.asm,32λLED��������ʾʵ��
INCLUDE NUAA.inc
.386P
IOY0         EQU   0E000H          ;ƬѡIOY0��Ӧ�Ķ˿�ʼ��ַ
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
A2:    MOV  ADDR,OFFSET HZDOT    ;ȡ��������ʼ��ַ     
       MOV  SI,ADDR         
A1:    MOV  CX,20H               ;����1����ʾʱ��
LOOP2: CALL DISPHZ
       SUB  SI,32
       LOOP LOOP2       
KEY:   MOV  AH,1                 ;�ж��Ƿ��а������£�
       INT  16H
       JNZ  QUIT
       ADD  SI,2  
       MOV  AX,SI       
       SUB  AX,ADDR
       CMP  AX,288               ;�Ƚ������Ƿ���ʾ���
       JNB  A2                   
       JMP  A1
QUIT:  MOV  EAX,0                ;���
       MOV  DX,IOY0
       OUT  DX,EAX
       MOV  AX,4C00H             ;���������˳�
       INT  21H
DISPHZ PROC NEAR                 ;��ʾ1�������ӳ���
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
DALLY  PROC NEAR                  ;�����ʱ�ӳ���
       MOV  AX,0FFFFH
D1:    DEC  AX
       JNZ  D1
       RET
DALLY  ENDP
CODE ENDS
     END START
