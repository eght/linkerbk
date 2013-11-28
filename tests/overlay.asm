;; vim: set expandtab ai textwidth=80:
                .TITLE  OVERL
                .IDENT  /V00.11/
                .INCLUDE lib/bk11m/bk11m.inc
                .INCLUDE lib/mkdos/mkdos.inc

;; ����� � �������� ������������� �������                
LoadAddr=100000               

;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:          AFTER$MKDOS             ; ���� ��������� ������������ �������
                                        ; MKDOS
                .BINIT                  ; �������������� ������� ��11�

                ; �������������� ������������� ������ ``��� ����'',
                ; � 40000 �������� 1  --- ������ ���.
                ; � 100000 �������� 2 --- ����� ����� �������.
                .BPAGE 1,0
                .BPAGE 5,1

                .BTSET  #30204
                .BPRIN  #Prompt
                .BTTIN

                ; ��������� �������
                MKDOS$TAPE #TapeParams


                .BPRIN  #Loaded
                .BTTIN
                .BEXIT
Prompt:         .ASCIZ  /Press any key to load overlay.../<12>
Loaded:         .ASCIZ  /Overlay loaded./
                .EVEN
TapeParams:     .BYTE   3,0                
                .WORD   LoadAddr,0
1$:             .ASCII  /overlay/
                .BLKB   ^D16-<.-1$>
                .BLKB   ^D16+4
                .END    Start

