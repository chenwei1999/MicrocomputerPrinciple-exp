STACK1 SEGMENT STACK
       DW 256 DUP(0)
STACK1 ENDS
DATA   SEGMENT
MES1   DB 'The data in buf2 are:',0AH,0DH,'$'
BUF1   DB 11H,22H,33H,44H,55H,66H,77H,88H,99H,0AAH,0BBH,0CCH,0DDH,0EEH,0FFH,00H
BUF2   DB 20H DUP(0)
MES2   DB 0DH,0AH,"SortResult:$"
result DB 0,0,'H   ','$'
DATA   ENDS

CODE   SEGMENT
       ASSUME CS:CODE,DS:DATA
START: MOV AX,DATA
       MOV DS,AX
       MOV SI,OFFSET BUF1
       MOV DI,OFFSET BUF2
       MOV CX,16             ;循环16次
       CMP SI,DI
       JG  LAB1              ;SI>DI
       JL  LAB2              ;SI<DI

LAB1:                        ;从前往后移动
       MOV BL,[SI]
       MOV [DI],BL
       INC SI
       INC DI
       LOOP LAB1
       JMP NEXT
       
       
LAB2:  ADD SI,15             ;BUF1末地址
       ADD DI,15             ;BUF2和BUF1等长的末地址
LAB3:  MOV BL,[SI]           ;从后往前移动
       MOV [DI],BL
       DEC SI
       DEC DI
       LOOP LAB3       
NEXT:       
       CALL PUTSTR
       CALL SORT
       
       MOV  AH,4CH
       INT  21H
       
       RET


SORT PROC  NEAR
    XOR  AX,AX                     ;选择排序算法
    MOV  BX,OFFSET BUF1             ;I=0
    MOV  SI,0
FORI:
    MOV  DI,SI
    INC  DI                        ;J=I+1
FORJ:
    MOV  AL,[BX+SI]
    CMP  AL,[BX+DI]                ;A[i]与A[j]比较
    JLE  NEXTJ                     ;A[i]小于等于A[j]跳转
    XCHG AL,[BX+DI]                ;A[i]与A[j]交换
    MOV  [BX+SI],AL
NEXTJ:
    INC DI                         ;J=J+1
    CMP DI,16                      ;J<16跳转
    JB  FORJ
NeXTI:
    INC SI                         ;I=I+1
    CMP SI,15
    JB  FORI                       ;I<15时跳转
    MOV  DX,OFFSET MES2         ;显示排序结果
    MOV  AH,9
    INT  21H
    MOV  CL,16
    MOV  SI,OFFSET BUF1
PutNum:
    MOV  BL,[SI]
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII
    MOV  [result],AL
    MOV  AL,BL
    CALL ToASCII
    MOV  [result+1],AL
    MOV  DX,OFFSET result
    MOV  AH,9
    INT  21H
    INC  SI
    LOOP PutNum
    RET      
SORT ENDP       
       
PUTSTR PROC  NEAR
    MOV  DX,OFFSET MES1      
    MOV  AH,9
    INT  21H
    MOV  CX,16
    MOV  SI,OFFSET BUF2
PutNum1:
    MOV  BL,[SI]
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII                    ;将高4位转换为ASCII码
    MOV  DL,AL
    MOV  AH,2
    INT  21H
    MOV  AL,BL
    CALL ToASCII                    ;将低4位转换为ASCII码
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
    LOOP PutNum1 
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