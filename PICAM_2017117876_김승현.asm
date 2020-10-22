	processor 16f876a
; 사용할 특수 레지스터 선언
OPTION_REG	EQU 81H ; RB Pull up 설정 및 분주비 설정
PCL	EQU	02H ; Lookup table 찾는 용도
STATUS	EQU	03H ; Bank 및 Zero Flag 관리
TRISA	EQU	85H ; A I/O 관리
TRISB	EQU	86H ; B I/O 관리
TRISC	EQU	87H ; C I/O 관리
PORTA	EQU	05H ; A 신호관리
PORTB	EQU	06H ; B 신호관리
PORTC	EQU	07H ; C 신호관리
ADCON1	EQU	9FH ; RA 디지털<>아날로그 변환
INTCON	EQU	0BH ; H/W 인터럽트

BUF	EQU	22H ; Delay 용
BUF2	EQU	23H ; Delay 용
W_TEMP	EQU	24H ; 인터럽트 SWAP 용
STATUS_TEMP	EQU	25H ; 인터럽트 SWAP 용
COUNT   EQU	26H ;인터럽트 횟수 확인용
D_10SEC	EQU	27H ; 세그먼트 10의 자리 가져올 수 보관용
D_1SEC	EQU	28H ; 세그먼트 1의 자리 가져올 수 보관용
FLAG	EQU	29H ; 제어할 세그먼트 선택용

W	EQU	B'0'
F	EQU	.1

	ORG	00H
	GOTO	START
	
	ORG	04H
	GOTO	ISR

ISR	MOVWF	W_TEMP 
	SWAPF	STATUS, W
	MOVWF	STATUS_TEMP
	; 인터럽트 부분 시작
	
	CALL      SEGMENT
	
	; 인터럽트 부분 끝
	SWAPF	STATUS_TEMP, W
	MOVWF	STATUS
	SWAPF	W_TEMP, F
	SWAPF	W_TEMP, W
	BCF	INTCON, 2 ;TMR0 가 Overflow 되서 발생한 Flag 를 다시 0으로  초기화
	RETFIE ; Return 이 되면서 GIE Disable 되는데, 바로 Enable 시킴. 

SEGMENT
  	BTFSS	FLAG,0 ;제어할 세그먼트 자리수 확인
  	GOTO	SEGMENT1 ; Flag가 0이면 10의 자리 세그먼트 제어
   	GOTO	SEGMENT2 ; Flag가 1이면 1의 자리 세그먼트 제어
      
SEGMENT1 ; 10의 자리 세그먼트
	BSF	PORTB,1 ; 1의 자리 세그먼트 OFF
	BCF	PORTB,2 ; 10의 자리 세그먼트 ON (스캐닝방식)
  	MOVF	D_10SEC,W ; 워킹에 D_10SEC 을 담는다.
   	CALL	LOOKUP_1 ; Lookup Table 에서 D_10SEC 에 해당하는 수 가져오기
  	MOVWF	PORTC ; 가져온 수를 출력시킨다. (a,b,c,d,e,f 담당)
  	MOVF	D_10SEC,W ; 워킹에 D_10SEC 을 담는다.
  	CALL	LOOKUP_2 ; Lookup Table 에서 D_10SEC 에 해당하는 수 가져오기
  	MOVWF 	PORTA; 가져온 수를 출력시킨다. (g, dot 담당)
   	BSF	FLAG,0 ; 1의 자리를 제어하도록 바꾼다.
   	INCF	COUNT ; 인터럽트가 일어났음을 COUNT 에 기록한다.
   	RETURN

