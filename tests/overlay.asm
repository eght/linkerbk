;; vim: set expandtab ai textwidth=80:
                .TITLE  OVERL
                .IDENT  /V00.11/
                .MCALL  .BINIT,.BEXIT
                .MCALL  AFTER$MKDOS,MKDOS$TAPE
LoadAddr=40000               

;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:          AFTER$MKDOS             ; ���� ��������� ������������ �������
                                        ; MKDOS
                .BINIT                  ; �������������� ������� ��11�
                MKDOS$TAPE #TapeParams
                .BEXIT
                .EVEN
TapeParams:     .BLKB   3,0                
                .END    Start

