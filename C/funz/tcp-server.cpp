/* ------------------------------------------------------------------ */
/* A test server written in c++ ... hopefully eventually this will
   be ported to a tcp/udp server class that simplifies the process
   of implementing a simple server interface
*/
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/* Includes */
/* ------------------------------------------------------------------ */
#include <iostream>

/* ------------------------------------------------------------------ */
/* Use */
/* ------------------------------------------------------------------ */
using namespace std;

/* ------------------------------------------------------------------ */
/* Main Function */
/* ------------------------------------------------------------------ */
int main(int argc, char *argv[]){
  cout << "Number of Arguments: " << argc << endl;
  
  for (int n = 0; n < argc; n++){
    cout << "argv[" << n << "]: " << argv[n] << endl;
  }
}
