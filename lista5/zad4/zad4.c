#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdbool.h>
#include <fcntl.h>

#define BUFF_SIZE 256
#define MAX_ARGS 50
#define MAX_PIPE_SIZE 25

struct pipe_arguments
{
    int arg_count;
    char *values[MAX_ARGS];
};

void handle_sigint() {}
void handle_exit(int arg_count, char *arguments[]);
void handle_cd(int arg_count, char *arguments[]);
pid_t exec(char *arguments[], int in, int out, char *file_in, char *file_out, char *file_err);
void exec_process(int arg_count, char *arguments[]);
void exec_pipe(int pipe_size, struct pipe_arguments args[]);

int main(int argc, char *argv[])
{
    signal(SIGINT, handle_sigint);

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

        int pipe_size = 0;
        struct pipe_arguments args[MAX_PIPE_SIZE];
        args[pipe_size].values[0] = strtok(input, " ");

        int i, idx = 1;
        if (args[pipe_size].values[0] != NULL)
        {
            for (i = 1; i < MAX_ARGS; i++)
            {
                args[pipe_size].values[idx] = strtok(NULL, " ");
                if (args[pipe_size].values[idx] == NULL)
                    break;
                if (strcmp(args[pipe_size].values[idx], "|") == 0)
                {
                    args[pipe_size].values[idx] = NULL;
                    args[pipe_size].arg_count = idx + 1;
                    pipe_size++;
                    idx = -1;
                }
                idx++;
            }
        }
        else
            continue;
        args[pipe_size].arg_count = idx;
        args[pipe_size].values[args[pipe_size].arg_count - 1][strlen(args[pipe_size].values[args[pipe_size].arg_count - 1]) - 1] = '\0';
        pipe_size++;

        if (pipe_size == 1 && args[0].values[0][0] == '\0')
            continue;

        if (pipe_size == 1 && strcmp(args[0].values[0], "exit") == 0)
            handle_exit(args[0].arg_count, args[0].values);
        else if (pipe_size == 1 && strcmp(args[0].values[0], "cd") == 0)
            handle_cd(args[0].arg_count, args[0].values);
        else if (pipe_size == 1)
            exec_process(args[0].arg_count, args[0].values);
        else
            exec_pipe(pipe_size, args);
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
        perror("lsh: cd");
}

pid_t exec(char *arguments[], int in, int out, char *file_in, char *file_out, char *file_err)
{
    pid_t pid = fork();
    if (pid == 0)
    {
        if (in != -1)
        {
            dup2(in, 0);
            close(in);
        }
        if (out != -1)
        {
            dup2(out, 1);
            close(out);
        }
        if (file_in != NULL)
            freopen(file_in, "r", stdin);
        if (file_out != NULL)
            freopen(file_out, "w", stdout);
        if (file_err != NULL)
            freopen(file_err, "w", stderr);

        execvp(arguments[0], arguments);
        perror("lsh: fail by running command");
        exit(1);
    }
    
    if (in != -1)
        close(in);
    if (out != -1)
        close(out);

    return pid;
}

void exec_process(int arg_count, char *arguments[])
{
    bool is_bg = false;
    if (strcmp(arguments[arg_count - 1], "&") == 0)
    {
        is_bg = true;
        arguments[arg_count - 1] = NULL;
        arg_count--;
    }

    char *file_in = NULL, *file_out = NULL, *file_err = NULL;
    for (int i = arg_count - 1; i >= arg_count - 3 && i >= 0; i--)
    {
        switch (arguments[i][0])
        {
        case '<':
            file_in = arguments[i] + 1;
            arguments[i] = NULL;
            break;
        case '>':
            file_out = arguments[i] + 1;
            arguments[i] = NULL;
            break;
        case '2':
            if (arguments[i][1] == '>')
            {
                file_err = arguments[i] + 2;
                arguments[i] = NULL;
            }
            break;
        }
    }

    pid_t pid = exec(arguments, -1, -1, file_in, file_out, file_err);

    int status;
    if (is_bg)
        waitpid(pid, &status, WNOHANG);
    else
        wait(&status);
}

void exec_pipe(int pipe_size, struct pipe_arguments args[])
{
    bool is_bg = false;
    if (strcmp(args[pipe_size - 1].values[args[pipe_size - 1].arg_count - 1], "&") == 0)
    {
        is_bg = true;
        args[pipe_size - 1].values[args[pipe_size - 1].arg_count - 1] = NULL;
        args[pipe_size - 1].arg_count--;
    }

    //TODO: dodać obsługę przekierować dla pipe'ów

    pid_t pids[pipe_size];

    int pipefd[2];
    for (int i = 0; i < pipe_size; i++)
    {
        int in = -1;
        if (i != 0)
            in = pipefd[0];
        
        int out = -1;
        if (i < pipe_size - 1)
        {
            pipe(pipefd);
            out = pipefd[1];
        }

        pids[i] = exec(args[i].values, in, out, NULL, NULL, NULL);

        if (in != -1)
            close(in);
        if (out != -1)
            close(out);
    }

    int status;
    for (int i = 0; i < pipe_size; i++)
    {
        if (is_bg)
            waitpid(pids[i], &status, WNOHANG);
        else
            wait(&status);
    }
}
