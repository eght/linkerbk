;; vim: set expandtab ai textwidth=80:
                .TITLE  OVRTST
                .IDENT  /V00.11/
                .INCLUDE lib/bk11m/bk11m.inc
                .INCLUDE lib/mkdos/mkdos.inc

;; ����� � �������� ������������� �������                
LoadAddr=40000               

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
                BACK$TO$MKDOS

Prompt:         .ASCIZ  /Press any key to load overlay.../
Loaded:         .ASCIZ  /Overlay loaded./
                .EVEN
TapeParams:     .BYTE   3,0                
                .WORD   LoadAddr,0
1$:             .ASCII  /overlay-SUBS.v/
                .BLKB   ^D16-<.-1$>
                .BLKB   ^D16+4

;; ==========
;;  �������. 
;; ==========
                .PSECT  SUBS
.=.+LoadAddr                
SayHi:          .BPRIN  #HiStr
                rts     PC
HiStr:          .ASCIZ  /I'm overlay!/                
                .END    Start

