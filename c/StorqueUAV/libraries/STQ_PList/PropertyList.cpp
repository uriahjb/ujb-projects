/* ---------------------------------------------------------------------------- */
/* (CPP)
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


/* ------------------------------------------------------------------------ */
/* Includes */
/* ------------------------------------------------------------------------ */
#include "WProgram.h"
#include "PropertyList.h"

/* ------------------------------------------------------------------------ */
/* Method Declarations */
/* PropertyList class:
     - contains:
          property struct
	  current append index
	  number of properties
	  get_flag
*/
/* ------------------------------------------------------------------------ */	  

/* ------------------------------------------------------------------------ */
/* Construct PropertyList, declare memory for property_list, and
   take note of num_properties
*/
/* ------------------------------------------------------------------------ */
PropertyList::PropertyList(int n, String name){
  
  property_list = (property_t*)malloc(n*sizeof(property_t));
  num_properties = n;
  list_name = name;
  list_index = 0;
  num_requests = 0;
  
  /* Initialize relevant property values */
  int i;
  for (i = 0; i < n; ++i){
    property_list[i].flag = 0;
    property_list[i].initialized = false;
  }
}

/* ------------------------------------------------------------------------ */
/* Set values for given property in property_list with name */
/* ------------------------------------------------------------------------ */
int PropertyList::Set(int index, int type, int length, void *data, char *name){

  /* If index too great, fail */
  if (index > num_properties){
    return 0;
  }

  /* Check if property has been initialized */
  if (property_list[index].initialized == false){
    ++list_index;
    property_list[index].initialized = true;
  }

  /* Calculate size, which is equal to length*sizeof(type) */
  int size = 0;
  switch(type){
  case Char: {    
    size = length*sizeof(char);
    break;
  }
  case Int: {
    size = length*sizeof(int);
    break;
  }
  case UInt: {
    size = length*sizeof(unsigned int);
    break;
  }
  case Word: {
    size = length*sizeof(word);
    break;
  }
  case Long: {
    size = length*sizeof(long);
    break;
  }
  case ULong: {
    size = length*sizeof(unsigned long);
    break;
  }
  case Float: {
    size = length*sizeof(float);
    break;
  }
  }
  /* End Switch */


  /* Assign type, length, and data */
  property_list[index].type = type;
  property_list[index].size = size;
  property_list[index].length = length;
  property_list[index].data = data;

  /* Assign a name ... this is basically strcpy */
  unsigned int i;
  for (i = 0; name[i] != '\0'; ++i){
    /* If greater than max name length otherwise continue assign*/
    if (i > 9){
      property_list[index].name[i] = '\0';
      return 0;
    }else{
      property_list[index].name[i] = name[i];    
    }
  }
  property_list[index].name[i] = '\0';

  return 1;
}

/* ------------------------------------------------------------------------ */
/* Set a value that has already been initialized, 
     note: this can return nonesense if the data assigned
           doesn't align with the initialization type
*/
/* ------------------------------------------------------------------------ */
int PropertyList::Set(int index, void *data){

  /* If index too great, fail */
  if (index > num_properties){
    return 0;
  }
  
  /* Check if property has been initialized, if not fail */
  if (property_list[index].initialized == false){
    return 0;
  }
  /* Assign new data */
  property_list[index].data = data;

  return 1;
}

/* ------------------------------------------------------------------------ */
/* Get values for given property in property_list */
/* ... currently by assigning to string */
/* ------------------------------------------------------------------------ */
String PropertyList::Get(int index, int verbose){
 
  /* If index too great, don't get */
  /* Note: need to make this compile error */
  if (index > num_properties){
    String str_error = String("PropertyList::Get; index greater than num_properties");
    return str_error;
  }

  /* Clear Get Flag */
  property_list[index].flag = false; 
  --num_requests;

  property_t *pl = property_list;

  int type;
  int length;
  int i;
  
  String str_space = String(" ");

  String str_out = String(list_name);
  str_out += str_space;  

  /* If verbose. Start with list name and then append item name */
  if (verbose){
    str_out += String((char*)pl[index].name);
    str_out += str_space;
  }
  
  String str_cur;

  /* Begin Switch */
  switch(pl[index].type){  
	
  case Char: {
    char *dp = (char*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_out += String(dp[i]);
    }
    break;
    }
	
  case Int: {
    int *dp = (int*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_out += String(dp[i], DEC);
      // Add a space between ints for funz
      str_out += str_space;
    }
    break;
  }
      
  case UInt: {
    unsigned int *dp = (unsigned int*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_out += String(dp[i], DEC);
      // Add a space between ints for funz
      str_out += str_space;
    }
    break;
  }

  case Word: {
    word *dp = (word*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_out += String(dp[i], DEC);
      // Add a space between ints for funz
      str_out += str_space;
    }
    break;
  }

  case Long: {
    long *dp = (long*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_out += String(dp[i], DEC);
      // Add a space between ints for funz
      str_out += str_space;
    }
    break;
  }

  case ULong: {
    unsigned long *dp = (unsigned long*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_out += String(dp[i], DEC);
      // Add a space between ints for funz
      str_out += str_space;
    }
    break;
  }

    /* This a temporary hack, we need to modify arduino
       WString to include floats */
  case Float: {
    word fl_out = 0;
    float *dp = (float*)pl[index].data; 
    for (i = 0; i < (pl[index].length); i++){
      fl_out = (word)dp[i]*1000;
      str_out += String(fl_out, DEC);
      // Add a space between ints for funz
      str_out += str_space;
    }
    break;
  }

  } 
  /* End Switch */
    
  return str_out;
}

/* ------------------------------------------------------------------------ */
/*
  Set Property value in property list ...
    takes char array ...
    checks if sizes match up ...
    sets property value equal to typecasted char array
*/
/* ------------------------------------------------------------------------ */
void PropertyList::_Set(int property_index, int buffer_len, String &buffer_data){
  
  int i;
  for (i = 0; i < buffer_data.length(); ++i){
    Serial.print(buffer_data[i]);
  }
  Serial.println();

  /* Get type of input */
  int type = property_list[property_index].type;
  
  /* Switch for different types */
  switch(type){
  case Char: {    
    break;
  }
  case Int: {
    break;
  }
  case UInt: {
    break;
  }
  case Word: {
    break;
  }
  case Long: {
    break;
  }
  case ULong: {
    break;
  }
  case Float: {
    break;
  }
  }
  /* End Switch */

  return;
}
    

/* ------------------------------------------------------------------------ */
/* 
   Set get request flag for given property ...
     also make sure that entire list request
     flag is set
*/
/* ------------------------------------------------------------------------ */
void PropertyList::SetFlag(int index){
  if (index < list_index){
    property_list[index].flag = true;
    ++num_requests;
  }
  return;
}

/* ------------------------------------------------------------------------ */
/* Check get flag for a given property */
/* ------------------------------------------------------------------------ */
int PropertyList::CheckFlag(int index){
  if (index < list_index){
    if (property_list[index].flag){
      return true;
    }
  }
  return false;
};


/* ------------------------------------------------------------------------ */
/* Get "Size" of property list */
/* ------------------------------------------------------------------------ */
int PropertyList::Size(){
  return list_index;
}
