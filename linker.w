% vim: set ai textwidth=80:
\input macro

\def\version{0.1}
\font\twentycmcsc=cmcsc10 at 20 truept

\datethis

@* ��������.
\vskip 120pt
\centerline{\twentycmcsc linkbk}
\vskip 20pt
\centerline{���������� ��������� ��������� ������ ���������� MACRO-11}
\vskip 2pt
\centerline{(������ \version)}
\vskip 10pt
\centerline{Yellow Rabbit}
\vskip 80pt

@* ����� ����� ���������.
@c
@<��������� ������������ ������@>@;
@h
@<���������@>@;
@<����������� ���� ������@>@;
@<���������� ����������@>@;
int
main(int argc, char *argv[])
{
	@<������ ���������@>@;
	const char *objname;
	int i, all_resolved;

	@<��������� ��������� ������@>@;
	@<������������� �������� ������@>@;
	@<������������� ������� ���������� ��������@>@;
	@<������������� ������ ������ ��� ��������@>@;

	/* ���������� ������������ ��� �������� ��������� ����� */
	cur_input = 0;
	all_resolved = 1;
	while ((objname = config.objnames[cur_input]) != NULL) {
		@<������� ��������� ����@>@;
		handleOneFile(fobj);
		/* ��������� ���������� ������ */
		all_resolved = resolveGlobals();
		fclose(fobj);
		++cur_input;
	}
	@<����� ������� ���������� ��������@>@;
	@<������ ���� ����������@>@;
	@<������� �������� ������@>@;
	@<���������� ������ ������ ��� ��������@>@;
	return(0);
}

@ ����� �������� ��������������� ���������� �����.
@<���������� ����������@>=
static int cur_input;
@ @<������ ���������@>=
FILE *fobj, *fresult;

@ @<������� ��������� ����@>=
	fobj = fopen(objname,"r");
	if (fobj== NULL) {
		PRINTERR("Can't open %s\n", objname);
		return(ERR_CANTOPEN);
	}

@ �� ��������� � ��������� ������ ����� �������� ���� � ����������� �������,
��� ������� ������ ����� �������. ��������� ������ ��������� ����� �����������
������ � �������������� ����� (�������).
@<������ ���� ����������@>=
	fresult = fopen(config.output_filename, "w");
	if (fresult == NULL) {
		PRINTERR("Can't create %s\n", config.output_filename);
		return(ERR_CANTCREATE);
	}
	for (i = 0; i < NumSections; ++i) {
		if (SectDir[i].transfer_addr == 1 || SectDir[i].len == 0) 
			continue;
		fwrite(SectDir[i].text + SectDir[i].min_addr, 
			SectDir[i].len - SectDir[i].min_addr, 1, fresult);
	}
	fclose(fresult);

@* ��������� ���������� �����.

@ ��������� ���������� �����.
��������� ���� ������� �� ������, ������� ���������� ����������
 |BinaryBlock|, ���������� ������ ������ |len - 4| � ����� 
����������� ����� (0 - ����� ���� ����).  ����� ������� ����� ���� ������������
���������� ������� ����.
@ @<����������� ���� ������@>=
typedef struct _BinaryBlock {
	uint8_t	one;	/* must be 1 */
	uint8_t	zero;	/* must be 0 */
	uint16_t len; /* length of block */
} BinaryBlock;


@ ���������� ���� ��������� ����.
@c
static void
handleOneFile(FILE *fobj) {
	BinaryBlock obj_header;
	int first_byte;
	unsigned int block_len;
	
	while (!feof(fobj)) {
		/* ���� ������ ����� */
		do {
			first_byte = fgetc(fobj);
			if (first_byte == EOF) goto end;
		} while (first_byte != 1);

		/* ������ ��������� */
		ungetc(first_byte, fobj);
		if (fread(&obj_header, sizeof(BinaryBlock), 1, fobj) != 1) {
			PRINTERR("IO error: %s\n",config.objnames[cur_input]);
			break;
		}
		if (obj_header.zero != 0) continue;
		block_len = obj_header.len - 4;
		PRINTVERB(2, "Binary block found. Length:%o\n", block_len);

		/* ������ ���� ����� � ���������� ������ */
		if (fread(block_body, block_len + 1, 1, fobj) != 1) {
			PRINTERR("IO error: %s\n", config.objnames[cur_input]);
			break;
		}
		@<���������� ����@>@;
	}
end:;
}

@ ������ ��� ���� �����. 
@<����������...@>=
static uint8_t block_body[65536 + 1];

