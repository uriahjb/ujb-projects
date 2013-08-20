/* ------------------------------------------------------------------------ */
/* maevarm to host code                                                     */
/*                                                                          */
/*                                                                          */
/* Authors :                                                                */
/*           Storque UAV team:                                              */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 11-12-2010                                                        */
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

#include <avr/io.h>
#include "maevarm.h"
#include "maevarm-usb.h"

// SET BOTH OF THESE TO CORRESPOND TO CORRECT VALUES
// IE: PRESDIV = pow(2,PRESVAL)
// Prescaler Scaling Value
#define PRESVAL 0
// Prescaler Divisor Value
#define PRESDIV 1

int main(void){
  
  /* Do some LED stuffs */
  /* ---------------------------------------------------------- */
  set(DDRE,6);			// Enable output on E6 (Red onboard LED)
  set(DDRE,2);
  clear(PORTE,2);

  /* Set up Timer0 */
  /* ---------------------------------------------------------- */
  clear(TCCR0B,WGM02);     // Count up to OCR0A, then down to 0x00 (PWM mode)
  clear(TCCR0A,WGM01);
  clear(TCCR0A,WGM00);
  set(TCCR0B,CS02);	   // Set timer prescaler at /1024
  clear(TCCR0B,CS01);
  set(TCCR0B,CS00);      

  CLKPR = (1<<CLKPCE);  // Enable changes to prescaler
  CLKPR = PRESVAL;      // set prescaler to /pow(2,PRESVAL) (ie: /PRESDIV)
  
  /* Set up Timer1 (16 bit) */
  /* ---------------------------------------------------------- */
  // Set B6 and B7 as output (Timer1B and Timer1C, respectively)
  set(DDRB,6);
  set(DDRB,7);

  // Set the timer prescaler (currently: /1)
  clear(TCCR1B,CS12);
  set(TCCR1B,CS11);
  clear(TCCR1B,CS10);

  // Set the timer Waveform Generation mode 
  // (currently: Mode 14, up to ICR1)
  set(TCCR1B,WGM13);
  set(TCCR1B,WGM12);
  set(TCCR1A,WGM11);
  clear(TCCR1A,WGM10);

  // Set set/clear mode for Channel B (currently: set at rollover, clear at OCR1A)
  // (OC1B holds state and Pin B6 is multiplexed to state)
  set(TCCR1A,COM1B1);
  clear(TCCR1A, COM1B0);

  // Set set/clear mode for Channel C (currently: set at rollover, clear at OCR1B)
  // State is held in OC1C and Pin B7
  set(TCCR1A, COM1C1);
  clear(TCCR1A, COM1C0);

  #define MAX 2400
  #define MIN 1000
  ICR1 =  20000;
  OCR1A = MIN;
  OCR1B = MIN;
    

  /* Init USB communications */
  /* use: screen /dev/tty.[something] */
  /* ---------------------------------------------------------- */
  unsigned int value;
  usb_init();
  while(!usb_configured()); // wait for a connection

  /* ---------------------------------------------------------- */
  for(;;) {
  
    /* Transmit 16 bit data value to Maevarm = to OCR1B
       Echos back data transmitted */
     if (usb_rx_available()){
       char input;
       input = usb_rx_char();
       if (input == 'u'){
       	 OCR1B = OCR1B + 10;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 'd'){
	 OCR1B = OCR1B - 10;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 'y'){
       	 OCR1B = OCR1B + 50;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 's'){
       	 OCR1B = OCR1B - 50;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 'k'){
	 OCR1B = MIN;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 'i'){
	 OCR1B = MAX; 
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 'm'){
	 OCR1B = MAX - 100;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == 'h'){
	 OCR1B = MAX - (MAX - MIN)/2;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '1'){
	 OCR1B = 1100;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '2'){
	 OCR1B = 1200;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '3'){
	 OCR1B = 1300;
	 	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '4'){
	 OCR1B = 1400;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '5'){
	 OCR1B = 1500;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '6'){
	 OCR1B = 1600;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '7'){
	 OCR1B = 1700;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '8'){
	 OCR1B = 1800;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '9'){
	 OCR1B = 1900;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '0'){
	 OCR1B = 2000;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
       if (input == '['){
         OCR1B = OCR1B - 1;;
	 toggle(PORTE,6);
     	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n'); 
	 }
       if (input == ']'){
	 OCR1B = OCR1B + 1;
	 toggle(PORTE,6);
 	 usb_tx_decimal(OCR1B);
	 usb_tx_char('\n');
       }
     }
  }
}
	
    /* Check ADC value */
    /*
    if (check(ADCSRA,ADIF)) {
      set(ADCSRA,ADIF);		// Clear conversion finished flag
      set(ADCSRA,ADSC);		// Start another conversion
      usb_tx_decimal(ADC);      // Send ADC value through serial
      if (ADC > 512) {
        clear(PORTE,6);         // If V>2.5, turn on LED
      }else{
        set(PORTE,6);		// else, V<2.5, turn off LED
      }
      }*/
