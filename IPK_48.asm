;������ ���-48 V8
;��������� �� 14.01.2015

;-----------------------------------------------------------------------																					
.include	"m48def.inc"
.include	"IPKdef.inc"

.org	0x000
        rjmp	PRESET          ;Reset Handler

.org	0x001
	rjmp	AVAR		;INT0

.org	0x006
	rjmp	PRESET		;WDT

.org	0x009
	rjmp	INDIK		;TCNT2 OVF

.org	0x010
	rjmp	TIME_OUT	;TCNT0 OVF

.org	0x012		
	rjmp	Rx_DATA		;USART, RXC USART, Rx Complete

.org	0x014		
	rjmp	Tx_DATA		;USART, Tx Complete



.org    0x20
;.CSEG
PRESET:
 	cli

        ldi     r16,high(RAMEND); Main program start
        out     SPH,r16         ; Set Stack Pointer to top of RAM
        ldi     r16,low(RAMEND)
        out     SPL,r16
 
        ldi     r16,0b00001111  ; Define directions for port pins
        ldi     r17,0b00000000  ; Define pull-ups and set outputs high
        out     DDRB,r16
        out     PORTB,r17

        ldi     r16,0b01111100  ; Define directions for port pins
        ldi     r17,0b00000000  ; Define pull-ups and set outputs high
        out     DDRC,r16
        out     PORTC,r17

        ldi     r16,0b00011010  ; (R**) Define directions for port pins
        ldi     r17,0b00010111  ; Define pull-ups and set outputs high
        out     DDRD,r16
        out     PORTD,r17

;������� ���. ���������	
	clr	CLK_L
	clr	CLK_H
	clr	R_BIT

;������� ��� � 0100 �� 0170
	ldi	r31,0x01	
	clr	r30
	clr	r17
PRE:	st	Z+,r17
	cpi	r30,0x70
	brne	PRE

;������������� �������
	ldi	r16,M_GL_L	;������� ���� ������
	ldi	r28,low(GL_L)	;����� ��� 
	ldi	r29,high(GL_L)		;
	ldi	r19,4
	rcall	_RD

	
PRE_1:
	ldi	r16,M_MEM	;������� ���� ������ � EERAM
	ldi	r28,low(N_MEM)	;����� ��� � RAM
	ldi	r29,high(N_MEM)	;
	ldi	r19,1		;���������� ����������� ������ ������
	rcall	_RD
	lds	r17,N_MEM	;� �������� ������� �������� � EERAM
	cpi	r17,10
	brlo	pre_5
		
	clr	r16
	sts	N_MEM,r16
	ldi	r16,M_MEM
	ldi	r28,low(N_MEM)
	ldi	r29,high(N_MEM)
	ldi	r19,1
	rcall	_WRT	
	
pre_5:
	ldi	r16,M_STP_L	;��������� ����� �������� � EERAM
	ldi	r28,low(STP_L)	;����� ��� ��� STP � RAM
	ldi	r29,high(STP_L)	;
	ldi	r19, M_K_TM_H - M_STP_L + 1	;���������� ����������� ������ ������
	rcall	EE_RD
	clr	r16
	sts	W_BIT_H,r16
	lds	r16,W_BIT_L
	andi	r16,0x07
	cpi	r16,0x05
	brlo	PRE_2
	ldi	r16,0x01	;MOD_0
	sts	W_BIT_L,r16

;�������� ����������� ����
PRE_2:	lds	r16,STP_H
	cpi	r16,STP_H_MAX
	brsh	PRE_3
	cpi	r16,STP_H_MIN
	brlo	PRE_3
	rjmp	PRE_4

PRE_3:	ldi	r16,STP_H_DEF
	sts	STP_H,r16
	clr	r16
	sts	STP_L,r16

	ldi	r16,M_STP_L	;������� ���� ������
	ldi	r28,low(STP_L)	;����� ��� ��� 
	ldi	r29,high(STP_L)		;
	ldi	r19,2
	rcall	EE_WRT

	clr	r16
	sts	GL_L,r16
	sts	GL_M,r16
	sts	GL_H,r16
	sts	GL_Z,r16
	ldi	r16,M_GL_L
	ldi	r28,low(GL_L)
	ldi	r29,high(GL_L)
	ldi	r19,4
	rcall	_WRT	

PRE_4:	

;CNT0	TIME_OUT
	clr	r16
	out	TCNT0,r16
	ldi	r16,0b00000000   ;
	out	TCCR0A,r16
	out	TCCR0B,r16
	
;CNT1	Mode7
	clr	r16
	sts	TCNT1H,r16
	sts	TCNT1L,r16
	ldi	r16,0b10100011	;16/8 
	sts	TCCR1A,r16
	ldi	r16,0b00001010	;Fpwm=1,95kHz	
	sts	TCCR1B,r16

	lds	r16,PWM_N_H
	sts	OCR1AH,r16
	lds	r16,PWM_N_L
	sts	OCR1AL,r16
	
	lds	r16,PWM_M_H
	sts	OCR1BH,r16
	lds	r16,PWM_M_L
	sts	OCR1BL,r16


;CNT2	Mode3	
	ldi	r16,0b10100011
	sts	TCCR2A,r16
	ldi	r16,0b00000011
	sts	TCCR2B,r16	; 32/16=2mks (Tpwm = 0.512ms)
	clr	r16
	sts	OCR2A,r16	;�� ��
	ldi	r16,33
	sts	OCR2B,r16	;��� ���
	clr	r16
	sts	TCNT2,r16

;ADC
	clr	r16
	sts	ADC_N_L,r16		
	sts	ADC_N_H,r16
	ldi	r16,0b01000000    ;AVCC ref 
	sts	ADMUX,r16
	ldi	r16,0b11010111    ;F=125 kHz
	sts	ADCSRA,r16

;AC
	ldi	r16,0x00
	out	ACSR,r16

