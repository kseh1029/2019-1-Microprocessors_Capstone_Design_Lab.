# **Ⅰ. 프로젝트 결과**

![https://blog.kakaocdn.net/dn/beKmqH/btqLvFYGWVB/Z2q3oHdTv8kjbuBVwZBAY1/img.png](https://blog.kakaocdn.net/dn/beKmqH/btqLvFYGWVB/Z2q3oHdTv8kjbuBVwZBAY1/img.png)

프로젝트의 목표인 60 초 타이머를 코딩하고, 실제로 PIC16F876A 에 프로그램화 하여 5V 전원을 공급해본 결과, 이상없이 작동함을 확인하였다.

실제 가정에서 쓰는 요리용타이머와 비슷하게 작동할 수 있도록 전원을 인가시 사용자가 시작(SW3) 버튼을 누르는지 확인을 하고, 시간이 흘러갈 때 정지(SW2) 버튼을 누르면 그 시간에서 정지한다. 정지된 상태에서 시작(SW3) 버튼을 누르면, 그 시간을 이어서 타이머가 흐르게 되고, 리셋(SW1) 버튼을 누르면, 시간을 00초로 초기화 후 사용자가 시작버튼을 누를 때 까지 대기한다. 정지되지 않은 상태에서도 리셋(SW1) 버튼을 누르면 똑같이 작동하도록 하였다.

60초가 지나고 나면, Beep음을 잠깐 발생시키며, 00초로 초기화 후 사용자의 시작버튼을 기다린다.

# Ⅱ. 프로젝트 목적, 접근방법 및 세부결과

이 프로젝트를 수행하기 위해선, 수행해야 하는 과정을 여러부분으로 나눠서 생각할 필요가 있다.

① 납땜, ② 회로도 확인, ③ 세그먼트 진리표 만들기, ④ 인터럽트, ⑤ 옵션 레지스터

**① 납땜**

![https://blog.kakaocdn.net/dn/m7POW/btqLyLcxffi/t8vnRPlhIYY0pCVT3i7kCk/img.jpg](https://blog.kakaocdn.net/dn/m7POW/btqLyLcxffi/t8vnRPlhIYY0pCVT3i7kCk/img.jpg)

![https://blog.kakaocdn.net/dn/cLaeD0/btqLA3XA6Ky/fbkKYf96134y3z7sIGIki1/img.jpg](https://blog.kakaocdn.net/dn/cLaeD0/btqLA3XA6Ky/fbkKYf96134y3z7sIGIki1/img.jpg)

실납에는 납과 화학물질이 섞여있다.

이 화학물질은 페이스트라고 부르는데,

실제로 납땜을 할 때 납은 페이스트를

따라서 가는 성질이 있다.

인두기로 실납에 열을 가하면 나는 연기는 페이스트 때문에 발생하는 것이다.

그래서, 납땜을 할 때 페이스트가 가라앉는 시간이 있으므로 납이 녹자마자 바로 인두기를 떼면 안되며, 인두기로 1초정도 더 열을 가한후 떼어내야 한다. 이때 조심할점은, 기판의 홀 마다, Plate 처리가 되어있고 내부적으로 회로가 연결되어 있으므로 인두기로 기판을 장시간 열을 가하게 되면 기판이 손상될 우려가 있으니 조심해야 한다.

![https://blog.kakaocdn.net/dn/tijie/btqLweNjQZ7/Oiy1b1k9iKJSGiwWQHOAGk/img.jpg](https://blog.kakaocdn.net/dn/tijie/btqLweNjQZ7/Oiy1b1k9iKJSGiwWQHOAGk/img.jpg)

납떔을 할 때 조금 더 깔끔하게 하기위해서는 실납에 들어있는 페이스트가 아닌 여분의 페이스트를 발라가면서 하면 좋다.

**② 회로도 확인**

타이머를 만들기 위해서,

필요한 포트를 우선 찾아야한다.

시작, 정지, 리셋 버튼을 사용하므로

SW1, SW2, SW3를 사용하고

60초가 됐을 때 알려줄 피에조부저,

시간을 표시할 세그먼트를 사용한다.

피에조부저의 경우 VDD 가 있으므로

풀업이며, SW 의 경우 공통접지가 되어있으므로 풀다운이다.

세그먼트도 공통접지가 되어있으므로,

Common Cathode Type 임을 확인할 수 있다. 필요한 소자들의 포트를 정리하면 다음과 같다.

![https://blog.kakaocdn.net/dn/oujnA/btqLxvgIwV2/bgZQ2nlcLYOT8k0UNlwTSK/img.png](https://blog.kakaocdn.net/dn/oujnA/btqLxvgIwV2/bgZQ2nlcLYOT8k0UNlwTSK/img.png)

**③ 세그먼트 진리표 만들기**

위 회로에서 세그먼트가 공통 케소드 방식임을 확인하였다. 따라서 해당 비트에 1이 들어가면 불이 켜지고, 0이 들어가면 불이 꺼지므로, 그에 맞게 진리표를 작성하면 다음과 같다.

![https://blog.kakaocdn.net/dn/doKjQs/btqLzF4eNFX/rYVMwf2z6HKD2iitNSXPN1/img.png](https://blog.kakaocdn.net/dn/doKjQs/btqLzF4eNFX/rYVMwf2z6HKD2iitNSXPN1/img.png)

수업시간에 실습했을때와는 다르게, PORTC 와 PORTA를 둘다 사용해야 하는 상황이므로 일반적인 Lookup Table을 이용한 주소찾기로 값을 RETLW 하여 보내는 것은 불가능하다.

따라서, Lookup Table을 2개를 만들어서 표현한다면 표현이 가능할 것이다. 이때 문제가 되는 점이 있는데,

PORTC 의 경우 7:5 , 2:0 비트는 세그먼트에 사용하지만, 4, 3번째 비트는 다른 용도로 사용한다는 점 이다.

그래서 회로도를 확인해본 결과, RC4/SDI, RC3/SCK 는 어떠한 소자와도 연결이 되어있지 않았으며 테이블시트에서 PORTC 의 기본 값을 확인해본 결과, 8 비트 모두 ‘XXXXXXXX’ 로 돈케어 였다. 따라서 Lookup Table 작성 시 사용하지 않는 4:3 비트는 0으로 주었다.

PORTA 의 경우 1:0 비트는 세그먼트에 사용하지만, 7:2 비트는 다른 용도로 사용된다. 회로도를 확인해보니

![https://blog.kakaocdn.net/dn/nVcSf/btqLzYboght/xs2qGxEP5kDpvJcbGbx7Bk/img.png](https://blog.kakaocdn.net/dn/nVcSf/btqLzYboght/xs2qGxEP5kDpvJcbGbx7Bk/img.png)

왼쪽의 표처럼 되어 있었다. RA2:3 의 경우 60초 타이머 이므로, TRISA에서 RA2:3 을 output 으로만 바꾸지 않는다면, 초기에 input 으로 되어있으므로 어떤값을 넣더라도 실제로 출력은 되지 않을 것이다. RA4 는 Pull-up 인 피에조 부저이므로 1을 넣어야 소리가 나지 않을 것이다. RA5 는 개방된 상태로 아무것도 연결되어있지 않았고, RA6:7은 설계상 원래 사용하지 않는 부분이였으므로 RA5:7 은 어떤 값을 넣어도 상관이 없다. 따라서, RA7:5 에 000, RA4 에 1, RA3:2 에 0을 넣고 세그먼트 진리표를 정리하면 다음과 같은 Lookup Table을 만들 수 있다.

![https://blog.kakaocdn.net/dn/3laUw/btqLyK5K7KS/a8G6tIrqiE3kA0X7B97opk/img.png](https://blog.kakaocdn.net/dn/3laUw/btqLyK5K7KS/a8G6tIrqiE3kA0X7B97opk/img.png)

**④ 인터럽트**

인터럽트는 소프트웨어적인 방법과, 하드웨어적인 방법이 있다. 소프트웨어 방법의 경우 스캐닝방식을 사용하는 것으로, BTFSS 나BTFSC와 같은 명령어로 실시간 감시가 가능하다. 많은 사용을 하면 프로그램상 과부하가 생길 수 있다. 하드웨어 방법의 경우 하드웨어 자체에 실시간 감시를 하는 부분이 있는데 (주소상 04H) 통상적으로 이를 인터럽트라고 부르게 된다. 이 프로젝트를 설계할 때 시작, 정지, 리셋 버튼은 소프트웨어적인 인터럽트를 사용하는 것이 좋고, 세그먼트의 숫자가 바뀌는건 하드웨어적인 인터럽트를 사용하는 것이 좋다.

인터럽트를 제어하는 레지스터 INTCON(0BH)를 살펴보면

![https://blog.kakaocdn.net/dn/HxR5Q/btqLyKYXkmS/kWOT4VX0Q7gJz0JcvMAnNK/img.jpg](https://blog.kakaocdn.net/dn/HxR5Q/btqLyKYXkmS/kWOT4VX0Q7gJz0JcvMAnNK/img.jpg)

다음과 같고 기본적으로 각각 비트에 ‘0000000X’를 초기값으로 두고 있다.

인터럽트를 사용하기 위해선 Global Interrupt를 활성화 시켜줘야 한다. 따라서INTCON:7 은 1이 되어야 한다.

TMR0 Overflow Interrupt 는 타이머에 오버플로우가 발생하게 되면 인터럽트가 작동하게 되는것이므로 INTCON:5 는 1이 되어야 한다.

RB0 에 외부신호가 들어오거나, RB 포트가 변경이 생겼을때는 이 프로젝트에서 사용하지 않으므로 0 으로 두어도 무관하며, 마찬가지로 Flag 기능을 사용하지 않으므로INTCON2:0 모두 0으로 두어도 무관하다. 따라서 스탑워치를 만들기 위해 7번 비트와5번 비트만 활성화 시키면 된다.

![https://blog.kakaocdn.net/dn/bH2lG3/btqLveUwYgL/M8OqvQoXpKwy63TJLV5pL1/img.png](https://blog.kakaocdn.net/dn/bH2lG3/btqLveUwYgL/M8OqvQoXpKwy63TJLV5pL1/img.png)

TMR0 가 Overflow 가 되고 나면, INTCON:2 가 TMR0 의 Flag를 나타내므로 1로 자동으로 바뀔 것이다. 따라서 인터럽트가 끝나고 나면 0 으로 바꿔줄 필요가 있다. 인터럽트가 작동해서 04H 에 다녀오고 나서, 워킹레지스트에 저장된 값을 잃어서는 안되고, STATUS 에 변동이 생겨서는 안된다. 따라서 인터럽트를 사용할때에는 통상적으로 왼쪽 표와 같이 사용을 하며, 인터럽트 작성 부분에 실제로 작동하는 내용을 적으면 된다. 인터럽트가 끝나고 나면, RETFIE를 사용하는게 적합할 수 있다. 그 이유는, 한번 인터럽트가 끝나면 INTCON:7 의 Global Interrupt가 0으로 돌아가기 때문에, 인터럽트를 반복해주기 위해서RETFIE 으로 리턴을 시킨다면, GIE 가 항상 1로 유지되기 때문이다.

**⑤ 옵션 레지스터**

![https://blog.kakaocdn.net/dn/PFuGt/btqLwdU9Eq6/akMS0S7BNDck4Hc0NkgFnK/img.jpg](https://blog.kakaocdn.net/dn/PFuGt/btqLwdU9Eq6/akMS0S7BNDck4Hc0NkgFnK/img.jpg)

옵션 레지스터는 타이머 인터럽트를 사용할 때, Prescaler를 조절하여 비율적으로 PIC 가 타이머 시간을 많이 가지도록 설정할 수 있는 레지스터이다. 뿐만 아니라 PORTB를 Pull-up 으로 사용할 것인지 설정이 가능하다. 회로도에서 PORTB를 사용하는 소자는 SW 와 7.Segment 의 dg3, dg4 이다.

회로도상 Pull-up 이며, 실제로 Pull-up 으로 동작을 할 수 있도록 OPTION_REG:7을 1로 바꿔주어야 한다. 또한, TMR0를 정확하게 사용하기 위해서는 분주비를 계산하고, 비율을 정해줘야 한다.

XT 발진기에서

![https://blog.kakaocdn.net/dn/ni0tf/btqLyLjjt4P/LIkGYBK6zZ70XJaRSKpWD1/img.jpg](https://blog.kakaocdn.net/dn/ni0tf/btqLyLjjt4P/LIkGYBK6zZ70XJaRSKpWD1/img.jpg)

이므로

![https://blog.kakaocdn.net/dn/nRnyb/btqLxuPESD7/o9iiyIb2KBmK3iWezphkz1/img.jpg](https://blog.kakaocdn.net/dn/nRnyb/btqLxuPESD7/o9iiyIb2KBmK3iWezphkz1/img.jpg)

이다. TMR0IE 는 PIC 가 8bits 이므로, 256 번 카운터 후 오버플로우가 발생하면 인터럽트가 작동하여 04H 로 가게된다. 따라서 기본적으로 TMR0 가 한번 작동하기 위해 걸리는 시간은

![https://blog.kakaocdn.net/dn/IMWsU/btqLAzvFvEv/QIVKEirOE5ThMbowd2jfMk/img.jpg](https://blog.kakaocdn.net/dn/IMWsU/btqLAzvFvEv/QIVKEirOE5ThMbowd2jfMk/img.jpg)

임을 알 수 있다. 여기에 분주비가 곱해지면서, 원하는 시간을 얻을 수 있게 된다.

프로젝트에서 원하는 시간은 1초이므로 여기서 어떠한 분주비를 선택하여도 1초를 얻을 수 없다. 하지만, 내부에서 인터럽트가 일어날때마다 임의의 파일레지스트가 증가하도록 하고, 그 파일레지스트가 1초가 되었을 때 작동을 하게 한다면, 1초처럼 작동할 수 있다.

즉, 분주비를 TMR0 Rate에서 1:8을 선택하였을 때,

![https://blog.kakaocdn.net/dn/lykzn/btqLA4vq2H5/holXN69FDfDbhk6OmDUgf0/img.jpg](https://blog.kakaocdn.net/dn/lykzn/btqLA4vq2H5/holXN69FDfDbhk6OmDUgf0/img.jpg)

이 되고, 이러한 인터럽트가 500번 쌓였을 때 세그먼트에서 숫자 1을 증가시키면 된다. 따라서 프로젝트에 적용을 해보자면 첫째자리와 둘째자리 세그먼트는 항상 스캐닝방식으로 출력이 나오고 있어야하며, 그 스캐닝은 인터럽트가 항상 하고있으므로, 스캐닝방식으로 출력이 나올때를 임의의 파일레지스트에 값이 쌓여서 500이 되도록 만들면 된다. 하지만, 우리가 사용하는 PIC16F876A는 8bits를 사용하기 때문에, 파일레지스트에 최대 .255 까지 밖에 담지를 못한다.

그래서 이를 방지하기 위해 분주비를 1:16 으로 선택한다면,

![https://blog.kakaocdn.net/dn/mSOi6/btqLvGJ0heU/2vZMoHGaGoTH2qg1bfm0P1/img.jpg](https://blog.kakaocdn.net/dn/mSOi6/btqLvGJ0heU/2vZMoHGaGoTH2qg1bfm0P1/img.jpg)

이며, 한번 인터럽트 발생을 위해

![https://blog.kakaocdn.net/dn/cxT7JF/btqLyMicrBK/B9JnQo7oygcUC2ALkTQYz0/img.jpg](https://blog.kakaocdn.net/dn/cxT7JF/btqLyMicrBK/B9JnQo7oygcUC2ALkTQYz0/img.jpg)

가 필요하게 되며, 1초, 즉

![https://blog.kakaocdn.net/dn/cR3bur/btqLwdU9Esd/bkKaVw10PbIe5W6DCZp7NK/img.jpg](https://blog.kakaocdn.net/dn/cR3bur/btqLwdU9Esd/bkKaVw10PbIe5W6DCZp7NK/img.jpg)

가 되기 위해선 파일레지스트가 250 이 될 때, 실제로 첫째자리의 숫자를 올리는 방식으로 가면 된다. 분주비는 1:8을 유지하되, 시간을 2배 더 늘리는 응용을 하기 위해, 둘째자리 혹은 첫째자리 중 하나만 임의의 파일레지스트가 1이 증가하도록 할 수 있다.

즉, 인터럽트가 2번 돌때마다 임의의 파일레지스트가 1이 증가하고, 이 임의의 파일레지스트가 250이 될 때 첫째자리의 값을 증가시키도록 하면 해결이 된다.

근사값으로 계산하지 않고 완벽하게 정확한 1초를 구하면, 분주비를 1:16 으로 선택하고

![https://blog.kakaocdn.net/dn/2077T/btqLzYP1Z6u/eEGtaTjBvgvjfvz4FjUpik/img.jpg](https://blog.kakaocdn.net/dn/2077T/btqLzYP1Z6u/eEGtaTjBvgvjfvz4FjUpik/img.jpg)

1초 (

![https://blog.kakaocdn.net/dn/qQHAE/btqLA3cdAMr/5i5JeYuUKTAuK9OEWi6QG1/img.jpg](https://blog.kakaocdn.net/dn/qQHAE/btqLA3cdAMr/5i5JeYuUKTAuK9OEWi6QG1/img.jpg)

) 가 지나기 위해선 244.14 번이 필요하므로, 파일레지스트가 244이 될 때 첫째자리의 숫자를 올리면 가장 정확하다. 실제로 적용을 할땐, 분주비를 1:8 으로 선택하고 세그먼트 둘째자리를 확인할때마다 파일레지스트를 1개씩 올렸다.

실제론 244.14 번 해야 정확하지만 0.14 번은 구현하지 못했으므로 실제 1초보다

![https://blog.kakaocdn.net/dn/cATipn/btqLyLXVg3V/vjkfX245TTdy7IdikUtFk0/img.jpg](https://blog.kakaocdn.net/dn/cATipn/btqLyLXVg3V/vjkfX245TTdy7IdikUtFk0/img.jpg)

의 오차가 발생할 것이다.

# Ⅲ. 프로젝트 코드 및 해석

processor 16f876a

; 사용할 특수 레지스터 선언

OPTION_REG EQU 81H ; RB Pull up 설정 및 분주비 설정

PCL EQU 02H ; Lookup table 찾는 용도

STATUS EQU 03H ; Bank 및 Zero Flag 관리

TRISA EQU 85H ; A I/O 관리

TRISB EQU 86H ; B I/O 관리

TRISC EQU 87H ; C I/O 관리

PORTA EQU 05H ; A 신호관리

PORTB EQU 06H ; B 신호관리

PORTC EQU 07H ; C 신호관리

ADCON1 EQU 9FH ; RA 디지털<>아날로그 변환

INTCON EQU 0BH ; H/W 인터럽트

BUF EQU 22H ; Delay 용

BUF2 EQU 23H ; Delay 용

W_TEMP EQU 24H ; 인터럽트 SWAP 용

STATUS_TEMP EQU 25H ; 인터럽트 SWAP 용

COUNT EQU 26H ;인터럽트 횟수 확인용

D_10SEC EQU 27H ; 세그먼트 10의 자리 가져올 수 보관용

D_1SEC EQU 28H ; 세그먼트 1의 자리 가져올 수 보관용

FLAG EQU 29H ; 제어할 세그먼트 선택용

W EQU B'0'

F EQU .1

ORG 00H

GOTO START

ORG 04H

GOTO ISR

ISR MOVWF W_TEMP

SWAPF STATUS, W

MOVWF STATUS_TEMP

; 인터럽트 부분 시작

CALL SEGMENT

; 인터럽트 부분 끝

SWAPF STATUS_TEMP, W

MOVWF STATUS

SWAPF W_TEMP, F

SWAPF W_TEMP, W

BCF INTCON, 2 ;TMR0 가 Overflow 되서 발생한 Flag 를 다시 0으로 초기화

RETFIE ; Return 이 되면서 GIE Disable 되는데, 바로 Enable 시킴.

SEGMENT

BTFSS FLAG,0 ;제어할 세그먼트 자리수 확인

GOTO SEGMENT1 ; Flag가 0이면 10의 자리 세그먼트 제어

GOTO SEGMENT2 ; Flag가 1이면 1의 자리 세그먼트 제어

SEGMENT1 ; 10의 자리 세그먼트

BSF PORTB,1 ; 1의 자리 세그먼트 OFF

BCF PORTB,2 ; 10의 자리 세그먼트 ON (스캐닝방식)

MOVF D_10SEC,W ; 워킹에 D_10SEC 을 담는다.

CALL LOOKUP_1 ; Lookup Table 에서 D_10SEC 에 해당하는 수 가져오기

MOVWF PORTC ; 가져온 수를 출력시킨다. (a,b,c,d,e,f 담당)

MOVF D_10SEC,W ; 워킹에 D_10SEC 을 담는다.

CALL LOOKUP_2 ; Lookup Table 에서 D_10SEC 에 해당하는 수 가져오기

MOVWF PORTA; 가져온 수를 출력시킨다. (g, dot 담당)

BSF FLAG,0 ; 1의 자리를 제어하도록 바꾼다.

INCF COUNT ; 인터럽트가 일어났음을 COUNT 에 기록한다.

RETURN

SEGMENT2 ; 1의 자리 세그먼트

BCF PORTB,1 ; 1의 자리 세그먼트 ON

BSF PORTB,2 ; 10의 자리 세그먼트 OFF (스캐닝방식)

MOVF D_1SEC,W ; 워킹에 D_1SEC 을 담는다.

CALL LOOKUP_1 ; Lookup Table 에서 D_1SEC 에 해당하는 수 가져오기

MOVWF PORTC ; 가져온 수를 출력시킨다. (a,b,c,d,e,f 담당)

MOVF D_1SEC,W ; 워킹에 D_1SEC 을 담는다.

CALL LOOKUP_2 ; Lookup Table 에서 D_1SEC 에 해당하는 수 가져오기

MOVWF PORTA; 가져온 수를 출력시킨다. (g, dot 담당)

BCF FLAG,0 ; 10의 자리를 제어하도록 바꾼다.

;여기서는 인터럽트가 일어났음을 COUNT 에 기록하지 않는다. 분주비가 1:8

;만약 여기에 COUNT 를 기록한다면, 분주비를 1:16 으로 바꿔야 한다.

RETURN

START BSF STATUS,5 ; Bank 1 으로 변환

MOVLW B'00000110' ; RA 를 모두 디지털로 바꾸기 위해 워킹에 담아서

MOVWF ADCON1 ; ADCON1 으로 옮김

MOVLW B'00011000';RC7:5, RC2:0 (세그먼트 a,b,c,d,e,f 부분) 을 출력으로 사용하기 위해 워킹에 담아서

MOVWF TRISC ; TRISC 으로 옮김

BCF TRISA,1;세그먼트 g 부분을 출력으로 사용

BCF TRISA,0;세그먼트 dot 부분을 출력으로 사용

BCF TRISB,1;1의 자리 세그먼트 출력으로 사용

BCF TRISB,2;10의 자리 세그먼트 출력으로 사용

BSF TRISB,3;SW1 를 입력으로 사용

BSF TRISB,4;SW2 를 입력으로 사용

BSF TRISB,5;SW3 를 입력으로 사용

BCF TRISA,4;부저를 출력으로 사용

MOVLW B'00000010' ;TMR0 분주비를 1:8 로 바꾸고 PORTB를 Pull-up 으로 바꾸기 위해 워킹에 담아서

MOVWF OPTION_REG ; OPTION_REG 로 옮김

BCF STATUS,5 ;Bank 0 으로 변환

BSF PORTA,4 ; 부저가 울리지 않도록 꺼줌 (Pull 이므로 BSF)

BSF INTCON,7 ;인터럽트 사용을 위해 Global Interrupt 활성화

BSF INTCON,5 ;타이머로 인터럽트 작동을 위해 TMR0 Overflow Interrupt 활성화

MAIN CALL initialize ;흐른 시간이 남아있지 않도록 초기화

GOTO STOP ; 전원을 넣자마자 시간이 흐르지 않게 멈춤

SEC1_LOOP

MOVLW .244 ; 인터럽트 횟수 확인

SUBWF COUNT,W ; 워킹에 (COUNT - 워킹) 값을 담는다.

BTFSS STATUS,2 ; 워킹에 0 이 되어서 Zeroflag 가 1이 되는지 확인한다. (COUNT=244 인지 확인)

GOTO SW_CHECK ; SW 를 누르는지 확인 + 숫자 1 증가 루프로 돌아간다

;1:8 분주비에 1us 가 지나고, 244번이 쌓이면 실제로 숫자를 증가시킨다.

CK_LOOP

CLRF COUNT

INCF D_1SEC ;1의 자리의 값을 증가시킨다.

MOVLW .10 ;

SUBWF D_1SEC,W ; 워킹에 (D_1SEC - 워킹) 값을 담는다.

BTFSS STATUS,2 ; 워킹에 0 이 되어서 Zeroflag 가 1이 되는지 확인한다. (D_1SEC=10 인지 확인)

GOTO SW_CHECK ; 워킹 0 아니면 SW 를 누르는지 확인 + 숫자 1 증가 루프로 돌아간다

; 워킹에 0 이 저장되어 있으면 (0~9 까지 다 했으면)

CLRF D_1SEC ;1의 자리에 저장된 수를 초기화 시킨다.

INCF D_10SEC ;10의 자리에 값을 증가시킨다.

MOVLW .6

SUBWF D_10SEC,W ; 워킹에 (D_10SEC - 워킹) 값을 담는다.

BTFSS STATUS,2 ; 워킹에 0 이 되어서 Zeroflag 가 1이 되는지 확인한다. (D_10SEC=6 인지 확인)

GOTO SW_CHECK ; 워킹 0 아니면 SW 를 누르는지 확인 + 숫자 1 증가 루프로 돌아간다

; 워킹에 0이 저장되어 있으면 (0~5 까지 다 했으면)

CLRF D_1SEC ;1의 자리에 저장된 수를 초기화 시킨다.

CLRF D_10SEC ;10의 자리에 저장된 수를 초기화 시킨다.

BCF PORTA,4 ; 부저를 켠다.

CALL DELAY ; 딜레이 초 시간 유지

BSF PORTA,4 ; 부저를 끈다.

GOTO MAIN ; 처음으로 돌아간다.

SW_CHECK

BTFSS PORTB,3 ;SW3(리셋) 을 누르면

GOTO MAIN ; 메인으로 돌아간다.

BTFSS PORTB,4 ;SW2(정지) 를 누르면

GOTO STOP ; 정지한다.

GOTO SEC1_LOOP ; 둘다 안눌렀으면, 계속 루프를 돈다.

STOP BTFSC PORTB,5 ;SW3(리셋) 을 누른지 확인한다.

GOTO STOP2 ; 안눌렀으면, 계속 멈춰있는다.

CALL DELAY ; 눌렀으면 여기로 와서

GOTO SEC1_LOOP; 다시 루프를 돈다.

STOP2 BTFSC PORTB,3 ;SW3(리셋) 을 누르면

GOTO STOP ; 안눌렀으면, 계속 멈춰있는다.

GOTO MAIN; 메인으로 돌아간다.

;LOOKUP_1 은 a,b,c,d,e,f 만 관리

LOOKUP_1 ANDLW 0FH ;9보다 큰 값이 나오면 9 안에서 끝나도록, 뒷자리 4 비트만 살림

ADDWF PCL,F

RETLW B'11111111' ;0

RETLW B'01111000' ;1

RETLW B'11011011' ;2

RETLW B'11111010' ;3

RETLW B'01111100' ;4

RETLW B'10111110' ;5

RETLW B'10111111' ;6

RETLW B'11111100' ;7

RETLW B'11111111' ;8

RETLW B'11111100' ;9

;LOOKUP_2 는 g, dot 만 관리

LOOKUP_2 ANDLW 0FH ;9보다 큰 값이 나오면 9 안에서 끝나도록, 뒷자리 4 비트만 살림

ADDWF PCL,F

RETLW B'00010000' ;0

RETLW B'00010000' ;1

RETLW B'00010010' ;2

RETLW B'00010010' ;3

RETLW B'00010010' ;4

RETLW B'00010010' ;5

RETLW B'00010010' ;6

RETLW B'00010000' ;7

RETLW B'00010010' ;8

RETLW B'00010010' ;9

RETLWDELAY MOVLW .1 ;딜레이

DE_LOOP2 MOVWF BUF

MOVLW .255

MOVWF BUF2

DE_LOOP1 DECFSZ BUF2

GOTO DE_LOOP1

DECFSZ BUF

GOTO DE_LOOP2

RETURN

initialize MOVLW B'00000000'

MOVWF COUNT ;시간계수 초기화

MOVWF D_10SEC ;1의 자리 초기화

MOVWF D_1SEC ;10의 자리 초기화

MOVWF FLAG ;10의 자리부터 시작을 위해 초기화 (시간계수 미세한 오차방지)

RETURN

END

