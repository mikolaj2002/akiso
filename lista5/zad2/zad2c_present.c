#include <stdio.h>
#include <signal.h>
#include <unistd.h>

int count = 0;

void sig_handler(int sig_num)
{
	count++;

	printf("receive: %d. Odebrano sygnał %d\n", count, sig_num);
}

int main(int argc, char *argv[])
{
	signal(SIGUSR1, sig_handler);

	sleep(3600);

	return 0;
}