;USART_Init
        ldi     r17,00
        ldi     r16,51
        sts     UBRR0H,r17        ;c������� �������� 19.2 ����
        sts     UBRR0L,r16
 
        ldi     r16,0b00000000
        sts     UCSR0A,r16	

        ldi     r16,0b10010000	;RxD -enable	
        sts     UCSR0B,r16
 
        ldi     r16,0b00001110	   ;��� ���� ��������,2 �����
        sts     UCSR0C,r16
 
;INT0 Enable
	ldi	r16,0x02
	sts	EICRA,r16
	in	r16,EIMSK
	sbr	r16,(1<<INT0)
	out	EIMSK,r16

;TC0,TC2 int enable
	lds	r16,TIMSK0
	sbr	r16,(1<<TOIE0)
	sts	TIMSK0,r16

	lds	r16,TIMSK2
	sbr	r16,(1<<TOIE2)
	sts	TIMSK2,r16

;WDT Init
	wdr
	ldi	r16,0b00010000
	sts	WDTCSR,r16         
	ldi	r16,0b01000101
	sts	WDTCSR,r16
; Enable interrupts
lds	r16,UDR0
        sei           
	rjmp	MINE
;------------------------------------------------------------------------	
;------------------------------------------------------------------------	
;------------------------------------------------------------------------	
Tx_DATA:
	in	r2,SREG
	sts	STEK1,r16
	sts	STEK2,r17

	lds	r16,N_PAR
	dec	r16
	sts	N_PAR,r16
	breq	END_Tx

Tx_1:	lds	r16,UCSR0A
	sbrs	r16,UDRE0
	rjmp	Tx_1
	ld	r16,Z+
	sts	UDR0,r16
	
	out	SREG,r2
	lds	r16,STEK1
	lds	r17,STEK2
	reti

END_Tx:	
	ldi	r16,0b10010000
	sts	UCSR0B,r16

	out	SREG,r2
	lds	r16,STEK1
	lds	r17,STEK2
	reti
;------------------------------------------------------------------------	
Rx_DATA:
	in	r3,SREG
	sts	STEK3,r16
	sts	STEK4,r17

	;������ ����_����=0,6ms
	ldi	r16,105
	out	TCNT0,r16
	ldi	r16,0b00000011	;(64/16)*150=600mks
	out	TCCR0B,r16

;sbi	PORTC,2

	lds	r16,UDR0
	lds	r17,ST_SEND

	cpi	r17,0x00
	breq	Rx_0
	cpi	r17,0x01
	breq	Rx_1
	cpi	r17,0x02
	breq	Rx_2
	cpi	r17,0x03
	breq	Rx_3
	cpi	r17,0x04
	breq	Rx_4
	cpi	r17,0x05
	breq	Rx_5
	cpi	r17,0x06
	breq	Rx_6
	cpi	r17,0x07
	breq	Rx_7

	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END

Rx_0:	
	sts	ADR_DEV,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_1:	
	sts	N_KOM,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_2:	
	sts	R_DAT_0,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_3:	
	sts	R_DAT_1,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_4:	
	sts	R_DAT_2,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_5:	
	sts	R_DAT_3,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_6:	
	sts	R_DAT_4,r16	
	inc	r17
	sts	ST_SEND,r17
	rjmp	Rx_END
Rx_7:	
	sts	R_DAT_5,r16	
	inc	r17
	sts	ST_SEND,r17

Rx_END:	out	SREG,r3
	lds	r16,STEK3
	lds	r17,STEK4
;cbi	PORTC,2
	reti

;------------------------------------------------------------------------	
;------------------------------------------------------------------------	
TIME_OUT:
	in	r4,SREG
	push	r16
	push	r17
	push	r18
	push	r19

	;������� ST ����_����=0,6ms
	clr	r16
	out	TCNT0,r16
	ldi	r16,0b00000000
	out	TCCR0B,r16

;cbi	PORTC,2

	clr	r16
	sts	ST_SEND,r16

	lds	r16,ADR_DEV
	cpi	r16,0x01
	breq	TO_1
	rjmp	TO_END
	
TO_1:
	lds	r16,N_KOM
	cpi	r16,0x01
	brne	TO_2
	cbr	R_BIT,(1<<B_KOR)
	rjmp	T_GL

TO_2:	cpi	r16,0x02
	brne	TO_3
	cbr	R_BIT,(1<<B_KOR)
	rjmp	R_GL

TO_3:	cpi	r16,0x03
	brne	TO_4
	rjmp	T_ADC_N

TO_4:	cpi	r16,0x04
	brne	TO_5
	rjmp	R_PWM_N

TO_5:	cpi	r16,0x05
	brne	TO_6
	rjmp	T_ADC_M

TO_6:	cpi	r16,0x06
	brne	TO_7
	rjmp	R_PWM_M

TO_7:	cpi	r16,0x07
	brne	TO_8
	sbr	R_BIT,(1<<B_KOR)
	rjmp	T_ST_STP

TO_8:	cpi	r16,0x08
	brne	TO_9
	sbr	R_BIT,(1<<B_KOR)
	rjmp	R_ST_STP

TO_9:	cpi	r16,0x09
	brne	TO_10
	rjmp	T_NAT_MAX

TO_10:	cpi	r16,0x0A
	brne	TO_11
	rjmp	R_NAT_MAX

TO_11:	cpi	r16,0x0B
	brne	TO_12
	rjmp	T_K_NAT

TO_12:	cpi	r16,0x0C
	brne	TO_13
	rjmp	R_K_NAT

TO_13:	cpi	r16,0x0D
	brne	TO_14
	rjmp	T_W_BIT

TO_14:	cpi	r16,0x0E
	brne	TO_15
	rjmp	R_W_BIT

TO_15:	cpi	r16,0x0F
	brne	TO_16
	rjmp	T_STP

