#include <stdio.h>
#include <signal.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	printf("Sprawdzanie obsługi sygnałów:\n");

	for (int i = 1; i <= 64; i++)
	{
		if (i == 32 || i == 33)
			continue;

		printf("Sygnał %d: ", i);
		if (signal(i, SIG_IGN) == SIG_ERR)
			printf("NIE\n");
		else
			printf("TAK\n");
	}
	

	return 0;
}

