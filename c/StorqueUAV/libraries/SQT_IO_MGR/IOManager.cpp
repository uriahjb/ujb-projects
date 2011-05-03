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
IOManager_Class::IOManager_Class(): io_manager_plist(7, "IOMgr") {};

void IOManager_Class::Init(int num_lists, HardwareSerial *serialObj){

  plist_index = 0; 
  transmit_length = 2;

  timer_period1 = 0;
  timer_period2 = 0;
  timer_period3 = 0;

  _rx_buffer = "";
  _rx_len = 0;
  
  /* Set up transmit */
  _tx_locked = false;
  _tx_index = 0;
  

  /* Allocate memory for plist_array */
  plist_array = (PropertyList**)malloc(num_lists*sizeof(PropertyList*));
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

  /* If newline then message complete */
  if (input == '\n'){
    _rx_buffer += input;
    _rx_index = 0;
    serial_handle->println("Message complete");
    _rx_complete_flag = true;
  }else{
    if (_rx_index < RX_BUFFER_SIZE){
      _rx_buffer += input;
    }else{
      /* Message receive fail */
      _rx_buffer = "";
      _rx_index = 0;
    }
  }          
  return;
}
    
    
  
/* ----------------------------------------------------------------------------- */
/* Transmit a set number of chars every loop */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::Transmit(){
  /* If locked, transmit until end of message then unlock */
  if (_tx_locked){
    int i;
    for (i = 0; i < transmit_length; ++i){      
      if ((_tx_index + i) == _tx_buffer.length()){
	// Reset index and unlock
	serial_handle->println();
	_tx_index = 0;
	_tx_locked = false;
	return;
      }else{
	serial_handle->print(_tx_buffer[_tx_index + i]);
      }        
    }
    _tx_index += transmit_length;
  }
  return;
}



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
    if ((plist_array[list_index]->num_requests) > 0){
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
  serial_handle->println("setting flag: ");
  SetFlag(i, index);
  serial_handle->print("checking flag: ");
  serial_handle->println(plist_array[i]->CheckFlag(index));
  serial_handle->print("plist_index: ");
  serial_handle->println(plist_index);
  serial_handle->print("list_index: ");
  serial_handle->println((int)plist_array[i]->Size());
  serial_handle->println("Transmitting");
  String out  = plist_array[i]->Get(index, verbose);
  _tx_buffer = out;
  _tx_locked = true;
  Transmit();
  serial_handle->print("checking flag again: ");
  serial_handle->println(plist_array[i]->CheckFlag(index));
  return out;
 }

/* ----------------------------------------------------------------------------- */
/* Parse Input Buffer  
     - Expects:
        i,n,p,len,data,\n

*/
/* ----------------------------------------------------------------------------- */
int IOManager_Class::_parseInput(){
  serial_handle->println("Parsing Input");
  
  int index = 0;     
  int meta = false;
  int meta_index = 0; // These are for '_' chars
  int rx_len = 0;
  int len_index = 0;
  char current_char = 0;
  _rx_data = "";

  while(current_char != '\n'){
    current_char = _rx_buffer[index];

    if (index == 0){
      if (current_char != 'i'){
	return 0;
      }
    }

    if (index == 1){
      if (current_char != 'n'){
	return 0;
      }
    }

    if (index == 2){
      if (current_char != 'p'){
	return 0;
      }
    }

    if (index == 3){
      if (current_char != '_'){
	return 0;
      }else{
	meta = true;
      }
    }

    // Get Command
    if ((index == 4) && (meta_index == 1)){
      _rx_cmd = current_char;
    }
    
    if (index == 5){
      if (current_char != '_'){
	return 0;
      }else{
	meta = true;;
      }
    }

    // Get Length
    if (meta_index == 2){
      if (current_char == '_'){
	meta = true;
      }else if (current_char == '\n'){    // This might be iffy
	if (rx_len == (index - meta_index - 5)){
	  return 1;
	}else{
	  return 0;
	}
      }else{	
	serial_handle->println("len_index");
	serial_handle->println(len_index);
	// Convert string to int */
      	rx_len = (current_char - '0') + rx_len*10;
	serial_handle->println(rx_len);
	++len_index;	
      }
    }

    if (meta_index > 2){
      if (current_char == '_'){
	++meta_index;
      }
      _rx_data += current_char;
    }

    if (current_char == '\n'){
      
      if (rx_len == (index - meta_index - 5)){
	return 1;
      }else{
        return 0;
      }
    }

    // Increment meta_index meta is found
    if (meta){
      ++meta_index;
      meta = false;
    }
    
    ++index;
	
  }

  return 1;

}  

