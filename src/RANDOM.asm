DATAS  SEGMENT
    Number DB 50 DUP(0)
    CompleteNumber DB 50 DUP(0)
    Message1 DB 'Press SPACE to','$'
    Message2 DB 'Select Your Lucky Number:','$'
    Message3 DB 'Your Lucky Number Is:','$'
    Count DW 0
    Seed DWORD 0
    StopFlag DB 0
    ImmediateStop DB 0
    NumberLocation DB 0
    LoopTimes DW 0
    
    ;���Զ���ֵ
    StopKey DB ' '				;ֹͣ������������������Ӧ
    DelayFactor DW 20000		;����������ٶȣ�ԽСԽ��
    NumberLength DW 10			;�����λ��
    StopSpeed DW 10				;��λֹͣ�ٶȣ�ԽСԽ��
DATAS  ENDS

STACKS SEGMENT
    DB 64 DUP(0)
STACKS ENDS

CODES  SEGMENT
ASSUME CS:CODES,DS:DATAS
START:
.386
	MOV AX, DATAS
	MOV DS, AX
	;���ع��
	CALL HideCursor
	;��ʾ��ʾ�ı�
    MOV DX,0721H
    LEA BX,Message1
    CALL PrintString
    MOV DX,081CH
    LEA BX,Message2
    CALL PrintString
	;��������λ��
	MOV AX,NumberLength
    SHR AX,1
    MOV NumberLocation,AL
    ;������������
    MOV SI,NumberLength
    MOV CompleteNumber[SI],'$'
    
    NEXT:
    ;�������������
	CALL Generator
	SHL EDX,16
	MOV Seed,EDX
	
	MOV CX,NumberLength
	MOV Count,0
    AGAIN:
	;����һ��һλ�������DL�У���λ��Ϊ0
	ZERO:
    CALL Random
	CMP Count,0
	JNZ PASS
	CMP DL,0
	JZ ZERO
	PASS:
	;���뵽��ʱ�ַ�����
    MOV SI,Count
    ADD DL,'0'
    MOV Number[SI],DL
    INC SI
    MOV COUNT,SI
    LOOP AGAIN
    INC LoopTimes
    ;����������������
    MOV SI,NumberLength
    MOV NUMBER[SI],'$'
    MOV DX,0A28H
    SUB DL,NumberLocation
    LEA BX,Number
    CALL PrintString
    ;�ȴ�һ��ʱ�䣬ͬʱ����������
    MOV BX,DelayFactor
    CALL Delay
    CALL Detect
    ;����Ƿ�ʼֹͣ���洢���˺�
    CMP immediateStop,1
    JNE ifStopping
    MOV immediateStop,0
    MOV LoopTimes,0
    DEC NumberLength
    MOV SI,NumberLength
    MOV AL,Number[SI]
    MOV CompleteNumber[SI],AL
    
    ifStopping:
    CMP StopFlag,1
    JNE continue
    MOV AX,LoopTimes
    CMP AX,StopSpeed
    JNE continue
    MOV LoopTimes,0
    DEC NumberLength
    MOV SI,NumberLength
    MOV AL,Number[SI]
    MOV CompleteNumber[SI],AL
    continue:
    CMP NumberLength,0
    JE Quit
    JMP NEXT
    
    
    HideCursor:
    PUSH AX
    PUSH CX
    MOV AH,1
	MOV CX,3000H
	INT 10H
	POP CX
	POP AX
    RET
    
    PrintString:
	PUSH AX
	PUSH DX
	MOV AH,2H
	INT 10H
	MOV DX,BX
	MOV AH,9H
	INT 21H
    POP DX
    POP AX
    RET
    
    Generator:
    PUSH AX
    PUSH BX
    PUSH CX
    MOV AH,2CH
	INT 21H
	POP CX
	POP BX
	POP AX
	RET
    
    Random:
    PUSH AX
    PUSH BX
    PUSH CX
    XOR AX,AX
    MOV EAX,Seed
    XOR EBX,EBX
    MOV EBX,214013
    MUL EBX
    ADD EAX,2531011
    MOV Seed,EAX
    SHR EAX,16
    MOV CX,7FFFH
    AND AX,CX
    XOR AH,AH
    MOV CL,10
    DIV CL
    MOV DL,AH
	POP CX
	POP BX
	POP AX
	RET
    
    Delay: 
    PUSH AX
    PUSH DX
    MOV DX,BX
    MOV BX,2
    L2:
    L1:
    DEC DX
	CMP DX,0
    JNE L1
    DEC BX
    CMP BX,0
    JNE L2
    POP DX
    POP AX
    RET
    
    Detect:
    PUSH AX
    MOV AH,11H
    INT 16H
    JZ noKey
	MOV AH,10H
    INT 16H
	CMP AL,StopKey
	JNE noKey
	stop:
	MOV immediateStop,1
	MOV StopFlag,1
	noKey:
	POP AX
	RET
        
    Quit:
    MOV AH,0H
    MOV AL,3
    INT 10H
    MOV DX,081DH
    LEA BX,Message3
    CALL PrintString
    MOV DX,0B28H
    SUB DL,NumberLocation
    LEA BX,CompleteNumber
    CALL PrintString
    MOV AX,4C00H
    INT 21H
    RET
CODES  ENDS
    END   START




