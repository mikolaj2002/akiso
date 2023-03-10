#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdbool.h>

#define BUFF_SIZE 256
#define MAX_ARGS 50

void handle_exit(int arg_count, char *arguments[]);
void handle_cd(int arg_count, char *arguments[]);
void exec_process(int arg_count, char *arguments[]);

int main(int argc, char *argv[])
{
    char input[BUFF_SIZE];
    char curr_path[BUFF_SIZE];

    while (1)
    {
        getcwd(curr_path, sizeof(curr_path));
        printf("\033[32mlsh\033[37m:\033[34m%s\033[37m$ ", curr_path);

        if (fgets(input, sizeof(input), stdin) == NULL)
        {
            printf("\n");
            break;
        }

        char *arguments[MAX_ARGS];
        arguments[0] = strtok(input, " ");

        int i;
        if (arguments[0] != NULL)
        {
            for (i = 1; i < MAX_ARGS; i++)
            {
                arguments[i] = strtok(NULL, " ");
                if (arguments[i] == NULL)
                    break;
            }
        }
        else
            continue;
        int arg_count = i;
        arguments[arg_count - 1][strlen(arguments[arg_count - 1]) - 1] = '\0';

        if (strcmp(arguments[0], "exit") == 0)
            handle_exit(arg_count, arguments);
        else if (strcmp(arguments[0], "cd") == 0)
            handle_cd(arg_count, arguments);
        else
            exec_process(arg_count, arguments);
    }
    
    return 0;
}

void handle_exit(int arg_count, char *arguments[])
{
    if (arg_count > 2)
        perror("lsh: exit: incorrect number of arguments");
    else if (arg_count == 2)
    {
        int exit_code = atoi(arguments[1]);
        exit(exit_code);
    }
    else
        exit(0);
}

void handle_cd(int arg_count, char *arguments[])
{
    if (arg_count != 2)
        perror("lsh: cd: incorrect number of arguments");
    else if (chdir(arguments[1]) != 0)
        perror("lsh: cd: failed");
}

void exec_process(int arg_count, char *arguments[])
{
    bool is_bg = false;
    if (strcmp(arguments[arg_count - 1], "&") == 0)
    {
        is_bg = true;
        arguments[arg_count - 1] = NULL;
    }

    pid_t pid = fork();
    if (pid == 0)
    {
        execvp(arguments[0], arguments);
        perror("lsh: fail by running command");
        exit(0);
    }
    else if (pid > 0)
    {
        int status;
        if (is_bg)
            waitpid(pid, &status, WNOHANG);
        else
            wait(&status);
    }   
}
