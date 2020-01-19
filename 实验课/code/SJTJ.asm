DATA SEGMENT
    NUM      DB 12H,88H,82H,89H,33H,90H,0H,10H,0BDH,01H
    Positive DB DUP (0)
    Negative DB DUP (0)
    Zero     DB DUP (0)
    SUM      DW 2 DUP (0)
DATA ENDS 

STACK1 SEGMENT STACK
    DB  100  DUP(0)
STACK1 ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACK1    


START PROC  FAR
    PUSH DS
    MOV  AX, 0 
    PUSH AX
    MOV  AX, DATA
    MOV  DS, AX 
    
    MOV  CX,10            ;ѭ��10��
    LEA  SI,NUM
    MOV  BX,0
LAB1:
    MOV DL,[SI]
    CMP DL,0              ;�ж�num�Ƿ�Ϊ0
    JG  LAB2              ;num>0,��ת��LAB2
    JL  LAB3              ;num<0,��ת��LAB3
    INC ZERO              ;num=0,ZERO��1
    JMP LAB4
LAB2:
    INC Positive          ;����+1
    JMP LAB4 
LAB3:
    INC Negative          ;����+1
LAB4:
    MOV AL,[SI]
    CBW                   ;������չ��8λ��չΪ16λ
    ADD SUM,AX            ;+sum  
    ADC [SUM+2],0
    INC SI
    LOOP LAB1             ;ѭ��

    RET

START ENDP
CODE ENDS
     END   START