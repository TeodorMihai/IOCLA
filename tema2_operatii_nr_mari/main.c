#include <stdio.h>
#include <string.h>
#include "util.h"

#define SIGN_INDEX 0
#define LENGTH_INDEX 1
#define SIGN_REPRESENTATION_LENGTH sizeof(unsigned int)
#define NUMBER_LENGTH_REPRESENTATION_LENGTH sizeof(unsigned int)
#define MAGIC_PADDING 128

/* TODO implement these functions in assembly, in the calc.asm file 
 * Additional *.asm files can be used, but must be in assembly */
extern void convert_to_native(char *a_str, char *b_str,
			      void *a, void *b)
	asm("convert_to_native");
extern void do_operation(void *a, void *b, char *operation)
	asm("do_operation");
extern void print_number(void *number) asm("print_number");

static void allocate_vectors(char *a_str, char *b_str,
			     unsigned int **a_ptr, unsigned int **b_ptr)
{
	unsigned int *a, *b;
	unsigned int a_len, b_len;
	unsigned int max_str_len;
	unsigned int total_length;

	a_len = strlen(a_str);
	b_len = strlen(b_str);

	/* the sign itself gets counted separately */
	if (a_str[0] == '-')
		a_len--;
	if (b_str[0] == '-')
		b_len--;

	max_str_len = MAX(a_len, b_len);

	/* some numbers might have the MSB represented as a single hex digit
	 * inside the input */
	if (max_str_len % 2)
		max_str_len += 1;

	/* Although 2 hex digits can be represented on one byte,
	 * the result itself might be double the size of biggest operand
	 * Examples: mul operation */
	total_length = max_str_len * 2;
	total_length += SIGN_REPRESENTATION_LENGTH;
	total_length += NUMBER_LENGTH_REPRESENTATION_LENGTH;
	total_length += MAGIC_PADDING;
	a = calloc(1, total_length);
	wtf(a == NULL, "Could not allocate space to represent A");
	b = calloc(1, total_length);
	wtf(b == NULL, "Could not allocate space to represent B");

	/* number[SIGN_INDEX] = zeros if number is positive
	 * number[SIGN_INDEX] = all ones if number is negative */
	if (a_str[0] == '-')
		memset(a + SIGN_INDEX, 0xFF, SIGN_REPRESENTATION_LENGTH);
	if (b_str[0] == '-')
		memset(b + SIGN_INDEX, 0xFF, SIGN_REPRESENTATION_LENGTH);

	/* The string itself is double the size
	 * because there are 2 hex digits per byte */
	/* Added and extra byte
	 * in case the MSB value was represented by a single hex digit */
	a[LENGTH_INDEX] = a_len / 2 + a_len % 2;
	b[LENGTH_INDEX] = b_len / 2 + b_len % 2;

	*a_ptr = a;
	*b_ptr = b;
}

static void print_hex_digit(unsigned char digit)
{
	if (digit >= 0x0 && digit <= 0x9) {
		putchar(digit + '0');
	} else {
		digit -= 10;
		putchar(digit + 'A');
	}
}

static void dump_byte(unsigned char number)
{
	unsigned char digit;

	/* print first digit */
	digit = number;
	/* clear lower half and align to right */
	digit = digit >> 4;
	print_hex_digit(digit);

	/* print second digit */
	digit = number;
	/* clear upper half */
	digit = digit << 4;
	/* align back to right */
	digit = digit >> 4;
	print_hex_digit(digit);
}

static void dump_number(unsigned int *mm)
{
	/* do NOT dump sign or number length */
	unsigned char *mm_ptr = (unsigned char *)(mm + 2);
	unsigned int length = mm[LENGTH_INDEX];
	unsigned int i;

	for (i = 0; i < length; i++)
		dump_byte(mm_ptr[i]);

	putchar('\n');
}

int main(int argc, char *argv[])
{
	char *a_str, *b_str;
	unsigned int *a, *b;
	char *operation;

	wtf(argc < 4, "Not enough paramateres\n"
		      "Usage:\n"
		      "\t%s $A op $B\n"
		      "Example:\n"
		      "\t%s FF34AAAAA3341 + 000012342341FFF",
		      argv[0], argv[0]);

	/* input thingie */
	/* A=argv[1] op=argv[2] B=argv[3] */
	a_str = argv[1];
	b_str = argv[3];
	operation = argv[2];

	allocate_vectors(a_str, b_str, &a, &b);
	/* number[SIGN_INDEX] = zeros if number is positive
	 * number[SIGN_INDEX] = all ones if number is negative
	 * number[LENGTH_INDEX] = actual length of number 
	 * - these things are already set in the A and B pointers 
	 * - length is represented in bytes 
	 * - the actual space allocated for A and B is bigger than the actual
	 * size. Maily because one of them is used to store the result, which
	 * might be double in size for operations such as "mul" */
	convert_to_native(a_str, b_str, a, b);

	dump_number(a);
	dump_number(b);

	/* store result in A */
	/* be sure to store correct length
	 * NO paddings of zeros included in length */
	do_operation(a, b, operation);
	/* memory dump of native representation of number */
	dump_number(a);

	/* print the number in the format the input was received */
	/* NO paddings of zeros */
	print_number(a);

	free(a);
	free(b);

	return 0;
}