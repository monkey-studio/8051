; b:  error code
; r3: timer high expected value
; r4: timer low expected value


t2con	EQU 0c8h;
t2mod	EQU 0c9h;
rcap2l	EQU 0cah;
rcap2h	EQU 0cbh;
tl2	EQU 0cch;
th2	EQU 0cdh;

tr2	EQU 0cah;
exen2	EQU 0cbh;
exf2	EQU 0ceh;
tf2	EQU 0cfh;

	ajmp start;

	org 03h	;	external interrupt 0
	reti;

	org 0bh	;	t/c 0 interrupt
	reti;

	org 13h	;	external interrupt 1
	reti;

	org 1bh	;	t/c 1 interrupt
	reti;

	org 23h	;	serial interface interrupt
	reti;

	org 2bh;	t/c 2 interrupt
	reti;


test2:
	mov a, th2	;
	subb a, r3	;
	jnz error	;

	mov a,tl2	;
	subb a, r4	;
	jnz error	;

	ret;


error:
	mov p1, b;
	nop;
	ajmp error;


start:
	clr a;
	mov r0, a;
	mov r1, a;
	mov ie, #00h	;disable interrupts
	clr c;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; timer 2 test
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; capture mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov tcon, #000h	; disable t/c 0,1
	mov t2con, #01h; timer 2 capture mode,
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	setb tr2	;start timer 2;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #00h	; error 0
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2;
	nop;
	nop;
	nop;
	nop;
	clr tr2		; stop timer 2
	mov b, #01h	; error 1
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 0
	mov b, #02h	; error 2
	mov r3, #000h	;
	mov r4, #002h	;
	acall test2	;
	mov b, #03h	; error 3
	jnb tf2, error	;
	clr tf2		;

	mov p0, #01h;
;
; test exen2
;
	mov rcap2l, #43h
	mov rcap2h, #21h
	mov th2, #23h	;
	mov tl2, #45h	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop1:  nop		;
	dec a		;
	jnz loop1	;
	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #04h	;error 4
	subb a, #43h	;
	jnz error0	;
	mov a, rcap2h	;
	subb a, #21h	;
	jnz error0	;

	mov b, #05h	;error 5
	jb exf2, error0	;
	clr exf2	;

	setb exen2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop2:  nop		;
	dec a		;
	jnz loop2	;
	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #06h	;error 6
	subb a, #45h	;
	jnz error0	;
	mov a, rcap2h	;
	subb a, #23h	;
	jnz error0	;

	mov b, #07h	;error 7
	jnb exf2, error0;
	clr exf2	;

	mov p0, #02h;
	
	ajmp arm;

error0:
	ljmp error;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; auto reload mode, up counter
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
arm:
	mov t2con, #00h	; t/c 2 in auto reload mode
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	mov rcap2l, #11h;
	mov rcap2h, #22h;
	setb tr2	;start timer 2;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #08h	; error 8
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2
	nop;
	nop;
	nop;
	nop;
	clr tr2		; stop timer 2
	mov b, #09h	; error 9
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov b, #0ah	; error a
	jb  tf2, error0	;
	clr tf2	;


	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 0
	mov b, #0bh	; error b
	mov r3, #022h	;
	mov r4, #013h	;
	acall test2	;

	mov b, #0ch	; error c
	jnb tf2, error0	;
	clr tf2	;


	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f0h	;error f0
	subb a, #11h	;
	jnz error1	;
	mov a, rcap2h	;
	subb a, #22h	;
	jnz error0	;

	mov p0, #03h;


;
; test exen2
;
	mov rcap2l, #12h
	mov rcap2h, #34h
	mov tl2, #56h	;
	mov th2, #78h	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop3:  nop		;
	dec a		;
	jnz loop3	;

	mov b, #0dh	; error d
	mov r3, #078h	;
	mov r4, #056h	;
	acall test2	;

	mov b, #0eh	; error e
	jb exf2, error1	;
	clr exf2	;

	setb exen2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop4:  nop		;
	dec a		;
	jnz loop4	;

	mov b, #0fh	; error f
	mov r3, #034h	;
	mov r4, #012h	;
	acall test2	;

	mov b, #10h	;error 10
	jnb exf2, error1;
	clr exf2	;

	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f1h	;error f1
	subb a, #12h	;
	jnz error1	;
	mov a, rcap2h	;
	subb a, #34h	;
	jnz error1	;

	mov p0, #04h	;

	ajmp upc;


