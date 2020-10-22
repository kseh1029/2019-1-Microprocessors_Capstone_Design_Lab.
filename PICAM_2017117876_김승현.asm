	processor 16f876a
; ����� Ư�� �������� ����
OPTION_REG	EQU 81H ; RB Pull up ���� �� ���ֺ� ����
PCL	EQU	02H ; Lookup table ã�� �뵵
STATUS	EQU	03H ; Bank �� Zero Flag ����
TRISA	EQU	85H ; A I/O ����
TRISB	EQU	86H ; B I/O ����
TRISC	EQU	87H ; C I/O ����
PORTA	EQU	05H ; A ��ȣ����
PORTB	EQU	06H ; B ��ȣ����
PORTC	EQU	07H ; C ��ȣ����
ADCON1	EQU	9FH ; RA ������<>�Ƴ��α� ��ȯ
INTCON	EQU	0BH ; H/W ���ͷ�Ʈ

BUF	EQU	22H ; Delay ��
BUF2	EQU	23H ; Delay ��
W_TEMP	EQU	24H ; ���ͷ�Ʈ SWAP ��
STATUS_TEMP	EQU	25H ; ���ͷ�Ʈ SWAP ��
COUNT   EQU	26H ;���ͷ�Ʈ Ƚ�� Ȯ�ο�
D_10SEC	EQU	27H ; ���׸�Ʈ 10�� �ڸ� ������ �� ������
D_1SEC	EQU	28H ; ���׸�Ʈ 1�� �ڸ� ������ �� ������
FLAG	EQU	29H ; ������ ���׸�Ʈ ���ÿ�

W	EQU	B'0'
F	EQU	.1

	ORG	00H
	GOTO	START
	
	ORG	04H
	GOTO	ISR

ISR	MOVWF	W_TEMP 
	SWAPF	STATUS, W
	MOVWF	STATUS_TEMP
	; ���ͷ�Ʈ �κ� ����
	
	CALL      SEGMENT
	
	; ���ͷ�Ʈ �κ� ��
	SWAPF	STATUS_TEMP, W
	MOVWF	STATUS
	SWAPF	W_TEMP, F
	SWAPF	W_TEMP, W
	BCF	INTCON, 2 ;TMR0 �� Overflow �Ǽ� �߻��� Flag �� �ٽ� 0����  �ʱ�ȭ
	RETFIE ; Return �� �Ǹ鼭 GIE Disable �Ǵµ�, �ٷ� Enable ��Ŵ. 

SEGMENT
  	BTFSS	FLAG,0 ;������ ���׸�Ʈ �ڸ��� Ȯ��
  	GOTO	SEGMENT1 ; Flag�� 0�̸� 10�� �ڸ� ���׸�Ʈ ����
   	GOTO	SEGMENT2 ; Flag�� 1�̸� 1�� �ڸ� ���׸�Ʈ ����
      
SEGMENT1 ; 10�� �ڸ� ���׸�Ʈ
	BSF	PORTB,1 ; 1�� �ڸ� ���׸�Ʈ OFF
	BCF	PORTB,2 ; 10�� �ڸ� ���׸�Ʈ ON (��ĳ�׹��)
  	MOVF	D_10SEC,W ; ��ŷ�� D_10SEC �� ��´�.
   	CALL	LOOKUP_1 ; Lookup Table ���� D_10SEC �� �ش��ϴ� �� ��������
  	MOVWF	PORTC ; ������ ���� ��½�Ų��. (a,b,c,d,e,f ���)
  	MOVF	D_10SEC,W ; ��ŷ�� D_10SEC �� ��´�.
  	CALL	LOOKUP_2 ; Lookup Table ���� D_10SEC �� �ش��ϴ� �� ��������
  	MOVWF 	PORTA; ������ ���� ��½�Ų��. (g, dot ���)
   	BSF	FLAG,0 ; 1�� �ڸ��� �����ϵ��� �ٲ۴�.
   	INCF	COUNT ; ���ͷ�Ʈ�� �Ͼ���� COUNT �� ����Ѵ�.
   	RETURN