TO_16:	cpi	r16,0x10
	brne	TO_17
	rjmp	R_STP

TO_17:	cpi	r16,0x11
	brne	TO_18
	rjmp	T_GL_SPD_NAT_BIT

TO_18:	cpi	r16,0x12
	brne	TO_19
	rjmp	R_N_MEM

TO_19:	cpi	r16,0x13
	brne	TO_20
	rjmp	T_ALL_KONST

TO_20:	cpi	r16,0x14
	brne	TO_21
	sbr	R_BIT,(1<<B_SEEK)
	rjmp	TO_END

TO_21:	cpi	r16,0x15
	brne	TO_END
	rjmp	ADJ_MMG

TO_END:
	out	SREG,r4
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	reti

;------------------------------------------------------------------------	
;------------------------------------------------------------------------	

MINE:
	wdr
	sbic	PINB,4
	rcall	STDN
	sbic	PINB,5
	rcall	STUP

	;���������� ���
	in	r16,ACSR	
	sbrs	r16,ACO
	rjmp	M_1		;��� ���

	;���� ���
	lds	r16,W_BIT_H
	sbrc	r16,B_MMG
	rjmp	M_2
	sbr	r16,(1<<B_MMG)
	sts	W_BIT_H,r16
	cbi	PORTD,4		;TM MMG
	rjmp	M_2

	;��� ���
M_1:	lds	r16,W_BIT_H
	sbrs	r16,B_MMG
	rjmp	M_2
	cbr	r16,(1<<B_MMG)
	sts	W_BIT_H,r16
	sbi	PORTD,4		;TM MMG

	;�������� B_STOP1, B_STOP2
M_2:	andi	r16,0x42	;b01000010
	breq	M_3
	sbi	PORTC,6		;���� ���
	rjmp	MINE

M_3:	cbi	PORTC,6		;���� ����
	rjmp	MINE

;------------------------------------------------------------------------	
;------------------------------------------------------------------------	
;����� �� - ���������� �����
STUP:	sbi	PORTB,0		;����� ��������
	lds	r16,W_BIT_L
	sbrc	r16,F_INV	;��������?
	rjmp	STDN1

STUP1:
	cbi	PORTB,0		;����������� �������
	sbrc	R_BIT,B_KOR	;��������� STP?
	rjmp	STP_INC		;����� �� RET ���� ���������

	lds	r16,W_BIT_H
	cbr	r16,(1<<B_NAPR)	;�����
	sts	W_BIT_H,r16

	lds	r19,SUM_CM	;��������� ����� �����������
	andi	r19,0xF0
	rcall	I10_0

	lds	r16,SUM_CM	;�������� ��������� ����� �����������
	andi	r16,0xF0
	mov	r17,r19
	clc
	rcall	BCDsub		;r16-r17=>r16
	tst	r16
	brne	UP_1
	ret

UP_1:	
	sbr	R_BIT,(1<<B_STUP)

	cpi	r16,0x20
	brne	UP_2
	sbr	R_BIT,(1<<B_SEC);������� �������� �� ������ 
UP_2:	rcall	ST_SPD		;������� �� �� ���
	rcall	GL_INC

	;�������� ������ ��������
	lds	r16,W_BIT_L
	sbrs	r16,F_RAZ	;��������?
	ret

;-------��������----------------------------------------------------
	sbis	PORTC,3		;�������� ������ ��������������?
	rjmp	UP2_1

	;������ ����� ��������������
	lds	r16,ST_MAGN	;
	dec	r16		;
	sts	ST_MAGN,r16	;
	brne	UP2_2	
	cbi	PORTC,3		;����� ������� ��������������
	ret

UP2_1:	;����� ���� ������� 10�
	lds	r16,SUM_M	;�����
	tst	r16		;
	breq	UP2_2		;00 �� �� -������ 10� - �����
	
	lds	r16,SUM_CM	;����������
	andi	r16,0xF0	;
	tst	r16		;
	brne	UP2_2		;�� �� �0 - �����

	;������ ��=0
	lds	r16,SUM_DM	;���������
	tst	r16
	breq	UP2_4		;DM=0 - ��������� 10�
	cpi	r16,0x10	;101� ?
	breq	UP2_3
UP2_2:	ret		

UP2_3:	;������ DM=10 �.�. 1�
	lds	r16,SUM_M
	andi	r16,0x0F	;�������� ��������� 100�
	brne	UP2_2		;
			
UP2_4:	sbi	PORTC,3		;��������� ����. ��������������
	ldi	r16,20		;20 �� - ����� �������������� �������
	sts	ST_MAGN,r16	;
	ret

;-----------------------------------------------------------------------		
I10_0:	;��������� 4-� BDC ������ 
	lds	r16,SUM_MM
	lds	r17,STP_L
	clc
	rcall	BCDadd
	sts	SUM_MM,r16
	sbrc	r17,0
	sec
	
	lds	r16,SUM_CM
	lds	r17,STP_H
	rcall	BCDadd
	sts	SUM_CM,r16
	sbrs	r17,0
	ret
	
	lds	r16,GL_Z	;���� ������� ������������
	sbrs	r16,7
	rjmp	I10_2
	clr	r16
	sts	SUM_DM,r16
	sts	SUM_M,r16
	ret

I10_2:	lds	r16,SUM_DM
	ldi	r17,0x01
	clc
	rcall	BCDadd
	sts	SUM_DM,r16
	sbrs	r17,0
	ret

I10_3:	lds	r16,SUM_M
	ldi	r17,0x01
	clc
	rcall	BCDadd
	sts	SUM_M,r16
;	sbrs	r17,0
	ret

;-----------------------------------------------------------------------
GL_INC:	
	swap	r16
	lds	r17,GL_L
	add	r17,r16
	sts	GL_L,r17
	brcc	INK_1

	clr	r16
	lds	r17,GL_M
	adc	r17,r16
	sts	GL_M,r17
	brcc	INK_1

	lds	r17,GL_H
	adc	r17,r16
	sts	GL_H,r17
	brcc	INK_1

	lds	r17,GL_Z
	adc	r17,r16
	sts	GL_Z,r17
	
