% vim: set ai textwidth=80:
\input cwebmac-ru

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

	@<��������� ��������� ������@>@;
	@<������ ���� ����������@>@;

	/* ���������� ������������ ��� �������� ��������� ����� */
	cur_input = 0;
	while ((objname = config.objnames[cur_input]) != NULL) {
		@<������� ��������� ����@>@;
		handle_one_file(fresult, fobj);
		fclose(fobj);
		++cur_input;
	}
	fclose(fresult);
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

@ @<������ ���� ����������@>=
	fresult = fopen(config.output_filename, "w");
	if (fresult == NULL) {
		PRINTERR("Can't create %s\n", config.output_filename);
		return(ERR_CANTCREATE);
	}

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
	uint8_t len[2]; /* length of block */
} BinaryBlock;


@ ���������� ���� ��������� ����.
@c
static void
handle_one_file(FILE *fresult, FILE *fobj) {
	BinaryBlock obj_header;
	int first_byte;
	unsigned int block_len;
	
	current_block = 0;
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
		block_len = obj_header.len[0] + obj_header.len[1] * 256 - 4;
		PRINTVERB(2, "Binary block found. Length:%d\n", block_len);

		/* ������ ���� ����� � ���������� ������ */
		if (fread(block_body[current_block], block_len + 1, 1, fobj) != 1) {
			PRINTERR("IO error: %s\n", config.objnames[cur_input]);
			break;
		}
		@<���������� ����@>@;
	}
end:;
}

@ ������ ��� ���� �����. ��� ����� ������� ����� ������������� ����� �������
���������� ������������ ����. ����� ���� ��������, ����� ���������� �����
�������� ����� �������� ����������� ������.
@<����������...@>=
static uint8_t block_body[2][65536 + 1];
static int current_block; /* ������ ������� ����� ������� */

@ ��������� ������ ��������� �����. �� ������� ����� ����� �������� ��� ���.
@<���������� ����@>=
	PRINTVERB(2, "  Block type: %o, ", block_body[current_block][0]);
	switch (block_body[current_block][0]) {
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
		  block_body[current_block][0], config.objnames[cur_input]);
	}

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
	handle_GSD(block_len);
@ @<����������� ����...@>=
typedef struct _GSD_Entry {
	uint16_t name[2];
	uint8_t flags;
	uint8_t type;
	uint16_t value;
} GSD_Entry;

@ @c
void handle_GSD(int len) {
	int i;
	GSD_Entry *entry;
	char name[7];

	for (i = 2; i< len; i += 8) {
		entry = (GSD_Entry*)(block_body[current_block] + i);
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
				PRINTVERB(2, "CSectName, flags:%o, length:%d.\n",
						entry->flags, entry->value);
				break;
			case GSD_INTERNAL_SYMBOL_NAME:
				/* ��� ����������� ������� */
				PRINTVERB(2, "InternalSymbolName\n");
				break;
			case GSD_TRANFER_ADDRESS:
				/* ����� ������� ��������� */
				PRINTVERB(2, "TransferAddress, offset:%o.\n", entry->value);
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
@d GLOBAL_WEAK_MASK	  001 // 00000001b
@d GLOBAL_DEFINITION_MASK 010 // 00001000b
@d GLOBAL_RELOCATION_MASK 040 // 00100000b
@c
static void
handleGlobalSymbol(GSD_Entry *entry) {
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

@ ������ ����������� ������.
@d PSECT_SAVE_MASK	  0001	// 00000001b
@d PSECT_ALLOCATION_MASK  0004  // 00000100b
@d PSECT_ACCESS_MASK	  0020  // 00010000b
@d PSECT_RELOCATION_MASK  0040  // 00100000b
@d PSECT_SCOPE_MASK	  0100  // 01000000b
@d PSECT_TYPE_MASK	  0200  // 10000000b
@c
static void
handleProgramSection(GSD_Entry *entry) {
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
}

@ ���������� ������ Text.
@c
static void 
handleTextSection(uint8_t *block) {
	uint16_t addr;

	addr = block[2] + block[3] * 256;
	PRINTVERB(2, "  Load address: %o.\n", addr);
}


@ @<���������� ���������� ������� � ������@>=
handleGlobalSymbol(entry);

@ @<���������� ����������� ������@>=
handleProgramSection(entry);

@ @<���������� ������ TXT@>=
handleTextSection(block_body[current_block]);

@ @<����������...@>=
static void handleGlobalSymbol(GSD_Entry *);
static void handleProgramSection(GSD_Entry *);
static void handleTextSection(uint8_t *);

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
static void handle_one_file(FILE *, FILE *);
static void handle_GSD(int);
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

