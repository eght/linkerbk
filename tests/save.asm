;; vim: set expandtab ai textwidth=80:
                .TITLE  BUILT
                .IDENT  /V01.00/
                .INCLUDE lib/bk11m/bk11m.inc
                .INCLUDE lib/mkdos/mkdos.inc

                .PSECT  MAIN
;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:          AFTER$MKDOS             ; ���� ��������� ������������ �������
                                        ; MKDOS
                .BINIT                  ; �������������� ������� ��11�

                ; �������������� ������������� ������ ``��� ����'',
                ; � 40000 �������� 1  --- ����� ����� ������������ ������
                ; � 100000 �������� 2 --- ������ ���, ����� ��� �������� �� ����
                ; MKDOS.
                .BPAGE 1,0
                .BPAGE 2,1

                .BTSET  #30204
                .BPRIN  #Prompt
                .BTTIN

                ; ���������� ������
                mov     #EndOfMain,R1   ; ������ ������ ���������� � .LIMIT
                mov     (R1),R2         ; R2 --- ��������� ����� ��� ����������
                                        ; ������
                mov     2(R1),R0        ; R0 --- ����� ������ 
                sub     R2,R0
                ror     R0
                adc     R0
1$:             mov    (R1)+,(R2)+                
                sob     R0,1$
                ; �������� ������� �� ������������ ������
                jsr     PC,SayHi

                .BPRIN  #Loaded
                .BTTIN
                BACK$TO$MKDOS           ; ����� � MKDOS

Prompt:         .ASCIZ  /Press any key to load overlay.../
Loaded:         .ASCIZ  /Overlay loaded./
                .EVEN
EndOfMain:      ; ��� ����� �������� ������ � ������ ������������ ������
                .END    Start

