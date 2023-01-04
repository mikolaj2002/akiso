#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <stdbool.h>

#define MAX_ARGS 50
#define PIPE_SIZE 2

int main()
{
    int out = open("out.txt", O_RDONLY);
    printf("%d\n", out);

    dup2(out, 0);

    int a;
    scanf("%d", &a);
    printf("%d\n", a);

    close(out);

    return 0;
}
