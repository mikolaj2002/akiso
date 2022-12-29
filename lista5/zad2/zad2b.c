#include <stdio.h>
#include <signal.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	printf("Wysyłanie SIGKILL do procesu init:\n");

	if (kill(1, SIGKILL) == -1)
		printf("NIE da się\n");
	else
		printf("Jest to możliwe\n");	

	return 0;
}