@ ��������� ������ ��������� �����. �� ������� ����� ����� �������� ��� ���.
@<���������� ����@>=
	PRINTVERB(2, "  Block type: %o, ", block_body[0]);
	switch (block_body[0]) {
		case 1 :
			PRINTVERB(2, "GSD\n");
			@<��������� GSD@>@;
			break;
		case 2 :
			PRINTVERB(2, "ENDGSD\n");
			break;
		case 3 :
			PRINTVERB(2, "TXT\n");
			@<���������� ������ TXT@>@;
			break;
		case 4 :
			PRINTVERB(2, "RLD\n");
			@<���������� ������ �����������@>@;
			break;
		case 5 :
			PRINTVERB(2, "ISD\n");
			break;
		case 6 :
			PRINTVERB(2, "ENDMOD\n");
			break;
		case 7 :
			PRINTVERB(2, "Librarian header\n");
			break;
		case 8 :
			PRINTVERB(2, "Librarian end\n");
			break;
		default :
		  PRINTERR("Bad block type: %o : %s\n",
		  block_body[0], config.objnames[cur_input]);
	}

@* GSD.
@ ������ ����� GSD~---~Global Symbol Directory (������� ���������� ��������). ��
�������� ��� ����������, ����������� ���������� ��� ������������ �������
���������� �������� � ��������� ������.
������� ������� �� 8-�� �������� ������� ��������� �����:
@d GSD_MODULE_NAME			0
@d GSD_CSECT_NAME			1
@d GSD_INTERNAL_SYMBOL_NAME 2
@d GSD_TRANFER_ADDRESS		3
@d GSD_GLOBAL_SYMBOL_NAME	4
@d GSD_PSECT_NAME			5
@d GDS_IDENT				6
@d GSD_MAPPED_ARRAY			7
@<��������� GSD@>=
	handleGSD(block_len);
@ @<����������� ����...@>=
typedef struct _GSD_Entry {
	uint16_t name[2];
	uint8_t flags;
	uint8_t type;
	uint16_t value;
} GSD_Entry;

@ @c
static void 
handleGSD(int len) {
	int i, sect;
	GSD_Entry *entry;
	char name[7];

	for (i = 2; i< len; i += 8) {
		entry = (GSD_Entry*)(block_body + i);
		@<����������� ���@>@;
		PRINTVERB(2, "    Entry name: '%s', type: %o --- ", name, entry->type);
		switch (entry->type) {
			case GSD_MODULE_NAME: 
				/* ������ ��� ������. */
				PRINTVERB(2, "ModuleName.\n");
				PRINTVERB(1, "Module:%s\n", name);
				break;
			case GSD_CSECT_NAME:
				/* ��� ����������� ������ */
				PRINTVERB(2, "CSectName, flags:%o, length:%o.\n",
						entry->flags, entry->value);
				break;
			case GSD_INTERNAL_SYMBOL_NAME:
				/* ��� ����������� ������� */
				PRINTVERB(2, "InternalSymbolName\n");
				break;
			case GSD_TRANFER_ADDRESS:
				/* ����� ������� ��������� */
				PRINTVERB(2, "TransferAddress, offset:%o.\n", entry->value);
				@<���������� ����� �������@>@;
				break;
			case GSD_GLOBAL_SYMBOL_NAME:
				/* �����������/������ �� ���������� ����� */
				PRINTVERB(2, "GlobalSymbolName, flags:%o, value:%o.\n",
						entry->flags, entry->value);
				@<���������� ���������� ������� � ������@>@;		
				break;		
			case GSD_PSECT_NAME:
				/* ��� ����������� ������ */
				PRINTVERB(2, "PSectName, flags:%o, max length:%o.\n",
						entry->flags, entry->value);
				@<���������� ����������� ������@>@;
				break;
			case GDS_IDENT:
				/* ������ ������ */
				PRINTVERB(2, "Ident.\n");
				PRINTVERB(1, "  Ident: %s\n", name);
				break;
			case GSD_MAPPED_ARRAY:
				/* ������ */
				PRINTVERB(2, "MappedArray, length:%o.\n", entry->value);
				break;
			default:
			  PRINTERR("Bad entry type: %o : %s\n", 
				entry->type, config.objnames[cur_input]);
		}
	}
}

@ @<����������� ���@>=
	fromRadix50(entry->name[0], name);
	fromRadix50(entry->name[1], name + 3);

@ ������ �����������/������ �� ���������� ������.
@ ������� ���������� ��������. |addr| �������� ��� ��������� ����� ������������
0.
@d MAX_GLOBALS 512
@<����������� ���� ������...@>=
typedef struct _GSymDefEntry {
	uint16_t name[2];	
	uint8_t	flags;
	uint8_t	 sect; /* ����� ������, � ������� ��������� ���������� ������ */
	uint16_t addr; /* ����� ������� � ������ */
} GSymDefEntry;


@ @<���������� ����������...@>=
static GSymDefEntry GSymDef[MAX_GLOBALS];
static int NumGlobalDefs;

@ @<������������� ������� ���������� ��������@>=
	NumGlobalDefs = 0;