SEGMENT2 ; 1의 자리 세그먼트
	BCF	PORTB,1 ; 1의 자리 세그먼트 ON
	BSF	PORTB,2 ; 10의 자리 세그먼트 OFF (스캐닝방식)
   	MOVF	D_1SEC,W ; 워킹에 D_1SEC 을 담는다.
	CALL	LOOKUP_1 ; Lookup Table 에서 D_1SEC 에 해당하는 수 가져오기
   	MOVWF	PORTC ; 가져온 수를 출력시킨다. (a,b,c,d,e,f 담당)
   	MOVF	D_1SEC,W ; 워킹에 D_1SEC 을 담는다.
  	CALL	LOOKUP_2 ; Lookup Table 에서 D_1SEC 에 해당하는 수 가져오기
  	MOVWF	PORTA; 가져온 수를 출력시킨다. (g, dot 담당)
   	BCF	FLAG,0 ; 10의 자리를 제어하도록 바꾼다.
	;여기서는 인터럽트가 일어났음을 COUNT 에 기록하지 않는다. 분주비가 1:8
	;만약 여기에 COUNT 를 기록한다면, 분주비를 1:16 으로 바꿔야 한다.
  	RETURN

START	BSF	STATUS,5 ; Bank 1 으로 변환
	MOVLW	B'00000110' ; RA 를 모두 디지털로 바꾸기 위해 워킹에 담아서
	MOVWF	ADCON1 ; ADCON1 으로 옮김
	MOVLW	B'00011000';RC7:5, RC2:0 (세그먼트 a,b,c,d,e,f 부분) 을 출력으로 사용하기 위해 워킹에 담아서
	MOVWF	TRISC ; TRISC 으로 옮김
	BCF	TRISA,1;세그먼트 g 부분을 출력으로 사용
	BCF 	TRISA,0;세그먼트 dot 부분을 출력으로 사용
	BCF 	TRISB,1;1의 자리 세그먼트 출력으로 사용
	BCF	TRISB,2;10의 자리 세그먼트 출력으로 사용
	BSF	TRISB,3;SW1 를 입력으로 사용
	BSF	TRISB,4;SW2 를 입력으로 사용
	BSF	TRISB,5;SW3 를 입력으로 사용
	BCF	TRISA,4;부저를 출력으로 사용
	MOVLW	B'00000010' ;TMR0 분주비를 1:8 로 바꾸고 PORTB를 Pull-up 으로 바꾸기 위해 워킹에 담아서
   	MOVWF	OPTION_REG ; OPTION_REG 로 옮김
   	
	BCF	STATUS,5 ;Bank 0 으로 변환
	BSF	PORTA,4 ; 부저가 울리지 않도록 꺼줌 (Pull 이므로 BSF)
	BSF     INTCON,7 ;인터럽트 사용을 위해 Global Interrupt 활성화
   	BSF     INTCON,5 ;타이머로 인터럽트 작동을 위해 TMR0 Overflow Interrupt 활성화
	
MAIN	CALL	initialize ;흐른 시간이 남아있지 않도록 초기화
	GOTO	STOP ; 전원을 넣자마자 시간이 흐르지 않게 멈춤
		
SEC1_LOOP 
   	MOVLW   .244 ;  인터럽트 횟수 확인
   	SUBWF   COUNT,W ; 워킹에 (COUNT - 워킹) 값을 담는다.
   	BTFSS   STATUS,2 ; 워킹에 0 이 되어서 Zeroflag 가 1이 되는지 확인한다. (COUNT=244 인지 확인)
   	GOTO    SW_CHECK ; SW 를 누르는지 확인 + 숫자 1 증가 루프로 돌아간다
	
	;1:8 분주비에 1us 가 지나고, 244번이 쌓이면 실제로 숫자를 증가시킨다.
