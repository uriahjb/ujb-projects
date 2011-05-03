/* ---------------------------------------------------------------------------- */
/* (HEADER)
   Property List: 
      - Capable of containing the following types:         
         - char
         - byte
	 - int
	 - unsigned int
	 - word
	 - long

      - Has methods:
         - Get:
	     returns string of single property
	 - Set:
	     sets the value for a single property
*/
/* ----------------------------------------------------------------------------- */

#ifndef PROPERTY_LIST_H
#define PROPERTY_LIST_H

/* ----------------------------------------------------------------------------- */
/* Includes */
/* ----------------------------------------------------------------------------- */
#include "WProgram.h"

/* ------------------------------------------------------------------------ */
/* Type enumeration */
/* ------------------------------------------------------------------------ */
enum type {
  Char,
  Byte,
  Int,
  UInt,
  Word,
  Long,
  ULong,
  Float,
  Str
};

/* ------------------------------------------------------------------------ */
/* PropertyList class:
     - contains:
          property struct
	  current append index
	  number of properties
	  get_flag
*/
/* ------------------------------------------------------------------------ */	  

class PropertyList {

 public:

  /* Parameters */
  typedef struct property {
    int initialized;
    char name[10];
    int type;
    int length;
    int size;
    void *data;
    int flag;
  } property_t;
  
  String list_name;
  int list_index;
  int num_properties;
  int num_requests;
  
  /* Declare property_list */
  property_t *property_list;
  
  /* Methods */
  PropertyList(int, String name);
  int Set(int index, int type, int length, void *data, char *name);
  int Set(int index, void *data);
  void _Set(int index, int buffer_len, String &buffer_data);
  String Get(int index, int verbose);

  void SetFlag(int index);
  int CheckFlag(int index);
  int Size();
};

#endif