error1:
	ljmp error;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; auto reload mode, up/down counter
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; up counter
;
upc:
	mov t2con, #00h	; t/c 2 in auto reload mode
	mov t2mod, #01h	;
	setb p3.2	;
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	mov rcap2l, #33h;
	mov rcap2h, #44h;
	setb tr2	;start timer 2;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #11h	; error 11
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2
	nop;
	nop;
	nop;
	nop;
	clr tr2		; stop timer 2
	mov b, #12h	; error 12
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov b, #13h	; error 13
	jb  tf2, error1	;
	clr tf2	;

	mov b, #14h	; error 14
	jb  exf2, error1;

	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #15h	; error 15
	mov r3, #044h	;
	mov r4, #035h	;
	acall test2	;

	mov b, #16h	; error 16
	jnb tf2, error1	;
	clr tf2	;

	mov b, #17h	; error 17
	jnb exf2, error1;


	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2

	mov b, #18h	; error 18
	jb exf2, error15;
	clr exf2	;
	clr tf2	;

	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f2h	;error f2
	subb a, #33h	;
	jnz error15	;
	mov a, rcap2h	;
	subb a, #44h	;
	jnz error15	;

	mov p0, #05h	;

	ajmp down;

error15:
	ljmp error;

;
; down counter
;
down:
	mov t2con, #00h	; t/c 2 in auto reload mode
	mov t2mod, #01h	;
	clr p3.2	;
	mov th2, #0e2h	;load timer 2
	mov tl2, #048h	;
	mov rcap2l, #11h;
	mov rcap2h, #22h;
	setb tr2	;start timer 2;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #19h	; error 19
	mov r3, #0e2h	;
	mov r4, #044h	;
	acall test2	;

	mov tl2, #01h	; load timer 2
	setb tr2	; start timer 2
	nop;
	nop;
	nop;
	nop;
	clr tr2		; stop timer 2
	mov b, #1ah	; error 1a
	mov r3, #0e1h	;
	mov r4, #0fch	;
	acall test2	;

	mov b, #1bh	; error 1b
	jb  tf2, error2	;
	clr tf2	;

	mov b, #1ch	; error 1c
	jb  exf2, error2;

	mov tl2, #012h	;
	mov th2, #022h	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #1dh	; error 1d
	mov r3, #0ffh	;
	mov r4, #0fbh	;
	acall test2	;

	mov b, #1eh	; error 1e
	jnb tf2, error2	;
	clr tf2	;

	mov b, #1fh	; error 1f
	jnb exf2, error2;


	mov tl2, #012h	;
	mov th2, #022h	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2

	mov b, #18h	; error 18
	jb exf2, error2	;
	clr exf2	;
	clr tf2	;

	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #04h	;error f3
	subb a, #11h	;
	jnz error2	;
	mov a, rcap2h	;
	subb a, #22h	;
	jnz error2	;

	mov p0, #06h	;

	ajmp brate;



error2:
	ljmp error;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; baud rate generator
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
brate:
	mov t2con, #10h	; t/c 2 in baud rate generator mode
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	mov rcap2l, #11h;
	mov rcap2h, #22h;
	setb tr2	;start timer 2;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 2
	mov b, #20h	; error 20
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov t2con, #20h	;
	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2
	nop;
	nop;
	nop;
	nop;
	clr tr2		; stop timer 2
	mov b, #021h	; error 21
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov b, #22h	; error 22
	jb  tf2, error2	;
	clr tf2	;


	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	nop;
	nop;
	nop;
	nop;
	nop;
	clr tr2		;stop timer 0
	mov b, #23h	; error 23
	mov r3, #022h	;
	mov r4, #013h	;
	acall test2	;

	mov b, #24h	; error 24
	jb tf2, error2	;
	clr tf2	;


	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f4h	;error f4
	subb a, #11h	;
	jnz error2	;
	mov a, rcap2h	;
	subb a, #22h	;
	jnz error2	;

	mov p0, #07h;


