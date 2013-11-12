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
	int cur_input;
	const char *objname;

	@<��������� ��������� ������@>@;
	@<������ ���� ����������@>@;

	/* ���������� ������������ ��� �������� ��������� ����� */
	while ((objname = config.objnames[cur_input++]) != NULL) {
		@<������� ��������� ����@>@;
		handle_one_file(fresult, fobj);
		fclose(fobj);
	}
	fclose(fresult);
}

@ @<������ ���������@>=
FILE *fobj, *fresult;

@ @<������� ��������� ����@>=
	fobj = fopen(objname,"r");
	if (fobj== NULL) {
		printerr("Can't open ");
		printerr(objname);
		return(ERR_CANTOPEN);
	}

@ @<������ ���� ����������@>=
	fresult = fopen(config.output_filename, "w");
	if (fresult == NULL) {
		printerr("Can't create ");
		printerr(config.output_filename);
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
	
	while (!feof(fobj)) {
		/* ���� ������ ����� */
		do {
			first_byte = fgetc(fobj);
			if (first_byte == EOF) goto end;
		} while (first_byte != 1);

		/* ������ ��������� */
		ungetc(first_byte, fobj);
		if (fread(&obj_header, sizeof(BinaryBlock), 1, fobj) != 1) {
			printerr("IO error\n");
			break;
		}
		if (obj_header.zero != 0) continue;
		block_len = obj_header.len[0] + obj_header.len[1]*256;
		printf("Block found.\n Length:%d\n", block_len);
	}
end:;
}

@ @<����������...@>=
static void handle_one_file(FILE *, FILE *);

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
	{ 0 }@/
};
static error_t parse_opt(int, char*, struct argp_state*);@!
static struct argp argp = {options, parse_opt, NULL, argp_program_doc};

@ ��� ��������� ������������ ��� ��������� ����������� ������� ���������� ��������� ������.
@<�����������...@>=
typedef struct _Arguments {
	char output_filename[FILENAME_MAX]; /* ��� ����� � ������ */
	char **objnames;		    /* ����� ��������� ������
					 objnames[?] == NULL --> ����� ����*/
} Arguments;

@ @<����������...@>=
static Arguments config = { {0}, NULL, };


@ ������� ������� �������� ������� �������� ���������� ��������� |Arguments| �� ���������
���������� ��������� ������.
@c
static error_t 
parse_opt(int key, char *arg, struct argp_state *state) {
 Arguments *arguments;
	arguments = (Arguments*)state->input;
 switch (key) {
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
		printerr("No output filename specified\n");
		return(ERR_SYNTAX);
	}
	if (config.objnames == NULL) {
		printerr("No input filenames specified\n");
		return(ERR_SYNTAX);
	}

@ @<��������� ...@>=
#include <string.h>
#include <stdlib.h>

#include <argp.h>

@ @<����������...@>=
static void printerr(const char*);

@ @c
static void
printerr(const char *str) {
	fprintf(stderr, str);
}