@
@d GLOBAL_WEAK_MASK	  001 // 00000001b
@d GLOBAL_DEFINITION_MASK 010 // 00001000b
@d GLOBAL_RELOCATION_MASK 040 // 00100000b
@c
static void
handleGlobalSymbol(GSD_Entry *entry) {
	if (entry->flags & GLOBAL_DEFINITION_MASK) {
		GSymDef[NumGlobalDefs].name[0] = entry->name[0];
		GSymDef[NumGlobalDefs].name[1] = entry->name[1];
		GSymDef[NumGlobalDefs].flags = entry->flags;
		GSymDef[NumGlobalDefs].sect = CurSect;
		GSymDef[NumGlobalDefs].addr = SectDir[CurSect].start + entry->value;
		++NumGlobalDefs;
	}
	if (config.verbosity >= 2) {
		PRINTVERB(2, "        Flags: ");
		if (entry->flags & GLOBAL_WEAK_MASK) {
			PRINTVERB(2, "Weak,");
		} else {
			PRINTVERB(2, "Strong,");
		}
		if (entry->flags & GLOBAL_DEFINITION_MASK) {
			PRINTVERB(2, "Definition,");
		} else {
			PRINTVERB(2, "Reference,");
		}
		if (entry->flags & GLOBAL_WEAK_MASK) {
			PRINTVERB(2, "Relative.\n");
		} else {
			PRINTVERB(2, "Absolute.\n");
		}
	}	
}

@ ����� ������ � �������. -1~---~������ �� ������.
@c
static int findGlobalSym(uint16_t *name) {
	int found, i;

	found = -1;
	for (i = 0; i< NumGlobalDefs; ++i) {
		if (name[0] == GSymDef[i].name[0] && name[1] == GSymDef[i].name[1]) {
			found = i;
			break;
		}
	}

	return(found);
}

@ @<���������� ����������...@>=
static int findGlobalSym(uint16_t *);

@ @<������ ���������...@>=
	char name[7];
@ @<����� ������� ���������� ��������@>=
	if (config.verbosity >= 1) {
		PRINTVERB(1, "=Global Definitions:\n");
		for(i = 0; i < NumGlobalDefs; ++i) {
			fromRadix50(GSymDef[i].name[0], name);
			fromRadix50(GSymDef[i].name[1], name + 3);
			fromRadix50(SectDir[GSymDef[i].sect].name[0], sect_name);
			fromRadix50(SectDir[GSymDef[i].sect].name[1], sect_name + 3);
			PRINTVERB(1, "%s: %s/%o\n", name, sect_name,
			GSymDef[i].addr);
		}	
	}
@ ������ ����������� ������. ������ � ������� �������� � �������� ������.
@d MAX_PROG_SECTIONS 254
@<����������� ����...@>=
typedef struct _SectionDirEntry {
	uint16_t name[2];	// ��� � Radix50
	uint8_t	 flags;	// ����� ������
	uint16_t start;		// �������� ������ ��� �������� ������
	int32_t min_addr;  // ����������� �����, � �������� ����������� ������
	uint16_t len;	// ����� ������
	uint16_t transfer_addr; // ����� ������ (1 --- ������ �� ���������)
	uint16_t last_load_addr; // ����� ���������� ������������ ����� TEXT
	uint8_t *text;	// ����� ����� ������ ��� ������ ������
} SectionDirEntry;
@ @<���������� ����������...@>=
static SectionDirEntry SectDir[MAX_PROG_SECTIONS];
static int NumSections;
@
@d PSECT_SAVE_MASK	  0001	// 00000001b
@d PSECT_ALLOCATION_MASK  0004  // 00000100b
@d PSECT_ACCESS_MASK	  0020  // 00010000b
@d PSECT_RELOCATION_MASK  0040  // 00100000b
@d PSECT_SCOPE_MASK	  0100  // 01000000b
@d PSECT_TYPE_MASK	  0200  // 10000000b
@c
static void
handleProgramSection(GSD_Entry *entry) {
	@<������� ���������� ���������� �� �������@>@;
	CurSect = findSection(entry->name);
	if (CurSect == -1) {
		@<�������� ����������� ������@>@;
	} else {
		// �������� �������� ������ � ������
		SectDir[CurSect].start += SectDir[CurSect].len;
		SectDir[CurSect].len += entry->value;
	}
}

@ @<���������� ����������...@>=
static int CurSect;

@ ������������� ������� ������.
@<��������� ������� ������ � �������@>=
	const_entry = (RLD_Const_Entry *) entry;
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Name: %s, +Const: %o.\n", gname,
		const_entry->constant);
	CurSect = findSection(entry->value);
	if (SectDir[CurSect].min_addr == -1 ||
		SectDir[CurSect].min_addr > (const_entry->constant +
			SectDir[CurSect].start)) {
		SectDir[CurSect].min_addr = const_entry->constant +
			SectDir[CurSect].start;
	}
	RLD_i += 8;

@ ����� �������, ������ ������� ������������.
@ @<���������� ����� �������@>=
	sect = findSection(entry->name);
	SectDir[sect].transfer_addr = entry->value;
@ ���������� ������ |TEXT|. ���������� ����������� � ������� ������
|CurSect|. ��������� ������ |TEXT| ����� ��������� ���� �� ������, � ���� �
��������� �� ��� ����������� ������ ��������� �������, �� ���������� �����, �
�������� ���� ��������� ��������� ������ |TEXT|.
@c
static void 
handleTextSection(uint8_t *block, unsigned int len) {
	uint16_t addr;

	addr = block[2] + block[3] * 256;
	PRINTVERB(2, "  Load address: %o, Current section: %d.\n", addr,
	CurSect);
	memcpy(SectDir[CurSect].text + SectDir[CurSect].start + addr, block + 4, len - 4);
	SectDir[CurSect].last_load_addr = SectDir[CurSect].start + addr;
}

