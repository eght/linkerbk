;; vim: set expandtab ai textwidth=80:
                .TITLE  SIMLBL
                .IDENT  /V00.10/
;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:          jsr     PC,@140010      ; �������������� ������� ��11�
                mov     #30204,R0
                jsr     PC,@140132      ; ������� � 80 �������� � ������ (� ��.)
                mov     #Welcome,R0
                jsr     PC,@140160      ; ����� ������ 
                jsr     PC,@140076      ; �������� ������� �������
                mov     #Bye,R0
                jsr     PC,@140160      ; ��� ����� ������
                jsr     PC,@140076      ; ��� �������� ������ �������
                jmp     @#140000        ; reset ��������
Welcome:        .ASCIZ  /Very simple MACRO-11 program./
Bye:            .ASCIZ  /Bye./
                .END    Start

