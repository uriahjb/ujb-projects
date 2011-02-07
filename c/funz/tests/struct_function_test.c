/* ------------------------------------------------------------------------ */
/* Function pointer inside struct test code */
/* ------------------------------------------------------------------------ */

#include<stdlib.h>
#include<stdio.h>

/* Define struct */
typedef struct hasfuncts {
  int val;
  void (*funct)(int i);
}hasfuncts_t;

/* Define function types */
void funct_def(int i){
  printf("hey its a value: %i \n", i);
};

/* Define a basic 'constructor' for struct */
hasfuncts_t funct_const(void){
  hasfuncts_t hasf;
  hasf.funct = funct_def;
  return hasf;
};

int main(void){
  hasfuncts_t A = funct_const();
  A.val = 0;
  A.funct(2);
};
