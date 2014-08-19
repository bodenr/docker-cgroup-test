#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <time.h>


int main() {

	pid_t childpid;
	time_t start;
	time_t now;
	int i = 0;

	start = time(NULL);
	childpid = fork();
	if (childpid >= 0) { /* fork ok */

		if (childpid == 0) { /* in child */
			for (;;) {
				now = time(NULL);
				if (now - start > 30) {
					break;
				}
				i++;
			}
			exit(0);
		} else {
			printf("%d\n", childpid);
		}
	} else {
		perror("fork failed");
		exit(1);
	}
}
