; AssemblerApplication3.asm
;
; Created: 4/5/2020 7:28:21 PM
; Author : Magy Gamal
;


; key expansion algorithm
;first step
	LDI R16, 12 
	LDI R17, 1
	LDI XL, LOW(0x0100)
	LDI XH, HIGH(0x0100)
L0:	ST X+, R17
	INC R17
	DEC R16
	BRNE L0

	;second step
	LDI R20, 17
 	LDI R21, LOW(0xB7E1)
	LDI R22, HIGH(0xB7E1)
	STS 0x0111, R21
	STS 0x0112, R22
	LDI R23, 0x37
	LDI R24, 0x9E
	LDI XL, LOW(0x0111)
	LDI XH, HIGH(0x0111)
	LDI YL , LOW(0X0113)
	LDI YH, HIGH(0X0113)
L1:	LD R21, X+
	LD R22, X+
	ADD R21, R23
	ADC R22, R24
	ST Y+, R21
	ST Y+, R22
	DEC R20
	BRNE L1

	;third step
	LDI ZL, LOW(0x0111);S[0]LOW
	LDI ZH, HIGH(0x0111);S[0]HIGH
	LDI YL, LOW(0x0100);L[0]low
	LDI YH, HIGH(0x0100);L[0]HIGH
	LDS R5, 0x0100
	LDI R16, 0 ;Alow					
	LDI R17, 0 ;Ahigh			
	LDI R18, 0	;Blow			
	LDI R19, 0	;Bhigh				
	LDI R20, 54 ;max(t,c)
	LDI R21, 18 ;t 
	LDI R22, 6 ;c
	LDI XL, LOW(0x0111) ;S[0]LOW
	LDI XH, HIGH(0X0111) ;S[0]HIGH
L3:	ADD R16, R18 ;add A and B to A
	ADC R17, R19
	LD R23, X+ ;load S[i]LOW
	LD R24, X+ ;load S[i]high
	ADD R16, R23 
	ADC R17, R24 
	LDI R25, 3
L4:	BST R16, 7 ;store bit 7 in temproary register
	ROL R17 ;rotate Ahigh left
	ROL R16 ;rotate A low left
	BLD R17, 0 ;load bit from temporary to bit 0
	DEC R25
	BRNE L4
	ST Z+, R16 ;store in original place 
	ST Z+, R17
	CLR R25
	ADD R18, R16 ;add A and B to B
	ADC R19, R17 
	MOV R25, R18 
	ANDI R25,0x0F ;to get the value of the rotate
	LD R23, Y+ ;L[i]low 
	LD R24, Y+ ;L[i]high
	ADD R18, R23
	ADC R19, R24
L5:	BST R18, 7
	ROL R19
	ROL R18
	BLD R19, 0	
	DEC R25
	BRNE L5 
	ST -Y, R19 ; to save in original place where the Y has incremented up 
	ST -Y, R18
	LD R23, Y+; increment it again to continue
	LD R24, Y+
	DEC R21 ; DEC 18
	BREQ DOWN
THERE:DEC R22 ; DEC 6
	BREQ AGAIN
BACK:DEC R20 ;DEC 54
	BRNE L3
	JMP FINAL
AGAIN:LDI YL, LOW(0x0100) ;looping over the keys L[i]
	 LDI YH, HIGH(0x0100)
	 LDI R22, 6
	 JMP BACK
DOWN:LDI ZL, LOW(0x0111) ;looping over S[i]
	 LDI ZH, HIGH(0x0111)
	 LDI R21, 18
	 JMP THERE
FINAL : NOP	

; encryption algorithm
.DEF Alow=R16 						
.DEF Ahigh=R17						
.DEF Blow=R18						
.DEF Bhigh=R19	
	LDI Alow, 0x0A ;Input Alow
	LDI Ahigh, 0x0B ;Input Ahigh
	LDI Blow, 0x0C	;input Blow
	LDI Bhigh, 0x0D	;input Bhigh				
	LDI XL, LOW(0X0115)		;location of S[2]low	
	LDI XH, HIGH(0X0115)	;location of S[2]high		
	LDS R20, 0x0111		;load S[0]low
	LDS R21, 0x0112		;load S[0]high		
	LDS R22, 0x0113		;load S[1]low		
	LDS R23, 0x0114		;load S[1]high		
	ADD Alow, R20		;Alow+S[0]low		
	ADC Ahigh, R21		;Ahigh+S[0]high			
	ADD Blow, R22		;Blow+S[1]low			
	ADC Bhigh, R23		;Bhigh+S[1]high				
	LDI R24, 8	;r					
L6: EOR Alow,Blow		;part A			
	EOR Ahigh, Bhigh
	LDI R25, 15					
	AND R25, Blow ;for the rotation 
	BREQ INFIN	;if the value of rotation is zero don't do the following rotation procedures 			
L7: BST Alow, 7							
	ROL Ahigh					
	ROL Alow					
	BLD Ahigh ,0					
	DEC R25					
	BRNE L7					
INFIN:	LD R21, X+ 	;load S[i]low			
	LD R22, X+		;Load S[i]high			
	ADD Alow, R21					
	ADC Ahigh,R22					
	LDI R25, 15					
	EOR Blow,Alow ; partB
	EOR Bhigh, Ahigh
    AND R25, Alow
	BREQ INFINITY
L8:	BST Blow, 7
	ROL Bhigh
	ROL Blow
	BLD Bhigh, 0
	DEC R25
	BRNE L8
	INFINITY:LD R21, X+
	LD R22, X+
	ADD Blow, R21
	ADC Bhigh,R22
	DEC R24
	BRNE L6
	STS 0x010D, Alow
	STS 0x10E,Ahigh
	STS  0x010F, Blow
	STS 0x0110, Bhigh
	
	;decryption algorithm
	LDS Alow, 0X10D 
	LDS Ahigh, 0X10E
	LDS Blow, 0X10F
	LDS Bhigh, 0X110
	LDI R20, 8 ;r
	LDI XL, LOW(0X0135) ;S[i] from the bottom to top
	LDI XH, HIGH(0X0135)
L9:	LD R21, -X
	LD R22, -X
	SUB Blow, R22
	SBC Bhigh, R21
	LDI R23, 15
	AND R23, Alow
	BREQ INF
L10: BST Bhigh, 0
	ROR Blow
	ROR Bhigh
	BLD Blow,7
	DEC R23
	BRNE L10
INF:	EOR Blow,Alow
	EOR Bhigh, Ahigh
	LD R21, -X
	LD R22, -X
	SUB Alow, R22
	SBC Ahigh, R21
	LDI R23, 15
	AND R23, Blow
	BREQ INFI
L11: BST Ahigh, 0
	ROR Alow
	ROR Ahigh
	BLD Alow,7
	DEC R23
	BRNE L11
INFI: EOR Alow,Blow
	EOR Ahigh,Bhigh
	DEC R20
	BRNE L9
	LDS R21, 0X0111
	LDS R22, 0X0112
	LDS R23, 0X0113
	LDS R24, 0X0114
	SUB Blow, R23
	SBC Bhigh, R24
	SUB Alow, R21
	SBC Ahigh, R22
	STS 0X010D, Alow
	STS 0X010E, Ahigh
	STS 0X010F, Blow
	STS 0X0110, Bhigh

	