@
@<������������� �������� ������@>=
	NumSections = 0;
	memset(SectDir, 0, sizeof(SectDir));

@ @<������ ���������...@>=
	char sect_name[7];
@ @<������� �������� ������@>=
	PRINTVERB(1, "=Sections:\n");
	for (i = 0; i < NumSections; ++i) {
		fromRadix50(SectDir[i].name[0], sect_name);
		fromRadix50(SectDir[i].name[1], sect_name + 3);
		PRINTVERB(1, "%s, addr: %p, len: %o, min addr: %o,"
			" current start: %o\n", sect_name,
		SectDir[i].text, SectDir[i].len, SectDir[i].min_addr,
		SectDir[i].start);
		if (SectDir[i].text != NULL)
			free(SectDir[i].text);
	}
	
@ ����� ����������� ������ �� �����.
@c
static int
findSection(uint16_t *name) {
	int found, i;

	found = -1;
	for (i = 0; i < NumSections; ++i) {
		if (SectDir[i].name[0] == name[0] && SectDir[i].name[1] ==
		name[1]) {
			found = i;
			break;
		}
	}

	return(found);
}
@  ������ ���������� ��� ��� ������, ���� ��, ������� ����� ������� �����.
@d DEFAULT_SECTION_LEN 65536
@<�������� ����������� ������@>=
	SectDir[NumSections].name[0] = entry->name[0];
	SectDir[NumSections].name[1] = entry->name[1];
	SectDir[NumSections].flags = entry->flags;
	SectDir[NumSections].len = entry->value;
	/* ���� ������ ��� ������� ������������� �� �����, �� �������� ����� */
	if (!(entry->flags & PSECT_TYPE_MASK)) {
		if(SectDir[NumSections].len & 1)
			++SectDir[NumSections].len;
	}
	SectDir[NumSections].min_addr = -1;
	SectDir[NumSections].transfer_addr = 1;
	SectDir[NumSections].text = (uint8_t*)calloc(1, DEFAULT_SECTION_LEN);
	CurSect = NumSections;
	++NumSections;

@ @<���������� ���������...@>=
static int findSection(uint16_t *);


@ @<������� ���������� ���������� �� �������@>=
	if (config.verbosity >= 2) {
		PRINTVERB(2, "        Flags: ");
		if (entry->flags & PSECT_SAVE_MASK) {
			PRINTVERB(2, "RootScope,");
		} else {
			PRINTVERB(2, "NonRootScope,");
		}
		if (entry->flags & PSECT_ALLOCATION_MASK) {
			PRINTVERB(2, "Overlay,");
		} else {
			PRINTVERB(2, "Concatenate,");
		}
		if (entry->flags & PSECT_ACCESS_MASK) {
			PRINTVERB(2, "ReadOnly,");
		} else {
			PRINTVERB(2, "ReadWrite,");
		}
		if (entry->flags & PSECT_RELOCATION_MASK) {
			PRINTVERB(2, "Relocable,");
		} else {
			PRINTVERB(2, "Absolute,");
		}
		if (entry->flags & PSECT_SCOPE_MASK) {
			PRINTVERB(2, "Global,");
		} else {
			PRINTVERB(2, "Local,");
		}
		if (entry->flags & PSECT_TYPE_MASK) {
			PRINTVERB(2, "Dref.\n");
		} else {
			PRINTVERB(2, "Iref.\n");
		}
	}

@* ������ ������ �� ���������� �������.
@ ���� ��� ���� ������ �� ���������� �������: ��� ���������� ���������, �
����������� ��������� � ������� ������. ������ ��� ���� ����� �������������
(���� � ������) ������, � ������~---~������������ ������.

������� ���������, ������� ��������� �� ������� ����������� ��� ���������
������, � ���������� �������� ������ � ��������� � �������.

@ ��������� �������� ������ ��� �������� ������ ���  ���������.
@d INITIAL_SIMPLE_REF_LIST_SIZE 100
@<����������� ���� ������...@>=
typedef struct _SimpleRefEntry {
	uint16_t link; /* ���� ����� */
	uint8_t	type;
	uint8_t	sect;	/* ����� ������ */
	uint16_t	disp;	/* �������� � ������ ��� ����������� ����� ����� ������ */
	uint16_t name[2];
} SimpleRefEntry;
typedef struct _SimpleRefList {
	uint16_t avail;	/* ������ ������ ��������� ������ */
	uint16_t poolmin;	/* ����� �������� --- ������ ������� ���� */
	SimpleRefEntry *pool;	/* ������ ��� �������� ������ */
} SimpleRefList;

