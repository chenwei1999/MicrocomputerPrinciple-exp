STACK1 SEGMENT STACK
       DW 256 DUP(0)
STACK1 ENDS
DATA   SEGMENT
MES1   DB 'The data in buf2 are:',0AH,0DH,'$'
BUF1   DB 11H,22H,33H,44H,55H,66H,77H,88H,99H,0AAH,0BBH,0CCH,0DDH,0EEH,0FFH,00H
BUF2   DB 20H DUP(0)
DATA   ENDS

CODE   SEGMENT
       ASSUME CS:CODE,DS:DATA
START: MOV AX,DATA
       MOV DS,AX
       MOV SI,OFFSET BUF1
       MOV DI,OFFSET BUF2
       MOV CX,16             ;ѭ��16��
       CMP SI,DI
       JG  LAB1              ;SI>DI
       JL  LAB2              ;SI<DI

LAB1:                        ;��ǰ�����ƶ�
       MOV BL,[SI]
       MOV [DI],BL
       INC SI
       INC DI
       LOOP LAB1
       JMP NEXT
       
       
LAB2:  ADD SI,15             ;BUF1ĩ��ַ
       ADD DI,15             ;BUF2��BUF1�ȳ���ĩ��ַ
LAB3:  MOV BL,[SI]           ;�Ӻ���ǰ�ƶ�
       MOV [DI],BL
       DEC SI
       DEC DI
       LOOP LAB3       
NEXT:       
       CALL PUTSTR
       RET



      
       
       
PUTSTR PROC  NEAR
    MOV  DX,OFFSET MES1      
    MOV  AH,9
    INT  21H
    MOV  CX,16
    MOV  SI,OFFSET BUF2
PutNum:
    MOV  BL,[SI]
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII                    ;����4λת��ΪASCII��
    MOV  DL,AL
    MOV  AH,2
    INT  21H
    MOV  AL,BL
    CALL ToASCII                    ;����4λת��ΪASCII��
    MOV  DL,AL
    MOV  AH,2
    INT  21H
    MOV  DL,'H'
    MOV  AH,2
    INT  21H
    MOV  DL,' '
    MOV  AH,2
    INT  21H
    INC  SI
    LOOP PutNum 
    MOV  AH,4CH
    INT  21H
    RET    
PUTSTR ENDP       
       


       
ToASCII PROC  NEAR
    AND AL,0FH
    ADD AL,'0'
    CMP AL,'9'
    JBE LAB5
    ADD AL,7
LAB5:
    RET
ToASCII ENDP          

CODE  ENDS
       END START