SEGMENT2 ; 1�� �ڸ� ���׸�Ʈ
	BCF	PORTB,1 ; 1�� �ڸ� ���׸�Ʈ ON
	BSF	PORTB,2 ; 10�� �ڸ� ���׸�Ʈ OFF (��ĳ�׹��)
   	MOVF	D_1SEC,W ; ��ŷ�� D_1SEC �� ��´�.
	CALL	LOOKUP_1 ; Lookup Table ���� D_1SEC �� �ش��ϴ� �� ��������
   	MOVWF	PORTC ; ������ ���� ��½�Ų��. (a,b,c,d,e,f ���)
   	MOVF	D_1SEC,W ; ��ŷ�� D_1SEC �� ��´�.
  	CALL	LOOKUP_2 ; Lookup Table ���� D_1SEC �� �ش��ϴ� �� ��������
  	MOVWF	PORTA; ������ ���� ��½�Ų��. (g, dot ���)
   	BCF	FLAG,0 ; 10�� �ڸ��� �����ϵ��� �ٲ۴�.
	;���⼭�� ���ͷ�Ʈ�� �Ͼ���� COUNT �� ������� �ʴ´�. ���ֺ� 1:8
	;���� ���⿡ COUNT �� ����Ѵٸ�, ���ֺ� 1:16 ���� �ٲ�� �Ѵ�.
  	RETURN

START	BSF	STATUS,5 ; Bank 1 ���� ��ȯ
	MOVLW	B'00000110' ; RA �� ��� �����з� �ٲٱ� ���� ��ŷ�� ��Ƽ�
	MOVWF	ADCON1 ; ADCON1 ���� �ű�
	MOVLW	B'00011000';RC7:5, RC2:0 (���׸�Ʈ a,b,c,d,e,f �κ�) �� ������� ����ϱ� ���� ��ŷ�� ��Ƽ�
	MOVWF	TRISC ; TRISC ���� �ű�
	BCF	TRISA,1;���׸�Ʈ g �κ��� ������� ���
	BCF 	TRISA,0;���׸�Ʈ dot �κ��� ������� ���
	BCF 	TRISB,1;1�� �ڸ� ���׸�Ʈ ������� ���
	BCF	TRISB,2;10�� �ڸ� ���׸�Ʈ ������� ���
	BSF	TRISB,3;SW1 �� �Է����� ���
	BSF	TRISB,4;SW2 �� �Է����� ���
	BSF	TRISB,5;SW3 �� �Է����� ���
	BCF	TRISA,4;������ ������� ���
	MOVLW	B'00000010' ;TMR0 ���ֺ� 1:8 �� �ٲٰ� PORTB�� Pull-up ���� �ٲٱ� ���� ��ŷ�� ��Ƽ�
   	MOVWF	OPTION_REG ; OPTION_REG �� �ű�
   	
	BCF	STATUS,5 ;Bank 0 ���� ��ȯ
	BSF	PORTA,4 ; ������ �︮�� �ʵ��� ���� (Pull �̹Ƿ� BSF)
	BSF     INTCON,7 ;���ͷ�Ʈ ����� ���� Global Interrupt Ȱ��ȭ
   	BSF     INTCON,5 ;Ÿ�̸ӷ� ���ͷ�Ʈ �۵��� ���� TMR0 Overflow Interrupt Ȱ��ȭ
	
MAIN	CALL	initialize ;�帥 �ð��� �������� �ʵ��� �ʱ�ȭ
	GOTO	STOP ; ������ ���ڸ��� �ð��� �帣�� �ʰ� ����
		
SEC1_LOOP 
   	MOVLW   .244 ;  ���ͷ�Ʈ Ƚ�� Ȯ��
   	SUBWF   COUNT,W ; ��ŷ�� (COUNT - ��ŷ) ���� ��´�.
   	BTFSS   STATUS,2 ; ��ŷ�� 0 �� �Ǿ Zeroflag �� 1�� �Ǵ��� Ȯ���Ѵ�. (COUNT=244 ���� Ȯ��)
   	GOTO    SW_CHECK ; SW �� �������� Ȯ�� + ���� 1 ���� ������ ���ư���
	
	;1:8 ���ֺ� 1us �� ������, 244���� ���̸� ������ ���ڸ� ������Ų��.