@ @<���������� ����������...@>=
static SimpleRefList SRefList;
static int simpleRefIsEmpty(void);
@ 
@c
static int
simpleRefIsEmpty(void) {
	return(SRefList.pool[0].link == 0);
}

@ ��������� ����� ������ � ������
@c
static void
addSimpleRef(RLD_Entry *ref) {
	SimpleRefEntry *new_entry;
	uint16_t new_index;

	/* ���� �� ������� ���������� ������� ���� */
	if (SRefList.poolmin == INITIAL_SIMPLE_REF_LIST_SIZE) {
		PRINTERR("No memory for simple ref list");
		return;
	}
	/* ���� ���� ��������� ����� */
	if (SRefList.avail != 0) {
		new_index = SRefList.avail;
		SRefList.avail = SRefList.pool[SRefList.avail].link;
	} else {
	/* ��������� ������ ���, ���������� ��� */
		new_index = SRefList.poolmin;
		++SRefList.poolmin;
	}
	new_entry = SRefList.pool + new_index;
	new_entry->link = SRefList.pool[0].link;
	SRefList.pool[0].link = new_index;

	/* ���������� ������ ������ */
	new_entry->name[0] = ref->value[0];
	new_entry->name[1] = ref->value[1];
	new_entry->disp = ref->disp - 4 + SectDir[CurSect].last_load_addr;
	new_entry->sect = CurSect;
	new_entry->type = ref->cmd.type;
}

@ ������� ������ �� ������. ���������� ���� ����� ��������� ��������. ������
���������� �������: �������� ��� �������� � ���� ����� ����������� ��������.
@c
static uint16_t 
delSimpleRef(uint16_t ref_i) {
	uint16_t link;

	link = SRefList.pool[ref_i].link;
	SRefList.pool[ref_i].link = SRefList.avail;
	SRefList.avail = ref_i;
	
	return(link);
}

@ |poolmin| ������������� ������ 1, ��� ��� ��� ������ ������� �������� ������
������� ������� ���� �� ������������, � ��� ����� ��������� ���-�� ����� NULL.
@<������������� ������ ������ ��� ��������...@>=
	SRefList.pool = (SimpleRefEntry *)malloc(sizeof(SimpleRefEntry) *
		INITIAL_SIMPLE_REF_LIST_SIZE);
	SRefList.pool[0].link = 0;	
	SRefList.avail = 0;
	SRefList.poolmin = 1;

@ @<���������� ������ ������ ��� ��������...@>=
	if (config.verbosity >= 2) {
		PRINTVERB(2, "=Simple Refs:\n avail: %d, poolmin: %d\n",
		 SRefList.avail, SRefList.poolmin);
		for (i = SRefList.pool[0].link; i != 0; i = SRefList.pool[i].link) {
			fromRadix50(SRefList.pool[i].name[0], name);
			fromRadix50(SRefList.pool[i].name[1], name + 3);
			fromRadix50(SectDir[SRefList.pool[i].sect].name[0], sect_name);
			fromRadix50(SectDir[SRefList.pool[i].sect].name[1], sect_name + 3);
			PRINTVERB(2, "i: %4d, name: %s, disp: %s/%o\n", i, name, sect_name,
			SRefList.pool[i].disp);
		}
	}
	free(SRefList.pool);

@ @<���������� ����������...@>=
static void addSimpleRef(RLD_Entry *);
static uint16_t delSimpleRef(uint16_t);

@* ���������� ������ �� ���������� �������.
@ ��������� ��������� ������ ������ �� ���������� ������� � ������� ��� �� ���
����������� ��������� ������. ���������� 0, ���� ������������� ������ ���.
@c
static int
resolveGlobals(void) {
	uint16_t ref, *dest_addr;
	int global;
	char name [7];

	PRINTVERB(2, "resolve globals. [0].link: %d\n", SRefList.pool[0].link);
	/* ������ ��� �������� */
	if (!simpleRefIsEmpty()) {
		for (ref = SRefList.pool[0].link; ref != 0; ref =
			SRefList.pool[ref].link) {
			global = findGlobalSym(SRefList.pool[ref].name);
			if (global == -1) {
				continue;
			}
			fromRadix50(SRefList.pool[ref].name[0], name);
			fromRadix50(SRefList.pool[ref].name[1], name + 3);
			PRINTVERB(2, "try resolve %s.", name);
			if (SRefList.pool[ref].type == RLD_CMD_GLOBAL_RELOCATION) {
				/* ������ ������ */
				PRINTVERB(2, " global: %d, sect: %d, disp: %o, addr: %o\n", global, SRefList.pool[ref].sect,
					SRefList.pool[ref].disp, GSymDef[global].addr);
				dest_addr =
				(uint16_t*)(SectDir[SRefList.pool[ref].sect].text + SRefList.pool[ref].disp);
				*dest_addr = GSymDef[global].addr;
			}
		}
	}
	return (simpleRefIsEmpty() && 1);
}


@ @<���������� ����������...@>=
static int resolveGlobals(void);

