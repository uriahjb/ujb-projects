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

#define RX_BUFFER_SIZE 128

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
IOManager_Class::IOManager_Class(): io_manager_plist(7, "IOMgr"){};

void IOManager_Class::Init(int num_lists, HardwareSerial *serialObj){

  plist_index = 0; 
  transmit_length = 2;

  timer_period1 = 0;
  timer_period2 = 0;
  timer_period3 = 0;

  /* Allocated memory for _rx_buffer */
  char rx_buffer[RX_BUFFER_SIZE]; 
  _rx_buffer = rx_buffer;
  _rx_len = 0;
  

  /* Allocate memory for plist_array */
  plist_array = (PropertyList**)malloc(num_lists*sizeof(PropertyList));
  plist_size = num_lists;

  /* Set IO Manager serial handle to assigned serial */     
  serial_handle = serialObj;

  /* Add properties */
  /*       Format: { index | type | length | data | name } */
  io_manager_plist.Set(0,    Int,   1, &transmit_length, "TxLen");
  io_manager_plist.Set(1,    ULong, 1, &timer_period1,   "TP1");
  io_manager_plist.Set(2,    ULong, 1, &timer_period2,   "TP2");
  io_manager_plist.Set(3,    ULong, 1, &timer_period3,   "TP3");
  io_manager_plist.Set(4,    Int,   1, &plist_index,     "PLindex"); // This one is for debugging
  io_manager_plist.Set(5,    Int,   1, &plist_size,      "PLsize");
  
  Append(&io_manager_plist);

}


/* ----------------------------------------------------------------------------- */
/* Read in a char every loop */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::Receive(){
  
  /* Input structure is as follows:
       msg_indicator = 3 char = "inp"
       msg_cmd = 1 char
       msg_len = 0 - RX_BUFFER_LEN
       data;

       chksum??? maybe, ... probably useful
  */


  /* Check if char to be read, otherwise bail */
  if (!serial_handle->available()){
      return;
  }
  
  char input = serial_handle->read();

  if (_rx_index == 0){
    if (input == 'i'){
      serial_handle->println(input);
      ++_rx_index;
    }else{
      _rx_index = 0;
    }
    return;
  }

  if (_rx_index == 1){
    if (input == 'n'){
      serial_handle->println(input);
      ++_rx_index;
    }else{
      _rx_index = 0;
    }
    return;
  }

  if (_rx_index == 2){
    if (input == 'p'){
      serial_handle->println(input);
      ++_rx_index;
    }else{
      _rx_index = 0;
    }
    return;
  }

  if (_rx_index == 3){
    serial_handle->println(input);
    _rx_cmd = input;
    ++_rx_index;
    return;
  }

  if (_rx_index == 4){
    /* Set expected input length */
    if (input < RX_BUFFER_SIZE){
      serial_handle->println((uint16_t)input);
      /* If data length is zero */
      if (input == 0){
        _rx_complete_flag = true;
	_rx_index = 0;
	return;
      }
      _rx_len = input;
      ++_rx_index;
    }else{
      _rx_index = 0;
    }
    return;
  }

  /* Set buffer equivalent to input until end of data */
  if ((_rx_index - 5) < _rx_len){
   serial_handle->println(input);
   serial_handle->println(_rx_index);
   _rx_buffer[_rx_index - 5] = input;
   ++_rx_index;
  }

  /* At end of data set _rx_complete_flag to true */
  if ((_rx_index - 5) == _rx_len){
    _rx_complete_flag = true;
    _rx_index = 0;
  } 
  return;
}
    
    
  
/* ----------------------------------------------------------------------------- */
/* Transmit a set number of chars every loop */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::Transmit(){}
  


/* ----------------------------------------------------------------------------- */
/* Set Flag if requested index is valid */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::SetFlag(int list_index, int property_index){
  if (list_index < plist_index){
    plist_array[list_index]->SetFlag(property_index);
  }
}

/* ----------------------------------------------------------------------------- */
/* Check get_flag for a property list */
/* ----------------------------------------------------------------------------- */
int IOManager_Class::CheckFlag(int list_index){
  if (list_index < plist_index){
    if (plist_array[list_index]->get_request_flag){
      return true;
    }
  }
  return false;
}
  
/* ----------------------------------------------------------------------------- */
/* Append a PropertyList object to array of PropertyLists */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::Append(PropertyList *plist){  
  if (plist_index < plist_size){
    plist_array[plist_index] = plist;
    ++plist_index;
  }
  return;
}

/* ----------------------------------------------------------------------------- */
/* Testing for funz */
/* ----------------------------------------------------------------------------- */
String IOManager_Class::Test(int i, int index, int verbose){
  String out  = plist_array[i]->Get(index, verbose);
  serial_handle->println(out);
  return out;
}

/* ----------------------------------------------------------------------------- */
/* Parse input buffer and handle requests */
/*   Input arguements are defined as follows:
            
       - Get:    'g' | PropertyList Index | Property Index
       - GetAll: 'a'
       
       - Set:    's' | PropertyList Index | Property Index | Data
*/     
/* ----------------------------------------------------------------------------- */
void IOManager_Class::HandleInput(){
  if (!_rx_complete_flag){
    return;
  }

  /* Handle a single get command by setting output flag*/
  if (_rx_cmd == 'g'){
    char list_index = _rx_buffer[0];
    char property_index = _rx_buffer[1];

    // some debugging fun
    serial_handle->println("Get Command");
    serial_handle->println("list index");
    serial_handle->println((uint16_t)list_index);
    serial_handle->println("property index");
    serial_handle->println((uint16_t)property_index);

    SetFlag(list_index, property_index);
  }
    
  /* More debugging fun */   
  serial_handle->println("Input complete");
  int i;
  for (i = 0; i < _rx_len; ++i){
    serial_handle->print((uint16_t)_rx_buffer[i]);
  }
  serial_handle->println();
      
  _rx_complete_flag = false;
  return;
}

/* ----------------------------------------------------------------------------- */
/* 
   Handle Requests, checks List and PropertyList get flags to and if _tx_lock is
   false, sets output buffer equivalent to Property output String 
*/
/* ----------------------------------------------------------------------------- */
void IOManager_Class::HandleRequests(){};

/* ----------------------------------------------------------------------------- */
/* Run all processes necessary per cycle */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::Loop(){
  Receive();
  HandleInput();
  HandleRequests();
  return;
}


/* Make single instance of IOManager */
IOManager_Class IOManager;