CK_LOOP
   	CLRF	COUNT
   	INCF	D_1SEC ;1의 자리의 값을 증가시킨다.
   	MOVLW	.10 ;
   	SUBWF   D_1SEC,W ; 워킹에 (D_1SEC - 워킹) 값을 담는다.
   	BTFSS   STATUS,2 ; 워킹에 0 이 되어서 Zeroflag 가 1이 되는지 확인한다. (D_1SEC=10 인지 확인)
   	GOTO	SW_CHECK ; 워킹 0 아니면  SW 를 누르는지 확인 + 숫자 1 증가 루프로 돌아간다
	; 워킹에 0 이 저장되어 있으면 (0~9 까지 다 했으면)
   	CLRF    D_1SEC ;1의 자리에 저장된 수를 초기화 시킨다.
   	INCF    D_10SEC ;10의 자리에 값을 증가시킨다.
   	MOVLW   .6
   	SUBWF   D_10SEC,W ; 워킹에 (D_10SEC - 워킹) 값을 담는다.
   	BTFSS   STATUS,2 ; 워킹에 0 이 되어서 Zeroflag 가 1이 되는지 확인한다. (D_10SEC=6 인지 확인)
   	GOTO	SW_CHECK ; 워킹 0 아니면 SW 를 누르는지 확인 + 숫자 1 증가 루프로 돌아간다
   	; 워킹에 0이 저장되어 있으면 (0~5 까지 다 했으면)
   	CLRF 	D_1SEC ;1의 자리에 저장된 수를 초기화 시킨다.
   	CLRF	D_10SEC ;10의 자리에 저장된 수를 초기화 시킨다.

	BCF	PORTA,4 ; 부저를 켠다.
   	CALL	DELAY ; 딜레이 초 시간 유지
   	BSF	PORTA,4 ; 부저를 끈다.
   	GOTO	MAIN ; 처음으로 돌아간다.
   	
   
SW_CHECK
	BTFSS	PORTB,3 ;SW3(리셋) 을 누르면
	GOTO	MAIN ; 메인으로 돌아간다.
	BTFSS	PORTB,4 ;SW2(정지) 를 누르면
	GOTO	STOP ; 정지한다.
   	GOTO    SEC1_LOOP ; 둘다 안눌렀으면, 계속 루프를 돈다.
   	
STOP	BTFSC	PORTB,5 ;SW3(리셋) 을 누른지 확인한다.
	GOTO	STOP2 ; 안눌렀으면, 계속 멈춰있는다.
	CALL	DELAY ;눌렀으면 여기로 와서
	GOTO	SEC1_LOOP; 다시 루프를 돈다.
	
STOP2	BTFSC	PORTB,3 ;SW3(리셋) 을 누르면
	GOTO	STOP ; 안눌렀으면, 계속 멈춰있는다.
	GOTO	MAIN; 메인으로 돌아간다.

	;LOOKUP_1 은 a,b,c,d,e,f 만 관리
LOOKUP_1	ANDLW   0FH ;9보다 큰 값이 나오면 9 안에서 끝나도록, 뒷자리 4 비트만 살림
   	ADDWF   PCL,F
   	RETLW   B'11111111' ;0
   	RETLW   B'01111000' ;1
   	RETLW   B'11011011' ;2
   	RETLW   B'11111010' ;3
   	RETLW   B'01111100' ;4
   	RETLW   B'10111110' ;5
   	RETLW   B'10111111' ;6
   	RETLW   B'11111100' ;7
   	RETLW   B'11111111' ;8
   	RETLW   B'11111100' ;9
   	
	;LOOKUP_2 는 g, dot 만 관리
LOOKUP_2	ANDLW   0FH ;9보다 큰 값이 나오면 9 안에서 끝나도록, 뒷자리 4 비트만 살림
   	ADDWF   PCL,F
   	RETLW   B'00010000' ;0
   	RETLW   B'00010000' ;1
   	RETLW   B'00010010' ;2
   	RETLW   B'00010010' ;3
   	RETLW   B'00010010' ;4
   	RETLW   B'00010010' ;5
   	RETLW   B'00010010' ;6
   	RETLW   B'00010000' ;7
	RETLW   B'00010010' ;8
   	RETLW	 B'00010010' ;9
 
DELAY	MOVLW	.1 ;딜레이
DE_LOOP2	MOVWF	BUF
	MOVLW	.255
	MOVWF	BUF2
DE_LOOP1	DECFSZ	BUF2
	GOTO	DE_LOOP1
	DECFSZ	BUF
	GOTO	DE_LOOP2
	RETURN
	
initialize	MOVLW   B'00000000'
	MOVWF   COUNT ;시간계수 초기화
  	MOVWF   D_10SEC ;1의 자리 초기화
  	MOVWF   D_1SEC ;10의 자리 초기화
  	MOVWF   FLAG ;10의 자리부터 시작을 위해 초기화 (시간계수 미세한 오차방지)
  	RETURN
	END