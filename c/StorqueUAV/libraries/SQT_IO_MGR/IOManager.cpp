/* ---------------------------------------------------------------------------- */
/* (CPP)
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
	    - sends out a String at a set number of chars per cycle
          Receive:
	    - recieves a single byte every cycle

*/  
/* ----------------------------------------------------------------------------- */

#include "WProgram.h"
#include "IOManager.h"

/* ----------------------------------------------------------------------------- */
/* Method Declarations */
/* PropertyList class:
     - contains:
          property struct
	  current append index
	  number of properties
	  get_flag
*/
/* ----------------------------------------------------------------------------- */
IOManager::IOManager(int num_lists) : io_manager_plist(7, "IOMgr"){

  plist_index = 0; 
  transmit_length = 2;

  timer_period1 = 0;
  timer_period2 = 0;
  timer_period3 = 0;


  /* Allocate memory for plist_array */
  plist_array = (PropertyList**)malloc(num_lists*sizeof(PropertyList));
  plist_size = num_lists;
  
  /* Add properties */
  /*       Format: { index | type | length | data | name } */
  io_manager_plist.Set(0,    Int,   1, &transmit_length, "TxLen");
  io_manager_plist.Set(1,    ULong, 1, &timer_period1,   "TP1");
  io_manager_plist.Set(2,    ULong, 1, &timer_period2,   "TP2");
  io_manager_plist.Set(3,    ULong, 1, &timer_period3,   "TP3");
  io_manager_plist.Set(4,    Int,   1, &plist_index,     "PLindex"); // This one is for debugging
  io_manager_plist.Set(5,    Int,   1, &plist_size,      "PLsize");
  

  Append(&io_manager_plist);
  //  plist_array[plist_index] = &io_manager_plist;
  //++plist_index;

}

/* Append a PropertyList object to array of PropertyLists */
void IOManager::Append(PropertyList *plist){  
  if (plist_index < plist_size){
    plist_array[plist_index] = plist;
    ++plist_index;
  }
}

String IOManager::Test(int i, int index){
  //String out =  io_manager_plist.Get(index);
  String out  = plist_array[i]->Get(index);
  return out;
}
  
  
