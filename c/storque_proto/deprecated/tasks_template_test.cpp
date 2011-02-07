/* Tester for tasks template */

#include "task_template.h"
#include <vector>
#include <iostream>

using std::vector;
using namespace std;

#define LENGTH 3
#define HEIGHT 2
#define NUM_PROPERTIES 2

short **property_list;

/*
void print_properties(const void *array);

void print_properties(const void *array){
  for (int n = 0; n < 2; n++){
    int s = (*(int*)array[n][0]);
    switch (s){
      // INT case
      case 1:
        cout << *(int*)array[n][1] << endl;
        break;
      case 2:
        cout << *(unsigned int*)array[n][1] << endl;
	break;
    }	
  }
  return;
}
*/


int main(int argc, char *argv[]){

  property_list =  new short*[HEIGHT];
  for (int i = 0; i < HEIGHT; i++)
    property_list[i] =  new short[LENGTH];

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
     
  for (int n = 0; n < 2; n++){
    int s = (*(int*)array[n][0]);
    switch (s){
      // INT case
      case 1:
        cout << *(int*)array[n][1] << endl;
        break;
      case 2:
        cout << *(unsigned int*)array[n][1] << endl;
	break;
    }	
  }
  /*    
  cout << *(unsigned int*)array[0][0] << endl;
  cout << *(int*)array[0][1] << endl;
  cout << *(char*)array[1][0] << endl;
  cout << *(int*)array[1][1] << endl;
  */
  cout << "Update length" << endl;
  length++;

  // This all works ... good!!!
  
}
