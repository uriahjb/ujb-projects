/* ---------------------------------------------------------------------------- */
/* (HEADER)
   IO Manager:
     - Manages PropertyList Input and Output streams
     - Has iterable array of property lists, enabling
       browsability of properties
     - Contains its own property list for timers and other IO settings
     - Has Timer based PropertyList Outputs
     - May even have some sort of error/warning Output ability (lets hope)

    - Has Methods:
      - High-Level:
        - AppendList:
           appends PropetyList to PropertyList array (unless array full)
        - GetList: 
           gets entire list if no args, 
	    or gets specified index, 
	    **or maybe gets all specified by array**
	- GetAll: 
	   gets all lists in PropertyList array
	- SetItem
	   sets values for given item based on protocol ... need this


-----> need some sorts of check/set flags <<< probably low level <<<

      - Low-Level: <- this will probably be packaged in a single function
          Transmit:
	    - sends out a set number of chars per cycle
          Receive:
	    - recieves a single byte every cycle

*/  
/* ----------------------------------------------------------------------------- */

#ifndef IO_MANAGER_H
#define IO_MANAGER_H

#include "WProgram.h"
#include <PropertyList.h>

/* ----------------------------------------------------------------------------- */
/* IO Manager Class:
      - contains:
        IO Manager PropertyList
	Timer Compares
	Number of Output bytes

	PropertyList Array
	Number of Lists
*/
/* ----------------------------------------------------------------------------- */

class IOManager {
 public:
  
  /* Parameters */
  /* Property List Array ... currently with fixed number of propertylists */
  int plist_index;
  int plist_size;
  PropertyList **plist_array;
  
  /* The IOManager's own property list */
  PropertyList io_manager_plist;
  
  /* Three timers to generate IO events */
  unsigned long timer_compare1;
  unsigned long timer_compare2;
  unsigned long timer_compare3;
  unsigned long timer_period1;
  unsigned long timer_period2;
  unsigned long timer_period3;

  int transmit_length;

  /* Methods */
  IOManager(int);
  void Append(PropertyList *plist);
  String Test(int, int);

};

#endif
	    
