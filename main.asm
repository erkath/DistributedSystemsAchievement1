	; Определяем параметры интервалов (в миллисекундах)
.EQU TIMER1_INTERVAL = 200000   ; Интервал для первого таймера (1 секунда)
.EQU TIMER2_INTERVAL = 100000   ; Интервал для второго таймера (2 секунды)


.cseg
.org 0x0000
    rjmp Start                  ; Переход в начало


.org 0x0004
    rjmp TIMER2_COMPA_vect                  ; Вектор прерываний для восьмибитного Timer/Counter2
.org 0x0009
    rjmp TIMER0_COMPA_vect                  ; Вектор прерываний для восьмибитного Timer/Counter0

.org 0x000C ; UASRT
    ret


.org 0x0010

; Определяем функцию инициализации USART
USART_Init:
    ; Для 1MHz: UBRRH = (F_CPU/(16*BAUD))-1, где F_CPU = 1000000, BAUD = 9600
    ldi r16, 12          ; Установка значения UBRRH для 9600
    out UBRRH, r16
    
    ldi r16, 0           ; Значение для UBRRL
    out UBRRL, r16
    
    ldi r16, (1<<RXEN) | (1<<TXEN)   ; Включаем RX и TX
    out UCSRB, r16

    ldi r16, (1<<URSEL) | (3<<UCSZ0)  ; 8 бит данных, 1 стоп-бит, нет четности
    out UCSRC, r16
    
    ret


USART_Send:
    ; Принимает указатель на строку в r30:r31 (Z- регистры)
USART_SendLoop:
    lpm r16, Z+                  ; Загружаем следующий байт строки
    cpi r16, 0                  ; Проверяем на конец строки
    breq USART_SendDone        ; Если конец, выходим
    ; Ждем, пока передатчик готов
USART_Wait:
    sbi UCSRB, UDRE            ; Устанавливаем флаг
    sbis UCSRA, UDRE           ; Ожидание флага
    rjmp USART_Wait            ; Ожидаем

    out UDR, r16               ; Отправляем байт
    rjmp USART_SendLoop        ; Повторяем
USART_SendDone:
    ret


; Инициализация таймеров
Init_Timers:
    ; Настройка второго таймера (Timer/Counter 2 8bit)
    ldi r16, (0<<CS22) | (1<<CS21) | (1<<CS20) ; предделитель 64
    out TCCR2, r16
    
     ; Прерывание по сравнению для второго таймера
    ldi r16, (TIMER1_INTERVAL / 1000) ; значение для OCR0
    out TCNT2, r16

    ; Настройка нулевого таймера (Timer/Counter 0 8bit)
    ldi r16, (0<<CS02) | (1<<CS01) | (1<<CS00) ; предделитель 64
    out TCCR0, r16

    ; Прерывание по сравнению для нулевого таймера
    ldi r16, (TIMER2_INTERVAL / 1000) ; значение для OCR0
    out TCNT0, r16

    ; Включить прерывание для таймеров 0 и 2
    ldi r16, (1<<TOIE0 | 1<<TOIE2)           ; Включаем прерывание
    out TIMSK, r16
    ret


Start:
    rcall USART_Init             ; Инициализация USART
    rcall Init_Timers            ; Инициализация таймеров

main_loop:
    sei                         ; Включаем глобальные прерывания
    rjmp main_loop             ; Бесконечный цикл управления

; Обработчик прерывания для Timer2
TIMER2_COMPA_vect:
    ldi r30, low(2*TIMER1_STR)   ; Указатель на строку
    ldi r31, high(2*TIMER1_STR)
    rcall USART_Send            ; Отправляем строку "ping"
    ret

; Обработчик прерывания для Timer0
TIMER0_COMPA_vect:
    ldi r30, low(2*TIMER2_STR)   ; Указатель на строку
    ldi r31, high(2*TIMER2_STR)
    rcall USART_Send            ; Отправляем строку "pong"
    ret



;.dseg
.org 0x0100
; Определяем строки сообщений
TIMER1_STR: 
  .db "ping\r\n",0x00
TIMER2_STR: 
 .db "pong\r\n",0x00
STR_END:
