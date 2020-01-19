DATA SEGMENT
    NUM      DB 12H,88H,82H,89H,33H,90H,0H,10H,0BDH,01H
    Positive DB DUP (0)
    Negative DB DUP (0)
    Zero     DB DUP (0)
    SUM      DW 2 DUP (0)
    result   DB 0,0,'H',0DH,0AH,'$'
    results  DB 0,0,0,0,'H',0DH,0AH,'$'   
    result1  DB "Positive:$"
    result2  DB "Negative:$"
    result3  DB "Zero:$"
    result4  DB "SUM:$" 
    result5  DB "SortResult:$"
    resultsort DB 0,0,'H   ','$'
DATA ENDS 

STACK1 SEGMENT STACK
    DB  100  DUP(0)
STACK1 ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACK1    


START PROC  FAR
BEGIN:
    PUSH DS
    MOV  AX, 0 
    PUSH AX
    MOV  AX, DATA
    MOV  DS, AX 
    
    MOV  CX,10            ;循环10次
    LEA  SI,NUM
    MOV  BX,0
LAB1:
    MOV DL,[SI]
    CMP DL,0              ;判断num是否为0
    JG  LAB2              ;num>0,跳转到LAB2
    JL  LAB3              ;num<0,跳转到LAB3
    INC ZERO              ;num=0,ZERO加1
    JMP LAB4
LAB2:
    INC Positive          ;负数+1
    JMP LAB4 
LAB3:
    INC Negative          ;正数+1
LAB4:
    MOV AL,[SI]
    CBW                   ;符号拓展，8位拓展为16位
    ADD SUM,AX            ;+sum  
    ADC [SUM+2],0
    INC SI
    LOOP LAB1             ;循环
    
    
    MOV  DX,OFFSET result1     ;显示Positive
    MOV  AH,9
    INT  21H
    MOV  BL,Positive
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII           ;把高四位转换为对应的ASCII码
    MOV  [result],AL
    MOV  AL,BL
    CALL ToASCII           ;把低四位转换为对应的ASCII码
    MOV  [result+1],AL
    MOV  DX,OFFSET result
    MOV  AH,9
    INT  21H
    
    
    
    MOV  DX,OFFSET result2       ;显示Negative
    MOV  AH,9
    INT  21H
    MOV  BL,Negative
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
    
    
    MOV  DX,OFFSET result3     ;显示Zero
    MOV  AH,9
    INT  21H
    MOV  BL,Zero
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
    
    
    MOV  DX,OFFSET result4      ;显示Sum
    MOV  AH,9
    INT  21H
    
    MOV  BX,SUM
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII
    MOV  [results+2],AL
    MOV  AL,BL
    CALL ToASCII
    MOV  [results+3],AL
    SHR  BX,8
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII
    MOV  [results],AL
    MOV  AL,BL
    CALL ToASCII
    MOV  [results+1],AL
    
    MOV  DX,OFFSET results
    MOV  AH,9
    INT  21H
    
    
    XOR  AX,AX                     ;选择排序算法
    MOV  BX,OFFSET NUM             ;I=0
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
    CMP DI,10                      ;J<10跳转
    JB  FORJ
NeXTI:
    INC SI                         ;I=I+1
    CMP SI,9
    JB  FORI                       ;I<9时跳转
    
    
    MOV  DX,OFFSET result5         ;显示排序结果
    MOV  AH,9
    INT  21H
    MOV  CL,10
    MOV  SI,OFFSET NUM
PutNum:
    MOV  BL,[SI]
    MOV  AL,BL
    SHR  AL,4
    CALL ToASCII
    MOV  [resultsort],AL
    MOV  AL,BL
    CALL ToASCII
    MOV  [resultsort+1],AL
    MOV  DX,OFFSET resultsort
    MOV  AH,9
    INT  21H
    INC  SI
    LOOP PutNum
    
    
    
    
    
    MOV AH,4CH
    INT 21H
    RET

START ENDP 




ToASCII PROC
    AND AL,0FH
    ADD AL,'0'
    CMP AL,'9'
    JBE LAB5
    ADD AL,7
LAB5:
    RET
ToASCII ENDP    


CODE ENDS
     END   BEGIN