;; vim: set expandtab ai textwidth=80:
                .TITLE  TSTAB2
                .IDENT  /V00.11/
                KeyboardVect=60
                KeyboardPSW=KeyboardVect+2
;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:          jsr     PC,@140010      ; �������������� ������� ��11�
                mov     #30204,R0
                jsr     PC,@140132      ; ������� � 80 �������� � ������ (� ��.)

                ;; ���������� ������ ���������� ����������
                mov     @#KeyboardVect,OldHandler
                mov     @#KeyboardPSW,OldHandler+2

                ;; <<��� ��������� ������ ����������� � �����-�� ���������>>

                jsr     PC,@140076      ; �������� ������� �������
                jmp     @#140000        ; reset ��������
OldHandler:     .BLKW   2               ; ����� ��� ������ ������� �����������
                                        ; ����������
                .END    Start

