;; vim: set expandtab ai textwidth=80:
                .TITLE  RAMBS
                .IDENT  /V00.10/
                .INCLUDE lib/bk11m/bk11m.inc
                .INCLUDE lib/ram-bios/ram-bios.inc
                .INCLUDE lib/mkdos/mkdos.inc

                .PSECT  MAINPS
.=.+1000        ;; ��� ������ ���������� � 0, ������� ����� ��������
Start:          AFTER$MKDOS
                .BINIT                  ; �������������� ������� ��11�
                .BTSET  #30204          ; ������� � 80 �������� � ������ (� ��.)

                .BPRIN   #HelloStr
                .BTTIN                  ; �������� ������� �������

                ; ����������� � ������� �� ����� ���������
                ; ��������� RAM-BIOS
                CAT$    #GetVersion     ; ��������� ������ RAM-BIOS
                mov     R1,-(SP)
                mov     R2,-(SP)
                mov     #NumberBuf,R1
                mov     R1,R4
                jsr     PC,ToStr
                .BSTR   #VersionStr
                .BPRIN  R4
                mov     R4,R1
                mov     (SP)+,R0
                jsr     PC,ToStr
                .BSTR   #NumRecordsStr
                .BPRIN  R4
                mov     R4,R1
                mov     (SP)+,R0
                jsr     PC,ToStr
                .BSTR   #CatalogAddrStr
                .BPRIN  R4
                ; ��������� ������ ����������� ������
                mov     #Module,R1
                clr     R2
                mov     #"CY,Cat.Name(R1)
                mov     #<YCodeEnd-YCode>/2+1,Cat.Len(R1)
                mov     #<Cat.Flags.NoSplit!Cat.Flags.Run!Cat.Flags.Del>,Cat.Flags(R1)
                CAT$    #CreateModule
                ; ������ �������� � �������� ������������ ������
                CAT$    #ReadWriteCatRecord
                .WORD   "CY,Cat.Off
                mov     R1,R0
                mov     R4,R1
                jsr     PC,ToStr
                .BSTR   #SegmentOffStr
                .BPRIN  R4

                ; ��������� ������ ����������� ������
                mov     #Module,R1
                clr     R2
                mov     #"DY,Cat.Name(R1)
                mov     #<YCodeEnd-YCode>/2+1,Cat.Len(R1)
                mov     #<Cat.Flags.NoSplit!Cat.Flags.Run!Cat.Flags.Del>,Cat.Flags(R1)
                CAT$    #CreateModule
                ; ������ �������� � �������� ������������ ������
                CAT$    #ReadWriteCatRecord
                .WORD   "DY,Cat.Off
                mov     R1,R0
                mov     R4,R1
                jsr     PC,ToStr
                .BSTR   #SegmentOffStr
                .BPRIN  R4

                ; ��������� ������������ � ��� ������
                MOV$G   NASEG.Current,#YCode,"CY,0,<#YCodeEnd-YCode>/2+1
                MOV$G   NASEG.Current,#YCode,"DY,0,<#YCodeEnd-YCode>/2+1

                ; ��������� ������ ����� �� ������� ������
                clr     R0
                mov     PC,R1
                CHW$G   0,"DY
                mov     R4,R1
                jsr     PC,ToStr
                .BSTR   #WordStr
                .BPRIN  R4

                ; ��������� ��� ������������
                mov     #123,R3
                CAL$G   0,"CY
                mov     #346,R3
                CAL$G   0,"DY

                ; �������� ����������
                MOV$G   "CY,#Pic-YCode,NASEG.Current,#60000,#PicSize/2
                MOV$G   "DY,#Pic-YCode,NASEG.Current,#PicSize+60000,#PicSize/2

                ; ������� ������
                mov     #"CY,R1
                CAT$    #DeleteModule
                mov     #"DY,R1
                CAT$    #DeleteModule
                .BTTIN

                BACK$TO$MKDOS  RAM
                EXIT$

Module:         .BLKB   20              ; ������ ������������ ������
HelloStr:       .ASCIZ  /Ask RAM-BIOS.../
VersionStr:     .ASCIZ  /Version: /
NumRecordsStr:  .ASCIZ  /Number of catalog records: /
CatalogAddrStr: .ASCIZ  /Address of catalog: /
SegmentOffStr:  .ASCIZ  /Offset in the segment: /
LogSegStr:      .ASCIZ  /Logical segment number: /
WordStr:        .ASCIZ  /First word of module: /
NumberBuf:      .BLKB   7
                .EVEN
; ������� ����� �� R0 � ������ ������������ ���� � ������ R1
ToStr:          mov     #5,R2
                add     R2,R1
                inc     R1
                clrb    (R1)
1$:                          
                movb    R0,-(R1)
                bicb    #370,(R1)
                bisb    #'0,(R1)
                ror     R0
                ror     R0
                ror     R0
                sob     R2,1$
                bicb    #376,R0
                bisb    #'0,R0
                movb    R0,-(R1)
                rts     PC

; ������������, ���������� � ������ SMK � ������������� ����� � ���� ������.
; 
PicSize=2400*2  ; ������, �������� ���������
YCode:          mov     PC,R1
                add     #Pic - .,R1
                mov     #PicSize,R0
1$:             movb    R3,(R1)+
                sob     R0,1$
                rts     PC
Pic:            .BLKB   PicSize
YCodeEnd:                
                .END    Start

