;; vim: set expandtab ai textwidth=80:
                .TITLE  BUILT2
                .IDENT  /V01.00/
                .INCLUDE lib/bk11m/bk11m.inc

;; ����� � �������� ������������� ������������ ������
LoadAddr==40000               
;; =============================================
;;  �������� ������������ SayHi, ������� 
;;  ������� �� ����� �������.
;;  ���������� ������� SAV.
;; =============================================
                .PSECT  SUBS,SAV
.=.+LoadAddr                
                .LIMIT          ; ��� ��������������� ���������� ��������
                                ; ������
SayHi::         .BPRIN  #HiStr
                rts     PC
HiStr:          .ASCIZ  /I'm overlay!/                
                .END 
