;; vim: set expandtab ai textwidth=80:
                .TITLE  TSTAB2
                .IDENT  /V00.11/
                .MCALL  .BINIT,.BEXIT,.BTSET,.BSTR,.BTTIN

                ;; ������ ���������� �� ����������
KeyboardVect=60
KeyboardPSW=KeyboardVect+2
;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:    
                .BINIT                  ; �������������� ������� ��11�
                .BTSET  #30204          ; ������� � 80 �������� � ������ (� ��.)

                .BSTR   #HelloStr
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