INK_1:	ret
;-----------------------------------------------------------------------
STP_INC:	
	ldi	r16,0x01
	lds	r17,ST_STP_L
	add	r17,r16
	sts	ST_STP_L,r17
	brcc	STP_INC_EXIT

	clr	r16
	lds	r17,ST_STP_M
	adc	r17,r16
	sts	ST_STP_M,r17
	brcc	STP_INC_EXIT

	lds	r17,ST_STP_H
	adc	r17,r16
	sts	ST_STP_H,r17
	brcc	STP_INC_EXIT

	lds	r17,ST_STP_Z
	adc	r17,r16
	sts	ST_STP_Z,r17
STP_INC_EXIT:
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;������ ��-���������� �����
STDN:	sbi	PORTB,0		;����� ��������
	lds	r16,W_BIT_L
	sbrc	r16,F_INV	;�������� �� ��������
	rjmp	STUP1

STDN1:	
	cbi	PORTB,0
	sbrc	R_BIT,B_KOR	;��������� STP?
	rjmp	STP_DCR		;����� �� RET ���� ���������

	lds	r16,W_BIT_H
	sbr	r16,(1<<B_NAPR)	;������
	sts	W_BIT_H,r16

	lds	r19,SUM_CM	;��������� ����� ��
	andi	r19,0xF0
	rcall	D10_0

	lds	r17,SUM_CM	;���� ��������� � ��?
	andi	r17,0xF0
	mov	r16,r19
	clc
	rcall	BCDsub		;r16-r17=>r
	tst	r16
	brne	DN_1
	ret

DN_1:
	sbr	R_BIT,(1<<B_STDN)
DN_9:	cpi	r16,0x20
	brne	DN_2
	sbr	R_BIT,(1<<B_SEC)

DN_2:
	rcall	ST_SPD		;������� �� �� ���
	rcall	GL_DCR
	ret	

;-----------------------------------------------------------------------		
D10_0:	;��������� 4-x BDC ������
	lds	r16,SUM_MM
	lds	r17,STP_L
	clc
	rcall	BCDsub
	sts	SUM_MM,r16
	sbrc	r17,0
	sec

	lds	r16,SUM_CM
	lds	r17,STP_H
	rcall	BCDsub
	sts	SUM_CM,r16
	sbrs	r17,0
	ret

	lds	r16,GL_Z	;���� ������� ������������
	sbrs	r16,7
	rjmp	D10_2
	clr	r16
	sts	SUM_DM,r16
	sts	SUM_M,r16
	ret	

D10_2:	lds	r16,SUM_DM
	ldi	r17,0x01
	clc
	rcall	BCDsub
	sts	SUM_DM,r16
	sbrs	r17,0
	ret

D10_3:	lds	r16,SUM_M
	ldi	r17,0x01
	clc
	rcall	BCDsub
	sts	SUM_M,r16
;	sbrs	r17,0
	ret

;-----------------------------------------------------------------------																					
GL_DCR:
	swap	r16
	lds	r17,GL_L
	sub	r17,r16
	sts	GL_L,r17
	brcc	DCR_1

	clr	r16
	lds	r17,GL_M
	sbc	r17,r16
	sts	GL_M,r17
	brcc	DCR_1

	lds	r17,GL_H
	sbc	r17,r16
	sts	GL_H,r17
	brcc	DCR_1

	lds	r17,GL_Z
	sbc	r17,r16
	sts	GL_Z,r17
DCR_1:	ret
;-----------------------------------------------------------------------																					
STP_DCR:
	ldi	r16,0x01
	lds	r17,ST_STP_L
	sub	r17,r16
	sts	ST_STP_L,r17
	brcc	DCR_1

	clr	r16
	lds	r17,ST_STP_M
	sbc	r17,r16
	sts	ST_STP_M,r17
	brcc	DCR_1

	lds	r17,ST_STP_H
	sbc	r17,r16
	sts	ST_STP_H,r17
	brcc	DCR_1

	lds	r17,ST_STP_Z
	sbc	r17,r16
	sts	ST_STP_Z,r17
	ret
;-----------------------------------------------------------------------																					
ST_SPD:
	mov	r17,r16
	swap	r17
	lds	r18,ST_VEL_L
	lds	r19,ST_VEL_H
	add	r18,r17
	clr	r17
	adc	r19,r17
	sts	ST_VEL_L,r18
	sts	ST_VEL_H,r19
	ret

;-----------------------------------------------------------------------																					
ADJ_MMG:
	lds	r16,R_DAT_1
	sts	PWM_M_H,r16
	sts	OCR1BH,r16
	lds	r16,R_DAT_0
	sts	PWM_M_L,r16
	sts	OCR1BL,r16

	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16


	lds	r16,ADC_M_L
	sts	T_DAT_2,r16
	lds	r16,ADC_M_H
	sts	T_DAT_3,r16

	lds	r16,W_BIT_L
	sts	T_DAT_4,r16
	lds	r16,W_BIT_H
	sts	T_DAT_5,r16

	ldi	r16,6
	rcall	D_TRANSMIT
	rjmp	TO_END

;-----------------------------------------------------------------------																					
NAT_0:	;���� ��������� ����� ������������ ��������������� � ������ ����32 ( 128�� )

	lds	r16,TEMP3
	tst	r16
	brne	PE2_1

	;������ ������ ��������� �������� ����� =512
	ldi	r16,10
	sts	TEMP3,r16
	ldi	r27,0b00000010
	clr	r26
	ldi	r17,0b00000010
	clr	r16
	rjmp	PE2_4

