/* Wrapping the hetero-container.c in a gcc compliant class */

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
/*typedef struct property {
  int type;
  int length;
  void *data;
  }property_t;*/


/* ------------------------------------------------------------------------ */
/* PropertyList class */
/* ------------------------------------------------------------------------ */

class PropertyList {
public:
  typedef struct property {
    int type;
    int length;
    void *data;
  }property_t;

  int list_index;
  property_t *property_list[];
  
  PropertyList(int num_properties);
  void Add(int type, int length, void *data);
  void Set(int index, void *data);
  void Print(int index); // this could probably convert everything to a string or something ...
  
};

PropertyList::PropertyList(int num_properties){
};

void PropertyList::Add(int type, int length, void *data){
  /* these tings are valid */
  printf("type %i \n", type);
  printf("length %i \n", length);
  for (int i = 0; i < length; ++i){
    int p = *((int*)data + i);
    printf("data[%i]: %i \n", i, p);
  }

  printf("list index %i \n", list_index);
  property_t add = {type, length, data};
  property_t *add_p = &add;
  property_list[list_index] = add_p;
  ++list_index;
};

void PropertyList::Set(int index, void *data){};

void PropertyList::Print(int index){
  int type;
  int length;
  int data_i;
  int data_c;
  int i;
  
  type = (**(property_list + index)).type;
  length = (**(property_list + index)).length;

  printf("type: %i \n", type);
  printf("length: %i \n", length);

  switch(type){    

  case 1:
    /* int_t */
    for (i = 0; i < length; ++i){ // this FOR loop segfaults ... don't know why...
      /* This is kinda tricky, basically dereference and index(i) 
	 data then typecast, but only after derefrencing and 
	 indexing(index) the property list array */
	 
    data_i = (*(((int*)(**(property_list + index)).data) + i));
    printf("data[%i]: %i", i,  data_i);
    }
    printf("\n");
    break;

  case 2:
    /* char_t */
    for (i = 0; i < length; ++i){
      data_c = *(((char*)(**(property_list + index)).data) + i);
      printf("data[%i]: %c; ", i,  data_c);
    }
    printf("\n");
    break;
  }
}; 

/* Test */
int main(void){
  PropertyList p(2);
  int a[2] = {0, 2};
  p.Add(int_t, 2, &a); 
  p.Print(0);  // this segfaults with a length of more than 2.
};