@* �������� �����������.
@ ����� ��������� ����������� �������� ����������, ������� ����� ���������� ���
������������� ������ � ���������� ����� |TEXT|. ������ ������ ������� ����� ����
�� ���� ���� RLD, ������� ���������� ������� ���� ������ |TEXT|, ���
������~---~������� ������� PSECT � � ����������.

������� ����������� ������� �� �������:
@ @<����������� ����...@>=
typedef struct _RLD_Entry {
	struct {
	    uint8_t type:7;
	    uint8_t b:1;
	} cmd;
	uint8_t disp;
	uint16_t value[2];
} RLD_Entry;

typedef struct _RLD_Const_Entry {
	RLD_Entry ent;
	uint16_t constant;
} RLD_Const_Entry;

@ ���� |cmd.type| ���������  
@d RLD_CMD_INTERNAL_RELOCATION			01
@d RLD_CMD_GLOBAL_RELOCATION			02
@d RLD_CMD_INTERNAL_DISPLACED_RELOCATION	03
@d RLD_CMD_GLOBAL_DISPLACED_RELOCATION		04
@d RLD_CMD_GLOBAL_ADDITIVE_RELOCATION		05
@d RLD_CMD_GLOBAL_ADDITIVE_DISPLACED_RELOCATION 06
@d RLD_CMD_LOCATION_COUNTER_DEFINITION		07
@d RLD_CMD_LOCATION_COUNTER_MODIFICATION	010 
@d RLD_CMD_PROGRAM_LIMITS			011
@d RLD_CMD_PSECT_RELOCATION			012
@d RLD_CMD_PSECT_DISPLACED_RELOCATION		014
@d RLD_CMD_PSECT_ADDITIVE_RELOCATION		015
@d RLD_CMD_PSECT_ADDITIVE_DISPLACED_RELOCATION  016
@d RLD_CMD_COMPLEX_RELOCATION			017
@c
static void 
handleRelocationDirectory(uint8_t *block, int len) {
	RLD_Entry *entry;
	RLD_Const_Entry *const_entry;
	char gname[7];
	uint16_t *value;
	int RLD_i;

	for (RLD_i = 2; RLD_i < len; ) {
		entry = (RLD_Entry*)(block + RLD_i);
		PRINTVERB(2, "    cmd: %o --- ", entry->cmd.type);
		switch (entry->cmd.type) {
			case RLD_CMD_INTERNAL_RELOCATION:
				PRINTVERB(2, "Internal Relocation.\n");
				@<������ ������ �� ���������� �����@>@;
				break;
			case RLD_CMD_GLOBAL_RELOCATION:
				PRINTVERB(2, "Global Relocation.\n");
				@<������ ������ �� ���������� ������@>@;
				break;
			case RLD_CMD_INTERNAL_DISPLACED_RELOCATION:
				PRINTVERB(2, "Internal Displaced Relocation.\n");
				@<��������� ������ �� ���������� �����@>@;
				break;
			case RLD_CMD_GLOBAL_DISPLACED_RELOCATION:
				PRINTVERB(2, "Global Displaced Relocation.\n");
				@<��������� ������ �� ���������� ������@>@;
				break;
			case RLD_CMD_GLOBAL_ADDITIVE_RELOCATION:
				PRINTVERB(2, "Global Additive Relocation.\n");
				@<������ ������ �� ��������� ���������� ������@>@;
				break;
			case RLD_CMD_GLOBAL_ADDITIVE_DISPLACED_RELOCATION:
				PRINTVERB(2, "Global Additive Displaced Relocation.\n");
				@<��������� ������ �� ��������� ����������
				  ������@>@;
				break;
			case RLD_CMD_LOCATION_COUNTER_DEFINITION:
				PRINTVERB(2, "Location Counter Definition.\n");
				@<��������� ������� ������ � �������@>@;
				break;
			case RLD_CMD_LOCATION_COUNTER_MODIFICATION:
				PRINTVERB(2, "Location Counter Modification.\n");
				@<��������� ������� �������@>@;
				break;
			case RLD_CMD_PROGRAM_LIMITS:
				PRINTVERB(2, "Program Limits.\n");
				@<��������� ��������@>@;
				break;
			case RLD_CMD_PSECT_RELOCATION:
				PRINTVERB(2, "PSect Relocation.\n");
				@<������ ������ �� ������@>@;
				break;
			case RLD_CMD_PSECT_DISPLACED_RELOCATION:
				PRINTVERB(2, "PSect Displaced Relocation.\n");
				@<��������� ������ �� ������@>@;
				break;
			case RLD_CMD_PSECT_ADDITIVE_RELOCATION:
				PRINTVERB(2, "PSect Additive Relocation.\n");
				@<������ ��������� ������ �� ������@>@;
				break;
			case RLD_CMD_PSECT_ADDITIVE_DISPLACED_RELOCATION:
				PRINTVERB(2, "PSect Additive Displaced Relocation.\n");
				@<��������� ��������� ������ �� ������@>@;
				break;
			case RLD_CMD_COMPLEX_RELOCATION:
				PRINTVERB(2, "Complex Relocation.\n");
				@<������� ������@>@;
				break;
			default :
				PRINTERR("Bad RLD entry type: %o : %s\n", 
					entry->cmd.type, config.objnames[cur_input]);
				return;	
		}
	}
}

