#include<stdio.h>
#include<stdlib.h>

int main(void) {
    int i;
    int size = 65536;
    for (i=0; i<9999999999; i++) {
        char *q = malloc(size);
        printf ("Malloced: %ld\n", size*i);
    }
    sleep(9999999);
}