PE2_1:	;��������� �������
	lds	r16,TEMP3
	dec	r16
	sts	TEMP3,r16	
	breq	PE2_5	;���� =0 �� �����

	;�������� ������ � 8 ������
	lds	r16,ADCL	;��������� ���
	lds	r17,ADCH
	tst	r17
	brne	PE2_2

	cpi	R16,8
	brlo	PE2_3		;������ 8 - ���� �� ���������� S

	;��� ������ 8 - ��������� S
PE2_2:
	lds	r26,OCR1AL
	lds	r27,OCR1AH
	lds	r16,TEMP1
	lds	r17,TEMP2
	sub	r26,r16
	sbc	r27,r17
	clc
	ror	r17
	ror	r16
	or	r26,r16
	or	r27,r17
	rjmp	PE2_4
	
PE2_3:	;��� ������ 8 - ����������� S
	lds	r26,OCR1AL
	lds	r27,OCR1AH
	lds	r16,TEMP1
	lds	r17,TEMP2
	clc
	ror	r17
	ror	r16
	or	r26,r16
	or	r27,r17

PE2_4:
	sts	OCR1AH,r27
	sts	OCR1AL,r26
	sts	TEMP1,r16
	sts	TEMP2,r17
	ret

	;����� �����
PE2_5:	cbr	R_BIT,(1<<B_SEEK)
	sts	PWM_N_L,r26
	sts	PWM_N_H,r27

	ldi	r16,M_PWM_N_L
	ldi	r28,low(PWM_N_L)	;OCR1A_L
	ldi	r29,high(PWM_N_L)
	ldi	r19,2
	rcall	EE_WRT
	ret
;-----------------------------------------------------------------------																					
;-----------------------------------------------------------------------																					
;-----------------------------------------------------------------------
SPEED:	
	clr	r18
	clr	r19	
	lds	r16,N_BUF_2	;����� ���� ���������
	lds	r17,N_BUF_3
	sts	N_BUF_4,r16
	sts	N_BUF_5,r17
	add	r18,r16
	adc	r19,r17
	lds	r16,N_BUF_0
	lds	r17,N_BUF_1
	sts	N_BUF_2,r16
	sts	N_BUF_3,r17
	add	r18,r16
	adc	r19,r17
	lds	r16,ST_VEL_L
	lds	r17,ST_VEL_H
	sts	N_BUF_0,r16
	sts	N_BUF_1,r17
	add	r18,r16
	adc	r19,r17
	sts	SPD_L,r18
	sts	SPD_H,r19
	clr	r16
	sts	ST_VEL_L,r16
	sts	ST_VEL_H,r16
	ret	

;------------------------------------------------------------------------	
ADC_N:	;� ����������� �� 32 ����� �� 4,096 �� (131 mc)
	lds	r16,ADCL
	lds	r17,ADCH
	ldi	r18,0x08	;8 - ����� ���� ���-���������
	ldi	r19,0x00

	sub	r16,r18
	sbc	r17,r19
	brcc	ADC_0

	clr	r16
	clr	r17

ADC_0:	lds	r18,T_ADC_L
	lds	r19,T_ADC_H
	add	r16,r18		;���������� �����������, r10-�������
	adc	r17,r19
	sts	T_ADC_L,r16
	sts	T_ADC_H,r17

	lds	r16,ST_ADC
	inc	r16
	sts	ST_ADC,r16
	cpi	r16,32
	brne	ADC_1

	;����� ����������
	lds	r16,T_ADC_L
	sts	ADC_N_L,r16
	lds	r16,T_ADC_H
	sts	ADC_N_H,r16

	clr	r16
	sts	ST_ADC,r16
	sts	T_ADC_L,r16
	sts	T_ADC_H,r16

	rcall	TM_N

	;���������� ���� �� 10 �������� �� 131 ��
	sbrc	R_BIT,B_SEEK
	rcall	NAT_0	
	
ADC_1:	ldi	r16,0b01000001    ;5,0v ref , ���� 1 
	sts	ADMUX,r16	
	ldi	r16,0b11010110
	sts	ADCSRA,r16
	
	ret	
;------------------------------------------------------------------------
ADC_M:	;��� ���������� ������ 4 ��
	lds	r16,ADCL
	sts	ADC_M_L,r16

	lds	r16,ADCH
	sts	ADC_M_H,r16

	ldi	r16,0b01000000    ;5,0v ref , ���� 0 
	sts	ADMUX,r16	
	ldi	r16,0b11010110
	sts	ADCSRA,r16
	ret	
;------------------------------------------------------------------------
D_TRANSMIT:
	dec	r16
	sts	N_PAR,r16
	ldi	r30,0x46
	ldi	r31,0x01

RS_1:	lds	r16,UCSR0A
	sbrs	r16,UDRE0
	rjmp	RS_1
	ld	r16,Z+
	sts	UDR0,r16
    
        ldi     r16,0b01000000
        sts     UCSR0A,r16
	ldi	r16,0b01001000
	sts	UCSR0B,r16

RS_2:	lds	r16,UCSR0A
	sbrs	r16,UDRE0
	rjmp	RS_2
	ld	r16,Z+
	sts	UDR0,r16
RS_END:	ret	

;------------------------------------------------------------------------
EE_WRT:
	lds	r17,N_MEM
	swap	r17
	or	r16,r17
_WRT: 
	cli
_WRT_EE_LOOP: 
	sbic	EECR,EEWE
	rjmp	_WRT_EE_LOOP
	out	EEARL,r16
	ld	r18,Y+
	out	EEDR,r18
	sbi	EECR,EEMWE
	sbi	EECR,EEWE	
	inc	r16
	dec	r19
	tst	r19
	brne _WRT_EE_LOOP

	sei
	ret	

;-----------------------------------------------------------------------
EE_RD:
	lds	r17,N_MEM
	swap	r17
	or	r16,r17
_RD:
	cli
