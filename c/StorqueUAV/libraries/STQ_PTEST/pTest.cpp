/* CPP tester */

#include "WProgram.h"
#include <IOManager.h>
#include "pTest.h"

pTest_Class::pTest_Class(): p(3, "Test") {};

void pTest_Class::Init(){

  /* This doesn't seem to work as I would like ... need to fix
  a = (int*)malloc(3*sizeof(int));
  
  a[0] = 1;
  a[1] = 2;
  a[2] = 3;
  */

  a = 1;
  b = 'b';

  p.Set(0, Int, 1, &a, "a");
  p.Set(1, Char, 1, &b, "b");
  
  IOManager.Append(&p);
}

pTest_Class pTest;
  
