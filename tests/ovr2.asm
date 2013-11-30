;; vim: set expandtab ai textwidth=80:
                .TITLE  OVR2
                .IDENT  /V01.00/
                .INCLUDE lib/bk11m/bk11m.inc
                .INCLUDE lib/mkdos/mkdos.inc

;; ����� � �������� ������������� �������
LoadAddr=40000               

                .PSECT  MAIN
;; ��� ������ ���������� � 0, ������� ����� ��������
.=.+1000
Start:          AFTER$MKDOS             ; ���� ��������� ������������ �������
                                        ; MKDOS
                .BINIT                  ; �������������� ������� ��11�

                ; �������������� ������������� ������ ``��� ����'',
                ; � 40000 �������� 1  --- ����� ����� �������
                ; � 100000 �������� 2 --- ������ ���, ����� ��� �������� �� ����
                ; MKDOS.
                .BPAGE 1,0
                .BPAGE 2,1

                .BTSET  #30204
                .BPRIN  #Prompt
                .BTTIN

                ; ��������� �������
                MKDOS$TAPE #TapeParams

                ; �������� ������� �� �������
                jsr     PC,SayHi

                .BPRIN  #Loaded
                .BTTIN
                BACK$TO$MKDOS           ; ����� � MKDOS

Prompt:         .ASCIZ  /Press any key to load overlay.../
Loaded:         .ASCIZ  /Overlay loaded./
                .EVEN
TapeParams:     .BYTE   3,0                
                .WORD   LoadAddr,0
1$:             .ASCII  /ovr2-SUBS.v/        ; ��� ����� �������
                .BLKB   ^D16-<.-1$>
                .BLKB   ^D16+4

;; ������ ������, ������ �������� ��������� ��������
;; � ������ .asm ������ ������ � ������ SUBS ����� ������������ 
;; ����
                .PSECT  SUBS
.=.+LoadAddr                
                .END    Start