_RD_EE_LOOP:
	sbic	EECR,EEWE	;if EEWE not clear
	rjmp	_RD_EE_LOOP
	out	EEARL,r16	;output address low for 48
	sbi	EECR,EERE	;set EEPROM Read strobe
	in	r18,EEDR	;get data
	st	Y+,r18
	inc	r16
	dec	r19
	tst	r19
	brne _RD_EE_LOOP

	sei
	ret

;-----------------------------------------------------------------------
AVAR:;	sbi	PORTA,2
	ldi	r16,M_GL_L
	ldi	r28,low(GL_L)
	ldi	r29,high(GL_L)
	ldi	r19,4
	rcall	_WRT
AVAR1:	sbic	PIND,2
	rjmp	PRESET
	wdr
	rjmp	AVAR1

;------------------------------------------------------------------------
;* This subroutine adds the two unsigned 2-digit BCD numbers 
;* "BCD1" and "BCD2". The result is returned in "BCD1", and the overflow 
;* carry in C.
BCDadd:
	ldi	r18,6		;value to be added later
	adc	r16,r17  	;add the numbers binary
	clr	r17		;clear BCD carry
	brcc	add_0		;if carry not clear
	ldi	r17,1		;    set BCD carry
add_0:	brhs	add_1		;if half carry not set
	add	r16,r18 	;    add 6 to LSD
	brcc	add_c
	ldi	r17,1
add_c:	brhs	add_2		;    if half carry not set (LSD <= 9)
	subi	r16,6		;        restore value
	rjmp	add_2		;else
add_1:	add	r16,r18 	;    add 6 to LSD
add_2:	swap	r18
	add	r16,r18 	;add 6 to MSD
	brcs	add_4		;if carry not set (MSD <= 9)
	sbrs	r17,0		;    if previous carry not set
	subi	r16,$60	        ;	restore value 
add_3:	ret			;else

add_4:	ldi	r17,1		;    set BCD carry
	ret

;------------------------------------------------------------------------
;* This subroutine subtracts the two unsigned 2-digit BCD numbers 
;* "BCDa" and "BCDb" (BCDa - BCDb ). The result is returned in "BCDa", and 
;* the underflow carry in C.
BCDsub:
	sbc	r16,r17		;subtract the numbers binary
	clr	r17
	brcc	sub_0		;if carry not clear
	ldi	r17,1		;    store carry in BCDB1, bit 0
sub_0:	brhc	sub_1		;if half carry not clear
	subi	r16,$06		;    LSD = LSD - 6
sub_1:	sbrs	r17,0		;if previous carry not set
	ret			;    return
	subi	r16,$60		;subtract 6 from MSD
	ldi	r17,1		;set underflow carry
	brcc	sub_2		;if carry not clear
	ldi	r17,1		;    clear underflow carry	
sub_2:	ret

;------------------------------------------------------------------------
TM_N:
	lds	r16,ADC_N_L
	lds	r17,ADC_N_H

TM_1:	lds	r18,K_TM_L
	lds	r19,K_TM_H

	mul	r16,r19
	mov	r16,r1
	mul	r17,r18
	add	r16,r1
	brcs	TM_3
	clc
	mul	r17,r19
	add	r16,r0
	brcs	TM_3

TM_2:	tst	r1
	breq	TM_4

TM_3:	ldi	r16,0xFF

TM_4:	sts	OCR2A,r16

	ret
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
INDIK:
;sbi	PORTC,2
;	wdr
	in	r5,SREG
	sts	STEK7,r16
	sts	STEK8,r17
	sts	STEK9,r18
	sts	STEK10,r19

;������������ -ST,+ST
	sbrc	R_BIT,B_STUP
	rjmp	MOD_OUT
	sbrc	R_BIT,B_STDN
	rjmp	MOD_OUT
	rjmp	IND_9

MOD_OUT:
	lds	r16,W_BIT_L
	sbrc	r16,F_MOD1
	rjmp	INCD
	sbrc	r16,F_MOD2
	rjmp	DIR

	;������� �����
SIMPL:	sbrs	R_BIT,B_ISP
	rjmp	IND_2

	cbr	R_BIT,(1<<B_ISP)
	cbi	PORTC,5
	cbi	PORTC,4
	sbrs	R_BIT,B_SEC
	rjmp	IND_1
	cbr	R_BIT,(1<<B_SEC)
	rjmp	IND_9

IND_1:	cbr	R_BIT,(1<<B_STDN)
	cbr	R_BIT,(1<<B_STUP)
	rjmp	IND_9

IND_2:	sbrs	R_BIT,B_STUP
	rjmp	IND_3
	sbi	PORTC,4
	sbr	R_BIT,(1<<B_ISP)
	rjmp	IND_9

IND_3:	sbrs	R_BIT,B_STDN
	rjmp	IND_9			
	sbi	PORTC,5
	sbr	R_BIT,(1<<B_ISP)
	rjmp	IND_9

	;�������
INCD:	lds	r16,ST_OUT
	cpi	r16,0x00
	breq	INC_1
	cpi	r16,0x01
	breq	INC_2
	cpi	r16,0x02
	breq	INC_3
	rjmp	INC_4
	;������ ������
INC_1:	inc	r16
	sts	ST_OUT,r16
	sbrs	R_BIT,B_STUP
	rjmp	INC_1a
	cbi	PORTC,5
	rjmp	IND_9
INC_1a:	sbrs	R_BIT,B_STDN
	rjmp	IND_9			
	cbi	PORTC,4
	rjmp	IND_9

	;������ ������
INC_2:	inc	r16
	sts	ST_OUT,r16
	sbrs	R_BIT,B_STUP
	rjmp	INC_2a
	cbi	PORTC,4
	rjmp	IND_9
INC_2a:	cbi	PORTC,5
	rjmp	IND_9

	;������ ������
