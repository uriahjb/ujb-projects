/* ------------------------------------------------------------------------ */
/*
  Implement a C-style heterogenous container and wrap it in a C++ class
*/
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/* Defines */
/* ------------------------------------------------------------------------ */

#define int_t 1
#define char_t 2


/* ------------------------------------------------------------------------ */
/* Includes */
/* ------------------------------------------------------------------------ */
#include <stdlib.h>
#include <stdio.h>


/* ------------------------------------------------------------------------ */
/* Struct containing pointers to type, length, and data */
/* ------------------------------------------------------------------------ */
typedef struct data {
  int type;
  int length;
  void *data;
} data_t;

data_t *property_list[5];

/* ------------------------------------------------------------------------ */
/* Function Declarations */
/* ------------------------------------------------------------------------ */
void print_property(data_t **property_list, int index);

/* ------------------------------------------------------------------------ */
/* Some random stuff for testing */
/* ------------------------------------------------------------------------ */

int z = 3;
int y[2] = {0, 2};
int x[2] = {4, 3};

data_t first = {int_t, 1, &z};
data_t *first_p = &first;

data_t second = {int_t, 2, &y};
data_t *second_p = &second;

data_t third = {int_t, 2, &x};
data_t *third_p = &third;

int main(void){

  property_list[0] = first_p;
  property_list[1] = second_p;
  property_list[2] = third_p;
  
  /*
  int s_first = sizeof(*first_p);
  int s_second = sizeof(*second_p);
  printf("size first: %i \n", s_first);
  printf("size second: %i \n", s_second);
  */

  /*  
  a = (*property_list)[1].type;
  b = (*property_list)[1].length;
  c = *(int*)(*property_list)[1].data;
  a = 1;
  printf("type %i \n", a);
  printf("length %i \n", b);
  printf("data %i \n", c);
  */
  
  print_property(property_list, 0);
  print_property(property_list, 1);
  print_property(property_list, 2);
  
  return 0;
};

void print_property(data_t **property_list, int index){
  int type;
  int length;
  int i;
  
  type = (**(property_list + index)).type;
  length = (**(property_list + index)).length;

  printf("type: %i \n", type);
  printf("length: %i \n", length);

  switch(type){    

  case 1:
    /* int_t */
    for (i = 0; i < length; i++){
      /* This is kinda tricky, basically dereference and index(i) 
	 data then typecast, but only after derefrencing and 
	 indexing(index) the property list array */
	 
      int data = *(((int*)(**(property_list + index)).data) + i);
      printf("data[%i]: %i; ", i,  data);
    }
    printf("\n");
    break;

  case 2:
    /* char_t */
    for (i = 0; i < length; i++){
      char data = *(((char*)(**(property_list + index)).data) + i);
      printf("data[%i]: %c; ", i,  data);
    }
    printf("\n");
    break;
  }
  return;
}

      
    
  
