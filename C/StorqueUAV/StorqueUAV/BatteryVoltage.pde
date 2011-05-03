/* ------------------------------------------------------------------------ */
/* Storque Battery Voltage Reading     code:                                */
/*                       for reading voltages from BlueLipo 11v Batteries   */
/*                                                                          */
/* Authors :                                                                */
/*           Storque UAV team:                                              */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 11-12-2010                                                        */
/* Version : 0.1 beta                                                       */
/* Hardware : ArduPilot Mega + CHRobotics CHR-6dm IMU (Production versions) */
/*
 This program is free software: you can redistribute it and/or modify 
 it under the terms of the GNU General Public License as published by 
 the Free Software Foundation, either version 3 of the License, or 
 (at your option) any later version. 
 
 This program is distributed in the hope that it will be useful, 
 but WITHOUT ANY WARRANTY; without even the implied warranty of 
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
 GNU General Public License for more details. 
 
 You should have received a copy of the GNU General Public License 
 along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
void BatteryVoltage_Init(){
  
  battery_voltage.sample_time = 0;
  battery_voltage.sample_period = 200;
  battery_voltage.flag = 0;
  
  battery_voltage.v0 = 0;
  battery_voltage.v1 = 0;
  battery_voltage.v2 = 0;
  battery_voltage.v3 = 0;
  
  pinMode(BATTERY0_PIN, INPUT);
  pinMode(BATTERY1_PIN, INPUT);
  pinMode(BATTERY2_PIN, INPUT);
  pinMode(BATTERY3_PIN, INPUT);
 
  return;
}

void BatteryVoltage_Read(){
  
  ftdiPrintln("reading batery");
  battery_voltage.v0 = analogRead(BATTERY0_PIN);
  battery_voltage.v1 = analogRead(BATTERY1_PIN);
  battery_voltage.v2 = analogRead(BATTERY2_PIN);
  battery_voltage.v3 = analogRead(BATTERY3_PIN);
  ftdiPrintln(battery_voltage.v0);
 
  return; 
}

/* ------------------------------------------------------------------------------------ */
/* Print RC Inputs */
/* ------------------------------------------------------------------------------------ */
void BatteryVoltage_Print(uint8_t type){
   
   switch(type){
     
     case(DATA):{
       
       console.tx.transmit_type[0] = 'B';
       console.tx.transmit_type[1] = 'A';
       console.tx.transmit_type[2] = 'T';
       console.tx.cmd = DATA;
       console.tx.len = 15;
       
       
       console.tx.data_typecast[0] = CHAR;
       console.tx.data_typecast[1] = CHAR;
       console.tx.data_typecast[2] = CHAR;
       console.tx.data_typecast[3] = UINT;
       console.tx.data_typecast[4] = CHAR;
       console.tx.data_typecast[5] = CHAR;
       console.tx.data_typecast[6] = CHAR;
       console.tx.data_typecast[7] = UINT;
       console.tx.data_typecast[8] = CHAR;
       console.tx.data_typecast[9] = CHAR;
       console.tx.data_typecast[10] = CHAR;
       console.tx.data_typecast[11] = UINT;
       console.tx.data_typecast[12] = CHAR;
       console.tx.data_typecast[13] = CHAR;
       console.tx.data_typecast[14] = CHAR;
       console.tx.data_typecast[15] = UINT;    
                 
       console.tx.data_char[0] = 'B';
       console.tx.data_char[1] = '0';
       console.tx.data_char[2] = ':';
       console.tx.data_uint[3] = battery_voltage.v0; 
       console.tx.data_char[4] = 'B';
       console.tx.data_char[5] = '1';
       console.tx.data_char[6] = ':';
       console.tx.data_uint[7] = battery_voltage.v1;
       console.tx.data_char[8] = 'B';
       console.tx.data_char[9] = '2';
       console.tx.data_char[10] = ':';
       console.tx.data_uint[11] = battery_voltage.v2;
       console.tx.data_char[12] = 'B';
       console.tx.data_char[13] = '3';
       console.tx.data_char[14] = ':';
       console.tx.data_uint[15] = battery_voltage.v3;         
       
       console.tx.index = 0;
       console.tx.chk = console.tx.transmit_type[0] + console.tx.transmit_type[1] + console.tx.transmit_type[2] \
                         + console.tx.cmd + console.tx.len;
    
       // Figure out the checksum
       for (uint8_t i = 0; i < console.tx.len; i++){ 
         if (console.tx.data_typecast[i] == UINT){
           console.tx.chk += console.tx.data_uint[i];
         }else if (console.tx.data_typecast[i] == INT){
           console.tx.chk += console.tx.data_int[i];
         }else if (console.tx.data_typecast[i] == FLOAT){
           console.tx.chk += console.tx.data_float[i];
         }else if (console.tx.data_typecast[i] == CHAR){
           console.tx.chk += console.tx.data_char[i];
         }
       }
     }
   }
 return; 
}