INC_3:	inc	r16
	sts	ST_OUT,r16
	sbrs	R_BIT,B_STUP
	rjmp	INC_3a
	sbi	PORTC,5
	rjmp	IND_9
INC_3a:	sbi	PORTC,4
	rjmp	IND_9

	;��������� ������
INC_4:	clr	r16
	sts	ST_OUT,r16
	sbi	PORTC,4
	sbi	PORTC,5
	sbrs	R_BIT,B_SEC
	rjmp	INC_4a
	cbr	R_BIT,(1<<B_SEC)
	rjmp	IND_9

INC_4a:	cbr	R_BIT,(1<<B_STUP)
	cbr	R_BIT,(1<<B_STDN)
	rjmp	IND_9

	;���-�����������
DIR:	sbrs	R_BIT,B_ISP
	rjmp	DIR_2

	cbr	R_BIT,(1<<B_ISP)
	cbi	PORTC,4
	sbrs	R_BIT,B_SEC
	rjmp	DIR_1
	cbr	R_BIT,(1<<B_SEC)
	rjmp	IND_9

DIR_1:	cbr	R_BIT,(1<<B_STDN)
	cbr	R_BIT,(1<<B_STUP)
	rjmp	IND_9

DIR_2:	sbrs	R_BIT,B_STUP
	rjmp	DIR_3
	sbi	PORTC,4
	sbi	PORTC,5
	sbr	R_BIT,(1<<B_ISP)
	rjmp	IND_9
DIR_3:	sbrs	R_BIT,B_STDN
	rjmp	IND_9			
	sbi	PORTC,4
	cbi	PORTC,5
	sbr	R_BIT,(1<<B_ISP)
;	rjmp	IND_9


;������� ������ 0,512ms	
IND_9:	ldi	r16,0x01
	add	CLK_L,r16
	brcc	IND_11
	add	CLK_H,r16
;4ms-����������� ���������� ���_� ��� ���_�
IND_11:	mov	r16,CLK_L
	andi	r16,0x07
	cpi	r16,0x04
	brne	IND_12
	rcall	ADC_N
	rjmp	IND_13
		
IND_12:
	cpi	r16,0x00
	brne	IND_13
	rcall	ADC_M

;1s-������� ��������
IND_13:	mov	r16,CLK_H
	cpi	r16,0x07
	brne	D_CR
	mov	r16,CLK_L
	cpi	r16,0xA1
	brne	D_CR
	rcall	SPEED
	clr	r16
	clr	CLK_H
	clr	CLK_L
	sts	ST_VEL_L,r16
	sts	ST_VEL_H,r16

D_CR:	wdr
	out	SREG,r5
	lds	r16,STEK7
	lds	r17,STEK8
	lds	r18,STEK9
	lds	r19,STEK10
;cbi	PORTC,2
	reti
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------																					
;*******������������ ������ � ������� ���������*************************																					
;-----------------------------------------------------------------------																					
T_GL:
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16


	lds	r16,GL_L
	sts	T_DAT_2,r16
	lds	r16,GL_M
	sts	T_DAT_3,r16
	lds	r16,GL_H
	sts	T_DAT_4,r16
	lds	r16,GL_Z
	sts	T_DAT_5,r16

	ldi	r16,6
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					

R_GL:
	lds	r16,R_DAT_0
	sts	GL_L,r16
	lds	r16,R_DAT_1
	sts	GL_M,r16
	lds	r16,R_DAT_2
	sts	GL_H,r16
	lds	r16,R_DAT_3
	sts	GL_Z,r16
	lds	r16,R_DAT_4
	sts	SUM_DM,r16
	lds	r16,R_DAT_5
	sts	SUM_M,r16

	clr	r16
	sts	SUM_MM,r16
	sts	SUM_CM,r16
;	sts	SUM_DM,r16
;	sts	SUM_M,r16
	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_ADC_N:
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16


	lds	r16,ADC_N_L
	sts	T_DAT_2,r16
	lds	r16,ADC_N_H
	sts	T_DAT_3,r16

	ldi	r16,4
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_PWM_N:			;� �����
;cbi	PORTC,5
	lds	r16,R_DAT_0
	sts	PWM_N_L,r16
	sts	OCR1AL,r16
	lds	r16,R_DAT_1
	sts	PWM_N_H,r16
	sts	OCR1AH,r16
	
	ldi	r16,M_PWM_N_L
	ldi	r28,low(PWM_N_L)
	ldi	r29,high(PWM_N_L)
	ldi	r19,2
	rcall	EE_WRT	
	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_ADC_M:
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16


	lds	r16,ADC_M_L
	sts	T_DAT_2,r16
	lds	r16,ADC_M_H
	sts	T_DAT_3,r16

	ldi	r16,4
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_PWM_M:			;� �����
;cbi	PORTC,5
	lds	r16,R_DAT_0
	sts	PWM_M_L,r16
	sts	OCR1BL,r16
	lds	r16,R_DAT_1
	sts	PWM_M_H,r16
	sts	OCR1BH,r16

	ldi	r16,M_PWM_M_L
	ldi	r28,low(PWM_M_L)
	ldi	r29,high(PWM_M_L)
	ldi	r19,2
	rcall	EE_WRT	
	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_ST_STP:			
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16

	lds	r16,ST_STP_L
	sts	T_DAT_2,r16
	lds	r16,ST_STP_M
	sts	T_DAT_3,r16
	lds	r16,ST_STP_H
	sts	T_DAT_4,r16
	lds	r16,ST_STP_Z
	sts	T_DAT_5,r16

	ldi	r16,6
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_ST_STP:			
	lds	r16,R_DAT_0
	sts	ST_STP_L,r16
	lds	r16,R_DAT_1
	sts	ST_STP_M,r16
	lds	r16,R_DAT_2
	sts	ST_STP_H,r16
	lds	r16,R_DAT_3
	sts	ST_STP_Z,r16

	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_NAT_MAX:			;�� ������
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16

	lds	r16,NAT_MAX_L
	sts	T_DAT_2,r16
	lds	r16,NAT_MAX_H
	sts	T_DAT_3,r16

	ldi	r16,4
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_NAT_MAX:			;� �����
;cbi	PORTC,5
	lds	r16,R_DAT_0
	sts	NAT_MAX_L,r16
	lds	r16,R_DAT_1
	sts	NAT_MAX_H,r16

	ldi	r16,M_NAT_MAX_L
	ldi	r28,low(NAT_MAX_L)
	ldi	r29,high(NAT_MAX_L)
	ldi	r19,2
	rcall	EE_WRT	
	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_K_NAT:			;�� ������
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16

	lds	r16,K_NAT_L
	sts	T_DAT_2,r16
	lds	r16,K_NAT_H
	sts	T_DAT_3,r16

	ldi	r16,4
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_K_NAT:			;� �����
;cbi	PORTC,5
	lds	r16,R_DAT_0
	sts	K_NAT_L,r16
	lds	r16,R_DAT_1
	sts	K_NAT_H,r16