/* ----------------------------------------------------------------------------- */
/* Handle requests */
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
  _rx_complete_flag = false;

  int parsing_success = _parseInput();
  /* This probably isn't the best place to do this */
  _rx_buffer = ""; 

  if (parsing_success){ 
    serial_handle->println("Parsing success");
  }else{
    serial_handle->println("Parsing Fail");
    return;
  }

  int k;
  for (k = 0; k < _rx_data.length(); ++k){
    Serial.print(_rx_data[k]);
  }
  Serial.println();

  // Handle Receive Commands
  if (_rx_cmd == 'g'){
    serial_handle->println("Getting property");
    GetProperty();
  }
  if (_rx_cmd == 'a'){
    GetAllProperties();    
  }
  /*
  if (_rx_cmd == 's'){
    Set(_rx_buffer[0], _rx_buffer[1]);
  }
    
  // More debugging fun ... prints entire input buffer
  serial_handle->println("Input complete");
  int i;
  for (i = 0; i < _rx_len; ++i){
    serial_handle->print((uint16_t)_rx_buffer[i]);
  }
  serial_handle->println();
  */

  return;
}

/* ----------------------------------------------------------------------------- */
/* Set the request flag for a Property Get request */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::GetProperty(){
  // Set a single request flag

  int i = 0;
  int meta = false;
  int meta_index = 0;
  char current_char = 0;
  int list_index = 0;
  int property_index = 0;

  while(current_char != '\n'){
    current_char = _rx_data[i];
    if (meta_index == 0){
      if (current_char == '_'){
	meta = true;
      }else if (current_char == '\n'){
	return;	
      }else{
	list_index = (current_char - '0') + list_index*10;      	
	serial_handle->println(list_index);
      }
    }
    if (meta_index == 1){
      if (current_char == '_'){
	return;
      }else if (current_char == '\n'){
	  /* Don't anything, just index forward ... out of the while */
      }else{
	property_index = (current_char - '0') + property_index*10;
	serial_handle->println(property_index);    
      }
    }
   
    if (meta){
      ++meta_index;
      meta = false;
    }
    ++i;
  }

  serial_handle->println(list_index);
  serial_handle->println(property_index);    
  SetFlag(list_index, property_index);
}

/* ----------------------------------------------------------------------------- */
/* Set the request flag for a Properties Get All request */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::GetAllProperties(){
  // Set all request flags
  int i;
  int j;
  for (i = 0; i < plist_index; ++i){
    for (j = 0; j < plist_array[i]->Size(); ++j){
      SetFlag(i, j);
    }
  }
}

/* ----------------------------------------------------------------------------- */
/* Set value in property list in property list array */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::SetProperty(int i, int index){
  if (i < plist_index){
    plist_array[i]->_Set(index, _rx_len,  _rx_buffer);
  }
  return;
}

/* ----------------------------------------------------------------------------- */
/* 
   Handle Requests, checks if _tx_locked, thenchecks List and PropertyList get 
   flags to and if _tx_lock is false, sets output buffer equivalent to Property 
   output String 
*/
/* ----------------------------------------------------------------------------- */
void IOManager_Class::HandleRequests(){

  if (!_tx_locked){
    /* Check to see if any lists have requests */
    int i;
    for (i = 0; i < plist_index; ++i){
      if (CheckFlag(i)){
	int j;
	for (j = 0; j < plist_array[i]->Size(); ++j){
	  if (plist_array[i]->CheckFlag(j)){

	    serial_handle->println("Transmitting");
	    int verbose = true;
	    String out = plist_array[i]->Get(j, verbose);	   
	    _tx_buffer = out;
	    serial_handle->println("tx Length");
	    serial_handle->println(_tx_buffer.length());
	    _tx_locked = true;
	    return;
	  }
	}
      }
    }
  }

  return;
};

/* ----------------------------------------------------------------------------- */
/* Run all processes necessary per cycle */
/* ----------------------------------------------------------------------------- */
void IOManager_Class::Loop(){
  Receive();
  HandleInput();
  HandleRequests();
  Transmit();
  return;
}


/* Make single instance of IOManager */
IOManager_Class IOManager;
