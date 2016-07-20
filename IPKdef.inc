; смещения констант в EEPROM
.equ	M_STP_L		=$02		
.equ	M_STP_H		=$03   		
.equ	M_PWM_N_L	=$04 		
.equ	M_PWM_N_H	=$05		
.equ	M_PWM_M_L	=$06		
.equ	M_PWM_M_H	=$07		
.equ	M_NAT_MAX_L	=$08		
.equ	M_NAT_MAX_H	=$09		
.equ	M_W_BIT_L	=$0A		
.equ	M_W_BIT_H	=$0B
.equ	M_K_NAT_L	=$0C		
.equ	M_K_NAT_H	=$0D		
.equ	M_K_TM_L	=$0E		
.equ	M_K_TM_H	=$0F		
				
.equ	M_GL_L		=$f0		
.equ	M_GL_M		=$f1		
.equ	M_GL_H		=$f2		
.equ	M_GL_Z		=$f3

.equ	M_MEM		=$f5

; Глобальные переменные
; Константы в ОЗУ
.equ	STP_L		=$0100		
.equ	STP_H		=$0101		
.equ	PWM_N_L		=$0102		
.equ	PWM_N_H		=$0103		
.equ	PWM_M_L		=$0104		
.equ	PWM_M_H		=$0105
.equ	NAT_MAX_L	=$0106		
.equ	NAT_MAX_H	=$0107		
.equ	W_BIT_L		=$0108		
.equ	W_BIT_H		=$0109		
.equ	K_NAT_L		=$010A		
.equ	K_NAT_H		=$010B
.equ	K_TM_L		=$010C		
.equ	K_TM_H		=$010D		


;рассчитанные и считанные значения
.equ	SUM_MM		=$0114
.equ	SUM_CM		=$0115
.equ	SUM_DM		=$0116
.equ	SUM_M		=$0117

.equ	GL_L		=$0118		
.equ	GL_M		=$0119		
.equ	GL_H		=$011A
.equ	GL_Z		=$011B

.equ	ST_STP_L	=$011C
.equ	ST_STP_M	=$011D
.equ	ST_STP_H	=$011E
.equ	ST_STP_Z	=$011F
		
.equ	ST_VEL_L	=$0120
.equ	ST_VEL_H	=$0121
.equ	ST_MAGN		=$0122
.equ	ST_ADC		=$0123

.equ	ADC_M_L		=$0124		
.equ	ADC_M_H		=$0125
.equ	ADC_N_L		=$0126
.equ	ADC_N_H		=$0127
.equ	T_ADC_L		=$0128
.equ	T_ADC_H		=$0129
.equ	N_PAR		=$012A
.equ	K_FLAGS		=$012B		
.equ	ST_SEND		=$012C

.equ	SPD_L		=$012D
.equ	SPD_H		=$012E

.equ	ST_OUT		=$012F

.equ	N_BUF_0		=$0130
.equ	N_BUF_1		=$0131
.equ	N_BUF_2		=$0132
.equ	N_BUF_3		=$0133
.equ	N_BUF_4		=$0134
.equ	N_BUF_5		=$0135

.equ	N_MEM		=$013A

; Данные запроса по UART
.equ	ADR_DEV		=$013E
.equ	N_KOM		=$013F
.equ	R_DAT_0		=$0140
.equ	R_DAT_1		=$0141
.equ	R_DAT_2		=$0142
.equ	R_DAT_3		=$0143
.equ	R_DAT_4		=$0144
.equ	R_DAT_5		=$0145

; Данные ответа по UART
.equ	T_DAT_0		=$0146
.equ	T_DAT_1		=$0147
.equ	T_DAT_2		=$0148
.equ	T_DAT_3		=$0149
.equ	T_DAT_4		=$014A
.equ	T_DAT_5		=$014B
.equ	T_DAT_6		=$014C
.equ	T_DAT_7		=$014D
.equ	T_DAT_8		=$014E
.equ	T_DAT_9		=$014F
.equ	T_DAT_10	=$0150
.equ	T_DAT_11	=$0151
.equ	T_DAT_12	=$0152
.equ	T_DAT_13	=$0153
.equ	T_DAT_14	=$0154
.equ	T_DAT_15	=$0155
.equ	T_DAT_16	=$0156
.equ	T_DAT_17	=$0157

.equ	TEMP1		=$0158
.equ	TEMP2		=$0159
.equ	TEMP3		=$015A
.equ	TEMP4		=$015B


.equ	STEK1		=$015C
.equ	STEK2		=$015D
.equ	STEK3		=$015E
.equ	STEK4		=$015F
.equ	STEK5		=$0160
.equ	STEK6		=$0161
.equ	STEK7		=$0162
.equ	STEK8		=$0163
.equ	STEK9		=$0164
.equ	STEK10		=$0165
.equ	STEK11		=$0166

;W_BIT_L
.equ	F_MOD0		=0
.equ	F_MOD1		=1
.equ	F_MOD2		=2
.equ	F_INV		=3
.equ	F_OKR		=4
.equ	F_RAZ		=5
;.equ			=6
;.equ			=7

;W_BIT_H
.equ	B_10		=0
.equ	B_STOP1		=1
.equ	B_100		=2
.equ	B_GL_MAX	=3
.equ	B_NAPR		=4
.equ	B_BLOK		=5
.equ	B_STOP2		=6
.equ	B_MMG		=7


;R_BIT
.equ	B_STUP		=0
.equ	B_STDN		=1
.equ	B_SEC		=2
.equ	B_ISP		=3
.equ	B_PWM		=4
.equ	B_WIND		=5
.equ	B_SEEK		=6
.equ	B_KOR		=7


;R_TM
;.equ	B_GL		=0
;.equ	B_MM		=1


.def	CLK_L		=r10
.def	CLK_H		=r11

.def	R_BIT		=r22

