#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int pid = atoi(argv[1]);

	for (int i = 1; i <= 1000; i++)
	{
		kill(pid, SIGUSR1);
	}

	return 0;
}