@ ?
@<������ ������ �� ���������� �����@>=
	PRINTVERB(2, "      Disp: %o, +Const: %o.\n", entry->disp, entry->value[0]);
	RLD_i += 4;
@ ?
@<��������� ������ �� ���������� �����@>=
	PRINTVERB(2, "      Disp: %o, +Const: %o.\n", entry->disp, entry->value[0]);
	RLD_i += 4;
@ ?
@<������ ������ �� ���������� ������@>=
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Disp: %o, Name: %s.\n", entry->disp, gname);
	addSimpleRef(entry);
	RLD_i += 6;
@ ?
@<��������� ������ �� ���������� ������@>=
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Disp: %o, Name: %s.\n", entry->disp, gname);
	RLD_i += 6;

@ ?
@<������ ������ �� ��������� ���������� ������@>=
	const_entry = (RLD_Const_Entry *) entry;
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Disp: %o, Name: %s, +Const: %o.\n", entry->disp, gname,
		const_entry->constant);
	RLD_i += 8;

@ ?
@<��������� ������ �� ��������� ���������� ������@>=
	const_entry = (RLD_Const_Entry *) entry;
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Disp: %o, Name: %s, +Const: %o.\n", entry->disp, gname,
		const_entry->constant);
	RLD_i += 8;

@ ?
@<��������� ������� �������@>=
	PRINTVERB(2, "      +Const: %o.\n", entry->value[0]);
	RLD_i += 4;

@ ?
@<��������� ��������@>=
	PRINTVERB(2, "      Disp: %o.\n", entry->disp);
	RLD_i += 2;

@ ?
@<������ ������ �� ������@>=
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Disp: %o, Name: %s.\n", entry->disp, gname);
	RLD_i += 6;

@ ?
@<��������� ������ �� ������@>=
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Disp: %o, Name: %s.\n", entry->disp, gname);
	RLD_i += 6;

@ ?
@<������ ��������� ������ �� ������@>=
	const_entry = (RLD_Const_Entry *) entry;
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Name: %s, +Const: %o.\n", gname,
		const_entry->constant);
	RLD_i += 8;

@ ?
@<��������� ��������� ������ �� ������@>=
	const_entry = (RLD_Const_Entry *) entry;
	fromRadix50(entry->value[0], gname);
	fromRadix50(entry->value[1], gname + 3);
	PRINTVERB(2, "      Name: %s, +Const: %o.\n", gname,
		const_entry->constant);
	RLD_i += 8;

@ ?
@d CREL_OP_NONE			000
@d CREL_OP_ADDITION		001
@d CREL_OP_SUBSTRACTION		002
@d CREL_OP_MULTIPLICATION	003
@d CREL_OP_DIVISION		004
@d CREL_OP_AND			005
@d CREL_OP_OR			006
@d CREL_OP_XOR			007
@d CREL_OP_NEG			010
@d CREL_OP_COM			011
@d CREL_OP_STORE_RESULT		012
@d CREL_OP_STORE_RESULT_DISP	013
@d CREL_OP_FETCH_GLOBAL		016
@d CREL_OP_FETCH_RELOCABLE	017
@d CREL_OP_FETCH_CONSTANT	020
@<������� ������@>=
	PRINTVERB(2, "      Disp: %o.\n        ", entry->disp);
	for (RLD_i += 2; block[RLD_i] != CREL_OP_STORE_RESULT; ++RLD_i) {
		switch (block[RLD_i]) {
			case CREL_OP_NONE:
				break;
			case CREL_OP_ADDITION:
				PRINTVERB(2, "+ ");
				break;
			case CREL_OP_SUBSTRACTION:
				PRINTVERB(2, "- ");
				break;
			case CREL_OP_MULTIPLICATION:
				PRINTVERB(2, "* ");
				break;
			case CREL_OP_DIVISION:
				PRINTVERB(2, "/ ");
				break;
			case CREL_OP_AND:
				PRINTVERB(2, "and ");
				break;
			case CREL_OP_OR:
				PRINTVERB(2, "or ");
				break;
			case CREL_OP_XOR:
				PRINTVERB(2, "xor ");
				break;
			case CREL_OP_NEG:
				PRINTVERB(2, "neg ");
				break;
			case CREL_OP_COM:
				PRINTVERB(2, "com ");
				break;
			case CREL_OP_STORE_RESULT_DISP:
				break;
			case CREL_OP_FETCH_GLOBAL:
				++RLD_i;
				value = (uint16_t *)(block + RLD_i);
				fromRadix50(value[0], gname);
				fromRadix50(value[1], gname + 3);
				RLD_i += 3;
				PRINTVERB(2, "%s ", gname);
				break;
			case CREL_OP_FETCH_RELOCABLE:
				value = (uint16_t *)(block + RLD_i + 2);
				PRINTVERB(2, "sect:%o/%o ", block[RLD_i + 1],
					value[0]);
				RLD_i += 3;	
				break;
			case CREL_OP_FETCH_CONSTANT:
				++RLD_i;
				value = (uint16_t *)(block + RLD_i);
				++RLD_i;
				PRINTVERB(2, "%o ", *value);
				break;
			default :
				PRINTERR("Bad complex relocation opcode.\n");
				return;
		}
	}
	++RLD_i;
	PRINTVERB(2, "\n");

