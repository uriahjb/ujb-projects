/* Tester for tasks template */

#include <stdio.h>

#define LENGTH 3
#define HEIGHT 2
#define NUM_PROPERTIES 2

void print(void * array);


int main(void){


  /* This demonstrates a list of values being 
     stored in a void pointer array then being
     derefrenced and printed.
     
     This should be useful for storing object
     properties, one just needs to store the
     following property properties like:
     {cast, length, property} 
       ... maybe even property name

     The cool thing about this set-up is that
     any modification to a property by its name
     is immediately updated in the 'searchable'
     array.

  */
  /* This method is alright for C, but 
     C++ kinda hates it. Need to make
     a C++ style heterogeneous containter
  */
  unsigned int length = 2; 
  int width = 4;
  char meh = 'm';
  int lss = 5;
  int UINT = 1;
  int INT = 2;
 
  void * array[2][2] = {               
    {&UINT, &length},		       
    {&INT, &width}		       
  };

  print(&array);
  // This all works ... good!!!
  
}

void print(void * array){
  for (int n = 0; n < 2; n++){
    int s = (*(int*)array[n][0]);
    switch (s){
      // INT case
      case 1:
	printf("%d \n", *(int*)array[n][1]);
        break;
      case 2:
	printf("%d \n", *(unsigned int*)array[n][1]);
	break;
    }	
  }
  return;
}
