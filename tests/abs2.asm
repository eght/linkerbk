;; vim: set expandtab ai textwidth=80:
                .TITLE  TSTAB2
                .IDENT  /V00.11/
                .INCLUDE lib/bk11m/bk11m.inc

                ;; ������ ���������� �� ����������
KeyboardVect=60
KeyboardPSW=KeyboardVect+2

.=.+1000        ;; ��� ������ ���������� � 0, ������� ����� ��������
Start:          .BINIT                  ; �������������� ������� ��11�
                .BTSET  #30204          ; ������� � 80 �������� � ������ (� ��.)

                .BPRIN   #HelloStr
                ;; ���������� ������ ���������� ����������
                mov     @#KeyboardVect,OldHandler
                mov     @#KeyboardPSW,OldHandler+2

                ;; <<��� ��������� ������ ����������� � �����-�� ���������>>

                .BTTIN                  ; �������� ������� �������
                .BEXIT                  ; �����
OldHandler:     .BLKW   2               ; ����� ��� ������ ������� �����������
                                        ; ����������
HelloStr:       .ASCIZ  /Hi, there! :)/                                        
                .END    Start