;
; test exen2
;
	mov tl2, #56h	;
	mov th2, #78h	;
	setb p3.2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop5:  nop		;
	dec a		;
	jnz loop5	;

	mov b, #25h	; error 25
	mov r3, #078h	;
	mov r4, #056h	;
	acall test2	;

	mov b, #0eh	; error e
	jb exf2, error3	;
	clr exf2	;

	setb exen2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop6:  nop		;
	dec a		;
	jnz loop6	;

	mov b, #26h	; error 26
	mov r3, #078h	;
	mov r4, #056h	;
	acall test2	;

	mov b, #27h	;error 27
	jnb exf2, error3;
	clr exf2	;


	mov p0, #08h	;
	ajmp counter;

error3:
	ljmp error;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; counter 2 test
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; capture mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
counter:
	mov tcon, #000h	; disable t/c 0,1
	mov t2con, #03h; timer 2 capture mode,
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	setb tr2	;start timer 2;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #00h	; error 0
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		; stop timer 2
	mov b, #01h	; error 1
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 0
	mov b, #02h	; error 2
	mov r3, #000h	;
	mov r4, #002h	;
	acall test2	;
	mov b, #03h	; error 3
	jnb tf2, error4	;
	clr tf2		;

	mov p0, #09h;
;
; test exen2
;
	mov rcap2l, #43h
	mov rcap2h, #21h
	mov th2, #23h	;
	mov tl2, #45h	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop7:  nop		;
	dec a		;
	jnz loop7	;
	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #04h	;error 4
	subb a, #43h	;
	jnz error4	;
	mov a, rcap2h	;
	subb a, #21h	;
	jnz error4	;

	mov b, #05h	;error 5
	jb exf2, error4	;
	clr exf2	;

	setb exen2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop8:  nop		;
	dec a		;
	jnz loop8	;
	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #06h	;error 6
	subb a, #45h	;
	jnz error4	;
	mov a, rcap2h	;
	subb a, #23h	;
	jnz error4	;

	mov b, #07h	;error 7
	jnb exf2, error4;
	clr exf2	;

	mov p0, #0ah;
	
	ajmp armc;

error4:
	ljmp error;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; auto reload mode, up counter
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
armc:
	mov t2con, #02h	; t/c 2 in auto reload mode
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	mov rcap2l, #11h;
	mov rcap2h, #22h;
	setb tr2	;start timer 2;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #08h	; error 8
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		; stop timer 2
	mov b, #09h	; error 9
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov b, #0ah	; error a
	jb  tf2, error4	;
	clr tf2	;


	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 0
	mov b, #0bh	; error b
	mov r3, #022h	;
	mov r4, #013h	;
	acall test2	;

	mov b, #0ch	; error c
	jnb tf2, error5	;
	clr tf2	;


	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f0h	;error f0
	subb a, #11h	;
	jnz error5	;
	mov a, rcap2h	;
	subb a, #22h	;
	jnz error5	;

	mov p0, #0bh;


;
; test exen2
;
	mov rcap2l, #12h
	mov rcap2h, #34h
	mov tl2, #56h	;
	mov th2, #78h	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop9:  nop		;
	dec a		;
	jnz loop9	;

	mov b, #0dh	; error d
	mov r3, #078h	;
	mov r4, #056h	;
	acall test2	;

	mov b, #0eh	; error e
	jb exf2, error5	;
	clr exf2	;

	setb exen2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop10: nop		;
	dec a		;
	jnz loop10	;

	mov b, #0fh	; error f
	mov r3, #034h	;
	mov r4, #012h	;
	acall test2	;

	mov b, #10h	;error 10
	jnb exf2, error5;
	clr exf2	;

	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f1h	;error f1
	subb a, #12h	;
	jnz error5	;
	mov a, rcap2h	;
	subb a, #34h	;
	jnz error5	;

	mov p0, #0ch	;

	ajmp upcc;


error5:
	ljmp error;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; auto reload mode, up/down counter
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; up counter
;
upcc:
	mov t2con, #02h	; t/c 2 in auto reload mode
	mov t2mod, #01h	;
	setb p3.2	;
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	mov rcap2l, #33h;
	mov rcap2h, #44h;
	setb tr2	;start timer 2;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #11h	; error 11
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		; stop timer 2
	mov b, #12h	; error 12
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov b, #13h	; error 13
	jb  tf2, error5	;
	clr tf2	;

	mov b, #14h	; error 14
	jb  exf2, error5;

	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #15h	; error 15
	mov r3, #044h	;
	mov r4, #035h	;
	acall test2	;

	mov b, #16h	; error 16
	jnb tf2, error6	;
	clr tf2	;

	mov b, #17h	; error 17
	jnb exf2, error6;


	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2

	mov b, #18h	; error 18
	jb exf2, error6	;
	clr exf2	;
	clr tf2	;

	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f2h	;error f2
	subb a, #33h	;
	jnz error6	;
	mov a, rcap2h	;
	subb a, #44h	;
	jnz error6	;

	mov p0, #0dh	;

	ajmp downc;