K_TM:	lds	r16,R_DAT_2
	sts	K_TM_L,r16
	lds	r16,R_DAT_3
	sts	K_TM_H,r16


	ldi	r16,M_K_NAT_L
	ldi	r28,low(K_NAT_L)
	ldi	r29,high(K_NAT_L)
	ldi	r19,4
	rcall	EE_WRT	
	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_W_BIT:			;�� ������
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16

	lds	r16,W_BIT_L
	sts	T_DAT_2,r16
	lds	r16,W_BIT_H
	sts	T_DAT_3,r16

	ldi	r16,4
	rcall	D_TRANSMIT
	rjmp	TO_END

;-----------------------------------------------------------------------																					
R_W_BIT:			;� �����
;cbi	PORTC,5
	lds	r16,R_DAT_1
	sts	W_BIT_H,r16

	lds	r19,W_BIT_L
	lds	r16,R_DAT_0
	cp	r19,r16
	brne	BIT_1
	rjmp	TO_END

BIT_1:	sts	W_BIT_L,r16
	ldi	r16,M_W_BIT_L
	ldi	r28,low(W_BIT_L)
	ldi	r29,high(W_BIT_L)
	ldi	r19,2
	rcall	EE_WRT	
	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_STP:			;�� ������
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16

	lds	r16,STP_L
	sts	T_DAT_2,r16
	lds	r16,STP_H
	sts	T_DAT_3,r16

	ldi	r16,4
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_STP:			;� �����
;cbi	PORTC,5
	lds	r16,R_DAT_0
	sts	STP_L,r16
	lds	r16,R_DAT_1
	sts	STP_H,r16

	ldi	r16,M_STP_L
	ldi	r28,low(STP_L)
	ldi	r29,high(STP_L)
	ldi	r19,2
	rcall	EE_WRT	
	rjmp	TO_END

;-----------------------------------------------------------------------																					
T_GL_SPD_NAT_BIT:
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_KOM
	sts	T_DAT_1,r16

	lds	r16,GL_L
	sts	T_DAT_2,r16
	lds	r16,GL_M
	sts	T_DAT_3,r16
	lds	r16,GL_H
	sts	T_DAT_4,r16
	lds	r16,GL_Z
	sts	T_DAT_5,r16

	lds	r16,ADC_N_L
	sts	T_DAT_6,r16
	lds	r16,ADC_N_H
	sts	T_DAT_7,r16

	lds	r16,SPD_L
	sts	T_DAT_8,r16
	lds	r16,SPD_H
	sts	T_DAT_9,r16

	lds	r16,W_BIT_L
	sts	T_DAT_10,r16
	lds	r16,W_BIT_H
	sts	T_DAT_11,r16

	ldi	r16,12
	rcall	D_TRANSMIT
	rjmp	TO_END
;-----------------------------------------------------------------------																					
R_N_MEM:			;� �����
	lds	r16,R_DAT_0
	sts	N_MEM,r16

	ldi	r16,M_MEM
	ldi	r28,low(N_MEM)
	ldi	r29,high(N_MEM)
	ldi	r19,1
	rcall	_WRT
		
	ldi	r16,M_STP_L	;��������� ����� �������� � EERAM
	ldi	r28,low(STP_L)	;����� ��� ��� STP � RAM
	ldi	r29,high(STP_L)	;
	ldi	r19,14		;���������� ����������� ������ ������
	rcall	EE_RD
	clr	r16
	sts	W_BIT_H,r16
	lds	r16,W_BIT_L
	andi	r16,0x07
	cpi	r16,0x05
	brlo	T_ALL_KONST
	ldi	r16,0x01	;MOD_0
	sts	W_BIT_L,r16
;	rjmp	TO_END
;-----------------------------------------------------------------------																					
T_ALL_KONST:
	lds	r16,ADR_DEV
	sts	T_DAT_0,r16
	lds	r16,N_MEM	;N_MEM!!! � �� N_KOM
	sts	T_DAT_1,r16

	lds	r16,PWM_N_L
	sts	T_DAT_2,r16
	lds	r16,PWM_N_H
	sts	T_DAT_3,r16

	lds	r16,PWM_M_L
	sts	T_DAT_4,r16
	lds	r16,PWM_M_H
	sts	T_DAT_5,r16

	lds	r16,NAT_MAX_L
	sts	T_DAT_6,r16
	lds	r16,NAT_MAX_H
	sts	T_DAT_7,r16

	lds	r16,K_NAT_L
	sts	T_DAT_8,r16
	lds	r16,K_NAT_H
	sts	T_DAT_9,r16

	lds	r16,STP_L
	sts	T_DAT_10,r16
	lds	r16,STP_H
	sts	T_DAT_11,r16

	ldi	r16,12
	rcall	D_TRANSMIT
	rjmp	TO_END
