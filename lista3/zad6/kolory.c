#include <stdio.h>

int main(int argc, char **argv)
{
	for (int i = 0; i < 256; i++)
	{
		printf("\033[38;5;%dmHello, world! ", i);

		if (i % 8 == 7)
			printf("\n");
	}

	printf("\033[0m");

	return 0;
}