error6:
	ljmp error;

;
; down counter
;
downc:
	mov t2con, #02h	; t/c 2 in auto reload mode
	mov t2mod, #01h	;
	clr p3.2	;
	mov th2, #0e2h	;load timer 2
	mov tl2, #048h	;
	mov rcap2l, #11h;
	mov rcap2h, #22h;
	setb tr2	;start timer 2;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #19h	; error 19
	mov r3, #0e2h	;
	mov r4, #044h	;
	acall test2	;

	mov tl2, #01h	; load timer 2
	setb tr2	; start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		; stop timer 2
	mov b, #1ah	; error 1a
	mov r3, #0e1h	;
	mov r4, #0fch	;
	acall test2	;

	mov b, #1bh	; error 1b
	jb  tf2, error6	;
	clr tf2	;

	mov b, #1ch	; error 1c
	jb  exf2, error6;

	mov tl2, #012h	;
	mov th2, #022h	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #1dh	; error 1d
	mov r3, #0ffh	;
	mov r4, #0fbh	;
	acall test2	;

	mov b, #1eh	; error 1e
	jnb tf2, error7	;
	clr tf2	;

	mov b, #1fh	; error 1f
	jnb exf2, error7;


	mov tl2, #012h	;
	mov th2, #022h	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2

	mov b, #18h	; error 18
	jb exf2, error7	;
	clr exf2	;
	clr tf2	;

	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #04h	;error f3
	subb a, #11h	;
	jnz error7	;
	mov a, rcap2h	;
	subb a, #22h	;
	jnz error7	;

	mov p0, #0eh	;

	ajmp bratec;



error7:
	ljmp error;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; baud rate generator
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bratec:
	mov t2con, #12h	; t/c 2 in baud rate generator mode
	mov th2, #000h	;load timer 2
	mov tl2, #000h	;
	mov rcap2l, #11h;
	mov rcap2h, #22h;
	setb tr2	;start timer 2;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 2
	mov b, #20h	; error 20
	mov r3, #000h	;
	mov r4, #004h	;
	acall test2	;

	mov tl2, #0fch	; load timer 2
	setb tr2	; start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		; stop timer 2
	mov b, #021h	; error 21
	mov r3, #001h	;
	mov r4, #001h	;
	acall test2	;

	mov b, #22h	; error 22
	jb  tf2, error7	;
	clr tf2	;


	mov tl2, #0fch	;
	mov th2, #0ffh	;
	setb tr2	;start timer 2
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	cpl p3.5;
	clr tr2		;stop timer 0
	mov b, #23h	; error 23
	mov r3, #022h	;
	mov r4, #013h	;
	acall test2	;

	mov b, #24h	; error 24
	jb tf2, error8	;
	clr tf2	;


	mov a, rcap2l	;
	mov psw, #00h	;
	mov b, #0f4h	;error f4
	subb a, #11h	;
	jnz error8	;
	mov a, rcap2h	;
	subb a, #22h	;
	jnz error8	;

	mov p0, #0fh;


;
; test exen2
;
	mov tl2, #56h	;
	mov th2, #78h	;
	setb p3.2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop11: nop		;
	dec a		;
	jnz loop11	;

	mov b, #25h	; error 25
	mov r3, #078h	;
	mov r4, #056h	;
	lcall test2	;

	mov b, #0eh	; error e
	jb exf2, error8	;
	clr exf2	;

	setb exen2	;
	clr p3.2	;
	setb p3.2	;
	mov a, #10h	;
loop12: nop		;
	dec a		;
	jnz loop12	;

	mov b, #26h	; error 26
	mov r3, #078h	;
	mov r4, #056h	;
	lcall test2	;

	mov b, #27h	;error 27
	jnb exf2, error8;
	clr exf2	;

	mov p0, #10h	;

	ajmp finish	;

error8:
	ljmp error;




finish:
	nop;
	nop;
	ajmp finish;



end