@ @<���������� ���������� ������� � ������@>=
handleGlobalSymbol(entry);

@ @<���������� ����������� ������@>=
handleProgramSection(entry);

@ @<���������� ������ TXT@>=
handleTextSection(block_body, block_len);

@ @<���������� ������ ���������...@>=
handleRelocationDirectory(block_body, block_len);

@ @<����������...@>=
static void handleGlobalSymbol(GSD_Entry *);
static void handleProgramSection(GSD_Entry *);
static void handleTextSection(uint8_t *, unsigned int);
static void handleRelocationDirectory(uint8_t *, int);

@* ��������������� �������.

@ ������� ���� ���� �� RADIX-50 � ������.
@c
static void fromRadix50(int n, char *name) {
	int i, x;

	for (i = 2; i >= 0; --i) {
		x = n % 050;
		n /= 050;
		if (x <= 032 && x != 0) {
			name[i] = x + 'A' - 1; 
			continue;
		}
		if (x >= 036) {
			name[i] = x + '0' - 036;
			continue;
		}
		switch (x) {
			case 033 : name[i] = '$'; break;
			case 034 : name[i] = '.'; break;
			case 035 : name[i] = '%'; break;
			case 000 : name[i] = ' '; break;
		}
	}
	name[3] = '\0';
}

@ @<����������...@>=
static void handleOneFile(FILE *);
static void handleGSD(int);
static void fromRadix50(int, char*);

@* ������ ���������� ��������� ������.

��� ���� ���� ������������ ���������� ������� ��������� ���������� 
{\sl argp}.
@d VERSION "0.6"

@ @<���������@>=
const char *argp_program_version = "linkbk, " VERSION;
const char *argp_program_bug_address = "<yellowrabbit@@bk.ru>";

@ @<��������...@>=
static char argp_program_doc[] = "Link MACRO-11 object files";

@ ������������ ��������� �����:
\smallskip
	\item {} {\tt -o} --- ��� ��������� �����.
\smallskip
@<��������...@>=
static struct argp_option options[] = {@|
	{ "output", 'o', "FILENAME", 0, "Output filename"},@|
	{ "verbose", 'v', NULL, 0, "Verbose output"},@!
	{ 0 }@/
};
static error_t parse_opt(int, char*, struct argp_state*);@!
static struct argp argp = {options, parse_opt, NULL, argp_program_doc};

@ ��� ��������� ������������ ��� ��������� ����������� ������� ���������� ��������� ������.
@<�����������...@>=
typedef struct _Arguments {
	int  verbosity;
	char output_filename[FILENAME_MAX]; /* ��� ����� � ������ */
	char **objnames;		    /* ����� ��������� ������
					 objnames[?] == NULL --> ����� ����*/
} Arguments;

@ @<����������...@>=
static Arguments config = { 0, {0}, NULL, };


@ ������� ������� �������� ������� �������� ���������� ��������� |Arguments| �� ���������
���������� ��������� ������.
@c
static error_t 
parse_opt(int key, char *arg, struct argp_state *state) {
 Arguments *arguments;
	arguments = (Arguments*)state->input;
 switch (key) {
	case 'v':
		++arguments->verbosity;
		break;
	case 'o':
		if (strlen(arg) == 0)
			return(ARGP_ERR_UNKNOWN);
		strncpy(arguments->output_filename, arg, FILENAME_MAX - 1);
		break;
	case ARGP_KEY_ARG:
		/* ����� ��������� ������ */
		arguments->objnames = &state->argv[state->next - 1];
		/* ������������� ������ ���������� */
		state->next = state->argc;
		break;
	default:
		break;
		return(ARGP_ERR_UNKNOWN);
	}
	return(0);
}
@ 
@d ERR_SYNTAX		1
@d ERR_CANTOPEN		2
@d ERR_CANTCREATE	3
@<��������� ���...@>=
	argp_parse(&argp, argc, argv, 0, 0, &config);@|
	/* �������� ���������� */
	if (strlen(config.output_filename) == 0) {
		PRINTERR("No output filename specified\n");
		return(ERR_SYNTAX);
	}
	if (config.objnames == NULL) {
		PRINTERR("No input filenames specified\n");
		return(ERR_SYNTAX);
	}

@ @<��������� ...@>=
#include <string.h>
#include <stdlib.h>

#ifdef __linux__
#include <stdint.h>
#endif

#include <argp.h>

@
@<����������...@>=
#define PRINTVERB(level, fmt, a...) (((config.verbosity) >= level) ? printf(\
  (fmt), ## a) : 0)
#define PRINTERR(fmt, a...) fprintf(stderr, (fmt), ## a) 