CK_LOOP
   	CLRF	COUNT
   	INCF	D_1SEC ;1�� �ڸ��� ���� ������Ų��.
   	MOVLW	.10 ;
   	SUBWF   D_1SEC,W ; ��ŷ�� (D_1SEC - ��ŷ) ���� ��´�.
   	BTFSS   STATUS,2 ; ��ŷ�� 0 �� �Ǿ Zeroflag �� 1�� �Ǵ��� Ȯ���Ѵ�. (D_1SEC=10 ���� Ȯ��)
   	GOTO	SW_CHECK ; ��ŷ 0 �ƴϸ�  SW �� �������� Ȯ�� + ���� 1 ���� ������ ���ư���
	; ��ŷ�� 0 �� ����Ǿ� ������ (0~9 ���� �� ������)
   	CLRF    D_1SEC ;1�� �ڸ��� ����� ���� �ʱ�ȭ ��Ų��.
   	INCF    D_10SEC ;10�� �ڸ��� ���� ������Ų��.
   	MOVLW   .6
   	SUBWF   D_10SEC,W ; ��ŷ�� (D_10SEC - ��ŷ) ���� ��´�.
   	BTFSS   STATUS,2 ; ��ŷ�� 0 �� �Ǿ Zeroflag �� 1�� �Ǵ��� Ȯ���Ѵ�. (D_10SEC=6 ���� Ȯ��)
   	GOTO	SW_CHECK ; ��ŷ 0 �ƴϸ� SW �� �������� Ȯ�� + ���� 1 ���� ������ ���ư���
   	; ��ŷ�� 0�� ����Ǿ� ������ (0~5 ���� �� ������)
   	CLRF 	D_1SEC ;1�� �ڸ��� ����� ���� �ʱ�ȭ ��Ų��.
   	CLRF	D_10SEC ;10�� �ڸ��� ����� ���� �ʱ�ȭ ��Ų��.

	BCF	PORTA,4 ; ������ �Ҵ�.
   	CALL	DELAY ; ������ �� �ð� ����
   	BSF	PORTA,4 ; ������ ����.
   	GOTO	MAIN ; ó������ ���ư���.
   	
   
SW_CHECK
	BTFSS	PORTB,3 ;SW3(����) �� ������
	GOTO	MAIN ; �������� ���ư���.
	BTFSS	PORTB,4 ;SW2(����) �� ������
	GOTO	STOP ; �����Ѵ�.
   	GOTO    SEC1_LOOP ; �Ѵ� �ȴ�������, ��� ������ ����.
   	
STOP	BTFSC	PORTB,5 ;SW3(����) �� ������ Ȯ���Ѵ�.
	GOTO	STOP2 ; �ȴ�������, ��� �����ִ´�.
	CALL	DELAY ;�������� ����� �ͼ�
	GOTO	SEC1_LOOP; �ٽ� ������ ����.
	
STOP2	BTFSC	PORTB,3 ;SW3(����) �� ������
	GOTO	STOP ; �ȴ�������, ��� �����ִ´�.
	GOTO	MAIN; �������� ���ư���.

	;LOOKUP_1 �� a,b,c,d,e,f �� ����
LOOKUP_1	ANDLW   0FH ;9���� ū ���� ������ 9 �ȿ��� ��������, ���ڸ� 4 ��Ʈ�� �츲
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
   	
	;LOOKUP_2 �� g, dot �� ����
LOOKUP_2	ANDLW   0FH ;9���� ū ���� ������ 9 �ȿ��� ��������, ���ڸ� 4 ��Ʈ�� �츲
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
 
DELAY	MOVLW	.1 ;������
DE_LOOP2	MOVWF	BUF
	MOVLW	.255
	MOVWF	BUF2
DE_LOOP1	DECFSZ	BUF2
	GOTO	DE_LOOP1
	DECFSZ	BUF
	GOTO	DE_LOOP2
	RETURN
	
initialize	MOVLW   B'00000000'
	MOVWF   COUNT ;�ð���� �ʱ�ȭ
  	MOVWF   D_10SEC ;1�� �ڸ� �ʱ�ȭ
  	MOVWF   D_1SEC ;10�� �ڸ� �ʱ�ȭ
  	MOVWF   FLAG ;10�� �ڸ����� ������ ���� �ʱ�ȭ (�ð���� �̼��� ��������)
  	RETURN
	END