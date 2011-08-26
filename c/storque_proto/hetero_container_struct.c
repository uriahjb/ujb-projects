/* ------------------------------------------------------------------------ */
/* Packaging a heterogenous array in a struct interaction layer */
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
/* A single Property struct containing pointers to type, length, and data */
/* ------------------------------------------------------------------------ */
typedef struct property {
  int type;
  int length;
  void *data;
} property_t;


/* ------------------------------------------------------------------------ */
/* Property List struct:
     - Contains data, and pointers to methods
     - Must be constructed using PropertyListInit
*/
/* ------------------------------------------------------------------------ */
typedef struct property_list {
  int index;
  property_t *properties[5];
} property_list_t;


/* ------------------------------------------------------------------------ */
/* Function decls */
/* ------------------------------------------------------------------------ */
property_list_t  property_list_const(void);
//void add_property(property_list_t *property_list, int type, int length, void *data);
//void print_property(property_list_t *property_list, int index);

/* Simulated Constructor */
property_list_t property_list_const(void){
  property_list_t property_list;
  property_list.index = 0;
  return property_list;
};

/* Functions */

/* Add a property to the property_list */
void add_property(property_list_t *property_list, int index, int type, int length, void *data){
  property_t add = {type, length, &data};
  property_t *add_p = &add;
  *((*property_list).properties + index) = add_p;
  //*((*property_list).properties + (*property_list).index) = add_p;
  ++(*property_list).index;
  printf("p-list index %i \n", (int)(*property_list).index);
  printf("data if int: %i \n", *(int*)data);
};

/* Print a given property from the property_list */
void print_property(property_list_t *property_list, int index){
  int type;
  int length;
  int i;
  
  type = (**((*property_list).properties + index)).type;
  length = (**((*property_list).properties + index)).length;

  printf("type: %i \n", type);
  printf("length: %i \n", length);

  switch(type){    

  case 1: {

    int data = *(int*)(**((*property_list).properties + index)).data;
    printf("data[%i]: %c; ", i,  data);
    /* This is kinda tricky, basically dereference and index(i) 
	 data then typecast, but only after derefrencing and 
	 indexing(index) the property list array */
  /*for (i = 0; i < length; i++){
      int data = *(((int*)(**((*property_list).properties + index)).data) + i);
      printf("data[%i]: %i; ", i,  data);
    }*/
    printf("\n");
    break;
  }
  case 2: {
    /* char_t */
    for (i = 0; i < length; i++){
      char data = *(((char*)(**((*property_list).properties + index)).data) + i);
      printf("data[%i]: %c; ", i,  data);
    }
    printf("\n");
    break;
  }
  }
  return;
}

  
/* ------------------------------------------------------------------------ */
/* Test */
/* ------------------------------------------------------------------------ */
int main(void){
  property_list_t p = property_list_const();
  int a = 9;
  int b = 8;
  add_property(&p, 0, int_t, 2, &a);
  add_property(&p, 1, int_t, 1, &b);
  print_property(&p, 0);
  print_property(&p, 1);
  
  return 0;
};
