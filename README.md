# Построение распределенных систем и облачные вычисления

### Achievement 1

Выполнила Екатерина Еременко, МИВ231.

#### Задание 1

Разработана программа на AVR assembler под Atmega8 в Atmel studio: запускаются два параллельных таймера, параметры интервалов задаются константами TIMER1_INTERVAL и TIMER2_INTERVAL. При срабатывании первого таймера (через интервал TIMER1_INTERVAL) в USART выводится строка TIMER1_STR, равная "ping\r\n", при срабатывании второго -- строка (через интервал TIMER2_INTERVAL) TIMER2_STR, равная "pong\r\n".

Использовались 2 восьмибитных таймера Atmega8 -- Timer/Counter2 и Timer/Counter0.

Скриншот валидации работы программы в Proteus:

![image](https://github.com/user-attachments/assets/ff800f17-be38-41d5-a860-643745169d3f)

